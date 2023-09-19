-- STREAMDATA_MV
-- Create database materialized view to return relational data from JSON collection
CREATE MATERIALIZED VIEW STREAMDATA_MV
    BUILD IMMEDIATE
    REFRESH FAST ON STATEMENT WITH PRIMARY KEY
    AS SELECT ID, STREAM, KEY, PARTITION, OFFSET, BATCH_TIMESTAMP, TO_TIMESTAMP(TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF') TIMESTAMP, EQUIPMENT_ID, VIBRATION_AMPLITUDE, VIBRATION_FREQUENCY, TEMPERATURE, HUMIDITY, INFERENCE from STREAMDATA,
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
                        HUMIDITY NUMBER PATH '$.humidity',
                        INFERENCE NUMBER PATH '$.Prediction'
                    )
                )
            )
        );

-- STREAMDATA_MV_IDX
-- Create timestamp index on materialized view
CREATE INDEX STREAMDATA_MV_IDX ON STREAMDATA_MV (TIMESTAMP);

-- STREAMDATA_LAST3_VIEW
-- Create database view to return the most recent 3 minutes of relational data from JSON collection
CREATE OR REPLACE VIEW STREAMDATA_LAST3_VIEW AS
SELECT * FROM STREAMDATA_MV
WHERE TIMESTAMP > (SELECT MAX(TIMESTAMP) FROM STREAMDATA_MV) - INTERVAL '3' MINUTE;


-- FOR REFERENCE
-- Queries for views:
-- Select all data in one of the two views
SELECT * FROM STREAMDATA_MV;
SELECT * FROM STREAMDATA_LAST3_VIEW;
-- Select the number of rows in one of the two views
SELECT count(*) FROM STREAMDATA_MV;
SELECT count(*) FROM STREAMDATA_LAST3_VIEW;

-- Queries for JSON:
-- Select all metadadata in JSON collection.  JSON payload data is within "BLOB"
SELECT * FROM STREAMDATA;