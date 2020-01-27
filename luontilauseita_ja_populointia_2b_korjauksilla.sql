 --Nipsun luontilauseet ja populoinnit 22.1.2020
--tsekkaa, että kaikki tietotyypit samoja kuin tietohakemistossa?
--tietohakemistosta myös löytyy tauluja mitä relaatiokaaviossa ei ole
--postinumeroiden täytynee olla varchar koska voi alkaa nollilla
--tsekkaa että ääkköset oikein ettei jossain ole ääkkösiä ja toisessa aakkosia
--miksi NO ACTION ei tunnista?
--onko nyt liian monen surrogaatin tietotyyppinä integer?


CREATE TABLE postitoimipaikka (
postinumero VARCHAR(5) PRIMARY KEY,
postitoimipaikka VARCHAR(40)
);

CREATE TABLE kuuntelija_kirjautumistiedot (
nimimerkki VARCHAR(20) PRIMARY KEY,
salasana chkpass,
FOREIGN KEY(nimimerkki) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE
);

--huom onko kakkuri vaihtanut kuuntelijaID:n kuten puhuttiin? vaihdoin itse nyt IDn olemaan varchar
CREATE TABLE soittolista (
soittolistaID SERIAL PRIMARY KEY,
kuuntelijaID VARCHAR,
nimi VARCHAR(40),
FOREIGN KEY(kuuntelijaID) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE teos (
teosID SERIAL PRIMARY KEY,
nimi VARCHAR(100),
julkaisuvuosi DATE
);

CREATE TABLE musiikintekija (
tekijaID SERIAL PRIMARY KEY,
nimi VARCHAR(40),
rooli VARCHAR(40)
);

CREATE TABLE musiikkikappale (
PUID SERIAL PRIMARY KEY,
teosID INTEGER,
kesto TIME,
aanitiedosto VARCHAR(40),
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE kokoelma (
kokoelmaID SERIAL PRIMARY KEY,
teosID INTEGER,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE yhdiste_profiili_tekija (
profiiliID INTEGER,
tekijaID INTEGER,
PRIMARY KEY(profiiliID, tekijaID),
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tekijaID) REFERENCES musiikintekija(tekijaID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_profiili_kuuntelija (
profiiliID INTEGER,
nimimerkki VARCHAR(30),
PRIMARY KEY(profiiliID, nimimerkki),
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(nimimerkki) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE
); 

CREATE TABLE yhdiste_teos_genre (
teosID INTEGER,
genreID INTEGER,
PRIMARY KEY(teosID, genreID),
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(genreID) REFERENCES genre(genreID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_profiili_genre (
profiiliID INTEGER,
genreID INTEGER,
PRIMARY KEY(profiiliID, genreID),
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(genreID) REFERENCES genre(genreID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_teos_soittolista (
soittolistaID INTEGER,
teosID INTEGER,
PRIMARY KEY(soittolistaID, teosID),
FOREIGN KEY(soittolistaID) REFERENCES soittolista(soittolistaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

--en tiedä onko id ja nimi nyt sama juttu mut tein kuitenki ku muissakin on?
CREATE TABLE musarooli (
rooliID SERIAL PRIMARY KEY,
roolin_nimi VARCHAR(30)
);

CREATE TABLE yhdiste_teos_tekija_rooli (
teosID INTEGER,
tekijaID INTEGER,
rooliID INTEGER ,
PRIMARY KEY(teosID, tekijaID, rooliID),
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tekijaID) REFERENCES musiikintekija(tekijaID) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(rooliID) REFERENCES musarooli(rooliID) ON UPDATE CASCADE ON DELETE NO ACTION
);

--järjestysnumerolle jokin parempi tietotyyppi?

CREATE TABLE kokoelmateos (
kokoelmaID INTEGER,
teosID INTEGER,
jarjestysnumero NUMERIC,
PRIMARY KEY(kokoelmaID, teosID),
FOREIGN KEY(kokoelmaID) REFERENCES kokoelma(kokoelmaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

--molemmat vierasavaimet viittaavat samaan, haittaako?

CREATE TABLE karhulasku (
karhulaskuNro INTEGER,
laskuNro INTEGER,
PRIMARY KEY(karhulaskuNro, laskuNro),
FOREIGN KEY(karhulaskuNro) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(laskuNro) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE NO ACTION
);

--tähän keksin itse laskunron viite-eheyden kun puuttui, tsekkaa

CREATE TABLE yhdiste_kampanja (
kampanjaID INTEGER,
mainostajaID VARCHAR(30),
kayttajatunnus VARCHAR(30),
laskuNro INTEGER,
PRIMARY KEY(kampanjaID, mainostajaID, kayttajatunnus, laskuNro),
FOREIGN KEY(kampanjaID) REFERENCES mainoskampanja(kampanjaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(mainostajaID) REFERENCES mainostaja(VAT) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(kayttajatunnus) REFERENCES jarjestelma_kayttaja(kayttaja_tunnus) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(laskuNro) REFERENCES lasku(laskuid) ON UPDATE CASCADE ON DELETE NO ACTION
);

