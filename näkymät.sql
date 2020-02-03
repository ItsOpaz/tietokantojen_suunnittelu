/*
Luodut näkymät erityisesti laskutuksen helpottamiseen. Lisäksi mahdollisesti
tarpeellinen näkymä joka palauttaa kaikki mainokset käyttäjälle voi näyttää, mutta
mahdollisesti melko monimutkainen
*/

-- kaikki loppuneet kampanjat joissa laskua ei vielä tehty
-- helpottaa laskutuksessa, kun halutaan lista kampanjoista joihin voidaan 
-- luoda lasku
CREATE VIEW laskutettavat AS 
    SELECT m.kampanjaId, m.nimi
    FROM mainoskampanja m
	INNER JOIN yhdiste_kampanja y
	ON m.kampanjaId = y.kampanjaId
	WHERE y.laskuNro IS NULL
	AND m.tila = false;
	;
	
-- kaikkien mainosten kuuntelukerrat, auttaa mainoskampan mainosten tietojen 
-- hakemisessa
CREATE VIEW mainosten_kuuntelukerrat AS
	mainosId, COUNT(mainosId) AS lkm
	FROM esitys
	GROUP BY mainosId
	;

-- kaikkien kampanjoiden mainosten tiedot, kuuntelukerrat ja kokonaishinnan
-- auttaa laskun tekemisessä, kun tiedot saadaan kaikilta kampanjan mainoksilta
CREATE VIEW kampanjan_mainokset AS
	m.nimi, m.mainosId,m.kampanjaId, m.pituus, mk.sekuntihinta, ma.lkm
	, ma.lkm *sekuntihinta as kokhinta
	FROM mainoskampanja mk
	INNER JOIN mainos m
	ON m.kampanjaId = mk.kampanjaId
	INNER JOIN mainosten_kuuntelukerrat ma
	ON m.mainosId = ma.mainosId
	;

-- kaikkien kampanjoiden laskutustiedot
-- helpottaa kun kampanjan tarvittavat laskutustiedot saadaan helposti yhdellä
-- yksinkertaisella kyselyllä
CREATE VIEW laskutustiedot AS
	yk.kampanjaId, yk.kayttajatunnus, yk.mainostajaId
	, CONCAT(jk.etunimi, ' ',jk.sukunimi) as myyjä
	, CONCAT(yh.etunimi, ' ',yh.sukunimi) as tilaaja
	, m.nimi as mainostaja, m.laskutusosoiteId, mk.nimi as kampanja
	FROM yhdiste_kampanja yk
	INNER JOIN mainoskampanja mk
	ON yk.kampanjaId = mk.kampanjaId
	INNER JOIN jarjestelma_kayttaja jk
	ON yk.kayttajatunnus = jk.kayttajatunnus
	INNER JOIN mainostaja m
	ON yk.mainostajaId = m.VAT
	INNER JOIN yhteyshenkilo yh
	ON m.yhteyshloId = yh.hloid
	INNER JOIN laskutusosoite lo
	ON m.laskutusosoiteId = lo.osoiteId
	;

--näkymä jossa kaikki mainosesitykset, ongelma on kuitenkin että miten saadaan
--oikeat kappaleet listaan mukaan
CREATE VIEW mainoksen_esitykset AS 
    SELECT m.mainosId,
	e.pvm as esityspäivä,
	e.kloaika as esitysaika,
	k.sukupuoli,
	k.ika,
	k.maa,
	k.paikkakunta
    FROM mainos m
	INNER JOIN esitys e
	ON m.mainosId = e.mainosId
	INNER JOIN kuuntelija k
	ON e.kuuntelijaTunnus = nimimerkki;
