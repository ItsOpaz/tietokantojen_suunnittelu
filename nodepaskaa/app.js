const express = require('express');
const app = express();
const pg = require('pg');
const parser = require('body-parser')
const hbs = require('express-handlebars')

const PORT = 8000

const conString = "postgres://postgres:hilla123@localhost:5432/iflac";
const client = new pg.Client(conString);
app.engine('hbs', hbs({ extname: 'hbs', defaultLayout: 'home.hbs', layoutDir: __dirname + '/views/' }));
app.set('view engine', 'hbs')

const urlencodedParser = parser.urlencoded({ extended: false })


client.connect();

app.get('/mainokset', (req, res) => {
  client.query(('SELECT * FROM mainos'), function (err, result, fields) {
    const asd = result.rows;
    if (err) throw err;
    var asdd = JSON.parse(JSON.stringify(result.rows));
    console.log(asdd);
    var nakki = asdd[0].mainosid;
    res.render(__dirname + '/views/layouts/home.hbs', { asdd });

  });
});
app.get('/lisaa', (req, res) => {

  res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false });

});
app.post('/lisaa', urlencodedParser, (req, res) => {
  console.log(req.body);


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
