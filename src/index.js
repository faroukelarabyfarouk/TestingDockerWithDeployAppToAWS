const express = require('express');
const mongoose = require('mongoose');

const PORT = process.env.PORT || 4000;

const app = express();

const DB_USER = 'root';
const DB_PASSWORD = 'example';
const DB_PORT = '27017';
const DB_HOST = 'mongo'; // Replace with your MongoDB container's IP address

const URI = `mongodb://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}`;
mongoose.connect(URI).then(() => {
    console.log('Connected to MongoDB');
}).catch((err) => {
    console.error('Error connecting to MongoDB:', err);
});

app.get('/', (req, res) => {
    res.send('<h1>Hello FarouQ from Docker AWS test watchtower !</h1>');
});

app.listen(PORT, () => {
    console.log(`App is up and running on port: ${PORT}`);
}); 