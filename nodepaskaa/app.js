const express = require('express');
const pg = require('pg');
const app = express();

var conString = "localhost:5432";

var client = new pg.Client(conString);
client.connect();
var query = client.query('SELECT * FROM mainos');
console.log(query);
app.get( '/' ,(req, res) => {
  res.sendFile(__dirname+'/views/home.html');
});


app.listen(8000, () =>
  console.log("testi servuu DXD"));
