# CQRS-Architectural

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
./kafka-console-consumer.sh --bootstrap-server  localhost:29092  --topic mysql.pizzashop.users --from-beginning
```