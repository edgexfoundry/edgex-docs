---
title: App Service Configurable - Available Profiles
---

# App Service Configurable - Available Profiles

App Service Configurable was designed to be deployed as multiple instances for different purposes. 
Since the function pipeline is specified in the `configuration.yaml` file, we can use this as a way to run each instance
with a different function pipeline. App Service Configurable does not have the standard default configuration 
at `/res/configuration.yaml`. This default configuration has been moved to the `sample` profile. 
This forces user to specify the profile for the configuration you would like to run. 
The profile is specified using the `-p/--profile=[profilename]` command line option or 
the `EDGEX_PROFILE=[profilename]` environment variable override. 
The profile name selected is used in the service key (`app-[profile name]`) to make each instance unique, 
e.g. `AppService-sample` when specifying `sample` as the profile.

!!! note
    If you need to run multiple instances with the same profile, e.g. `http-export`, but configured differently, you will need to override the service key with a custom name for one or more of the services. This is done with the `-sk/-serviceKey` command-line option or the `EDGEX_SERVICE_KEY` environment variable. See the [Command-line Options](../../../details/CommandLine.md#service-key) and [Environment Overrides](../../../details/EnvironmentVariables.md#edgex_service_key) sections for more detail.

!!! note
    Functions can be declared in a profile but not used in the pipeline `ExecutionOrder`  allowing them to be added to the pipeline `ExecutionOrder` later at runtime if needed.

The following profiles and their purposes are provided with App Service Configurable. 

### rules-engine

Profile used to push Event messages to the Rules Engine via the **Redis Pub/Sub** Message Bus. This is used in the default docker compose files for the `app-rules-engine` service

One can optionally add Filter function via environment overrides

- `WRITABLE_PIPELINE_EXECUTIONORDER: "FilterByDeviceName, HTTPExport"`
- `WRITABLE_PIPELINE_FUNCTIONS_FILTERBYDEVICENAME_PARAMETERS_DEVICENAMES: "[comma separated list]"`

There are many optional functions and parameters provided in this profile. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/{{edgexversion}}/res/rules-engine/configuration.yaml) for more details

## http-export

Starter profile used for exporting data via HTTP.  Requires further configuration which can easily be accomplished using environment variable overrides

Required:

- `WRITABLE_PIPELINE_FUNCTIONS_HTTPEXPORT_PARAMETERS_URL: [Your URL]`

  There are many more optional functions and parameters provided in this profile. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/{{edgexversion}}/res/http-export/configuration.yaml) for more details.

## metrics-influxdb

Starter profile used for exporting telemetry data from other EdgeX services to InfluxDB via HTTP export. This profile configures the service to receive telemetry data from other services, transform it to Line Protocol syntax, batch the data and then export it to an InfluxDB service via HTTP. Requires further configuration which can easily be accomplished using environment variable overrides.

Required:

- `WRITABLE_PIPELINE_FUNCTIONS_HTTPEXPORT_PARAMETERS_URL: [Your InfluxDB URL]`

  - Example value: `"http://localhost:8086/api/v2/write?org=metrics&bucket=edgex&precision=ns"``

- ``WRITABLE_INSECURESECRETS_INFLUXDB_SECRETS_TOKEN`: [Your InfluxDB Token]

  - Example value: `"Token 29ER8iMgQ5DPD_icTnSwH_77aUhSvD0AATkvMM59kZdIJOTNoJqcP-RHFCppblG3wSOb7LOqjp1xubA80uaWhQ=="`

  - If using secure mode, store the token in the service's secret store via POST to the service's `/secret` endpoint 


  !!! example - "Example JSON to post to /secret endpoint"
      ```json
      {
          "apiVersion":"v2",
          "secretName":"influxdb",
          "secretData":[
          {
              "key":"Token",
              "value":"Token 29ER8iMgQ5DPD_icTnSwH_77aUhSvD0AATkvMM59kZdIJOTNoJqcP-RHFCppblG3wSOb7LOqjp1xubA80uaWhQ=="
          }]
      }
      ```

Optional Additional Tags:

- `WRITABLE_PIPELINE_FUNCTIONS_TOLINEPROTOCOL_PARAMETERS_TAGS: <your additional tags>`
  - Currently set to empty string
  - Example value: `"tag1:value1, tag2:value2"

Optional Batching parameters (see [Batch function](AvailablePipelineFunctions.md#batch) for more details):

- `WRITABLE_PIPELINE_FUNCTIONS_BATCH_PARAMETERS_MODE: <your batch mode>`
  - Currently set to `"bytimecount"`
    - Valid values are `"bycount"`, `"bytime"` or `"bytimecount"``
- ``WRITABLE_PIPELINE_FUNCTIONS_BATCH_PARAMETERS_BATCHTHRESHOLD: <your batch threshold count>`
  - Currently set to `100`
- `WRITABLE_PIPELINE_FUNCTIONS_BATCH_PARAMETERS_TIMEINTERVAL: <your batch time interval>`
  - Currently set to `"60s"`

## mqtt-export

Starter profile used for exporting data via MQTT. Requires further configuration which can easily be accomplished using environment variable overrides

Required:

- `WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS: [Your Broker Address]`


    There are many optional functions and parameters provided in this profile. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/{{edgexversion}}/res/mqtt-export/configuration.yaml) for more details

## sample

Sample profile with all available functions declared and a sample pipeline. Provided as a sample that can be copied and modified to create new custom profiles. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/{{edgexversion}}/res/sample/configuration.yaml) for more details

## functional-tests

Profile used for the TAF functional testing  

## external-mqtt-trigger

Profile used for the TAF functional testing  of external MQTT Trigger