
## Multi-Infrastructure (Cross-Cloud) Deployment
**Note:** DC/OS deployment across multiple regions is not officially supported yet as quoted:

> ... DC/OS does not currently support multiple region configurations. If you would like to experiment with multi-region configurations, this topic provides the setup recommendations and caveats ...

Multi-Infrastructure deployment resembles the [Multi-Region Deployment](https://docs.mesosphere.com/1.10/installing/high-availability/multi-region/), where nodes are running on different infrastructures
and cannot reach each other by their private IP addresses. Since DC/OS assumes nodes are running on the same infrastrcuture, the deployment script relies on the communication over private networks and thus
cannot support multi-infrastructure deployment out-of-the-box.

This tutorial discusses about the trick to "fool" the nodes by tweaking NAT rules and deploy DC/OS across multiple infrastructures. Here I assume the masters are running on the same infrastructure
and connect agents on different infrastructures to the masters to achieve multi-infrastructure deployment. I do this due to the following reasons: 1) to simplify the tutorial, since spreading masters across
infrastructures is similar as connecting agents on different infrastructures but just requires [DC/OS Advanced Installation](https://docs.mesosphere.com/1.10/installing/oss/custom/advanced/); 2) spreading
masters across infrastructures may cause performance issues due to high latency. Empirically masters can only tolerate up to ~10ms latency.

**Note:** This is only for experimental purposes and not yet tested towards production.

### 1. Deploy a Single-Infrastructure DC/OS Cluster
You can deploy the cluster via [GUI](https://docs.mesosphere.com/1.10/installing/oss/custom/gui/) or [CLI](https://docs.mesosphere.com/1.10/installing/oss/custom/cli/), or customize the deployment following
the [Advanced Installation](https://docs.mesosphere.com/1.10/installing/oss/custom/advanced/). In this tutorial, I use the GUI to deploy the DC/OS cluster following the DC/OS installation documentation.

### 2. Add Agents on Other Infrastructures
After the DC/OS cluster is deployed successfully, [backup the installer files](https://docs.mesosphere.com/1.10/installing/oss/custom/gui/#backup) on the bootstrap node. **Important:** these files
will be used for adding new agents to the cluster in the future, so keep it somewhere for future use.

To add a node as a agent, send the installer files to that node and [install the DC/OS agent](https://docs.mesosphere.com/1.10/administering-clusters/add-a-node/). It will install all the agent services on
the node. However, if the node is not running on the same infrastructure with the cluster, the installation is expected to fail as the node cannot reach the cluster by the private IP addresses. So you will
not see the new agent shown in the DC/OS dashboard at this moment.

### 3. Install NAT Rules Using `iptables`
Since we want the masters and agents to be able to reach each other using the private IP addresses even if they are not in the same private network, we need to map the private IP addresses to the public ones
and route the traffic accordingly. As a result, we want the nodes to "deem" that they communicate with each other via the private network, but the traffic is actually routed over the public network between agents
on different infrastructures. We can easily achieve this by adding NAT rules using `iptables` as following:

```bash
sudo iptables -t nat -A OUTPUT -d <private-ip-address> -j DNAT --to-destination <public-ip-address>
```

Verbally this rule says "modify the destination of packets to `<public-ip-address>` if their current destination matches `<private-ip-address>`". *This rule needs to be installed on any pair of nodes running on
different infrastructures*, so that they can communicate with each other using their private IP addresses. For instance, if there are nodes A, B and C running on 3 different infrastructures, each node needs to
install 2 NAT rules to route traffic properly to their peers on other infrastructures.

After installing these rules, if the agents are not shown in the DC/OS dashboard or in an "Unhealthy" status, restart the agents as below:
```bash
# restart private agent
sudo systemctl restart dcos-mesos-slave

# restart public agent
sudo systemctl restart dcos-mesos-slave-public
```

**Note:** Make sure you do Step 3 after Step 2, since some DC/OS components (*e.g.,* Spartan) also use `iptables` rules and will wipe out existing rules during the installation.

### References:
- [DC/OS Google User Group Discussion](https://groups.google.com/a/dcos.io/forum/#!topic/users/Xi1WKc3puJg)
- [DC/OS across Multiple Zones](https://docs.mesosphere.com/1.10/installing/high-availability/multi-zone/)
- [DC/OS across Multiple Regions](https://docs.mesosphere.com/1.10/installing/high-availability/multi-region/)
