const express = require('express');
const app = express();
const pg = require('pg');
var conString = "postgres://postgres:130m3ga11@localhost:5432/tika";
var client = new pg.Client(conString);
client.connect();

app.get( '/' ,(req, res) => {
   client.query(('SELECT * FROM mainos'), function (err, result, fields) {
    if (err) throw err;
    var data = result.rows;
    console.log(result.rows);
    res.sendFile(__dirname+'/views/home.html', {data});
  });
  //res.sendFile(__dirname+'/views/home.html')

});


app.listen(8000, () =>
  console.log("testi servuu DXD"));
