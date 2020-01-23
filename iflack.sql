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
  kayttaja_tunnus VARCHAR(30) PRIMARY KEY,
  etunimi VARCHAR NOT NULL,
  sukunimi VARCHAR NOT NULL,
  tyyppi rooli,
  tila BOOLEAN
);
-- Kirjautumistiedot
CREATE TABLE jarjestelma_kirjautumistiedot (
  kayttaja_tunnus VARCHAR(30) PRIMARY KEY,
  salasana VARCHAR NOT NULL,
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
  tiedoston_sijainti VARCHAR(40),
  nimi VARCHAR(30)
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