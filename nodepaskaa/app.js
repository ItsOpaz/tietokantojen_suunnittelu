const express = require('express');
const app = express();
const pg = require('pg');
const parser = require('body-parser')
const hbs = require('express-handlebars')
<<<<<<< HEAD
app.use(parser.json());
app.use(parser.urlencoded({ extended: true }));
const conString = "postgres://postgres:admin@localhost:5432/tika";
=======

const PORT = 8000

const conString = "postgres://postgres:hilla123@localhost:5432/iflac";
>>>>>>> def71181a7a378b95516dc1b557986cf1bcfc165
const client = new pg.Client(conString);
app.engine('hbs', hbs({ extname: 'hbs', defaultLayout: 'home.hbs', layoutDir: __dirname + '/views/' }));
app.set('view engine', 'hbs')

<<<<<<< HEAD

=======
const urlencodedParser = parser.urlencoded({ extended: false })


client.connect();
>>>>>>> def71181a7a378b95516dc1b557986cf1bcfc165

app.get('/mainokset', (req, res) => {
  client.connect();
  client.query(('SELECT * FROM mainos'), function (err, result, fields) {

    const asd = result.rows;
    if (err) throw err;
    var asdd = JSON.parse(JSON.stringify(result.rows));
    console.log(asdd);
    var nakki = asdd[0].mainosid;
<<<<<<< HEAD
    res.render(__dirname+'/views/layouts/home.hbs',{asdd});
    console.log(result.rows);
=======
    res.render(__dirname + '/views/layouts/home.hbs', { asdd });

>>>>>>> def71181a7a378b95516dc1b557986cf1bcfc165
  });
});
app.get('/lisaa', (req, res) => {

  res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false });

});
<<<<<<< HEAD
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
=======
app.post('/lisaa', urlencodedParser, (req, res) => {
  console.log(req.body);


>>>>>>> def71181a7a378b95516dc1b557986cf1bcfc165
});


app.get('/login', (req, res) => {

  res.render(__dirname + '/views/sivut/login.hbs', { layout: false, kayttajatunnus: "", salasana: "" })

})

app.post('/login', urlencodedParser, (req, res) => {
  const { kayttajatunnus, salasana } = req.body

  // Chekataan kannasta, että onko kayttajatunnus ja salasana oikein
  client.query('select * from jarjestelma_kirjautumistiedot where kayttajatunnus=\'' + kayttajatunnus + '\' and ' + 'salasana=\'' + salasana + '\'', (err, result) => {
    if (err) {
      res.render(__dirname + '/views/sivut/login.hbs', { layout: false, kayttajatunnus: "", salasana: "" })
    }

    try {
      if (result.rows.length > 0) {
        console.log('kirjautuminen onnistui')
        res.redirect('mainokset')
        // res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false })
      }

    } catch (error) {
      console.log('vittusaatana: ' + error)

    }
  })


})
app.listen(PORT, () =>
  console.log("testi servuu portilla: " + PORT));
