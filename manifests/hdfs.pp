# == Class spark::hdfs
#
# HDFS initialiations. Actions necessary to launch on HDFS namenode: Creates directory structure on HDFS for Spark. It needs to be called after Hadoop HDFS is working (its namenode and proper number of datanodes) and before Hive service startup.
#
# This class is needed to be launched on HDFS namenode. With some limitations it can be launched on any Hadoop node (user hive created or hive installed on namenode, kerberos ticket available on the local node).
#
class spark::hdfs {
  $touchfile = 'spark-dir-created'
  hadoop::kinit {'spark-kinit':
    touchfile => $touchfile,
  }
  ->
  hadoop::mkdir {'/user/spark':
    owner     => 'spark',
    group     => 'spark',
    mode      => '0755',
    touchfile => $touchfile,
  }
  ->
  hadoop::mkdir {'/user/spark/applicationHistory':
    owner     => 'spark',
    group     => 'spark',
    mode      => '1777',
    touchfile => $touchfile,
  }
  ->
  hadoop::kdestroy {'spark-kdestroy':
    touchfile => $touchfile,
    touch     => true,
  }
}
