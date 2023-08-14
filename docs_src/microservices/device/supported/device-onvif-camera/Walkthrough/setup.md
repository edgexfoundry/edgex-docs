# Setup

Follow this guide to set up your system to run the ONVIF Device Service.

## System Requirements

- Intel&#8482; Core&#174; processor
- Ubuntu 20.04.4 LTS or later
- ONVIF-compliant Camera

!!! note
    The instructions in this guide were developed and tested using Ubuntu 20.04 LTS and the Tapo C200 Pan/Tilt Wi-Fi Camera, referred to throughout this document as the **Tapo C200 Camera**. However, the software may work with other Linux distributions and ONVIF-compliant cameras. Refer to our [list of tested cameras for more information](../supplementary-info/ONVIF-protocol.md#tested-onvif-cameras)

**Other Requirements**

You must have administrator (sudo) privileges to execute the user guide commands.  

Make sure that the cameras are secured and the computer system runnning this software is secure.

## Dependencies
The software has dependencies, including Git, Docker, Docker Compose, and assorted tools. Follow the instructions below to install any dependency that is not already installed. 

### Install Git
Install Git from the official repository as documented on the [Git SCM](https://git-scm.com/download/linux) site.

1. Update installation repositories:
   ```bash
   sudo apt update
   ```

2. Add the Git repository:
   ```bash
   sudo add-apt-repository ppa:git-core/ppa -y
   ```

3. Install Git:
   ```bash
   sudo apt install git
   ```

### Install Docker
Install Docker from the official repository as documented on the [Docker](https://docs.docker.com/engine/install/ubuntu/) site.

### Verify Docker
To enable running Docker commands without the preface of sudo, add the user to the Docker group. Then run Docker with the `hello-world` test.

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

4. To verify the Docker installation, run <code>hello-world</code>:
      ```bash
      docker run hello-world
      ```
      A <strong>Hello from Docker!</strong> greeting indicates successful installation.

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

### Install Tools
Install the build, media streaming, and parsing tools:

```bash
sudo apt install build-essential ffmpeg jq curl
```

### Tool Descriptions
The table below lists command line tools this guide uses to help with EdgeX configuration and device setup.

| Tool        | Description | Note |
| ----------- | ----------- |----------- |
| **curl**     | Allows the user to connect to services such as EdgeX. |Use curl to get transfer information either to or from this service. In the tutorial, use `curl` to communicate with the EdgeX API. The call will return a JSON object.|
| **jq**   |Parses the JSON object returned from the `curl` requests. |The `jq` command includes parameters that are used to parse and format data. In this tutorial, the `jq` command has been configured to return and format appropriate data for each `curl` command that is piped into it. |
| **base64**   | Converts data into the Base64 format.| |

>Table 1: Command Line Tools

## Download EdgeX Compose
Clone the EdgeX compose repository:
```bash
git clone https://github.com/edgexfoundry/edgex-compose.git
```

## Proxy Setup (Optional)

!!! Note
    The device used for deployment of device-onvif-service must be behind proxy/VPN.


Setup Docker Daemon or Docker Desktop to use proxied environment.

- Follow guide [here](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy) for Docker Daemon proxy setup

- Follow guide [here](https://docs.docker.com/desktop/settings/windows/#proxies) for Docker Desktop proxy setup

!!! example - "http.conf file to configure Docker Client proxy"
    ```
        {
            "proxies": {
                "httpProxy": "http://proxy.example.com:3128",
                "httpsProxy": "https://proxy.example.com:3129",
                "noProxy": "*.test.example.com,.example.org,127.0.0.0/8"
            }
        }
    ```

!!! Note - "Note if building custom images"
    If building your own custom images, set environment variables for HTTP_PROXY, HTTPS_PROXY and NO_PROXY
    !!! example
        ```
        export HTTP_PROXY=http://proxy.example.com:3128
        export HTTPS_PROXY=https://proxy.example.com:3129
        export NO_PROXY=*.test.example.com,localhost,127.0.0.0/8
        ```

!!! Note
      Automated discovery of ONVIF device requires using provided script to get proper discovery subnets and proper network interface.

## Next Steps

   [Default Images>](./deployment.md){: .md-button }

!!! Warning
      While not recommended, you can follow the process for manually building the images.

   [Build Images>](./custom-build.md){: .md-button } 

## License

[Apache-2.0](https://github.com/edgexfoundry-holding/device-onvif-camera/blob/{{version}}/LICENSE)
