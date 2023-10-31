---
title: App RFID LLRP Inventory - Mobility Profile
---

# App RFID LLRP Inventory - Mobility Profile

The following configuration options define the `Mobility Profile` values.
These values are used in the Location algorithm as an adjustment function which
will decay RSSI values over time. This offset value is then applied to the existing Tag's Location
and compared to the non-adjusted average. Positive `offset` values will increase the likelihood of a tag
staying in the same location, whereas negative `offset` values will increase the likelihood that the tag
will move to the new location it was just read at.

The main goal of the Mobility Profile is to provide a way to customize the various tradeoffs when
dealing with erratic data such as RSSI values. In general there is a tradeoff between responsiveness
(how quickly tag movement is detected) and stability (preventing sporadic readings from generating erroneous events).
By tweaking these values you will be able to find the balance that is right for your specific use-case.

Suppose the following variables:

- **`incomingRSSI`** Mean RSSI of last `windowSize` reads by incoming read's location
- **`existingRSSI`** Mean RSSI of last `windowSize` reads by tag's existing location
- **`offset`** Result of Mobility Profile's computations

The location will change when the following equation is true:
- `incomingRSSI > (existingRSSI + offset)`

![Mobility Profile Diagram](./mobility-profile.png)

## Configure Mobility Profile

See the `Mobility`settings in the [Application Settings](../Configuration.md#applicationsettings) section of the service's configuration.

## Example Mobility Profile Values

Here are some example mobility profile values based on our previous experience.
These values can be used as a reference when creating your own Mobility Profile.

!!! example - "Asset Tracking - Uses default mobility profile values"
    | **Asset Tracking**    |        |
    |-----------------------|--------|
    | Slope                 | -0.008 |
    | Threshold             | 6.0    |
    | Holdoff Millis        | 500.0  |

!!! example - "Retail Garment - Uses alternate mobility profile values"
    | **Retail Garment** |         |
    |--------------------|---------|
    | Slope              | -0.0005 |
    | Threshold          | 6.0     |
    | Holdoff Millis     | 60000.0 |
