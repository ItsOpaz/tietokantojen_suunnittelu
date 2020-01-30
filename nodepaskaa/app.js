const express = require('express');
const app = express();
const pg = require('pg');
var conString = "postgres://sqlmanager:keittovesa@localhost:5432/iflac";
var client = new pg.Client(conString);
client.connect();
const query = client.query('SELECT * FROM mainos');
query.on('row', (row) => {
      console.log(row);
    });
    // After all data is returned, close connection and return results
query.on('end', () => {
    done();
    return res.json(results);
    });
app.get( '/' ,(req, res) => {
  res.sendFile(__dirname+'/views/home.html');
});


app.listen(8000, () =>
  console.log("testi servuu DXD"));
