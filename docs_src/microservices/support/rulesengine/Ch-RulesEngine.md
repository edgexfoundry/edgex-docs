# Rules Engine

![image](EdgeX_SupportingServicesRules.png)

## Deprecation Notice

Please note that the supporting rules engine service has been **deprecated with the Geneva release (v1.2)**.  With the Geneva release, EdgeX has formed a partnership with the [LF Edge eKuiper](https://www.emqx.io/products/kuiper) open source project and offers the [eKuiper Rules Engine](../eKuiper/Ch-eKuiper.md) as the reference implementation rules engine.  The EdgeX support rules engine  was Java-based and wrapped the open source [Drools rules engine](https://www.drools.org/).  This was the last of the EdgeX Java services to be replaced.

Starting with the Geneva release, by default, the EdgeX reference implementations (provided through the EdgeX Docker Compose files) will use eKuiper with a dedicated application service providing the data feed to the eKuiper engine.  The support rules engine is still available but users must find and uncomment the support rules engine in the Docker Compose file.

The Support Rules Engine will removed in a future release of EdgeX Foundry.

## Support Rules Engine Service Documentation

For information on the support rules engine service, see the Fuji release [rules engine service documentation](https://fuji-docs.edgexfoundry.org/Ch-RulesEngine.html).