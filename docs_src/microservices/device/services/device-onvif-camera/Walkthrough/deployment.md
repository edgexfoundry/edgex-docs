# Deployment
Follow this guide to deploy and run the service.

## Deploy EdgeX and ONVIF Device Camera Microservice

=== "Docker"

      1. Navigate to the EdgeX `compose-builder` directory:
   
         ```bash
         cd edgex-compose/compose-builder/
         ```
      
      2. Checkout the latest release ({{edgexversion}}):

        ```bash
        git checkout {{edgexversion}}
        ```

      3. Run Edgex with the ONVIF microservice in secure or non-secure mode.

        ##### Non-secure mode

        ```bash
        make run no-secty ds-onvif-camera
        ```
    
        ##### Secure mode 

        !!! note
            Recommended for secure and production level deployments. 

         ```bash
         make run ds-onvif-camera
         ```

        ### Token Generation (secure mode only)
        !!! note
            Need to wait for sometime for the services to be fully up before executing the next set of commands.
            Securely store Consul ACL token and the JWT token generated which are needed to map credentials and execute apis.
            It is not recommended to store these secrets in cleartext in your machine. 

        !!! note
            The JWT token expires after 119 minutes, and you will need to generate a new one.
        
        Generate the Consul ACL Token. Use the token generated anywhere you see `<consul-token>` in the documentation.
        ```bash
        make get-consul-acl-token
        ```
        Example output:
        ```bash
        12345678-abcd-1234-abcd-123456789abc
        ```

        Generate the JWT Token. Use the token generated anywhere you see `<jwt-token>` in the documentation.
        ```bash
        make get-token
        ```
        Example output:
        `eyJhbGciOiJFUzM4NCIsImtpZCI6IjUyNzM1NWU4LTQ0OWYtNDhhZC05ZGIwLTM4NTJjOTYxMjA4ZiJ9.eyJhdWQiOiJlZGdleCIsImV4cCI6MTY4NDk2MDI0MSwiaWF0IjoxNjg0OTU2NjQxLCJpc3MiOiIvdjEvaWRlbnRpdHkvb2lkYyIsIm5hbWUiOiJlZGdleHVzZXIiLCJuYW1lc3BhY2UiOiJyb290Iiwic3ViIjoiMGRjNThlNDMtNzBlNS1kMzRjLWIxM2QtZTkxNDM2ODQ5NWU0In0.oa8Fac9aXPptVmHVZ2vjymG4pIvF9R9PIzHrT3dAU11fepRi_rm7tSeq_VvBUOFDT_JHwxDngK1VqBVLRoYWtGSA2ewFtFjEJRj-l83Vz33KySy0rHteJIgVFVi1V7q5`

        !!! note
            Secrets such as passwords, certificates, tokens and more in Edgex are stored in a secret store which is implemented using Vault a product of Hashicorp.
            Vault supports security features allowing for the issuing of consul tokens. JWT token is required for the API Gateway which is a trust boundry for Edgex services. 
            It allows for external clients to be verified when issuing REST requests to the microservices. 
            For more info refer [Secure Consul](../../../../../security/Ch-Secure-Consul.md), [API Gateway](../../../../../security/Ch-APIGateway.md) 
            and [Edgex Security](../../../../../security/Ch-Security.md).


=== "Native"

    !!! note
        Go version 1.20+ is required to run natively. See <a href="https://go.dev/doc/install">here</a> for more information.

      1. Navigate to the EdgeX `compose-builder` directory:

         ```bash
         cd edgex-compose/compose-builder/
         ```
     
      2. Checkout the latest release ({{edgexversion}}):

         ```bash
         git checkout {{edgexversion}}
         ```

      3. Run EdgeX:

         ```bash
         make run no-secty
         ```

      4. Navigate out of the `edgex-compose` directory to the `device-onvif-camera` directory:

         ```bash
         cd device-onvif-camera
         ```

      5. Checkout the latest release ({{edgexversion}}):

         ```bash
         git checkout {{edgexversion}}
         ```

      6. Run the service
         ```bash
         make run
         ```
         
         <details>
         <summary>[Optional] Run with NATS</summary>
            ```bash
            make run-nats
            ```
         </details>

