const express = require('express');
const app = express();
const pg = require('pg');
const parser = require('body-parser')


const conString = "postgres://sqlmanager:keittovesa@localhost:5432/iflac";
const client = new pg.Client(conString);



client.connect();

app.get('/mainokset', (req, res) => {
  client.query(('SELECT * FROM mainos'), function (err, result, fields) {
    if (err) throw err;
    console.log(result.rows);
    res.write(JSON.stringify(result.rows));
  });
  //res.sendFile(__dirname+'/views/home.html')

});


app.listen(8000, () =>
  console.log("testi servuu DXD"));
