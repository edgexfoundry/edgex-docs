# Onvif Camera Device Service Specifications


This Onvif Camera Device Service is developed to control/communicate ONVIF-compliant cameras accessible via http in an EdgeX deployment

## Table of Contents

- [Onvif Features](#onvif-features)  
- [Custom Features](#custom-features)  
- [How does the service work?](#how-does-the-device-service-work)  
- [Tested Onvif Cameras](#tested-onvif-cameras)

## OpenAPI Spec
The latest version 2.2.0 of the device service API specifications can be found
[here](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/device-onvif-camera/2.2.0).



## Onvif Features
The device service supports the onvif features listed in the following table:

| Feature                                                                 | Onvif Web Service | Onvif Function                                                                                                                  | EdgeX Value Type |
|-------------------------------------------------------------------------|-------------------|---------------------------------------------------------------------------------------------------------------------------------|------------------|
| **[User Authentication](#user-authentication)**                         | Core              | **WS-Usernametoken Authentication**                                                                                             |                  |
|                                                                         |                   | **HTTP Digest**                                                                                                                 |                  |
| **[Auto Discovery](#auto-discovery)**                                   | Core              | **WS-Discovery**                                                                                                                |                  |
|                                                                         | Device            | [GetDiscoveryMode](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetDiscoveryMode)                                 | Object           |
|                                                                         |                   | [SetDiscoveryMode](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetDiscoveryMode)                                 | Object           |
|                                                                         |                   | [GetScopes](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetScopes)                                               | Object           |
|                                                                         |                   | [SetScopes](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetScopes)                                               | Object           |
|                                                                         |                   | [AddScopes](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.AddScopes)                                               | Object           |
|                                                                         |                   | [RemoveScopes](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.RemoveScopes)                                         | Object           |
| **[Network Configuration](#network-configuration)**                     | Device            | [GetHostname](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetHostname)                                           | Object           |
|                                                                         |                   | [SetHostname](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetHostname)                                           | Object           |
|                                                                         |                   | [GetDNS](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetDNS)                                                     | Object           |
|                                                                         |                   | [SetDNS](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetDNS)                                                     | Object           |
|                                                                         |                   | [**GetNetworkInterfaces**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetNetworkInterfaces)                     | Object           |
|                                                                         |                   | [**SetNetworkInterfaces**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetNetworkInterfaces)                     | Object           |
|                                                                         |                   | [GetNetworkProtocols](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetNetworkProtocols)                           | Object           |
|                                                                         |                   | [SetNetworkProtocols](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetNetworkProtocols)                           | Object           |
|                                                                         |                   | [**GetNetworkDefaultGateway**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetNetworkDefaultGateway)             | Object           |
|                                                                         |                   | [**SetNetworkDefaultGateway**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetNetworkDefaultGateway)             | Object           |
| **[System Function](#system-function)**                                 | Device            | [**GetDeviceInformation**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetDeviceInformation)                     | Object           |
|                                                                         |                   | [GetSystemDateAndTime](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetSystemDateAndTime)                         | Object           |
|                                                                         |                   | [SetSystemDateAndTime](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetSystemDateAndTime)                         | Object           |
|                                                                         |                   | [SetSystemFactoryDefault](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetSystemFactoryDefault)                   | Object           |
|                                                                         |                   | [SystemReboot](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SystemReboot)                                         | Object           |
| **[User Handling](#user-handling)**                                     | Device            | [**GetUsers**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.GetUsers)                                             | Object           |
|                                                                         |                   | [**CreateUsers**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.CreateUsers)                                       | Object           |
|                                                                         |                   | [**DeleteUsers**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.DeleteUsers)                                       | Object           |
|                                                                         |                   | [**SetUser**](https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetUser)                                               | Object           |
| **[Metadata Configuration](#metadata-configuration)**                   | Media             | [GetMetadataConfiguration](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.GetMetadataConfiguration)                       | Object           |
|                                                                         |                   | [GetMetadataConfigurations](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.GetMetadataConfigurations)                     | Object           |
|                                                                         |                   | [GetCompatibleMetadataConfigurations](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.GetCompatibleMetadataConfigurations) | Object           |
|                                                                         |                   | [**GetMetadataConfigurationOptions**](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.GetMetadataConfigurationOptions)     | Object           |
|                                                                         |                   | [AddMetadataConfiguration](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.AddMetadataConfiguration)                       | Object           |
|                                                                         |                   | [RemoveMetadataConfiguration](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.RemoveMetadataConfiguration)                 | Object           |
|                                                                         |                   | [**SetMetadataConfiguration**](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.SetMetadataConfiguration)                   | Object           |
| **[Video Streaming](#video-streaming)**                                 | Media             | [**GetProfiles**](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.GetProfiles)                                             | Object           |
|                                                                         |                   | [**GetStreamUri**](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.GetStreamUri)                                           | Object           |
| **[VideoEncoder Config](#videoencoder-config)**                         | Media             | [GetVideoEncoderConfiguration](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.GetVideoEncoderConfiguration)               | Object           |
|                                                                         |                   | [**SetVideoEncoderConfiguration**](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.SetVideoEncoderConfiguration)           | Object           |
|                                                                         |                   | [GetVideoEncoderConfigurationOptions](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.GetVideoEncoderConfigurationOptions) | Object           |
| **[PTZ Node](#ptz-node)**                                               | PTZ               | [GetNode](http://www.onvif.org/onvif/ver20/ptz/wsdl/ptz.wsdl#op.GetNode)                                                        | Object           |
|                                                                         |                   | [GetNodes](http://www.onvif.org/onvif/ver20/ptz/wsdl/ptz.wsdl#op.GetNodes)                                                      | Object           |
| **[PTZ Configuration](#ptz-configuration)**                             |                   | [GetConfigurations](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.GetConfigurations)                                         | Object           |
|                                                                         |                   | [GetConfiguration](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.GetConfiguration)                                           | Object           |
|                                                                         |                   | [GetConfigurationOptions](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.GetConfigurationOptions)                             | Object           |
|                                                                         |                   | [SetConfiguration](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.SetConfiguration)                                           | Object           |
|                                                                         | Media             | [AddPTZConfiguration](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.AddPTZConfiguration)                                 | Object           |
|                                                                         | Media             | [RemovePTZConfiguration](https://www.onvif.org/ver10/media/wsdl/media.wsdl#op.RemovePTZConfiguration)                           | Object           |
| **[PTZ Actuation](#ptz-actuation)**                                     | PTZ               | [AbsoluteMove](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.AbsoluteMove)                                                   | Object           |
|                                                                         |                   | [RelativeMove](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.RelativeMove)                                                   | Object           |
|                                                                         |                   | [ContinuousMove](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.ContinuousMove)                                               | Object           |
|                                                                         |                   | [Stop](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.Stop)                                                                   | Object           |
|                                                                         |                   | [GetStatus](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.GetStatus)                                                         | Object           |
|                                                                         |                   | [GetPresets](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.GetPresets)                                                       | Object           |
|                                                                         |                   | [GotoPreset](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.GotoPreset)                                                       | Object           |
|                                                                         |                   | [RemovePreset](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.RemovePreset)                                                   | Object           |
| **[PTZ Home Position](#ptz-home-position)**                             | PTZ               | [GotoHomePosition](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.GotoHomePosition)                                           | Object           |
|                                                                         |                   | [SetHomePosition](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.SetHomePosition)                                             | Object           |
| **[PTZ Auxiliary Operations](#ptz-auxiliary-operations)**               | PTZ               | [SendAuxiliaryCommand](https://www.onvif.org/ver20/ptz/wsdl/ptz.wsdl#op.SendAuxiliaryCommand)                                   | Object           |
| **[Event Handling](#event-handling)**                                   | Event             | [Notify](https://docs.oasis-open.org/wsn/wsn-ws_base_notification-1.3-spec-os.pdf)                                              | Object           |
|                                                                         |                   | [Subscribe](https://docs.oasis-open.org/wsn/wsn-ws_base_notification-1.3-spec-os.pdf)                                           | Object           |
|                                                                         |                   | [Renew](https://docs.oasis-open.org/wsn/wsn-ws_base_notification-1.3-spec-os.pdf)                                               | Object           |
|                                                                         |                   | [Unsubscribe](https://www.onvif.org/ver10/events/wsdl/event.wsdl#op.Unsubscribe)                                                | Object           |
|                                                                         |                   | [CreatePullPointSubscription](https://www.onvif.org/ver10/events/wsdl/event.wsdl#op.CreatePullPointSubscription)                | Object           |
|                                                                         |                   | [PullMessages](https://www.onvif.org/ver10/events/wsdl/event.wsdl#op.PullMessages)                                              | Object           |
|                                                                         |                   | [TopicFilter](https://docs.oasis-open.org/wsn/wsn-ws_base_notification-1.3-spec-os.pdf)                                         | Object           |
|                                                                         |                   | [MessageContentFilter](https://docs.oasis-open.org/wsn/wsn-ws_base_notification-1.3-spec-os.pdf)                                | Object           |
| **[Analytics Profile Configuration](#analytics-profile-configuration)** | Media2            | [GetProfiles](https://www.onvif.org/ver20/media/wsdl/media.wsdl#op.GetProfiles)                                                 | Object           |
|                                                                         |                   | [GetAnalyticsConfigurations](https://www.onvif.org/ver20/media/wsdl/media.wsdl#op.GetAnalyticsConfigurations)                   | Object           |
|                                                                         |                   | [AddConfiguration](https://www.onvif.org/ver20/media/wsdl/media.wsdl#op.AddConfiguration)                                       | Object           |
|                                                                         |                   | [RemoveConfiguration](https://www.onvif.org/ver20/media/wsdl/media.wsdl#op.RemoveConfiguration)                                 | Object           |
| **[Analytics Module Configuration](#analytics-module-configuration)**   | Analytics         | [GetSupportedAnalyticsModules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.GetSupportedAnalyticsModules)       | Object           |
|                                                                         |                   | [GetAnalyticsModules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.GetAnalyticsModules)                         | Object           |
|                                                                         |                   | [CreateAnalyticsModules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.CreateAnalyticsModules)                   | Object           |
|                                                                         |                   | [DeleteAnalyticsModules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.DeleteAnalyticsModules)                   | Object           |
|                                                                         |                   | [GetAnalyticsModuleOptions](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.GetAnalyticsModuleOptions)             | Object           |
|                                                                         |                   | [ModifyAnalyticsModules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.ModifyAnalyticsModules)                   | Object           |
| **[Rule Configuration](#rule-configuration)**                           | Analytics         | [GetSupportedRules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.GetSupportedRules)                             | Object           |
|                                                                         |                   | [GetRules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.GetRules)                                               | Object           |
|                                                                         |                   | [CreateRules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.CreateRules)                                         | Object           |
|                                                                         |                   | [DeleteRules](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.DeleteRules)                                         | Object           |
|                                                                         |                   | [GetRuleOptions](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.GetRuleOptions)                                   | Object           |
|                                                                         |                   | [ModifyRule](https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl#op.ModifyRules)                                          | Object           |

**Note**: The functions in the bold text are **mandatory** for Onvif protocol.

## Custom Features
The device service also include custom function to enhance the usage for the EdgeX user.

| Feature         | Service | Function               | EdgeX Value Type | Description                                                                            |
|-----------------|---------|------------------------|------------------|----------------------------------------------------------------------------------------|
| System Function | EdgeX   | RebootNeeded           | Bool             | Read only. Used to indicate the camera should reboot to apply the configuration change |
| System Function | EdgeX   | CameraEvent            | Bool             | A device resource which is used to send the async event to north bound                 |
| System Function | EdgeX   | SubscribeCameraEvent   | Bool             | Create a subscription to subscribe the event from the camera                           |
| System Function | EdgeX   | UnsubscribeCameraEvent | Bool             | Unsubscribe all subscription from the camera                                           |
| Media           | EdgeX   | GetSnapshot            | Binary           | Get Snapshot from the snapshot uri                                                     |
| Custom Metadata | EdgeX   | CustomMetadata         | Object           | Read and write custom metadata to the camera entry in EdgeX                            | 
| Custom Metadata | EdgeX   | DeleteCustomMetadata   | Object           | Delete custom metadata fields from the camera entry in EdgeX                           |

## How does the device service work?

The Onvif camera uses Web Services standards such as XML, SOAP 1.2 and WSDL1.1 over an IP network. 
- XML is used as the data description syntax
- SOAP is used for message transfer 
- and WSDL is used for describing the services.

The spec can refer to [ONVIF-Core-Specification](https://www.onvif.org/specs/core/ONVIF-Core-Specification-v221.pdf).

For example, we can send a SOAP request to the Onvif camera as below:
```shell
curl --request POST 'http://192.168.12.128:2020/onvif/service' \
--header 'Content-Type: application/soap+xml' \
--data-raw '<?xml version="1.0" encoding="UTF-8"?>
<soap-env:Envelope xmlns:soap-env="http://www.w3.org/2003/05/soap-envelope" xmlns:soap-enc="http://www.w3.org/2003/05/soap-encoding" xmlns:tan="http://www.onvif.org/ver20/analytics/wsdl" xmlns:onvif="http://www.onvif.org/ver10/schema" xmlns:trt="http://www.onvif.org/ver10/media/wsdl" xmlns:timg="http://www.onvif.org/ver20/imaging/wsdl" xmlns:tds="http://www.onvif.org/ver10/device/wsdl" xmlns:tev="http://www.onvif.org/ver10/events/wsdl" xmlns:tptz="http://www.onvif.org/ver20/ptz/wsdl" >
    <soap-env:Header>
        <Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
            <UsernameToken>
                <Username>myUsername</Username>
                <Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">+HKcvc+LCGClVwuros1sJuXepQY=</Password>
                <Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">w490bn6rlib33d5rb8t6ulnqlmz9h43m</Nonce>
                <Created xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">2021-10-21T03:43:21.02075Z</Created>
            </UsernameToken>
        </Security>
    </soap-env:Header>
    <soap-env:Body>
        <trt:GetStreamUri>
            <trt:ProfileToken>profile_1</trt:ProfileToken>
        </trt:GetStreamUri>
    </soap-env:Body>
  </soap-env:Envelope>'
```
And the response should be like the following XML data:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
	xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope" xmlns:SOAP-ENC="http://www.w3.org/2003/05/soap-encoding"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing"
	xmlns:wsdd="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:chan="http://schemas.microsoft.com/ws/2005/02/duplex"
	xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
	xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:wsa5="http://www.w3.org/2005/08/addressing"
	xmlns:xmime="http://tempuri.org/xmime.xsd" xmlns:xop="http://www.w3.org/2004/08/xop/include" xmlns:wsrfbf="http://docs.oasis-open.org/wsrf/bf-2"
	xmlns:wstop="http://docs.oasis-open.org/wsn/t-1" xmlns:wsrfr="http://docs.oasis-open.org/wsrf/r-2" xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2"
	xmlns:tt="http://www.onvif.org/ver10/schema" xmlns:ter="http://www.onvif.org/ver10/error" xmlns:tns1="http://www.onvif.org/ver10/topics"
	xmlns:tds="http://www.onvif.org/ver10/device/wsdl" xmlns:trt="http://www.onvif.org/ver10/media/wsdl"
	xmlns:tev="http://www.onvif.org/ver10/events/wsdl" xmlns:tdn="http://www.onvif.org/ver10/network/wsdl" xmlns:timg="http://www.onvif.org/ver20/imaging/wsdl"
	xmlns:trp="http://www.onvif.org/ver10/replay/wsdl" xmlns:tan="http://www.onvif.org/ver20/analytics/wsdl" xmlns:tptz="http://www.onvif.org/ver20/ptz/wsdl">
	<SOAP-ENV:Header></SOAP-ENV:Header>
	<SOAP-ENV:Body>
		<trt:GetStreamUriResponse>
			<trt:MediaUri>
				<tt:Uri>rtsp://192.168.12.128:554/stream1</tt:Uri>
				<tt:InvalidAfterConnect>false</tt:InvalidAfterConnect>
				<tt:InvalidAfterReboot>false</tt:InvalidAfterReboot>
				<tt:Timeout>PT0H0M2S</tt:Timeout>
			</trt:MediaUri>
		</trt:GetStreamUriResponse>
	</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
```

Since the SOAP message is an HTTP call, the device service can just do the transformation between REST(JSON) and SOAP(XML).

For the concept of implementation:
- The device service accepts the REST request from the client, then transforms the request to SOAP format and forward it to the Onvif camera.
- Once the device service receives the response from the Onvif camera, the device service will transform the SOAP response to REST format for the client.
```
                  - Onvif Web Service

                  - Onvif Function  ┌────────────────────┐
                                    │                    │
┌──────────────┐  - Input Parameter │   Device Service   │               ┌─────────────────┐
│              │                    │                    │               │                 │
│              │ REST request       │                    │ SOAP request  │                 │
│    Client  ──┼────────────────────┼──►  Transform  ────┼───────────────┼──► Onvif Camera │
│              │                    │   to SOAP request  │               │                 │
│              │                    │                    │               │                 │
└──────────────┘                    └────────────────────┘               └─────────────────┘


                                    ┌────────────────────┐
                                    │                    │
┌──────────────┐                    │   Device Service   │               ┌─────────────────┐
│              │                    │                    │               │                 │
│              │ REST response      │                    │ SOAP response │                 │
│    Client  ◄─┼────────────────────┼───  Transform   ◄──┼───────────────┼── Onvif Camera  │
│              │                    │   to REST response │               │                 │
│              │                    │                    │               │                 │
└──────────────┘                    └────────────────────┘               └─────────────────┘
```

## Tested Onvif Cameras
The following table shows the Onvif functions tested for various Onvif cameras:

* '✔' means the function works for the specified camera.
* '❌' means the function does not work or is not implemented by the specified camera.
* 'ⓘ' means there is additional details available. Click it to read more.
* Empty cells means the function has not yet been tested.

### User Authentication
| Onvif Web Service | Onvif Function   | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3|
|-------------------|------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Core**          | WS-UsernameToken | ✔                   | ✔         | ✔                                 | ✔                   | ✔                   |
|                   | HTTP Digest      | ✔                   | ❌         | ✔                                 | ❌                   |       ❌              | 

### Capabilities
| Onvif Web Service | Onvif Function         | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|------------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Device**        | GetCapabilities        |                     | ✔         |                                   |                     |    ❌                   |
|                   | GetServiceCapabilities |                     | ✔         |                                   |                     |      ❌                 |
| **Media**         | GetServiceCapabilities |                     | ✔         |                                   |                     |  ✔                    |
| **PTZ**           | GetServiceCapabilities |                     | ✔         |                                   |                     |  ✔                    |
| **Imaging**       | GetServiceCapabilities |                     | ❌         |                                   |                     |   ✔                   |
| **Event**         | GetServiceCapabilities |                     | ✔         |                                   |                     |    ✔                  |

### Auto Discovery
| Onvif Web Service | Onvif Function       | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Core**          | WS-Discovery         | ✔                   | ✔         | ✔                                 | ✔                   | ✔                   |
| **Device**        | GetDiscoveryMode     | ✔                   | ✔         | ✔                                 | ✔                   |     ✔                |
|                   | SetDiscoveryMode     | ✔                   | ✔         | ✔                                 | ✔                   |  ✔                   |
|                   | GetScopes            | ✔                   | ✔         | ✔                                 | ✔                   | ✔                    |
|                   | SetScopes            | ✔                   | ✔         | ✔                                 | ✔                   |  ❌                   |
|                   | AddScopes            | ✔                   | ❌         | ✔                                 | ✔                   |  ✔                    |
|                   | RemoveScopes         | ✔                   | ❌         | ✔                                 | ✔                   |   ✔                   |
|                   | GetEndpointReference |                     | ❌         | ✔                                 |                     |        ❌             |

### Network Configuration
| Onvif Web Service | Onvif Function           | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|--------------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Device**        | GetHostname              | ✔                   | ✔         | ✔                                 | ✔                   |  ✔                   |
|                   | SetHostname              | ✔                   | ❌         | ✔                                 | ✔                   |    ✔                 |
|                   | GetDNS                   | ✔                   | ❌         | ✔                                 | ✔                   |   ✔                  |
|                   | SetDNS                   | ✔                   | ❌         | ✔                                 | ✔                   |     ✔               |
|                   | GetNetworkInterfaces     | ✔                   | ✔         | ✔                                 | ✔                   |   ✔                   |
|                   | SetNetworkInterfaces     | ✔                   | ❌         | ✔                                 | ✔                   |    ❌                  |
|                   | GetNetworkProtocols      | ✔                   | ✔         | ✔                                 | ✔                   |    ✔                  |
|                   | SetNetworkProtocols      | ✔                   | ❌         | ✔                                 | ✔                   |     ✔                 |
|                   | GetNetworkDefaultGateway | ✔                   | ❌         | ✔                                 | ✔                   |   ✔                   |
|                   | SetNetworkDefaultGateway | ✔                   | ❌         | ✔                                 | ✔                   |      ✔                |

### System Function
| Onvif Web Service | Onvif Function          | Hikvision DFI6256TE | Tapo C200                                                  | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|-------------------------|---------------------|------------------------------------------------------------|-----------------------------------|---------------------|---------------------|
| **Device**        | GetDeviceInformation    | ✔                   | ✔                                                          | ✔                                 | ✔                   |    ✔                  |
|                   | GetSystemDateAndTime    | ✔                   | ✔                                                          | ✔                                 | ✔                   |    ✔                  |
|                   | SetSystemDateAndTime    | ✔                   | ✔ [ⓘ](onvif-footnotes.md#tapo-c200---setsystemdateandtime) | ✔                                 | ✔                   |        ✔             |
|                   | SetSystemFactoryDefault | ✔                   | ✔                                                          | ✔                                 | ✔                   |              ✔        |
|                   | SystemReboot            | ✔                   | ✔                                                          | ✔                                 | ✔                   |           ✔           |

### User Handling
| Onvif Web Service | Onvif Function | Hikvision DFI6256TE | Tapo C200                                             | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------|---------------------|-------------------------------------------------------|-----------------------------------|---------------------|---------------------|
| **Device**        | GetUsers       | ✔                   | ❌ [ⓘ](onvif-footnotes.md#tapo-c200---user-management) | ✔                                 | ✔                   |    ✔                  |
|                   | CreateUsers    | ✔                   | ❌ [ⓘ](onvif-footnotes.md#tapo-c200---user-management) | ✔                                 | ✔                   |      ✔                |
|                   | DeleteUsers    | ✔                   | ❌ [ⓘ](onvif-footnotes.md#tapo-c200---user-management) | ✔                                 | ✔                   |       ✔               |
|                   | SetUser        | ✔                   | ❌ [ⓘ](onvif-footnotes.md#tapo-c200---user-management) | ✔                                 | ✔                   |    ✔                  |

### Metadata Configuration
| Onvif Web Service | Onvif Function                      | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|-------------------------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Media**         | GetMetadataConfigurations           | ✔                   | ❌         | ✔                                 | ✔                   |   ✔                   |
|                   | GetMetadataConfiguration            | ✔                   | ❌         | ✔                                 | ✔                   |  ✔                    |
|                   | GetCompatibleMetadataConfigurations | ✔                   | ❌         | ✔                                 | ✔                   |      ✔               |
|                   | GetMetadataConfigurationOptions     | ✔                   | ❌         | ✔                                 | ✔                   |     ✔                 |
|                   | AddMetadataConfiguration            | ✔                   | ❌         | ✔                                 | ✔                   |      ✔              |
|                   | RemoveMetadataConfiguration         | ✔                   | ❌         | ✔                                 | ✔                   |     ✔                |
|                   | SetMetadataConfiguration            | ✔                   | ❌         | ✔                                 | ✔                   |     ✔               |

### Video Streaming
| Onvif Web Service | Onvif Function | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Media**         | GetProfiles    | ✔                   | ✔         | ✔                                 | ✔                   |   ✔                   |
|                   | GetStreamUri   | ✔                   | ✔         | ✔                                 | ✔                   |  ✔                    |

### VideoEncoder Config
| Onvif Web Service | Onvif Function                      | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|-------------------------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Media**         | GetVideoEncoderConfigurations       |                     |           |                                   |                     |                     |
|                   | GetVideoEncoderConfiguration        | ✔                   | ✔         | ✔                                 | ✔                   |    ✔                   |
|                   | SetVideoEncoderConfiguration        | ✔                   | ❌         | ✔                                 | ✔                   |       ✔                 |
|                   | GetVideoEncoderConfigurationOptions | ✔                   | ✔         | ✔                                 | ✔                   |    ✔                   |

### PTZ Node
| Onvif Web Service | Onvif Function | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **PTZ**           | GetNodes       | ❌                   | ✔         | ❌                                 | ❌                   |    ✔                  |
|                   | GetNode        | ❌                   | ✔         | ❌                                 | ❌                   |    ✔                  |

### PTZ Configuration
| Onvif Web Service | Onvif Function          | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|-------------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **PTZ**           | GetConfigurations       | ❌                   | ✔         | ❌                                 | ❌                   |   ✔                    |
|                   | GetConfiguration        | ❌                   | ✔         | ❌                                 | ❌                   |    ✔                   |
|                   | GetConfigurationOptions | ❌                   | ✔         | ❌                                 | ❌                   |   ✔                    |
|                   | SetConfiguration        | ❌                   | ❌         | ❌                                 | ❌                   |     ✔                 |
| **Media**         | AddPTZConfiguration     | ❌                   | ❌         | ❌                                 | ❌                   |     ✔                |
| **Media**         | RemovePTZConfiguration  | ❌                   | ❌         | ❌                                 | ❌                   |       ✔              |

### PTZ Actuation
| Onvif Web Service | Onvif Function | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **PTZ**           | AbsoluteMove   | ❌                   | ✔         | ❌                                 | ❌                   |   ✔                  |
|                   | RelativeMove   | ❌                   | ✔         | ❌                                 | ❌                   |   ✔                  |
|                   | ContinuousMove | ❌                   | ✔         | ❌                                 | ❌                   |   ✔                  |
|                   | Stop           | ❌                   | ✔         | ❌                                 | ❌                   |   ✔                  |
|                   | GetStatus      | ❌                   | ✔         | ❌                                 | ❌                   |    ✔                 |

### PTZ Preset
| Onvif Web Service | Onvif Function | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **PTZ**           | SetPreset      | ❌                   | ✔         | ❌                                 | ❌                   |  ✔                   |
|                   | GetPresets     | ❌                   | ✔         | ❌                                 | ❌                   |  ✔                   |
|                   | GotoPreset     | ❌                   | ✔         | ❌                                 | ❌                   |   ✔                  |
|                   | RemovePreset   | ❌                   | ✔         | ❌                                 | ❌                   |   ✔                  |

### PTZ Home Position
| Onvif Web Service | Onvif Function   | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **PTZ**           | GotoHomePosition | ❌                   | ❌         | ❌                                 | ❌                   |         ✔            |
|                   | SetHomePosition  | ❌                   | ❌         | ❌                                 | ❌                   |      ✔               |

### PTZ Auxiliary Operations
| Onvif Web Service | Onvif Function       | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **PTZ**           | SendAuxiliaryCommand | ❌                   | ❌         | ❌                                 | ❌                   |    ❌                 |

### Event Handling
| Onvif Web Service | Onvif Function              | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|-----------------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Event**         | Notify                      | ✔                   | ❌         | ✔                                 | ❌                   |                     |
|                   | Subscribe                   | ✔                   | ❌         | ✔                                 | ❌                   |                     |
|                   | Renew                       | ❌                   | ❌         | ✔                                 | ❌                   |                     |
|                   | Unsubscribe                 | ✔                   | ❌         | ✔                                 | ❌                   |                     |
|                   | CreatePullPointSubscription | ✔                   | ❌         | ✔                                 | ❌                   |                     |
|                   | PullMessages                | ✔                   | ❌         | ✔                                 | ❌                   |                     |
|                   | TopicFilter                 | ✔                   | ❌         | ✔                                 | ❌                   |                     |
|                   | MessageContentFilter        | ❌                   | ❌         | ❌                                 | ❌                   |                     |
|                   | GetEventProperties          |                     | ✔         |                                   |                     |                     |

### Analytics Profile Configuration
| Onvif Web Service | Onvif Function             | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Media2**        | GetProfiles                | ❌                   | ❌         | ✔                                 | ❌                   |    ✔                  |
|                   | GetAnalyticsConfigurations | ❌                   | ❌         | ✔                                 | ❌                   |    ✔                  |
|                   | AddConfiguration           | ❌                   | ❌         | ✔                                 | ❌                   |     ❌                |
|                   | RemoveConfiguration        | ❌                   | ❌         | ✔                                 | ❌                   |     ❌                |

### Analytics Module Configuration
| Onvif Web Service | Onvif Function               | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|------------------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Analytics**     | GetSupportedAnalyticsModules | ❌                   | ❌         | ✔                                 | ❌                   |    ❌                  |
|                   | GetAnalyticsModules          | ❌                   | ❌         | ✔                                 | ❌                   |  ❌                    |
|                   | CreateAnalyticsModules       | ❌                   | ❌         | ❌                                 | ❌                   |  ❌                    |
|                   | DeleteAnalyticsModules       | ❌                   | ❌         | ❌                                 | ❌                   |   ❌                   |
|                   | GetAnalyticsModuleOptions    | ❌                   | ❌         | ✔                                 | ❌                   |    ❌                  |
|                   | ModifyAnalyticsModules       | ❌                   | ❌         | ✔                                 | ❌                   |     ❌                 |

### Rule Configuration
| Onvif Web Service | Onvif Function    | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD | GeoVision GV-BX8700 | Hikvision DS-2DE2A404IW-DE3 |
|-------------------|-------------------|---------------------|-----------|-----------------------------------|---------------------|---------------------|
| **Analytics**     | GetSupportedRules | ❌                   | ❌         | ✔                                 | ❌                   |     ❌                |
|                   | GetRules          | ❌                   | ❌         | ✔                                 | ❌                   |  ❌                   |
|                   | CreateRules       | ❌                   | ❌         | ✔                                 | ❌                   |   ❌                  |
|                   | DeleteRules       | ❌                   | ❌         | ✔                                 | ❌                   |  ❌                   |
|                   | GetRuleOptions    | ❌                   | ❌         | ✔                                 | ❌                   |     ❌                |
|                   | ModifyRules       | ❌                   | ❌         | ✔                                 | ❌                   |    ❌                 |

### Custom EdgeX
| Onvif Web Service | Onvif Function | Hikvision DFI6256TE | Tapo C200 | BOSCH DINION IP starlight 6000 HD             | GeoVision GV-BX8700 |Hikvision DS-2DE2A404IW-DE3 |
|-------------------|----------------|---------------------|-----------|-----------------------------------------------|---------------------|---------------------|
| **EdgeX**         | GetSnapshot    | ✔                   | ❌         | ✔ [ⓘ](onvif-footnotes.md#bosch---getsnapshot) | ❌                   |       ✔               |
