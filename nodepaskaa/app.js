const express = require('express');
const app = express();
const pg = require('pg');
const parser = require('body-parser')
const hbs = require('express-handlebars')
const Handlebars = require('handlebars')
const passport = require('passport')
const flash = require('express-flash')
const session = require('express-session')


const PORT = 8000

const conString = "postgres://postgres:admin@localhost:5432/iflac";
const client = new pg.Client(conString);
app.engine('hbs', hbs({ extname: 'hbs', defaultLayout: 'home.hbs', layoutDir: __dirname + '/views/' }));
app.set('view engine', 'hbs')

app.use(parser.urlencoded({ extended: false }));
app.use(parser.json());
app.use(flash())

app.use(session({
  secret: "super_secret_key",
  resave: false,
  saveUninitialized: false
}))

app.use(passport.initialize())
app.use(passport.session())


client.connect();

const initPassport = require("./passport-config")
initPassport(passport, (user) => {
  const query = 'select * from jarjestelma_kirjautumistiedot where kayttajatunnus=\'' + user + '\''
  client.query(query, (err, result) => {
    if (err) { throw err }

    console.log(result)

    return result[0]
  })

})


app.get('/', (req, res) => {
  res.render(__dirname + '/views/layouts/home.hbs')
})
app.get('/mainokset', (req, res) => {

  client.query(('SELECT * FROM mainos'), function (err, result) {

    if (err) throw err;
    var data = JSON.parse(JSON.stringify(result.rows));

    res.render(__dirname + '/views/sivut/mainokset.hbs', { data: data, layout: false });
  });
});

app.post("/mainokset", (req, res) => {
  let mainosid = Object.keys(req.body)[0]


  res.redirect(`/mainosesitysraportit/${mainosid}`);

})


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


app.get('/laskutus', (req, res) => {
  client.query(('SELECT * FROM laskutustiedot'), function (err, result, fields) {
    if (err) throw err;
    const asd = result.rows;

    var laskut = JSON.parse(JSON.stringify(result.rows));

    res.render(__dirname + '/views/sivut/laskutus.hbs', { laskut, layout: false })

  });
})
app.post('/laskutus', (req, res) => {
  console.log(req.body);

  if (req.body.laskunumero == "all") {
    client.query(('SELECT * FROM laskutustiedot'), function (err, result) {
      if (err) throw err;
      const asd = result.rows;
      laskut = JSON.parse(JSON.stringify(result.rows));
      res.render(__dirname + '/views/sivut/laskutus.hbs', { laskut, layout: false });
    }
    )
  }
  else {
    if (req.body.mainostaja != null) {
      console.log(req.body.mainostaja);
      client.query((`SELECT * FROM laskutustiedot WHERE mainostaja = '${req.body.mainostaja}'`), function (err, result) {
        if (err) throw err;
        const asd = result.rows;
        laskut = JSON.parse(JSON.stringify(result.rows));
        res.render(__dirname + '/views/sivut/laskutus.hbs', { laskut, layout: false });
      }
      );
    }
    else {
      if (req.body.laskunumero > 1) {
        var list = [];
        client.query((`SELECT * FROM lasku WHERE laskuid = ${req.body.laskunumero}`), function (err, result) {
          if (err) throw err;
          var lasku = JSON.parse(JSON.stringify(result.rows));
          client.query(('SELECT * FROM laskutustiedot'), function (err, result) {
            if (err) throw err;
            laskut = JSON.parse(JSON.stringify(result.rows));
            var z;
            for (x of laskut) {
              if (x.laskuid == req.body.laskunumero) {
                lasku[0].tilaaja = x.tilaaja;
                lasku[0].mainostaja = x.mainostaja;
                lasku[0].laskutusosoiteid = x.laskutusosoiteid;
                lasku[0].mainoskampanja = x.kampanja;
                z = x.laskutusosoiteid;
              }
            }
            console.log(z);
            if (z != null) {
              client.query((`SELECT * FROM laskutusosoite WHERE osoiteid = ${z}`), function (err, results) {
                if (err) throw err;
                var pars = JSON.parse(JSON.stringify(results.rows));

                lasku[0].osoite = pars[0].katuosoite;
                lasku[0].postinumero = pars[0].postinumero;
                lasku[0].maa = pars[0].maa;
              })
            }

            console.log(JSON.stringify(lasku, null, "    "));
            res.render(__dirname + '/views/sivut/laskutus.hbs', { laskut, lasku, layout: false });
          }
          );
        });
      }
    }
  }
})

app.get("/mainosesitysraportit", (req, res) => {
  res.redirect("/mainokset")
})

