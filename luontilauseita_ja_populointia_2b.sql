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
salasana VARCHAR(40),
FOREIGN KEY(nimimerkki) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE,
);

--huom onko kakkuri vaihtanut kuuntelijaID:n kuten puhuttiin?
CREATE TABLE soittolista (
soittolistaID SERIAL PRIMARY KEY,
kuuntelijaID INTEGER,
nimi VARCHAR(40),
FOREIGN KEY(kuuntelijaID) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE teos (
teosID SERIAL PRIMARY KEY,
nimi VARCHAR(100),
julkaisuvuosi YEAR
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
äänitiedosto VARCHAR(40),
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE kokoelma (
kokoelmaID SERIAL PRIMARY KEY,
teosID INTEGER,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE yhdiste_profiili_tekijä (
profiiliID INTEGER PRIMARY KEY,
tekijäID INTEGER PRIMARY KEY,
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tekijäID) REFERENCES musiikintekija(tekijäID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_profiili_kuuntelija (
profiiliID INTEGER PRIMARY KEY,
nimimerkki VARCHAR(30) PRIMARY KEY,
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(nimimerkki) REFERENCES kuuntelija(nimimerkki) ON UPDATE CASCADE ON DELETE CASCADE
); 

CREATE TABLE yhdiste_teos_genre (
teosID INTEGER PRIMARY KEY,
genreID INTEGER PRIMARY KEY,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(genreID) REFERENCES genre(genreID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_profiili_genre (
profiiliID INTEGER PRIMARY KEY,
genreID INTEGER PRIMARY KEY,
FOREIGN KEY(profiiliID) REFERENCES profiili(profiiliID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(genreID) REFERENCES genre(genreID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_teos_soittolista (
soittolistaID INTEGER PRIMARY KEY,
teosID INTEGER PRIMARY KEY,
FOREIGN KEY(soittolistaID) REFERENCES soittolista(soittolistaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE yhdiste_teos_tekijä_rooli (
teosID INTEGER PRIMARY KEY,
tekijäID INTEGER PRIMARY KEY,
rooliID INTEGER PRIMARY KEY,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(tekijäID) REFERENCES tekijä(tekijäID) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(rooliID) REFERENCES rooli(rooliID) ON UPDATE CASCADE ON DELETE NO ACTION
);

--järjestysnumerolle jokin parempi tietotyyppi?

CREATE TABLE kokoelmateos (
kokoelmaID INTEGER PRIMARY KEY,
teosID INTEGER PRIMARY KEY,
järjestysnumero NUMERIC,
FOREIGN KEY(kokoelmaID) REFERENCES kokoelma(kokoelmaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(teosID) REFERENCES teos(teosID) ON UPDATE CASCADE ON DELETE CASCADE
);

--molemmat vierasavaimet viittaavat samaan, haittaako?

CREATE TABLE karhulasku (
karhulaskuNro INTEGER PRIMARY KEY,
laskuNro INTEGER PRIMARY KEY,
FOREIGN KEY(karhulaskuNro) REFERENCES lasku(laskuNro) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(laskuNro) REFERENCES lasku(laskuNro) ON UPDATE CASCADE ON DELETE NO ACTION
);

--tähän keksin itse laskunron viite-eheyden kun puuttui, tsekkaa

CREATE TABLE yhdiste_kampanja (
kampanjaID INTEGER PRIMARY KEY,
mainostajaID INTEGER PRIMARY KEY,
käyttäjätunnus VARCHAR(30) PRIMARY KEY,
laskuNro INTEGER PRIMARY KEY,
FOREIGN KEY(kampanjaID) REFERENCES mainoskampanja(kampanjaID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY(mainostajaID) REFERENCES mainostaja(mainostajaID) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(käyttäjätunnus) REFERENCES järjestelmä_käyttäjä(käyttäjätunnus) ON UPDATE CASCADE ON DELETE NO ACTION,
FOREIGN KEY(laskuNro) REFERENCES lasku(laskuNro) ON UPDATE CASCADE ON DELETE NO ACTION
);