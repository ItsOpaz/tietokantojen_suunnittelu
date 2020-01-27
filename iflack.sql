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
	-- tyyppi "sihteeri"|"myyjä" 
	tila BOOLEAN

CREATE TABLE jarjestelma_kayttaja (
  kayttaja_tunnus VARCHAR(30) PRIMARY KEY,
  etunimi VARCHAR NOT NULL,
  sukunimi VARCHAR NOT NULL,
  tyyppi rooli,
  tila BOOLEAN
);

CREATE EXTENSION chkpass;
-- Kirjautumistiedot
CREATE TABLE jarjestelma_kirjautumistiedot (
  kayttaja_tunnus VARCHAR(30) PRIMARY KEY,
  salasana chkpass NOT NULL,
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
-- xor tarkistus varmaa järkevin tehdä triggerillä?
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
	tila BOOLEAN DEFAULT false NOT NULL, -- enabled/disabled

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
-- eiks tää oo ny väärinpäin nyt lasku -> laskurivi ja laskussa voi olla monta laskuriviä
-- pitäis olla laskurivi -> lasku
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