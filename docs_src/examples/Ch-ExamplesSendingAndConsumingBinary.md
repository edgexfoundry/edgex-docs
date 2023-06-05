# Sending and Consuming Binary Data From EdgeX Device Services

EdgeX - Ireland Release

## Overview

In this example, we will demonstrate how to send EdgeX Events and
Readings that contain arbitrary binary data.

## DeviceService Implementation

### Device Profile

To indicate that a deviceResource represents a Binary type, the
following format is used:

``` yaml
deviceResources:
  -
    name: "camera_snapshot"
    isHidden: false
    description: "snapshot from camera"
    properties:
        valueType: "Binary"
        readWrite: "R"
        mediaType: "image/jpeg"
deviceCommands:
  -
    name: "OnvifSnapshot"
    isHidden: false
    readWrite: "R"
    resourceOperations:
      - { deviceResource: "camera_snapshot" }
```

### Device Service

Here is a snippet from a hypothetical Device Service's
`HandleReadCommands()` method that produces an event that
represents a JPEG image captured from a camera:

``` golang
if req.DeviceResourceName == "camera_snapshot" {
  data, err := cameraClient.GetSnapshot() // returns ([]byte, error)
  check(err)

  cv, err := sdkModels.NewCommandValue(reqs[i].DeviceResourceName, common.ValueTypeBinary, data)
  check(err)

  responses[i] = cv
}
```

## Calling Device Service Command

Querying core-metadata for the Device's Commands and DeviceName provides
the following as the URL to request a reading from the snapshot command:
<http://localhost:59990/api/v3/device/name/camera-device/OnvifSnapshot>

Unlike with non-binary Events, making a request to this URL will return
an event in CBOR representation. CBOR is a representation of binary data
loosely based off of the JSON data model. This Event will not be
human-readable.

### Parsing CBOR Encoded Events

To access the data enclosed in these Events and Readings, they will
first need to be decoded from CBOR. The following is a simple Go program
that reads in the CBOR response from a file containing the response from
the previous HTTP request. The Go library recommended for parsing these
events can be found at <https://github.com/fxamacker/cbor/>

``` golang
package main

import (
	"io/ioutil"

	"github.com/edgexfoundry/go-mod-core-contracts/v2/dtos/requests"
	"github.com/fxamacker/cbor/v2"
)

func check(e error) {
  if e != nil {
      panic(e)
  }
}

func main() {
    // Read in our cbor data
    fileBytes, err := ioutil.ReadFile("/Users/johndoe/Desktop/image.cbor")
    check(err)

    // Decode into an EdgeX Event
    eventRequest := &requests.AddEventRequest{}
    err = cbor.Unmarshal(fileBytes, eventRequest)
    check(err)

    // Grab binary data and write to a file
    imgBytes := eventRequest.Event.Readings[0].BinaryValue
    ioutil.WriteFile("/Users/johndoe/Desktop/image.jpeg", imgBytes, 0644)
}
```

In the code above, the CBOR data is read into a byte array , an EdgeX Event struct is created, 
and `cbor.Unmarshal` parses the CBOR-encoded data and stores the result in the Event struct. 
Finally, the binary payload is written to a file from the `BinaryValue` field of
the Reading.

This method would work as well for decoding Events off the EdgeX message bus.

## Encoding Arbitrary Structures in Events

The Device SDK's `NewCommandValue()` function above only
accepts a byte slice as binary data. Any arbitrary Go structure can be
encoded in a binary reading by first encoding the structure into a byte
slice using CBOR. The following illustrates this method:

``` golang
// DeviceService HandleReadCommands() code:
foo := struct {
  X int
  Y int
  Z int
  Bar string
} {
  X: 7,
  Y: 3,
  Z: 100,
  Bar: "Hello world!",
}

data, err := cbor.Marshal(&foo)
check(err)

cv, err := sdkModels.NewCommandValue(reqs[i].DeviceResourceName, common.ValueTypeBinary, data)
responses[i] = cv
```

This code takes the anonymous struct with fields X, Y, Z, and Bar (of
different types) and serializes it into a byte slice using the same
`cbor` library, and passing the output to
`NewCommandValue()`.

When consuming these events, another level of decoding will need to take
place to get the structure out of the binary payload.

``` golang
func main() {
    // Read in our cbor data
    fileBytes, err := ioutil.ReadFile("/Users/johndoe/Desktop/foo.cbor")
    check(err)

    // Decode into an EdgeX Event
    eventRequest := &requests.AddEventRequest{}
    err = cbor.Unmarshal(fileBytes, eventRequest)
    check(err)

    // Decode into arbitrary type
    foo := struct {
        X   int
        Y   int
        Z   int
        Bar string
    }{}

    err = cbor.Unmarshal(eventRequest.Event.Readings[0].BinaryValue, &foo)
    check(err)
    fmt.Println(foo)
}
```

This code takes a command response in the same format as the previous
example, but uses the `cbor` library to decode the CBOR
data inside the EdgeX Reading's `BinaryValue` field.

Using this approach, an Event can be sent containing data containing an
arbitrary, flexible structure. Use cases could be a Reading containing
multiple images, a variable length list of integer read-outs, etc.
