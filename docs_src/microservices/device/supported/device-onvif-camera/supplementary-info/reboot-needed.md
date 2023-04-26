# RebootNeeded

!!! Warning
      Information in this page may be outdated.

Currently, only the SetNetworkInterfaces function returns the **RebootNeeded** value. If **RebootNeeded** is true, the user needs to reboot the camera to apply the config changes.

Since the Set command can't return the **RebootNeeded** value in the command response, the device service will store the value, then the user can use the custom web service **EdgeX** and function **RebootNeeded** to check the value.

## How does the RebootNeeded work with EdgeX?


1. Execute Set command to change the networkInterfaces setting:
   ```bash
   curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/Camera001/NetworkInterfaces' \
   --header 'Content-Type: application/json' \
   --data-raw '{
      "NetworkInterfaces": {
         "InterfaceToken": "eth0",
         "NetworkInterface": {
               "Enabled": true,
               "IPv4": {
                  "DHCP": true
               }
         } 
      }
   }'
   ```
2. Check the RebootNeeded value:
   ```bash
   $ curl 'http://0.0.0.0:59882/api/v2/device/name/Camera001/RebootNeeded' | jq .
   {
      "apiVersion" : "v2",
      "event" : {
         "apiVersion" : "v2",
         "deviceName" : "Camera001",
         "id" : "e370bbb5-55d2-4392-84ca-8d9e7f097dae",
         "origin" : 1635750695886624000,
         "profileName" : "onvif-camera",
         "readings" : [
            {
               "deviceName" : "Camera001",
               "id" : "abd5c555-ef7d-44a7-9273-c1dbb4d14de2",
               "origin" : 1635750695886624000,
               "profileName" : "onvif-camera",
               "resourceName" : "RebootNeeded",
               "value" : "true",
               "valueType" : "Bool"
            }
         ],
         "sourceName" : "RebootNeeded"
      },
      "statusCode" : 200
   }
   ```
   The **RebootNeeded** value is true which indicates the camera should reboot to apply the necessary changes.

3. Reboot the camera to apply the change:
   ```shell
   curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/Camera001/SystemReboot' \
   --header 'Content-Type: application/json' \
   --data-raw '{
      "SystemReboot": {}
   }'
   ```

4. Check The RebootNeeded value:
   ```shell
   $ curl 'http://0.0.0.0:59882/api/v2/device/name/Camera001/RebootNeeded' | jq .
   {
      "apiVersion" : "v2",
      "event" : {
         "apiVersion" : "v2",
         "deviceName" : "Camera001",
         "id" : "53585696-ec1a-4ac7-9a42-7d480c0a75d9",
         "origin" : 1635750854455262000,
         "profileName" : "onvif-camera",
         "readings" : [
            {
               "deviceName" : "Camera001",
               "id" : "87819d3a-25d0-4313-b69a-54c4a0c389ed",
               "origin" : 1635750854455262000,
               "profileName" : "onvif-camera",
               "resourceName" : "RebootNeeded",
               "value" : "false",
               "valueType" : "Bool"
            }
         ],
         "sourceName" : "RebootNeeded"
      },
      "statusCode" : 200
   }
   ```
   Because of the reboot, **RebootNeeded** is now `false`.
