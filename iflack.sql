
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
-- EI VIELÄ MITÄÄN VIRHETARKASTELUA!!! 

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

CREATE TABLE yhteyshenkilo(

	hloId SERIAL PRIMARY KEY,
	etunimi VARCHAR(30),
	sukunimi VARCHAR(40),
	email VARCHAR(40),
	puhelinnumero VARCHAR(30)

);

