
/*
	En oo laittanu vielä esim NOT NULL lisämääreitä iha hirvesti
	Koitan vasta saada jonkunäkösen kannan pystyyn ja kattoo mite toimii
	lisää sit noi virhetarkastelut myöhemmin

	
*/

-- Järjestelmän käyttäjä

-- Pitääköhän mainosmyyjä ja sihteeri erotella jotenki?
-- Eli pitääkö esim tähän laittaa rooli? tms.
CREATE TABLE jarjestelma_kayttaja (
	
	kayttaja_tunnus VARCHAR(30) PRIMARY KEY,
	etunimi VARCHAR NOT NULL,
	sukunimi VARCHAR NOT NULL,
	tila BOOLEAN

);

-- Kirjautumistiedot
CREATE TABLE jarjestelma_kirjautumistiedot (
	
	kayttaja_tunnus VARCHAR(30) PRIMARY KEY,
	salasana VARCHAR NOT NULL,
	FOREIGN KEY(kayttaja_tunnus) REFERENCES jarjestelma_kayttaja(kayttaja_tunnus)
	ON DELETE CASCADE ON UPDATE CASCADE
);

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


-- Lisää uuden käyttäjän järjestelmään
-- Pitää kai lisätä virhetarkastelu vai voiko sen tehdä koodin puolella

-- first_name, last_name, user_name, password
CREATE OR REPLACE FUNCTION add_user(VARCHAR, VARCHAR, VARCHAR(30), VARCHAR) 
	RETURNS boolean AS 
	$func$
	
	BEGIN
		INSERT INTO jarjestelma_kayttaja VALUES(
			
			$3,
			$1,
			$2,
			false
		);

		IF NOT FOUND THEN
			RETURN FALSE;
		END IF;

		INSERT INTO jarjestelma_kirjautumistiedot VALUES(
			$3,
			$4
		);

		RETURN FOUND;
	END
	$func$ LANGUAGE plpgsql;


-- käyttö: SELECT add_user(etunimi, sukunimi, kayttaja_tunnus, salasana);

-- Tämä ei osaa vielä käsitellä väärässä muodossa olevia postinumeroja
-- Tarviiko sitä edes tarkistaa?
CREATE TABLE laskutusosoite(

	osoiteId SERIAL PRIMARY KEY,
	katuosoite VARCHAR(40),
	postinumero NUMERIC(5),
	postitoimipaikka VARCHAR(40),
	maa VARCHAR(20)
	
);

-- Vois tehä funktion, joka automaattisesti etsii id:n kun sille antaa nimen/katuosoitteen/jotain muuta

INSERT INTO laskutusosoite (katuosoite, postinumero, postitoimipaikka, maa) VALUES(
	'tunitie 45',
	33720,
	'Tampere',
	'Suomi'
);

CREATE TABLE yhteyshenkilo(

	hloId SERIAL PRIMARY KEY,
	etunimi VARCHAR(30),
	sukunimi VARCHAR(40),
	email VARCHAR(40),
	puhelinnumero VARCHAR(30)

);

INSERT INTO yhteyshenkilo(etunimi, sukunimi, email, puhelinnumero) VALUES(
	'Pekka', 'Penttilä', 'pekupena@tuni.fi', '6969696969'
);

