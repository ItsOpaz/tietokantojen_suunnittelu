

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