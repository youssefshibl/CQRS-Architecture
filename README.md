# CQRS-Architectural


To add kafka connector 
```bash 
curl -H 'Content-Type: application/json' localhost:8083/connectors --data '
{
   "name":"orders-connector",
   "config":{
      "connector.class":"io.debezium.connector.mysql.MySqlConnector",
      "tasks.max":"1",
      "database.hostname":"mysql",
      "database.port":"3306",
      "database.user":"debezium",
      "database.password":"dbz",
      "database.server.id":"184054",
      "database.server.name":"mysql",
      "database.include.list":"shop",
      "database.history.kafka.bootstrap.servers":"kafka:9092",
      "database.history.kafka.topic":"mysql-history"
   }
}'
```

Make all sources in debezium
```bash
CREATE SOURCE users
FROM KAFKA BROKER 'kafka:9092' TOPIC 'mysql.shop.users'
FORMAT AVRO USING CONFLUENT SCHEMA REGISTRY 'http://schema-registry:8081' ENVELOPE DEBEZIUM;

CREATE SOURCE addresses
FROM KAFKA BROKER 'kafka:9092' TOPIC 'mysql.shop.addresses'
FORMAT AVRO USING CONFLUENT SCHEMA REGISTRY 'http://schema-registry:8081' ENVELOPE DEBEZIUM;

CREATE SOURCE orders
FROM KAFKA BROKER 'kafka:9092' TOPIC 'mysql.shop.orders'
FORMAT AVRO USING CONFLUENT SCHEMA REGISTRY 'http://schema-registry:8081' ENVELOPE DEBEZIUM;

CREATE SOURCE order_items
FROM KAFKA BROKER 'kafka:9092' TOPIC 'mysql.shop.order_items'
FORMAT AVRO USING CONFLUENT SCHEMA REGISTRY 'http://schema-registry:8081' ENVELOPE DEBEZIUM;
```


Download kafak cli 
```bash
wget https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz
```

List all topics 
```bash
./kafka-topics.sh --bootstrap-server localhost:29092 --list
```
List all messages in topic 
```bash
./kafka-console-consumer.sh --bootstrap-server  localhost:29092  --topic mysql.shop.users --from-beginning
```