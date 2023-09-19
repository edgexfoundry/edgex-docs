[Render](../supplementary-info/auto-discovery.md#adding-the-devices-to-edgex)
<div class="mermaid">
sequenceDiagram
    Onvif Device Service->>Onvif Camera: WS-Discovery Probe
    Onvif Camera->>Onvif Device Service: Probe Response
    Onvif Device Service->>Onvif Camera: GetDeviceInformation
    Onvif Camera->>Onvif Device Service: GetDeviceInformation Response
    Onvif Device Service->>Onvif Camera: GetNetworkInterfaces
    Onvif Camera->>Onvif Device Service: GetNetworkInterfaces Response
    Onvif Device Service->>EdgeX Core-Metadata: Create Device
    EdgeX Core-Metadata->>Onvif Device Service: Device Added
</div>

[Render](../supplementary-info/auto-discovery.md#rediscovery)
<div class="mermaid">
%% Note: The node and edge definitions are split up to make it easier to adjust the
%% links between the various nodes.
flowchart TD
    %% -------- Node Definitions -------- %%
    Multicast[/Devices Discovered<br/>via Multicast/]
    Netscan[/Devices Discovered<br/>via Netscan/]
    DupeFilter[Filter Duplicate Devices<br/>based on EndpointRef]    
    MACMatches{MAC Address<br/>matches existing<br/>device?}
    RefMatches{EndpointRef<br/>matches existing<br/>device?}
    IPChanged{IP Address<br/>Changed?}
    MACChanged{MAC Address<br/>Changed?}
    UpdateIP[Update IP Address]
    UpdateMAC(Update MAC Address)
    RegisterDevice(Register New Device<br/>With EdgeX)
    DeviceNotRegistered(Device Not Registered)
    PWMatches{Device matches<br/>Provision Watcher?}
    
    %% -------- Graph Definitions -------- %%
    Multicast --> DupeFilter
    Netscan --> DupeFilter
    DupeFilter --> ForEachDevice
    subgraph ForEachDevice[For Each Unique Device]
        MACMatches -->|Yes| IPChanged
        MACMatches -->|No| RefMatches
        RefMatches -->|Yes| IPChanged
        RefMatches -->|No| ForEachPW
        ForEachPW --> PWMatches
        PWMatches-->|No Matches| DeviceNotRegistered
        IPChanged -->|No| MACChanged
        IPChanged -->|Yes| UpdateIP
        UpdateIP --> MACChanged
        MACChanged -->|Yes| UpdateMAC

        PWMatches -->|Yes| RegisterDevice
    end
</div>

[Render](./../supplementary-info/credentials.md#during-discovery)
<div class="mermaid">
    %% Note: The node and edge definitions are split up to make it easier to adjust the
    %% links between the various nodes.
    flowchart TD;   
        %% -------- Node Definitions -------- %%
        DiscoveredDevice[/Discovered Device/]
        UseDefault[Use Default Credentials]
        EndpointRefHasMAC{Does EndpointRef<br/>contain<br/>MAC Address?}
        InNoAuthGroup{MAC Belongs<br/>to NoAuth group?}
        AuthModeNone[Set AuthMode to 'none']
        ApplyCreds[Apply Credentials]
        InSecretStore{Credentials exist<br/>in SecretStore?}
        CreateClient[Create Onvif Client]
        GetDeviceInfo[Get Device Information]
        GetNetIfaces[Get Network Interfaces]
        CreateDevice(Create Device:<br/>&ltMfg&gt-&ltModel&gt-&ltEndpointRef&gt)
        CreateUnknownDevice(Create Device:<br/>unknown_unknown_&ltEndpointRef&gt)

        %% -------- Graph Definitions -------- %%
        DiscoveredDevice --> ForAllMAC
        subgraph ForAllMAC[For all MAC Addresses in CredentialsMap]
        EndpointRefHasMAC
        end
        EndpointRefHasMAC -->|Yes| InNoAuthGroup
        EndpointRefHasMAC -- No Matches --> UseDefault
        InNoAuthGroup -->|Yes| AuthModeNone
        InNoAuthGroup -->|No| InSecretStore
        UseDefault --> InSecretStore
        AuthModeNone --> CreateClient
        InSecretStore -->|Yes| ApplyCreds
        InSecretStore -->|No| AuthModeNone
        ApplyCreds --> CreateClient
        CreateClient --> GetDeviceInfo
        GetDeviceInfo -->|Failed| CreateUnknownDevice
        GetDeviceInfo -->|Success| GetNetIfaces
        GetNetIfaces ----> CreateDevice
</div>

[Render](../supplementary-info/credentials.md#connecting-to-existing-devices)
<div class="mermaid">
%% Note: The node and edge definitions are split up to make it easier to adjust the
%% links between the various nodes.
flowchart TD;
    %% -------- Node Definitions -------- %%
    ExistingDevice[/Existing Device/]
    ContainsMAC{Device Metadata contains<br/>MAC Address?}
    ValidMAC{Is it a valid<br/>MAC Address?}
    InMap{MAC exists in<br/>CredentialsMap?}
    InNoAuth{MAC Belongs<br/>to NoAuth group?}
    UseDefault[Use Default Credentials]
    InSecretStore{Credentials exist<br/>in SecretStore?}
    AuthModeNone(Set AuthMode to 'none')
    ApplyCreds(Apply Credentials)
    CreateClient(Create Onvif Client)

    %% -------- Edge Definitions -------- %%
    ExistingDevice --> ContainsMAC
    ContainsMAC -->|Yes| ValidMAC
    ValidMAC -->|Yes| InMap
    ValidMAC -->|No| AuthModeNone
    InMap -->|Yes| InNoAuth
    InMap -->|No| AuthModeNone
    ContainsMAC -->|No| UseDefault
    InNoAuth -->|Yes| AuthModeNone
    InNoAuth -->|No| InSecretStore
    UseDefault --> InSecretStore
    InSecretStore -->|Yes| ApplyCreds
    InSecretStore -->|No| AuthModeNone
    AuthModeNone ----> CreateClient
    ApplyCreds ----> CreateClient
</div>

[Render](../supplementary-info/device-status.md#status-check-flow-for-each-device)
<div class="mermaid">
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
</div>