# Command Line Interface (CLI)

## What is EdgeX CLI?

EdgeX CLI is a command-line interface tool for developers, used for interacting with EdgeX Foundry microservices. 


## Installing EdgeX CLI

The client can be installed using a [snap](https://github.com/edgexfoundry/edgex-cli/tree/main/snap)

```
sudo snap install edgex-cli
```

You can also download the appropriate binary for your operating system from [GitHub](https://github.com/edgexfoundry/edgex-cli/releases).

If you want to build EdgeX CLI from source, do the following:

```
git clone http://github.com/edgexfoundry/edgex-cli.git
cd edgex-cli
make tidy
make build
./bin/edgex-cli
```

For more information, see the [EdgeX CLI README](https://github.com/edgexfoundry/edgex-cli/blob/master/README.md).

## Features

EdgeX CLI provides access to most of the core and support APIs. The commands map directly to the REST API structure.

Running `edgex-cli` with no arguments shows a list of the available commands and information for each of them, including the name of the service implementing the command. Use the `-h` or `--help` flag to get more information about each command.


```
$ edgex-cli
EdgeX-CLI

Usage:
  edgex-cli [command]

Available Commands:
  command          Read, write and list commands [Core Command]
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
```



## Commands implemented by all microservices

The `ping`, `config`, `metrics` and `version` work with more than one microservice. 

By default these commands will return values from all core and support services:

```
$ edgex-cli metrics
Service               CpuBusyAvg MemAlloc MemFrees MemLiveObjects MemMallocs MemSys   MemTotalAlloc
core-metadata         13         1878936  38262    9445           47707      75318280 5967608
core-data             13         1716256  40200    8997           49197      75580424 5949504
core-command          13         1737288  31367    8582           39949      75318280 5380584
support-scheduler     10         2612296  20754    20224          40978      74728456 4146800
support-notifications 10         2714480  21199    20678          41877      74728456 4258640
```

To only return information for one service, specify the service to use:

```
  -c, --command         use core-command service endpoint
  -d, --data            use core-data service endpoint
  -m, --metadata        use core-metadata service endpoint
  -n, --notifications   use support-notifications service endpoint
  -s, --scheduler       use support-scheduler service endpoint
```

Example:
```
$ edgex-cli metrics -d
Service   CpuBusyAvg MemAlloc MemFrees MemLiveObjects MemMallocs MemSys   MemTotalAlloc
core-data 14         1917712  870037   12258          882295     75580424 64148880

$ edgex-cli metrics -c
Service      CpuBusyAvg MemAlloc MemFrees MemLiveObjects MemMallocs MemSys   MemTotalAlloc
core-command 13         1618424  90890    8328           99218      75580424 22779448

$ edgex-cli metrics --metadata
Service       CpuBusyAvg MemAlloc MemFrees MemLiveObjects MemMallocs MemSys   MemTotalAlloc
core-metadata 12         1704256  39606    8870           48476      75318280 6139912
```

The `-j/--json` flag can be used with most of `edgex-go` commands to return the JSON output:

```
$ edgex-cli metrics --metadata --json
{"apiVersion":"v2","metrics":{"memAlloc":1974544,"memFrees":39625,"memLiveObjects":9780,"memMallocs":49405,"memSys":75318280,"memTotalAlloc":6410200,"cpuBusyAvg":13}}
```

This could then be formatted and filtered using `jq`:

```
$ edgex-cli metrics --metadata --json | jq '.'
{
  "apiVersion": "v2",
  "metrics": {
    "memAlloc": 1684176,
    "memFrees": 41142,
    "memLiveObjects": 8679,
    "memMallocs": 49821,
    "memSys": 75318280,
    "memTotalAlloc": 6530824,
    "cpuBusyAvg": 12
  }
}
```
 
## Core-command service

### `edgex-cli command list` 
Return a list of all supported device commands, optionally filtered by device name. 

Example:

```
$ edgex-cli command list
Name                    Device Name                    Profile Name                   Methods   URL
BoolArray               Random-Boolean-Device          Random-Boolean-Device          Get, Put  http://localhost:59882/api/v2/device/name/Random-Boolean-Device/BoolArray
WriteBoolValue          Random-Boolean-Device          Random-Boolean-Device          Put       http://localhost:59882/api/v2/device/name/Random-Boolean-Device/WriteBoolValue
WriteBoolArrayValue     Random-Boolean-Device          Random-Boolean-Device          Put       http://localhost:59882/api/v2/device/name/Random-Boolean-Device/WriteBoolArrayValue
```

### `edgex-cli command read` 
Issue a read command to the specified device. 

Example:

```
$ edgex-cli command read -c Int16 -d Random-Integer-Device -j | jq '.'
{
  "apiVersion": "v2",
  "statusCode": 200,
  "event": {
    "apiVersion": "v2",
    "id": "e19f417e-3130-485f-8212-64b593b899f9",
    "deviceName": "Random-Integer-Device",
    "profileName": "Random-Integer-Device",
    "sourceName": "Int16",
    "origin": 1641484109458647300,
    "readings": [
      {
        "id": "dc1f212d-148a-457c-ab13-48aa0fa58dd1",
        "origin": 1641484109458647300,
        "deviceName": "Random-Integer-Device",
        "resourceName": "Int16",
        "profileName": "Random-Integer-Device",
        "valueType": "Int16",
        "binaryValue": null,
        "mediaType": "",
        "value": "587"
      }
    ]
  }
}
```

### `edgex-cli command write` 
Issue a write command to the specified device. 

Example using in-line request body:

```
$ edgex-cli command write -d Random-Integer-Device -c Int8 -b "{\"Int8\": \"99\"}"
$ edgex-cli command read -d Random-Integer-Device -c Int8
apiVersion: v2,statusCode: 200
Command Name  Device Name            Profile Name           Value Type  Value
Int8          Random-Integer-Device  Random-Integer-Device  Int8        99
```

Example using a file containing the request:

```
$ echo "{ \"Int8\":\"88\" }" > file.txt

$ edgex-cli command write -d Random-Integer-Device -c Int8 -f file.txt
apiVersion: v2,statusCode: 200

$ edgex-cli command read -d Random-Integer-Device -c Int8
Command Name  Device Name            Profile Name           Value Type  Value
Int8          Random-Integer-Device  Random-Integer-Device  Int8        88
```

## Core-metadata service

### `edgex-cli deviceservice list` 
List device services

```
$ edgex-cli deviceservice list
```

### `edgex-cli deviceservice add` 
Add a device service

```
$ edgex-cli deviceservice add -n TestDeviceService -b "http://localhost:51234"
```

### `edgex-cli deviceservice name` 
Shows information about a device service. Most `edgex-cli` commands support the `-v/--verbose` and `-j/--json` flags:

```
$ edgex-cli deviceservice name -n TestDeviceService
Name               BaseAddress             Description
TestDeviceService  http://localhost:51234  

$ edgex-cli deviceservice name -n TestDeviceService -v
Name               BaseAddress             Description  AdminState  Id                                    Labels  LastConnected  LastReported  Modified
TestDeviceService  http://localhost:51234               UNLOCKED    7f29ad45-65dc-46c0-a928-00147d328032  []      0              0             10 Jan 22 17:26 GMT

$ edgex-cli deviceservice name -n TestDeviceService  -j | jq '.'
{
  "apiVersion": "v2",
  "statusCode": 200,
  "service": {
    "created": 1641835585465,
    "modified": 1641835585465,
    "id": "7f29ad45-65dc-46c0-a928-00147d328032",
    "name": "TestDeviceService",
    "baseAddress": "http://localhost:51234",
    "adminState": "UNLOCKED"
  }
}
```

### `edgex-cli deviceservice rm` 
Remove a device service

```
$ edgex-cli deviceservice rm -n TestDeviceService
```

### `edgex-cli deviceservice update` 
Update the device service, getting the ID using jq and confirm that the labels were added

```
$ edgex-cli deviceservice add -n TestDeviceService -b "http://localhost:51234"
{{{v2} c2600ad2-6489-4c3f-9207-5bdffdb8d68f  201} 844473b1-551d-4545-9143-28cfdf68a539}

$ ID=`edgex-cli deviceservice name -n TestDeviceService -j | jq -r '.service.id'`
$ edgex-cli deviceservice update -n TestDeviceService -i $ID --labels "label1,label2"
{{v2} 9f4a4758-48a1-43ce-a232-828f442c2e34  200}

$ edgex-cli deviceservice name -n TestDeviceService -v
Name               BaseAddress             Description  AdminState  Id                                    Labels           LastConnected  LastReported  Modified
TestDeviceService  http://localhost:51234               UNLOCKED    844473b1-551d-4545-9143-28cfdf68a539  [label1 label2]  0              0             28 Jan 22 12:00 GMT
```


### `edgex-cli deviceprofile list` 
List device profiles

```
$ edgex-cli deviceprofile list
```

### `edgex-cli deviceprofile add` 
Add a device profile

```
$ edgex-cli deviceprofile add -n TestProfile -r "[{\"name\": \"SwitchButton\",\"description\": \"Switch On/Off.\",\"properties\": {\"valueType\": \"String\",\"readWrite\": \"RW\",\"defaultValue\": \"On\",\"units\": \"On/Off\" } }]"  -c "[{\"name\": \"Switch\",\"readWrite\": \"RW\",\"resourceOperations\": [{\"deviceResource\": \"SwitchButton\",\"DefaultValue\": \"false\" }]} ]"
{{{v2} 65d083cc-b876-4744-af65-59a00c63fc25  201} 4c0af6b0-4e83-4f3c-a574-dcea5f42d3f0}

```

### `edgex-cli deviceprofile name` 
Show information about a specifed device profile

```
$ edgex-cli deviceprofile name -n TestProfile
Name         Description  Manufacturer  Model  Name
TestProfile                                    TestProfile

```

### `edgex-cli deviceprofile rm` 
Remove a device profile

```
$ edgex-cli deviceprofile rm -n TestProfile
```

### `edgex-cli device list` 
List current devices

```
$ edgex-cli device list
Name                           Description                ServiceName        ProfileName                    Labels                    AutoEvents
Random-Float-Device            Example of Device Virtual  device-virtual     Random-Float-Device            [device-virtual-example]  [{30s false Float32} {30s false Float64}]
Random-UnsignedInteger-Device  Example of Device Virtual  device-virtual     Random-UnsignedInteger-Device  [device-virtual-example]  [{20s false Uint8} {20s false Uint16} {20s false Uint32} {20s false Uint64}]
Random-Boolean-Device          Example of Device Virtual  device-virtual     Random-Boolean-Device          [device-virtual-example]  [{10s false Bool}]
TestDevice                                                TestDeviceService  TestProfile                    []                        []
Random-Binary-Device           Example of Device Virtual  device-virtual     Random-Binary-Device           [device-virtual-example]  []
Random-Integer-Device          Example of Device Virtual  device-virtual     Random-Integer-Device          [device-virtual-example]  [{15s false Int8} {15s false Int16} {15s false Int32} {15s false Int64}]
```

### `edgex-cli device add` 
Add a new device. This needs a device service and device profile to be created first

```
$ edgex-cli device add -n TestDevice -p TestProfile -s TestDeviceService --protocols "{\"modbus-tcp\":{\"Address\": \"localhost\",\"Port\": \"1234\" }}"
{{{v2} e912aa16-af4a-491d-993b-b0aeb8cd9c67  201} ae0e8b95-52fc-4778-892d-ae7e1127ed39}

```

### `edgex-cli device name` 
Show information about a specified named device 

```
$ edgex-cli device name -n TestDevice
Name        Description  ServiceName        ProfileName  Labels  AutoEvents
TestDevice               TestDeviceService  TestProfile  []      []
```

### `edgex-cli device rm` 
Remove a device

```
edgex-cli device rm -n TestDevice
edgex-cli device list
edgex-cli device add -n TestDevice -p TestProfile -s TestDeviceService --protocols "{\"modbus-tcp\":{\"Address\": \"localhost\",\"Port\": \"1234\" }}"
edgex-cli device list
```

### `edgex-cli device update` 
Update a device 

This example gets the ID of a device, updates it using that ID and then displays device information to confirm that the labels were added

```
$ ID=`edgex-cli device name -n TestDevice -j | jq -r '.device.id'`

$ edgex-cli device update -n TestDevice -i $ID --labels "label1,label2"
{{v2} 73427492-1158-45b2-9a7c-491a474cecce  200}

$ edgex-cli device name -n TestDevice
Name        Description  ServiceName        ProfileName  Labels           AutoEvents
TestDevice               TestDeviceService  TestProfile  [label1 label2]  []

```


### `edgex-cli provisionwatcher add` 
Add a new provision watcher

```
$ edgex-cli provisionwatcher add -n TestWatcher --identifiers "{\"address\":\"localhost\",\"port\":\"1234\"}" -p TestProfile -s TestDeviceService
{{{v2} 3f05f6e0-9d9b-4d96-96df-f394cc2ad6f4  201} ee76f4d8-46d4-454c-a4da-8ad9e06d8d7e}

```


### `edgex-cli provisionwatcher list` 
List provision watchers

```
$ edgex-cli provisionwatcher list
Name         ServiceName        ProfileName  Labels  Identifiers
TestWatcher  TestDeviceService  TestProfile  []      map[address:localhost port:1234]
```

### `edgex-cli provisionwatcher name` 
Show information about a specific named provision watcher 

```
$ edgex-cli provisionwatcher name -n TestWatcher
Name         ServiceName        ProfileName  Labels  Identifiers
TestWatcher  TestDeviceService  TestProfile  []      map[address:localhost port:1234]
```

### `edgex-cli provisionwatcher rm` 
Remove a provision watcher

```
$ edgex-cli provisionwatcher rm -n TestWatcher
$ edgex-cli provisionwatcher list
No provision watchers available
```

### `edgex-cli provisionwatcher update` 
Update a provision watcher 

This example gets the ID of a provision watcher, updates it using that ID and then displays  information about it to confirm that the labels were added

```
$ edgex-cli provisionwatcher add -n TestWatcher2 --identifiers "{\"address\":\"localhost\",\"port\":\"1234\"}" -p TestProfile -s TestDeviceService
{{{v2} fb7b8bcf-8f58-477b-929e-8dac53cddc81  201} 7aadb7df-1ff1-4b3b-8986-b97e0ef53116}

$ ID=`edgex-cli provisionwatcher name -n TestWatcher2 -j | jq -r '.provisionWatcher.id'`

$ edgex-cli provisionwatcher update -n TestWatcher2 -i $ID --labels "label1,label2"
{{v2} af1e70bf-4705-47f4-9046-c7b789799405  200}

$ edgex-cli provisionwatcher name -n TestWatcher2
Name          ServiceName        ProfileName  Labels           Identifiers
TestWatcher2  TestDeviceService  TestProfile  [label1 label2]  map[address:localhost port:1234]

```


## Core-data service

### `edgex-cli event add`
Create an event with a specified number of random readings

```
$ edgex-cli event add -d Random-Integer-Device -p Random-Integer-Device -r 1 -s Int16 -t int16
Added event 75f06078-e8da-4671-8938-ab12ebb2c244

$ edgex-cli event list -v
Origin               Device                 Profile                Source  Id                                    Versionable  Readings
10 Jan 22 15:38 GMT  Random-Integer-Device  Random-Integer-Device  Int16   75f06078-e8da-4671-8938-ab12ebb2c244  {v2}         [{974a70fe-71ef-4a47-a008-c89f0e4e3bb6 1641829092129391876 Random-Integer-Device Int16 Random-Integer-Device Int16 {[] } {13342}}]
```

### `edgex-cli event count`
Count the number of events in core data, optionally filtering by device name

```
$ edgex-cli event count -d Random-Integer-Device
Total Random-Integer-Device events: 54
```


### `edgex-cli event list`
List all events, optionally specifying a limit and offset

```
$ edgex-cli event list
```

To see two readings only, skipping the first 100 readings:

```
$ edgex-cli reading list --limit 2 --offset 100
Origin               Device                 ProfileName            Value                ValueType
28 Jan 22 12:55 GMT  Random-Integer-Device  Random-Integer-Device  22502                Int16
28 Jan 22 12:55 GMT  Random-Integer-Device  Random-Integer-Device  1878517239016780388  Int64
```

### `edgex-cli event rm`
Remove events, specifying either device name or maximum event age in milliseconds
- `edgex-cli event rm --device {devicename}` removes all events for the specified device
- `edgex-cli event rm --age {ms}` removes all events generated in the last {ms} milliseconds

```
$ edgex-cli event rm -a 30000
$ edgex-cli event count
Total events: 0
```

### `edgex-cli reading count`
Count the number of readings in core data, optionally filtering by device name

```
$ edgex-cli reading count
Total readings: 235
```

### `edgex-cli reading list`
List all readings, optionally specifying a limit and offset

```
$ edgex-cli reading list
```


## Support-scheduler service

### `edgex-cli interval add`
Add an interval

```
$ edgex-cli interval add -n "hourly" -i "1h"
{{{v2} c7c51f21-dab5-4307-a4c9-bc5d5f2194d9  201} 98a6d5f6-f4c4-4ec5-a00c-7fe24b9c9a18}
```

### `edgex-cli interval name`
Return an interval by name

```
$ edgex-cli interval name -n "hourly"
Name    Interval  Start  End
hourly  1h               
```

### `edgex-cli interval list`
List all intervals

```
$ edgex-cli interval list  -j | jq '.'
{
  "apiVersion": "v2",
  "statusCode": 200,
  "intervals": [
    {
      "created": 1641830955058,
      "modified": 1641830955058,
      "id": "98a6d5f6-f4c4-4ec5-a00c-7fe24b9c9a18",
      "name": "hourly",
      "interval": "1h"
    },
    {
      "created": 1641830953884,
      "modified": 1641830953884,
      "id": "507a2a9a-82eb-41ea-afa8-79a9b0033665",
      "name": "midnight",
      "start": "20180101T000000",
      "interval": "24h"
    }
  ]
}
```


### `edgex-cli interval update`
Update an interval, specifying either ID or name

```
$ edgex-cli interval update -n "hourly" -i "1m"
{{v2} 08239cc4-d4d7-4ea2-9915-d91b9557c742  200}
$ edgex-cli interval name -n "hourly" -v
Id                                    Name    Interval  Start  End
98a6d5f6-f4c4-4ec5-a00c-7fe24b9c9a18  hourly  1m  
```


### `edgex-cli interval rm`
Delete a named interval and associated interval actions

```
$ edgex-cli interval rm  -n "hourly" 
```

### `edgex-cli intervalaction add`
Add an interval action
 
```
$ edgex-cli intervalaction add -n "name01" -i "midnight" -a "{\"type\": \"REST\", \"host\": \"192.168.0.102\", \"port\": 8080, \"httpMethod\": \"GET\"}"

```

### `edgex-cli intervalaction name`
Return an interval action by name

```
$ edgex-cli intervalaction name -n "name01"
Name    Interval  Address                                                      Content  ContentType
name01  midnight  {REST 192.168.0.102 8080 { GET} {  0 0 false false 0} {[]}}  
``` 

### `edgex-cli intervalaction list`
List all interval actions

```
$ edgex-cli intervalaction list
Name               Interval  Address                                                                                       Content  ContentType
name01             midnight  {REST 192.168.0.102 8080 { GET} {  0 0 false false 0} {[]}}                                            
scrub-aged-events  midnight  {REST localhost 59880 {/api/v2/event/age/604800000000000 DELETE} {  0 0 false false 0} {[]}}   
```

### `edgex-cli intervalaction update`
Update an interval action, specifying either ID or name

```
$ edgex-cli intervalaction update -n "name01" --admin-state "LOCKED"
{{v2} afc7b08c-5dc6-4923-9786-30bfebc8a8b6  200}
$ edgex-cli intervalaction name -n "name01" -j | jq '.action.adminState'
"LOCKED"
```

### `edgex-cli intervalaction rm`
Delete an interval action by name

```
$ edgex-cli intervalaction rm  -n "name01" 
```


## Support-notifications service

### `edgex-cli notification add`
Add a notification to be sent

```
$ edgex-cli notification add -s "sender01" -c "content" --category "category04" --labels "l3"
{{{v2} 13938e01-a560-47d8-bb50-060effdbe490  201} 6a1138c2-b58e-4696-afa7-2074e95165eb}

```

### `edgex-cli notification list`
List notifications associated with a given label, category or time range

```
$ edgex-cli notification list -c "category04"
Category    Content  Description  Labels  Sender    Severity  Status
category04  content               [l3]    sender01  NORMAL    PROCESSED

$ edgex-cli notification list --start "01 jan 20 00:00 GMT" --end "01 dec 24 00:00 GMT"
Category    Content  Description  Labels  Sender    Severity  Status
category04  content               [l3]    sender01  NORMAL    PROCESSED
```

### `edgex-cli notification rm`
Delete a notification and all of its associated transmissions

```
$ ID=`edgex-cli notification list -c "category04" -v -j | jq -r '.notifications[0].id'`
$ echo $ID
6a1138c2-b58e-4696-afa7-2074e95165eb
$ edgex-cli notification rm -i $ID
$ edgex-cli notification list -c "category04"
No notifications available
```


### `edgex-cli notification cleanup`
Delete all notifications and corresponding transmissions

```
$ edgex-cli notification cleanup
$ edgex-cli notification list --start "01 jan 20 00:00 GMT" --end "01 dec 24 00:00 GMT"
No notifications available
```

### `edgex-cli subscription add`
Add a new subscription

```
$ edgex-cli subscription add -n "name01" --receiver "receiver01" -c "[{\"type\": \"REST\", \"host\": \"localhost\", \"port\": 7770, \"httpMethod\": \"POST\"}]" --labels "l1,l2,l3"
{{{v2} 2bbfdac0-d2e1-4f08-8344-392b8e8ddc5e  201} 1ec08af0-5767-4505-82f7-581fada6006b}

$ edgex-cli subscription add -n "name02" --receiver "receiver01" -c "[{\"type\": \"EMAIL\", \"recipients\": [\"123@gmail.com\"]}]" --labels "l1,l2,l3"
{{{v2} f6b417ca-740c-4dee-bc1e-c721c0de4051  201} 156fc2b9-de60-423b-9bff-5312d8452c48}
```

### `edgex-cli subscription name`
Return a subscription by its unique name

```
$ edgex-cli subscription name -n "name01"
Name    Description  Channels                                                    Receiver    Categories  Labels
name01               [{REST localhost 7770 { POST} {  0 0 false false 0} {[]}}]  receiver01  []          [l1 l2 l3]
```

### `edgex-cli subscription list`
List all subscriptions, optionally filtered by a given category, label or receiver

```
$ edgex-cli subscription list --label "l1"
Name    Description  Channels                                                    Receiver    Categories  Labels
name02               [{EMAIL  0 { } {  0 0 false false 0} {[123@gmail.com]}}]    receiver01  []          [l1 l2 l3]
name01               [{REST localhost 7770 { POST} {  0 0 false false 0} {[]}}]  receiver01  []          [l1 l2 l3]
```

### `edgex-cli subscription rm`
Delete the named subscription

```
$ edgex-cli subscription rm -n "name01" 
```


### `edgex-cli transmission list`
To create a transmission, first create a subscription and notifications:
```
$ edgex-cli subscription add -n "Test-Subscription" --description "Test data for subscription" --categories "health-check" --labels "simple" --receiver "tafuser" --resend-limit 0 --admin-state "UNLOCKED" -c "[{\"type\": \"REST\", \"host\": \"localhost\", \"port\": 7770, \"httpMethod\": \"POST\"}]"
{{{v2} f281ec1a-876e-4a29-a14d-195b66d0506c  201} 3b489d23-b0c7-4791-b839-d9a578ebccb9}

$ edgex-cli notification add -d "Test data for notification 1" --category "health-check" --labels "simple" --content-type "string" --content "This is a test notification" --sender "taf-admin"
{{{v2} 8df79c7c-03fb-4626-b6e8-bf2d616fa327  201} 0be98b91-daf9-46e2-bcca-39f009d93866}


$ edgex-cli notification add -d "Test data for notification 2" --category "health-check" --labels "simple" --content-type "string" --content "This is a test notification" --sender "taf-admin"
{{{v2} ec0b2444-c8b0-45d0-bbd6-847dd007c2fd  201} a7c65d7d-0f9c-47e1-82c2-c8098c47c016}

$ edgex-cli notification add -d "Test data for notification 3" --category "health-check" --labels "simple" --content-type "string" --content "This is a test notification" --sender "taf-admin"
{{{v2} 45af7f94-c99e-4fb1-a632-fab5ff475be4  201} f982fc97-f53f-4154-bfce-3ef8666c3911}

```

Then list the transmissions:
```
$ edgex-cli transmission list
SubscriptionName   ResendCount  Status
Test-Subscription  0            FAILED
Test-Subscription  0            FAILED
Test-Subscription  0            FAILED

```

### `edgex-cli transmission id`
Return a transmission by ID

```
$ ID=`edgex-cli transmission list -j | jq -r '.transmissions[0].id'`
$ edgex-cli transmission id -i $ID
SubscriptionName   ResendCount  Status
Test-Subscription  0            FAILED

```

### `edgex-cli transmission rm`
Delete processed transmissions older than the specificed age (in milliseconds)

```
$ edgex-cli transmission rm -a 100
```
 