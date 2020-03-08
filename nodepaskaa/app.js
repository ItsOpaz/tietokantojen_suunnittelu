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

const conString = "postgres://sqlmanager:keittovesan@localhost:5432/iflac";
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
    if (err) console.log(err.message);;
    var data = JSON.parse(JSON.stringify(result.rows));
    res.render(__dirname + '/views/sivut/mainokset.hbs', { data: data, layout: false });
  });

});

app.post("/mainokset", (req, res) => {
  console.log(req.body)
  let mainosid = Object.keys(req.body)[0]
  res.redirect(`/mainosesitysraportit/${mainosid}`);
})

app.get('/lisaa', (req, res) => {
  res.render(__dirname + '/views/sivut/lisaa.hbs', { layout: false });
});
app.post('/lisaa', (req, res) => {
  console.log(req.body);
  var querystring = `INSERT INTO mainos(kampanjaId, nimi, pituus, kuvaus, esitysaika, jingleId)
   VALUES($1, $2, $3, $4, $5, $6)`;
  client.query(querystring, [req.body.kampanjaid, req.body.nimi, req.body.pituus,
    req.body.kuvaus,req.body.esitysaika, req.body.jingle] ,
    (err, result) => {
      if (err) {
        console.log(err.message);
      }
      else (console.log("succes"));
    });
  res.redirect('/mainokset')
});


app.get('/laskutus', (req, res) => {
  client.query(('SELECT * FROM laskutustiedot ORDER BY laskuid DESC'), function (err, result, fields) {
    if (err) {
      console.log(err.message);
      res.redirect('/')
    }
    else{
    const asd = result.rows;
    var laskut = JSON.parse(JSON.stringify(result.rows));
    res.render(__dirname + '/views/sivut/laskutus.hbs', { laskut, layout: false });
  }
  });
})
app.post('/laskutus', (req, res) => {
  console.log(req.body);
  if (req.body.laskunumero == "all") {
    client.query(('SELECT * FROM laskutustiedot ORDER BY laskuid DESC'), function (err, result) {
      if (err) {
        console.log(err)
        res.redirect('/laskutus')
      }
      else{
        const asd = result.rows;
        laskut = JSON.parse(JSON.stringify(result.rows));
        res.render(__dirname + '/views/sivut/laskutus.hbs', { laskut, layout: false });
      }
    }
    )
  }
  else {
    if (req.body.mainostaja != null) {
      console.log(req.body.mainostaja);
      client.query((`SELECT * FROM laskutustiedot WHERE mainostaja = $1`),[req.body.mainostaja], function (err, result) {
        if (err) console.log(err.message);
        const asd = result.rows;
        laskut = JSON.parse(JSON.stringify(result.rows));
        res.render(__dirname + '/views/sivut/laskutus.hbs', { laskut, layout: false });
      }
      );
    }
    else {
      if (req.body.laskunumero > 1) {
        client.query(('SELECT * FROM laskutustiedot ORDER BY laskuid DESC'), function (err, result) {
          if (err) {
            console.log(err)
            res.redirect('/laskutus')
          }
          else{
            const asd = result.rows;
            laskut = JSON.parse(JSON.stringify(result.rows));
          }
        }
        )
        var list = [];
        client.query((`SELECT * FROM laskutustiedot lt INNER JOIN laskutusosoite lo
            ON lt.laskutusosoiteid = lo.osoiteid
            INNER JOIN mainoskampanja mk
            ON mk.kampanjaid = lt.kampanjaid
            WHERE laskuid = $1`), [req.body.laskunumero], (err, result) => {
          if (err) console.log(err.message);
          else{
            var tiedot = JSON.parse(JSON.stringify(result.rows));
            if(tiedot.length == 0 ){
              res.redirect('/laskutus');
            }
            else{
            client.query(('SELECT eraPvm, viitenro, korko FROM lasku WHERE laskuid = $1'), [req.body.laskunumero], (err, result)=>{
              if (err) console.log(err.message);
              else{
                console.log(result.rows);
                tiedot[0].erapvm = result.rows[0].erapvm;
                tiedot[0].viitenro = result.rows[0].viitenro;
                tiedot[0].viivastysmaksu = result.rows[0].viivastysmaksu;
              }
            })
            console.log(tiedot.length);


            client.query((`SELECT * FROM mainos m  FULL JOIN mainosten_kuuntelukerrat as m_k
                ON m_k.mainosid = m.mainosid
                WHERE kampanjaid = $1`),[tiedot[0].kampanjaid], (err, result) =>{
                if(err) console.log(err.message);
                var mainokset = JSON.parse(JSON.stringify(result.rows));
                var sekuntihinta = parseFloat(tiedot[0].sekuntihinta);
                var laskun_hinta = 0;
                for(let x of mainokset){
                  var tt = x.pituus.split(":");
                  var sec = tt[0] * 3600 + tt[1] * 60 + tt[2] * 1;
                  let yhe_hinta = sekuntihinta * sec;
                  let kuuntelut = parseInt(x.lkm);
                  x.kuuntelukerrat = kuuntelut
                  let mainos_hinta = kuuntelut * yhe_hinta;
                  x.mainoksen_hinta = mainos_hinta;
                  if(isNaN(mainos_hinta)){
                    laskun_hinta = laskun_hinta + 0;
                  }
                  else{
                    laskun_hinta = laskun_hinta + mainos_hinta;
                  }
                }
                tiedot[0].laskun_hinta = laskun_hinta;
                tiedot[0].mainokset = mainokset;
                lasku = tiedot;
                res.render(__dirname + '/views/sivut/laskutus.hbs', { lasku, laskut , layout: false })
            })}
          }
      })
    }
      else{
        res.redirect('/laskutus');
      }
    }

  }
})

