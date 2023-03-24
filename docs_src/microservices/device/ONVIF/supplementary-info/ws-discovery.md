# How does WS-Discovery work?

ONVIF devices support WS-Discovery, which is a mechanism that supports probing a network to find ONVIF capable devices.

Probe messages are sent over UDP to a standardized multicast address and UDP port number.

<img src="images/auto-discovery.jpg" width="75%"/>

WS-Discovery is generally faster than netscan becuase it only sends out one broadcast signal. However, it is normally limited by the network segmentation since the multicast packages typically do not traverse routers.

- Find the WS-Discovery programmer guide from https://www.onvif.org/profiles/whitepapers/
- Wiki page https://en.wikipedia.org/wiki/WS-Discovery

Example:
1. The client sends Probe message to find Onvif camera on the network.
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <soap-env:Envelope
            xmlns:soap-env="http://www.w3.org/2003/05/soap-envelope"
            xmlns:soap-enc="http://www.w3.org/2003/05/soap-encoding"
            xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing">
        <soap-env:Header>
            <a:Action mustUnderstand="1">http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</a:Action>
            <a:MessageID>uuid:a86f9421-b764-4256-8762-5ed0d8602a9c</a:MessageID>
            <a:ReplyTo>
                <a:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</a:Address>
            </a:ReplyTo>
            <a:To mustUnderstand="1">urn:schemas-xmlsoap-org:ws:2005:04:discovery</a:To>
        </soap-env:Header>
        <soap-env:Body>
            <Probe
                    xmlns="http://schemas.xmlsoap.org/ws/2005/04/discovery"/>
        </soap-env:Body>
    </soap-env:Envelope>
    ```

2. The Onvif camera responds the Hello message according to the Probe message
    > The Hello message from HIKVISION
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <env:Envelope
        xmlns:env="http://www.w3.org/2003/05/soap-envelope"
        ...>
        <env:Header>
            <wsadis:MessageID>urn:uuid:cea94000-fb96-11b3-8260-686dbc5cb15d</wsadis:MessageID>
            <wsadis:RelatesTo>uuid:a86f9421-b764-4256-8762-5ed0d8602a9c</wsadis:RelatesTo>
            <wsadis:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsadis:To>
            <wsadis:Action>http://schemas.xmlsoap.org/ws/2005/04/discovery/ProbeMatches</wsadis:Action>
            <d:AppSequence InstanceId="1637072188" MessageNumber="17"/>
        </env:Header>
        <env:Body>
            <d:ProbeMatches>
                <d:ProbeMatch>
                    <wsadis:EndpointReference>
                        <wsadis:Address>urn:uuid:cea94000-fb96-11b3-8260-686dbc5cb15d</wsadis:Address>
                    </wsadis:EndpointReference>
                    <d:Types>dn:NetworkVideoTransmitter tds:Device</d:Types>
                    <d:Scopes>onvif://www.onvif.org/type/video_encoder onvif://www.onvif.org/Profile/Streaming onvif://www.onvif.org/MAC/68:6d:bc:5c:b1:5d onvif://www.onvif.org/hardware/DFI6256TE http:123</d:Scopes>
                    <d:XAddrs>http://192.168.12.123/onvif/device_service</d:XAddrs>
                    <d:MetadataVersion>10</d:MetadataVersion>
                </d:ProbeMatch>
            </d:ProbeMatches>
        </env:Body>
    </env:Envelope>
    ```
    
    >The Hello message from Tapo C200
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope
        xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope"
        ...>
        <SOAP-ENV:Header>
            <wsa:MessageID>uuid:a86f9421-b764-4256-8762-5ed0d8602a9c</wsa:MessageID>
            <wsa:RelatesTo>uuid:a86f9421-b764-4256-8762-5ed0d8602a9c</wsa:RelatesTo>
            <wsa:ReplyTo SOAP-ENV:mustUnderstand="true">
                <wsa:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:Address>
            </wsa:ReplyTo>
            <wsa:To SOAP-ENV:mustUnderstand="true">urn:schemas-xmlsoap-org:ws:2005:04:discovery</wsa:To>
            <wsa:Action SOAP-ENV:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2005/04/discovery/ProbeMatches</wsa:Action>
        </SOAP-ENV:Header>
        <SOAP-ENV:Body>
            <wsdd:ProbeMatches>
                <wsdd:ProbeMatch>
                    <wsa:EndpointReference>
                        <wsa:Address>uuid:3fa1fe68-b915-4053-a3e1-c006c3afec0e</wsa:Address>
                        <wsa:ReferenceProperties></wsa:ReferenceProperties>
                        <wsa:PortType>ttl</wsa:PortType>
                    </wsa:EndpointReference>
                    <wsdd:Types>tdn:NetworkVideoTransmitter</wsdd:Types>
                    <wsdd:Scopes>onvif://www.onvif.org/name/TP-IPC onvif://www.onvif.org/hardware/MODEL onvif://www.onvif.org/Profile/Streaming onvif://www.onvif.org/location/ShenZhen onvif://www.onvif.org/type/NetworkVideoTransmitter </wsdd:Scopes>
                    <wsdd:XAddrs>http://192.168.12.128:2020/onvif/device_service</wsdd:XAddrs>
                    <wsdd:MetadataVersion>1</wsdd:MetadataVersion>
                </wsdd:ProbeMatch>
            </wsdd:ProbeMatches>
        </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
    ```
