
## [Apache Livy](https://livy.incubator.apache.org/) on DC/OS

### 1. Install
### 2. Configuration
### 3. *Gotchas*

#### 3.1 Use Spark executor Docker image
The default Livy installation assumes that Spark are installed on the Mesos agent, which can rarely be the case on a generic DC/OS cluster. As a consequence, if you create a Spark session without
specifying `spark.mesos.executor.docker.image`, Mesos will create LXC containers that load Spark libraries and executables from the Mesos agents they are running on, and raise errors due to missing
files. Instead, as shown in the code snippet below, you should point the new Spark session to a Docker image in which all the Spark libraries and executables (*e.g.*, pyspark, sparkR) are installed.
The docker image will be used to start Spark executor containers for running Spark tasks submitted to this session.

```python
import json
import requests

host = 'http://<livy-host>:8998'
data = {
  'kind': 'spark',
  'conf':{
    'spark.mesos.executor.docker.image': 'mesosphere/spark:1.0.9-2.1.0-1-hadoop-2.6',
    'spark.mesos.executor.home': '/opt/spark/dist',
  }
}
headers = {'Content-Type': 'application/json'}

# create a Spark session
r = requests.post(host + '/sessions', data=json.dumps(data), headers=headers)
print(r.json())
print(r.headers['location'])
```


#### 3.2 Keep Spark version consistent on Livy and Spark executors
Current Livy is built on top of `mesosphere/spark:1.0.9-2.1.0-1-hadoop-2.6`. **Make sure you are using the same Docker image for creating Spark sessions.**

Inconsistent versions of Spark running on Livy and the Spark executors will cause [compatibility issues](https://community.cloudera.com/t5/Advanced-Analytics-Apache-Spark/Spark-Standalone-error-local-class-incompatible-stream-classdesc/td-p/25909)
and fail Spark tasks.
