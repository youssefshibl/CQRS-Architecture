#!/bin/bash


# run docker compose 
docker compose up -d

sleep 10

# config debezium
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

sleep 10

# set dummy data users,orders,addresses
node ./scripts/test_realtime.js

sleep 10

# creating materialize sources and views
psql -U materialize -h localhost -p 6875 materialize -f "./infra/queries.sql"

sleep 10

# start to push events
node ./scripts/push_events.js