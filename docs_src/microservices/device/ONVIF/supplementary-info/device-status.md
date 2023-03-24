# Device Status
The device status goes hand in hand with the rediscovery of the cameras, but goes beyond the scope of just discovery. 
It is a separate background task running at a specified interval (default 30s) to determine the most accurate 
operating status of the existing cameras. This applies to all devices regardless of how or where they were added from.

## States and Descriptions
Currently, there are 4 different statuses that a camera can have

- **UpWithAuth**: Can execute commands requiring credentials  
- **UpWithoutAuth**: Can only execute commands that do not require credentials. Usually this means the camera's credentials have not been registered with the service yet, or have been changed.  
- **Reachable**: Can be discovered but no commands can be received.  
- **Unreachable**: Cannot be seen by service at all. Typically, this means that there is a connection issue either physically or with the network.

### Status Check flow for each device
```mermaid
%% Note: The node and edge definitions are split up to make it easier to adjust the
%% links between the various nodes.
flowchart TD;
    %% -------- Node Definitions -------- %%
    CheckDeviceStatus(Check Device Status)
    UpdateDeviceStatus[Update Device Status<br/>in Core-Metadata]
    SetLastSeen[Set LastSeen = Now]
    UpdateMetadata[Update Core-Metadata]
    CheckNowUpWithAuth{Status Changed<br/>&&<br/>Status == UpWithAuth?}
    DeviceHasMAC{Device Has<br/>MAC Address?}
    CreateClient[Create Onvif Client]
    GetCapabilities[Device::GetCapabilities]
    CheckUpdatedMAC[Check CredentialsMap for<br/>updated MAC Address]
    TCPProbe[TCP Probe]
    GetDeviceInfo[GetDeviceInformation]
    UpdateDeviceInfo[Update Device Information]
    UpdateMACAddress[Update MAC Address]
    UpdateEndpointRef[Update EndpointRefAddress]
    DeviceUnknown{Device Name<br/>begins with<br/>unknown_unknown_?}
    RemoveDevice[Remove Device<br/>unknown_unknown_&ltEndpointRef&gt]
    CreateDevice[Create Device<br/>&ltMfg&gt-&ltModel&gt-&ltEndpointRef&gt]
    
    %% -------- Graph Definitions -------- %%
    CheckDeviceStatus --> DeviceHasMAC
    DeviceHasMAC -->|No| CheckUpdatedMAC
    DeviceHasMAC -->|Yes| CreateClient
    CheckUpdatedMAC --> CreateClient
    
    subgraph TestConnection[Test Connection Methods]
        CreateClient --> GetCapabilities
        GetCapabilities -->|Failed| TCPProbe
        GetCapabilities -->|Success| GetDeviceInfo
        GetDeviceInfo -->|Success| UpWithAuth
        GetDeviceInfo -->|Failed| UpWithoutAuth
        TCPProbe -->|Failed| Unreachable
        TCPProbe -->|Success| Reachable
    end
    
    UpWithAuth --> SetLastSeen
    UpWithoutAuth --> SetLastSeen
    Reachable --> SetLastSeen
    Unreachable --> UpdateDeviceStatus
    UpdateDeviceStatus --> CheckNowUpWithAuth
    SetLastSeen --> UpdateDeviceStatus
    CheckNowUpWithAuth -->|Yes| RefreshDevice
    
    subgraph RefreshDevice[Refresh Device]
        UpdateDeviceInfo --> UpdateMACAddress
        UpdateMACAddress --> UpdateEndpointRef
        UpdateEndpointRef --> DeviceUnknown
        DeviceUnknown -->|No| UpdateMetadata
        DeviceUnknown -->|Yes| RemoveDevice
        RemoveDevice --> CreateDevice
    end
```

## Configuration Options
- Use `EnableStatusCheck` to enable the device status background service.
- `CheckStatusInterval` is the interval at which the service will determine the status of each camera.

```toml
EnableStatusCheck = true

# The interval in seconds at which the service will check the connection of all known cameras and update the device status 
# A longer interval will mean the service will detect changes in status less quickly
# Maximum 300s (1 hour)
CheckStatusInterval = 30
```

## Automatic Triggers
Currently, there are some actions that will trigger an automatic status check:
- Any modification to the `CredentialsMap` from the config provider (Consul)
