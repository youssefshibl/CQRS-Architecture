import mysql from "mysql2";

export const pool = mysql
    .createPool({
        host: 'mysql',
        user: 'mysqluser',
        password: 'mysqlpw',
        database: 'shop'
    })
    .promise();