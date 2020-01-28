-- Kätevä tapa katsoa taulun sisältö on komennolla
-- table <tablename>;
-- vastaa siis komentoa select * from <tablename>


-- select lisaa_kayttaja('etunimi', 'sukunimi', 'käyttäjätunnus', 'salasana')

SELECT lisaa_kayttaja('Pekka', 'Salminen', 'peksa08', 'PeksaOnKovaUkko87!');
-- Laskutusosoitteet
SELECT lisaa_laskutusosoite(
    'Opiskelijankatu 18',
    '33720',
    'Tampere',
    'Suomi'
);


-- Yhteyshenkilöt
INSERT INTO yhteyshenkilo(etunimi, sukunimi, email, puhelinnumero)
VALUES(
    'Mikko',
    'Mainio',
    'mikko.mainio@gmail.com',
    '0405838345'
);

-- Mainostajaan liittyvät lisäykset
INSERT INTO mainostaja
VALUES(
    'FI19195944',
    -- vat
    'Mainostoimisto Masa',
    -- nimi
    5,
    -- yht. hlö. id
    4 -- laskutusosoite id
);

INSERT INTO profiili (lahetysaika, maa, paikkakunta, alaikaraja, ylaikaraja)
VALUES
  (
    '00:00',
    'Suomi',
    'Tampere',
    6,
    null
);

INSERT INTO profiili (lahetysaika, maa, paikkakunta, alaikaraja, ylaikaraja)
VALUES
  (
    '17:30',
    'Suomi',
    'Seinäjoki',
    18,
    35
);

INSERT INTO profiili (lahetysaika, maa, paikkakunta, alaikaraja, ylaikaraja)
VALUES
  (
    '00:00',
    'Suomi',
    'Helsinki',
    6,
    16
);

-- Kokeilkaa luoda mainoskampanja ilman profiilia ja lisätä siihen mainos ilman profiilia
-- Pitäis tulla erroria
INSERT INTO mainoskampanja (
    laskuId,
    nimi,
    loppupvm,
    maaraRahat,
    sekuntihinta,
    tila,
    profiiliId
  )
VALUES(
    1,
    'Masan mainoskampanja',
    '2020-08-30',
    100.00,
    0.20,
    false,
    4
  );

INSERT INTO lasku (
  kampanjaid,
  lahetyspvm,
  eraPvm,
  tila,
  viitenro,
  korko
)
VALUES(
  5,
  '2020-1-27',
  '2020-4-27',
  false,
  '123452346',
  8.0
);

-- laskuid, selite, hinta, kampanjaid
INSERT INTO laskurivi(laskuid, selite, hinta) VALUES(12, 'Imurimainoksen perusmaksu', 20.00);

INSERT INTO jingle(tiedoston_sijainti, nimi) VALUES(
  'https://mainostoimisto-masa.fi/mainokset/jingle/backgroung-pump-track.mp3',
  'Background pump track'
);

INSERT INTO jingle(tiedoston_sijainti, nimi) VALUES(
  'https://mainostoimisto-masa.fi/mainokset/jingle/backgroung-fast-track.mp3',
  'Background fast track'
);


INSERT INTO mainos(kampanjaId, nimi, pituus, kuvaus, esitysaika, jingleId, profiiliId) VALUES(
  5,
  'Miele P5500 imuri',
  '00:00:25',
  'Uuden imurin mainos, joka kertoo imurin ominaisuuksista',
  '00:00',
  2,
  5
);


INSERT into kuuntelija values(
  'markalapanen',
  22,
  'mies',
  'Suomi',
  'Tampere',
  'markalapanen@gmail.com'

);

INSERT into kuuntelija_kirjautumistiedot values (
  'markalapanen',
  'kitaraTaivasJaTahdet'
  
);

insert into esitys(kuuntelijaTunnus, mainosid) values(
  'markalapanen',
  5
);

insert into yhdiste_profiili_kuuntelija(

);

