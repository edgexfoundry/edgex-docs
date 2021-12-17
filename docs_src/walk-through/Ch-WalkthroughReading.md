# Sending events and reading data

In the real world, the human/dog counting camera would start to take
pictures, count beings, and send that data to EdgeX. To simulate this
activity in this section of the walkthrough, you will make core data API calls as if you
were the camera's device and device service.  That is, you will report human and dog counts to core data in the form of event/reading objects.

## Send an Event/Reading

See [core data API](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-data/2.1.0) for more details.

Data is submitted to core data as an `Event` object. An event is a collection of
sensor readings from a device (associated to a device by its name)
at a particular point in time. A `Reading` object in an `Event` object is a particular
value sensed by the device and associated to a Device Resource (by name) to
provide context to the reading. 

So, the human/dog counting camera might
determine that there are 5 people and 3 dogs in the space it is
monitoring. In the EdgeX vernacular, the device service upon receiving
these sensed values from the camera device would create an `Event` with two
`Reading`s - one `Reading` would contain the key/value pair of HumanCount:5
and the other `Reading` would contain the key/value pair of CanineCount:3.

The device service, on creating the `Event` and associated `Reading` objects
would transmit this information to core data via REST call.

### Walkthrough - Send Event

Use either the Postman or Curl tab below to walkthrough sending an `Event` with `Reading`s to core data.

=== "Postman"

    Make a POST request to `http://localhost:59880/api/v2/event/camera-monitor-profile/countcamera1/HumanCount with the body below.

    ``` json
            {
                "apiVersion": "v2",
                "event": {
                    "apiVersion": "v2",
                    "deviceName": "countcamera1",
                    "profileName": "camera-monitor-profile",
                    "sourceName": "HumanCount",
                    "id": "d5471d59-2810-419a-8744-18eb8fa03465",
                    "origin": 1602168089665565200,
                    "readings": [
                        {
                            "id": "7003cacc-0e00-4676-977c-4e58b9612abd",
                            "origin": 1602168089665565200,
                            "deviceName": "countcamera1",
                            "resourceName": "HumanCount",
                            "profileName": "camera-monitor-profile",
                            "valueType": "Int16",
                            "value": "5"
                        },
                        {
                            "id": "7003cacc-0e00-4676-977c-4e58b9612abe",
                            "origin": 1602168089665565200,
                            "deviceName": "countcamera1",
                            "resourceName": "CanineCount",
                            "profileName": "camera-monitor-profile",
                            "valueType": "Int16",
                            "value": "3"
                        }                        
                    ]
                }
            }
    ```

    If your API call is successful, you will get a generated ID for your new `Event` as shown in the image below.

    ![image](EdgeX_WalkthroughSendEvent.png)

    !!! Note Info
        Notice that the POST request URL contains the device profile name, the device name and the device resource (or device command) associated with the device that is providing the event.

=== "Curl"

    Make a curl POST request as shown below.

    ``` shell
    curl -X POST -d '{"apiVersion": "v2","event": {"apiVersion": "v2","deviceName": "countcamera1","profileName": "camera-monitor-profile","sourceName": "HumanCount","id":"d5471d59-2810-419a-8744-18eb8fa03464","origin": 1602168089665565200,"readings": [{"id": "7003cacc-0e00-4676-977c-4e58b9612abc","origin": 1602168089665565200,"deviceName": "countcamera1","resourceName": "HumanCount","profileName": "camera-monitor-profile","valueType": "Int16","value": "5"},{"id": "7003cacc-0e00-4676-977c-4e58b9612abf","origin":1602168089665565200,"deviceName": "countcamera1","resourceName": "CanineCount","profileName": "camera-monitor-profile","valueType": "Int16","value": "3"}]}}' localhost:59880/api/v2/event/camera-monitor-profile/countcamera1/HumanCount
    ```

    ![image](EdgeX_WalkthroughSendEvent_Curl.png)

    !!! Note Info
        Notice that the POST request URL contains the device profile name, the device name and the device resource (or device command) associated with the device that is providing the event.

#### Origin Timestamp
The device service will supply an origin property in the `Event` and `Reading` object to suggest the time (in Epoch
timestamp/milliseconds format) at which the data was sensed/collected.

!!! Note
    Smart devices will often timestamp sensor data and this timestamp
    can be used as the origin timestamp. In cases where the sensor/device is
    unable to provide a timestamp ("dumb" or brownfield sensors), it is the device service that creates a timestamp for the sensor
    data that it be applied as the origin timestamp for the device.

## Exploring Events/Readings

Now that an `Event` and associated `Readings` have been sent to
core data, you can use the core data API to explore that data that is
now stored in the database.

Recall from a [previous walkthrough step](./Ch-WalkthroughCommands.md#walkthrough-events), you checked that no data was yet
stored in core data. Make a similar call to see event records have now been sent into core data..

### Walkthrough - Query Events/Readings

Use either the Postman or Curl tab below to walkthrough getting the list of events.

=== "Postman"

    Make a GET request to retrieve the `Event`s associated to the `countcamera1` device: `http://localhost:59880/api/v2/event/device/name/countcamera1`.

    Make a GET request to retrieve the `Reading`s associated to the `countcamera1` device: `http://localhost:59880/api/v2/reading/device/name/countcamera1`.

=== "Curl"

    Make a curl GET requests to retrieve 10 of the last `Event`s associated to the `countcamera1` device and to retrieve 10 of the human count readings associated to `countcamera1`

    ``` shell
    curl -X GET localhost:59880/api/v2/event/device/name/countcamera1 | json_pp
    curl -X GET localhost:59880/api/v2/reading/device/name/countcamera1 | json_pp
    ```

There are [many additional APIs on core data](https://app.swaggerhub.com/apis/EdgeXFoundry1/core-data/2.1.0) to retrieve `Event` and `Reading` data. As an example, here is one to find all events inside of a start and end time range.

``` shel
curl -X GET localhost:59880/api/v2/event/start/1602168089665560000/end/1602168089665570000 | json_pp
```

[<Back](Ch-WalkthroughCommands.md){: .md-button } [Next>](Ch-WalkthroughExporting.md){: .md-button }
