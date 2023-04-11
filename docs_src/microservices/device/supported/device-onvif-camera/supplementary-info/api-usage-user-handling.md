# User Handling

The device service shall be able to create, list, modify and delete users from the device using the CreateUsers, GetUsers, SetUser and DeleteUsers operations.

The spec can refer to https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl

## GetUsers
This operation lists the registered users and corresponding credentials on a device.
```shell
curl --request GET 'http://0.0.0.0:59882/api/v2/device/name/Camera001/Users'
```

## CreateUsers
This operation creates new camera users and corresponding credentials on a device for authentication purposes.
```shell
curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/Camera001/CreateUsers' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "CreateUsers": {
            "User": [
                {
                    "Username": "user1",
                    "Password": "Password1",
                    "UserLevel": "User"
                },
                {
                    "Username": "user2",
                    "Password": "Password1",
                    "UserLevel": "User"
                }
            ]
        }
    }'
```

## SetUser
This operation updates the settings for one or several users on a device for authentication purposes.
```shell
curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/Camera001/Users' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "Users": {
            "User": [
                {
                    "Username": "user1",
                    "UserLevel": "Administrator"
                },
                {
                    "Username": "user2",
                    "UserLevel": "Operator"
                }
            ]
        }
    }'
```

## DeleteUsers
This operation deletes users on a device.
```shell
curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/Camera001/DeleteUsers' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "DeleteUsers": {
            "Username": ["user1","user2"]
        }
    }'
```

