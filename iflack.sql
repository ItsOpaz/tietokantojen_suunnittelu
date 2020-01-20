
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
CREATE TABLE mainostaja(
	vat VARCHAR(30) PRIMARY KEY,
	nimi VARCHAR(30),
	yhteysHloId integer,
	laskutusosoiteId integer,

	FOREIGN KEY(laskutusosoiteId) REFERENCES laskutusosoite(osoiteId) ON DELETE CASCADE ON UPDATE CASCADE
	FOREIGN KEY(yhteysHloId) REFERENCES yhteyshenkilo(hloId) ON DELETE SET NULL ON UPDATE CASCADE
	
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
<<<<<<< HEAD
	maaraRahat numeric(8,2), -- Miljoona suurin luku, tuleeko ongelmia?
	sekuntihinta numeric(4,2), -- Ei varmaankaan yli 100€ sekuntihintaa?
=======
	maaraRahat NUMERIC(8,2), -- luokkaa miljoona varmaan riittää
	sekuntihinta NUMERIC(5,2),-- tietotyyppi money on kuulemma erittäin vanhanaikainen
>>>>>>> 2c81a16d32783dc814e77c35afc6f9ce83b6a431
	tila boolean DEFAULT false NOT NULL, -- enabled/disabled

	profiiliId integer,
	FOREIGN Key(profiiliId) REFERENCES profiili(profiiliId)
	ON UPDATE CASCADE ON DELETE SET NULL

);

CREATE TABLE laskurivi(

	riviId SERIAL PRIMARY KEY,
	selite VARCHAR(40),
	hinta numeric(8,2),
	kampanjaId integer,
	FOREIGN KEY(kampanjaId) REFERENCES mainoskampanja(kampanjaId)
	ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Muutetaan laskurivi vielä laskun vierasavaimeksi
ALTER TABLE lasku
	ADD CONSTRAINT fk_lasku_rivi FOREIGN KEY (riviId) REFERENCES laskurivi(riviId)
	ON DELETE SET NULL ON UPDATE CASCADE;

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
	CONSTRAINT mainos_profiili_fk FOREIGN KEY(profiiliId) REFERENCES profiili(profiiliId) ON UPDATE CASCADE ON DELETE SET NULL,
	UNIQUE(kampanjaId, jingleId, profiiliId)
);

CREATE TABLE kuuntelija(
	nimimerkki VARCHAR(30) PRIMARY KEY,
	ika integer,
	CHECK(ika > 0 and ika < 150),
	sukupuoli CHAR(1) CHECK(sukupuoli = 'm' or sukupuoli = 'f'),
	hinta numeric(5,2),
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

<<<<<<< HEAD
INSERT INTO laskurivi(selite, hinta, kampanjaId) VALUES (
	'Perkeleen kallis mainos',
	99.99,
	1
);

UPDATE lasku WHERE laskuId = 1 SET riviId = 1;

INSERT INTO laskurivi(selite, hinta, kampanjaId) VALUES (
	'Toinen vitun kallis mainos',
	20.20,
	1
);
=======

-- laskuid, nimi, alkupvm, loppupvm maararahat, sekuntihinta, tila(false), profiili
CREATE OR REPLACE FUNCTION add_ad_campaign(int, varchar, date, date, numeric(5,2), numeric(5,2), int) 
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
>>>>>>> 2c81a16d32783dc814e77c35afc6f9ce83b6a431
