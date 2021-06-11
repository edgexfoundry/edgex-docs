# Secure MessageBus

Starting with the Ireland release (2.0.0) the default `MessageBus` implementation used is `Redis Pub/Sub`. `Redis Pub/Sub` utilizes the existing `Redis` database service so that no additional broker service is required. When running in secure mode the `Redis` database service is secured with a username/password. This in turn creates a `Secure MessageBus`.

All the default services (Core Data, App Service Rules, Device Virtual, Kuiper, etc.) that utilize the `MessageBus` are configured out of the box to connect securely. 

Additional add-on services that require `Secure MessageBus` access (App and/or Device services) need to follow the steps outline in the section [Configure the API gateway access route for add-on service](Ch-Configuring-Add-On-Services.md#Configure-the-API-gateway-access-route-for-add-on-service) of [Configuring Add-On Services for Security](Ch-Configuring-Add-On-Services.md) documentation.

!!! Note
     `Secure MQTT MessageBus` capability does not exist . This will be a future enhancement.

