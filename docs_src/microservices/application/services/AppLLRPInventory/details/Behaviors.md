---
title: App RFID LLRP Inventory - Behaviors
---

# App RFID LLRP Inventory - Behaviors

The code processes ROAccessReports coming from the LLRP Device Service,
and so you can direct those Readers through that service.
Alternatively, this code includes a "Behaviors" concept,
which abstracts and simplifies LLRP Reader configuration
at the expense of configuration expressiveness.

A Behavior provides a limited set of options applicable to inventory applications.
This service determines and applies the LLRP options
that best match the desired Behavior
using information about the current environment and Readers' capabilities.

Here's how the service works with Behaviors:

- On startup, it retrieves the current device list from EdgeX's Metadata service.
- It uses the LLRP device service
  to reset those Readers to their factory default configs
  and deletes any ROSpecs they currently have.
- Next, it generates an ROSpec per Reader based on its device capabilities,
  the current desired behavior, and certain environmental factors.
- It sends those ROSpecs to each Reader.
- When directed to start reading, it enables and/or starts the ROSpecs on each device.
    - If the desired behavior has an infinite duration, they start automatically.
    - If the behavior has a GPI trigger, it waits til that trigger starts it.
    - If the behavior has a finite duration (i.e., is a one-off), the service sends it a Start command.
- When it gets a stop request, it stops and/or disables ROSpecs, as necessary.


## Important Limitations

