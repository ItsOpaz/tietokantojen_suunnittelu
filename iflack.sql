
-- Järjestelmän käyttäjä

-- Pitääköhän mainosmyyjä ja sihteeri erotella jotenki?
-- Eli pitääkö esim tähän laittaa rooli? tms.
CREATE TABLE jarjestelma_kayttaja (
	
	kayttaja_tunnus SERIAL PRIMARY KEY,
	etunimi VARCHAR NOT NULL,
	sukunimi VARCHAR NOT NULL,
	tila BOOLEAN

);

-- Kirjautumistiedot
CREATE TABLE jarjestelma_kirjautumistiedot (
	
	kayttaja_tunnus int PRIMARY KEY,
	salasana VARCHAR NOT NULL,
	 FOREIGN KEY(kayttaja_tunnus) REFERENCES jarjestelma_kayttaja(kayttaja_tunnus)
);

-- Testi dataa
INSERT INTO jarjestelma_kayttaja(etunimi, sukunimi, tila) VALUES(

	'Toni',
	'Halme',
	false);

INSERT INTO jarjestelma_kayttaja(etunimi, sukunimi, tila) VALUES(

	'Donald',
	'Trump',
	false);