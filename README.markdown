#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with spark](#setup)
    * [What spark affects](#what-spark-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Spark in YARN cluster mode](#usage-yarn)
    * [Spark jar file optimization](#usage-jar-optimization)
    * [Add Spark History Server](#usage-history-server)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Module Parameters](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

<a name="overview"></a>
## Overview

Puppet module for deployment of Apache Spark.

<a name="module-description"></a>
## Module Description

This puppet module installs and setup Apache Spark cluster, optionally with security.

The standalone Apache Spark cluster is not supported yet (there are missing master and worker daemons here), only client is supported. But the YARN mode is working, so the full cluster submit (to Hadoop) is possible.

Supported are:

* Debian 7/wheezy: Cloudera distribution (tested with Hadoop 2.5.0)
* Ubuntu 14/trusty: Cloudera distribution (tested with Hadoop 2.5.0)

<a name="setup"></a>
## Setup

<a name="what-spark-affects"></a>
### What spark affects

* Packages: installs Spark packages as needed (core, python, history server, ...)
* Files modified:
 * */etc/spark/conf/spark-default.conf*
 *  */etc/default/spark*
 * */etc/profile.d/hadoop-spark.csh* (frontend)
 * */etc/profile.d/hadoop-spark.sh* (frontend)
* Permissions modified:
 * */etc/security/keytab/spark.service.keytab* (historyserver)
* Alternatives:
 * alternatives are used for */etc/spark/conf* in Cloudera
 * this module switches to the new alternative by default, so the Cloudera original configuration can be kept intact
* Services:
 * history server (when *spark::historyserver* or *spark::historyserver::service* included)
* Helper files:
 * */var/lib/hadoop-hdfs/.puppet-spark-\**

<a name="setup-requirements"></a>
### Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Hadoop repositories**
 * neither Cloudera nor Hortonworks repositories are configured in this module (for Cloudera you can find list and key files here: [http://archive.cloudera.com/cdh5/debian/wheezy/amd64/cdh/](http://archive.cloudera.com/cdh5/debian/wheezy/amd64/cdh/))
 * *java* is not installed by this module (*openjdk-7-jre-headless* is OK for Debian 7/wheezy)

* **No inter-node dependencies**: working HDFS is required before deploying of Spark History Server, dependency of Spark HDFS initialization on HDFS namenode is handled properly (if the class *spark::hdfs* is included on the HDF namenode, see example)

<a name="usage"></a>
## Usage

<a name="usage-yarn"></a>
### Spark in YARN cluster mode

Example of Apache Spark over Hadoop cluster. For simplicity one-machine Hadoop cluster is used (everything is on *$::fqdn*, replication factor 1).

    class{'hadoop':
      hdfs_hostname => $::fqdn,
      yarn_hostname => $::fqdn,
      slaves => [ $::fqdn ],
      frontends => [ $::fqdn ],
      realm => '',
      properties => {
        'dfs.replication' => 1,
      },
    }

    class{'spark':
      hdfs_hostname => $::fqdn,
    }

    node default {
      include stdlib

      include hadoop::namenode
      include hadoop::resourcemanager
      include hadoop::historyserver
      include hadoop::datanode
      include hadoop::nodemanager
      include hadoop::frontend

      include spark::frontend
      # should be collocated with hadoop::namenode
      include spark::hdfs
    }

Now you can submit spark jobs in the cluster mode:

    spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode cluster --master yarn /usr/lib/spark/lib/spark-examples-1.2.0-cdh5.3.1-hadoop2.5.0-cdh5.3.1.jar 10

<a name="usage-jar-optimization"></a>
### Spark jar file optimization

The *spark-assembly.jar* file is copied into HDFS on each job submit. It is possible to optimize this by copying it manually. Keep in mind the jar file needs to be refreshed on HDFS with each Spark SW update.

    ...

    class{'spark':
      hdfs_hostname => $::fqdn,
      jar_enable    => true,
    }

    ...

Copy the jar file after installation and deployment (superuser credentials are needed if security in Hadoop is enabled):

    hdfs dfs -put /usr/lib/spark/spark-assembly.jar /user/spark/share/lib/spark-assembly.jar

<a name="usage-history-server"></a>
### Add Spark History Server

Spark History server stores details about Spark jobs. It is provided by the class *spark::historyserver*. The parameter *historiserver\_hostname* needs to be also specified (replace *$::fqdn* by real hostname):

    ...
    class{'spark':
      ...
      historyserver_hostname => $::fqdn,
    }

    node default {
      ...
      include spark::historyserver
    }

<a name="reference"></a>
##Reference

<a name="classes"></a>
###Classes

* common:
 * config
 * postinstall
* **frontend** - Client
 * config
 * install
* init
* **hdfs** - HDFS initializations
* **historyserver** - History Server
 * config
 * install
 * service
* params

<a name="parameters"></a>
###Module Parameters

####`alternatives` (see params.pp)

Use alternatives to switch configuration. Use it only when supported (like with Cloudera).

####`hdfs_hostname` undef

HDFS hostname or defaultFS (for example: host:8020, haName, ...).

####`historyserver_hostname` undef

Spark History server hostname.

####`jar_enable` false

Configure Apache Spark to search Spark jar file in *$hdfs\_hostname/user/spark/share/lib/spark-assembly.jar*. The jar needs to be copied to HDFS manually after installation, and also manually updated after each Spark SW update:

    hdfs dfs -put /usr/lib/spark/spark-assembly.jar /user/spark/share/lib/spark-assembly.jar

####`yarn_enable` true

Enable YARN mode by default. This requires configured Hadoop using CESNET Hadoop puppet module.

<a name="limitations"></a>
## Limitations

Spark standalone cluster not supported (missing support master and worker daemons). But the YARN mode is working, so the full cluster submit (to Hadoop) is possible.

And Puppet 3.x and Ruby >= 1.9.x is required, thus following systems are not supported:

* RedHat/CentOS 6 and older
* Ubuntu 12/precise and older

<a name="development"></a>
## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-spark](https://github.com/MetaCenterCloudPuppet/cesnet-spark)
* Tests: [https://github.com/MetaCenterCloudPuppet/hadoop-tests](https://github.com/MetaCenterCloudPuppet/hadoop-tests)
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
