/*
==========================================================
FUNCIÓN: COMPRA DE ENTRADA
Versión: 1.0
Fecha de creación: 17/05/2026

Descripción:
Esta función permite realizar la compra de una
entrada para un partido de fútbol utilizando
el saldo disponible en la billetera (wallet)
del usuario.

Funcionalidades:
- Verifica que el usuario exista.
- Verifica que el partido exista.
- Verifica que el usuario tenga wallet.
- Verifica saldo suficiente en wallet.
- Crea el ticket de compra.
- Registra el historial del ticket.
- Registra el pago realizado.
- Descuenta el saldo de la wallet.
- Registra el movimiento financiero.
- Si algo falla, la transacción se revierte.

Parámetros:
p_user_id   -> ID del usuario comprador.
p_match_id  -> ID del partido.
p_price     -> Precio de la entrada.

Retorna:
- Mensaje de confirmación si la compra es exitosa.
- Error controlado si ocurre un problema.

Ejemplo de uso:
SELECT buy_ticket(1, 5, 150000);

==========================================================
*/

CREATE OR REPLACE FUNCTION buy_ticket(
    p_user_id INT,
    p_match_id INT,
    p_price NUMERIC(10,2)
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_balance NUMERIC(10,2);
    v_wallet_id INT;
    v_ticket_id INT;
BEGIN

    -- =============================
    -- VALIDAR USUARIO
    -- =============================
    IF NOT EXISTS (
        SELECT 1
        FROM "USER"
        WHERE idUser = p_user_id
    ) THEN
        RAISE EXCEPTION 'El usuario no existe';
    END IF;

    -- =============================
    -- VALIDAR PARTIDO
    -- =============================
    IF NOT EXISTS (
        SELECT 1
        FROM MATCH
        WHERE idMatch = p_match_id
    ) THEN
        RAISE EXCEPTION 'El partido no existe';
    END IF;

    -- =============================
    -- OBTENER WALLET Y BLOQUEAR
    -- =============================
    SELECT id_wallet, balance
    INTO v_wallet_id, v_balance
    FROM WALLET
    WHERE id_user = p_user_id
    FOR UPDATE;

    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION 'El usuario no tiene billetera';
    END IF;

    -- =============================
    -- VALIDAR SALDO
    -- =============================
    IF v_balance < p_price THEN
        RAISE EXCEPTION 'Saldo insuficiente';
    END IF;

    -- =============================
    -- CREAR TICKET
    -- =============================
    INSERT INTO TICKET (
        status,
        price,
        id_match,
        id_user
    )
    VALUES (
        'CONFIRMED',
        p_price,
        p_match_id,
        p_user_id
    )
    RETURNING id_ticket
    INTO v_ticket_id;

    -- =============================
    -- HISTORIAL DEL TICKET
    -- =============================
    INSERT INTO TICKET_HISTORY (
        status,
        reason,
        id_ticket
    )
    VALUES (
        'CONFIRMED',
        'Compra realizada exitosamente',
        v_ticket_id
    );

    -- =============================
    -- REGISTRAR PAGO
    -- =============================
    INSERT INTO PAYMENT (
        status,
        amount,
        provider,
        id_user
    )
    VALUES (
        'APPROVED',
        p_price,
        'WALLET',
        p_user_id
    );

    -- =============================
    -- DESCONTAR SALDO
    -- =============================
    UPDATE WALLET
    SET balance = balance - p_price
    WHERE id_wallet = v_wallet_id;

    -- =============================
    -- MOVIMIENTO DE WALLET
    -- =============================
    INSERT INTO WALLET_TRANSACTION (
        type,
        amount,
        reason,
        id_wallet
    )
    VALUES (
        'DEBIT',
        p_price,
        CONCAT(
            'Compra entrada partido ',
            p_match_id
        ),
        v_wallet_id
    );

    RETURN 'Compra realizada correctamente';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en la compra: %', SQLERRM;
END;
$$;