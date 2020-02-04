const express = require('express');
const app = express();
const pg = require('pg');
const parser = require('body-parser')
const hbs = require('express-handlebars')
app.use(parser.json());
app.use(parser.urlencoded({ extended: true }));
const conString = "postgres://postgres:admin@localhost:5432/tika";
const client = new pg.Client(conString);
app.engine('hbs', hbs({extname: 'hbs', defaultLayout: 'home.hbs', layoutDir: __dirname+ '/views/'}));
app.set('view engine', 'hbs')



app.get('/mainokset', (req, res) => {
  client.connect();
  client.query(('SELECT * FROM mainos'), function (err, result, fields) {

    const asd = result.rows;
    if (err) throw err;
    var asdd = JSON.parse(JSON.stringify(result.rows));
    console.log(asdd);
    var nakki = asdd[0].mainosid;
    res.render(__dirname+'/views/layouts/home.hbs',{asdd});
    console.log(result.rows);
  });
});
app.get('/lisaa', (req, res)=>{
    res.render(__dirname+'/views/sivut/lisaa.hbs', {layout: false});
});
app.post('/lisaa', (req,res)=>{
   client.connect();
   console.log(req.body);
   var querystring = `INSERT INTO mainos(kampanjaId, nimi, pituus, kuvaus, esitysaika, jingleId)
   VALUES(${req.body.kampanjaid}, '${req.body.nimi}', '${req.body.pituus}', '${req.body.kuvaus}',
   '${req.body.esitysaika}',
   ${req.body.jingle} )`
   console.log(querystring);
   client.query(querystring, (err, res)=>{
     if(err) throw err;
     else (console.log("succes"));

   });
   res.redirect('/mainokset')
});
app.listen(8000, () =>
  console.log("testi servuu DXD"));
