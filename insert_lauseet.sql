
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

INSERT INTO yhteyshenkilo(etunimi, sukunimi, email, puhelinnumero) VALUES(
	'Pekka', 'Penttilä', 'pekupena@tuni.fi', '6969696969'
);


INSERT INTO mainostaja VALUES(
	'45 TUNIPATSAS', -- vat
	'Mainostoimisto Masa', -- nimi
	1, -- yht. hlö. id
	1 -- laskutusosoite id
);


INSERT INTO lasku (	lahetyspvm,
					eraPvm,
					tila,
					viitenro,
					korko,
					riviId) VALUES(
						
						'2020-11-1',
						'2020-11-2',
						false,
						'123452346',
						12.00,
						NULL

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

INSERT INTO laskurivi(selite, hinta, kampanjaId) VALUES (
	'Perkeleen kallis mainos',
	99.99,
	1
);

INSERT INTO kuuntelija VALUES (
    
)