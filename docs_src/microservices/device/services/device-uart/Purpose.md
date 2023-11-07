---
title: Device UART - Purpose
---

# Device UART - Purpose

The Device UART Microservice is a device service used for connecting serial UART devices/sensors to EdgeX. This device service implements communication with universal serial devices such as USB to TTL serial, rs232, or rs485 interface device for reading and setting values. The values read are published to the EdgeX Message Bus; the values set are received from other EdgeX services. This device service **ONLY** works on **Linux** systems. This device service is contributed by [Jiangxing Intelligence](https://www.jiangxingai.com/) and HCL Technologies (EPL Team).