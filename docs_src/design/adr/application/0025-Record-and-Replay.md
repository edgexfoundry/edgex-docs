# Record and Replay ADR

## Submitters
- Lenny Goodell (Intel)

## Change Log
- [Pending](https://github.com/edgexfoundry/edgex-docs/pull/863) (2022-09-20)

## Referenced Use Case(s)
- [Record and Replay UCR](https://docs.edgexfoundry.org/2.3/design/ucr/Record-and-Replay/)

## Context
This design involves creating a new Application Service that is responsible for the requirements in the above referenced UCR. This new Application Service will go above and beyond that of a normal Application Service,  thus it is architecturally significant.

## Proposed Design
A new Application Service will be created with a RESTful API to handle the Record, Replay, Export and Import capabilities. The service will not create or start a Functions Pipeline on start-up as normally done in Application Services. It will wait until the Record request has been received. Once the recording is complete the Functions Pipeline will be stopped. 

!!! note
    Application Services do not receive data when the Functions Pipelines are stopped.

### Record Endpoint

This `POST` API will start recording data as specified in the [request Data Transfer Object (DTO)](#record-request-dto) defined below. The request handler will validate the DTO and then create a new Functions Pipeline and [Start the Functions Pipeline](https://docs.edgexfoundry.org/2.3/microservices/application/ApplicationServiceAPI/#makeitrun) to process incoming data. 

The Functions Pipeline will contain the following pipeline functions in the following order

- [Filter functions](https://docs.edgexfoundry.org/2.3/microservices/application/BuiltIn/#filtering) if filtering is needed, configured based on the DTO parameters.
- [Batching pipeline function](https://docs.edgexfoundry.org/2.3/microservices/application/BuiltIn/#batching) configured based on the DTO parameters. This will be used to control the record duration/count. 
- New pipeline function written to process the batched data once the batching threshold has been exceeded. This function will simply send the recorded data to an async function for processing. 

The async  function receiving the data will first [stop the Functions Pipeline](https://docs.edgexfoundry.org/2.3/microservices/application/ApplicationServiceAPI/#makeitstop) and then save the data for later replay and/or export. It will also determine the list of unique Device Profile and Device Names from the data and store them along side the recorded data. Since app services can receive Events out of order per their timestamps, the saved Event data must be sorted by the Event timestamps. All data will saved in in-memory storage. 

!!! note
    Starting a new recording will overwrite any previous recorded data.

#### Record Request DTO

##### Duration

Time duration in which to record data. Required if **Event Limit** is not specified.

##### Event Limit 

Maximum number `Events` to record. Required if **Duration** is not specified

##### Include Device Profile Names 

Optional list of Device Profile Names to filter for

##### Include Device Names

Optional list of Device Names to filter for

##### Exclude Device Profile Names

Optional list of Device Profile Names to filter out

##### Exclude Device Names

Optional list of Device Names to filter out

### Replay endpoint

This `POST` API will start replaying the recorded data as specified in the [request Data Transfer Object (DTO)](#replay-request-dto) defined below. The request handler will validate the DTO and that the appropriate Device Profiles and Devices from the data exist. It will then start an async Go function to handle the replay so the request doesn't timeout on long replays. 

The replay async Go function will use the [Background Publishing](https://docs.edgexfoundry.org/2.3/microservices/application/AdvancedTopics/#background-publishing) capability to send the recorded Events to the EdgeX MessageBus using the same publish topic scheme used by Device Services, which is `edgex/events/device/<device-profile-name>/<device-name>/<source-name>`. The App SDK has the  [Publish Topic Placeholders](https://docs.edgexfoundry.org/2.3/microservices/application/Triggers/#publish-topic-placeholders) capability built-in to facilitate this. The data for these topics is available from the Event DTO. The timestamps in the Events and Readings published will be set to the current date/time. This requires a copy be made of the Event/Readings as they are published in order to not corrupt the original data.

Once the first event is published the replay function will calculate the wait time to use before sending the next Event from the recorded data. This will be based on the time difference from the original timestamp of the previous event published and the timestamp of the next event multiplied by the inverse of the `Replay Rate` specified in the request DTO. 

!!! example - "Examples - Replay Rate wait time calculation"
    Delta time between original Events is 800ms<br/>
    Replay rate is 2.0 (100% faster) making wait time 400ms (800ms * (1 / 2.0))<br/>
    Replay rate is 0.5 (100% slower) making wait time 1600ms (800ms * (1 / 0.5))

The replay function will repeat publishing the recorded data per the `Repeat Count` in from the DTO. 

#### Replay Request DTO

##### Replay Rate

Required rate at which to replay the data compared to the rate the data was recorded. Float value greater than 0 where 1 is the same rate, less than 1 is slower rate and greater than 1 is faster rate than the rate the data was recorded. 

##### Repeat Count

Optional count of number of times to repeat the replay. Default is 1 if not specified or value is 0.

### Download endpoint (Export)

This `GET` API will request that the previously recorded data be exported as a file download. It will accept an optional query parameter to specify compression (NONE, ZIP or GZIP). An error is returned if no data has been recorded or invalid compression type requested.

The file content will be the [Recorded Data DTO](#recorded-data-dto) as define below. The request handler will build the DTO described below by extracting the recorded `Events` from in-memory storage, pulling the referenced `Device Profiles` and `Devices` from Core Metadata using the names from in-memory storage. The file extension used will be `.json`, `.zip` or `.gzip` depending on the compression selected.

#### Recorded Data DTO

##### Events

List of `Events` (with `Readings`) that were recorded

##### Device Profiles

List of `Device Profiles` (complete profiles) that are referenced in the recorded `Events` 

##### Devices

List of `Device defintions` that are referenced in the recorded `Events` 

### Upload endpoint (Import)

This `POST` API will upload previously exported recorded data file. It will accept an optional Boolean query parameter to specify to **not** overwrite existing Device Profiles and/or Devices if they already exist. Default is to overwrite existing with those captured with the recorded data.

The request handler will receive the file as a [Recorded Data DTO](#recorded-data-dto) described above and detect if it is compressed and un-compress the contents if needed before un-marshaling the JSON into the DTO. The compression will be determined based on the file extension. The `Event` data from the DTO will then be saved to the in-memory storage along with the Device Profile and Device Names. The `Device Profiles` and `Devices` will be pushed to Core Metadata if they don't exist or if overwrite is enabled.  

!!! note
    Import will overwrite any previous recorded data.

## Considerations
- Only one recorded data set is available for replay.
- The whole data set is replayed. Can not specify to replay data for specific Devices within the larger data set.
- Wait times simulating rate of Events published will not be perfect since dependent on non-Realtime OS.

## Decision
Implement this design as outlined above

## Other Related ADRs
- None

## References
- [Application SDK documentation](https://docs.edgexfoundry.org/2.2/microservices/application/ApplicationFunctionsSDK/)
