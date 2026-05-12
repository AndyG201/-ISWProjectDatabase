CREATE OR REPLACE PROCEDURE reserve_ticket (
	user_id INTEGER,
	match_id_param INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
	stadium_capacity INTEGER;
	current_tickets INTEGER;
BEGIN

	SELECT COALESCE(SUM(t.id_ticket), 0) INTO current_tickets
	FROM ticket t 
	INNER JOIN "match" m ON m.id_match = t.id_match
	WHERE m.id_match = match_id_param;

	SELECT s.capacity INTO stadium_capacity
	FROM stadium s 
	INNER JOIN "match" m ON m.stadium_id = s.stadium_id
	WHERE m.id_match = match_id_param;

	IF current_tickets + 1 > stadium_capacity THEN
		RAISE EXCEPTION 'No tickets available';
	ELSE
		INSERT INTO ticket (id_user, id_match, status, reservation_date)
		VALUES (user_id, match_id_param, 'RESERVED', NOW());
	END IF;

END;
$$;

CREATE OR REPLACE PROCEDURE confirmar_pago_entrada (
	id_entrada INTEGER,
	id_usuario INTEGER,
	provider_name VARCHAR(100)
	
)
LANGUAGE plpgsql
AS $$
DECLARE
	precio NUMERIC;
BEGIN

	IF EXISTS (
		SELECT 1 
		FROM ticket 
		WHERE id_ticket = id_entrada 
		AND status = 'RESERVED'
	) THEN

		SELECT price INTO precio 
		FROM ticket 
		WHERE id_ticket = id_entrada;

		UPDATE ticket
		SET status = 'PAID'
		WHERE id_ticket = id_entrada;

		INSERT INTO payment (status, amount, payment_date, provider, id_user)
		VALUES ('PAID', precio, NOW(), provider, id_usuario);

	ELSE
		RAISE EXCEPTION 'No se pudo registrar el pago';
	END IF;

END;
$$;