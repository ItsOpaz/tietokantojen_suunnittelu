const express = require('express');
const app = express();
const pg = require('pg');

app.set('view engine', 'pug')

const port = 3000
var conString = "postgres://postgres:hilla123@localhost:5432/iflac";
var client = new pg.Client(conString);
client.connect();

app.get('/mainokset', (req, res) => {
  client.query(('SELECT * FROM jarjestelma_kayttaja'), function (err, result) {
    if (err) throw err;
    console.log(result.rows);
    res.sendFile(__dirname + '/views/home.html')
  });

});

app.get('/login', (req, res) => {
  client.query('select * from laskutusosoite', (err, result) => {
    if (err) throw err;

    console.log(result.rows)

    res.render('./login', { t: 'Saatana', message: result.rows[0].osoiteid })
  })
})

app.get('/paskaa', (req, res) => {
  res.render('./paskaa', { vittu: () => console.log('vittu') })
})


app.listen(port, () =>
  console.log("server open on port: " + port));