-- Eikös tässä voi olla tilanne, jossa mainostajalla ei ole yhteyshenkilöä?
-- Jos poistetaan yhteyshenkilö, tilalle jää null- arvo
-- oliko tää sallittua
CREATE TABLE mainostaja(
	vat VARCHAR(30) PRIMARY KEY,
	nimi VARCHAR(30),
	yhteysHloId integer,
	FOREIGN KEY(yhteysHloId) REFERENCES yhteyshenkilo(hloId) ON DELETE SET NULL ON UPDATE CASCADE,
	laskutusosoiteId integer,
	FOREIGN KEY(laskutusosoiteId) REFERENCES laskutusosoite(osoiteId) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO mainostaja VALUES(
	'45 TUNIPATSAS', -- vat
	'Mainostoimisto Masa', -- nimi
	1, -- yht. hlö. id
	1 -- laskutusosoite id
);


-- Experimental

CREATE TABLE lasku(

	laskuId SERIAL PRIMARY KEY,
	lahetyspvm DATE,
	eraPvm DATE,
	tila boolean,
	viitenro VARCHAR(20),
	korko decimal(5,2),
	riviId integer -- Ei aseteta vierasavainta vielä
);

CREATE TABLE profiili(

	profiiliId SERIAL PRIMARY Key,
	lahetysAika TIME,
	maa VARCHAR(20),
	paikkakunta VARCHAR(40),
	alaikaraja integer,
	CHECK(alaikaraja > 0),
	ylaikaraja integer,
	CHECK(ylaikaraja > 0)
);

-- Tämä ei tarkista vielä sitä xor- suhdetta profiilin ja mainoksen välillä
CREATE TABLE mainoskampanja(
	kampanjaId SERIAL PRIMARY KEY,
	laskuId integer,
	FOREIGN Key(laskuId) REFERENCES lasku(laskuId)
	ON UPDATE CASCADE ON DELETE SET NULL,

	nimi VARCHAR(40),
	alkupvm DATE DEFAULT CURRENT_DATE,
	loppupvm DATE,
	maaraRahat MONEY,
	sekuntihinta MONEY,
	tila boolean DEFAULT false NOT NULL, -- enabled/disabled

	profiiliId integer,
	FOREIGN Key(profiiliId) REFERENCES profiili(profiiliId)
	ON UPDATE CASCADE ON DELETE SET NULL

);

CREATE TABLE laskurivi(

	riviId SERIAL PRIMARY KEY,
	selite VARCHAR(40),
	hinta MONEY,
	kampanjaId integer,
	FOREIGN KEY(kampanjaId) REFERENCES mainoskampanja(kampanjaId)
	ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Muutetaan laskurivi vielä laskun vierasavaimeksi
ALTER TABLE lasku
	ADD CONSTRAINT fk_lasku_rivi FOREIGN KEY (riviId) REFERENCES laskurivi(riviId)
	ON DELETE SET NULL ON UPDATE CASCADE;

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

CREATE TABLE jingle (
	jingleID SERIAL PRIMARY KEY,
	tiedoston_sijainti VARCHAR(40),
	nimi VARCHAR(30)
);

CREATE TABLE genre(
	genreID SERIAL PRIMARY KEY,
	nimi VARCHAR(50)
);

CREATE TABLE mainos(
	mainosId SERIAL PRIMARY KEY,
	kampanjaId REFERENCES mainoskampanja(kampanjaId) ON DELETE CASCADE ON UPDATE CASCADE,
	nimi VARCHAR(40),
	pituus TIME,
	kuvaus VARCHAR(300),
	esitysaika TIME,
	jingleId int REFERENCES jingle(jingleId) ON DELETE NO ACTION ON UPDATE CASCADE,
	profiiliId int REFERENCES profiili(profiiliId) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE kuuntelija(
	nimimerkki VARCHAR(30) PRIMARY KEY,
	ika integer,
	CHECK(ika > 0 and ika < 150),
	hinta numeric(5,2),
	maa VARCHAR(20),
	paikkakunta VARCHAR(40),
	sahkoposti VARCHAR(40)
);

-- CREATE TABLE esitys (
-- 	esitysId SERIAL PRIMARY KEY,
-- 	kuuntelijaTunnus VARCHAR(30) REFERENCES kuuntelija(nimimerkki) ON DELETE NO ACTION ON UPDATE CASCADE,
-- 	mainosId integer REFERENCES mainos(mainosId) ON DELETE NO ACTION ON UPDATE CASCADE,
-- 	pvm DATE,
-- 	kloaika TIME,
-- 	FOREIGN KEY (kuuntelija)
-- 	UNIQUE(kuuntelijaTunnus, mainosId)
-- );
