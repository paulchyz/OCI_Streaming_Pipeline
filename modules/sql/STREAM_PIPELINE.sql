-- Create database view to return relational data from JSON collection
CREATE OR REPLACE VIEW STREAMDATA_VIEW AS
SELECT STREAM, KEY, PARTITION, OFFSET, BATCH_TIMESTAMP, TO_TIMESTAMP(TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF') TIMESTAMP, EQUIPMENT_ID, VIBRATION_AMPLITUDE, VIBRATION_FREQUENCY, TEMPERATURE, HUMIDITY from STREAMDATA,
    JSON_TABLE (
        STREAMDATA.JSON_DOCUMENT COLUMNS (
            NESTED PATH '$[*]' COLUMNS (
                STREAM VARCHAR2(40) PATH '$.stream',
                KEY NUMBER PATH '$.key',
                PARTITION NUMBER PATH '$.partition',
                OFFSET NUMBER PATH '$.offset',
                BATCH_TIMESTAMP NUMBER PATH '$.timestamp',
                NESTED PATH '$.value[*]' COLUMNS (
                    TIMESTAMP VARCHAR2(100) PATH '$.timestamp',
                    EQUIPMENT_ID NUMBER PATH '$.equipment_id',
                    VIBRATION_AMPLITUDE NUMBER PATH '$.vibration_amplitude',
                    VIBRATION_FREQUENCY NUMBER PATH '$.vibration_frequency',
                    TEMPERATURE NUMBER PATH '$.temperature',
                    HUMIDITY NUMBER PATH '$.humidity'
                )
            )
        )
    ) ORDER BY KEY DESC;

-- Create database view to return the most recent 10 minutes of relational data from JSON collection
CREATE OR REPLACE VIEW STREAMDATA_LAST10_VIEW AS
SELECT STREAM, KEY, PARTITION, OFFSET, BATCH_TIMESTAMP, TO_TIMESTAMP(TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF') TIMESTAMP, EQUIPMENT_ID, VIBRATION_AMPLITUDE, VIBRATION_FREQUENCY, TEMPERATURE, HUMIDITY from STREAMDATA,
    JSON_TABLE (
        STREAMDATA.JSON_DOCUMENT COLUMNS (
            NESTED PATH '$[*]' COLUMNS (
                STREAM VARCHAR2(40) PATH '$.stream',
                KEY NUMBER PATH '$.key',
                PARTITION NUMBER PATH '$.partition',
                OFFSET NUMBER PATH '$.offset',
                BATCH_TIMESTAMP NUMBER PATH '$.timestamp',
                NESTED PATH '$.value[*]' COLUMNS (
                    TIMESTAMP VARCHAR2(100) PATH '$.timestamp',
                    EQUIPMENT_ID NUMBER PATH '$.equipment_id',
                    VIBRATION_AMPLITUDE NUMBER PATH '$.vibration_amplitude',
                    VIBRATION_FREQUENCY NUMBER PATH '$.vibration_frequency',
                    TEMPERATURE NUMBER PATH '$.temperature',
                    HUMIDITY NUMBER PATH '$.humidity'
                )
            )
        )
    ) WHERE TO_TIMESTAMP(TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF') > (SELECT MAX(TIMESTAMP) FROM STREAMDATA_VIEW) - INTERVAL '10' MINUTE ORDER BY KEY DESC;

-- Create database view to return the most recent 3 minutes of relational data from JSON collection
CREATE OR REPLACE VIEW STREAMDATA_LAST3_VIEW AS
SELECT STREAM, KEY, PARTITION, OFFSET, BATCH_TIMESTAMP, TO_TIMESTAMP(TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF') TIMESTAMP, EQUIPMENT_ID, VIBRATION_AMPLITUDE, VIBRATION_FREQUENCY, TEMPERATURE, HUMIDITY from STREAMDATA,
    JSON_TABLE (
        STREAMDATA.JSON_DOCUMENT COLUMNS (
            NESTED PATH '$[*]' COLUMNS (
                STREAM VARCHAR2(40) PATH '$.stream',
                KEY NUMBER PATH '$.key',
                PARTITION NUMBER PATH '$.partition',
                OFFSET NUMBER PATH '$.offset',
                BATCH_TIMESTAMP NUMBER PATH '$.timestamp',
                NESTED PATH '$.value[*]' COLUMNS (
                    TIMESTAMP VARCHAR2(100) PATH '$.timestamp',
                    EQUIPMENT_ID NUMBER PATH '$.equipment_id',
                    VIBRATION_AMPLITUDE NUMBER PATH '$.vibration_amplitude',
                    VIBRATION_FREQUENCY NUMBER PATH '$.vibration_frequency',
                    TEMPERATURE NUMBER PATH '$.temperature',
                    HUMIDITY NUMBER PATH '$.humidity'
                )
            )
        )
    ) WHERE TO_TIMESTAMP(TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF') > (SELECT MAX(TIMESTAMP) FROM STREAMDATA_VIEW) - INTERVAL '3' MINUTE ORDER BY KEY DESC;

-- QUERIES FOR VIEW:
-- Select all data in one of the 3 views
SELECT * FROM STREAMDATA_VIEW;
SELECT * FROM STREAMDATA_LAST10_VIEW;
SELECT * FROM STREAMDATA_LAST3_VIEW;
-- Select the number of rows in one of the 3 views
SELECT count(*) FROM STREAMDATA_VIEW;
SELECT count(*) FROM STREAMDATA_LAST10_VIEW;
SELECT count(*) FROM STREAMDATA_LAST3_VIEW;

-- QUERIES FOR JSON
-- Select all metadadata in JSON collection.  JSON payload data is within "BLOB"
SELECT * FROM STREAMDATA;