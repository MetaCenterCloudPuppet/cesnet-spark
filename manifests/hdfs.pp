# == Class spark::hdfs
#
# HDFS initialiations. Actions necessary to launch on HDFS namenode: Creates directory structure on HDFS for Spark, creates system spark user. It needs to be called after Hadoop HDFS Namenode is working.
#
# This class is needed to be launched on HDFS namenode. With some limitations it can be launched on any Hadoop node (kerberos ticket available on the local node).
#
class spark::hdfs {
  include ::spark::user

  $touchfile = 'spark-root-dir-created'
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

  if $spark::jar_enable {
    $touchfile2 = 'spark-jar-dir-created'
    hadoop::kinit {'spark-kinit-jar':
      touchfile => $touchfile2,
    }
    ->
    hadoop::mkdir {'/user/spark/share':
      owner     => 'spark',
      group     => 'spark',
      touchfile => $touchfile2,
    }
    ->
    hadoop::mkdir {'/user/spark/share/lib':
      owner     => 'spark',
      group     => 'spark',
      touchfile => $touchfile2,
    }
    ->
    hadoop::kdestroy {'spark-kdestroy-jar':
      touchfile => $touchfile2,
      touch     => true,
    }
  }
}
