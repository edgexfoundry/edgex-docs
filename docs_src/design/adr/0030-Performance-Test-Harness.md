# Performance Test Harness ADR
### Submitters
- Cherry Wang (IOTech)

## Change Log
<!--
List the changes to the document, incl. state, date, and PR URL.
State is one of: pending, approved, amended, deprecated.
Date is an ISO 8601 (YYYY-MM-DD) string.
PR is the pull request that submitted the change, including information such as the diff, contributors, and reviewers.

E.g.:
- [approved](URL of PR) (2022-04-01)
- [amended](URL of PR) (2022-05-01)
-->

## Referenced Use Case(s)
- [Performance Test Harness UCR](https://docs.edgexfoundry.org/3.0/design/ucr/Performance-Test-Harness/)

## Context
The Performance Test Harness for EdgeX Foundry is architecturally significant as it plays a crucial role in ensuring the scalability and performance of the EdgeX platform under various scenarios. This ADR is created to outline the proposed design for the Performance Test Harness.

## Proposed Design
### Compose File:
- Services:
    - device-service
    - app-service
    - core-services, exclude core-data
    - simultaor or real device
    - InfluxDB and Telegraf for retrieve metrics

### Details:
- Data:
    - device template: Default use `modbus simulator`. The template can be coustomized which dependance on device by user.
    - device profiles: Default profiles are for `device-modbus`, The files can be coustomized which dependance on device by user.
    - app-service profile template: Default use `MQTTExport` function. The template can be coustomized by user.
- Setup:
    - A configuration file to define:
        - device or simulator IP
        - InfluxDB server IP
        - Retrieve report data time range
        - And etc.
    - Use shell script to get compose file from [edgex-compose](https://github.com/edgexfoundry/edgex-compose) and combine the external service, like telegraf and etc.
    - Use shell script to generate pre-define device file based on templates and configuration file, then put device and profile yaml files under /res of device-service.
    - Use shell script to generate app-services profiles based on templates and configuration file.
    - Use `atd` service to schedule a one-time task at a specific time for generating report
- Report:
    - Report presents
        - Server Total CPU and Memory
        - Server CPU and Memory metrics in the peroid of running the EdgeX
        - Services CPU and Memory metrics in the peroid of running the EdgeX
        - Services CPU and Memory aggreations in the peroid of running the EdgeX
    - Set schedule by `at` command to generate report. example `at now + 6 hour -f schedule.sh`

    !!! example - "Example `schedule.sh`"
        ```shell
        # Generate Report
        python3 generate-report.py

        FILE="./report*.png"
        if [ -f "$FILE" ]; then
          # Shutdown Services
          docker compose down -v
        fi
        ```
    - Generate image report by python script
        - Use matplotlib, seaborn and pandas libraries to generate image report
        - See example report as below
        ![Performance Report](performance-report.png)

## Considerations
The scalability and reliability of the Performance Test Harness should be considered to ensure accurate performance evaluations.

## Decision
<!--
Document any agreed upon important implementation detail, caveats, future considerations, remaining or deferred design issues.
Document any part of the requirements not satisfied by the proposed design.
-->

## Other Related ADRs
- None

## References
- None

