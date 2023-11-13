---
title: Device REST - Protocol Properties
---

# Device REST - Protocol Properties

This service defines the following Protocol Properties for each defined device that supports 2-way communications.  These properties reside under the `REST` key in the `protocols` section of each device definition and are used to construct a URL to send GET/SET commands to the end device.

| Property | Description                                                  |
| -------- | ------------------------------------------------------------ |
| Host     | Hostname/IP Address for the device's REST service            |
| Port     | Port number for the device's REST service                    |
| Path     | **Optional** - Base REST endpoint for the device's REST service in which the GET/SET commands are sent. |

!!! note
    These Protocol Properties are not used/needed for REST devices which only send asynchronous data (one-way).

!!! example - "Example REST Protocol Properties - Two-way device"

    ```yaml
        protocols:
          REST:
            Host: 127.0.0.1
            Port: '5000'
            Path: api
    ```

In the above example the resulting Command URL will be `http://127.0.0.1:5000/api/<resource-name>?<query-param>` where:

- `resource-name` is the name of the resource for the Command from the Device Profile.
- `query-param` is the optional query parameter defined in the resource's `attributes` section as `urlRawQuery`.

GET commands result in `GET` REST requests, while SET Commands result in `PUT` REST requests to the end device.

!!! warning
    This service does not support Device Commands defined in the Device Profile (combining multiple device resources). 
