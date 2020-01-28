
-- Lisää uuden käyttäjän järjestelmään
-- Pitää kai lisätä virhetarkastelu vai voiko sen tehdä koodin puolella

-- first_name, last_name, user_name, password
CREATE OR REPLACE FUNCTION lisaa_kayttaja(VARCHAR, VARCHAR, VARCHAR(30), chkpass) 
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


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- käyttö: SELECT add_user(etunimi, sukunimi, kayttaja_tunnus, salasana);

-- Tämä ei osaa vielä käsitellä väärässä muodossa olevia postinumeroja
-- Tarviiko sitä edes tarkistaa?

-- laskuid, selite, hinta
CREATE OR REPLACE FUNCTION lisaa_laskurivi(int, VARCHAR, NUMERIC) 
	RETURNS boolean AS
	$func$
	DECLARE

		riviid_ int;
	
	BEGIN
		-- Lisää uuden laskurivin
		INSERT INTO laskurivi(laskuid, selite, hinta) VALUES(
            $1, $2 ,$3
        ) RETURNING riviid AS riviid_;

        RETURN FOUND;
    END
	$func$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------


-- Tällä voi lisätä kivasti ja helposti uusia laskutusosoitteita
-- Jos postinumero on jo olemassa, ei tarvi siitä murehtia
-- postiosoite, postinumero, postitoimipaikka, maa
CREATE OR REPLACE FUNCTION lisaa_laskutusosoite(VARCHAR, VARCHAR, VARCHAR, VARCHAR)
	RETURNS void AS
	$$
	DECLARE
		pstosoite alias for $1;
		pstnumero alias for $2;
		pstoimipaikka alias for $3;
		maa alias for $4;

		isFound integer;
	BEGIN

		SELECT count(*) INTO isFound FROM postitoimipaikka as pt WHERE pt.postinumero = pstnumero; 

		IF isFound = 0 THEN
			INSERT INTO postitoimipaikka VALUES(pstnumero, pstoimipaikka);
		END IF;

		INSERT INTO laskutusosoite(postinumero, katuosoite, maa) VALUES(
			pstnumero, pstosoite, maa
		);
	END
	$$ LANGUAGE plpgsql;


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Ei salli mainoskampanjan poistamista, mikäli laskua ei ole maksettu
-- Jos lasku on maksettu, ja mainoskampanjaa ollaan poistamassa,
-- poistetaan lasku ja siihen liittyvät laskurivit
CREATE OR REPLACE FUNCTION kampanja_poisto_func() RETURNS TRIGGER AS

$kampanja_poisto_func$

	BEGIN
		perform * from lasku l

			where l.tila = false and OLD.kampanjaId = l.kampanjaid;
		IF FOUND THEN
			RAISE EXCEPTION 'Maksamatonta mainoskampanjaa ei voi poistaa!';
			RETURN FOUND;
		ELSE
			-- Ei maksamattomia laskurivejä, kampanja voidaan poistaa
			-- Poistetaan kaikki siihen liittyvät laskurivit, lasku sekä kampanja
			
			DELETE FROM lasku l WHERE OLD.kampanjaId = l.kampanjaId;

		END IF;

		RETURN OLD;

	END;
$kampanja_poisto_func$ LANGUAGE plpgsql;

CREATE TRIGGER check_mainoskampanja_del_tr BEFORE DELETE ON mainoskampanja
	FOR EACH ROW EXECUTE PROCEDURE kampanja_poisto_func();



---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Kopioi alkuperäisen laskun
-- Kopioi alkuperäisen laskun laskurivit ja muuttaa niiden hinnat

-- KÄYTTÖ: select lisaa_karhulasku(x), missä x on laskuid
CREATE OR REPLACE FUNCTION lisaa_karhulasku(laskuid_ int) RETURNS void AS
$karhulasku$
DECLARE
	bearBillId integer;
	interest integer;

