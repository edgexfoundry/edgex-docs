# Threat Modeling Report

Created on 9/6/2022 2:49:03 PM

*generated from HTML by
https://www.convertsimple.com/convert-html-to-markdown/*
*embedded images extracted with Pandoc https://pandoc.org (Pandoc did not do well with tables so just used for image extraction)*

**Threat Model Name:** EdgeX Foundry Threat Model

**Owner:** Jim White (IOTech Systems)

**Reviewer:** Bryon Nevis, Lenny Goodell, Jim Wang (all from Intel),
Farshid Tavakolizadeh (Canonical), Rodney Hess (Beechwoods)

**Contributors:**

**Description:** General Threat Model for EdgeX Foundry - inclusive of
security elements (Kong, Vault, etc).

**Assumptions:** EdgeX is platform agnostic, but this Threat model
assumes the underlying OS is a Linux distribution. EdgeX can run
containerized or non-containerized (natively). This Threat Model assumes
EdgeX is running in a containerized environment (Docker). EdgeX micro
services can run distributed, but this Threat Model assumes EdgeX is
running on a single host (single Docker deamon with a single Docker
network unless otherwise specified). Many different devices/sensors can
be connected to EdgeX via its device services. This Threat model treats
all sensors/devices the same (which is not always the case given the
varoius protocols of support). Per
https://docs.edgexfoundry.org/2.0/threat-models/secret-store/threat_model/,
additional hardening such as secure boot with hardware root of trust,
and secure disk encryption are outside of EdgeX control but would
greatly improve the threat mitigation.

**External Dependencies:** Operating system and hardware (including
devices/sensors) Device/sensor drivers Possibly a cloud system or
external enterprise system that EdgeX gets data to A message bus broker
(such as an MQTT broker)

### Notes:

| Id  | Note | Date | Added By |
| --- | --- | --- | --- |
| 1   | Tampering with Data - This is a threat where information in the system is changed by an attacker. For example, an attacker changes an account balance Unauthorized changes made to persistent data, such as that held in a database, and the alteration of data as it flows between two computers over an open network, such as the Internet | 8/25/2022 8:40:40 PM | DESKTOP-SL3KKHH\\jpwhi |
| 2   | XSS protections: filter input on arrival (don't do), encode data on oputput (don't do), use appropriate headers (do), use CSP (dont do) | 8/25/2022 8:54:16 PM | DESKTOP-SL3KKHH\\jpwhi |
| 3   | priority is determined by the likelihood of a threat occuring and the severity of the impact of its occurance | 8/25/2022 9:11:40 PM | DESKTOP-SL3KKHH\\jpwhi |
| 4   | Repudiation - don't track and log users actions; can't prove a transaction took place | 8/25/2022 9:13:14 PM | DESKTOP-SL3KKHH\\jpwhi |
| 5   | Elevation of privil - authorized or unauthorized user gains access to info not authorized | 8/25/2022 9:16:24 PM | DESKTOP-SL3KKHH\\jpwhi |
| 6   | Remote code execution: https://www.comparitech.com/blog/information-security/remote-code-execution-attacks/ buffer overflow sanitize user inputs proper auth use a firewall | 8/25/2022 9:21:28 PM | DESKTOP-SL3KKHH\\jpwhi |
| 7   | Privilege escalation attacks occur when bad actors exploit misconfigurations, bugs, weak passwords, and other vulnerabilities | 8/27/2022 3:57:18 PM | DESKTOP-SL3KKHH\\jpwhi |

### Threat Model Summary:

|     |     |
| --- | --- |
| Not Started | 0   |
| Not Applicable | 17  |
| Needs Investigation | 17  |
| Mitigation Implemented | 62  |
| Total | 96  |
| Total Migrated | 0   |


------------------------------------------------------------------------

## Diagram: EdgeX Foundry (Big Picture)

![EdgeX Foundry (Big Picture) diagram
screenshot](./images/58a5213e8a15694ea2f5d209d7c37c9c5872f230.png)

### EdgeX Foundry (Big Picture) Diagram Summary:

  ------------------------ ----
  Not Started              0
  Not Applicable           10
  Needs Investigation      6
  Mitigation Implemented   58
  Total                    74
  Total Migrated           0
  ------------------------ ----

### Interaction: config

![config interaction
screenshot](./images/ecf3c5333506362006cc52b2424e70b91919e2c9.png)

#### 1. Weak Access Control for a Resource  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- ---------------------------------------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Improper data protection of Consul (configuration) can allow an
                                      attacker to read information not intended for disclosure.
                                      Review authorization settings.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            EdgeX services that use Consul must use a Vault access token
                                      provided in bootstrapping of the service. See
                                      https://docs.edgexfoundry.org/2.3/security/Ch-Secure-Consul/.
                                      There is also per service ACL rules in place to limit Consul
                                      access. As of the Ireland release, access of Consul requires
                                      ACL token header X-Consul-Token in any HTTP calls. Moreover,
                                      Consul itself is now bootstrapped and started with its ACL
                                      system enabled and thus provides better authentication and
                                      authorization security features for services. In other words,
                                      with the required Consul's ACL token for accessing Consul,
                                      assets inside Consul like EdgeX's configuration items in
                                      Key-Value (KV) store are now better protected.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- ---------------------------------------------------------------

#### 2. Spoofing of Source Data Store Consul (configuration)  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Consul (configuration) may be
                                      spoofed by an attacker and this may
                                      lead to incorrect data delivered to
                                      EdgeX Foundry. Consider using a
                                      standard authentication mechanism
                                      to identify the source data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            If someone was able to provide a
                                      container that was spoofing as
                                      Consul, the service would not know
                                      that the response came from
                                      something other than Consul.
                                      However, Consul is run as a
                                      container on the EdgeX Docker
                                      network. Replacing/spoofing the
                                      Consul container would require
                                      privileaged (root) access to the
                                      host. Additional adopter mitigation
                                      would include putting TLS in place
                                      between EdgeX and Consul (with TLS
                                      cert in place). A spoofing service
                                      (in this case Consul), would not
                                      have the appropriate cert in place
                                      to participate in the
                                      communications.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

### Interaction: configuration

![configuration interaction
screenshot](./images/af56f65371d0c62204f92068ee6d3f4c71d70866.png)

#### 3. Spoofing of Source Data Store Configuration Files  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Configuration Files may be spoofed
                                      by an attacker and this may lead to
                                      incorrect data delivered to EdgeX
                                      Foundry. Consider using a standard
                                      authentication mechanism to
                                      identify the source data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Configuration files are used to
                                      seed EdgeX configuration service
                                      (Consul) before the services are
                                      started. Configuration files are
                                      made part of the service container
                                      (deployed with the container
                                      image). The only way to spoof the
                                      file is to replace the entire
                                      service container with new
                                      configuration or to transplant new
                                      configuration in the container -
                                      both require privileaged access to
                                      the host.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

#### 4. Weak Access Control for a Resource  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Improper data protection of
                                      Configuration Files can allow an
                                      attacker to read information not
                                      intended for disclosure. Review
                                      authorization settings.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Disclosure of configuration files
                                      is not important. Configuration
                                      data is not considered sensitive.
                                      As long as the configuration files
                                      are not manipulated, then access to
                                      configuration files is not deemed a
                                      threat. All secret configuration is
                                      made available through Vault.

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

### Interaction: data

![data interaction
screenshot](./images/c7ab4add30664e0cec81b9168110e7e897a5a942.png)

#### 5. Spoofing of Source Data Store Redis  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Redis may be spoofed by an attacker
                                      and this may lead to incorrect data
                                      delivered to EdgeX Foundry.
                                      Consider using a standard
                                      authentication mechanism to
                                      identify the source data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            If someone was able to provide a
                                      container that was spoofing as
                                      Redis, the service would not know
                                      that the response came from
                                      something other than Redis.
                                      However, Redis is run as a
                                      container on the EdgeX Docker
                                      network. Replacing/spoofing the
                                      Redis container would require
                                      privileaged (root) access to the
                                      host. Additional adopter mitigation
                                      would include putting TLS in place
                                      between EdgeX and Redis (with TLS
                                      cert in place). A spoofing service
                                      (in this case Redis), would not
                                      have the appropriate cert in place
                                      to participate in the
                                      communications.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

#### 6. Weak Access Control for a Resource  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Improper data protection of Redis
                                      can allow an attacker to read
                                      information not intended for
                                      disclosure. Review authorization
                                      settings.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Access control credentials for
                                      Redis are secured in Vault
                                      (provided to EdgeX services at
                                      bootstrapping but otherwise
                                      unknown). Access without
                                      credentials is denied.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

