# nifitfdemo
Tensorflow and Nifi Demo for Code Free Image Recognition Application
tested with whoville - HDF 3.4 NIFI 1.9

*Although this AMI is not public and is available for Cloudera workhops only, the steps can be reproduced in your own environment**

- Launch AWS AMI **ami-0e27d5a9d5cb14e8f** in Frankfurt region with **m5d.4xlarge** instance type
- Keep default storage (300GB SSD)
- Set security group with:
  - Type: All TCP
  - Source: My IP
- Choose an existing or create a new key pair


# prepare TF 
```bash
su - nifi
cd /home/nifi
mkdir /home/nifi/model
```
# load tensorflow resouces from git
```bash
git clone https://github.com/frothkoetter/nifitfdemo.git 
```

# copy the TF model and NIFI-Tensorflow.Jar into the directories.
```bash
cd nifitfdemo
cp ima*.txt /home/nifi/model 
cp tens*.pb /home/nifi/model
cp nifi-ten*jar /usr/hdf/<version>/nifi/lib
```  
# restart NIFI on Ambari to load jar file and register the tensorflow processor
go to Ambari -- Restart NIFI

# import the Flowfile 
Download demo.nifi.tf.v3.xml to your desktop and then upload as template demo.nifi.tf.v3.xml to Nifi UI

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

```bash
wget http://nlp.stanford.edu/software/stanford-corenlp-full-2018-10-05.zip
unzip stanford-corenlp-full-2018-10-05.zip
```

Then, in order to start the web service, run the CoreNLP jar file, with the following commands:

```bash
cd stanford-corenlp-full-2018-10-05
java -mx1g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer -port 9999 -timeout 15000 </dev/null &>/dev/null &
```
This will run in the background on port 9999 and you can visit the web page to make sure it's running.

The model will classify the given text into 5 categories:

very negative
negative
neutral
positive
very positive

# Create Kafka topic

```bash
sudo su - kafka
cd /usr/hdp/current/kafka-broker
```

Create a topic 

```bash
./bin/kafka-topics.sh --create --zookeeper demo.cloudera.com:2181 --replication-factor 1 --partitions 1 --topic demo_nifi_tf
```

List topics to check that it's been created

```bash
./bin/kafka-topics.sh --list --zookeeper demo.cloudera.com:2181
```

Open a consumer so later we can monitor and verify that JSON records will stream through this topic:

```bash
./bin/kafka-console-consumer.sh --bootstrap-server demo.cloudera.com:6667 --topic demo_nifi_tf
```

Keep this terminal open, and see events comming.

# Druid / Hive processing 

Create a database named workshop and run the SQL

```SQL
CREATE DATABASE workshop;
```

Create the Hive table backed by Druid storage where the social medias sentiment analysis will be streamed into

```SQL
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
```
Start Druid indexing

```SQL
ALTER TABLE workshop.demo_nifi_tf SET TBLPROPERTIES('druid.kafka.ingestion' = 'START');
```

```SQL
select * from workshop.demo_nifi_tf
```

Goto Ambari and check the Druid Coordinator working

# Superset 

Login into Superset http://demo.cloudera.com:9088/login/  admin/admin 

Refresh Druid got to Sources -> refresh Druid Metadata will show the Druid Table and start to create the 
