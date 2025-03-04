---
title: App RFID LLRP Inventory - Inventory Events
---

# App RFID LLRP Inventory - Inventory Events

There are 3 basic inventory events that are generated and sent to the EdgeX MessageBus.
Here are some example `EdgeX Events` with accompanying `EdgeX Readings`.

!!! note
    The `readings` field of the `EdgeX Event` is an array and multiple Inventory Events may be sent via a single `EdgeX Event`. Each `EdgeX Reading` corresponds to a single Inventory Event.

## Arrived
Arrived events are generated when _**ANY**_ of the following conditions are met:

- A tag is read that has never been read before
- A tag is read that is currently in the Departed state
- A tag aged-out of the inventory and has been read again

!!! example - "Example **InventoryEventArrived Event**"
    ```json
    {
      "apiVersion": "v3",
      "id": "6def8859-5a12-4c83-b68c-256303146682",
      "deviceName": "app-rfid-llrp-inventory",
      "profileName": "app-rfid-llrp-inventory",
      "sourceName" : "app-rfid-llrp-inventory",
      "origin": 1598043284109799400,
      "readings": [
        {
          "apiVersion": "v3",
          "origin": 1598043284109799400,
          "deviceName": "app-rfid-llrp-inventory",
          "resourceName": "InventoryEventArrived",
          "profileName": "app-rfid-llrp-inventory",
          "valueType": "String",
          "value": "{\"epc\":\"30340bb6884cb101a13bc744\",\"tid\":\"\",\"timestamp\":1598043284104,\"location\":\"SpeedwayR-10-EF-25_1\"}"
        }
      ]
    }
    ```

## Moved
Moved events are generated when _**ALL**_ of the following conditions are met:

- A tag is read by an Antenna (`Incoming Antenna`) that is not the current Location
- The `Incoming Antenna`'s Alias does not match the current Location's Alias
- The `Incoming Antenna` has read that tag at least `2` times total (including this one)
- The moving average of RSSI values from the `Incoming Antenna` are greater than the
  current Location's _**adjusted**_ moving average _([See: Mobility Profile](./MobilityProfile.md))_

!!! example - "Example **InventoryEventMoved** Event"
    ```json
    {
      "apiVersion": "v3",
      "id": "c78c304e-1906-4d17-bf26-5075756a231f",
      "deviceName": "app-rfid-llrp-inventory",
      "profileName": "app-rfid-llrp-inventory",
      "sourceName" : "app-rfid-llrp-inventory",
      "origin": 1598401259697580500,
      "readings": [
        {
          "apiVersion": "v3",
          "origin": 1598401259697580500,
          "deviceName": "app-rfid-llrp-inventory",
          "resourceName": "InventoryEventMoved",
          "profileName": "app-rfid-llrp-inventory",
          "valueType": "String",
          "value": "{\"epc\":\"30340bb6884cb101a13bc744\",\"tid\":\"\",\"timestamp\":1598401259691,\"old_location\":\"Freezer\",\"new_location\":\"Kitchen\"}"
        }
      ]
    }
    ```

## Departed
Departed events are generated when:

- A tag is in the `Present` state and has not been read in more than
  the configured `DepartedThresholdSeconds`

!!! note
    Departed tags have their tag statistics cleared, essentially resetting any values used by the tag algorithm. So if this tag is seen again, the Location will be set to the
first Antenna that reads the tag again.

!!! example - "Example **InventoryEventDeparted** Event"
    ```json
    {
      "apiVersion": "v3",
      "id": "4d042708-c5de-41fa-827a-3f24b364c6de",
      "deviceName": "app-rfid-llrp-inventory",
      "profileName": "app-rfid-llrp-inventory",
      "sourceName" : "app-rfid-llrp-inventory",
      "origin": 1598062424894043600,
      "readings": [
        {
          "apiVersion": "v3",
          "origin": 1598062424894043600,
          "deviceName": "app-rfid-llrp-inventory",
          "resourceName": "InventoryEventDeparted",
          "profileName": "app-rfid-llrp-inventory",
          "valueType": "String",
          "value": "{\"epc\":\"30340bb6884cb101a13bc744\",\"tid\":\"\",\"timestamp\":1598062424893,\"last_read\":1598062392524,\"last_known_location\":\"SpeedwayR-10-EF-25_1\"}"
        },
        {
          "apiVersion": "v3",
          "origin": 1598062424894043600,
          "deviceName": "rfid-llrp-inventory",
          "resourceName": "InventoryEventDeparted",
          "profileName": "rfid-llrp-inventory",
          "valueType": "String",
          "value": "{\"epc\":\"30340bb6884cb101a13bc688\",\"tid\":\"\",\"timestamp\":1598062424893,\"last_read\":1598062392512,\"last_known_location\":\"POS Terminals\"}"
        }
      ]
    }
    ```
## Tag State Machine
Below is a diagram of the internal tag state machine. Every tag starts in the `Unknown` state (more precisely does not exist at all in memory).
Throughout the lifecycle of the tag, events will be generated that will cause it to move between
`Present` and `Departed`. Eventually once a tag has been in the `Departed` state for long enough
it will "Age Out" which removes it from memory, effectively putting it back into the `Unknown` state.

![Tag State Diagram](./tag-state-diagram.png)