BEGIN
	-- Lisätään ensin uusi lasku päivitetyllä hinnalla
	INSERT INTO lasku(kampanjaid, lahetyspvm, erapvm, tila, viitenro, korko)
		(SELECT kampanjaid, lahetyspvm, erapvm, tila, viitenro, korko from lasku WHERE laskuId = laskuid_)
		RETURNING laskuid into bearBillId;
	-- Päivitetään lasku
	--RAISE notice 'päivitetyn laskun id: %', bearBillId; -- DEBUG

	-- Lisätään karhulaskuun uusi lasku
	INSERT INTO karhulasku VALUES(
		bearBillId,
		laskuid_
	);

	-- Lasketaan viivästysmaksun summa
	interest := (SELECT sum(hinta) FROM laskurivi WHERE laskuid = laskuId_)*(SELECT korko from lasku WHERE laskuid = laskuid_)/100;

	-- Lisätään laskuriviin uusi rivi, joka kertoo karhulaskun viivästysmaksun hinnan
	INSERT INTO laskurivi(selite, laskuid, hinta) VALUES(
		'Viivästysmaksu',
		bearBillId,
		interest
	);
END
$karhulasku$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Tätä käytetään PUID-arvon luontiin
CREATE OR REPLACE FUNCTION rand_puid() RETURNS text AS
$$
DECLARE
	chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
	result text := '';
	i integer := 0;
	-- Tietohakemiston mukaan puid:n pituus on [32,40]
	length integer := random()*(41-32)+32; -- 32 <= n < 41
BEGIN
	-- Generoidaan satunnainen puid, jonka pituus on välillä 32-40
	for i in 1..length LOOP
		result := result || chars[1+random()*(array_length(chars, 1)-1)];
	END LOOP;

	-- Tarkistetaan, onko vastaavaa puid:tä vielä olemassa, jos on luodaan uusi
	IF exists(SELECT PUID FROM musiikkikappale WHERE PUID = result LIMIT 1) THEN
		-- Kutsutaan funktiota rekursiivisesti, jolloin generoidaan uusi puid
		result = rand_puid();	
	ELSE
		RETURN result;
	END IF;

END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Tarkistaa mainoskampanjan sekä mainoksen välisen xor-suhteen
-- Jos mainoskampanjalle on asetettu profiili, siihen lisättävillä mainoksilla ei ole profiilia
-- Toisaalta, jos mainoskampanjaan ei ole asetettu profiilia
-- mainoksella täytyy olla profiili
CREATE OR REPLACE FUNCTION check_mainoskampanja_mainos_profiili() RETURNS trigger AS
$$
DECLARE
	kampanjaHasProfile boolean;
BEGIN
	kampanjaHasProfile := exists(SELECT profiiliId FROM mainoskampanja AS m WHERE m.kampanjaid = NEW.kampanjaId); 
	-- NEW tarkoittaa siis uutta mainos-tauluun lisättävää/päivitettävää riviä
	
	if kampanjaHasProfile then
		-- Mainoskampanjalla on profiili -> mainoksella ei saa olla profiilia
		if NEW.profiiliid is not null then
			RAISE EXCEPTION 'Mainoskampanjalla on jo profiili! Lisättävällä mainoksella tällöin ei saa olla profiilia. Uutta mainosta ei lisätty.';
		end if;
	ELSE
		-- Mainoskampanjalla ei ole profiilia -> mainoksella täytyy olla profiili
		if NEW.profiiliid = null then
			RAISE EXCEPTION 'Mainoskampanjalla ei ole profiilia! Tällöin mainokselle täytyy asettaa profiili. Uutta mainosta ei lisätty.';
		end if;
	end if;

	RETURN NEW;
END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER check_mainoskampanja_mainos_profiili_tr BEFORE INSERT ON mainos
	FOR EACH ROW EXECUTE PROCEDURE check_mainoskampanja_mainos_profiili();
