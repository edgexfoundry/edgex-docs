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

### Creating a CBOR Payload for use with PUT Commands

To create a CBOR payload that, for example, can be used with `PUT` commands,
we first need to set up some content which will be used to create the CBOR data.
Then we encode that content and finally write the CBOR-encoded data to a file,
followed by using that file with an example `PUT` command.

The relevant data structures are as follows, containing details of the key
and the corresponding value, where you should note in particular the `Put`
field in the `Command` struct, and below the `Command` struct is the `Put`
struct itself. More details available at
https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/models/put.go:
``` golang
type Command struct {
	Timestamps  `yaml:",inline"`
	Id          string `json:"id" yaml:"id,omitempty"`     // Id is a unique identifier, such as a UUID
	Name        string `json:"name" yaml:"name,omitempty"` // Command name (unique on the profile)
	Get         Get    `json:"get" yaml:"get,omitempty"`   // Get Command
	Put         Put    `json:"put" yaml:"put,omitempty"`   // Put Command
	isValidated bool   // internal member used for validation check
}

type Put struct {
	Action         `yaml:",inline"`
	ParameterNames []string `json:"parameterNames,omitempty" yaml:"parameterNames,omitempty"`
}
```
What follows below is the accompanying `golang` code that accomplishes the steps above:

``` golang
package main

import (
	"io/ioutil"

	"github.com/ugorji/go/codec"
)

const (
  fileLocation = "/Users/johnpoe/Desktop/CBOR_Binary"
)

const (
	enableRandomizationBinary = "EnableRandomization_Binary"
	path                      = "Path"
	url                       = "Url"
)

func main() {
	// Set up some records which will be used to create the CBOR data
	cborContents := make(map[string]string)

	// The user should put values in the cborContents variable above, which will
	// be converted to CBOR. Please refer to the earlier note containing details
	// of the key and the corresponding value each keys represent. What follows
	// below is an example of populating the "ParameterNames" (aka "Put")
	cborContents[enableRandomizationBinary] = "true"
	cborContents[path] = "/api/v1/device/9f872d68/Binary"
	cborContents[url] = "http://localhost:48082/api/v1/device/9f872d68/command/7ff8d51ea50d"


	// Encode the contents that were set up above.
	input := make([]byte, 0)
	check(codec.NewEncoderBytes(&input, &codec.CborHandle{}).Encode(cborContents))

	// Write the CBOR-encoded data to a file.
	ioutil.WriteFile(fileLocation, input, 0644)
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}
```

In the code above, as a final step, the CBOR payload has been written to the filesystem,
into a file that we are calling `CBOR_Binary`.

Here is how to use the `PUT` command: Via the `--data-binary` flag in `cURL`, supply as
follows the CBOR-encoded file created above. You will want to replace the fileLocation
(i.e. `'@/Users/johnpoe/Desktop/CBOR_Binary'` by a suitably-located local file on your
filesystem:
```
curl --location --request PUT 'http://localhost:48082/api/v1/device/9f872d68-2281-4af4-959d-29e4d51c2192/command/b349df4a-6c3d-4218-b8bc-7ff8d51ea50d' \
--header 'Content-Type: application/cbor' \
--data-binary '@/Users/johnpoe/Desktop/CBOR_Binary'
```