#### 7. Authenticated Data Flow Compromised  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- ------------------------------------------------------------------------------------------------------------------------------------
  **Category:**                       Tampering

  **Description:**                    An attacker can read or modify data transmitted over an authenticated dataflow.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            EdgeX containers communicate via a Docker network. A hacker would need to gain access to the host and have elevated privileages on
                                      the host to access the network traffic. If extra security is needed or if an adopter is running EdgeX services in a distributed
                                      environment (multiple hosts), then overlay network encryption can be used (see example:
                                      https://github.com/edgexfoundry/edgex-examples/tree/update-custom-trigger-multiple-pipelines/security/remote_devices/docker-swarm)

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- ------------------------------------------------------------------------------------------------------------------------------------

### Interaction: published message

![published message interaction
screenshot](./images/cb2eb0473d8e1a765b623b86201257f18ce5f215.png)

#### 8. Potential Excessive Resource Consumption for EdgeX Foundry or Message Bus Broker  \[State: Mitigation Implemented\]  \[Priority: Medium\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Does EdgeX Foundry or Message Bus
                                      Broker take explicit steps to
                                      control resource consumption?
                                      Resource consumption attacks can be
                                      hard to deal with, and there are
                                      times that it makes sense to let
                                      the OS do the job. Be careful that
                                      your resource requests don't
                                      deadlock, and that they do timeout.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            The EdgeX message broker is either
                                      Redis Pub/Sub or an MQTT broker
                                      like Mosquitto and runs as a
                                      container in a Docker network that,
                                      by default with security on, does
                                      not allow direct access to the
                                      broker. Access to publish or
                                      subscribe to cause it to use
                                      excessive resources would require
                                      authorized access to the host as
                                      the port to the internal message
                                      broker is protected. In other
                                      words, EdgeX mitigates unauthorized
                                      attacks resulting in DoS event, but
                                      would not mitigate authorized
                                      attacks (such as a service
                                      producing too many message than the
                                      broker can handle) that result in a
                                      DoS event.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

#### 9. Spoofing of Destination Data Store Message Bus  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Message Bus may be spoofed by an
                                      attacker and this may lead to data
                                      being written to the attacker's
                                      target instead of Message Bus.
                                      Consider using a standard
                                      authentication mechanism to
                                      identify the destination data
                                      store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            The message bus when requiring a
                                      broker (MQTT broker for example) is
                                      run as a container on the EdgeX
                                      Docker network. Replacing/spoofing
                                      the broker container would require
                                      privileaged access to the host.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

### Interaction: queries & data

![queries & data interaction
screenshot](./images/c7ab4add30664e0cec81b9168110e7e897a5a942.png)

#### 10. Spoofing of Destination Data Store Redis  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Redis may be spoofed by an attacker
                                      and this may lead to data being
                                      written to the attacker's target
                                      instead of Redis. Consider using a
                                      standard authentication mechanism
                                      to identify the destination data
                                      store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            If someone was able to provide a
                                      container that was spoofing as
                                      Redis, the service would not know
                                      that the response came from
                                      something other than Redis.
                                      However, Redis is run as a
                                      container on the EdgeX Docker
                                      network. Replacing/spoofing the
                                      Redis container would require
                                      privileaged (root) access to the
                                      host. Additional adopter mitigation
                                      would include putting TLS in place
                                      between EdgeX and Redis (with TLS
                                      cert in place). A spoofing service
                                      (in this case Redis), would not
                                      have the appropriate cert in place
                                      to participate in the
                                      communications.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

#### 11. Authenticated Data Flow Compromised  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- ------------------------------------------------------------------------------------------------------------------------------------
  **Category:**                       Tampering

  **Description:**                    An attacker can read or modify data transmitted over an authenticated dataflow.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            EdgeX containers communicate via a Docker network. Docker containers do not share the host's network interface by default and
                                      instead is based on virtual ethernet adapters and bridges. A hacker would need to gain access to the host and have elevated
                                      privileages on the host to access the network traffic. If extra security is needed or if an adopter is running EdgeX services in a
                                      distributed environment (multiple hosts), then overlay network encryption can be used (see example:
                                      https://github.com/edgexfoundry/edgex-examples/tree/update-custom-trigger-multiple-pipelines/security/remote_devices/docker-swarm)

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- ------------------------------------------------------------------------------------------------------------------------------------

#### 12. Potential Excessive Resource Consumption for EdgeX Foundry or Redis  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Does EdgeX Foundry or Redis take
                                      explicit steps to control resource
                                      consumption? Resource consumption
                                      attacks can be hard to deal with,
                                      and there are times that it makes
                                      sense to let the OS do the job. Be
                                      careful that your resource requests
                                      don't deadlock, and that they do
                                      timeout.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Redis runs as a container in a
                                      Docker network that, by default
                                      with security on, does not allow
                                      direct access to the database.
                                      Access to query or push data into
                                      it to cause it to use excessive
                                      resources would require authorized
                                      access to the host as the port to
                                      the database is protected. In other
                                      words, EdgeX mitigates unauthorized
                                      attacks resulting in DoS event, but
                                      would not mitigate authorized
                                      attacks (such as a service making
                                      too many queries or pushing to much
                                      data into it) that result in a DoS
                                      event. EdgeX does have a routine
                                      with customizable configuration
                                      that "cleans up" and removes older
                                      data so that "normal" or otherwise
                                      expected use of the database for
                                      persistenct does not result in DoS.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

### Interaction: query

![query interaction
screenshot](./images/e7176a6f9f8c4c00ed2658a0e0aad5a56fc9b069.png)

#### 13. Spoofing of Destination Data Store Vault  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- --------------------------------------------------------------------------------------------
  **Category:**                       Spoofing

  **Description:**                    Vault may be spoofed by an attacker and this may lead to data being written to the
                                      attacker's target instead of Vault. Consider using a standard authentication mechanism to
                                      identify the destination data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            If someone was able to provide a container that was spoofing as Vault, the service would not
                                      know that the response came from something other than Vault. However, Vault is run as a
                                      container on the EdgeX Docker network. Replacing/spoofing the Vault container would require
                                      privileaged (root) access to the host. Additional adopter mitigation would include putting
                                      TLS in place between EdgeX and Vault (with TLS cert in place). A spoofing service (in this
                                      case Vault), would not have the appropriate cert in place to participate in the
                                      communications. EdgeX services that use Vault must use the go-mod-secrets client or a Vault
                                      service token to access its secrets (which is revoked by default). See
                                      https://docs.edgexfoundry.org/2.3/security/Ch-SecretStore/#using-the-secret-store See EdgeX
                                      Threat Model documentation
                                      (https://docs.edgexfoundry.org/2.0/threat-models/secret-store/threat_model/#threat-matrix)
                                      for additional considerations and mitigation.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- --------------------------------------------------------------------------------------------

#### 14. Potential Excessive Resource Consumption for EdgeX Foundry or Vault  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Does EdgeX Foundry or Vault take
                                      explicit steps to control resource
                                      consumption? Resource consumption
                                      attacks can be hard to deal with,
                                      and there are times that it makes
                                      sense to let the OS do the job. Be
                                      careful that your resource requests
                                      don't deadlock, and that they do
                                      timeout.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Vault runs as a container in a
                                      Docker network that, by default
                                      with security on, does not allow
                                      direct access to the secret store.
                                      Access to query or push data into
                                      it to cause it to use excessive
                                      resources would require authorized
                                      access to the host as the port to
                                      the database is protected. In other
                                      words, EdgeX mitigates unauthorized
                                      attacks resulting in DoS event, but
                                      would not mitigate authorized
                                      attacks (such as a service making
                                      too many queries or pushing to many
                                      secrets into it) that result in a
                                      DoS event.

  **Mitigator:**                      Third Party

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

### Interaction: query or actuation

![query or actuation interaction
screenshot](./images/45202e3bd894b0bc778d85fa97f7ccc8758cc962.png)

#### 15. Spoofing the EdgeX Foundry Process  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    EdgeX Foundry may be spoofed by an
                                      attacker and this may lead to
                                      unauthorized access to
                                      Device/Sensor. Consider using a
                                      standard authentication mechanism
                                      to identify the source process.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Spoofing all of EdgeX would require
                                      either replacing all of EdgeX
                                      containers and network (requiring
                                      host access and elevated
                                      privileges) or intercepting and
                                      rerouting traffic.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 16. Spoofing of Destination Data Store Device/Sensor  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Spoofing

  **Description:**                    Device/Sensor may be spoofed by an attacker and
                                      this may lead to data being written to the
                                      attacker's target instead of Device/Sensor.
                                      Consider using a standard authentication
                                      mechanism to identify the destination data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Due to the nature of many protocols, an outside
                                      agent could spoof as a ligitimage device/sensor.
                                      This is of particular concern if the device
                                      service auto provisions the devices/sensors
                                      without any authentication. Auto provisioning
                                      shold be limited to pick up trusted devices.
                                      Protocols such as BACnet do allow for
                                      authentication with the device/sensor. In this
                                      case, the device service should be written to use
                                      proper authentication. Commercial 3rd party
                                      software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------

#### 17. The Device/Sensor Data Store Could Be Corrupted  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Tampering

  **Description:**                    Data flowing across query or actuation may be
                                      tampered with by an attacker. This may lead to
                                      corruption of Device/Sensor. Ensure the integrity
                                      of the data flow to the data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device or
                                      intercept/use of the data to the device/sensor is
                                      one of the biggest threats to an edge system and
                                      one of the hardest to mitigate. If tampered with,
                                      a sensor or device could be used to send the
                                      wrong data (e.g., force a temp sensor to send a
                                      signal that it is too hot when it is really too
                                      cold), too much data (overwhelming the edge
                                      system by causing the sensor to send data too
                                      often), or not enough data (e.g., disconnecting a
                                      critical monitor sensor that would cause a system
                                      to stop). The device service can be constructed
                                      to filter data to avoid the "too much" data DoS.
                                      The device service can be constructed to report
                                      and alert when there is not enough data coming
                                      from the device or sensor or the sensor/device
                                      appears to be offline (provided by the last
                                      connected tracking in EdgeX). Wrong data can be
                                      mitigated by having the device service look for
                                      expected ranges of values (as supported by
                                      min/max attributes on device profiles).
                                      Commercial 3rd party software or extensions to
                                      EdgeX (see, for example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------

#### 18. Data Store Denies Device/Sensor Potentially Writing Data  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    Device/Sensor claims that it did
                                      not write data received from an
                                      entity on the other side of the
                                      trust boundary. Consider using
                                      logging or auditing to record the
                                      source, time, and summary of the
                                      received data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Use of elevated log level can be
                                      used to log all data
                                      communications.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 19. Data Flow Sniffing  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- ----------------------------------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Data flowing across query or actuation may be sniffed by
                                      an attacker. Depending on what type of data an attacker
                                      can read, it may be used to attack other parts of the
                                      system or simply be a disclosure of information leading to
                                      compliance violations. Consider encrypting the data flow.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Securing the data flow to/from a device or sensor is
                                      dependent on the OT protocol. In the case of something
                                      like BACnet secure (which is based on TLS - see
                                      https://www.bacnetinternational.org/page/secureconnect),
                                      the flow between EdgeX and the BACnet device can be
                                      encryped. The Device Service would need to be written to
                                      use that secure communications. In other simpler and
                                      typically older OT protocols (Modbus or GPIO as examples),
                                      there is no way to secure the communications with the
                                      device/sensor under that protocol. Critical
                                      sensors/devices of this nature should be physically
                                      secured (along with their connection to the EdgeX host).

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- ----------------------------------------------------------

#### 20. Potential Excessive Resource Consumption for EdgeX Foundry or Device/Sensor  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Does EdgeX Foundry or Device/Sensor take explicit
                                      steps to control resource consumption? Resource
                                      consumption attacks can be hard to deal with, and
                                      there are times that it makes sense to let the OS
                                      do the job. Be careful that your resource
                                      requests don't deadlock, and that they do
                                      timeout.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device is one of
                                      the biggest threats to an edge system and one of
                                      the hardest to mitigate. If tampered with, a
                                      sensor or device could be used to send the wrong
                                      data (e.g., force a temp sensor to send a signal
                                      that it is too hot when it is really too cold),
                                      too much data (overwhelming the edge system by
                                      causing the sensor to send data too often), or
                                      not enough data (e.g., disconnecting a critical
                                      monitor sensor that would cause a system to
                                      stop). The device service can be constructed to
                                      filter data to avoid the "too much" data DoS. The
                                      device service can be constructed to report and
                                      alert when there is not enough data coming from
                                      the device or sensor or the sensor/device appears
                                      to be offline (provided by the last connected
                                      tracking in EdgeX). Wrong data can be mitigated
                                      by having the device service look for expected
                                      ranges of values (as supported by min/max
                                      attributes on device profiles). Commercial 3rd
                                      party software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Third Party

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------

#### 21. Data Flow query or actuation Is Potentially Interrupted  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data flowing across
                                      a trust boundary in either direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device is one of
                                      the biggest threats to an edge system and one of
                                      the hardest to mitigate. If tampered with, a
                                      sensor or device could be used to send the wrong
                                      data (e.g., force a temp sensor to send a signal
                                      that it is too hot when it is really too cold),
                                      too much data (overwhelming the edge system by
                                      causing the sensor to send data too often), or
                                      not enough data (e.g., disconnecting a critical
                                      monitor sensor that would cause a system to
                                      stop). The device service can be constructed to
                                      filter data to avoid the "too much" data DoS. The
                                      device service can be constructed to report and
                                      alert when there is not enough data coming from
                                      the device or sensor or the sensor/device appears
                                      to be offline (provided by the last connected
                                      tracking in EdgeX). Wrong data can be mitigated
                                      by having the device service look for expected
                                      ranges of values (as supported by min/max
                                      attributes on device profiles). Commercial 3rd
                                      party software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------

#### 22. Data Store Inaccessible  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent prevents access to a data store
                                      on the other side of the trust boundary.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device is one of
                                      the biggest threats to an edge system and one of
                                      the hardest to mitigate. If tampered with, a
                                      sensor or device could be used to send the wrong
                                      data (e.g., force a temp sensor to send a signal
                                      that it is too hot when it is really too cold),
                                      too much data (overwhelming the edge system by
                                      causing the sensor to send data too often), or
                                      not enough data (e.g., disconnecting a critical
                                      monitor sensor that would cause a system to
                                      stop). The device service can be constructed to
                                      filter data to avoid the "too much" data DoS. The
                                      device service can be constructed to report and
                                      alert when there is not enough data coming from
                                      the device or sensor or the sensor/device appears
                                      to be offline (provided by the last connected
                                      tracking in EdgeX). Wrong data can be mitigated
                                      by having the device service look for expected
                                      ranges of values (as supported by min/max
                                      attributes on device profiles). Commercial 3rd
                                      party software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------

### Interaction: query & config

![query & config interaction
screenshot](./images/ecf3c5333506362006cc52b2424e70b91919e2c9.png)

#### 23. Potential Excessive Resource Consumption for EdgeX Foundry or Consul (configuration)  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- --------------------------------------------------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Does EdgeX Foundry or Consul (configuration) take explicit steps to control resource
                                      consumption? Resource consumption attacks can be hard to deal with, and there are times that
                                      it makes sense to let the OS do the job. Be careful that your resource requests don't
                                      deadlock, and that they do timeout.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Consul runs as a container in a Docker network that, by default with security on, does not
                                      allow direct access to the APIs and UI without the Consul access token (see
                                      https://docs.edgexfoundry.org/2.3/security/Ch-Secure-Consul/#how-to-get-consul-acl-token). A
                                      rogue authorized user or someone that illegally obtained the Consul token could force Consul
                                      to use too many resources by invoking its API or stuffing too much configuration in the
                                      system (or impact it enough that disrupts its abilty to service the EdgeX services).

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- --------------------------------------------------------------------------------------------

#### 24. Spoofing of Destination Data Store Consul (configuration)  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- --------------------------------------------------------------
  **Category:**                       Spoofing

  **Description:**                    Consul (configuration) may be spoofed by an attacker and this
                                      may lead to data being written to the attacker's target
                                      instead of Consul (configuration). Consider using a standard
                                      authentication mechanism to identify the destination data
                                      store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As of the Ireland release, access of Consul requires ACL token
                                      header X-Consul-Token in any HTTP calls. Moreover, Consul
                                      itself is now bootstrapped and started with its ACL system
                                      enabled and thus provides better authentication and
                                      authorization security features for services. In other words,
                                      with the required Consul's ACL token for accessing Consul,
                                      assets inside Consul like EdgeX's configuration items in
                                      Key-Value (KV) store are now better protected. Consul is run
                                      as a container on the EdgeX Docker network. Replacing/spoofing
                                      the Consul container would require privileaged access to the
                                      host and the spoofing service would not the bootstrapped ACL
                                      needed. EdgeX services that use Consul must use a Vault access
                                      token provided in bootstrapping of the service. See
                                      https://docs.edgexfoundry.org/2.3/security/Ch-Secure-Consul/

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- --------------------------------------------------------------

### Interaction: read

![read interaction
screenshot](./images/af56f65371d0c62204f92068ee6d3f4c71d70866.png)

#### 25. Spoofing of Destination Data Store Configuration Files  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Configuration Files may be spoofed
                                      by an attacker and this may lead to
                                      data being written to the
                                      attacker's target instead of
                                      Configuration Files. Consider using
                                      a standard authentication mechanism
                                      to identify the destination data
                                      store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Configuration files are used to
                                      seed EdgeX configuration service
                                      (Consul) before the services are
                                      started. Configuration files are
                                      made part of the service container
                                      (deployed with the container
                                      image). The only way to spoof the
                                      file is to replace the entire
                                      service container with new
                                      configuration or to transplant new
                                      configuration in the container -
                                      both require privileaged access to
                                      the host.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

#### 26. Potential Excessive Resource Consumption for EdgeX Foundry or Configuration Files  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Does EdgeX Foundry or Configuration
                                      Files take explicit steps to
                                      control resource consumption?
                                      Resource consumption attacks can be
                                      hard to deal with, and there are
                                      times that it makes sense to let
                                      the OS do the job. Be careful that
                                      your resource requests don't
                                      deadlock, and that they do timeout.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Config file does not consume
                                      resources other than file space.
                                      Configuration file is deployed with
                                      the service container and
                                      therefore, without access to the
                                      host and Docker, its size is
                                      controlled.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

### Interaction: request

![request interaction
screenshot](./images/3a355c928ca913b55d05ee7d9b020d0b4b92c818.png)

#### 27. Weakness in SSO Authorization  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------------------------------------------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    Common SSO implementations such as OAUTH2 and OAUTH Wrap are vulnerable to MitM attacks.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            In EdgeX, Kong is configured to use JWT token authentication. OAUTH2 and OAUTH are not allowed as of EdgeX 2.0
                                      (Ireland release - see
                                      https://docs.edgexfoundry.org/2.3/security/Ch-APIGateway/#configuration-of-jwt-authentication-for-api-gateway).
                                      JWT token expires in one hour by default.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------------------------------------------------------------------------------------

### Interaction: request

![request interaction
screenshot](./images/95f08360c41330542faa2c7a1ea36c0f19b926f7.png)

#### 28. Elevation Using Impersonation  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    EdgeX Foundry may be able to
                                      impersonate the context of Kong in
                                      order to gain additional privilege.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Impersonating EdgeX would require
                                      access to the host system and the
                                      Docker network. With this access,
                                      many other severe issues could
                                      occur (stopping the system, sending
                                      incorrect data, etc.).

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 29. Spoofing the Kong External Entity  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Kong may be spoofed by an attacker
                                      and this may lead to unauthorized
                                      access to EdgeX Foundry. Consider
                                      using a standard authentication
                                      mechanism to identify the external
                                      entity.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            If someone was able to provide a
                                      container that was spoofing as
                                      Kong, the service would not know
                                      that the response came from
                                      something other than Kong. However,
                                      Kong is run as a container on the
                                      EdgeX Docker network.
                                      Replacing/spoofing the Kong
                                      container would require privileaged
                                      (root) access to the host.
                                      Additional adopter mitigation would
                                      include putting TLS in place
                                      between EdgeX and Kong (with TLS
                                      cert in place). A spoofing service
                                      (in this case Kong), would not have
                                      the appropriate cert in place to
                                      participate in the communications.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

### Interaction: request

![request interaction
screenshot](./images/2d2403398f35d117985163fde9f6f6ae0509c20b.png)

#### 30. Elevation by Changing the Execution Flow in EdgeX UI - Web Application  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    An attacker may pass data into
                                      EdgeX UI - Web Application in order
                                      to change the flow of program
                                      execution within EdgeX UI - Web
                                      Application to the attacker's
                                      choosing.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            In order to use the Web UI (with
                                      secure mode EdgeX), authentication
                                      required via Kong. With proper
                                      authentication, a rogue user could
                                      invoke commands, change the rules
                                      engine rules (and alter
                                      workkflows), stop services (and
                                      alter workflows), etc. - but these
                                      could then be accomplished directly
                                      with EdgeX. If the GUI is of
                                      extreme concern, it can be removed
                                      or turned off as it is a
                                      convenience mechanism and is not
                                      required for EdgeX operation.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 31. EdgeX UI - Web Application May be Subject to Elevation of Privilege Using Remote Code Execution  \[State: Needs Investigation\]  \[Priority: Medium\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    Browser/API Caller may be able to
                                      remotely execute code for EdgeX
                                      UI - Web Application.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Possible protections to be
                                      implemented: buffer overflow
                                      protection, sanitize user inputs,
                                      use of a firewall

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation Research needed
  ----------------------------------- -----------------------------------

#### 32. Elevation Using Impersonation  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    EdgeX UI - Web Application may be
                                      able to impersonate the context of
                                      Browser/API Caller in order to gain
                                      additional privilege.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            The Edge GUI is deployed as a
                                      container part of the EdgeX
                                      application set. Impersonation of
                                      Web Application would require
                                      access to the host (with privilege)
                                      and require changing or removing
                                      the existing GUI Web application.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 33. Data Flow request Is Potentially Interrupted  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- ----------------------------------------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data flowing across a trust boundary in either
                                      direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            While a DoS on the GUI is possible (its endpoint is accessible on the Docker
                                      network), the GUI would not prevent the critical work of EdgeX from continuing.
                                      Kong prevents unauthorized access beyond the GUI. Kong can also be used to
                                      throttle requests coming from the GUI or other caller (see
                                      https://keyvatech.com/2019/12/03/secure-your-business-critical-apps-with-kong/).
                                      Other mechisms exist to work with EdgeX (such as the service APIs). The GUI is a
                                      convenience. It can be removed if a high risk target without affect to the rest of
                                      EdgeX.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- ----------------------------------------------------------------------------------

#### 34. Potential Process Crash or Stop for EdgeX UI - Web Application  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    EdgeX UI - Web Application crashes,
                                      halts, stops or runs slowly; in all
                                      cases violating an availability
                                      metric.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            While a DoS on the GUI is possible
                                      (its endpoint is accessible on the
                                      Docker network), the GUI would not
                                      prevent the critical work of EdgeX
                                      from continuing. Kong prevents
                                      unauthorized access beyond the GUI.
                                      Other mechisms exist to work with
                                      EdgeX (such as the service APIs).
                                      As another EdgeX, stopping the
                                      service requires host access (and
                                      access to the Docker engine, Docker
                                      containers and Docker network) with
                                      eleveated privileges. The GUI
                                      service can be removed for extra
                                      security. The GUI is a convenience.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 35. Data Flow Sniffing  \[State: Mitigation Implemented\]  \[Priority: Medium\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Data flowing across request may be
                                      sniffed by an attacker. Depending
                                      on what type of data an attacker
                                      can read, it may be used to attack
                                      other parts of the system or simply
                                      be a disclosure of information
                                      leading to compliance violations.
                                      Consider encrypting the data flow.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Use of a VPN or HTTPS can be used
                                      to secure the communications with
                                      the EdgeX UI.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 36. Potential Data Repudiation by EdgeX UI - Web Application  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    EdgeX UI - Web Application claims
                                      that it did not receive data from a
                                      source outside the trust boundary.
                                      Consider using logging or auditing
                                      to record the source, time, and
                                      summary of the received data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            The Web UI can use elevated
                                      logging, but if it did not see a
                                      request from a browser or API
                                      caller like Postman, then nothing
                                      gets issued to EdgeX.

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 37. Cross Site Scripting  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Tampering

  **Description:**                    The web server 'EdgeX UI - Web
                                      Application' could be a subject to
                                      a cross-site scripting attack
                                      because it does not sanitize
                                      untrusted input.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            X-XSS-Protection is enabled on all
                                      pages to protect against detected
                                      XSS. In environments where cross
                                      site scripting is a huge concern,
                                      the EdgeX UI Web application can be
                                      removed with no effect to the rest
                                      of the system. The UI is offered as
                                      a convenience.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 38. Potential Lack of Input Validation for EdgeX UI - Web Application  \[State: Needs Investigation\]  \[Priority: Medium\] 

  ----------------------------------- ------------------------------------------------------------------------------------------------------
  **Category:**                       Tampering

  **Description:**                    Data flowing across request may be tampered with by an attacker. This may lead to a denial of service
                                      attack against EdgeX UI - Web Application or an elevation of privilege attack against EdgeX UI - Web
                                      Application or an information disclosure by EdgeX UI - Web Application. Failure to verify that input
                                      is as expected is a root cause of a very large number of exploitable issues. Consider all paths and
                                      the way they handle data. Verify that all input is verified for correctness using an approved list
                                      input validation approach.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Input validation should be added to the GUI. However, access to the Web GUI (and then EdgeX) requires
                                      the API gateway token (see
                                      https://docs.edgexfoundry.org/2.2/getting-started/tools/Ch-GUI/#secure-mode-with-api-gateway-token).
                                      If this threat is likely, the Web GUI can be removed as this does not impact the remainder of EdgeX
                                      operations.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation Research needed
  ----------------------------------- ------------------------------------------------------------------------------------------------------

#### 39. Spoofing the Browser/API Caller External Entity  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Browser/API Caller may be spoofed
                                      by an attacker and this may lead to
                                      unauthorized access to EdgeX UI -
                                      Web Application. Consider using a
                                      standard authentication mechanism
                                      to identify the external entity.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Spoofing as the browser or any tool
                                      or system of EdgeX is immaterial.
                                      Any browser or API tool like
                                      Postman would need to request
                                      access using the API gateway token.
                                      With the token, they are considered
                                      a legitimate user of EdgeX.

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 40. Spoofing the EdgeX UI - Web Application Process  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    EdgeX UI - Web Application may be
                                      spoofed by an attacker and this may
                                      lead to information disclosure by
                                      Browser/API Caller. Consider using
                                      a standard authentication mechanism
                                      to identify the destination
                                      process.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As one of the services deployed as
                                      a container of EdgeX, spoofing of
                                      EdgeX GUI would require either
                                      replacing the container (requiring
                                      host access and elevated
                                      privileges) and/or intercepting and
                                      rerouting traffic. Further, the GUI
                                      must obtain and use a Kong JWT
                                      token to access the EdgeX APIs
                                      which a spoofer would not have.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

### Interaction: request

![request interaction
screenshot](./images/576e433e8eb5796c68f2bb91390ebbc998db0789.png)

#### 41. Weakness in SSO Authorization  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------------------------------------------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    Common SSO implementations such as OAUTH2 and OAUTH Wrap are vulnerable to MitM attacks.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            In EdgeX, Kong is configured to use JWT token authentication. OAUTH2 and OAUTH are not allowed as of EdgeX 2.0
                                      (Ireland release - see
                                      https://docs.edgexfoundry.org/2.3/security/Ch-APIGateway/#configuration-of-jwt-authentication-for-api-gateway).
                                      JWT token expires in one hour by default.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------------------------------------------------------------------------------------

#### 42. Data Flow request Is Potentially Interrupted  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- --------------------------------------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data flowing across a trust boundary in either
                                      direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Kong can be configured to throttle requests to prevent a DoS attack. See
                                      https://keyvatech.com/2019/12/03/secure-your-business-critical-apps-with-kong/

  **Mitigator:**                      Third Party

  **Mitigation Status:**              Mitigation written
  ----------------------------------- --------------------------------------------------------------------------------

#### 43. External Entity Kong Potentially Denies Receiving Data  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    Kong claims that it did not receive
                                      data from a process on the other
                                      side of the trust boundary.
                                      Consider using logging or auditing
                                      to record the source, time, and
                                      summary of the received data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Kong provides logging, but if it
                                      did not see a request from a
                                      browser or API caller like Postman,
                                      then nothing gets issued to EdgeX.

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

### Interaction: response

![response interaction
screenshot](./images/8c77b80e96a413e27bfd5ddc1bb8004ee0f78e8e.png)

#### 44. Weakness in SSO Authorization  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------------------------------------------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    Common SSO implementations such as OAUTH2 and OAUTH Wrap are vulnerable to MitM attacks.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            In EdgeX, Kong is configured to use JWT token authentication. OAUTH2 and OAUTH are not allowed as of EdgeX 2.0
                                      (Ireland release - see
                                      https://docs.edgexfoundry.org/2.3/security/Ch-APIGateway/#configuration-of-jwt-authentication-for-api-gateway).
                                      JWT token expires in one hour by default.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------------------------------------------------------------------------------------

### Interaction: response

![response interaction
screenshot](./images/0658b8e643ba5473ac137acd8ab3f864a33f21da.png)

#### 45. Spoofing the Kong External Entity  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Kong may be spoofed by an attacker
                                      and this may lead to unauthorized
                                      access to EdgeX UI - Web
                                      Application. Consider using a
                                      standard authentication mechanism
                                      to identify the external entity.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Kong is run as a container on the
                                      EdgeX Docker network.
                                      Replacing/spoofing Kong would
                                      require privileaged access to the
                                      host.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 46. Cross Site Scripting  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Tampering

  **Description:**                    The web server 'EdgeX UI - Web
                                      Application' could be a subject to
                                      a cross-site scripting attack
                                      because it does not sanitize
                                      untrusted input.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Because the Web application is
                                      running as a container on the
                                      Docker network with Kong, access to
                                      the response traffic via Kong would
                                      require access to the Docker
                                      network (requiring access to the
                                      host with elevated privilege). The
                                      EdgeX Web GUI has X-XSS-Protection
                                      enabled. In environments where
                                      cross site scripting is a concern,
                                      the EdgeX UI Web application can be
                                      removed with no effect to the rest
                                      of the system. The UI is offered as
                                      a convenience.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 47. Elevation Using Impersonation  \[State: Mitigation Implemented\]  \[Priority: Medium\] 

  ----------------------------------- ------------------------------------------------------------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    EdgeX UI - Web Application may be able to impersonate the context of Kong in order to gain additional
                                      privilege.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            The Web GUI must authenticate with Kong using a JWT token (see
                                      https://docs.edgexfoundry.org/2.2/getting-started/tools/Ch-GUI/#secure-mode-with-api-gateway-token).
                                      Without the proper JWT token access, the Web GUI cannot get eleveated privilege to EdgeX as a whole.
                                      An impersonating Web GUI might be used to have a user provide their JWT token which could be used to
                                      then perform other operations in EdgeX. If this is a real threat, the GUI can be removed and not used
                                      without other impacts to EdgeX. The GUI is a convenience tool.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- ------------------------------------------------------------------------------------------------------

### Interaction: response

![response interaction
screenshot](./images/991c32e446da35cd1c0b0af70650326cea128e8b.png)

#### 48. Data Flow response Is Potentially Interrupted  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- ----------------------------------------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data flowing across a trust boundary in either
                                      direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            While a DoS on the GUI is possible (its endpoint is accessible on the Docker
                                      network), the GUI would not prevent the critical work of EdgeX from continuing.
                                      Kong prevents unauthorized access beyond the GUI. Kong can also be used to
                                      throttle requests coming from the GUI or other caller (see
                                      https://keyvatech.com/2019/12/03/secure-your-business-critical-apps-with-kong/).
                                      Other mechisms exist to work with EdgeX (such as the service APIs). The GUI is a
                                      convenience. It can be removed if a high risk target without affect to the rest of
                                      EdgeX.

  **Mitigator:**                      Third Party

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- ----------------------------------------------------------------------------------

#### 49. External Entity Browser/API Caller Potentially Denies Receiving Data  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    Browser/API Caller claims that it
                                      did not receive data from a process
                                      on the other side of the trust
                                      boundary. Consider using logging or
                                      auditing to record the source,
                                      time, and summary of the received
                                      data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            The Web GUI can use elevated log
                                      level to log all requests.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 50. Spoofing of the Browser/API Caller External Destination Entity  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Browser/API Caller may be spoofed
                                      by an attacker and this may lead to
                                      data being sent to the attacker's
                                      target instead of Browser/API
                                      Caller. Consider using a standard
                                      authentication mechanism to
                                      identify the external entity.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Spoofing as the browser or any tool
                                      or system of EdgeX is immaterial.
                                      Any browser or API tool like
                                      Postman would need to request
                                      access using the API gateway token.
                                      With the token, they are considered
                                      a legitimate user of EdgeX.

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

### Interaction: response

![response interaction
screenshot](./images/576e433e8eb5796c68f2bb91390ebbc998db0789.png)

#### 51. Data Flow response Is Potentially Interrupted  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- --------------------------------------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data flowing across a trust boundary in either
                                      direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Kong can be configured to throttle requests to prevent a DoS attack. See
                                      https://keyvatech.com/2019/12/03/secure-your-business-critical-apps-with-kong/

  **Mitigator:**                      Third Party

  **Mitigation Status:**              Mitigation written
  ----------------------------------- --------------------------------------------------------------------------------

#### 52. External Entity Browser/API Caller Potentially Denies Receiving Data  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    Browser/API Caller claims that it
                                      did not receive data from a process
                                      on the other side of the trust
                                      boundary. Consider using logging or
                                      auditing to record the source,
                                      time, and summary of the received
                                      data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Kong provides logging to document
                                      all requests.

  **Mitigator:**                      Third Party

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

### Interaction: sensor data

![sensor data interaction
screenshot](./images/45202e3bd894b0bc778d85fa97f7ccc8758cc962.png)

#### 53. Spoofing the EdgeX Foundry Process  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    EdgeX Foundry may be spoofed by an
                                      attacker and this may lead to
                                      information disclosure by
                                      Device/Sensor. Consider using a
                                      standard authentication mechanism
                                      to identify the destination
                                      process.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Spoofing all of EdgeX would require
                                      either replacing all of EdgeX
                                      containers and network (requiring
                                      host access and elevated
                                      privileges) or intercepting and
                                      rerouting traffic.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 54. Spoofing of Source Data Store Device/Sensor  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Spoofing

  **Description:**                    Device/Sensor may be spoofed by an attacker and
                                      this may lead to incorrect data delivered to
                                      EdgeX Foundry. Consider using a standard
                                      authentication mechanism to identify the source
                                      data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Due to the nature of many protocols, an outside
                                      agent could spoof as a ligitimage device/sensor.
                                      This is of particular concern if the device
                                      service auto provisions the devices/sensors
                                      without any authentication. Auto provisioning
                                      shold be limited to pick up trusted devices.
                                      Protocols such as BACnet do allow for
                                      authentication with the device/sensor. In this
                                      case, the device service should be written to use
                                      proper authentication. Commercial 3rd party
                                      software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation Research needed
  ----------------------------------- -------------------------------------------------

#### 55. Potential Data Repudiation by EdgeX Foundry  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    EdgeX Foundry claims that it did
                                      not receive data from a source
                                      outside the trust boundary.
                                      Consider using logging or auditing
                                      to record the source, time, and
                                      summary of the received data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Use of elevated log level can be
                                      used to log all data communications
                                      for any EdgeX service.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 56. Weak Access Control for a Resource  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Improper data protection of
                                      Device/Sensor can allow an attacker
                                      to read information not intended
                                      for disclosure. Review
                                      authorization settings.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            In some cases (such as BACNet), the
                                      communications between EdgeX and
                                      the device/sensor can be secured
                                      (ex: secured BACNet). Otherwise, it
                                      is up to the device service
                                      implementer to either secure the
                                      communications (if possible) or
                                      mitigate the danger by making sure
                                      the incoming data conforms to
                                      expectations.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 57. Potential Process Crash or Stop for EdgeX Foundry  \[State: Mitigation Implemented\]  \[Priority: Medium\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    EdgeX Foundry crashes, halts, stops
                                      or runs slowly; in all cases
                                      violating an availability metric.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Stopping EdgeX services requires
                                      host access (and access to the
                                      Docker engine, Docker containers
                                      and Docker network) with eleveated
                                      privileges or access to the EdgeX
                                      system management APIs (requiring
                                      the Kong JWT token). The system
                                      management service can be removed
                                      for extra security.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 58. Data Flow sensor data Is Potentially Interrupted  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data flowing across
                                      a trust boundary in either direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device is one of
                                      the biggest threats to an edge system and one of
                                      the hardest to mitigate. If tampered with, a
                                      sensor or device could be used to send the wrong
                                      data (e.g., force a temp sensor to send a signal
                                      that it is too hot when it is really too cold),
                                      too much data (overwhelming the edge system by
                                      causing the sensor to send data too often), or
                                      not enough data (e.g., disconnecting a critical
                                      monitor sensor that would cause a system to
                                      stop). The device service can be constructed to
                                      filter data to avoid the "too much" data DoS. The
                                      device service can be constructed to report and
                                      alert when there is not enough data coming from
                                      the device or sensor or the sensor/device appears
                                      to be offline (provided by the last connected
                                      tracking in EdgeX). Wrong data can be mitigated
                                      by having the device service look for expected
                                      ranges of values (as supported by min/max
                                      attributes on device profiles). Commercial 3rd
                                      party software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------

#### 59. Data Store Inaccessible  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent prevents access to a data store
                                      on the other side of the trust boundary.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device is one of
                                      the biggest threats to an edge system and one of
                                      the hardest to mitigate. If tampered with, a
                                      sensor or device could be used to send the wrong
                                      data (e.g., force a temp sensor to send a signal
                                      that it is too hot when it is really too cold),
                                      too much data (overwhelming the edge system by
                                      causing the sensor to send data too often), or
                                      not enough data (e.g., disconnecting a critical
                                      monitor sensor that would cause a system to
                                      stop). The device service can be constructed to
                                      filter data to avoid the "too much" data DoS. The
                                      device service can be constructed to report and
                                      alert when there is not enough data coming from
                                      the device or sensor or the sensor/device appears
                                      to be offline (provided by the last connected
                                      tracking in EdgeX). Wrong data can be mitigated
                                      by having the device service look for expected
                                      ranges of values (as supported by min/max
                                      attributes on device profiles). Commercial 3rd
                                      party software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------

#### 60. EdgeX Foundry May be Subject to Elevation of Privilege Using Remote Code Execution  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    Device/Sensor may be able to
                                      remotely execute code for EdgeX
                                      Foundry.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            EdgeX does not execute random code
                                      based on input from a device or
                                      sensor (as if it was from a web
                                      application with something like
                                      unsanitized inputs). All data is
                                      santized by extracting expected
                                      data values from the sensor input
                                      data, creating an EdgeX
                                      event/reading message and sending
                                      that into the rest of EdgeX. The
                                      data coming from a sensor could be
                                      used to kill the service (ex:
                                      buffer overflow attack and sending
                                      too much data for the service to
                                      consume for example - see DoS
                                      threats). The device service in
                                      EdgeX can be written to reject to
                                      large of a request (for example).
                                      In some cases, a protocol may offer
                                      dual authentication, and if used,
                                      help to mitigate RCE

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 61. Elevation by Changing the Execution Flow in EdgeX Foundry  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    An attacker may pass data into EdgeX Foundry in
                                      order to change the flow of program execution
                                      within EdgeX Foundry to the attacker's choosing.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device is one of
                                      the biggest threats to an edge system and one of
                                      the hardest to mitigate. If tampered with, a
                                      sensor or device could be used to send the wrong
                                      data (e.g., force a temp sensor to send a signal
                                      that it is too hot when it is really too cold),
                                      too much data (overwhelming the edge system by
                                      causing the sensor to send data too often), or
                                      not enough data (e.g., disconnecting a critical
                                      monitor sensor that would cause a system to
                                      stop). The device service can be constructed to
                                      filter data to avoid the "too much" data DoS. The
                                      device service can be constructed to report and
                                      alert when there is not enough data coming from
                                      the device or sensor or the sensor/device appears
                                      to be offline (provided by the last connected
                                      tracking in EdgeX). Wrong data can be mitigated
                                      by having the device service look for expected
                                      ranges of values (as supported by min/max
                                      attributes on device profiles). Commercial 3rd
                                      party software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------

### Interaction: sensor data

![sensor data interaction
screenshot](./images/90275c0fd866ee831f1791f0fe94207138f563fe.png)

#### 62. External Entity Megaservice - Cloud or Enterprise Potentially Denies Receiving Data  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    Megaservice - Cloud or Enterprise
                                      claims that it did not receive data
                                      from a process on the other side of
                                      the trust boundary. Consider using
                                      logging or auditing to record the
                                      source, time, and summary of the
                                      received data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Application services can use
                                      elevated log level to log all
                                      exports.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 63. Spoofing of the Megaservice - Cloud or Enterprise External Destination Entity  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Megaservice - Cloud or Enterprise
                                      may be spoofed by an attacker and
                                      this may lead to data being sent to
                                      the attacker's target instead of
                                      Megaservice - Cloud or Enterprise.
                                      Consider using a standard
                                      authentication mechanism to
                                      identify the external entity.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Spoofing as the browser or any tool
                                      or system of EdgeX is immaterial.
                                      Any browser or API tool like
                                      Postman would need to request
                                      access using the API gateway token.
                                      With the token, they are considered
                                      a legitimate user of EdgeX. In the
                                      case of a megacloud or enterprise,
                                      most communication is from EdgeX to
                                      that system vs sending requests to
                                      EdgeX (as an export)

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 64. Data Flow sensor data Is Potentially Interrupted  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data
                                      flowing across a trust boundary in
                                      either direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Data flow is in one direction
                                      (exporting from EdgeX to the
                                      cloud). If the data is deemed
                                      critical and if by some means the
                                      data flow was interrupted, then
                                      store and forward mechisms in EdgeX
                                      allow the data to be sent once the
                                      communications are re-established.
                                      If using MQTT, the quality of
                                      service (QoS) setting on a message
                                      broker can also be used to ensure
                                      all data is delivered or it is
                                      resent later.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

### Interaction: sensor data

![sensor data interaction
screenshot](./images/d49eafc75d4d780a7092b7c1d9a3df82cf18b9c9.png)

#### 65. Data Flow sensor data Is Potentially Interrupted  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data
                                      flowing across a trust boundary in
                                      either direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Data flow is in one direction
                                      (exporting from EdgeX to the
                                      external message bus). If the data
                                      is deemed critical and if by some
                                      means the data flow was
                                      interrupted, store and forward
                                      mechisms in EdgeX allow the data to
                                      be sent once the communications are
                                      re-established. If using MQTT, the
                                      quality of service (QoS) setting on
                                      a message broker can also be used
                                      to ensure all data is delivered or
                                      it is resent later.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 66. External Entity Message Topic Potentially Denies Receiving Data  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    Message Topic claims that it did
                                      not receive data from a process on
                                      the other side of the trust
                                      boundary. Consider using logging or
                                      auditing to record the source,
                                      time, and summary of the received
                                      data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Application services can use
                                      elevated log level to log all
                                      exports.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 67. Spoofing of the Message Topic External Destination Entity  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Message Topic may be spoofed by an
                                      attacker and this may lead to data
                                      being sent to the attacker's target
                                      instead of Message Topic. Consider
                                      using a standard authentication
                                      mechanism to identify the external
                                      entity.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Spoofing as the browser or any tool
                                      or system of EdgeX is immaterial.
                                      Any browser or API tool like
                                      Postman would need to request
                                      access using the API gateway token.
                                      With the token, they are considered
                                      a legitimate user of EdgeX. In the
                                      case of an external message bus,
                                      most communication is from EdgeX to
                                      that system vs sending requests to
                                      EdgeX (as an export).

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

### Interaction: service registration

![service registration interaction
screenshot](./images/07d84b7181df0567f94ffa3139a1017078073813.png)

#### 68. Spoofing of Destination Data Store Consul (registry)  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Consul (registry) may be spoofed by
                                      an attacker and this may lead to
                                      data being written to the
                                      attacker's target instead of Consul
                                      (registry). Consider using a
                                      standard authentication mechanism
                                      to identify the destination data
                                      store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            If someone was able to provide a
                                      container that was spoofing as
                                      Consul, the service would not know
                                      that the response came from
                                      something other than Consul.
                                      However, Consul is run as a
                                      container on the EdgeX Docker
                                      network. Replacing/spoofing the
                                      Consul container would require
                                      privileaged (root) access to the
                                      host. Additional adopter mitigation
                                      would include putting TLS in place
                                      between EdgeX and Consul (with TLS
                                      cert in place). A spoofing service
                                      (in this case Consul), would not
                                      have the appropriate cert in place
                                      to participate in the
                                      communications.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

#### 69. Potential Excessive Resource Consumption for EdgeX Foundry or Consul (registry)  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- ----------------------------------------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Does EdgeX Foundry or Consul (registry) take explicit steps to
                                      control resource consumption? Resource consumption attacks can
                                      be hard to deal with, and there are times that it makes sense to
                                      let the OS do the job. Be careful that your resource requests
                                      don't deadlock, and that they do timeout.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            EdgeX services and Consul run as containers in a Docker network
                                      that, by default with security on, does not allow direct access
                                      to the service APIs. During the process of Consul bootstrapping,
                                      the EdgeX security bootstrapper ensures that the Consul APIs and
                                      GUI cannot be accessed without an ACL token (see
                                      https://docs.edgexfoundry.org/2.2/security/Ch-Secure-Consul/).
                                      Therefore, using the Consul APIs to cause a DoS attack would
                                      require access tokens. A rogue authorized user or someone able
                                      to illegally get the Consul token could cause excess use of
                                      resources that cause the services or Consul down.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- ----------------------------------------------------------------

#### 70. Authenticated Data Flow Compromised  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- ------------------------------------------------------------------------------------------------------------------------------------
  **Category:**                       Tampering

  **Description:**                    An attacker can read or modify data transmitted over an authenticated dataflow.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            EdgeX containers communicate via a Docker network. A hacker would need to gain access to the host and have elevated privileages on
                                      the host to access the network traffic. If extra security is needed or if an adopter is running EdgeX services in a distributed
                                      environment (multiple hosts), then TLS or overlay network encryption can be used (see example:
                                      https://github.com/edgexfoundry/edgex-examples/tree/update-custom-trigger-multiple-pipelines/security/remote_devices/docker-swarm)

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- ------------------------------------------------------------------------------------------------------------------------------------

### Interaction: service secrets

![service secrets interaction
screenshot](./images/e7176a6f9f8c4c00ed2658a0e0aad5a56fc9b069.png)

#### 71. Weak Access Control for a Resource  \[State: Mitigation Implemented\]  \[Priority: Medium\] 

  ----------------------------------- -------------------------------------------------------------------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Improper data protection of Vault can allow an attacker to read information not intended
                                      for disclosure. Review authorization settings.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            The Vault root and service level tokens are revoked after setup and then all interactions
                                      is via the programmatic interface (with properly authenticated token). There are additional
                                      options to Vault Master Key encryption provided here:
                                      https://docs.edgexfoundry.org/2.2/threat-models/secret-store/vault_master_key_encryption/

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -------------------------------------------------------------------------------------------

#### 72. Spoofing of Source Data Store Vault  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Vault may be spoofed by an attacker
                                      and this may lead to incorrect data
                                      delivered to EdgeX Foundry.
                                      Consider using a standard
                                      authentication mechanism to
                                      identify the source data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            If someone was able to provide a
                                      container that was spoofing as
                                      Vault, the service would not know
                                      that the response came from
                                      something other than Vault.
                                      However, Vault is run as a
                                      container on the EdgeX Docker
                                      network. Replacing/spoofing the
                                      Vault container would require
                                      privileaged (root) access to the
                                      host. Additional adopter mitigation
                                      would include putting TLS in place
                                      between EdgeX and Vault (with TLS
                                      cert in place). A spoofing service
                                      (in this case Vault), would not
                                      have the appropriate cert in place
                                      to participate in the
                                      communications.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

### Interaction: subscribed message

![subscribed message interaction
screenshot](./images/0b90a0c293af117ac3ae56739d5422f5edfcf14f.png)

#### 73. Weak Access Control for a Resource  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -------------------------------------------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Improper data protection of Message Bus Broker can allow an
                                      attacker to read information not intended for disclosure. Review
                                      authorization settings.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            When running EdgeX in secure mode the Redis database service is
                                      secured with a username/password. Redis Pub/Sub utilizes the
                                      existing Redis database service so that no additional broker
                                      service is required. This in turn creates a Secure MessageBus. See
                                      https://docs.edgexfoundry.org/2.2/security/Ch-Secure-MessageBus/.
                                      MQTTS can used for internal message bus communications but not
                                      provided by EdgeX

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -------------------------------------------------------------------

#### 74. Spoofing of Source Data Store Message Bus Broker  \[State: Mitigation Implemented\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Message Bus Broker may be spoofed
                                      by an attacker and this may lead to
                                      incorrect data delivered to EdgeX
                                      Foundry. Consider using a standard
                                      authentication mechanism to
                                      identify the source data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            The message bus when requiring a
                                      broker (MQTT broker for example) is
                                      run as a container on the EdgeX
                                      Docker network. Replacing/spoofing
                                      the broker container would require
                                      privileaged access to the host.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation reviewed
  ----------------------------------- -----------------------------------

------------------------------------------------------------------------

## Diagram: EdgeX Service to Service HTTP comms

![EdgeX Service to Service HTTP comms diagram
screenshot](./images/1fff065c526b312244ec8ddd15d4a2788b2af39d.png)

### EdgeX Service to Service HTTP comms Diagram Summary:

  ------------------------ ---
  Not Started              0
  Not Applicable           0
  Needs Investigation      2
  Mitigation Implemented   0
  Total                    2
  Total Migrated           0
  ------------------------ ---

### Interaction: HTTP

![HTTP interaction
screenshot](./images/7c737a8daffe1b6aecfcbde9db603dc5ab70cf17.png)

#### 75. EdgeX Service A Process Memory Tampered  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------------------------------------------------------------------------------------------
  **Category:**                       Tampering

  **Description:**                    If EdgeX Service A is given access to memory, such as shared memory or pointers, or is given the ability to control what EdgeX
                                      Service B executes (for example, passing back a function pointer.), then EdgeX Service A can tamper with EdgeX Service B. Consider if
                                      the function could work with less access to memory, such as passing data rather than pointers. Copy in data provided, and then
                                      validate it.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            EdgeX services (like core and metadata) offer a REST API that communicate via a Docker network. Ports on the service are restricted
                                      except through Kong. A hacker would need to gain access to the host and have elevated privileages on the host to access the network
                                      traffic. If extra security is needed or if an adopter is running EdgeX services in a distributed environment (multiple hosts), then
                                      overlay network encryption can be used (see example:
                                      https://github.com/edgexfoundry/edgex-examples/tree/update-custom-trigger-multiple-pipelines/security/remote_devices/docker-swarm).
                                      Alternately, TLS can be used to encrypt all traffic.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------------------------------------------------------------------------------------------

#### 76. Elevation Using Impersonation  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------------------------------------------------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    EdgeX Service B may be able to impersonate the context of EdgeX Service A in order to gain additional privilege.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Impersonating another EdgeX service would require access to the host system and the Docker network. Ports to the service APIs is
                                      restricted except through Kong. If extra security is needed or if an adopter is running EdgeX services in a distributed environment
                                      (multiple hosts), then overlay network encryption can be used (see example:
                                      https://github.com/edgexfoundry/edgex-examples/tree/update-custom-trigger-multiple-pipelines/security/remote_devices/docker-swarm).
                                      Alternately, TLS can be used to encrypt all traffic.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

## Diagram: EdgeX Service to Service message bus comms

![EdgeX Service to Service message bus comms diagram
screenshot](./images/7fd90a3a832adaabe4d2baeddbf9664f474dfcc5.png)

### EdgeX Service to Service message bus comms Diagram Summary:

  ------------------------ ---
  Not Started              0
  Not Applicable           0
  Needs Investigation      0
  Mitigation Implemented   2
  Total                    2
  Total Migrated           0
  ------------------------ ---

### Interaction: message bus (MQTT, Redis Pub/Sub, NATS)

![message bus (MQTT, Redis Pub/Sub, NATS) interaction
screenshot](./images/b9973b14d0632faeeac9619d16f594f8ba37725d.png)

#### 77. Elevation Using Impersonation  \[State: Mitigation Implemented\]  \[Priority: Medium\] 

  ----------------------------------- -------------------------------------------------------------------------------------------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    EdgeX Service B may be able to impersonate the context of EdgeX Service A in order to gain additional privilege.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Impersonating another EdgeX service would require access to the host system and the Docker network. Ports to the service message bus
                                      is restricted to internal communications only. If extra security is needed or if an adopter is running EdgeX services in a
                                      distributed environment (multiple hosts), then overlay network encryption can be used (see example:
                                      https://github.com/edgexfoundry/edgex-examples/tree/update-custom-trigger-multiple-pipelines/security/remote_devices/docker-swarm).
                                      Alternately, secure MQTT (MQTTS) message bus communications can be used.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------------------------------------------------------------------------------------------

#### 78. EdgeX Service A Process Memory Tampered  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------------------------------------------------------------------------------------------
  **Category:**                       Tampering

  **Description:**                    If EdgeX Service A is given access to memory, such as shared memory or pointers, or is given the ability to control what EdgeX
                                      Service B executes (for example, passing back a function pointer.), then EdgeX Service A can tamper with EdgeX Service B. Consider if
                                      the function could work with less access to memory, such as passing data rather than pointers. Copy in data provided, and then
                                      validate it.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Many EdgeX services (like core command and device services) offer (or will offer as of Levski) a message bus interface (via Redis
                                      Pub/Sub, MQTT, etc.). These services communicate with oe another via messages on a Docker network. Message bus ports on the service
                                      are restricted to internal-only communications. A hacker would need to gain access to the host and have elevated privileages on the
                                      host to access the network traffic and make message bus calls on the network. If extra security is needed or if an adopter is running
                                      EdgeX services in a distributed environment (multiple hosts), then overlay network encryption can be used (see example:
                                      https://github.com/edgexfoundry/edgex-examples/tree/update-custom-trigger-multiple-pipelines/security/remote_devices/docker-swarm).
                                      Alternately, secure MQTT (MQTTS) message bus communications can be used.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

## Diagram: Access via VPN

![Access via VPN diagram
screenshot](./images/63fc23b40a738e784b3074d26cf79523c14bee7a.png)

### Access via VPN Diagram Summary:

  ------------------------ ---
  Not Started              0
  Not Applicable           0
  Needs Investigation      0
  Mitigation Implemented   0
  Total                    0
  Total Migrated           0
  ------------------------ ---

------------------------------------------------------------------------

## Diagram: Host Access

![Host Access diagram
screenshot](./images/823024f5475035426d1ebf5fa2bbe57770a424bb.png)

### Host Access Diagram Summary:

  ------------------------ ---
  Not Started              0
  Not Applicable           0
  Needs Investigation      0
  Mitigation Implemented   0
  Total                    0
  Total Migrated           0
  ------------------------ ---

------------------------------------------------------------------------

## Diagram: Open Port Protections

![Open Port Protections diagram
screenshot](./images/f73b4eb2d21b54e94ac6eb4c73ffbaea1641df2b.png)

### Open Port Protections Diagram Summary:

  ------------------------ ---
  Not Started              0
  Not Applicable           0
  Needs Investigation      0
  Mitigation Implemented   0
  Total                    0
  Total Migrated           0
  ------------------------ ---

------------------------------------------------------------------------

## Diagram: Device Protocol Threats - Modbus example

![Device Protocol Threats - Modbus example diagram
screenshot](./images/c08d88b37e006a9b9192e8e9ec9f04dce16f3cea.png)

### Device Protocol Threats - Modbus example Diagram Summary:

  ------------------------ ----
  Not Started              0
  Not Applicable           7
  Needs Investigation      9
  Mitigation Implemented   2
  Total                    18
  Total Migrated           0
  ------------------------ ----

### Interaction: Binary RTU (GET or SET)

![Binary RTU (GET or SET) interaction
screenshot](./images/4c10423b800e184f32fcbafaae84d29ca327d40f.png)

#### 79. Spoofing of Destination Data Store Modbus Device/Sensor  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Modbus Device/Sensor may be spoofed
                                      by an attacker and this may lead to
                                      data being written to the
                                      attacker's target instead of Modbus
                                      Device/Sensor. Consider using a
                                      standard authentication mechanism
                                      to identify the destination data
                                      store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As there are no means to secure
                                      Modbus communications via the
                                      protocol exchange, the Modbus
                                      device/sensor and its wired
                                      connection must be physically
                                      secured to insure no spoofing or
                                      unauthorized collection of data or
                                      actuation with the device.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 80. Potential Excessive Resource Consumption for Modbus Device Service or Modbus Device/Sensor  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Does Modbus Device Service or
                                      Modbus Device/Sensor take explicit
                                      steps to control resource
                                      consumption? Resource consumption
                                      attacks can be hard to deal with,
                                      and there are times that it makes
                                      sense to let the OS do the job. Be
                                      careful that your resource requests
                                      don't deadlock, and that they do
                                      timeout.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As an unprotected (physically)
                                      Modbus device/sensor can be used to
                                      create a DOS attack (sending too
                                      much data), or send
                                      erroneous/faulty data, or disrupted
                                      / cut off and thereofore not send
                                      any data, the device service must
                                      be written to monitor and thwart
                                      the flow of too much data, notify
                                      when data is outside of expected
                                      ranges and notify when it appears
                                      the device/sensor is no longer
                                      connected and reporting.
                                      Provisioning of the device using
                                      known or specific ranges of MAC
                                      addresses (or IP addresses if using
                                      Modbus TCP/IP), etc. can help
                                      onboarding with an unauthorized
                                      device.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 81. Spoofing the Modbus Device Service Process  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Modbus Device Service may be
                                      spoofed by an attacker and this may
                                      lead to unauthorized access to
                                      Modbus Device/Sensor. Consider
                                      using a standard authentication
                                      mechanism to identify the source
                                      process.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As the communication to a Modbus
                                      device / sensor is not
                                      authenticated/authorized by the
                                      Protocol, any service (any spoof)
                                      could appear to be the EdgeX device
                                      service and either get data from or
                                      (worse) actuate the device
                                      illegally. Given the nature of
                                      Modbus, the only way to protect
                                      against this threat is to
                                      physically secure the device and
                                      connectivity (wire).

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 82. The Modbus Device/Sensor Data Store Could Be Corrupted  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Tampering

  **Description:**                    Data flowing across Binary RTU (GET
                                      or SET) may be tampered with by an
                                      attacker. This may lead to
                                      corruption of Modbus Device/Sensor.
                                      Ensure the integrity of the data
                                      flow to the data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As the communication to a Modbus
                                      device / sensor is not
                                      authenticated/authorized by the
                                      protocol, the communication across
                                      the wire could be tampered with or
                                      shut off to cause DOS attacts or
                                      actuate the device illegally. Given
                                      the nature of Modbus, the only way
                                      to protect against this threat is
                                      to physically secure the device and
                                      connectivity (wire).

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 83. Data Store Denies Modbus Device/Sensor Potentially Writing Data  \[State: Not Applicable\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    Modbus Device/Sensor claims that it
                                      did not write data received from an
                                      entity on the other side of the
                                      trust boundary. Consider using
                                      logging or auditing to record the
                                      source, time, and summary of the
                                      received data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            It is unlikely that a Modbus
                                      device/sensor has a log to provide
                                      an audit of requests.

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 84. Data Flow Sniffing  \[State: Not Applicable\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Data flowing across Binary RTU (GET
                                      or SET) may be sniffed by an
                                      attacker. Depending on what type of
                                      data an attacker can read, it may
                                      be used to attack other parts of
                                      the system or simply be a
                                      disclosure of information leading
                                      to compliance violations. Consider
                                      encrypting the data flow.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As the communication to a Modbus
                                      device / sensor is not
                                      authenticated/authorized nor
                                      encrypted by the Protocol, any
                                      service (any spoof) could appear to
                                      be the EdgeX device service and
                                      either get data from or (worse)
                                      actuate the device illegally. Given
                                      the nature of Modbus, the only way
                                      to protect against this threat is
                                      to physically secure the device and
                                      connectivity (wire).

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 85. Weak Credential Transit  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Credentials on the wire are often
                                      subject to sniffing by an attacker.
                                      Are the credentials
                                      re-usable/re-playable? Are
                                      credentials included in a message?
                                      For example, sending a zip file
                                      with the password in the email. Use
                                      strong cryptography for the
                                      transmission of credentials. Use
                                      the OS libraries if at all
                                      possible, and consider
                                      cryptographic algorithm agility,
                                      rather than hardcoding a choice.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Modbus does not support any type of
                                      authentication/authorization in
                                      communications. Physical security
                                      of the device and wire are the only
                                      ways to thwart information
                                      disclosure.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 86. Data Flow Binary RTU (GET or SET) Is Potentially Interrupted  \[State: Not Applicable\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data
                                      flowing across a trust boundary in
                                      either direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As the communication to a Modbus
                                      device / sensor is not
                                      authenticated/authorized by the
                                      protocol, the communication across
                                      the wire could be tampered with or
                                      shut off to cause DOS attacts or
                                      actuate the device illegally. Given
                                      the nature of Modbus, the only way
                                      to protect against this threat is
                                      to physically secure the device and
                                      connectivity (wire).

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 87. Data Store Inaccessible  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent prevents access
                                      to a data store on the other side
                                      of the trust boundary.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As the communication to a Modbus
                                      device / sensor is not
                                      authenticated/authorized by the
                                      protocol, the communication across
                                      the wire could be tampered with to
                                      cause DOS attacts or actuate the
                                      device illegally. Given the nature
                                      of Modbus, the only way to protect
                                      against this threat is to
                                      physically secure the device and
                                      connectivity (wire).

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

### Interaction: Binary RTU Response (GET or SE

![Binary RTU Response (GET or SE interaction
screenshot](./images/2365df34bb3d0eae545edda1705cc56cbf3bdeac.png)

#### 88. Spoofing of Source Data Store Modbus Device/Sensor  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Modbus Device/Sensor may be spoofed
                                      by an attacker and this may lead to
                                      incorrect data delivered to Modbus
                                      Device Service. Consider using a
                                      standard authentication mechanism
                                      to identify the source data store.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As an unprotected (physically)
                                      Modbus device/sensor can be used to
                                      create a DOS attack (sending too
                                      much data), or send
                                      erroneous/faulty data, or disrupted
                                      / cut off and thereofore not send
                                      any data, the device service must
                                      be written to monitor and thwart
                                      the flow of too much data, notify
                                      when data is outside of expected
                                      ranges and notify when it appears
                                      the device/sensor is no longer
                                      connected and reporting.
                                      Provisioning of the device using
                                      known or specific ranges of MAC
                                      addresses (or IP addresses if using
                                      Modbus TCP/IP), etc. can help
                                      onboarding with an unauthorized
                                      device.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 89. Weak Access Control for a Resource  \[State: Not Applicable\]  \[Priority: Low\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Information Disclosure

  **Description:**                    Improper data protection of Modbus
                                      Device/Sensor can allow an attacker
                                      to read information not intended
                                      for disclosure. Review
                                      authorization settings.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As Modbus is a simple protocol
                                      (reporting data or reacting to
                                      accuation requests), it is not
                                      possible for the device or sensor
                                      to gain other data from the device
                                      service (or EdgeX as a whole).

  **Mitigator:**                      No mitigation or not applicable

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 90. Spoofing the Modbus Device Service Process  \[State: Not Applicable\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Spoofing

  **Description:**                    Modbus Device Service may be
                                      spoofed by an attacker and this may
                                      lead to information disclosure by
                                      Modbus Device/Sensor. Consider
                                      using a standard authentication
                                      mechanism to identify the
                                      destination process.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As there are no means to secure
                                      Modbus communications via the
                                      protocol exchange, the Modbus
                                      device/sensor and its wired
                                      connection must be physically
                                      secured to insure no spoofing or
                                      unauthorized collection of data or
                                      actuation with the device.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 91. Potential Data Repudiation by Modbus Device Service  \[State: Mitigation Implemented\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Repudiation

  **Description:**                    Modbus Device Service claims that
                                      it did not receive data from a
                                      source outside the trust boundary.
                                      Consider using logging or auditing
                                      to record the source, time, and
                                      summary of the received data.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Use of elevated log level can be
                                      used to log all data communications
                                      from a device/sensor.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 92. Potential Process Crash or Stop for Modbus Device Service  \[State: Mitigation Implemented\]  \[Priority: Medium\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    Modbus Device Service crashes,
                                      halts, stops or runs slowly; in all
                                      cases violating an availability
                                      metric.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Stopping EdgeX services requires
                                      host access (and access to the
                                      Docker engine, Docker containers
                                      and Docker network) with eleveated
                                      privileges or access to the EdgeX
                                      system management APIs (requiring
                                      the Kong JWT token). The system
                                      management service can be removed
                                      for extra security.

  **Mitigator:**                      EdgeX Foundry

  **Mitigation Status:**              Mitigation written
  ----------------------------------- -----------------------------------

#### 93. Data Flow Binary RTU Response (GET or SET Is Potentially Interrupted  \[State: Not Applicable\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent interrupts data
                                      flowing across a trust boundary in
                                      either direction.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As the communication to a Modbus
                                      device / sensor is not
                                      authenticated/authorized by the
                                      protocol, the communication across
                                      the wire could be tampered with or
                                      shut off to cause DOS attacts or
                                      actuate the device illegally. Given
                                      the nature of Modbus, the only way
                                      to protect against this threat is
                                      to physically secure the device and
                                      connectivity (wire).

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 94. Data Store Inaccessible  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -----------------------------------
  **Category:**                       Denial Of Service

  **Description:**                    An external agent prevents access
                                      to a data store on the other side
                                      of the trust boundary.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            As the communication to a Modbus
                                      device / sensor is not
                                      authenticated/authorized by the
                                      protocol, the communication across
                                      the wire could be tampered with to
                                      cause DOS attacts or actuate the
                                      device illegally. Given the nature
                                      of Modbus, the only way to protect
                                      against this threat is to
                                      physically secure the device and
                                      connectivity (wire).

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -----------------------------------

#### 95. Modbus Device Service May be Subject to Elevation of Privilege Using Remote Code Execution  \[State: Needs Investigation\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    Modbus Device/Sensor may be able to remotely
                                      execute code for Modbus Device Service.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device is one of
                                      the biggest threats to an edge system and one of
                                      the hardest to mitigate. If tampered with, a
                                      sensor or device could be used to send the wrong
                                      data (e.g., force a temp sensor to send a signal
                                      that it is too hot when it is really too cold),
                                      too much data (overwhelming the edge system by
                                      causing the sensor to send data too often), or
                                      not enough data (e.g., disconnecting a critical
                                      monitor sensor that would cause a system to
                                      stop). The device service can be constructed to
                                      filter data to avoid the "too much" data DoS. The
                                      device service can be constructed to report and
                                      alert when there is not enough data coming from
                                      the device or sensor or the sensor/device appears
                                      to be offline (provided by the last connected
                                      tracking in EdgeX). Wrong data can be mitigated
                                      by having the device service look for expected
                                      ranges of values (as supported by min/max
                                      attributes on device profiles). Commercial 3rd
                                      party software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Mitigation Research needed
  ----------------------------------- -------------------------------------------------

#### 96. Elevation by Changing the Execution Flow in Modbus Device Service  \[State: Not Applicable\]  \[Priority: High\] 

  ----------------------------------- -------------------------------------------------
  **Category:**                       Elevation Of Privilege

  **Description:**                    An attacker may pass data into Modbus Device
                                      Service in order to change the flow of program
                                      execution within Modbus Device Service to the
                                      attacker's choosing.

  **Justification:**                  \<no mitigation provided\>

  **Possible Mitigation:**            Outside influence on a sensor or device is one of
                                      the biggest threats to an edge system and one of
                                      the hardest to mitigate. If tampered with, a
                                      sensor or device could be used to send the wrong
                                      data (e.g., force a temp sensor to send a signal
                                      that it is too hot when it is really too cold),
                                      too much data (overwhelming the edge system by
                                      causing the sensor to send data too often), or
                                      not enough data (e.g., disconnecting a critical
                                      monitor sensor that would cause a system to
                                      stop). The device service can be constructed to
                                      filter data to avoid the "too much" data DoS. The
                                      device service can be constructed to report and
                                      alert when there is not enough data coming from
                                      the device or sensor or the sensor/device appears
                                      to be offline (provided by the last connected
                                      tracking in EdgeX). Wrong data can be mitigated
                                      by having the device service look for expected
                                      ranges of values (as supported by min/max
                                      attributes on device profiles). Physical security
                                      of the sensor and communications (wire) offer the
                                      best hope to mitigate this threat. Commercial 3rd
                                      party software or extensions to EdgeX (see, for
                                      example, RSA's Netwitness IoT:
                                      https://www.netwitness.com/en-us/products/iot/)
                                      could be used to detect anomalous sensor/device
                                      communications and isolate the sensor from the
                                      system.

  **Mitigator:**                      Adopter

  **Mitigation Status:**              Cannot mitigate or not appilcable
  ----------------------------------- -------------------------------------------------
