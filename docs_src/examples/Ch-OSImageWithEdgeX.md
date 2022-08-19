# Creating an EdgeX OS Image

This document walks you through creating an OS image that is preloaded with an EdgeX stack. We use [Ubuntu Core] as the OS, which is optimized for IoT and allows secure deployment of applications. We build the image using the default tooling and the snapped versions of EdgeX components. Since snaps receive automatic and transactional updates, the components stay up to date reliably with the latest security and bug fixes.

This guide is divided into three chapters:

- Creating an image with EdgeX components, using default configurations
- Overriding basic service configurations
- Replacing default service configurations

Each chapter results in a working Ubuntu Core OS image that can be flashed on a drive and boot up with the expected EdgeX stack. 

In this example, we will use the Device Virtual service to simulate devices and produce synthetic events. We will create an `amd64` image, but the instructions can be adapted to other architectures and even for a Raspberry Pi.

We will use the following tools:

- [snapcraft](https://snapcraft.io/snapcraft) to manage keys in the store and build snaps
- [YQ](https://snapcraft.io/yq) to validate YAML files and convert them to JSON
- [ubuntu-image](https://snapcraft.io/ubuntu-image) to build the Ubuntu Core image
- [EdgeX CLI](https://snapcraft.io/edgex-cli) to query information from EdgeX core components 

It is a good idea to read through the [Getting Started using Snaps](../../getting-started/Ch-GettingStartedSnapUsers) before working on this walk-through or at any point to better understand the concepts.

This guide has been tested on **Ubuntu 22.04** as *development environment*. It may work on other Linux distributions and Ubuntu versions. 



## A. Create an image with EdgeX components

In this chapter, we are going to create OS image that includes the expected EdgeX components. Perform these steps in your development environment.

### Configure the Ubuntu Core volumes
Configuring the volumes is possible via a Gadget snap.

We will use the [pc-amd64-gadget](https://github.com/snapcore/pc-amd64-gadget) as basis and build on top of it.

!!! tip
    For a Raspberry Pi, you need to use the [pi-gadget](https://github.com/snapcore/pi-gadget) instead.

Modify the following in `gadget.yml`. 
Under `volumes.pc.structure`:

- Find the item with name `ubuntu-seed` and increase its size to `1500M`. This is to make sure our snap will fit in the image.
- If planning to use an emulator: Find the item with name `ubuntu-data` and increase its size to `2G`. This is to give sufficient writable storage. When flashing on actual hardware, this volume would automatically take the whole remaining space (NEED TO VERIFY).

Build:
```bash
$ snapcraft
...
Snapped pc_20-0.4_amd64.snap
```

!!! note
    You need to rebuild the snap every time you change the `gadget.yaml` file.

### Create an Ubuntu Core model assertion
The model assertion is a document that describes the contents of the OS image. The document needs to be signed by its owner.

Refer to [this article](https://ubuntu.com/core/docs/custom-images#heading--signing) for details on how to sign the model assertion.

1. Create and register a key if you don't already have one:

```bash
snap login
snap keys
# continue if you have no existing keys
# you'll be asked to set a passphrase which is needed before signing
snap create-key edgex-demo
snapcraft register-key edgex-demo
```
We now have a registered key named `edgex-demo` which we'll use later.

2. Now, create the model assertion.

First, make yourself familiar with the Ubuntu Core [model assertion](https://ubuntu.com/core/docs/reference/assertions/model).

Find your developer ID using CLI:
```bash
$ snapcraft whoami
...
developer-id: SZ4OfFv8DVM9om64iYrgojDLgbzI0eiL
```
Or from https://dashboard.snapcraft.io/dev/account/.

Unlike the official documentation which uses JSON, we use YAML serialization for the model. This is for consistency with all the other serialization formats in this tutorial. Moreover, it allows us to comment out some parts for testing or add comments to describe the details inline.

Create `model.yaml` with the following content:
```yaml
type: model
series: '16'

# authority-id and brand-id must be set to your developer-id
authority-id: SZ4OfFv8DVM9om64iYrgojDLgbzI0eiL
brand-id: SZ4OfFv8DVM9om64iYrgojDLgbzI0eiL

model: ubuntu-core-20-amd64
architecture: amd64

# timestamp should be within your signature's validity period
timestamp: '2022-06-21T10:45:00+00:00'
base: core20

grade: dangerous

snaps:
- # This is our custom, dev gadget snap
  # It has no channel and id, because it isn't in the store.
  # We're going to build it locally and pass it to the image builder. 
  name: pc
  type: gadget
  # default-channel: 20/stable
  # id: UqFziVZDHLSyO3TqSWgNBoAdHbLI4dAH

- name: pc-kernel
  type: kernel
  default-channel: 20/stable
  id: pYVQrBcKmBa0mZ4CCN7ExT6jH8rY1hza

- name: snapd
  type: snapd
  default-channel: latest/stable
  id: PMrrV4ml8uWuEUDBT8dSGnKUYbevVhc4

- name: core20
  type: base
  default-channel: latest/stable
  id: DLqre5XGLbDqg9jPtiAhRRjDuPVa5X1q

- name: core22
  type: base
  default-channel: latest/stable
  id: amcUKQILKXHHTlmSa7NMdnXSx02dNeeT

- name: edgexfoundry
  type: app
  default-channel: latest/edge # using features added in 2.3 (unreleased)
  id: AZGf0KNnh8aqdkbGATNuRuxnt1GNRKkV

- name: edgex-device-virtual
  type: app
  default-channel: latest/edge # device virtual has not been released
  id: AmKuVTOfsN0uEKsyJG34M8CaMfnIqxc0
```

3. Sign the model

We sign the model using the `edgex-demo` key created and registered earlier. 

The `snap sign` command takes JSON as input and produces YAML as output! We use the YQ app to convert our model assertion to JSON before passing it in for signing.

```bash
# sign
yq eval model.yaml -o=json | snap sign -k edgex-demo > model.signed.yaml

# check the signed model
cat model.signed.yaml
```

!!! note
    You need to repeat the signing every time you change the input model, because the signature is calculated based on the model.

### Build the Ubuntu Core image
We use ubuntu-image and set the following:

- Path to signed model assertion YAML file
- Path to gadget snap that we built in the previous steps

This will download all the needed snaps and build a file called `pc.img`.
Note that even the kernel and OS base (core20) are snap packages!

```bash
$ ubuntu-image snap model.signed.yaml --validation=enforce --snap pc-amd64-gadget/pc_20-0.4_amd64.snap 
Fetching snapd
Fetching pc-kernel
Fetching core20
Fetching core22
Fetching edgexfoundry
Fetching edgex-device-virtual
WARNING: "pc" installed from local snaps disconnected from a store cannot be refreshed subsequently!
Copying "pc-amd64-gadget/pc_20-0.4_amd64.snap" (pc)

# check the image file
$ file pc.img
pc.img: DOS/MBR boot sector, extended partition table (last)
```

The warning is because we side-loaded the gadget for demonstration purposes. In production settings, a custom gadget would need to be uploaded to the [store](https://ubuntu.com/internet-of-things/appstore) to also receive updates.

!!! done
    The image file is now ready to be flashed on a medium to create a bootable drive with the needed applications!

#### Flash the image
You can use one of following to flash the image:
- [Ubuntu Startup Disk Creator](https://ubuntu.com/tutorials/create-a-usb-stick-on-ubuntu)
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- [`dd` command](https://ubuntu.com/download/iot/installation-media)

For instructions specific to a device, refer to Ubuntu Core section [here](https://ubuntu.com/download/iot); for example: [Intel NUC](https://ubuntu.com/download/intel-nuc).

Once the boot is complete, it will prompt for the email address of your [Ubuntu SSO account](https://login.ubuntu.com/) to deploy your [SSH public keys](https://login.ubuntu.com/ssh-keys). This is done with the help of a program called `console-conf`. Read [here](https://ubuntu.com/core/docs/system-user) to know how this manual step looks like and how it can be automated.

Instead of flashing and installing the OS on actual hardware, we will continue this guide using an Emulator. Every other step will be similar to when image is flashed and installed on actual hardware.

#### Run in an emulator
Running the image in an emulator makes it easier to quickly try the image and find out possible issues.

We use a `amd64` QEMU emulator. You may refer to [Testing Ubuntu Core with QEMU](https://ubuntu.com/core/docs/testing-with-qemu) and [Image building](https://ubuntu.com/core/docs/image-building#heading--testing) for more information.

Run the following command and wait for the boot to complete:
```bash
sudo qemu-system-x86_64 \
 -smp 4 \
 -m 4096 \
 -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on \
 -drive file=pc.img,cache=none,format=raw,id=disk1,if=none \
 -device virtio-blk-pci,drive=disk1,bootindex=1 \
 -machine accel=kvm \
 -serial mon:stdio \
 -net nic,model=virtio \
 -net user,hostfwd=tcp::8022-:22,hostfwd=tcp::8443-:8443,hostfwd=tcp::59880-:59880
```

The above command forwards the SSH port `22` of the emulator to `8022` on the host. In addition, it forwards the API Gateway's port `8433` for external and secure access to EdgeX endpoints Core Data's port `59880` for demonstration purposes.

As mentioned before, once the initial installation is complete, you will get a prompt for your email address to deploy your public key.

!!! tip
    The `pc.img` file passed to the emulator persists any changes made to the OS and user files after startup.
    You can stop and re-start the emulator at a later time without losing your changes.

    To do a fresh start, your need to rebuild the image.

!!! failure
    > Could not set up host forwarding rule 'tcp::8443-:8443'

    This means that the port is not available on the host. Try removing the service that uses this port or change the host port (left hand side) to another port number, e.g. `tcp::18443-:8443`.

### Connect, explore, configure

In this step, we connect to the machine that has the image installed via SSH, validate the installation, and do some manual configurations.

We SSH to the emulator from the previous step:
```bash
ssh <user>@localhost -p 8022
```
If you used the default approach (using `console-conf`) and entered your Ubuntu account email address at the end of the installation, then `<user>` is your Ubuntu account ID. If you don't know your ID, look it up using a browser from [here](https://login.ubuntu.com/) or programmatically from `https://login.ubuntu.com/api/v2/keys/<email>`.

List the installed snaps:
```
$ snap list
Name                  Version          Rev    Tracking       Publisher   Notes
core20                20220719         1587   latest/stable  canonical✓  base
core22                20220607         188    latest/stable  canonical✓  base
edgex-device-virtual  2.3.0-dev.10     150    latest/edge    canonical✓  -
edgexfoundry          2.3.0-dev.42     3893   latest/edge    canonical✓  -
pc                    20-0.4           x1     -              -           gadget
pc-kernel             5.4.0-122.138.1  1057   20/stable      canonical✓  kernel
snapd                 2.56.2           16292  latest/stable  canonical✓  snapd
```

Let's install the EdgeX CLI to easily query various APIs:
```
$ snap install edgex-cli
edgex-cli 2.2.0 from Canonical✓ installed
$ edgex-cli --help
EdgeX-CLI

Usage:
  edgex-cli [command]

Available Commands:
  command          Read, write and list commands [Core Command]
  completion       Generate the autocompletion script for the specified shell
  config           Return the current configuration of all EdgeX core/support microservices
  device           Add, remove, get, list and modify devices [Core Metadata]
  deviceprofile    Add, remove, get and list device profiles [Core Metadata]
  deviceservice    Add, remove, get, list and modify device services [Core Metadata]
  event            Add, remove and list events
  help             Help about any command
  interval         Add, get and list intervals [Support Scheduler]
  intervalaction   Get, list, update and remove interval actions [Support Scheduler]
  metrics          Output the CPU/memory usage stats for all EdgeX core/support microservices
  notification     Add, remove and list notifications [Support Notifications]
  ping             Ping (health check) all EdgeX core/support microservices
  provisionwatcher Add, remove, get, list and modify provison watchers [Core Metadata]
  reading          Count and list readings
  subscription     Add, remove and list subscriptions [Support Notificationss]
  transmission     Remove and list transmissions [Support Notifications]
  version          Output the current version of EdgeX CLI and EdgeX microservices

Flags:
  -h, --help   help for edgex-cli

Use "edgex-cli [command] --help" for more information about a command.

$ edgex-cli ping
core-metadata: Thu Aug 11 10:27:47 UTC 2022
core-data: Thu Aug 11 10:27:47 UTC 2022
core-command: Thu Aug 11 10:27:47 UTC 2022
```

We can verify that the core services are alive.

Let's now query the devices:
```
$ edgex-cli device list
No devices available
```

There are no devices, because the installed EdgeX Device Virtual is disabled and not started by default.

```
$ snap start edgex-device-virtual 
Started.
$ snap logs -f edgex-device-virtual 
2022-08-11T10:34:19Z edgex-device-virtual.device-virtual[5483]: level=INFO ts=2022-08-11T10:34:19.238771398Z app=device-virtual source=devices.go:87 msg="Device Random-UnsignedInteger-Device not found in Metadata, adding it ..."
...
2022-08-11T10:34:19Z edgex-device-virtual.device-virtual[5483]: level=INFO ts=2022-08-11T10:34:19.247960347Z app=device-virtual source=message.go:58 msg="Service started in: 417.152451ms"
```

This shows that the virtual devices have been added to Core Metadata and the service has started. Rerun the same CLI command:

```
$ edgex-cli device list
Name                           Description                ServiceName     ProfileName                    Labels                    AutoEvents
Random-Float-Device            Example of Device Virtual  device-virtual  Random-Float-Device            [device-virtual-example]  [{30s false Float32} {30s false Float64}]
Random-Integer-Device          Example of Device Virtual  device-virtual  Random-Integer-Device          [device-virtual-example]  [{15s false Int8} {15s false Int16} {15s false Int32} {15s false Int64}]
Random-Binary-Device           Example of Device Virtual  device-virtual  Random-Binary-Device           [device-virtual-example]  []
Random-Boolean-Device          Example of Device Virtual  device-virtual  Random-Boolean-Device          [device-virtual-example]  [{10s false Bool}]
Random-UnsignedInteger-Device  Example of Device Virtual  device-virtual  Random-UnsignedInteger-Device  [device-virtual-example]  [{20s false Uint8} {20s false Uint16} {20s false Uint32} {20s false Uint64}]
```

From the service logs, we can't see if the service is actually producing data. We can increase the logging verbosity by modifying the service log level:

```
$ snap set edgex-device-virtual config.writable-loglevel=DEBUG
$ snap restart edgex-device-virtual 
Restarted.
$ snap logs -f edgex-device-virtual 
...
2022-08-11T10:35:39Z edgex-device-virtual.device-virtual[5731]: level=INFO ts=2022-08-11T10:35:39.445141593Z app=device-virtual source=message.go:58 msg="Service started in: 74.554045ms"
2022-08-11T10:35:49Z edgex-device-virtual.device-virtual[5731]: level=DEBUG ts=2022-08-11T10:35:49.445151427Z app=device-virtual source=executor.go:52 msg="AutoEvent - reading Bool"
2022-08-11T10:35:49Z edgex-device-virtual.device-virtual[5731]: level=DEBUG ts=2022-08-11T10:35:49.445224126Z app=device-virtual source=command.go:127 msg="Application - readDeviceResource: reading deviceResource: Bool; X-Correlation-ID: "
2022-08-11T10:35:49Z edgex-device-virtual.device-virtual[5731]: level=DEBUG ts=2022-08-11T10:35:49.445329507Z app=device-virtual source=transform.go:121 msg="device: Random-Boolean-Device DeviceResource: Bool reading: {Id:3d7322bb-6d67-436d-a7f5-37fe90acf885 Origin:1660214149445259654 DeviceName:Random-Boolean-Device ResourceName:Bool ProfileName:Random-Boolean-Device ValueType:Bool Units: BinaryReading:{BinaryValue:[] MediaType:} SimpleReading:{Value:false} ObjectReading:{ObjectValue:<nil>}}"
2022-08-11T10:35:49Z edgex-device-virtual.device-virtual[5731]: level=DEBUG ts=2022-08-11T10:35:49.45082594Z app=device-virtual source=utils.go:80 msg="Event(profileName: Random-Boolean-Device, deviceName: Random-Boolean-Device, sourceName: Bool, id: 8dbf1a85-9876-4165-bc07-88e043bb7904) published to MessageBus"
```

The data is being published to the message bus and Core Data will be storing it. We can query to find out:

```
$ edgex-cli reading list --limit=2
Origin               Device                         ProfileName                    Value                 ValueType
11 Aug 22 10:50 UTC  Random-UnsignedInteger-Device  Random-UnsignedInteger-Device  14610331353796717782  Uint64
11 Aug 22 10:50 UTC  Random-UnsignedInteger-Device  Random-UnsignedInteger-Device  62286                 Uint16
```

We now have a running EdgeX platform with dummy devices, producing synthetic readings. We can access this data on the localhost, but not from another host. This is because the local service ports only listen on the loopback interface. Access from outside is only allowed via the API Gateway and after authentication. 

It is possible to configure the services to listen to other or all interfaces and access them from outside. Note that this will expose the endpoint without any access control!

To make Core Data's server listen to all interfaces (at your own risk):
```
$ snap set edgexfoundry app-options=true
$ snap set edgexfoundry apps.core-data.config.service-serverbindaddr="0.0.0.0"
$ snap restart edgexfoundry.core-data
Restarted
```

!!! tip
    Drop the `apps.core-data.` prefix to make this a global configuration setting for all EdgeX services inside that snap!


Let's exit the SSH session and query data from outside:
```
$ exit
logout
Connection to localhost closed.

$ curl --silent --show-err http://localhost:59880/api/v2/reading/all?limit=2 | jq
{
  "apiVersion": "v2",
  "statusCode": 200,
  "totalCount": 7040,
  "readings": [
    {
      "id": "5907adb3-18f6-4cf9-9826-216285b7f519",
      "origin": 1660225195484643300,
      "deviceName": "Random-Integer-Device",
      "resourceName": "Int32",
      "profileName": "Random-Integer-Device",
      "valueType": "Int32",
      "value": "445276022"
    },
    {
      "id": "86c87583-a220-44d9-b29a-e412efa97cc3",
      "origin": 1660225195423943200,
      "deviceName": "Random-Integer-Device",
      "resourceName": "Int64",
      "profileName": "Random-Integer-Device",
      "valueType": "Int64",
      "value": "-6696458089943342374"
    }
  ]
}
```

However, as expected, we can't access securely via the API Gateway:
```
$ curl --insecure https://localhost:8443/core-data/api/v2/reading/all?limit=2
{"message":"Unauthorized"}
```

You can follow the instructions from the [getting started](../../getting-started/Ch-GettingStartedSnapUsers/#adding-api-gateway-users) to create a key pair, add a user to API Gateway, and generate a JWT token to access the API securely.

In this chapter, we demonstrated how to build an image that is pre-loaded with some EdgeX snaps. We then connected into a (virtual) machine instantiated with the image, verified the setup and performed additional steps to interactively start and configure the services.

In the next chapter, we walk you through creating an image that comes pre-loaded with this configuration, so it boots into a working EdgeX environment that even includes your public key and user.

## B. Override basic service configurations
!!! todo
    Using custom gadget to set defaults and an admin user

    
In this chapter, we will improve our OS image so that:

- We don't need to manually start EdgeX Device Virtual
- We have our public key inside the image and can securely access the endpoint via API Gateway.

### Create key pair and JWT token
Create a private/public key pair:
```
$ openssl ecparam -genkey -name prime256v1 -noout -out private.pem
$ openssl ec -in private.pem -pubout -out public.pem
read EC key
writing EC key
```

Print the public key:
```
$ cat public.pem 
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE5slZTyp5Zfxoos7TljHgPSbGm3As
NZGr6EEet300xbC4VUVGcQBSEsSZmGMTxaCMlzvKt1dwUNxBFDAemWXSyg==
-----END PUBLIC KEY-----
```
In the next section, we will add this as the public key of the admin user.

Create a script called `create-jwt.sh` with the following content:
```bash
#!/bin/bash -e

# this is hardcoded because we'll be adding an admin user with this ID to the image
USER_ID=1

header='{
    "alg": "ES256",
    "typ": "JWT"
}'

TTL=$((EPOCHSECONDS+86400)) # valid for 1 day

payload='{
    "iss":"'$USER_ID'",
    "iat":'$EPOCHSECONDS',
    "nbf":'$EPOCHSECONDS',
    "exp":'$TTL'
}'

echo "Payload: $payload"

JWT_HEADER=`echo -n $header | openssl base64 -e -A | sed s/\+/-/ | sed -E s/=+$//`
JWT_PAYLOAD=`echo -n $payload | openssl base64 -e -A | sed s/\+/-/ | sed -E s/=+$//`
JWT_SIGNATURE=`echo -n "$JWT_HEADER.$JWT_PAYLOAD" | openssl dgst -sha256 -binary -sign private.pem  | openssl asn1parse -inform DER  -offset 2 | grep -o "[0-9A-F]\+$" | tr -d '\n' | xxd -r -p | base64 -w0 | tr -d '=' | tr '+/' '-_'`

TOKEN=$JWT_HEADER.$JWT_PAYLOAD.$JWT_SIGNATURE

echo $TOKEN > admin-jwt.txt
echo "Wrote token to admin-jwt.txt:"
echo "$TOKEN"
```

The script will read the `private.pem` file from the same directory.

Run the script to get a JWT (JSON Web Token):
```
$ ./create-jwt.sh 
Payload: {
    "iss":"1",
    "iat":1660314677,
    "nbf":1660314677,
    "exp":1660401077
}
Wrote token to admin-jwt.txt:
eyAiYWxnIjogIkVTMjU2IiwgInR5cCI6ICJKV1QiIH0.eyAiaXNzIjoiMSIsICJpYXQiOjE2NjAzMTQ2NzcsICJuYmYiOjE2NjAzMTQ2NzcsICJleHAiOjE2NjA0MDEwNzcgfQ.giBrf2UQjMRATBXZnJ-6B3dJQbeoVjfjlVhsjCtbjJBYBjJ8_qZW_s2YPZs3fWSpMWUVTX05Jsj1Xg4wnlQrGA
```
The token is printed and also written to `admin-jwt.txt`. We'll use this token in the next steps to access API Gateway securely. Note that the token is valid for a pre-defined period.

### Setup defaults using a Gadget snap
Setting up default options for snaps is possible with the gadget snap. 
We will go back to the same `gadget.yml` file for the gadget that we used to resize the volumes, but this time also add a new top level `defaults` key:

Add the following to `gadget.yml`:
```yml
# Add default config options
# The keys are unique snap IDs
defaults:
  AZGf0KNnh8aqdkbGATNuRuxnt1GNRKkV: # edgexfoundry
    # Enable app options
    app-options: true
    # Set the admin user's public key
    apps.secrets-config.proxy.admin.public-key: |
      -----BEGIN PUBLIC KEY-----
      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE5slZTyp5Zfxoos7TljHgPSbGm3As
      NZGr6EEet300xbC4VUVGcQBSEsSZmGMTxaCMlzvKt1dwUNxBFDAemWXSyg==
      -----END PUBLIC KEY-----

  AmKuVTOfsN0uEKsyJG34M8CaMfnIqxc0: # edgex-device-virtual
    # automatically start the service
    autostart: true
    # Enable app options
    app-options: true # not necessary because this service has it by default
    # Override the startup message (because we can)
    # The same syntax can be used to override most of the server configurations
    apps.device-virtual.config.service-startupmsg: "Example override from gadget!"
```

!!! tip "Snap ID"
    Query the unique store ID of a snap, for example the `edgexfoundry` snap:
    ```
    $ snap info edgexfoundry | grep snap-id
    snap-id: AZGf0KNnh8aqdkbGATNuRuxnt1GNRKkV
    ```

The public key is taken from `public.pem` generated in the previous section.

Refer to the following for details:

- [Managing services](../../getting-started/Ch-GettingStartedSnapUsers/#managing-services)
- [Adding API Gateway Users](../../getting-started/Ch-GettingStartedSnapUsers/#adding-api-gateway-users)




Build:
```bash
$ snapcraft
...
Snapped pc_20-0.4_amd64.snap
```

!!! note
    You need to rebuild the snap every time you change the gadget.yaml file.

### Build the image and boot
Perform the following:

1. Use ubuntu-image tool again to build a new image. Use the same instructions as [before](#build-the-ubuntu-core-image) to build.
2. [Flash the image](#flash-the-image) or [run it in an emulator](#run-in-an-emulator).

This time, as set in the gadget defaults, Device Virtual is started by default and we have a user to securely interact with the API Gateway.

!!! info
    SSH to the machine and verify that Device Virtual is enabled (to start on boot) and active (running):
    ```
    $ snap services edgex-device-virtual
    Service                              Startup  Current  Notes
    edgex-device-virtual.device-virtual  enabled  active   -
    ```

    Verify that the public key is there as a snap option:
    ```
    $ snap get edgexfoundry apps.secrets-config -d
    {
      "apps.secrets-config": {
        "proxy": {
          "admin": {
            "public-key": "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE5slZTyp5Zfxoos7TljHgPSbGm3As\nNZGr6EEet300xbC4VUVGcQBSEsSZmGMTxaCMlzvKt1dwUNxBFDAemWXSyg==\n-----END PUBLIC KEY-----\n"
          }
        }
      }
    }
    ```

    Verify that Device Virtual has the startup message set from the gadget:
    ```
    $ snap logs -n=all edgex-device-virtual | grep "gadget"
    2022-08-19T13:51:28Z edgex-device-virtual.device-virtual[4660]: level=INFO ts=2022-08-19T13:51:28.868688382Z app=device-virtual source=variables.go:352 msg="Variables override of 'Service.StartupMsg' by environment variable: SERVICE_STARTUPMSG=Example override from gadget!"
    ```

### Query data securely from another host

Let's query API Gateway from outside of the machine. The hostname is still `localhost` because this guide runs the image in an emulator on the same machine.
```
$ curl --insecure --silent --show-err https://localhost:8443/core-data/api/v2/reading/all?limit=2 -H "Authorization: Bearer $(cat admin-jwt.txt)" | jq
{
  "apiVersion": "v2",
  "statusCode": 200,
  "totalCount": 939,
  "readings": [
    {
      "id": "eb1faad8-d93d-4793-b2e7-19d0cf13c183",
      "origin": 1660314781398850300,
      "deviceName": "Random-Boolean-Device",
      "resourceName": "Bool",
      "profileName": "Random-Boolean-Device",
      "valueType": "Bool",
      "value": "true"
    },
    {
      "id": "2c1ea95a-b5b0-4051-a5b6-24d98f40a5c3",
      "origin": 1660314776365793500,
      "deviceName": "Random-Integer-Device",
      "resourceName": "Int64",
      "profileName": "Random-Integer-Device",
      "valueType": "Int64",
      "value": "-8755202057804760537"
    }
  ]
}
```

The response is similar to if query was sent directly to Core Data (http://localhost:59880/api/v2/reading/all?limit=2), except that it was done over TLS and with authentication. We didn't need to bind the Core Data's server to other interfaces or expose its port to outside.

!!! tip
    EdgeX's API Gateway internally generated a self-signed TLS certificate. The system doesn't trust that certificate and that's why we set the `--insecure` flag for curl.

    Refer [here](../../getting-started/Ch-GettingStartedSnapUsers/#changing-tls-certificates) to learn how you can replace the certificate with one that your system trusts.

## C. Replace default service configurations
!!! todo
    Create a config provider to replace Device Virtual configuration (server, device, profile)



## References
- [Getting Started using Snaps](https://docs.edgexfoundry.org/2.2/getting-started/Ch-GettingStartedSnapUsers)
- [EdgeX Core Data](https://docs.edgexfoundry.org/2.2/microservices/core/data/Ch-CoreData/)
- [Gadget snaps](https://snapcraft.io/docs/gadget-snap)
- [Ubuntu Core]
- [Testing Ubuntu Core with QEMU](https://ubuntu.com/core/docs/testing-with-qemu)
- [Ubuntu Core - Image building](https://ubuntu.com/core/docs/image-building#heading--testing)
- [Ubuntu Core - Custom images](https://ubuntu.com/core/docs/custom-images)
- [Ubuntu Core - Building a gadget snap](https://ubuntu.com/core/docs/gadget-building)


[Ubuntu Core]: https://ubuntu.com/core
