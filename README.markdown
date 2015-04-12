#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with spark](#setup)
    * [What spark affects](#what-spark-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
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

This puppet module installs and setup Apache Spark cluster.

TODO: Standalone Apache Spark cluster not supported yet (there is missing master and history server here), only client is supported. But YARN mode is working, so full cluster submit (to Hadoop) is OK.

Supported are:

* Debian 7/wheezy: Cloudera distribution (tested with Hadoop 2.5.0)
* Ubuntu 14/trusty: Cloudera distribution (tested with Hadoop 2.5.0)

<a name="setup"></a>
## Setup

<a name="what-spark-affects"></a>
### What spark affects

* Packages: installs Spark packages (core, python for frontend, ...)
* Files modified:
 * */etc/spark/spark-default.conf* (*/etc/spark/conf/spark-default.conf* on Debian)
 * */etc/profile.d/hadoop-spark.csh* (frontend)
 * */etc/profile.d/hadoop-spark.sh* (frontend)
* Alternatives:
 * alternatives are used for */etc/spark/conf* in Cloudera
 * this module switches to the new alternative by default, so the Cloudera original configuration can be kept intact
* Services: TODO
* Helper files:
 * */var/lib/hadoop-hdfs/.puppet-spark-dir-created*

<a name="setup-requirements"></a>
### Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Hadoop repositories**
 * neither Cloudera nor Hortonworks repositories are configured in this module (for Cloudera you can find list and key files here: [http://archive.cloudera.com/cdh5/debian/wheezy/amd64/cdh/](http://archive.cloudera.com/cdh5/debian/wheezy/amd64/cdh/))
 * *java* is not installed by this module (*openjdk-7-jre-headless* is OK for Debian 7/wheezy)

* **No inter-node dependencies**: working HDFS namenode is required before deploing of Spark: set dependency of *spark::hdfs* on *hadoop::namenode::service* on the HDFS namenode

<a name="usage"></a>
## Usage

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
      include spark::hdfs

      Class['hadoop::namenode::service'] -> Class['spark::hdfs']
    }

Notice the *spark::hdfs**, which needs to be launched on the HDFS namenode and the dependency on *hadoop::namenode::service*.

Now you can submit spark jobs in the cluster mode:

    spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode cluster --master yarn /usr/lib/spark/lib/spark-examples-1.2.0-cdh5.3.1-hadoop2.5.0-cdh5.3.1.jar 10

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
* params

<a name="parameters"></a>
###Module Parameters

####`alternatives` (see params.pp)

Use alternatives to switch configuration. Use it only when supported (like with Cloudera).

####`hdfs_hostname` undef

HDFS hostname or defaultFS (for example: host:8020, haName, ...).

####`history_hostname` undef

TODO: not implemented yet Spark History server hostname.

####`jar_enable` false

Configure Apache Spark to search Spark jar file in *$hdfs\_hostname/user/spark/share/lib/spark-assembly.jar*. The jar needs to be copied to HDFS manually, or also manually updated after each Spark SW update.

<a name="limitations"></a>
## Limitations

This is where you list OS compatibility, version compatibility, etc.

<a name="development"></a>
## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-spark](https://github.com/MetaCenterCloudPuppet/cesnet-spark)
* Tests: [https://github.com/MetaCenterCloudPuppet/hadoop-tests](https://github.com/MetaCenterCloudPuppet/hadoop-tests)
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
