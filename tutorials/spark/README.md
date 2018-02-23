
## Spark on DC/OS

### 1. Installation
[This documentation](https://docs.mesosphere.com/1.7/usage/tutorials/spark/) walks through the process to install Spark on DC/OS. However, the certified Spark service used in this documentation has open bugs
([mesosphere/spark-build#208](https://github.com/mesosphere/spark-build/issues/208), [mesosphere/spark-build#240](https://github.com/mesosphere/spark-build/issues/240)) and would fail DC/OS health checks when being deployed.
Instead, we use the community version (**beta-spark**), which has the known issues fixed and could be installed without errors.

As identified in [mesosphere/spark-build#240](https://github.com/mesosphere/spark-build/issues/240), incorrect DNS setup may also fail Spark installation on DC/OS. To run the Spark service, it is required that **the hostname
of every node in the cluster can be resolved and the nodes can reach each other by their hostnames.** One way to do this is to add a DNS service that knows every node in the cluster to the DNS service list in the DC/OS configuration.
A simple workaround is to add the "IP-hostname" mappings to the `/etc/hosts` file of every node.
