
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
CREATE FUNCTION add_user(VARCHAR, VARCHAR, VARCHAR(30), VARCHAR) RETURNS void AS $$
	
	WITH ins1 AS (
		INSERT INTO jarjestelma_kayttaja VALUES(
		
		$3,
		$1,
		$2,
		false
	)
	
	WITH ins2 AS (
		INSERT INTO jarjestelma_kirjautumistiedot VALUES(
			$3,
			$4
	)
	
$$ LANGUAGE SQL;


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

