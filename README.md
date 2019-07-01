# nifitfdemo
Tensorflow and Nifi Demo for Code Free Image Recognition Application
tested with whoville - HDF 3.4 NIFI 1.9

# prepare
su - nifi
/home/nifi
mkdir /home/nifi/model

# load the resouces
git clone "<this repo>"

# copy the TF model and NIFI-Tensorflow.Jar into the directories.
cd nifitfdemo
cp ima*.txt /home/nifi/model 
cp tens*.pb /home/nifi/model
cp nifi-ten*jar /usr/hdf/<version>/nifi/lib

# create hive table (optional)
beeline -u "jdbc:hive2://ip-10-0-1-167.eu-central-1.compute.internal:2181,ip-10-0-1-45.eu-central-1.compute.internal:2181,ip-10-0-1-134.eu-central-1.compute.internal:2181/superset;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2" -i /tmp/tf_images.sql -n hive
create database superset

# import the Flowfile 
upload template tfdemo3.xml to Nifi

# Check E-Mail Account/Password 
using demo.nifi.tf@gmx.de / hadoop88
