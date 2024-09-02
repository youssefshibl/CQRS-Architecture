# 👾 CQRS-Architectural

![Untitled-2023-08-22-15342](https://github.com/user-attachments/assets/3c9c7bf8-b669-485b-929d-b161114a0f5e)

### 🪲 Description

This project is a simple implementation of CQRS architectural pattern as well as materialized view. The project is a simple orders management system or ecommerce system with microservices architecture. The project is implemented using nodejs, express, kafka, debezium, materialize and docker.

### 🚀 Deep dive🧊

if we have some microservice which is responsible for handling current state of the orders of the system, so it make some of calls to other microservice like user service, address service, and kitchen service to get the data it needs to build the final status of orders with all its details like user name, address, and items and will make some effort to get last status of the order by comare status date of the order in orders service and kitchen service and delivery service,so this make some problems like:

- **Performance**: it will make a lot of calls to other services to get the data it needs to build the final status of the order.
- **Consistency**: it will make some effort to get last status of the order by comare status date of the order in orders service and kitchen service and delivery service.
- **Scalability**: it will make a lot of calls to other services to get the data it needs to build the final status of the order.

### 🛸 Solutions

- **Performance**: we can solve this problem by using materialized view, so we can get the data we need from the materialized view instead of making a lot of calls to other services.

### 🔥 How It Work

1- we will use debezium to get the data from mysql database and send it to kafka topic this can achieved becuase debezium will listen to the mysql database binary logs (which is a log that contains all the changes that happened to the database) and send the changes to kafka topic, every table in the database will have its own topic in kafka, so we will have a topic for users, a topic for addresses, a topic for orders, and a topic for order_items, in addition to that we will have a topic for order updates, so every service that related to the order will send the updates to this topic, throw this we solve the problem of consistency because we will have all the updates of the order in one place with time order, so we can get the last status of the order by getting the last update of the order from this topic.

2- we will use materialize to get the data from kafka topic and store it in materialized view, so we can get the data we need from the materialized view instead of making a lot of calls to other services , we make this by make source in materialize for every topic in kafka and make materialized view for every source, so we will have a materialized view for users, a materialized view for addresses, a materialized view for orders, a materialized view for order_items, and a materialized view for order updates, so we can get the data we need from the materialized view instead of making a lot of calls to other services.

### 🚀 How to run the project

if you don't want run the project in your local machine you can use github codespaces to run the project in the cloud, you can do this by clicking on the button below , code > codespace > create codespace, and you can run the project in your local machine by following the steps below.

1- execute `start.sh` script to start the project.

```bash
./start.sh
```

this script will do the following

```bash
#!/bin/bash


# run docker compose , this will start mysql, kafka, zookeeper, schema registry, and materialize , app (express server)
docker compose up -d

sleep 30

# config debezium , this will create a connector in kafka to get the data from mysql database and make a topic for every table in the database os if we have a table called users we will have a topic called mysql.shop.users
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

# set dummy data users,orders,order_items,addresses
node ./src/scripts/test_realtime.js

sleep 10

# creating materialize sources and views
# create materialize source for users, addresses, orders, order_items, and order_updates, and create materialized view for order_summary which is a join between orders, order_items, users, and addresses , update the status of the order by getting the last update of the order from order_updates
psql -U materialize -h localhost -p 6875 materialize -f "./infra/queries.sql"

sleep 10

# start to push events
# push events to order_updates topic using current date and random order id with array of sequence of status
node ./src/scripts/push_events.js 1 42

```

### 📢 Access Api

- **orders service**: http://localhost:8001/orders

```json
{
  "orders": [
    {
      "order_id": 1,
      "user_id": 1,
      "total": "391.12",
      "order_date": "2024-09-02T17:21:02.000Z",
      "order_status": "Created",
      "updated_date": "2024-09-02T17:21:02.000Z"
    },
    {
      "order_id": 2,
      "user_id": 1,
      "total": "166.23",
      "order_date": "2024-09-02T17:21:02.000Z",
      "order_status": "Created",
      "updated_date": "2024-09-02T17:21:02.000Z"
    }
  ]
}
```

- **Users service**: http://localhost:8001/users

```json
{
  "users": [
    {
      "user_id": 1,
      "name": "Verna Cartwright",
      "email": "Maritza.Crist@gmail.com",
      "phone": "5728013045",
      "created_at": "2024-09-02T17:21:01.000Z"
    },
    {
      "user_id": 2,
      "name": "Robin Cronin",
      "email": "Casey66@hotmail.com",
      "phone": "8402138341",
      "created_at": "2024-09-02T17:21:02.000Z"
    }
  ]
}
```

- **Addresses service**: http://localhost:8001/addresses

```json
{
  "orders": [
    {
      "address_id": 1,
      "user_id": 1,
      "street": "401 Jackson Street",
      "city": "National City",
      "state": "North Dakota",
      "postal_code": "21221",
      "country": "Equatorial Guinea",
      "created_at": "2024-09-02T17:21:02.000Z"
    },
    {
      "address_id": 2,
      "user_id": 2,
      "street": "27991 N Market Street",
      "city": "East Elvie",
      "state": "North Carolina",
      "postal_code": "49836-7346",
      "country": "Georgia",
      "created_at": "2024-09-02T17:21:02.000Z"
    }
  ]
}
```

### 📢 Access Materialize

- **Materialize**: http://localhost:8001/order_details_mv

```json
[
  {
    "order_id": 7,
    "total": "257.51",
    "order_date": "2024-09-02T17:21:02Z",
    "order_status": "delivered",
    "last_order_update": "2024-09-02T17:34:33.000Z",
    "user_id": 3,
    "user_phone": "1696967713",
    "full_address": "560 Cordie Dam, Nealview, Louisiana, 11434-1806, Rwanda",
    "order_items_details": "Modern Cotton Hat (Qty: 9, Price: 77.11, Total: 693.99)"
  },
  {
    "order_id": 17,
    "total": "21.5",
    "order_date": "2024-09-02T17:21:04Z",
    "order_status": "received",
    "last_order_update": "2024-09-02T17:29:53.000Z",
    "user_id": 7,
    "user_phone": "6007553680",
    "full_address": "629 Bartell Grove, Buffalo, Washington, 31269-4014, Ecuador",
    "order_items_details": "Sleek Cotton Chips (Qty: 1, Price: 11.48, Total: 11.48)"
  }
]
```

### 🕯️ Technologies

- **Nodejs**
- **Express**
- **Kafka**
- **Debezium**
- **Materialize**
- **Docker**
- **Bash**
