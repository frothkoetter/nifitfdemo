# nifitfdemo
Tensorflow and Nifi Demo for Code Free Image Recognition Application
tested with whoville - HDF 3.4 NIFI 1.9

# prepare TF 
su - nifi
cd /home/nifi
mkdir /home/nifi/model

# load the resouces
git clone https://github.com/frothkoetter/nifitfdemo.git

# copy the TF model and NIFI-Tensorflow.Jar into the directories.
cd nifitfdemo
cp ima*.txt /home/nifi/model 
cp tens*.pb /home/nifi/model
cp nifi-ten*jar /usr/hdf/<version>/nifi/lib
  
# restart NIFI on Ambari to load jar file and register the tensorflow processor
go to Ambari -- Restart NIFI

# create hive table (optional)
beeline -u "jdbc:hive2://ip-10-0-1-167.eu-central-1.compute.internal:2181,ip-10-0-1-45.eu-central-1.compute.internal:2181,ip-10-0-1-134.eu-central-1.compute.internal:2181/superset;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2" -i /tmp/tf_images.sql -n hive
create database superset

# import the Flowfile 
you may download to your desktop as template and then upload template demo.nifi.tf.xml to Nifi

# Check E-Mail Account/Password in the get mail and send mail processors (passwords are not exported in the XML Flow)
using demo.nifi.tf@gmx.de / hadoop88 

# Python Script to extract E-Mail Body (optional)
Good to know this piece 

https://stackoverflow.com/questions/47200178/read-message-body-of-an-email-using-apache-nifi
Adding a new attribute msgbody to the flow with the text of the E-Mail Body (no-header, no- attachements)

# NLP processing 
Run the sentiment analysis model as a REST-like service
For the purpose we re-use an existing sentiment analysis model, provided by the Stanford University as part of their CoreNLP - Natural language software

Download and unzip the CoreNLP using the wget as below:

wget http://nlp.stanford.edu/software/stanford-corenlp-full-2018-10-05.zip
unzip stanford-corenlp-full-2018-10-05.zip
Then, in order to start the web service, run the CoreNLP jar file, with the following commands:

cd stanford-corenlp-full-2018-10-05
java -mx1g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer -port 9999 -timeout 15000 </dev/null &>/dev/null &

This will run in the background on port 9999 and you can visit the web page to make sure it's running.

The model will classify the given text into 5 categories:

very negative
negative
neutral
positive
very positive

# Create Kafka topic

sudo su - kafka
cd /usr/hdp/current/kafka-broker

Create a topic 

./bin/kafka-topics.sh --create --zookeeper demo.cloudera.com:2181 --replication-factor 1 --partitions 1 --topic demo_nifi_tf

List topics to check that it's been created

./bin/kafka-topics.sh --list --zookeeper demo.cloudera.com:2181

Open a consumer so later we can monitor and verify that JSON records will stream through this topic:

./bin/kafka-console-consumer.sh --bootstrap-server demo.cloudera.com:6667 --topic demo_nifi_tf

Keep this terminal open, and see events comming.

# Druid / Hive processing 

create database workshop;

CREATE EXTERNAL TABLE workshop.demo_nifi_tf (
`__time` timestamp,
`sender` string,
`sentiment` string,
`label_1` string,
`probability_1` string
)
STORED BY 'org.apache.hadoop.hive.druid.DruidStorageHandler'
TBLPROPERTIES (
"kafka.bootstrap.servers" = "demo.cloudera.com:6667",
"kafka.topic" = "demo_nifi_tf",
"druid.kafka.ingestion.useEarliestOffset" = "true",
"druid.kafka.ingestion.maxRowsInMemory" = "5",
"druid.kafka.ingestion.startDelay" = "PT1S",
"druid.kafka.ingestion.period" = "PT1S",
"druid.kafka.ingestion.consumer.retries" = "2"
);
ALTER TABLE workshop.demo_nifi_tf SET TBLPROPERTIES('druid.kafka.ingestion' = 'START');

select * from workshop.demo_nifi_tf

