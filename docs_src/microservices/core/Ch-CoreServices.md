# Core Services

![image](EdgeX_CoreServices.png)

Core services provide the intermediary between the [north and south sides](../../general/Definitions.md#south-and-north-side) of EdgeX.  As the name of these services implies, they are “core” to EdgeX functionality.  Core services is where the innate knowledge of “things” connected, sensor data collected, and EdgeX configuration resides.  Core consists of the following micro services:

- [Core data](./data/Ch-CoreData.md): a persistence repository and associated management service for data collected from south side objects.
- [Command](./command/Ch-Command.md): a service that facilitates and controls actuation requests from the north side to the south side.
- [Metadata](./metadata/Ch-Metadata.md): a repository and associated management service of metadata about the objects that are connected to EdgeX Foundry. Metadata provides the capability to provision new devices and pair them with their owning device services.
- [Registry and Configuration](../configuration/Ch-Configuration.md): provides other EdgeX Foundry micro services with information about associated services within the system and micro services configuration properties (i.e. - a repository of initialization values).