app.get('/mainosesitysraportit/:mainosid', (req, res) => {
  // Esittää tietyn mainoksen kaikki esityskerrat, sekä muuta tietoa
  let quer = `select  mk.nimi as kampanja, m.nimi as mainos, ma.nimi as mainostaja, e.pvm, e.kloaika, k.sukupuoli, k.ika, k.maa, k.paikkakunta from
  mainos m inner join mainoskampanja mk on m.kampanjaid = mk.kampanjaid
  inner join yhdiste_kampanja yk on yk.kampanjaid = m.kampanjaid
  inner join esitys e on e.mainosid = m.mainosid
  inner join kuuntelija k on k.nimimerkki = e.kuuntelijatunnus
  left join mainostaja ma on ma.vat = yk.mainostajaid
  where m.mainosid = ${req.params.mainosid}`

  let success = false;
  client.query(quer, (err, result) => {

    let data = result.rows;
    if (data.length == 0) {
      client.query(`select  mk.nimi as kampanja, m.nimi as mainos, ma.nimi as mainostaja from
    mainos m inner join mainoskampanja mk on m.kampanjaid = mk.kampanjaid
    inner join yhdiste_kampanja yk on yk.kampanjaid = m.kampanjaid
    left join mainostaja ma on ma.vat = yk.mainostajaid where m.mainosid = ${req.params.mainosid}`, (err, result) => {

        var empty = {
          msg: "Tällä mainoksella ei ole vielä esityksiä"
        }
        info = result.rows[0]
        success = true
        res.render(__dirname + "/views/sivut/mainosesitysraportit.hbs", { info, empty, layout: false })
      })
    } else {


      var info = {
        kampanja: data[0].kampanja,
        mainostaja: data[0].mainostaja,
        mainos: data[0].mainos
      }
      for (let i = 0; i < data.length; i++) {
        data[i].pvm = data[i].pvm.toString().split("00:")[0]
        data[i].kloaika = data[i].kloaika.split('.')[0]
      }
      success = true;
      res.render(__dirname + "/views/sivut/mainosesitysraportit.hbs", { data, info, layout: false })

    }


    // console.log(foo);

  })




})

app.get('/login', (req, res) => {

  res.render(__dirname + '/views/sivut/login.hbs', { layout: false, kayttajatunnus: "", salasana: "" })

})

app.post('/login', passport.authenticate('local', {
  successRedirect: '/',
  failureRedirect: '/login',
  failureFlash: false
}))

// app.post('/login', urlencodedParser, (req, res) => {
//   const { kayttajatunnus, salasana } = req.body

//   // Chekataan kannasta, että onko kayttajatunnus ja salasana oikein
//   client.query('select * from jarjestelma_kirjautumistiedot where kayttajatunnus=\'' + kayttajatunnus + '\' and ' + 'salasana=\'' + salasana + '\'', (err, result) => {

//     // if (err) {
//     //   console.log("kirjautuminen epäonnistui");
//     //   res.render(__dirname + '/views/sivut/login.hbs', { layout: false, kayttajatunnus: "", salasana: "" })
//     // }

//     try {

//       if (result.rows.length > 0) {
//         console.log('kirjautuminen onnistui')
//         res.redirect('/mainokset')
//         // res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false })
//       }
//       else {
//         console.log("Käyttäjätunnusta tai salasanaa ei löydetty");
//         res.redirect("/login")
//       }

//     } catch (error) {
//       console.log('vittusaatana: ' + error)

//     }
//   })
// })

