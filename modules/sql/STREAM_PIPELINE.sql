-- Create database view to return relational data from JSON collection
CREATE OR REPLACE VIEW STREAMDATA_VIEW AS
SELECT STREAM, TO_TIMESTAMP(KEY, 'YYYY-MM-DD HH24:MI:SS.FF') KEY, PARTITION, OFFSET, TIMESTAMP, EQUIPMENT_ID, VIBRATION_AMPLITUDE, VIBRATION_FREQUENCY, TEMPERATURE, HUMIDITY from STREAMDATA,
    JSON_TABLE (
        STREAMDATA.JSON_DOCUMENT COLUMNS (
            NESTED PATH '$[*]' COLUMNS (
                STREAM VARCHAR2(40) PATH '$.stream',
                KEY VARCHAR2(100) PATH '$.key',
                PARTITION NUMBER PATH '$.partition',
                OFFSET NUMBER PATH '$.offset',
                TIMESTAMP NUMBER PATH '$.timestamp',
                EQUIPMENT_ID NUMBER PATH '$.equipment_id',
                VIBRATION_AMPLITUDE NUMBER PATH '$.vibration_amplitude',
                VIBRATION_FREQUENCY NUMBER PATH '$.vibration_frequency',
                TEMPERATURE NUMBER PATH '$.temperature',
                HUMIDITY NUMBER PATH '$.humidity'
            )
        )
    ) ORDER BY KEY DESC;

-- QUERIES FOR VIEW:
-- Select all data in STREAMDATA_VIEW
SELECT * FROM STREAMDATA_VIEW ORDER BY KEY DESC;
-- Select the number of rows in STREAMDATA_VIEW
SELECT count(*) FROM STREAMDATA_VIEW;

-- QUERIES FOR JSON
-- Select all metadadata in JSON collection.  JSON payload data is within "BLOB"
SELECT * FROM STREAMDATA;
-- Select JSON payload data from JSON collection and return it in a table format
SELECT stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity FROM STREAMDATA, JSON_TABLE(JSON_DOCUMENT, '$' COLUMNS(stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity));