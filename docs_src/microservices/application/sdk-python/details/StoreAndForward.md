---
title: App SDK - Store and Forward
---

# App Functions SDK for Python - Store and Forward

The Store and Forward capability allows for export functions to persist data on failure and for the export of the data to be retried at a later time. 

!!! note
    The order the data exported via this retry mechanism is not guaranteed to be the same order in which the data was initial received from Core Data

## Configuration

`Writable.StoreAndForward` allows enabling, setting the interval between retries and the max number of retries. If running with Configuration Provider, these settings can be changed on the fly via Keeper without having to restart the service.

!!! example "Example - Store and Forward configuration"
    ```yaml
    Writable:
      StoreAndForward:
        Enabled: false
        RetryInterval: "5m"
        MaxRetryCount: 10
    ```

!!! note
    RetryInterval should be at least 1 second (e.g. '1s') or greater. If a value less than 1 second is specified, 1 second will be used. Endless retries will occur when MaxRetryCount is set to 0. If MaxRetryCount is set to less than 0, a default of 1 retry will be used.

Database configuration section describes which database type to use and the information required to connect to the database. This section is required if Store and Forward is enabled. 

!!! example "Example - Database configuration"
    ```yaml
    Database:
      Type: "sqlite"
      Host: "./app-service.db"
    ```

!!! note
    The current python SDK supports `sqlite` as the Database Type only. If you specify a different type other than `sqlite`, the application service cannot be properly initialized.

## How it works

When an export function encounters an error sending data it can call `set_retry_data(data: bytes)` on the `AppFunctionContext`. This will store the data for later retry. If the Application Service is stopped and then restarted while stored data hasn't been successfully exported, the export retry will resume once the service is up and running again.

!!! note
    It is important that export functions return an error and stop pipeline execution after the call to `set_retry_data`. See following code as an example:
    ```python
    from typing import Any, Tuple
    from app_functions_sdk_py.contracts import errors
    from app_functions_sdk_py.interfaces import AppFunctionContext
    ...
    def export_data(ctx: AppFunctionContext, data: Any) -> Tuple[bool, Any]:
        try:
            # call a function to send data
            function_to_send(data)
        except Exception as e:
            # when any exception occurs, call set_retry_data, stop pipeline execution and return error
            ctx.set_retry_data(data)
            return False, errors.new_common_edgex(errors.ErrKind.CONTRACT_INVALID,f"fail to send data: {e}")
        return True, None
    ...
    ```

When the `RetryInterval` expires, the function pipeline will be re-executed starting with the export function that saved the data. The saved data will be passed to the export function which can then attempt to resend the data. 

!!! note
    The export function will receive the data as it was stored, so it is important that any transformation of the data occur in functions prior to the export function. The export function should only export the data that it receives.

One of three outcomes can occur after the export retried has completed. 

1. Export retry was successful

    In this case, the stored data is removed from the database and the execution of the pipeline functions after the export function, if any, continues. 

2. Export retry fails and retry count `has not been` exceeded

    In this case, the stored data is updated in the database with the incremented retry count

3. Export retry fails and retry count `has been` exceeded

    In this case, the stored data is removed from the database and never retried again.

!!! note
    Changing Writable.Pipeline.ExecutionOrder will invalidate all currently stored data and result in it all being removed from the database on the next retry. This is because the position of the *export* function can no longer be guaranteed and no way to ensure it is properly executed on the retry.
