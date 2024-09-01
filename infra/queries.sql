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

CREATE SOURCE updates_source
FROM KAFKA BROKER 'kafka:9092' TOPIC 'order_updates'
FORMAT BYTES;

CREATE MATERIALIZED VIEW updates AS
SELECT
(data->>'id')::int AS id,
(data->>'order_id')::int AS order_id,
data->>'status' AS status,
data->>'updated_at' AS updated_at
FROM (SELECT CONVERT_FROM(data, 'utf8')::jsonb AS data FROM updates_source);



CREATE MATERIALIZED VIEW LastUpdate AS
SELECT
    updates.order_id,
    updates.status AS last_status,
    to_timestamp(updates.updated_at::double precision)  as last_update,
    ROW_NUMBER() OVER (PARTITION BY updates.order_id ORDER BY updates.updated_at DESC) AS rn
FROM
    updates;




CREATE MATERIALIZED VIEW order_summary AS
SELECT
    orders.order_id,
    orders.total,
    orders.order_date,
    COALESCE(
        (SELECT last_status FROM lastupdate WHERE lastupdate.order_id = orders.order_id AND LastUpdate.rn = 1),
        orders.order_status
    ) AS order_status,
   COALESCE(
    (SELECT last_update FROM lastupdate WHERE lastupdate.order_id = orders.order_id AND LastUpdate.rn = 1),
    orders.updated_date::timestamp with time zone
) AS last_order_update,
    users.user_id,
    users.phone AS user_phone,
    CONCAT(addresses.street, ', ', addresses.city, ', ', addresses.state, ', ', addresses.postal_code, ', ', addresses.country) AS full_address,
    STRING_AGG(CONCAT(order_items.name, ' (Qty: ', order_items.quantity, ', Price: ', order_items.price, ', Total: ', (order_items.quantity * order_items.price), ')'), ' | ') AS order_items_details
FROM
    orders
JOIN
    users ON orders.user_id = users.user_id
LEFT JOIN
    addresses ON users.user_id = addresses.user_id
LEFT JOIN
    order_items ON orders.order_id = order_items.order_id
LEFT JOIN
    LastUpdate ON orders.order_id = LastUpdate.order_id AND LastUpdate.rn = 1
GROUP BY
    orders.order_id, orders.total, orders.order_date, addresses.address_id, users.user_id, orders.order_status, users.phone, addresses.street,
    addresses.city, addresses.state, addresses.postal_code, addresses.country,orders.updated_date;