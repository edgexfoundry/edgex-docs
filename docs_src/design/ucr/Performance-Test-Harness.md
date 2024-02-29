## Performance Test Harness

## Submitters
- Cherry Wang (IOTech)

## Changelog
[approved](https://github.com/edgexfoundry/edgex-docs/pull/1318) (2024-01-29)

## Market Segments
- All

## Motivation
The EdgeX Performance Test aims to evaluate the efficiency of the EdgeX services in handling a large volume of data transmission from the south side to the north side in a manufacturing context. This use case is motivated by the need to understand how EdgeX performs under heavy data loads and to identify potential areas for optimization.

By providing the Performance Test Harness, users can execute the Performance Tests with their own hardware and devices environment to evaluate the capability of the system.

## Target Users
- System Developer
- System Integrator

## Description
The EdgeX Performance Test involves the south side generating a substantial amount of data and transmitting it through EdgeX services to the north side. This process aims to simulate real-world scenarios where data flow between manufacturing devices and backend systems is intensive. The observation of this data transmission allows for an in-depth analysis of EdgeX's resource utilization patterns.

## Existing solutions
- The basic performance metrics collection in TAF: https://github.com/edgexfoundry/edgex-taf/blob/v3.1.0/docs/run-performance-metrics-collection-on-local.md
- Users may prepare the customized performance test script to measure different metrics according to their own requirements

## Requirements
- A device / app-service profile template shall be defined that allows user to specify the device and app-services to be involved.
- A configuration shall be defined that allows user to specify the number of device and app-services, server address, and etc. to run. e.g. 10 devices per profile and 10 app-services.
- Tools for monitoring real-time resource utilization during transmission. e.g. Telegraf, InfluxDB. The following resources will be monitored:
    - Host metrics.
    - Services metrics. e.g. app-service, device-services, core-services
- A tool to schedule a one-time task at a specific time for generating report. e.g. `atd (at daemon)` service
- A script to use for retrieving metrics and generating report.
- The capability to integrate additional services in the performance tests, such as eKuiper.

![Performance Test Infra](performance-test.png)

## Related Issues
N/A

## References
N/A
