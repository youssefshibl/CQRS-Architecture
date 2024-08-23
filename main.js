import express from "express";
import { pool } from "./connection.js"

const app = express();
let port = '8001'

app.get('/order_items', async (req, res) => {
    let sql = "SELECT * from pizzashop.order_items";
    const [rows] = await pool.query(sql)
    res.status(200).json({ notes: rows });
});

app.get('/orders', async (req, res) => {
    let sql = "SELECT * from pizzashop.orders";
    const [rows] = await pool.query(sql)
    res.status(200).json({ orders : rows });
});

app.get('/users', async (req, res) => {
    let sql = "SELECT * from pizzashop.users";
    const [rows] = await pool.query(sql)
    res.status(200).json({ orders : rows });
});


app.get('/addresses', async (req, res) => {
    let sql = "SELECT * from pizzashop.addresses";
    const [rows] = await pool.query(sql)
    res.status(200).json({ orders : rows });
});


app.listen(port, () => {
  console.log(`server running on port ${port}`);
});