## Verify Service and Device Profiles

=== "via Command Line"
    1. Check the status of the container:

        ```bash 
        docker ps
        ```

        The status column will indicate if the container is running, and how long it has been up.

        Example output:

        ```docker
        CONTAINER ID   IMAGE                                                       COMMAND                  CREATED       STATUS          PORTS                                                                                         NAMES
        33f9c5ecb70e   nexus3.edgexfoundry.org:10004/device-onvif-camera:latest    "/device-onvif-camer…"   7 weeks ago   Up 48 minutes   127.0.0.1:59985->59985/tcp                                                                    edgex-device-onvif-camera
        ```

    2. Check whether the device service is added to EdgeX:

        !!! note
            If running in secure mode all the api executions need the JWT token generated previously. E.g.
            ```bash
            curl --location --request GET 'http://localhost:59881/api/{{api_version}}/deviceservice/name/device-onvif-camera' \
            --header 'Authorization: Bearer <jwt-token>' \
            --data-raw ''
            ```

        ```bash
        curl -s http://localhost:59881/api/{{api_version}}/deviceservice/name/device-onvif-camera | jq .
        ```
        Good response:
        ```json
        {
            "apiVersion" : "{{api_version}}",
            "statusCode": 200,
            "service": {
                "created": 1657227634593,
                "modified": 1657291447649,
                "id": "e1883aa7-f440-447f-ad4d-effa2aeb0ade",
                "name": "device-onvif-camera",
                "baseAddress": "http://edgex-device-onvif-camera:59984",
                "adminState": "UNLOCKED"
            }         
        }
        ```
        Bad response:
        ```json
        {
        "apiVersion" : "{{api_version}}",
        "message": "fail to query device service by name device-onvif-camer",
        "statusCode": 404
        }
        ```


    3. Check whether the device profile is added:

        ```bash
        curl -s http://localhost:59881/api/{{api_version}}/deviceprofile/name/onvif-camera | jq -r '"profileName: " + '.profile.name' + "\nstatusCode: " + (.statusCode|tostring)'

        ```
        Good response:
        ```bash
        profileName: onvif-camera
        statusCode: 200
        ```
        Bad response:
        ```bash
        profileName: 
        statusCode: 404
        ```

    !!! note
        `jq -r` is used to reduce the size of the displayed response. The entire device profile with all resources can be seen by removing `-r '"profileName: " + '.profile.name' + "\nstatusCode: " + (.statusCode|tostring)', and replacing it with '.'`

