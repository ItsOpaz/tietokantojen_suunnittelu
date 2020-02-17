const express = require('express');
const app = express();
const pg = require('pg');
const parser = require('body-parser')
const hbs = require('express-handlebars')
const Handlebars = require('handlebars')

const PORT = 8000

const conString = "postgres://postgres:admin@localhost:5432/tika";
const client = new pg.Client(conString);
app.engine('hbs', hbs({ extname: 'hbs', defaultLayout: 'home.hbs', layoutDir: __dirname + '/views/' }));
app.set('view engine', 'hbs')

const urlencodedParser = parser.urlencoded({ extended: false })
app.use(parser.urlencoded({ extended: false }));
app.use(parser.json());


client.connect();
app.get('/mainokset', (req, res) => {

  client.query(('SELECT * FROM mainos'), function (err, result, fields) {

    const asd = result.rows;
    if (err) throw err;
    var asdd = JSON.parse(JSON.stringify(result.rows));
    console.log(asdd);
    res.render(__dirname + '/views/layouts/home.hbs', { asdd });
  });
});
app.get('/lisaa', (req, res) => {

  res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false });

});
app.post('/lisaa', (req, res) => {
  console.log(req.body);
  var querystring = `INSERT INTO mainos(kampanjaId, nimi, pituus, kuvaus, esitysaika, jingleId)
   VALUES(${req.body.kampanjaid}, '${req.body.nimi}', '${req.body.pituus}', '${req.body.kuvaus}',
   '${req.body.esitysaika}',
   ${req.body.jingle} )`
  console.log(querystring);
  client.query(querystring, (err, result) => {
    if (err) {
      throw err;
    }
    else (console.log("succes"));

  });
  res.redirect('/mainokset')
});


app.get('/login', (req, res) => {

  res.render(__dirname + '/views/sivut/login.hbs', { layout: false, kayttajatunnus: "", salasana: "" })

})

app.post('/login', urlencodedParser, (req, res) => {
  const { kayttajatunnus, salasana } = req.body

  // Chekataan kannasta, että onko kayttajatunnus ja salasana oikein
  client.query('select * from jarjestelma_kirjautumistiedot where kayttajatunnus=\'' + kayttajatunnus + '\' and ' + 'salasana=\'' + salasana + '\'', (err, result) => {

    // if (err) {
    //   console.log("kirjautuminen epäonnistui");
    //   res.render(__dirname + '/views/sivut/login.hbs', { layout: false, kayttajatunnus: "", salasana: "" })
    // }

    try {

      if (result.rows.length > 0) {
        console.log('kirjautuminen onnistui')
        res.redirect('/mainokset')
        // res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false })
      }
      else {
        console.log("Käyttäjätunnusta tai salasanaa ei löydetty");
        res.redirect("/login")
      }

    } catch (error) {
      console.log('vittusaatana: ' + error)

    }
  })
})

Handlebars.registerHelper("each_with", function (items, attr, options, value = "") {

  let result = ""

  console.log(value)

  if (value) {
    for (let i = 0; i < items.length; i++) {
      if (items[i][attr] == value) {

        result += options.fn(items[i])
      }
    }

  } else {

    for (let i = 0; i < items.length; i++) {
      result += options.fn(items[i])
    }

  }

  return result

});



app.get('/kampanjat', (req, res) => {

  client.query('select * from mainoskampanja', (err, result) => {
    if (err) throw err;


    if (result.rowCount > 0) {

      res.render(__dirname + '/views/sivut/kampanjat.hbs', {
        layout: false, data: result.rows
      })
    }
  })
})

app.get('/kampanjat/:id', (req, res) => {

})

app.post('/kampanjat/:id', (req, res) => {

  // Päivitä kampanja?
  let query = `select `;
})


app.listen(PORT, () =>
  console.log("Localhost listening on port: " + PORT));
