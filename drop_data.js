import mysql from "mysql2";

// Create a connection pool
const pool = mysql
    .createPool({
        host: '127.0.0.1',
        user: 'mysqluser',
        password: 'mysqlpw',
        database: 'shop'
    })
    .promise();

async function deleteAllData() {
    try {
        // Start a transaction
        await pool.query('START TRANSACTION');

        // Delete data in the reverse order of dependencies
        await pool.query('DELETE FROM order_items'); // Remove order items first
        await pool.query('DELETE FROM orders');       // Then remove orders
        await pool.query('DELETE FROM addresses');    // Then remove addresses
        await pool.query('DELETE FROM users');        // Finally remove users

        // Commit the transaction
        await pool.query('COMMIT');
        
        console.log('All data has been successfully deleted.');
    } catch (err) {
        // Rollback the transaction in case of error
        await pool.query('ROLLBACK');
        console.error('Error deleting data: ', err);
    } finally {
        pool.end(); // Close the connection pool
    }
}

// Run the function
deleteAllData();
