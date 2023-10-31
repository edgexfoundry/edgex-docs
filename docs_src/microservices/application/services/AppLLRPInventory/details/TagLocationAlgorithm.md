---
title: App RFID LLRP Inventory - Tag Location Alogrithm
---

# App RFID LLRP Inventory - Tag Location Alogrithm

Every tag is associated with a single `Location` which is the best estimation of the Reader and Antenna
that this tag is closest to.

The location algorithm is based upon comparing moving averages of various RSSI values from each RFID Antenna. Over time
these values will be decayed based on the configurable [Mobility Profile](MobilityProfile.md). Once the
algorithm computes a higher adjusted value for a new location, a Moved event is generated.

> **RSSI** stands for Received Signal Strength Indicator. It is an estimated measure of power (in dBm) that the RFID reader
> receives from the RFID tag's backscatter.
>
> In a perfect world as a tag gets closer to an antenna the
> RSSI would increase and vice-versa. In reality there are a lot of physics involved which make this
> a less than accurate representation, which is why we apply algorithms to the raw RSSI values.

!!! note
    Locations are actually based on `Aliases` and multiple antennas may be mapped to the same `Alias`, which will cause them to be treated as the same within the tag algorithm. This can be especially useful when using a dual-linear antenna and mapping both polarities to the same `Alias`.
