# Sending and Consuming Binary Data From EdgeX Device Services

EdgeX - Fuji Release

## Overview

In this example, we will demonstrate how to send EdgeX Events and
Readings that contain arbitrary binary data.

## DeviceService Implementation

### Device Profile

To indicate that a deviceResource represents a Binary type, the
following format is used:

``` yaml
- name: "camera_snapshot"
  description: "snapshot from camera"
  properties:
  value:
      { type: "Binary", readWrite: "R" }
  units:
      { type: "Binary", readWrite: "R", defaultValue: "CameraSnapshot" }
```

### Device Service

Here is a snippet from a hypothetical Device Service's
`HandleReadCommands()` method that produces an event that
represents a JPEG image captured from a camera:

``` golang
if req.DeviceResourceName == "camera_snapshot" {
  data, err := cameraClient.GetSnapshot() // returns ([]byte, error)
  check(err)

  cv, err := sdkModel.NewBinaryValue(reqs[i].DeviceResourceName, 0, data)
  check(err)

  responses[i] = cv
}
```

## Calling Device Service Command

Querying core-metadata for the Device's Commands and DeviceID provides
the following as the URL to request a reading from the snapshot command:
<http://localhost:49990/api/v1/device/3469a658-c3b8-46f1-9098-7d19973af402/OnvifSnapshot>

Unlike with non-binary Events, making a request to this URL will return
an event in CBOR representation. CBOR is a representation of binary data
loosely based off of the JSON data model. This Event will not be
human-readable.

### Parsing CBOR Encoded Events

To access the data enclosed in these Events and Readings, they will
first need to be decoded from CBOR. The following is a simple Go program
that reads in the CBOR response from a file containing the response from
the previous HTTP request. The Go library recommended for parsing these
events can be found at <https://github.com/ugorji/go>

``` golang
package main

import (
  “io/ioutil”

  contracts “github.com/edgexfoundry/go-mod-core-contracts/models”
  “github.com/ugorji/go/codec”
)

func check(e error) {
  if e != nil {
      panic(e)
  }
}

func main() {
  // Read in our cbor data
  fileBytes, err := ioutil.ReadFile(“/Users/johndoe/Desktop/image.cbor”)
  check(err)

  // Create a cbor decoder from the cbor bytes and a cbor code handle
  var h codec.Handle = new(codec.CborHandle)
  var dec *codec.Decoder = codec.NewDecoderBytes(fileBytes, h)

  // Decode into an EdgeX Event
  var event contracts.Event
  err = dec.Decode(&event)
  check(err)

  // Grab binary data and write to a file
  imgBytes := event.Readings[0].BinaryValue
  ioutil.WriteFile(“/Users/johndoe/Desktop/image.jpeg”, imgBytes, 0644)
}
```

In the code above, the CBOR data is read into a buffer, a
`code.Decoder` is created to decode the CBOR data, an EdgeX
Event struct is created, and a pointer is passed into the decoder's
`Decode()` method to be filled in. Finally, the binary
payload is written to a file from the `BinaryValue` field of
the Reading.

This method would work as well for decoding Events off the EdgeX message
bus.

### Encoding Arbitrary Structures in Events

The Device SDK's `NewBinaryValue()` function above only
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

buffer := new(bytes.Buffer)
ch := new(codec.CborHandle)
encoder := codec.NewEncoder(buffer, ch)

err = encoder.Encode(&foo)
check(err)

cv, err := sdkModel.NewBinaryValue(reqs[i].DeviceResourceName, 0, buffer.Bytes())
responses[i] = cv
```

This code takes the anonymous struct with fields X, Y, Z, and Bar (of
different types) and serializes it into a byte slice using the same
`codec` library, and passing the output to
`NewBinaryValue()`.

When consuming these events, another level of decoding will need to take
place to get the structure out of the binary payload.

``` golang
func main() {
  // Read in our cbor data
  fileBytes, err := ioutil.ReadFile(“/Users/johndoe/Desktop/image.cbor”)
  check(err)

  // Create a cbor decoder from the cbor bytes and a cbor code handle
  var h codec.Handle = new(codec.CborHandle)
  var dec *codec.Decoder = codec.NewDecoderBytes(fileBytes, h)

  // Decode into an EdgeX Event
  var event contracts.Event
  err = dec.Decode(&event)
  check(err)

  // Decode into arbitrary type
  foo := struct {
  X   int
  Y   int
  Z   int
  Bar string
  }{}

  dec = codec.NewDecoderBytes(event.Readings[0].BinaryValue, h)
  err = dec.Decode(&foo)
  check(err)

  fmt.Println(foo)
}
```

This code takes a command response in the same format as the previous
example, but uses the `codec` library to decode the CBOR
data inside the EdgeX Reading's `BinaryValue` field.

Using this approach, an Event can be sent containing data containing an
arbitrary, flexible structure. Use cases could be a Reading containing
multiple images, a variable length list of integer read-outs, etc.
