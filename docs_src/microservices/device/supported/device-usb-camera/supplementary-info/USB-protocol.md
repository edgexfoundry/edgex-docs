# USB Camera Device Service Specifications

## USB Protocol Properties
| Property | Description | EdgeX Value Type |               
| -- | -- |  |  
| **Paths** | **DEPRECATED: Path will be removed in the next major release, use Paths**. A list of internal [/dev/video paths](https://www.kernel.org/doc/html/v4.9/media/uapi/v4l/dev-capture.html) for the camera device. This list includes all streaming capable video paths for each device. | Object |  
| **SerialNumber** | The serial number of the camera device. | String |  
| **CardName** | The manufacturer specified name of the camera device. | String |
| **AutoStreaming** | A value indicating if the device should automatically start streaming. | String |
