--kaikki loppuneet kampanjat joissa laskua ei vielä tehty
CREATE OR REPLACE VIEW laskutettavat AS 
    SELECT *
    FROM mainoskampanja m
	WHERE tila = false;
	INNER JOIN yhdiste_kampanja y
	WHERE m.kampanjaId = y.kampanjaId
	AND y.laskuId IS NULL;
	
--kaikkien mainosten kuuntelukerrat
CREATE OR REPLACE VIEW mainosten_kuuntelukerrat AS
	SELECT mainosId, COUNT(mainosId) AS lkm
	FROM esitys
	GROUP BY mainosId;

--kaikkien kampanjoiden mainosten tiedot, kuuntelukerrat ja kokonaishinnan
CREATE OR REPLACE VIEW kampanjan_mainokset AS
	SELECT m.nimi, m.mainosId,m.kampanjaId, m.pituus, mk.sekuntihinta, ma.lkm
	, ma.lkm *sekuntihinta as kokhinta
	FROM mainoskampanja mk
	INNER JOIN mainos m
	WHERE m.kampanjaId = mk.kampanjaId
	INNER JOIN mainosten_kuuntelukerrat ma
	WHERE m.mainosId = ma.mainosId