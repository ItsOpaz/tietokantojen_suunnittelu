const express = require('express');
const app = express();
const { Client } = require('pg');
client = new Client({
    host: 'localhost:5432',
    user: 'sqlmanager',
    password: 'keittovesa',
    database: 'iflac',
});
client.connect();
var query = client.query('SELECT * FROM mainos');
console.log(query);
app.get( '/' ,(req, res) => {
  res.sendFile(__dirname+'/views/home.html');
});


app.listen(8000, () =>
  console.log("testi servuu DXD"));
