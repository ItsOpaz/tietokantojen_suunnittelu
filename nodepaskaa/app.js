const express = require('express');
const app = express();
const pg = require('pg');
var conString = "postgres://sqlmanager:keittovesa@localhost:5432/iflac";
var client = new pg.Client(conString);
client.connect();
var query = client.query('SELECT * FROM mainos');
query.on('row', function(row) {
    console.log(row);
});
app.get( '/' ,(req, res) => {
  res.sendFile(__dirname+'/views/home.html');
});


app.listen(8000, () =>
  console.log("testi servuu DXD"));