Handlebars.registerHelper("each_with", function (items, attr, options, value = "") {

  let result = ""

  console.log(value)

  if (value) {
    for (let i = 0; i < items.length; i++) {
      if (items[i][attr] == value) {

        result += options.fn(items[i])
      }
    }

  }
  // else {
  //
  //   for (let i = 0; i < items.length; i++) {
  //     result += options.fn(items[i])
  //   }
  //
  // }

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
//get request laskun lisäämiselle
app.get('/lisaalasku', (req, res) => {
  client.query(('SELECT * FROM mainoskampanja WHERE tila = false'), function (err, result) {
    if (err) throw err;
    var kampanjat = JSON.parse(JSON.stringify(result.rows));
    console.log(kampanjat);
    res.render(__dirname + '/views/sivut/lisaalasku.hbs', { kampanjat, layout: false });
  });
})
app.post('/lisaalasku', (req, res) => {
  console.log(req.body);
  var qstring = `
      INSERT INTO lasku (
        kampanjaid,
        lahetyspvm,
        eraPvm,
        tila,
        viitenro
      )
      VALUES(
        ${req.body.kampanjaid},
        null,
        '${req.body.erapaiva}',
        false,
        '${req.body.viitenro}'
      )`
  client.query((qstring), function (err, result) {
    if (err) throw err;
    console.log('succesful insert');
    res.redirect('/laskutus')
  })
  console.log(qstring);

})
app.get('/muokkaalasku/:id', (req, res) => {
  console.log('keeneri' + req.params.id);
  var qstring = `SELECT * FROM lasku WHERE laskuid = ${req.params.id}`;
  console.log(qstring);
  client.query((qstring), function (err, result) {
    if (err) throw err;
    var lasku = JSON.parse(JSON.stringify(result.rows));
    console.log(lasku);
    res.render(__dirname + '/views/sivut/muokkaalasku.hbs', { lasku, layout: false })
  })
})
app.post('/muokkaalasku/:id', (req, res) => {
  console.log(req.body);
  var query = `UPDATE lasku
               SET lahetyspvm = '${req.body.lahetyspvm}',
               erapvm = '${req.body.eraPvm}',
               tila = ${req.body.tila},
               viitenro = '${req.body.viitenro}',
               viivastysmaksu = ${req.body.viivastysmaksu}
               WHERE laskuid = ${req.body.laskuid}
               `
  console.log(query);
  client.query((query), (err, result) => {
    if (err) throw err;
    else {
      console.log("succesful update");
      res.redirect('/laskutus')
    }
  })
})
app.get('/poistalasku/:id', (req, res) => {
  console.log(req.body);
  client.query((`SELECT * FROM lasku WHERE laskuid = ${req.params.id}`), function (err, result, fields) {

    const asd = result.rows;
    if (err) throw err;
    var laskut = JSON.parse(JSON.stringify(result.rows));
    console.log(laskut);
    res.render(__dirname + '/views/sivut/poistalasku.hbs', { laskut, layout: false })
  });
})
app.post('/poistalasku/:id', (req, res) => {
  console.log(req.body);
  if (req.body.vastaus == "Ei") {
    res.redirect('/laskutus');
  }
  else {
    var query = `DELETE FROM lasku WHERE laskuid = ${req.body.laskuid}`;
    client.query((query), (err, result) => {
      if (err) throw err;
      else {
        res.redirect('/laskutus');
      }
    })
  }
})
app.get('/lisaakarhulasku/:id', (req, res) =>{
    console.log(req.params.id);
    var numero = req.params.id
    res.render(__dirname + '/views/sivut/lisaakarhulasku.hbs', { numero, layout: false });
})
app.post('/lisaakarhulasku/:id', (req, res)=>{
    console.log(req.body);
    let query = `INSERT INTO karhulasku(karhulaskuid, laskuid, viivastysmaksu, )`
})
app.get('/lahetalasku/:id', (req, res) => {
   console.log(req.params.id);
   client.query((`SELECT * FROM laskutustiedot lt INNER JOIN laskutusosoite lo
      ON lt.laskutusosoiteid = lo.osoiteid
      INNER JOIN mainoskampanja mk
      ON mk.kampanjaid = lt.kampanjaid
      WHERE laskuid = ${req.params.id}`), (err, result) =>{
      if(err) throw err;
      console.log(result.rows);
      var tiedot = JSON.parse(JSON.stringify(result.rows));
      console.log(tiedot[0].kampanjaid);
      client.query((`SELECT * FROM mainos m  FULL JOIN mainosten_kuuntelukerrat as m_k
        ON m_k.mainosid = m.mainosid
        WHERE kampanjaid = ${tiedot[0].kampanjaid}`), (err, result) =>{
        if(err) throw err;
        console.log(result.rows);
        var mainokset = JSON.parse(JSON.stringify(result.rows));
        console.log(tiedot[0].sekuntihinta);
        var sekuntihinta = parseFloat(tiedot[0].sekuntihinta);
        for(let x of mainokset){
          var tt = x.pituus.split(":");
          var sec = tt[0] * 3600 + tt[1] * 60 + tt[2] * 1;
          let yhe_hinta = sekuntihinta * sec;
          console.log(yhe_hinta);
          let kuuntelut = parseInt(x.lkm);
          x.kuuntelukerrat = kuuntelut
          let mainos_hinta = kuuntelut * yhe_hinta;
          x.mainoksen_hinta = mainos_hinta;
        }
        console.log(mainokset);
        tiedot[0].mainokset = mainokset;
      })
      res.render(__dirname + '/views/sivut/laskulahetys.hbs', { tiedot, layout: false })
   })
})
app.post('/laskulahetys/:id', (req, res) =>{
  console.log(req.body.a);
  var tila = JSON.parse(JSON.stringify(req.body.a));
  console.log(tila);
  if(tila == 'false'){
    console.log("lähetys onnistui");
    // req.flash('message', 'NEEKERI');
    // res.redirect('/laskutus')
  }
  else{
    console.log("lähetys epäonnistui");
  }

})

app.get('/kampanjat/:id', (req, res) => {

})

app.post('/kampanjat/:id', (req, res) => {

  // Päivitä kampanja?
  let query = `select `;
})


app.listen(PORT, () =>
  console.log("Localhost listening on port: " + PORT));
