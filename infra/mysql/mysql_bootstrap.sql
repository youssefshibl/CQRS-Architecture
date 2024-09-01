CREATE DATABASE IF NOT EXISTS shop;
USE shop;

GRANT ALL PRIVILEGES ON shop.* TO 'mysqluser';

CREATE USER 'debezium' IDENTIFIED WITH mysql_native_password BY 'dbz';

GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium';

FLUSH PRIVILEGES;



CREATE TABLE shop.users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE shop.addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES shop.users(user_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS shop.order_items
(
    id SERIAL PRIMARY KEY,
    order_id BIGINT UNSIGNED REFERENCES orders(order_id),
    name VARCHAR(255),
    quantity INT DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL
);

-- Sample structure for orders table
CREATE TABLE shop.orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(255),
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES shop.users(user_id) ON DELETE CASCADE
);







