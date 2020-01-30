const express = require('express');
const app = express();
const pg = require('pg');
var conString = "postgres://sqlmanager:keittovesa@localhost:5432/iflac";
var client = new pg.Client(conString);
client.connect();
client.query(('SELECT * FROM mainos'), function (err, result, fields) {
    if (err) throw err;
    console.log(result.rows);
    
  });
app.get( '/' ,(req, res) => {
  res.sendFile(__dirname+'/views/home.html');
});


app.listen(8000, () =>
  console.log("testi servuu DXD"));
