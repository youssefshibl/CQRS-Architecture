import mysql from "mysql2";
import { faker } from "@faker-js/faker";
import { pool } from "./connection.js"



// Function to insert users into the database
async function insertUsers(numberOfUsers, numberOfOrdersOfUser, ItemsNumber) {
    for (let i = 0; i < numberOfUsers; i++) {
        const name = faker.person.fullName();
        const email = faker.internet.email();
        const phone = faker.string.numeric(10); // Generates a 10-digit phone number

        const [result] = await pool.query(
            "INSERT INTO users (name, email, phone) VALUES (?, ?, ?)",
            [name, email, phone]
        );

        const userId = result.insertId;

        // Insert address for each user
        const street = faker.location.streetAddress();
        const city = faker.location.city();
        const state = faker.location.state();
        const postalCode = faker.location.zipCode();
        const country = faker.location.country();

        await pool.query(
            "INSERT INTO addresses (user_id, street, city, state, postal_code, country) VALUES (?, ?, ?, ?, ?, ?)",
            [userId, street, city, state, postalCode, country]
        );

        // Generate a random number of orders for each user (between 1 and 5)
        const numberOfOrders = faker.number.int({ min: 1, max: numberOfOrdersOfUser });

        for (let j = 0; j < numberOfOrders; j++) {
            const orderStatus = 'Created';
            const total = faker.number.float({ min: 20, max: 500 });

            const [orderResult] = await pool.query(
                "INSERT INTO orders (user_id, total, order_status) VALUES (?, ?, ?)",
                [userId, total, orderStatus]
            );

            const orderId = orderResult.insertId;

            const maxNumberOfItems = faker.number.int({ min: 1, max: ItemsNumber });
            const numberOfItems = faker.number.int({ min: 1, max: maxNumberOfItems });

            for (let k = 0; k < numberOfItems; k++) {
                const itemName = faker.commerce.productName();
                const quantity = faker.number.int({ min: 1, max: 10 });
                const price = faker.number.float({ min: 5, max: 100 });

                await pool.query(
                    "INSERT INTO order_items (order_id, name, quantity, price) VALUES (?, ?, ?, ?)",
                    [orderId, itemName, quantity, price]
                );
            }
        }
    }
}



// Generate and insert data
(async function () {
    try {
        let numberOfUsers = 20;
        let numberOfOrders = 3;
        let numberOfItems = 2;
        await insertUsers(numberOfUsers, numberOfOrders, numberOfItems);
        console.log(`${numberOfUsers} users with their addresses, orders, and order items have been inserted.`);
    } catch (err) {
        console.error("Error inserting data: ", err);
    } finally {
        pool.end(); // Close the connection pool
    }
})();