create extension IF NOT EXISTS pgcrypto;

WITH r1 AS (SELECT (1::bigint << 33) as r1),
     r2 AS (SELECT r1.r1 as r1, int2uuid(r1.r1, '00000000000000000000000000000000') as r2 FROM r1),
     r3 AS (SELECT r2.r1 as r1, r2.r2 as r2, uuid2int(r2.r2, '00000000000000000000000000000000') as r3 FROM r2)
SELECT *
FROM r3;

CREATE OR REPLACE FUNCTION int2uuid(_n NUMERIC, _key varchar) RETURNS UUID AS
$$
DECLARE
    _b BYTEA := '\x';
    _v INTEGER;
    _i INTEGER;
BEGIN
    WHILE _n > 0
        LOOP
            _v := _n % 256;
            _b := SET_BYTE(('\x00' || _b), 0, _v);
            _n := (_n - _v) / 256;
        END LOOP;
    _i := 8 - length(_b);
    WHILE _i > 0
        LOOP
            _b := ('\x00' || _b);
            _i := _i - 1;
        END LOOP;
    RETURN substring(encrypt(_b, decode(_key, 'hex'), 'aes')::text, 3)::uuid;
END;
$$ LANGUAGE PLPGSQL IMMUTABLE
                    STRICT;

CREATE OR REPLACE FUNCTION uuid2int(_u UUID, _key varchar) RETURNS NUMERIC AS
$$
DECLARE
    _n NUMERIC := 0;
    _b BYTEA;
BEGIN
    _b := decrypt(decode(replace(_u::text, '-', ''), 'hex'), decode(_key, 'hex'), 'aes');
    FOR _i IN 0 .. LENGTH(_b) - 1
        LOOP
            _n := _n * 256 + GET_BYTE(_b, _i);
        END LOOP;
    return _n;
END;
$$ LANGUAGE PLPGSQL IMMUTABLE
                    STRICT;

-- CREATE OR REPLACE FUNCTION bytea2numeric(_b BYTEA) RETURNS NUMERIC AS
-- $$
-- DECLARE
--     _n NUMERIC := 0;
-- BEGIN
--     FOR _i IN 0 .. LENGTH(_b) - 1
--         LOOP
--             _n := _n * 256 + GET_BYTE(_b, _i);
--         END LOOP;
--     RETURN _n;
-- END;
-- $$ LANGUAGE PLPGSQL IMMUTABLE
--                     STRICT;
--
-- CREATE OR REPLACE FUNCTION numeric2bytea(_n NUMERIC) RETURNS BYTEA AS
-- $$
-- DECLARE
--     _b BYTEA := '\x';
--     _v INTEGER;
--     _i INTEGER;
-- BEGIN
--     WHILE _n > 0
--         LOOP
--             _v := _n % 256;
--             _b := SET_BYTE(('\x00' || _b), 0, _v);
--             _n := (_n - _v) / 256;
--         END LOOP;
--     _i := 16 - length(_b);
--     WHILE _i > 0
--         LOOP
--             _b := ('\x00' || _b);
--             _i := _i - 1;
--         END LOOP;
--     RETURN _b;
-- END;
-- $$ LANGUAGE PLPGSQL IMMUTABLE
--                     STRICT;