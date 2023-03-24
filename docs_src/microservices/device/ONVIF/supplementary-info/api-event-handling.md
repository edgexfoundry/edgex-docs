# Event Handling

The device service shall be able to use at least one way to retrieve events out of the following:
* **PullPoint** - "Pull" using the CreatePullPointSubscription and PullMessage operations
* **BaseNotification** - "Push" using Notify, Subscribe and Renew operations from WSBaseNotification

The spec can refer to https://www.onvif.org/ver10/events/wsdl/event.wsdl and https://docs.oasis-open.org/wsn/wsn-ws_base_notification-1.3-spec-os.pdf


## Define the device resources for Event Handling

### Define a CameraEvent resource for device service to publish the event
Before receiving the event data from the camera, we must define a device resource for the event.
```yaml
- name: "CameraEvent"
 isHidden: true
 description: "This resource is used to send the async event reading to north bound"
 attributes:
   service: "EdgeX"
   getFunction: "CameraEvent"
 properties:
   valueType: "Object"
   readWrite: "R"
```

### Define device resource for PullPoint

* Define a SubscribeCameraEvent resource with PullPoint subscribeType for creating the subscription
    ```yaml
    - name: "SubscribeCameraEvent"
     isHidden: false
     description: "Create a subscription to subscribe the event from the camera"
     attributes:
       service: "EdgeX"
       setFunction: "SubscribeCameraEvent"
       # PullPoint | BaseNotification
       subscribeType: "PullPoint"
       defaultSubscriptionPolicy: ""
       defaultInitialTerminationTime: "PT1H"
       defaultAutoRenew: true
       defaultTopicFilter: "tns1:RuleEngine/TamperDetector"
       defaultMessageContentFilter: "boolean(//tt:SimpleItem[@Name=”IsTamper”])"
       defaultMessageTimeout: "PT5S"
       defaultMessageLimit: 10
     properties:
       valueType: "Object"
       readWrite: "W"
    ```

* Define a UnsubscribeCameraEvent resource for unsubscribing
    ```yaml
    - name: "UnsubscribeCameraEvent"
     isHidden: false
     description: "Unsubscribe all event from the camera"
     attributes:
       service: "EdgeX"
       setFunction: "UnsubscribeCameraEvent"
     properties:
       valueType: "Object"
       readWrite: "W"
    ```

### Define device resource for BaseNotification

* Define a SubscribeCameraEvent resource with BaseNotification subscribeType
    ```yaml
    - name: "SubscribeCameraEvent"
     isHidden: false
     description: "Create a subscription to subscribe the event ..."
     attributes:
       service: "EdgeX"
       setFunction: "SubscribeCameraEvent"
       # PullPoint | BaseNotification
       subscribeType: "BaseNotification"
       defaultSubscriptionPolicy: ""
       defaultInitialTerminationTime: "PT1H"
       defaultAutoRenew: true
       defaultTopicFilter: "..."
       defaultMessageContentFilter: "..."
     properties:
       valueType: "Object"
       readWrite: "W"
    ```

* Define a driver config BaseNotificationURL to indicate the device service network location
    ```
    # configuration.toml
    [Driver]
    # BaseNotificationURL indicates the device service network location, the user must replace the host to match their machine
    BaseNotificationURL = "http://192.168.12.112:59984"
    ```

Device service will generate the following path for pushing event from Camera to device service:
- {BaseNotificationURL}/api/v2/resource/{DeviceName}/{ResourceName}
- {BaseNotificationURL}/api/v2/resource/Camera1/CameraEvent

**Note**: The user can also override the config from the docker-compose environment variable:
```shell
export HOST_IP=$(ifconfig eth0 | grep "inet " | awk '{ print $2 }')
```
```yaml
environment:
   DRIVER_BASENOTIFICATIONURL: http://${HOST_IP}:59984
```
Then the device service can be accessed by the external camera from the other subnetwork.

### Define device resource for unsubscribing the event
```yaml
  - name: "UnsubscribeCameraEvent"
    isHidden: true
    description: "Unsubscribe all subscription from the camera"
    attributes:
      service: "EdgeX"
      setFunction: "UnsubscribeCameraEvent"
    properties:
      valueType: "Object"
      readWrite: "W"
```

## Find the supported Event Topics
Finding out what notifications a camera supports and what information they contain:

```shell
curl --request GET 'http://localhost:59882/api/v2/device/name/Camera003/GetEventProperties'
```

## Create a Pull Point
User can create pull point with the following command:
```shell
curl --request PUT 'http://localhost:59882/api/v2/device/name/Camera003/PullPointSubscription' \
--header 'Content-Type: application/json' \
--data-raw '{
    "PullPointSubscription": {
        "MessageContentFilter": "boolean(//tt:SimpleItem[@Name=\"Rule\"])",
        "InitialTerminationTime": "PT120S",
        "MessageTimeout": "PT20S"
    }
}'
```

**Note**:
* Device service uses a loop to pull message, and the subscription auto-renew by camera
* Device service create a new pull point when the pull point expired
* User can unsubscribe the subscription, then the device service will stop the loop to pull the message and execute unsubscribe Onvif function.

## Create a BaseNotification
User can create subscription, the InitialTerminationTime is required and should greater than ten seconds:
```shell
curl --request PUT 'http://localhost:59882/api/v2/device/name/Camera003/BaseNotificationSubscription' \
--header 'Content-Type: application/json' \
--data-raw '{
    "BaseNotificationSubscription": {
        "TopicFilter": "tns1:RuleEngine/TamperDetector/Tamper",
        "InitialTerminationTime": "PT180S"
    }
}'
```

**Note**:
- Device service send Renew request every ten second before termination time
- User can unsubscribe the subscription, then the device service stop to renew the subscription 

## Unsubscribe all subscriptions
The user can unsubscribe all subscriptions(PullPoint and BaseNotification) from the camera with the following command:
```shell
curl --request PUT 'http://localhsot:59882/api/v2/device/name/Camera003/UnsubscribeCameraEvent' \
--header 'Content-Type: application/json' \
--data-raw '{
    "UnsubscribeCameraEvent": {
    }
}'
```
