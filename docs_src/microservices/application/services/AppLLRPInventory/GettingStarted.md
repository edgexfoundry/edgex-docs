---
title: App RFID LLRP Inventory Replay - Getting Started
---

# App RFID LLRP Inventory - Getting Started

## Running the service

This service depends on the Device RFID LLRP service to also be running so that it is managing the LLRP readers and generating the raw LLRP events. Do the following to run these services along with the other EdgeX services:

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the compose-builder folder

3. Run the services
```bash
make run no-secty ds-llrp as-llrp
```

This runs, in non-secure mode, all the standard EdgeX services as well as the LLRP Device and Application services

## More Details

See the following additional detail sections for more details on getting started with this service

| Section Name                                                | Description                                                  |
| ----------------------------------------------------------- | ------------------------------------------------------------ |
| [Inventory Events](./details/InventoryEvents.md)            | Learn about the Events that this service generates and published back to the EdgeX MessageBus |
| [Tag Location Algorithm](./details/TagLocationAlgorithm.md) | Learn how each tag is associated with a single `Location`    |
| [Location Aliases](./details/LocationAliases.md)            | Learn how to configure location aliases for each LLRP reader |
| [Behaviors](./details/Behaviors.md)                         | Learn about "Behaviors" concept, which abstracts and simplifies LLRP Reader configuration |
| [Mobility Profile](./details/MobilityProfile.md)            | Learn how profile values are used in the Location algorithm as an adjustment function |