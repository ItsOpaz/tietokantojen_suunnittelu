

-- Lisää uuden käyttäjän järjestelmään
-- Pitää kai lisätä virhetarkastelu vai voiko sen tehdä koodin puolella

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

-- laskuid, selite, hinta, kampanjaid
CREATE OR REPLACE FUNCTION lisaa_laskurivi(int, VARCHAR, NUMERIC, int) 
	RETURNS boolean AS
	$func$
	
	BEGIN
		INSERT INTO laskurivi(selite, hinta, kampanjaid) VALUES(
            $2,$3,$4

        );

        UPDATE lasku SET riviId = (SELECT max(riviId) FROM laskurivi WHERE selite = $2)
        
        WHERE laskuId = $1;

        RETURN FOUND;
    END
	$func$ LANGUAGE plpgsql;


-- Ei salli mainoskampanjan poistamista, mikäli laskua ei ole maksettu
-- Jos lasku on maksettu, ja mainoskampanjaa ollaan poistamassa,
-- poistetaan lasku ja siihen liittyvät laskurivit
CREATE OR REPLACE FUNCTION kampanja_posto_func() RETURNS TRIGGER AS

$kampanja_posto_func$

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
$kampanja_posto_func$ LANGUAGE plpgsql;

CREATE TRIGGER check_mainoskampanja_del_tr BEFORE DELETE ON mainoskampanja
	FOR EACH ROW EXECUTE PROCEDURE kampanja_posto_func();


