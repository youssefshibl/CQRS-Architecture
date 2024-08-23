CREATE DATABASE IF NOT EXISTS pizzashop;
USE pizzashop;

GRANT ALL PRIVILEGES ON pizzashop.* TO 'mysqluser';

CREATE USER 'debezium' IDENTIFIED WITH mysql_native_password BY 'dbz';

GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium';

FLUSH PRIVILEGES;



CREATE TABLE pizzashop.users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE pizzashop.addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES pizzashop.users(user_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS pizzashop.order_items
(
    id SERIAL PRIMARY KEY,
    order_id BIGINT UNSIGNED REFERENCES orders(order_id),
    name VARCHAR(255),
    quantity INT DEFAULT 1
);

-- Sample structure for orders table
CREATE TABLE pizzashop.orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES pizzashop.users(user_id) ON DELETE CASCADE
);




INSERT INTO pizzashop.users (name, email, phone) VALUES
('Alice Johnson', 'alice.johnson@example.com', '123-456-7890'),
('Bob Smith', 'bob.smith@example.com', '098-765-4321');


INSERT INTO pizzashop.addresses (user_id, street, city, state, postal_code, country) VALUES
(1, '123 Maple Street', 'Springfield', 'Illinois', '62704', 'USA'),
(2, '456 Oak Avenue', 'Metropolis', 'New York', '10001', 'USA');


INSERT INTO pizzashop.orders (user_id, total) VALUES (1, 50.00);
INSERT INTO pizzashop.orders (user_id, total) VALUES (2, 149.95);

INSERT INTO pizzashop.order_items (order_id, name, quantity) VALUES (1, 'Sri Lankan Spicy Chicken Pizza', 1);
INSERT INTO pizzashop.order_items (order_id, name, quantity) VALUES (1, 'Chicken BBQ', 1);
INSERT INTO pizzashop.order_items (order_id, name, quantity) VALUES (2, 'Macaroni & Cheese', 1);
INSERT INTO pizzashop.order_items (order_id, name, quantity) VALUES (2, 'Cheesy Garlic Bread Supreme', 1);