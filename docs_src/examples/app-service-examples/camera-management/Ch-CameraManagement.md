# Camera Management Example App Service
Use the Camera Management Example application service to auto discover and connect to nearby ONVIF and USB based cameras. This application will also control cameras via commands, create inference pipelines for the camera video streams and publish inference results to MQTT broker.

This app uses [EdgeX compose][edgex-compose], [Edgex Onvif Camera device service][device-onvif-camera], 
[Edgex USB Camera device service][device-usb-camera], [Edgex MQTT device service][device-mqtt] and [Edge Video Analytics Microservice][evam].


## Install Dependencies

### Environment
This example has been tested with a relatively modern Linux environment - Ubuntu 20.04 and later

### Install Docker
Install Docker from the official repository as documented on the [Docker](https://docs.docker.com/engine/install/ubuntu/) site.

### Configure Docker
To enable running Docker commands without the preface of sudo, add the user to the Docker group.

!!! warning
    The docker group grants root-level privileges to the user. For details on how this impacts security in your system, see [Docker Daemon Attack Surface](https://docs.docker.com/engine/security/#docker-daemon-attack-surface).

1. Create Docker group:
    ```bash
    sudo groupadd docker
    ```

    !!! note
        If the group already exists, `groupadd` outputs a message: **groupadd: group `docker` already exists**. This is OK.

2. Add User to group:
   ```bash
   sudo usermod -aG docker $USER
   ```

3. Restart your computer for the changes to take effect.

### Verify Docker
To verify the Docker installation, run `hello-world`:

```bash
docker run hello-world
```
A **Hello from Docker!** greeting indicates successful installation.

```bash
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete 
Digest: sha256:10d7d58d5ebd2a652f4d93fdd86da8f265f5318c6a73cc5b6a9798ff6d2b2e67
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

### Install Docker Compose
Install Docker Compose from the official repository as documented on the [Docker Compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository) site.

### Install Golang
Install Golang from the official [Golang](https://go.dev/doc/install) website.

### Install Tools
Install build tools:

```bash
sudo apt install build-essential
```

## Steps for running this example:

### 1. Start the EdgeX Core Services and Device Services.

1. Clone `edgex-compose` from github.com.
    ```shell 
    git clone https://github.com/edgexfoundry/edgex-compose.git
    ```  

1. Navigate to the `edgex-compose` directory:
    ```bash
    cd edgex-compose
    ```

1. Checkout the latest release ({{version}}):
    ```shell
    git checkout {{version}}
    ```

1. Navigate to the `compose-builder` subdirectory:
    ```bash
    cd compose-builder/
    ```

1. (Optional) Update the `add-device-usb-camera.yml` file:

    !!! note
        This step is only required if you plan on using USB cameras.

    a. Add enable rtsp server and the rtsp server hostname environment variables to the `device-usb-camera` service, where `your-local-ip-address` is the ip address of the machine running the `device-usb-camera` service.

    !!! example - "Snippet from `add-device-usb-camera.yml`"
        ```yml
        services:
          device-usb-camera:
            environment:
              DRIVER_ENABLERTSPSERVER: "true"
              DRIVER_RTSPSERVERHOSTNAME: "your-local-ip-address"
        ```

    b. Under the `ports` section, find the entry for port 8554 and change the host_ip from `127.0.0.1` to either `0.0.0.0` or the ip address you put in the previous step.

1. Clone the EdgeX Examples repository :
    ```bash
    git clone https://github.com/edgexfoundry/edgex-examples.git
    ```

1. Navigate to the `edgex-examples` directory:
    ```bash
    cd edgex-examples
    ```

1. Checkout the latest release ({{version}}):
    ```shell
    git checkout {{version}}
    ```

1. Navigate to the `application-services/custom/camera-management` directory
    ```bash
    cd application-services/custom/camera-management
    ```

1. Configure [device-mqtt] service to send [Edge Video Analytics Microservice][evam] inference results into Edgex via MQTT

    a. Copy the entire [evam-mqtt-edgex](https://github.com/edgexfoundry/edgex-examples/tree/{{version}}/application-services/custom/camera-management/edge-video-analytics/evam-mqtt-edgex) folder into `edgex-compose/compose-builder` directory.

    b. Add this information into the [add-device-mqtt.yml](https://github.com/edgexfoundry/edgex-compose/blob/{{version}}/compose-builder/add-device-mqtt.yml) file in the `edgex-compose/compose-builder` directory.

    !!! example - "Snippet from add-device-mqtt.yml"
        ```yaml
        services:
          device-mqtt:
            ...
            environment:
              DEVICE_DEVICESDIR: /evam-mqtt-edgex/devices
              DEVICE_PROFILESDIR: /evam-mqtt-edgex/profiles
              MQTTBROKERINFO_INCOMINGTOPIC: "incoming/data/#"
              MQTTBROKERINFO_USETOPICLEVELS: "true"
              ...
            ...  
            volumes:
              # example: - /home/github.com/edgexfoundry/edgex-compose/compose-builder/evam-mqtt-edgex:/evam-mqtt-edgex
              - <add-absolute-path-of-your-edgex-compose-builder-here-example-above>/evam-mqtt-edgex:/evam-mqtt-edgex
        ```
    c. Add this information into the [add-mqtt-broker-mosquitto.yml](https://github.com/edgexfoundry/edgex-compose/blob/{{version}}/compose-builder/add-mqtt-broker-mosquitto.yml) file in the `edgex-compose/compose-builder` directory.

    !!! example - "Snippet from add-mqtt-broker-mosquitto.yml"
        ```yaml
        services:
          mqtt-broker:
            ...
            ports:
              ...
              - "59001:9001"
            ...
            volumes:
              # example: - /home/github.com/edgexfoundry/edgex-compose/compose-builder/evam-mqtt-edgex:/evam-mqtt-edgex
              - <add-absolute-path-of-your-edgex-compose-builder-here>/evam-mqtt-edgex/mosquitto.conf:/mosquitto-no-auth.conf:ro            
        ```

    !!! note
        Please note that both the services in this file need the absolute path to be inserted for their volumes.
   
1. Run the following command to start all the Edgex services.

    !!! note
        The `ds-onvif-camera` parameter can be omitted if no Onvif cameras are present, or the `ds-usb-camera` parameter can be omitted if no usb cameras are present.
    
    ```shell
    make run no-secty ds-mqtt mqtt-broker ds-onvif-camera ds-usb-camera 
    ```   

### 2. Start [Edge Video Analytics Microservice][evam] running for inference.

1. Open cloned `edgex-examples` repo and navigate to the `edgex-examples/application-services/custom/camera-management` directory:
    ```bash
    cd edgex-examples/application-services/custom/camera-management
    ```

1. Run this once to download edge-video-analytics into the edge-video-analytics sub-folder, download models, and patch pipelines
    ```bash
    make install-edge-video-analytics
    ```

### 3. Build and run the example application service

#### 3.1 (Optional) Configure Onvif Camera Credentials.
    
!!! note
    This step is only required if you have Onvif cameras. Currently, this example app is limited to supporting only 1 username/password combination for all Onvif cameras.

!!! note
    Please follow the instructions for the [Edgex Onvif Camera device service][device-onvif-manage] in order to connect your Onvif cameras to EdgeX.

=== "configuration.yaml"

    Modify the [res/configuration.yaml](https://github.com/edgexfoundry/edgex-examples/blob/{{version}}/application-services/custom/camera-management/res/configuration.yaml) file
 
    ```yaml
    InsecureSecrets:
      onvifauth:
        SecretName: onvifauth
        SecretData:
          username: "<username>"
          password: "<password>"
    ```

=== "env vars"

    Export environment variable overrides
    ```shell
    export WRITABLE_INSECURESECRETS_ONVIFAUTH_SECRETDATA_USERNAME="<username>"
    export WRITABLE_INSECURESECRETS_ONVIFAUTH_SECRETDATA_PASSWORD="<password>"
    ```  

#### 3.2 (Optional) Configure USB Camera RTSP Credentials.
!!! note
    This step is only required if you have USB cameras.

!!! note
    Please follow the instructions for the [Edgex USB Camera device service][device-usb-manage] in order to connect your USB cameras to EdgeX.

=== "configuration.yaml"

    Modify the [res/configuration.yaml](https://github.com/edgexfoundry/edgex-examples/blob/{{version}}/application-services/custom/camera-management/res/configuration.yaml) file

    ```yaml
    InsecureSecrets:
      rtspauth:
        SecretName: rtspauth
        SecretData:
          username: "<username>"
          password: "<password>"
    ```

=== "env vars"

    Export environment variable overrides
    ```shell
    export WRITABLE_INSECURESECRETS_RTSPAUTH_SECRETDATA_USERNAME="<username>"
    export WRITABLE_INSECURESECRETS_RTSPAUTH_SECRETDATA_PASSWORD="<password>"
    ```  

#### 3.3 Configure Default Pipeline
Initially, all new cameras added to the system will start the default analytics pipeline as defined in the configuration file below. The desired pipeline can be changed or the feature can be disabled by setting the `DefaultPipelineName` and `DefaultPipelineVersion` to empty strings.   

Modify the [res/configuration.yaml](https://github.com/edgexfoundry/edgex-examples/blob/{{version}}/application-services/custom/camera-management/res/configuration.yaml) file with the name and version of the default pipeline to use when a new device is added to the system.

!!! note 
    These values can be left empty to disable the feature.

```yaml
AppCustom:
  DefaultPipelineName: object_detection # Name of the default pipeline used when a new device is added to the system; can be left blank to disable feature
  DefaultPipelineVersion: person # Version of the default pipeline used when a new device is added to the system; can be left blank to disable feature
```

#### 3.4 Build and run
1. Make sure you are at the root of this example app
    ```shell
    cd edgex-examples/application-services/custom/camera-management
    ```

1. Build the docker image
    ```bash
    make docker
    ```

1. Start the docker compose services in the background for both EVAM and Camera Management App
    ```bash
    docker compose up -d
    ```

!!! note
    If you would like to view the logs for these services, you can use `docker compose logs -f`. To stop the services, use `docker compose down`.

!!! note
    The port for EVAM result streams has been changed from 8554 to 8555 to avoid conflicts with the device-usb-camera service.

## Using the App

Visit [http://localhost:59750](http://localhost:59750) to access the app.

![homepage](./images/homepage-demo-app-1.png)  
<p align="left">
<i>Figure 1: Homepage for the Camera Management app</i>
</p>

### Camera Position

You can control the position of supported cameras using ptz commands.

![camera-position](./images/camera-position.png)  

- Use the arrows to control the direction of the camera movement.
- Use the magnifying glass icons to control the camera zoom.

### Start an Edge Video Analytics Pipeline

This section outlines how to start an analytics pipeline for inferencing on a specific camera stream.

![camera](./images/camera.png)  

1. Select a camera out of the drop down list of connected cameras.  
   ![select-camera](./images/select-camera.png)  

1. Select a video stream out of the drop down list of connected cameras.  
   ![select-profile](./images/select-profile.png)  

1. Select a analytics pipeline out of the drop down list of connected cameras.  
   ![select-pipeline](./images/select-pipeline.png)  

1. Click the `Start Pipeline` button.


### Running Pipelines

Once the pipeline is running, you can view the pipeline and its status.

![default pipelines state](./images/multiple-pipelines-default.png)  

Expand a pipeline to see its status. This includes important information such as elapsed time, latency, frames per second, and elapsed time.  
   ![select-camera](./images/running-pipelines.png)  

In the terminal where you started the app, once the pipeline is started, this log message will pop up.
    ```bash
    level=INFO ts=2022-07-11T22:26:11.581149638Z app=app-camera-management source=evam.go:115 msg="View inference results at 'rtsp://<SYSTEM_IP_ADDRESS>:8555/<device name>'"
    ```

Use the URI from the log to view the camera footage with analytics overlayed.
    ```bash
    ffplay 'rtsp://<SYSTEM_IP_ADDRESS>:8555/<device name>'
    ```

   Example Output:  
   
![example analytics](./images/example-analytics.png)
    <p align="left">
    <i>Figure 2: analytics stream with overlay
    </p>

If you want to stop the stream, press the red square:

![stop pipeline](./images/stop-pipeline.png) 
    <p align="left">
    <i>Figure 3: the red square to shut down the pipeline
    </p>


### API Log

The API log shows the status of the 5 most recent calls and commands that the management has made. This includes important information from the responses, including camera information or error messages.

![API Logs](./images/api-log.png)  

Expand a log item to see the response

   Good response:
   ![good api response](./images/good-response.png)  
   Bad response:
   ![bad api response](./images/bad-response.png)  

### Inference Events

![inference events default](./images/inference-events-default.png)  

To view the inference events in a json format, click the `Stream Events` button.

![inference events](./images/inference-events.png)  

### Inference results in Edgex

To view inference results in Edgex, open Edgex UI [http://localhost:4000](http://localhost:4000), click on the `DataCenter`
tab and view data streaming under `Event Data Stream`by clicking on the `Start` button.

![inference events](./images/inference-edgex.png)

### Next steps
A custom app service can be used to analyze this inference data and take action based on the analysis.

## Video Example
A brief video demonstration of building and using the device service:
!!! warning
    This video was created with a previous release. Some new features may not be depicted in this video, and there might be some extra steps needed to configure the service.

<iframe
    width="100%"
    height="480"
    src="https://www.youtube.com/embed/vZqd3j2Zn2Y"
    frameborder="0"
    allow="autoplay; encrypted-media"
    allowfullscreen
>
</iframe>

## Additional Development

!!! warning
    The following steps are only useful for developers who wish to make modifications to the code and the Web-UI.

#### Development and Testing of UI
##### 1. Build the production web-ui
This builds the web ui into the `web-ui/dist` folder, which is what is served by the app service on port 59750.
```shell
make web-ui
```

##### 2. Serve the Web-UI in hot-reload mode
This will serve the web ui in hot reload mode on port 4200 which will recompile and update anytime you make changes to a file. It is useful for
rapidly testing changes to the UI.
```shell
make serve-ui
```

Open your browser to [http://localhost:4200](http://localhost:4200)


[edgex-compose]: https://github.com/edgexfoundry/edgex-compose
[device-onvif-camera]: https://github.com/edgexfoundry/device-onvif-camera
[device-onvif-manage]: ../../../microservices/device/supported/device-onvif-camera/Walkthrough/deployment.md#manage-devices
[device-usb-camera]: https://github.com/edgexfoundry/device-usb-camera
[device-usb-manage]: ../../../microservices/device/supported/device-usb-camera/walkthrough/deployment.md#manage-devices
[evam]: https://www.intel.com/content/www/us/en/developer/articles/technical/video-analytics-service.html
[device-mqtt]: https://github.com/edgexfoundry/device-mqtt-go
