---
title: App SDK - Store and Forward
---

# App Functions SDK - Store and Forward

The Store and Forward capability allows for export functions to persist data on failure and for the export of the data to be retried at a later time. 

!!! note
    The order the data exported via this retry mechanism is not guaranteed to be the same order in which the data was initial received from Core Data

## Configuration

`Writable.StoreAndForward` allows enabling, setting the interval between retries and the max number of retries. If running with Configuration Provider, these settings can be changed on the fly via Consul without having to restart the service.

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

Database configuration section describes which database type to use and the information required to connect to the database. This section is required if Store and Forward is enabled and is provided in [Common Configuration](../../../configuration/CommonConfiguration.md#common-configuration-properties). 

!!! example "Example - Database configuration"
    ```yaml
    Database:
      Type: "postgres"
      Host: "localhost"
      Port: 5432
      Timeout: "5s"
    ```

## How it works

When an export function encounters an error sending data it can call `SetRetryData(payload []byte)` on the `AppFunctionContext`. This will store the data for later retry. If the Application Service is stopped and then restarted while stored data hasn't been successfully exported, the export retry will resume once the service is up and running again.

!!! note
    It is important that export functions return an error and stop pipeline execution after the call to `SetRetryData`. See [HTTPPost](https://github.com/edgexfoundry/app-functions-sdk-go/blob/{{edgexversion}}/pkg/transforms/http.go) function in SDK as an example

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

## Custom Storage
The default backing store is PostgreSQL.  Custom implementations of the `StoreClient` interface can be provided if PostgreSQL does not meet your requirements.

```go
type StoreClient interface {
	// Store persists a stored object to the data store and returns the assigned UUID.
	Store(o StoredObject) (id string, err error)

	// RetrieveFromStore gets an object from the data store.
	RetrieveFromStore(appServiceKey string) (objects []StoredObject, err error)

	// Update replaces the data currently in the store with the provided data.
	Update(o StoredObject) error

	// RemoveFromStore removes an object from the data store.
	RemoveFromStore(o StoredObject) error

	// Disconnect ends the connection.
	Disconnect() error
}
```
A factory function to create these clients can then be registered with your service by calling [RegisterCustomStoreFactory](../api/ApplicationServiceAPI.md#registercustomstorefactory)

```go
service.RegisterCustomStoreFactory("jetstream", func(cfg interfaces.DatabaseInfo, cred config.Credentials) (interfaces.StoreClient, error) {
    conn, err := nats.Connect(fmt.Sprintf("nats://%s:%d", cfg.Host, cfg.Port))
    
    if err != nil {
        return nil, err
    }
    
    js, err := conn.JetStream()
    
    if err != nil {
        return nil, err
    }
    
    kv, err := js.KeyValue(serviceKey)
    
    if err != nil {
        kv, err = js.CreateKeyValue(&nats.KeyValueConfig{Bucket: serviceKey})
    }
    
    return &JetstreamStore{
        conn:       conn,
        serviceKey: serviceKey,
        kv:         kv,
    }, err
})
```

and configured using the registered name in the `Database` section:

!!! example "Example - Database configuration"
    ```yaml
    Database:
      Type: "jetstream"
      Host: "broker"
      Port: 4222
      Timeout: "5s"
    ```
