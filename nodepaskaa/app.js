const express = require('express');
const app = express();
const pg = require('pg');
const parser = require('body-parser')
const hbs = require('express-handlebars')
const Handlebars = require('handlebars')

const PORT = 8000

const conString = "postgres://sqlmanager:keittovesa@localhost:5432/iflac";
const client = new pg.Client(conString);
app.engine('hbs', hbs({ extname: 'hbs', defaultLayout: 'home.hbs', layoutDir: __dirname + '/views/' }));
app.set('view engine', 'hbs')

const urlencodedParser = parser.urlencoded({ extended: false })


client.connect();

app.get('/mainokset', (req, res) => {
  client.connect();
  client.query(('SELECT * FROM mainos'), function (err, result, fields) {

    const asd = result.rows;
    if (err) throw err;
    var asdd = JSON.parse(JSON.stringify(result.rows));
    console.log(asdd);
    var nakki = asdd[0].mainosid;
    res.render(__dirname + '/views/layouts/home.hbs', { asdd });
    console.log(result.rows);
  });
});
app.get('/lisaa', (req, res) => {

  res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false });

});
app.post('/lisaa', (req, res) => {
  client.connect();
  console.log(req.body);
  var querystring = `INSERT INTO mainos(kampanjaId, nimi, pituus, kuvaus, esitysaika, jingleId)
   VALUES(${req.body.kampanjaid}, '${req.body.nimi}', '${req.body.pituus}', '${req.body.kuvaus}',
   '${req.body.esitysaika}',
   ${req.body.jingle} )`
  console.log(querystring);
  client.query(querystring, (err, res) => {
    if (err) throw err;
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
    if (err) {
      console.log("kirjautuminen epäonnistui");
      res.render(__dirname + '/views/sivut/login.hbs', { layout: false, kayttajatunnus: "", salasana: "" })
    }

    try {
      if (result.rows.length > 0) {
        console.log('kirjautuminen onnistui')
        res.redirect('/views/sivut/mainokset')
        // res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false })
      }

    } catch (error) {
      console.log('vittusaatana: ' + error)

    }
  })
})

Handlebars.registerHelper("each", function (items, options) {
  const campaignList = items.map(item => "<li>" + options.fn(item) + "</li>");
  return "<ul>\n" + campaignList.join("\n") + "\n</ul>";
});

app.get('/kampanjat', (req, res) => {

  client.query('select * from mainoskampanja', (err, result) => {
    if (err) throw err;


    console.log(result)
    if (result.rowCount > 0) {

      res.render(__dirname + '/views/sivut/kampanjat.hbs', {
        layout: false, data: result.rows
      })
    }

  })

})
app.listen(PORT, () =>
  console.log("Localhost listening on port: " + PORT));