app.get("/mainosesitysraportit", (req, res) => {
  res.redirect("/mainokset")
})

app.get('/mainosesitysraportit/:mainosid', (req, res) => {
  // Esittää tietyn mainoksen kaikki esityskerrat, sekä muuta tietoa
  let quer = `select  ma.yhteyshloid, mk.nimi as kampanja, m.nimi as mainos, ma.nimi as mainostaja, e.pvm, e.kloaika, k.sukupuoli, k.ika, k.maa, k.paikkakunta from
  mainos m inner join mainoskampanja mk on m.kampanjaid = mk.kampanjaid
  inner join yhdiste_kampanja yk on yk.kampanjaid = m.kampanjaid
  inner join esitys e on e.mainosid = m.mainosid
  inner join kuuntelija k on k.nimimerkki = e.kuuntelijatunnus
  left join mainostaja ma on ma.vat = yk.mainostajaid
  where m.mainosid = $1`

  client.query(quer, [req.params.mainosid], async (err, result) => {
    if (err) {
      console.log(err.message)

    }
    let data = result.rows;
    if (data.length == 0) {
      client.query(`select  mk.nimi as kampanja, m.nimi as mainos, ma.nimi as mainostaja from
    mainos m inner join mainoskampanja mk on m.kampanjaid = mk.kampanjaid
    inner join yhdiste_kampanja yk on yk.kampanjaid = m.kampanjaid
    left join mainostaja ma on ma.vat = yk.mainostajaid where m.mainosid = $1`,[req.params.mainosid], (err, result) => {

        var empty = {
          msg: "Tällä mainoksella ei ole vielä esityksiä"
        }
        info = result.rows[0]
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


      const email = await client.query(`select email from yhteyshenkilo where hloid = $1`, [data[0].yhteyshloid])

      sapo = email.rows[0].email


      res.render(__dirname + "/views/sivut/mainosesitysraportit.hbs", { data, info, sapo, layout: false })
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
    if (err) console.log(err.message);;
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
    if (err) console.log(err.message);;
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
        $1,
        $2,
        $3,
        $4,
        $5
      )`
  client.query((qstring), [req.body.kampanjaid,
  null,
  req.body.erapaiva,
  false,
  req.body.viitenro], function (err, result) {
    if (err) console.log(err.message);;
    console.log('succesful insert');
    res.redirect('/laskutus')
  })
  console.log(qstring);

})
app.get('/muokkaalasku/:id', (req, res) => {
  console.log('keeneri' + req.params.id);
  var qstring = `SELECT * FROM lasku WHERE laskuid = $1`;
  console.log(qstring);
  client.query((qstring),[req.params.id], function (err, result) {
    if (err) console.log(err.message);
    var lasku = JSON.parse(JSON.stringify(result.rows));
    console.log(lasku);
    res.render(__dirname + '/views/sivut/muokkaalasku.hbs', { lasku, layout: false })
  })
})
app.post('/muokkaalasku/:id', (req, res) => {
  console.log(req.body);
  var query = `UPDATE lasku
               SET lahetyspvm = $1,
               erapvm = $2,
               tila = $3,
               viitenro = $4,
               korko = NULL
               WHERE laskuid = $5
               `
  client.query((query), [req.body.lahetyspvm, req.body.eraPvm, req.body.tila, req.body.viitenro , req.body.laskuid], (err, result) => {
    if (err) console.log(err.message);
    else {
      console.log("succesful update");
      res.redirect('/laskutus')
    }
  })
})
app.get('/poistalasku/:id', (req, res) => {
  console.log(req.params.id);
  client.query((`SELECT * FROM lasku WHERE laskuid = $1`), [req.params.id], function (err, result) {
    const asd = result.rows;
    if (err) console.log(err.message);
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
    var query = `DELETE FROM lasku WHERE laskuid = $1`;
    client.query((query), [req.body.laskuid], (err, result) => {
      if (err){
        console.log(err.message);
        res.redirect('/laskutus')
      }
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
    let query = `INSERT INTO karhulasku(karhulaskuid, laskuid, viivastysmaksu )
                VALUES($1, $2, $3)`
    client.query((query),[req.body.karhulaskuid, req.body.laskuid, req.body.viivastysmaksu ], (err, result)=>{
      if(err) console.log(err.message);
      else{
        console.log(result.rows);
        res.redirect('/laskutus')
      }
    })

})
app.get('/lahetalasku/:id', (req, res) => {
  console.log(req.params.id);
  client.query((`SELECT * FROM laskutustiedot lt INNER JOIN laskutusosoite lo
      ON lt.laskutusosoiteid = lo.osoiteid
      INNER JOIN mainoskampanja mk
      ON mk.kampanjaid = lt.kampanjaid
      WHERE laskuid = $1`),[req.params.id], (err, result) => {
    if (err) console.log(err.message);;
    console.log(result.rows);
    var tiedot = JSON.parse(JSON.stringify(result.rows));
    console.log(tiedot[0].kampanjaid);
    client.query((`SELECT * FROM mainos m  FULL JOIN mainosten_kuuntelukerrat as m_k
        ON m_k.mainosid = m.mainosid
        WHERE kampanjaid = $1`), [tiedot[0].kampanjaid], (err, result) =>{
        if(err) console.log(err.message);;
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

app.get('/kuukausiraportit', (req, res) => {
  let q = `Select * from mainostaja`
  client.query(q)
    .then(result => {
      return result.rows
    }).then(mainostajat => {
      res.render(__dirname + "/views/sivut/mainostajat.hbs", { mainostajat, layout: false })
    })
})

app.post("/kuukausiraportit", (req, res) => {


  let vat = Object.keys(req.body)[0]
  res.redirect(`/kuukausiraportit/${vat}`);

})

app.post("/kuukausiraportit/search", (req, res) => {
  res.redirect(`/kuukausiraportit/search/${req.body.filter}`)
})

app.get('/kuukausiraportit/search', (req, res) => {
  res.redirect('/kuukausiraportit')
})

app.get('/kuukausiraportit/search/:filter', async (req, res) => {

  let q = `Select * from mainostaja where nimi like '%${req.params.filter}%'`

  client.query(q)
    .then(result => {

      return result.rows
    }).then(mainostajat => {

      if (mainostajat.length == 0) {
        var error = { message: 'Ei hakutuloksia' }
        res.render(__dirname + "/views/sivut/mainostajat.hbs", { error, layout: false })
      } else {
        res.render(__dirname + "/views/sivut/mainostajat.hbs", { mainostajat, layout: false })

      }
    })
})
// Pakko rakentaa tämmönen helper-funktio, jota voi käyttää,
// jos haluaa monelle kampanjaid:lle hakea mainokset
// Kunei se perkeleen näkymä toimi tuola kannassa
// Menkää saatana töihin!!!!!
const getAds = (campaigns) => {
  const foo = campaigns.rows.map(async camp => {
    const kampanjaid = camp.kampanjaid;
    q = `select mainosid, nimi, pituus, esitysaika, profiiliid from mainos where kampanjaid = '${kampanjaid}'`
    return await client.query(q)
      .then(adData => {
        return adData.rows
      })
  })
  return Promise.all(foo)
}

app.get("/kuukausiraportit/:vat", async (req, res) => {

  let d = new Date()
  let date = {
    day: d.getDay(),
    month: d.getMonth(),
    year: d.getFullYear()
  }
  let q = `select vat, nimi, katuosoite, p.postinumero, p.postoimipaikka
   from mainostaja left join yhteyshenkilo on yhteyshloid = hloid
    left join laskutusosoite on laskutusosoiteid = osoiteid
    inner join postitoimipaikka p on laskutusosoite.postinumero = p.postinumero
    where mainostaja.vat = '${req.params.vat}'`
  let data = []
  await client.query(q)
    .then(d => {
      data = d.rows[0]

    })


  q = `select kampanjaid, nimi, profiiliid, sekuntihinta from mainoskampanja where mainostajaid = '${data.vat}'`
  let campaigns = await client.query(q)
  let ads = await getAds(campaigns)
  let summary = {
    yht: 0,
    kokonaispituus: 0,
    price: 0
  }
  for (let i = 0; i < ads.length; i++) {
    ads[i].nimi = campaigns.rows[i].nimi
    for (let j = 0; j < ads[i].length; j++) {
      const current = ads[i][j];
      let [h, m, s] = current.pituus.split(":")
      current.pituus = parseInt(s) + parseInt(m) * 60 + parseInt(h) * 60 * 60
      let [hh, mm, ss] = current.esitysaika.split(":")

      current.lkm = Math.ceil((parseInt(ss) + parseInt(mm) * 60 + parseInt(hh) * 60 * 60) / current.pituus)
      current.sekuntihinta = campaigns.rows[i].sekuntihinta

      if (current.profiiliid == null) {
        current.profiiliid = campaigns.rows[i].profiiliid
      }
      q = `select alkulahetysaika, loppulahetysaika from profiili where profiiliid = ${current.profiiliid}`
      const times = await client.query(q);
      current.alku = times.rows[0].alkulahetysaika
      current.loppu = times.rows[0].loppulahetysaika


      current.hinta = current.sekuntihinta * current.lkm
      summary.price += current.hinta
      summary.kokonaispituus += current.pituus * current.lkm
      summary.yht += current.lkm

    }
  }

  res.render(__dirname + "/views/sivut/kuukausiraportit.hbs", { data, ads, date, summary, layout: false })

})

app.listen(PORT, () =>
  console.log("Localhost listening on port: " + PORT))
