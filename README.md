DC/OS Experiments
=================

## Deployment
- System requirements:
   - Docker on CentOS 7: https://docs.mesosphere.com/1.10/installing/oss/custom/system-requirements/install-docker-centos/
   - https://docs.mesosphere.com/1.10/installing/oss/custom/system-requirements/
- GUI deployment: https://docs.mesosphere.com/1.10/installing/oss/custom/gui/

## System Management:
- Add agent: https://docs.mesosphere.com/1.10/administering-clusters/add-a-node/
- Update agent: https://docs.mesosphere.com/1.10/administering-clusters/update-a-node/

## Service/Job Management

### Attribute-aware service placement

DC/OS allows users to pass in **Mesos constraints** to control service placement as Marathon does.

1. Label agent nodes using key-value pairs. Specifically, add `MESOS_ATTRIBUTES` to `/var/lib/dcos/mesos-slave-common` (needs to be created) on the specific agent node. An agent node can
be labeled with multiple key-value pairs separated by semicolons.

```bash
cat | sudo tee /var/lib/dcos/mesos-slave-common <<EOF
MESOS_ATTRIBUTES=foo:bar;alpha:beta
EOF
```

2. Restart the agent node (private agent in this example)
```
sudo systemctl kill -s SIGUSR1 dcos-mesos-slave && sudo systemctl stop dcos-mesos-slave
sudo systemctl daemon-reload
sudo rm -rf /var/lib/mesos/slave/meta/slaves/*
sudo systemctl start dcos-mesos-slave
```

3. Add constraint(s) to a service to dictate placement. The constraint usage can be found [here](https://docs.mesosphere.com/1.11/deploying-services/marathon-constraints/).
```json
{
  ...
  "constraints": [
    [ "alpha", "CLUSTER", "beta"]
  ],
  ...
}
```

**Note:** Only services with `slave_public` specified in the `acceptedResourceRoles` field will be deployed on public agent nodes regardless of the attributes associated with them. In order
to override this default constraint, we need to allow the services to be deployed on both public and private agent nodes by adding `acceptedResourceRoles` in the service request as following:

```json
{
  ...
  "acceptedResourceRoles": [ "slave_public", "*" ],
  ...
}

```

`slave_public` and `*` allow the service to be deployed on public and private agent nodes, respectively.


## Virtual Network ([Reference](https://docs.mesosphere.com/1.10/networking/virtual-networks/))

- **Features:**
    - No global IPAM (Yay!). IP address space is split into smaller subnets, which are distributed among agent nodes.
    - Gossip protocol implementation - [lashup](https://github.com/dcos/lashup)
- **Limitations:**
    - Mesos tasks will fail if exhausting IP addresses on an agent node and there is no API for detecting such exhaustion, *i.e.*, **services/jobs have to infer the exhaustion on their own**.
    - The virtual network name is limited to *13 characters*.
    - The addresses allocated to each agent node are equally divided for Mesos and Docker containers.
- How to delete a virtual network?
    - Delete `/var/lib/dcos/mesos/master/overlay_replicated_log` on Mesos master
    - Delete `IPMASQ` rules of `iptables`
- How to add/replace a virtual network?
    - Remove current virtual network if available
    - Specify the new virtual network in the `config.yaml` file and reinstall


## TO-DOs
- [x] GUI deployment on Chameleon
- [x] Attribute-aware service placement
- [x] Virtual network
- [x] Cross-Cloud deployment
- [ ] DC/OS custom scheduler
    - [ ] Acquire offers from DC/OS scheduler
- [ ] Advanced deployment: https://docs.mesosphere.com/1.10/installing/oss/custom/advanced/


