-- Create STREAMDATA_TABLE
create table STREAMDATA_TABLE
(
    STREAM VARCHAR2(40),
    KEY TIMESTAMP,
    PARTITION NUMBER,
    OFFSET NUMBER,
    TIMESTAMP NUMBER,
    EQUIPMENT_ID NUMBER,
    VIBRATION_AMPLITUDE NUMBER,
    VIBRATION_FREQUENCY NUMBER,
    TEMPERATURE NUMBER,
    HUMIDITY NUMBER
);

-- Stored procedure to insert new JSON data into table
CREATE PROCEDURE UPDATE_STREAMDATA_TABLE 
AS 
BEGIN 
   INSERT INTO ADMIN.STREAMDATA_TABLE SELECT stream, TO_TIMESTAMP(key, 'YYYY-MM-DD HH24:MI:SS.FF'), partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity FROM STREAMDATA, JSON_TABLE(JSON_DOCUMENT, '$' COLUMNS(stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity)) WHERE TO_TIMESTAMP(key, 'YYYY-MM-DD HH24:MI:SS.FF') NOT IN (SELECT KEY FROM ADMIN.STREAMDATA_TABLE);
END UPDATE_STREAMDATA_TABLE; 

-- DBMS scheduled job to execute stored procedure at a regular interval
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'collection_to_table_job',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'ADMIN.UPDATE_STREAMDATA_TABLE',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'FREQ=MINUTELY; INTERVAL=5',
   enabled            =>  TRUE);
END;

-- Queries for table
SELECT * FROM STREAMDATA_TABLE ORDER BY KEY DESC;
SELECT count(*) FROM STREAMDATA_TABLE;

-- Queries for JSON
SELECT * FROM STREAMDATA;
SELECT stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity FROM STREAMDATA, JSON_TABLE(JSON_DOCUMENT, '$' COLUMNS(stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity))

-- Queries for stored procedure and DBMS scheduler
DROP PROCEDURE UPDATE_STREAMDATA_TABLE;
EXECUTE ADMIN.UPDATE_STREAMDATA_TABLE;
SELECT * FROM dba_scheduler_jobs WHERE JOB_CREATOR='ADMIN';