const express = require('express');
const app = express();
const pg = require('pg');
const parser = require('body-parser')
const hbs = require('express-handlebars')


const conString = "postgres://sqlmanager:keittovesa@localhost:5432/iflac";
const client = new pg.Client(conString);
app.engine('hbs', hbs({extname: 'hbs', defaultLayout: 'home.hbs', layoutDir: __dirname+ '/views/'}));
app.set('view engine', 'hbs')

client.connect();

app.get('/mainokset', (req, res) => {
  client.query(('SELECT * FROM mainos'), function (err, result, fields) {
    const asd = result.rows;
    if (err) throw err;
    var asdd = JSON.parse(JSON.stringify(result.rows));
    console.log(asdd);
    var nakki = asdd[0].mainosid;
    res.render(__dirname+'/views/layouts/home.hbs',{asdd});
  });
});
app.get('/lisaa', (req, res)=>{
    res.render(__dirname+'/views/sivut/lisaa.hbs', {layout: false});
});
app.post('/lisaa', (req,res)=>{
   console.log(req.body);
});
app.listen(8000, () =>
  console.log("testi servuu DXD"));
