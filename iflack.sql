/*
	En oo laittanu vielä esim NOT NULL lisämääreitä iha hirvesti
	Koitan vasta saada jonkunäkösen kannan pystyyn ja kattoo mite toimii
	lisää sit noi virhetarkastelut myöhemmin

	
*/
-- Järjestelmän käyttäjä
-- Pitääköhän mainosmyyjä ja sihteeri erotella jotenki?
-- Eli pitääkö esim tähän laittaa rooli? tms.
CREATE TYPE rooli AS ENUM('sihteeri', 'myyjä');
CREATE TYPE sukupuoli AS ENUM('nainen', 'mies', 'muu');

CREATE TABLE jarjestelma_kayttaja (
  kayttajatunnus VARCHAR(30) PRIMARY KEY,
  etunimi VARCHAR NOT NULL,
  sukunimi VARCHAR NOT NULL,
  tyyppi rooli,
  tila BOOLEAN
);

CREATE EXTENSION chkpass;
-- Kirjautumistiedot
CREATE TABLE jarjestelma_kirjautumistiedot (
  kayttajatunnus VARCHAR(30) PRIMARY KEY,
  salasana chkpass NOT NULL,
  FOREIGN KEY(kayttaja_tunnus) REFERENCES jarjestelma_kayttaja(kayttaja_tunnus) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE postitoimipaikka(
  postinumero VARCHAR(8) PRIMARY KEY,
  check(postinumero ~ '^[0-9]+$'),
  pstoimipaikka VARCHAR(40)
);
CREATE TABLE laskutusosoite(
  osoiteId SERIAL PRIMARY KEY,
  postinumero VARCHAR(8),
  katuosoite VARCHAR(40),
  maa VARCHAR(20),
  FOREIGN KEY(postinumero) REFERENCES postitoimipaikka(postinumero)
);
-- Vois tehä funktion, joka automaattisesti etsii id:n kun sille antaa nimen/katuosoitteen/jotain muuta
CREATE TABLE yhteyshenkilo(
  hloId SERIAL PRIMARY KEY,
  etunimi VARCHAR(30),
  sukunimi VARCHAR(40),
  email VARCHAR(40),
  puhelinnumero VARCHAR(30)
);
-- Eikös tässä voi olla tilanne, jossa mainostajalla ei ole yhteyshenkilöä?
-- Jos poistetaan yhteyshenkilö, tilalle jää null- arvo
-- oliko tää sallittua 
-- pitäis olla sallittu, koska ei voida vaihtaa yhteyshenkilöö poistamatta edellistä
CREATE TABLE mainostaja(
  vat VARCHAR(30) PRIMARY KEY,
  nimi VARCHAR(30),
  yhteysHloId integer,
  laskutusosoiteId integer,
  FOREIGN KEY(laskutusosoiteId) REFERENCES laskutusosoite(osoiteId) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY(yhteysHloId) REFERENCES yhteyshenkilo(hloId) ON UPDATE CASCADE ON DELETE SET NULL
);
-- Experimental
CREATE TABLE lasku(
  laskuId SERIAL PRIMARY KEY,
  kampanjaId int,
  lahetyspvm DATE,
  eraPvm DATE,
  tila boolean,
  viitenro VARCHAR(20),
  korko decimal(5, 2),
  FOREIGN KEY(kampanjaId) REFERENCES mainoskampanja(kampanjaId) ON UPDATE NO ACTION ON DELETE NO ACTION
);
CREATE TABLE profiili(
  profiiliId SERIAL PRIMARY KEY,
  lahetysAika TIME,
  maa VARCHAR(20),
  paikkakunta VARCHAR(40),
  alaikaraja integer,
  CHECK(alaikaraja > 0),
  ylaikaraja integer,
  CHECK(ylaikaraja > 0)
);
-- Tämä ei tarkista vielä sitä xor- suhdetta profiilin ja mainoksen välillä
-- XOR suhteen tarkastus varmaan järkevin tehdä triggerillä
CREATE TABLE mainoskampanja(
  kampanjaId SERIAL PRIMARY KEY,
  laskuId integer,
  FOREIGN Key(laskuId) REFERENCES lasku(laskuId) ON UPDATE CASCADE ON DELETE
  SET NULL,
    nimi VARCHAR(40),
    alkupvm DATE DEFAULT CURRENT_DATE,
    loppupvm DATE,
    maaraRahat numeric(8, 2),
    -- Miljoona suurin luku, tuleeko ongelmia?
    sekuntihinta numeric(4, 2),
    -- Ei varmaankaan yli 100€ sekuntihintaa?
    tila boolean DEFAULT false NOT NULL,
    -- enabled/disabled
    profiiliId integer,
    FOREIGN Key(profiiliId) REFERENCES profiili(profiiliId) ON UPDATE CASCADE ON DELETE
  SET
    NULL
);
-- Muutin laskurivin ja laskun vierasavaimen suunnan
-- Nyt laskurivi ottaa vierasavaimekseen laskuId:n
-- Lisäksi mietin, että kampanjaId olisi viisaampi siirtää lasku-relaatioon
-- Miksi kampanjaId:tä tarvittaisiin laskurivin yhteydessä?
-- Mun mielestä olis parempi jos siirtäis sen laskuun, en toki vielä näin tehnyt
CREATE TABLE laskurivi(
  riviId SERIAL PRIMARY KEY,
  laskuId int,
  selite VARCHAR(40),
  hinta numeric(8, 2),
  FOREIGN KEY(laskuId) REFERENCES lasku(laskuId) ON DELETE CASCADE
);
CREATE TABLE jingle (
  jingleID SERIAL PRIMARY KEY,
  tiedoston_sijainti TEXT,
  nimi TEXT
);
CREATE TABLE genre(
  genreID SERIAL PRIMARY KEY,
  nimi VARCHAR(50)
);
-- HUOM! Tässä ei tuota mainoksen viite-eheyttä oltu mietitty
-- Päätin sit että update ja delete on cascade, saa muuttaa
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
  CHECK(
    ika > 0
    and ika < 150
  ),
  -- tää järkevin varmaa määrittämällä jotkut arvot mitä sukupuoli voi saada tai booleanilla
  sukupuoli sukupuoli,
  hinta numeric(5, 2),
  maa VARCHAR(20),
  paikkakunta VARCHAR(40),
  sahkoposti VARCHAR(40)
);
CREATE TABLE esitys (
  esitysId SERIAL PRIMARY KEY,
  kuuntelijaTunnus VARCHAR(30) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE NO ACTION,
  mainosId integer REFERENCES mainos(mainosId) ON UPDATE CASCADE ON DELETE NO ACTION,
  pvm DATE,
  kloaika TIME,
  UNIQUE(kuuntelijaTunnus, mainosId)
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

CREATE TABLE teos (
teosID SERIAL PRIMARY KEY,
nimi VARCHAR(100),
julkaisuvuosi DATE
);

CREATE TABLE musiikintekija (
tekijaID SERIAL PRIMARY KEY,
nimi VARCHAR(40),
rooli VARCHAR(40)
);

-- PUID tietohakemistossa 32{M}40, Tein funktion, joka generoi automaattisesti
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

--en tiedä onko id ja nimi nyt sama juttu mut tein kuitenki ku muissakin on?
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

--järjestysnumerolle jokin parempi tietotyyppi?

CREATE TABLE kokoelmateos (
kokoelmaID INTEGER,
teosID INTEGER,
jarjestysnumero NUMERIC,
PRIMARY KEY(kokoelmaID, teosID),
FOREIGN KEY(kokoelmaID) REFERENCES kokoelma(kokoelmaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

--molemmat vierasavaimet viittaavat samaan, haittaako?

CREATE TABLE karhulasku (
karhulaskuId INTEGER,
laskuId INTEGER,
PRIMARY KEY(karhulaskuId, laskuId),
FOREIGN KEY(karhulaskuId) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(laskuId) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE NO ACTION
);

--tähän keksin itse laskuIdn viite-eheyden kun puuttui, tsekkaa

CREATE TABLE yhdiste_kampanja (
kampanjaID INTEGER,
mainostajaID VARCHAR(30),
kayttajatunnus VARCHAR(30),
laskuId INTEGER,
PRIMARY KEY(kampanjaID, mainostajaID, kayttajatunnus, laskuId),
FOREIGN KEY(kampanjaID) REFERENCES mainoskampanja(kampanjaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(mainostajaID) REFERENCES mainostaja(VAT) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(kayttajatunnus) REFERENCES jarjestelma_kayttaja(kayttaja_tunnus) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(laskuId) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE NO ACTION
);