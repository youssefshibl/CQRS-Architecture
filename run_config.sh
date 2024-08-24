#!/bin/bash

docker compose up -d

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


