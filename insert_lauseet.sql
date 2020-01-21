

-- Kätevä tapa katsoa taulun sisältö on komennolla
-- table <tablename>;
-- vastaa siis komentoa select * from <tablename>

-- Testi dataa
INSERT INTO jarjestelma_kayttaja VALUES(
	'isoTony69',
	'Toni',
	'Halme',
	false);

INSERT INTO jarjestelma_kayttaja VALUES(
	'MenkaaToihin',
	'Donald',
	'Trump',
	false);


INSERT INTO jarjestelma_kirjautumistiedot (kayttaja_tunnus, salasana) VALUES(

		'MenkaaToihin',
		'BuildAWall'
);

INSERT INTO jarjestelma_kirjautumistiedot (kayttaja_tunnus, salasana) VALUES(

		'isoTony69',
		'painuPelleHiiteen'
);


INSERT INTO laskutusosoite (katuosoite, postinumero, postitoimipaikka, maa) VALUES(
	'tunitie 45',
	33720,
	'Tampere',
	'Suomi'
);

INSERT INTO laskutusosoite (katuosoite, postinumero, postitoimipaikka, maa) VALUES(
	'Koodarinkatu 69',
	33720,
	'Tampere',
	'Suomi'
);

INSERT INTO yhteyshenkilo(etunimi, sukunimi, email, puhelinnumero) VALUES(
	'Pekka', 'Penttilä', 'pekupena@tuni.fi', '6969696969'
);

INSERT INTO yhteyshenkilo(etunimi, sukunimi, email, puhelinnumero) VALUES(
	'Tietokanta', 'Osaaja', 'superkoodari@koodia.com', '040583834588'
);



INSERT INTO mainostaja VALUES(
	'45 TUNIPATSAS', -- vat
	'Mainostoimisto Masa', -- nimi
	1, -- yht. hlö. id
	1 -- laskutusosoite id
);

INSERT INTO mainostaja VALUES(
	'89KOODAAJA', -- vat
	'Kooditorio', -- nimi
	2, -- yht. hlö. id
	2 -- laskutusosoite id
);




INSERT INTO lasku (	kampanjaid, lahetyspvm,eraPvm, tila, viitenro, korko) VALUES(
		1,		
		'2020-1-20',
		'2020-2-20',
		false,
		'123452346',
		6.50
);




INSERT INTO profiili VALUES (
	1,
	'00:00',
	'Suomi',
	'Tampere',
	3,
	null
);

INSERT INTO mainoskampanja (laskuId, nimi, loppupvm, maaraRahat, sekuntihinta, tila, profiiliId) VALUES(

	1,
	'masan mainoskampanja',
	'2020-08-30',
	100.00,
	0.20,
	false,
	1
);

INSERT INTO mainoskampanja (laskuId, nimi, loppupvm, maaraRahat, sekuntihinta, tila, profiiliId) VALUES(

	1,
	'masan mainoskampanja',
	'2020-08-30',
	100.00,
	0.20,
	false,
	1
);

INSERT INTO laskurivi(selite, laskuId, hinta) VALUES (
	'Perkeleen kallis mainos',
	1,
	99.99
	
);

INSERT INTO laskurivi(selite, laskuId, hinta) VALUES (
	'Testimainos',
	1,
	10.00
	
);


UPDATE lasku SET riviId = 1 WHERE laskuId = 1;

INSERT INTO kuuntelija VALUES (
    
)