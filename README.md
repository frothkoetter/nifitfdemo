# nifitfdemo
Tensorflow and Nifi Demo

# create hive table
beeline -u "jdbc:hive2://ip-10-0-1-167.eu-central-1.compute.internal:2181,ip-10-0-1-45.eu-central-1.compute.internal:2181,ip-10-0-1-134.eu-central-1.compute.internal:2181/superset;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2" -i /tmp/tf_images.sql -n hive
create database superset

