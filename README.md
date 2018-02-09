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

### Attribute-based service placement

DC/OS allows users to pass in **Mesos constraints** to control service placement as Marathon does.

1. Label agent nodes using key-value pairs. Specifically, add `MESOS_ATTRIBUTES` to `/var/lib/dcos/mesos-slave-common` (needs to be created) on the specific agent node. An agent node can
be labeled with multiple key-value pairs separated by semicolons.

```bash
# cat >> /var/lib/dcos/mesos-slave-common <<EOF
MESOS_ATTRIBUTES=foo:bar;alpha:beta
EOF
```

2. Restart the agent node (private agent in this example)
```
# systemctl kill -s SIGUSR1 dcos-mesos-slave && systemctl stop dcos-mesos-slave
# ⁠⁠sudo systemctl daemon-reload
# ⁠⁠⁠⁠sudo rm -rf /var/lib/mesos/slave/meta/slaves/*
# sudo systemctl start dcos-mesos-slave
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

## TO-DOs
- [x] GUI deployment on Chameleon
- [x] Attribute-based service placement
- [ ] Deeper understanding of DC/OS components and their inter-operations
- [ ] DC/OS API exploration
- [ ] Advanced deployment: https://docs.mesosphere.com/1.10/installing/oss/custom/advanced/


