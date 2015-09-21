## Apache Spark Puppet Module

[![Build Status](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-spark.svg?branch=master)](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-spark)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with spark](#setup)
    * [What spark affects](#what-spark-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Spark in YARN cluster mode](#usage-yarn)
    * [Spark in Spark cluster mode](#usage-master)
    * [Spark jar file optimization](#usage-jar-optimization)
    * [Add Spark History Server](#usage-history-server)
    * [Upgrade](#upgrade)
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

This puppet module installs and setup Apache Spark cluster, optionally with security. YARN and Spark Master cluster modes are supported.

Supported are:

* Debian 7/wheezy: Cloudera distribution (tested with CDH 5.4.2, Spark 1.3.0)
* Ubuntu 14/trusty: Cloudera distribution (tested with CDH 5.3.1, Spark 1.2.0)
* RHEL 6, CentOS 6, Scientific Linux 6 (tested with CDH 5.4.2, Spark 1.3.0)

<a name="setup"></a>
## Setup

<a name="what-spark-affects"></a>
### What spark affects

* Packages: installs Spark packages as needed (core, python, history server, ...)
* Files modified:
 * */etc/spark/conf/spark-default.conf*
 * */etc/spark/conf/spark-env.sh* (modified, when *environment* parameter set)
 * */etc/default/spark*
 * */etc/profile.d/hadoop-spark.csh* (frontend)
 * */etc/profile.d/hadoop-spark.sh* (frontend)
* Permissions modified:
 * */etc/security/keytab/spark.service.keytab* (historyserver)
* Alternatives:
 * alternatives are used for */etc/spark/conf* in Cloudera
 * this module switches to the new alternative by default, so the Cloudera original configuration can be kept intact
* Services:
 * master server (when *spark::master* or *spark::master::service* included)
 * history server (when *spark::historyserver* or *spark::historyserver::service* included)
 * worker node (when *spark::worker* or *spark::worker::service* included)
* Helper files:
 * */var/lib/hadoop-hdfs/.puppet-spark-\**

<a name="setup-requirements"></a>
### Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Hadoop repositories**
 * neither Cloudera nor Hortonworks repositories are configured in this module (for Cloudera you can find list and key files here: [http://archive.cloudera.com/cdh5/debian/wheezy/amd64/cdh/](http://archive.cloudera.com/cdh5/debian/wheezy/amd64/cdh/))
 * *java* is not installed by this module (*openjdk-7-jre-headless* is OK for Debian 7/wheezy)

* **No inter-node dependencies**: working HDFS is required before deploying of Spark History Server, dependency of Spark HDFS initialization on HDFS namenode is handled properly (if the class *spark::hdfs* is included on the HDFS namenode, see examples)

<a name="usage"></a>
## Usage

There are two cluster modes, how to use Spark (these modes can be both enabled):

* **YARN mode**: Hadoop is used for computing and scheduling
* **Spark mode**: Spark Master Server and Worker Nodes are used for computing and scheduling

Optionaly **Spark History Server** can be used (for both YARN or Spark modes), which would also require Hadoop HDFS.

The Spark mode doesn't support security, only YARN mode can be used with secured Hadoop cluster.

Puppet classes to include:

* everywhere: *spark*
* YARN mode (requires Hadoop cluster with YARN, see CESNET Hadoop puppet module):
 * client: *spark::frontend*
* Spark mode:
 * master: *spark::master*
 * slaves: *spark::worker*
* optionaly History Server (requires Hadoop cluster with HDFS, see CESNET Hadoop puppet module):
 * *spark::historyserver*
 * on HDFS namenode: *spark::hdfs*

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

Issues:

* if collocated with HDFS namenode, add dependency *Class['hadoop::namenode::service'] -> Class['spark::historyserver::service']*
* if not collocated, it is needed to have HDFS namenode running first (puppet should be launched later again, if Spark History Server won't start because of HDFS)

Notes:

* for Spark clients (in YARN mode): user must logout and login again or launch "*. /etc/profile.d/hadoop-spark.sh*"

Now you can submit spark jobs in the cluster mode over Hadoop YARN:

    spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode cluster --master yarn /usr/lib/spark/lib/spark-examples-1.2.0-cdh5.3.1-hadoop2.5.0-cdh5.3.1.jar 10

<a name="usage-master"></a>
### Spark in Spark Master cluster mode

Example of Apache Spark in Spark cluster mode:

    $master_hostname='spark-master.example.com'

    class{'hadoop':
      realm         => '',
      hdfs_hostname => $master_hostname,
      slaves        => ['spark1.example.com', 'spark2.example.com'],
    }

    class{'spark':
      master_hostname        => $master_hostname,
      hdfs_hostname          => $master_hostname,
      historyserver_hostname => $master_hostname,
      yarn_enable            => false,
    }

    node 'spark-master.example.com' {
      include spark::master
      include spark::historyserver
      include hadoop::namenode
      include spark::hdfs
    }

    node /spark(1|2).example.com/ {
      include spark::worker
      include hadoop::datanode
    }

    node 'client.example.com' {
      include hadoop::frontend
      include spark::frontend
    }

Notes:

* two-nodes cluster is used here
* there is also enabled Spark History Server (*spark::historyserver*), which requires HDFS (master: *hadoop::namenode*, slaves: *hadoop::datanode*)
* YARN is disabled completely, to enable YARN: include also *hadoop::nodemanager* on the slave nodes (colocation with *spark::worker* is not needed) and *hadoop::resourcemanager* on master (see previous example, or CESNET Hadoop puppet module)

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

Spark History server stores details about Spark jobs. It is provided by the class *spark::historyserver*. The parameter *historiserver\_hostname* needs to be also specified (replace *$::fqdn* by real hostname), and HDFS cluster is required:

    ...
    class{'spark':
      ...
      historyserver_hostname => $::fqdn,
    }

    node default {
      ...
      include spark::historyserver
    }

<a name="upgrade"></a>
### Upgrade

The best way is to refresh configrations from the new original (=remove the old) and relaunch puppet on top of it. There is also problem with start-up scripts on Debian, which needs to be worked around, where Spark history server is used.

For example:

    alternative='cluster'
    d='spark'
    mv /etc/{d}$/conf.${alternative} /etc/${d}/conf.cdhXXX
    update-alternatives --auto ${d}-conf

    service spark-history-server stop || :
    mv /etc/init.d/spark-history-server /etc/init.d/spark-history-server.prev

    # upgrade
    ...

    puppet agent --test
    #or: puppet apply ...

    # restore start-up script from spark-history-server.dpkg-new or spark-history-server.prev
    ...
    service spark-history-server start


<a name="reference"></a>
##Reference

<a name="classes"></a>
###Classes

* common:
 * config
 * postinstall
* **frontend** - Apache Spark Client
 * config
 * install
* init
* **hdfs** - HDFS initializations
* **historyserver** - Apache Spark History Server
 * config
 * install
 * service
* **master** - Apache Spark Master Server
 * config
 * install
 * service
* **worker** - Apache Spark Worker Node
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

####`master_hostname` undef

Spark Master hostname.

####`master_port` '7077'

Spark Master port.

####`master_ui_port` '18080'

Spark Master Web UI port.

####`historyserver_hostname` undef

Spark History server hostname.

####`historyserver_port` '18082'

Spark History Server Web UI port.

Notes:

* the Spark default value is 18080, which conflicts with default for Master server
* no *historyserver\_ui\_port* parameter (Web UI port is the same as the RPC port)

####`worker_port` '7078'

Spark Worker node port.

####`worker_ui_port` '18081'

Spark Worker node Web UI port.

####`environment` undef

Environments to set for Apache Spark. "::undef" will unset the variable.

You may need to increase memory in case of big amount of jobs:

    environment => {
      'SPARK_DAEMON_MEMORY' => '4096m',
    }

#### `properties` undef

Spark properties to set.

####`realm` undef

Kerberos realm. Non-empty string enables security.

####`jar_enable` false

Configure Apache Spark to search Spark jar file in *$hdfs\_hostname/user/spark/share/lib/spark-assembly.jar*. The jar needs to be copied to HDFS manually after installation, and also manually updated after each Spark SW update:

    hdfs dfs -put /usr/lib/spark/spark-assembly.jar /user/spark/share/lib/spark-assembly.jar

####`yarn_enable` true

Enable YARN mode by default. This requires configured Hadoop using CESNET Hadoop puppet module.

<a name="limitations"></a>
## Limitations

Tested with Cloudera distribution.

See also [Setup requirements](#setup-requirements).

<a name="development"></a>
## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-spark](https://github.com/MetaCenterCloudPuppet/cesnet-spark)
* Tests:
 * basic: see *.travis.yml*
 * vagrant: [https://github.com/MetaCenterCloudPuppet/hadoop-tests](https://github.com/MetaCenterCloudPuppet/hadoop-tests)
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
