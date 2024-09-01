import express from "express";
import { pool } from "./connection.js"
import pg from 'pg'
const { Client } = pg
const client = new Client({
    host: 'localhost',  
    port: 6875,       
    user: 'materialize',  
    password: '',  
    database: 'materialize'   
  });
await client.connect()

const app = express();
let port = '8001'

app.get('/order_items', async (req, res) => {
    let sql = "SELECT * from shop.order_items";
    const [rows] = await pool.query(sql)
    res.status(200).json({ notes: rows });
});

app.get('/orders', async (req, res) => {
    let sql = "SELECT * from shop.orders";
    const [rows] = await pool.query(sql)
    res.status(200).json({ orders: rows });
});

app.get('/users', async (req, res) => {
    let sql = "SELECT * from shop.users";
    const [rows] = await pool.query(sql)
    res.status(200).json({ orders: rows });
});


app.get('/addresses', async (req, res) => {
    let sql = "SELECT * from shop.addresses";
    const [rows] = await pool.query(sql)
    res.status(200).json({ orders: rows });
});


app.get('/order_details', async (req, res) => {
    let sql = `SELECT
        orders.order_id,
        orders.total,
        orders.order_date,
        orders.order_status,
        orders.updated_date,
        users.user_id,
        users.name AS user_name,
            users.email AS user_email,
                users.phone AS user_phone,
                    CONCAT(addresses.street, ', ', addresses.city, ', ', addresses.state, ', ', addresses.postal_code, ', ', addresses.country) AS full_address,
                        GROUP_CONCAT(CONCAT(order_items.name, ' (Qty: ', order_items.quantity, ', Price: ', order_items.price, ', Total: ', (order_items.quantity * order_items.price), ')') SEPARATOR ' | ') AS order_items_details
    FROM
    shop.orders
    JOIN
    shop.users ON orders.user_id = users.user_id
LEFT JOIN
    shop.addresses ON users.user_id = addresses.user_id
LEFT JOIN
    shop.order_items ON orders.order_id = order_items.order_id
GROUP BY
    orders.order_id, addresses.address_id, users.user_id;`
    const [rows] = await pool.query(sql)
    res.status(200).json({ orders: rows });
});


app.get('/order_details_mv', async (req, res) => {
    try {
        const result = await client.query("select * from order_summary");
        res.send(result.rows);
      } catch (error) {
        console.error('Error executing query', error.stack);
        res.status(500).send('Internal Server Error');
      }
});



app.listen(port, () => {
    console.log(`server running on port ${port}`);
});