-- Kätevä tapa katsoa taulun sisältö on komennolla
-- table <tablename>;
-- vastaa siis komentoa select * from <tablename>



-- Testi dataa
INSERT INTO jarjestelma_kayttaja
VALUES('isoTony69', 'Toni', 'Halme', false);
INSERT INTO jarjestelma_kayttaja
VALUES(
    'MenkaaToihin',
    'Donald',
    'Trump',
    false
  );

-- Kirjautumistietoja, älä käytä tätä!
-- Käytä 
-- select lisaa_kayttaja('etunimi', 'sukunimi', 'käyttäjätunnus', 'salasana')
INSERT INTO jarjestelma_kirjautumistiedot (kayttaja_tunnus, salasana)
VALUES('MenkaaToihin', 'BuildAWall');


INSERT INTO jarjestelma_kirjautumistiedot (kayttaja_tunnus, salasana)
VALUES('isoTony69', 'painuPelleHiiteen');

-- Laskutusosoitteet
SELECT lisaa_laskutusosoite(
    'tunitie 45',
    '33720',
    'Tampere',
    'Suomi'
  );

SELECT lisaa_laskutusosoite(
    'Koodarinkatu 69',
    '33720',
    'Tampere',
    'Suomi'
  );

SELECT lisaa_laskutusosoite(
  'Teekkarinkatu 23',
  '33720',
  'Tampere',
  'Suomi'
);

-- Yhteyshenkilöt
INSERT INTO yhteyshenkilo(etunimi, sukunimi, email, puhelinnumero)
VALUES(
    'Pekka',
    'Penttilä',
    'pekupena@tuni.fi',
    '6969696969'
  );
INSERT INTO yhteyshenkilo(etunimi, sukunimi, email, puhelinnumero)
VALUES(
    'Tietokanta',
    'Osaaja',
    'superkoodari@koodia.com',
    '040583834588'
  );

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
    '45 TUNIPATSAS',
    -- vat
    'Mainostoimisto Masa',
    -- nimi
    1,
    -- yht. hlö. id
    1 -- laskutusosoite id
  );
INSERT INTO mainostaja
VALUES(
    '89KOODAAJA',
    -- vat
    'Kooditorio',
    -- nimi
    2,
    -- yht. hlö. id
    2 -- laskutusosoite id
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
  3,
  '2020-1-20',
  '2020-2-20',
  false,
  '123452346',
  6.50
);



INSERT INTO profiili
VALUES
  (
    1,
    '00:00',
    'Suomi',
    'Tampere',
    3,
    null
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

INSERT INTO profiili(
    lahetysaika,
    maa,
    paikkakunta,
    alaikaraja,
    ylaikaraja
  )
VALUES
  (
    '00:00',
    'Suomi',
    'Helsinki',
    18,
    null
  );
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
    'masan mainoskampanja',
    '2020-08-30',
    100.00,
    0.20,
    false,
    1
  );
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
    2,
    'Tonyn mainoskampanja',
    '2020-08-30',
    69.00,
    0.20,
    false,
    null
);


INSERT INTO jingle(tiedoston_sijainti, nimi) VALUES(
  '/home/tikasu/tonihalme.mp3',
  'Toni Halme-Painu pelle hiiteen'
);

INSERT INTO genre(nimi) VALUES(
  'Halme rock'
);

INSERT INTO mainos(kampanjaId, nimi, pituus, kuvaus, esitysaika, jingleId, profiiliId) VALUES(
  3,
  'Halmeen eka mainos',
  '03:20',
  'Toni Halmeen hempeä esitys',
  '00:00',
  1,
  1
);

INSERT INTO laskurivi(selite, laskuId, hinta)
VALUES
  ('Perkeleen kallis mainos', 2, 99.99);
INSERT INTO laskurivi(selite, laskuId, hinta)
VALUES
  ('Testimainos', 2, 10.00);