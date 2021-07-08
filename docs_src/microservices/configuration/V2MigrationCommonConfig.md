# V2 Migration of Common Configuration 

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 there have been many breaking changes made to the configuration for all services. 

This section describes how to migrate the configuration sections that are common to all services. This information only applies if you have existing 1.x configuration that you have modified and need to migrate, rather than use the new V2 version of the configuration and modify it as needed.  

## Writable

The `Writable` section has the new InsecureSecrets sub-section. All services need the following added so they can access the Database and/or MessageBus :

```toml
  [Writable.InsecureSecrets]
    [Writable.InsecureSecrets.DB]
    path = "redisdb"
      [Writable.InsecureSecrets.DB.Secrets]
      username = ""
      password = ""
```

## Logging

Remove the `[Logging]` section.

## Service

The service section is now common to all EdgeX services. The migration to this new version slightly differs for each class of service, i.e. Core/Support, Device or Application Service. The sub-sections below describe the migration for each class.

### Core/Support

For the Core/Support services the following changes are required:

1. Remove `BootTimeout `
2. Remove `Protocol `
3. Rename `CheckInterval ` to `HealthCheckInterval `
4. Rename `Timeout` to `RequestTimeout` and change value to be duration string. i.e `5000` changes to `5s`
5. Add `MaxRequestSize` with value of `0`
6. `Port` value changes to be in proper range for new port assignments. See Port Assignments (TBD) section for more details

### Device

For Device service the changes are the same as **Core/Support** above plus the following:

1. Remove `ConnectRetries`
2. Move  `EnableAsyncReadings` to be under the `[Device]` section
3. Move `AsyncBufferSize` to be under the `[Device]` section
4. Move `labels` to be under the `[Device]` section

### Application 

For Application services the changes are the same as **Core/Support** above plus the following:

1.  Remove `ReadMaxLimit`
2.  Remove `ClientMonitor`
3.  Add `ServerBindAddr = "" # if blank, uses default Go behavior https://golang.org/pkg/net/#Listen`
4.  Add `MaxResultCount` and set value to `0` 

## Databases

Remove the `Username` and  `Password`  settings 

## Registry

No changes

## Clients

The map key names have changed to uses the service key for each of the target services. Each client entry must be changed to use the appropriate service key as follows:

1. `CoreData` => `core-data`
2. `Metadata` => `core-metadata`
3. `Command` => `core-command`
4. `Notifications` => `support-notifications`
5. `Scheduler` => `support-scheduler`

Remove the ` [Clients.Logging]` section

## SecretStore

All service now require the `[SecretStore]` section. For those that did not have it previously add the following replacing `<service-key>` with the service's actual service key:

```
[SecretStore]
Type = 'vault'
Protocol = 'http'
Host = 'localhost'
Port = 8200
Path = '<service-key>/'
TokenFile = '/tmp/edgex/secrets/<service-key>/secrets-token.json'
RootCaCertPath = ''
ServerName = ''
  [SecretStore.Authentication]
  AuthType = 'X-Vault-Token'
```

For those service that previously had the `[SecretStore]` section, make the following changes replacing `<service-key>` with the service's actual service key:

1. Add the `Type = 'vault'` setting
2. Remove `AdditionalRetryAttempts `
3. Remove `RetryWaitPeriod`
4. Change `Protocol` value to be `'http' `
5. Change `Path` value to be  `'<service-key>/'`
6. Change `TokenFile` value to be `'/tmp/edgex/secrets/<service-key>/secrets-token.json'`
7. Change `RootCaCertPath ` value to be empty, i.e `''`
8. Change `ServerName` value to be empty, i.e `''`

