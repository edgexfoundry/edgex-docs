# App Record and Replay

## Purpose

This service is a developer testing tool which will record Events from the EdgeX MessageBus and replay them back to the EdgeX MessageBus at a later time. The value of this is a session with devices present can be recorded for later replay on a system which doesn't have the required devices. This allows for testing of services that receive and process the Events without requiring the devices to be present.

!!! note
    The source device service must be running when data is imported since the devices and device profiles are captured as part of the recorded data will be added to the system during import.

!!! warning - "Storage Model"
    Since this is targeted as a developer testing tool, the storage model is kept simple by using in-memory storage for the recorded data. This should be kept in mind when recording or importing a recoding on systems with limited resources.
