const express = require('express');
const app = express();
const pg = require('pg');
var conString = "postgres://sqlmanager:keittovesa@localhost:5432/iflac";
var client = new pg.Client(conString);
client.connect();

app.get( '/' ,(req, res) => {
   client.query(('SELECT * FROM mainos'), function (err, result, fields) {
    if (err) throw err;
    console.log(result.rows);
    res.write(results.rows);
    res.end();
  });
  //res.sendFile(__dirname+'/views/home.html')
  
});


app.listen(8000, () =>
  console.log("testi servuu DXD"));