- Since this code makes use of various commands on the device service,
  your devices must be registered with the LLRP device service
  using device profiles with names matching
  the `deviceCommands` and `deviceResources` it needs.
  The full list [can be found below](#device-profile-requirements).
- In particular, Impinj devices must be registered with the device service
  using a profile that has an `enableImpinjExt` `deviceCommand`,
  to `set` to a `deviceResource` representing a `CustomMessage`
  that enables Impinj's custom extensions.
  An example profile that meets these conditions
  is available in the LLRP Device Service.
- You can modify a Behavior at any time,
  but doing so resets managed Readers' configurations,
  and thus if they were reading, they will stop.
- The current code uses only a single `default` Behavior that applies to all Readers,
  and currently isn't persisted between restarts.
  The code is written in a way to support multiple Behaviors,
  but since there are many ways one can reasonably relate behaviors and devices,
  extending this is left for future development
  or as an exercise for the user.


## Working with Behaviors

To start all Readers reading with the current behavior,
`POST` to the `/command/reading/start` endpoint:

    curl -o- -X POST localhost:59711/api/v3/command/reading/start

To stop reading,
`POST` to the `/command/reading/stop` endpoint:

    curl -o- -X POST localhost:59711/api/v3/command/reading/stop

To view the `default` Behavior:

    curl -o- localhost:59711/api/v3/behaviors/default

```json
{
    "impinjOptions": {
        "suppressMonza": false
    },
    "scanType": "Normal",
    "duration": 0,
    "power": {
        "max": 3000
    }
}
```

To modify the `default` Behavior, `PUT` a new one at that endpoint.
The new behavior completely replaces the old one.
The following example uses `jq` to generate the `JSON` Behavior structure,
the details of which are explained below.
This particular Behavior enables a `Fast` scan at `30 dBm`:

    curl -o- localhost:59711/api/v3/behaviors/default -X PUT \
        --data @<(jq -n '{ScanType: "Fast", Power: {Max: 3000}}')


If you attempt to set the Behavior to something that can't be supported
all the Readers to which it should apply,
you'll receive an error response, and the Behavior won't change:

    curl -o- -X PUT localhost:59711/api/v3/behaviors/default \
        --data @<(jq -n '{ScanType: "Fast"}')
    
    new behavior is invalid for "Speedway": target power (0.00 dBm)
    is lower than the lowest supported (10.00 dBm): behavior cannot be satisfied

## Supported Behavior Options
- `ScanType` is a string which should be set to one of the following:
    - `Fast` singulates tags as often as possible, with little regard for duplicates.
      This mode makes sense when tags are likely to "move fast"
      through antennas' Fields of View (FoV),
      or when the tag population is small
      and you want to detect as soon as possible when a tag is no longer present.
      For large, static tag populations,
      this mode is likely to repeatedly inventory only the strongest tags.
    - `Normal` mode reads tags in a way that keeps them quiet for a short while,
      but allow that to "timeout" so you'll see it multiple times
      as long as it's still in the Reader's antenna's Field of View (FoV).
      This mode is better than `Fast` at finding weaker tags,
      but as the population size grows,
      it'll become more difficult for the Reader to outpace tag timeouts.
    - `Deep` mode, like `Normal`, suppresses responses to find weaker tags,
      but does so in a way that makes it more likely to find even the weakest tags.
      It attempts to keep tags quiet until it has read every tag.
      If it reaches a point that it can no longer find tags,
      it changes strategies to attempt to re-inventory the population.
      It can take longer for this mode to notice a tag has entered or exited its FoV.
- `Duration` is a number of milliseconds between 0 and 4,294,967,295 (2^32-1)
  that determines how long the Behavior should run.
  If the value is zero, the Behavior applies until the service receives a `stop` command.
- `Power` is an object, though the current version accepts only one key:
    - `Max` is the 100x the maximum desired dBm output from the Reader to its antennas;
      actual radiated power depends on the gains and losses
      associated with the antenna and cabling.
      The service accepts values between -32,768 and 32,767 (the space of an int16),
      but it configures the Reader with its highest available power
      less than or equal to the given target.
      The service rejects the Behavior if its `Power.Max` is less than
      the lowest value supported by the Readers
      to which the Behavior should apply.
- `Frequencies` is a list of frequencies, in kHz, for which the `Power.Max` is legal.
  In non-frequency Hopping regulatory regions, this element is required,
  while in frequency Hopping regions, this element is ignored.
  In the first case, the service must tell the Reader what frequency to operate,
  but some regions allow different power levels at different frequencies.
  For these Readers, the service will only choose a Frequency from this list,
  or will reject the Behavior if the Reader lacks any matching frequencies.
  The US is a Hopping region, so this value is ignored for a Reader legal to operate in the US.
- `GPITrigger` is an optional object that configures a GPI trigger.
  When the service receives a `start` command,
  rather than starting the Behavior right away,
  the service tells the Reader to read
  whenever a GPI pin switches to a certain state.
  Likewise, the service handles `stop` by disabling the config on the Reader.
  The required elements match that of the LLRP structure:
    - `Port` is a uint16 port number.
    - `Event` is a bool with meaning for the GPI
    - `Timeout` is a uint32 number of milliseconds after which the trigger times out;
      if it's 0, it never times out.
- `ImpinjOptions` is an optional object with values that only apply
  if the target Reader supports them:
    - `SuppressMonza` is a boolean that, if true, enables Impinj's "TagFocus" feature.
      When an Impinj reader uses this mode and singulates tags in "Session 1"
      (a concept that applies to the EPCGlobal Gen2 standard),
      it refreshes Monza tags' S1 flag to the "B state",
      so those tags are inventoried only once when they enter the antenna's FoV.
      When this option is enabled on a Behavior,
      the service changes its `Fast` and `Normal` scans to use this.
      Since a `Deep` scan already attempts to keep all tags quiet
      until it inventories the full tag population,
      this option doesn't have an effect when the `ScanType` is `Deep`.

      Note that this feature only works on Impinj Monza tags
      when they're being read by an Impinj Reader;
      other readers are not configured with this option,
      and other tag types will act as they do under a `Normal` scan.


## Device Profile Requirements
As [mentioned above](#important-limitations), this service calls the Device Service
with specific `deviceCommands` and expects specific `deviceResources`.
Thus, those `deviceCommands` and `deviceResources`
must be defined in the `deviceProfile`s
for which devices are registered with the LLRP Device Service.

### All Devices
All devices must be registered with a `deviceProfile` that provides the following:

- The following `deviceResources` must be available:
    - EdgeX `"String"` types, the values of which
      encode json-representations of LLRP messages and/or parameters
      that can be marshaled by Go's standard `json` package
      into [the Go structs defined in the LLRP package](https://github.com/edgexfoundry/app-rfid-llrp-inventory/blob/{{edgexversion}}/internal/llrp/llrp_structs.go):
        - `ReaderCapabilities` with a `readWrite` of `"R"` or `"RW"`
          encoding an LLRP `GetReaderCapabilitiesResponse` message.
        - `ReaderConfig` with a `readWrite` of `"W"` or `"RW"`
          encoding an LLRP `GetReaderConfigResponse` message.
        - `ROSpec` with a `readWrite` of `"W"` or `"RW"`
          encoding an LLRP `ROSpec` parameter.
    - An EdgeX `"uint32"` type with `readWrite` of `"W"` or `"RW"` named `ROSpecID`,
      the string value of which encodes an LLRP `ROSpecID`
      as a base-10 unsigned integer.
    - An EdgeX `"String"` type with `readWrite` of `"W"` or `"RW"` named `"Action"`,
      which the device service uses to determine which `deviceCommand` was called.
- The following `deviceCommands` must be available:
    - `capabilities` must have a `get` for `ReaderCapabilities`.
    - `config` must have a `set` that accepts `ReaderConfig`.
    - `roSpec` must have a `set` that accepts `ROSpec`.
    - The following `deviceCommands` must have two `set`s --
      the first must accept `ROSpecID`
      and the second must `set` `Action` with the appropriate `parameter` value:
        - `enableROSpec` must `set` `Action` with the `parameter` value `"Enable"`
        - `startROSpec` must `set` `Action` with the `parameter` value `"Start"`
        - `stopROSpec` must `set` `Action` with the `parameter` value `"Stop"`
        - `disableROSpec` must `set` `Action` with the `parameter` value `"Disable"`
        - `deleteROSpec` must `set` `Action` with the `parameter` value `"Delete"`

### Impinj Devices
In addition to the above,
Impinj Readers must be registered with a profile
that has a `deviceResource` named `ImpinjCustomExtensionMessage`
with the `attributes` `vendor: "25882"` and `subtype: "21"`
and a `deviceCommand` named `enableImpinjExt`
with a `set` that targets that `deviceResource`.

When this service sees an Impinj device,
it sends a `PUT` request with `{"ImpinjCustomExtensionMessage": "AAAAAA=="}`
to `{deviceService}/api/v3/commands/{deviceName}/enableImpinjExt`;
if that `deviceCommand` and `deviceResource` exist,
the Device Service will send a `CustomMessage` to the reader,
enabling this service to send Impinj's `CustomParameter`s.
This is required because Impinj Readers reject LLRP `CustomParameter`s
unless a `Client` sends the afore-described `CustomMessage`
at some earlier point in their communication.
If that resource or command doesn't exist for the device,
this service will receive a 404 from the Device Service,
preventing it from operating as designed.