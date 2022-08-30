## Record and Replay
### Submitters
- Lenny Goodell (Intel)
- Jim White (IOTech)

## Change Log
- [pending](URL of PR) (2022-08-11)

### Market Segments
- Any/All

### Motivation
Currently one must have physical devices and appropriate environment to produce real device data (Event/Readings) into an EdgeX solution for other EdgeX services (Core Data, App Services, eKuiper Rules Engine) to consume. This is often not the case when someone is developing/testing one of these consuming EdgeX services. A good example of this is the **[RFID LLRP Inventory App Service](https://github.com/edgexfoundry/app-rfid-llrp-inventory)** . Testing this service is dependent on the [RFID LLRP Device Service](https://github.com/edgexfoundry/device-rfid-llrp-go), physical LLRP RFID readers, RFID Tags and environment where these are deployed. Having a way to record EdgeX the Event/Readings from an actual deployment that then could be replayed in development environment for testing would be very valuable. 

Other potential uses are:

- “Replayable data” could be used to validate a new or updated EdgeX service behaves like the existing one (EdgeX certification). Or the data could be offered by component providers to give users an example of the type of data generated from one of their device services.
- EdgeX Ready applicants could use a record feature to capture data from their device service and the committee could explore that in relation to their profile to make sure they seemed to know what they were doing.
- Record and replay can be used to reproduce a reported bug.
- Record and export could serve as a simple means to backup data in the event of data loss.

### Target Users
- Device Manufacturer
- Device Owner
- Device User
- Device Maintainer
- Software Developer
- Software Deployer
- Software Integrator

### Description
Target users have the need to be able to replay recorded EdgeX Event/Readings for functional, performance or reproducible testing. This UCR describes a new capability that allows user to first record Event/Readings from real devices in real-time and be able to replay the Event/Readings as if it was in real-time. The static device profile and device definition files at time of capture will need to be available and loaded at the time the captured data is replayed. 

### Existing solutions
There are simulators for some devices (i.e. Modbus), but there isn't an general solution to reproduce real device data into EdgeX without the physical devices being present. These simulators also don't have a way to produce a specific set of results in a timeline as do physical devices.

### Requirements
#### Record

Shall have capability to record device Event/Reading data as received from the Device Service(s). 

- Recorded Event/Reading timestamps shall be sufficient to determine the captured rate.

- Recorded Events shall be sufficient to determine the major version of EdgeX used, i.e. ApiVersion

- Record must allow the duration of capture and/or the max number of Readings to capture to be specified

- Record must capture all Device definitions for devices referenced in the captured Event/Readings

- Record must capture all Device Profiles for devices referenced in the captured Event/Readings

- Record must have the ability to record data only from specified target devices or device profiles.

#### Export

Shall have capability to export captured data for use at a later time or to send to other users

- Exported data shall be in JSON format with option for it to be compressed (ZIP or TAR). 

- Exported binary Event/Readings shall not be re-encoded in CBOR.

#### Import

Shall have capability to import data that was previously recorded and exported

- Import must validate that the current EdgeX version is compatible with the APIVersion captured in the recorded Events. 

- Import must add any captured Device definitions and Device Profiles to the system prior to play back.

- Import shall have option to overwrite or use existing Device definitions and Device Profiles

#### Replay

Shall have capability to replay previously captured data

- Replay must allow captured data to be replayed at captured, slower or faster speeds

- Replay must allow for the repeat replay option with number of times to repeat the captured data.

- Replay must allow recorded data from multiple sources at the same time (this mimics more device services feeding EdgeX )

### Other Related Issues
- None

### References
- http://www.cs.binghamton.edu/~ghyan/papers/sec20.pdf
- https://hal.inria.fr/hal-02056767/document
- https://iotatlas.net/en/patterns/telemetry_archiving/
