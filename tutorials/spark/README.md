
## Spark on DC/OS

### 1. Install
[This documentation](https://docs.mesosphere.com/1.7/usage/tutorials/spark/) walks through the process of installing Spark on DC/OS. However, there are two open issues
([mesosphere/spark-build#208](https://github.com/mesosphere/spark-build/issues/208), [mesosphere/spark-build#240](https://github.com/mesosphere/spark-build/issues/240)) that need to be taken care of.

#### 1.1 [Root privilege for initialization](https://github.com/mesosphere/spark-build/issues/208)
Spark service requires `root` privilege to initialize the service, but by default it runs as `nobody`. As a consequence,
it would incur `Permission denied` errors and fail the DC/OS health check. To address this issue, edit the service configuration and change user to `root` as below:

```json
...
  "service": {
    ...
    "user": "root",
    ...
  },
...
```

#### 1.2 [Proper DNS setup](https://github.com/mesosphere/spark-build/issues/240)
Spark requires the DC/OS nodes being able to find each other by their hostnames, therefore the DNS setup for the cluster must be correct so that the hostnames can be resolved to each node correctly. The
suggested approach is to set up a DNS service for the DC/OS cluster, which knows every node in the cluster. It can be added to the DC/OS configuration as below:

```yaml
...
resolvers:
- 192.168.0.2
- 8.8.8.8
- 8.8.4.4
...
```

A quick workaround is to add the "ip-hostname" mapping of the nodes to the `/etc/hosts` of every node in the cluster, so that they can reach each other by their hostnames.

#### 1.3 Re-install
Spark service needs to be **completely** uninstalled before being re-installed, otherwise the new installation will behave unexpectedly due to certain inconsistent states. In addition to invoke `dcos package uninstall spark` to uninstall Spark,
you also need to wipe out its footprints in DC/OS Zookeeper as it persists states there by default. Specifically, you need to do the following:
1) visit `http://<master-ip>/exhibitor` in the browser
2) click on `Explorer` tab
3) remove `spark_mesos_dispatcher` entry.


### 2. Run Spark Shell
[This documentation](https://docs.mesosphere.com/services/spark/v1.0.9-2.1.0-1/spark-shell/) introduces how to connect Spark shell to DC/OS Mesos. The documentation uses the private IP address of the Mesos leader master for connecting Spark shell.
Alternatively, you can use the Zookeeper endpoint of the Mesos master as below, which is more static.

```bash
./bin/spark-shell --master mesos://zk://zk-1.zk:2181,zk-2.zk:2181,zk-3.zk:2181,zk-4.zk:2181,zk-5.zk:2181/mesos \
                  --conf spark.mesos.executor.docker.image=mesosphere/spark:1.0.9-2.1.0-1-hadoop-2.6 \
                  --conf spark.mesos.executor.home=/opt/spark/dist
```
