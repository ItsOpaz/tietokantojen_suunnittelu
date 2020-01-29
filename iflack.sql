/*
	En oo laittanu vielä esim NOT NULL lisämääreitä iha hirvesti
	Koitan vasta saada jonkunäkösen kannan pystyyn ja kattoo mite toimii
	lisää sit noi virhetarkastelut myöhemmin

	
*/

-- uudet tietotyypit roolille ja sukupuolelle, jotta helpompi käsitellä
CREATE TYPE rooli AS ENUM('sihteeri', 'myyjä');
CREATE TYPE sukupuoli AS ENUM('nainen', 'mies', 'muu');

-- Järjestelmän käyttäjä
CREATE TABLE jarjestelma_kayttaja (
  kayttajatunnus VARCHAR(30) PRIMARY KEY,
  etunimi VARCHAR NOT NULL,
  sukunimi VARCHAR NOT NULL,
  tyyppi rooli NOT NULL,
  tila BOOLEAN
);

CREATE EXTENSION chkpass;
-- Kirjautumistiedot
CREATE TABLE jarjestelma_kirjautumistiedot (
  kayttajatunnus VARCHAR(30) PRIMARY KEY,
  salasana chkpass NOT NULL,
  FOREIGN KEY(kayttajatunnus) REFERENCES jarjestelma_kayttaja(kayttajatunnus) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE postitoimipaikka(
  postinumero VARCHAR(8) PRIMARY KEY,
  -- tarkistetaan onko postinumero numeroita (mahdollinen ehkä tehdä suoraan
  -- käyttöliittymään)
  check(postinumero ~ '^[0-9]+$'),
  postoimipaikka VARCHAR(40)
);

CREATE TABLE laskutusosoite(
  osoiteId SERIAL PRIMARY KEY,
  postinumero VARCHAR(8),
  katuosoite VARCHAR(40),
  maa VARCHAR(20),
  FOREIGN KEY(postinumero) REFERENCES postitoimipaikka(postinumero)
);

CREATE TABLE yhteyshenkilo(
  hloId SERIAL PRIMARY KEY,
  etunimi VARCHAR(30),
  sukunimi VARCHAR(40),
  email VARCHAR(40),
  puhelinnumero VARCHAR(30)
);

-- Jos poistetaan yhteyshenkilö, tilalle jää null- arvo
CREATE TABLE mainostaja(
  vat VARCHAR(30) PRIMARY KEY,
  nimi VARCHAR(30),
  yhteysHloId integer,
  laskutusosoiteId integer,
  FOREIGN KEY(laskutusosoiteId) REFERENCES laskutusosoite(osoiteId) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY(yhteysHloId) REFERENCES yhteyshenkilo(hloId) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE genre(
  genreID SERIAL PRIMARY KEY,
  nimi VARCHAR(50)
);

CREATE TABLE teos (
teosID SERIAL PRIMARY KEY,
nimi VARCHAR(100),
julkaisuvuosi smallint
);

CREATE TABLE musiikintekija (
tekijaID SERIAL PRIMARY KEY,
nimi VARCHAR(40),
rooli VARCHAR(40)
);

-- PUID tietohakemistossa 32{M}40, Tehty funktio, joka generoi automaattisesti
-- satunnaisen merkkijonon
-- select rand_puid();
CREATE TABLE musiikkikappale (
PUID TEXT PRIMARY KEY,
teosID INTEGER,
kesto TIME,
aanitiedosto VARCHAR(40),
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE kokoelma (
kokoelmaID SERIAL PRIMARY KEY,
teosID INTEGER,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE profiili(
  profiiliId SERIAL PRIMARY KEY,
  alkulahetysAika TIME,
  loppulahetysAika TIME,
  maa VARCHAR(20),
  paikkakunta VARCHAR(40),
  alaikaraja integer,
  sukupuoli sukupuoli,
  genre integer,
  esittaja integer ,
  kappale TEXT,
  CHECK(alaikaraja > 0),
  ylaikaraja integer,
  CHECK(ylaikaraja > 0),
  FOREIGN KEY(genre) REFERENCES genre(genreID) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY(esittaja) REFERENCES musiikintekija(tekijaID) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY(kappale) REFERENCES musiikkikappale(puid) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE mainoskampanja(
  kampanjaId SERIAL PRIMARY KEY,
  nimi VARCHAR(40),
  alkupvm DATE DEFAULT CURRENT_DATE,
  loppupvm DATE,
  -- oletetaan, että ei yli miljoonan kampanjoita 
  maaraRahat numeric(8, 2),
  -- oletetaan että sekuntihinta ei yli 99, koska ei kukaan osta
  sekuntihinta numeric(4, 2),
  -- true = kampanja aktiivinen, false = lopetettu
  tila boolean DEFAULT true NOT NULL,
  profiiliId integer,
  FOREIGN Key(profiiliId) REFERENCES profiili(profiiliId) ON UPDATE CASCADE ON DELETE SET NULL
);

-- laskussa viivästysmaksu, joka tulee vain jos laskusta tehdään karhulasku, joka
-- on normi lasku, mutta yhdistetty alkuperäiseen laskuun karhulasku taulussa
-- ratkaisu tehty, jotta laskuja on helppo ketjuttaa
CREATE TABLE lasku(
  laskuId SERIAL PRIMARY KEY,
  -- laskun lähetetään oletettavasti luontipäivänä
  lahetyspvm DATE DEFAULT NOW(),
  eraPvm DATE,
  tila boolean,
  viitenro VARCHAR(20),
  viivastysmaksu numeric DEFAULT NULL,
);

CREATE TABLE jingle (
  jingleID SERIAL PRIMARY KEY,
  tiedoston_sijainti TEXT,
  nimi TEXT
);

CREATE TABLE mainos(
  mainosId SERIAL PRIMARY KEY,
  kampanjaId int,
  nimi VARCHAR(40),
  pituus TIME,
  kuvaus VARCHAR(300),
  esitysaika TIME,
  jingleId int,
  profiiliId int,
  
  CONSTRAINT mainos_kampanja_fk FOREIGN KEY(kampanjaId) REFERENCES mainoskampanja(kampanjaId) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT mainos_jingle_fk FOREIGN KEY(jingleId) REFERENCES jingle(jingleId) ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT mainos_profiili_fk FOREIGN KEY(profiiliId) REFERENCES profiili(profiiliId) ON UPDATE CASCADE ON DELETE
  SET
    NULL,
    UNIQUE(kampanjaId, jingleId, profiiliId)
);

CREATE TABLE kuuntelija(
  nimimerkki VARCHAR(30) PRIMARY KEY,
  ika integer,
  -- oletetaan, ettei kuuntelija riko ikäennätyksiä yli 25 vuodella
  CHECK(
    ika > 0
    and ika < 150
  ),
  sukupuoli sukupuoli,
  maa VARCHAR(20),
  paikkakunta VARCHAR(40),
  sahkoposti VARCHAR(40)
);

CREATE TABLE esitys (
  esitysId SERIAL PRIMARY KEY,
  kuuntelijaTunnus VARCHAR(30) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE NO ACTION,
  mainosId integer REFERENCES mainos(mainosId) ON UPDATE CASCADE ON DELETE NO ACTION,
  pvm DATE DEFAULT NOW(),
  kloaika TIME DEFAULT NOW()
);

CREATE TABLE musiikintekija (
  tekijaId SERIAL PRIMARY KEY,
  nimi VARCHAR(40),
  rooli VARCHAR(30)
);

CREATE TABLE kuuntelija_kirjautumistiedot (
nimimerkki VARCHAR(20) PRIMARY KEY,
salasana chkpass,
FOREIGN KEY(nimimerkki) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE
);

--huom onko kakkuri vaihtanut kuuntelijaID:n kuten puhuttiin? vaihdoin itse nyt IDn olemaan varchar
CREATE TABLE soittolista (
soittolistaID SERIAL PRIMARY KEY,
kuuntelijatunnus VARCHAR,
nimi VARCHAR(40),
FOREIGN KEY(kuuntelijatunnus) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_profiili_tekija (
profiiliID INTEGER,
tekijaID INTEGER,
PRIMARY KEY(profiiliID, tekijaID),
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tekijaID) REFERENCES musiikintekija(tekijaID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_profiili_kuuntelija (
profiiliID INTEGER,
nimimerkki VARCHAR(30),
PRIMARY KEY(profiiliID, nimimerkki),
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(nimimerkki) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE
); 

CREATE TABLE yhdiste_teos_genre (
teosID INTEGER,
genreID INTEGER,
PRIMARY KEY(teosID, genreID),
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(genreID) REFERENCES genre(genreID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_profiili_genre (
profiiliID INTEGER,
genreID INTEGER,
PRIMARY KEY(profiiliID, genreID),
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(genreID) REFERENCES genre(genreID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_teos_soittolista (
soittolistaID INTEGER,
teosID INTEGER,
PRIMARY KEY(soittolistaID, teosID),
FOREIGN KEY(soittolistaID) REFERENCES soittolista(soittolistaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE musarooli (
rooliID SERIAL PRIMARY KEY,
roolin_nimi VARCHAR(30)
);

CREATE TABLE yhdiste_teos_tekija_rooli (
teosID INTEGER,
tekijaID INTEGER,
rooliID INTEGER ,
PRIMARY KEY(teosID, tekijaID, rooliID),
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tekijaID) REFERENCES musiikintekija(tekijaID) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(rooliID) REFERENCES musarooli(rooliID) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE kokoelmateos (
kokoelmaID INTEGER,
teosID INTEGER,
jarjestysnumero NUMERIC,
PRIMARY KEY(kokoelmaID, teosID),
FOREIGN KEY(kokoelmaID) REFERENCES kokoelma(kokoelmaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- yhdistää karhulaskun ja alkuperäisen laskun
CREATE TABLE karhulasku (
karhulaskuId INTEGER,
laskuId INTEGER,
PRIMARY KEY(karhulaskuId, laskuId),
FOREIGN KEY(karhulaskuId) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE NO ACTION
FOREIGN KEY(laskuId) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Lasku olis ollut järkevämpi yhdistää suoraan kampanjaan, mutta valmiiden funktioiden ja
-- näkymien takia muuttaminen on hankalampaa, kuin nykyisen tilan käyttäminen
CREATE TABLE yhdiste_kampanja (
kampanjaID INTEGER,
mainostajaID VARCHAR(30),
kayttajatunnus VARCHAR(30),
laskuId INTEGER DEFAULT NULL,
PRIMARY KEY(kampanjaID, mainostajaID, kayttajatunnus, laskuId),
FOREIGN KEY(kampanjaID) REFERENCES mainoskampanja(kampanjaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(mainostajaID) REFERENCES mainostaja(VAT) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(kayttajatunnus) REFERENCES jarjestelma_kayttaja(kayttajatunnus) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(laskuId) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE NO ACTION
);