=== "via EdgeX UI"

    !!! note
        Secure mode login to Edgex UI requires the [JWT token](#token-generation-secure-mode-only) generated in the above step


      <details>
      <summary><strong>Entering the JWT token</strong></summary>
         ![](../images/EdgeXJWTLogin.png)
      </details>
   

      1. Visit http://localhost:4000 to go to the dashboard for EdgeX Console GUI:

         ![EdgeXConsoleDashboard](../images/EdgeXDashboard.png)
         <p align="left">
            <i>Figure 1: EdgeX Console Dashboard</i>
         </p>

      2. To see **Device Services**, **Devices**, or **Device Profiles**, click on their respective tab:

         ![EdgeXConsoleDeviceServices](../images/EdgeXDeviceServices.png)
         <p align="left">
            <i>Figure 2: EdgeX Console Device Service List</i>
         </p>

         ![EdgeXConsoleDeviceList](../images/EdgeXDeviceList.png)
         <p align="left">
            <i>Figure 3: EdgeX Console Device List</i>
         </p>

         ![EdgeXConsoleDeviceProfileList](../images/EdgeXDeviceProfiles.png)
         <p align="left">
            <i>Figure 4: EdgeX Console Device Profile List</i>
         </p>

Additionally, ensure that the service config has been deployed and that Consul is reachable.
!!! note
    If running in secure mode this command needs the [Consul ACL token](#token-generation-secure-mode-only) generated previously.

```bash
curl -H "X-Consul-Token:<consul-token>" -X GET "http://localhost:8500/v1/kv/edgex/{{api_version}}/device-onvif-camera?keys=true"
```     

Example output:
```bash
["edgex/v3/device-onvif-camera/AppCustom/BaseNotificationURL", "edgex/v3/device-onvif-camera/AppCustom/CheckStatusInterval",
  "edgex/v3/device-onvif-camera/AppCustom/CredentialsMap/NoAuth", ... , "edgex/v3/device-onvif-camera/Writable/InsecureSecrets/credentials001/SecretData/username", "edgex/v3/device-onvif-camera/Writable/InsecureSecrets/credentials001/SecretName",
  "edgex/v3/device-onvif-camera/Writable/LogLevel"]
```

## Manage Devices
Follow these instructions to add and update devices manually.


### Curl Commands

#### Add Device

!!! warning
    Be careful when storing any potentially important information in cleartext on files in your computer. This includes information such as your camera IP and MAC addresses.

1. Edit the information to appropriately match the camera. The fields `Address`, `MACAddress` and `Port` should match that of the camera:

    !!! note
        If running in secure mode the commands might need the JWT or consul token generated previously.

    ```bash
    curl -X POST -H 'Content-Type: application/json'  \
    http://localhost:59881/api/{{api_version}}/device \
    -d '[
             {
                "apiVersion" : "{{api_version}}",
                "device": {
                   "name":"Camera001",
                   "serviceName": "device-onvif-camera",
                   "profileName": "onvif-camera",
                   "description": "My test camera",
                   "adminState": "UNLOCKED",
                   "operatingState": "UP",
                   "protocols": {
                      "Onvif": {
                         "Address": "10.0.0.0",
                         "Port": "10000",
                         "MACAddress": "aa:bb:cc:11:22:33",
                         "FriendlyName":"Default Camera"
                      },
                      "CustomMetadata": {
                         "Location":"Front door"
                      }
                   }
                }
             }
    ]'
    ```
    
    Example output: 
    ```bash
    [{"apiVersion" : "{{api_version}}","statusCode":201,"id":"fb5fb7f2-768b-4298-a916-d4779523c6b5"}]
    ```
    
2. Update credentials in Secret Store.

    === "Secure mode"
        !!! note
            If running in secure mode all the api executions need the [JWT token](#token-generation-secure-mode-only) generated previously.


        Enter your chosen username, password, and authentication mode and credentials name and then execute the command to create the secrets.
        !!! note
            The options for authentication mode are: `usernametoken`, `digest`, or `both`

        ```bash
        curl --data '{
                    "apiVersion" : "{{api_version}}",
                    "secretName": "<creds-name>",
                    "secretData":[
                        {
                            "key":"username",
                            "value":"<username>"
                        },
                        {
                            "key":"password",
                            "value":"<password>"
                        },
                        {
                            "key":"mode",
                            "value":"<auth-mode>"
                        }
                    ]
                }' --header 'Authorization:Bearer <jwt-token>' -X POST "http://localhost:59984/api/{{api_version}}/secret"
        ```
        Example output: 
        ```bash
        {"apiVersion":"v3","statusCode":201}
        ```

    === "Non-secure mode"
        Enter your chosen username, password, and authentication mode and credentials name and then execute the command to create the secrets.
        !!! note
            The options for authentication mode are: `usernametoken`, `digest`, or `both`

        ```bash
        curl --data '{
                    "apiVersion" : "{{api_version}}",
                    "secretName": "<creds-name>",
                    "secretData":[
                        {
                            "key":"username",
                            "value":"<username>"
                        },
                        {
                            "key":"password",
                            "value":"<password>"
                        },
                        {
                            "key":"mode",
                            "value":"<auth-mode>"
                        }
                    ]
                }' -X POST "http://localhost:59984/api/{{api_version}}/secret"
        ```
        
        Example output: 
        ```bash
        {"apiVersion":"v3","statusCode":201}
        ```

3. Map credentials to devices.

    === "Secure Mode"

        a. Enter your mac-address(es) and then execute the command to add the mac address(es) to the mapping.
        !!! note
            If you want to map multiple mac addresses, enter a comma separated list in the command

        ```bash
        curl --data '<mac-address>' -H "X-Consul-Token:<consul-token>" -X PUT "http://localhost:8500/v1/kv/edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/<creds-name>"
        ```
        Example output: 
        ```bash
        true
        ```
        
        b. Check the status of the credentials map.
        ```bash
        curl -H "X-Consul-Token:<consul-token>" -X GET "http://localhost:8500/v1/kv/edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap?keys=true" | jq .
        ```
        Example output:
        ```bash
        [
        "edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/NoAuth",
        "edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/credentials001",
        "edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/credentials002"
        ]
        ```

        c. Check the mac addresses mapped to a specific credenential name. Insert the credential name in the command to see the mac addresses associated with it.
        ```bash
        curl -H "X-Consul-Token:<consul-token>" -X GET "http://localhost:8500/v1/kv/edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/<creds-name>?raw=true"
        ```
        Example output:
        ```bash
        11:22:33:44:55:66
        ```

    === "Non-secure mode"
    
        a. Enter your mac-address(es) and then execute the command to add the mac address(es) to the mapping.
        !!! note
            If you want to map multiple mac addresses, enter a comma separated list in the command

        ```bash
        curl --data '<mac-address>' -X PUT "http://localhost:8500/v1/kv/edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/<creds-name>"
        ```
        
        Example output: 
        ```bash
        true
        ```
        
        b. Check the status of the credentials map.
        ```bash
        curl -X GET "http://localhost:8500/v1/kv/edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap?keys=true" | jq .
        ```
        Example output:
        ```bash
        [
        "edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/NoAuth",
        "edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/credentials001",
        "edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/credentials002"
        ]
        ```

        c. Check the mac addresses mapped to a specific credenential name. Insert the credential name in the command to see the mac addresses associated with it.
        ```bash
        curl -X GET "http://localhost:8500/v1/kv/edgex/{{api_version}}/device-onvif-camera/AppCustom/CredentialsMap/<creds-name>?raw=true"
        ```
        Example response:
        ```bash
        11:22:33:44:55:66
        ```

    !!! note
        The [helper scripts](../supplementary-info/utility-scripts.md#create-new-credentials-and-assign-mac-addresses) may also be used, but they have been deprecated.

3. Verify device(s) have been successfully added to core-metadata.

      ```bash
      curl -s http://localhost:59881/api/{{api_version}}/device/all | jq -r '"deviceName: " + '.devices[].name''
      ```

    Example output: 
    ```bash
    deviceName: Camera001
    deviceName: device-onvif-camera
    ```
     
    !!! note
        `jq -r` is used to reduce the size of the displayed response. The entire device with all information can be seen by removing `-r '"deviceName: " + '.devices[].name'', and replacing it with '.'`

#### Update Device

   There are multiple commands that can update aspects of the camera entry in meta-data. Refer to the [Swagger documentation](./general-usage.md) for Core Metadata for more information. For editing specific fields, see the [General Usage](./general-usage.md) tab.

#### Delete Device

   ```bash
   curl -X 'DELETE' \
   'http://localhost:59881/api/{{api_version}}/device/name/<device name>' \
   -H 'accept: application/json' 
   ```

## Shutting Down
To stop all EdgeX services (containers), execute the `make down` command. This will stop all services but not the images and volumes, which still exist.

1. Navigate to the `edgex-compose/compose-builder` directory.
1. Run this command
   ```bash
   make down
   ```
1. To shut down and delete all volumes, run this command
   ```bash
   make clean
   ```

## Next Steps

[Learn how to use the device service>](./general-usage.md){: .md-button}


# License

[Apache-2.0](https://github.com/edgexfoundry-holding/device-onvif-camera/blob/{{edgexversion}}/LICENSE)
