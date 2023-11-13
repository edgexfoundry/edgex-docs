---
title: Device GPIO - Configuration
---

# Device GPIO - Configuration

This service defines the following **Driver** configuration settings in addition to the configuration to that provided by the Device SDK.
See [Device Service Configuration](../../Configuration.md) section for details on the common device service configuration.

| Name                | Default Value | Description                                                                                        |
|---------------------|---------------|----------------------------------------------------------------------------------------------------|
| Driver.Interface    | "sysfs"       | GPIO interface to use. Valid values are `sysfs` and `chardev`. Note that `chardev` is experimental |
| Driver.ChipSelected | "0"           | Chip to select when using `chardev`  interface                                                     |

