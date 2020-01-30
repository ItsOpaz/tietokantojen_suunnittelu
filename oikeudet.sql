-- myyjä ja sihteeri roolit luotu ja tarvittavat oikeudet oikeisiin 
-- tauluihin ja näkymiin, kirjautumisvaihtoehdoissa vielä mietittävää

CREATE ROLE sihteeri NOLOGIN;
CREATE ROLE myyja NOLOGIN;

GRANT ALL PRIVILEGES ON kampanjan_mainokset,
karhulasku, lasku, laskutettavat, laskutustiedot,
mainosten_kuuntelukerrat, yhdiste_kampanja TO sihteeri;
GRANT ALL PRIVILEGES ON mainos, mainoskampanja,
yhteyshenkilö, yhdiste_kampanja, profiili, 
mainosten_kuuntelukerrat, mainostaja, laskutusosoite,
laskutustiedot
TO myyja;