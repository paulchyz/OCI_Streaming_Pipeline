-- Create STREAMDATA_TABLE
-- Creates a table with columns that match the data structure in the stream
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
-- Queries JSON collection for any data not in STREAMDATA_TABLE and inserts that data into the table
CREATE PROCEDURE UPDATE_STREAMDATA_TABLE 
AS 
BEGIN 
   INSERT INTO ADMIN.STREAMDATA_TABLE SELECT stream, TO_TIMESTAMP(key, 'YYYY-MM-DD HH24:MI:SS.FF'), partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity FROM STREAMDATA, JSON_TABLE(JSON_DOCUMENT, '$' COLUMNS(stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity)) WHERE TO_TIMESTAMP(key, 'YYYY-MM-DD HH24:MI:SS.FF') NOT IN (SELECT KEY FROM ADMIN.STREAMDATA_TABLE);
END UPDATE_STREAMDATA_TABLE; 

-- DBMS scheduled job to execute stored procedure at a regular interval
-- Change "Interval" as needed to change execution interval
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'collection_to_table_job',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'ADMIN.UPDATE_STREAMDATA_TABLE',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'FREQ=MINUTELY; INTERVAL=5',
   enabled            =>  TRUE);
END;

-- QUERIES FOR TABLE:
-- Select all data in STREAMDATA_TABLE
SELECT * FROM STREAMDATA_TABLE ORDER BY KEY DESC;
-- Select the number of rows in STREAMDATA_TABLE
SELECT count(*) FROM STREAMDATA_TABLE;

-- QUERIES FOR JSON
-- Select all metadadata in JSON collection.  JSON payload data is within "BLOB"
SELECT * FROM STREAMDATA;
-- Select JSON payload data from JSON collection and return it in a table format
SELECT stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity FROM STREAMDATA, JSON_TABLE(JSON_DOCUMENT, '$' COLUMNS(stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity))

-- QUERIES FOR STORED PROCEDURE AND DBMS SCHEDULER
-- Manually run the stored procedure to update STREAMDATA_TABLE
EXECUTE ADMIN.UPDATE_STREAMDATA_TABLE;
-- Drop the stored procedure to update STREAMDATA_TABLE
DROP PROCEDURE UPDATE_STREAMDATA_TABLE;
-- View DBMS Scheduler information for ADMIN jobs, which includes the job that schedules the stored procedure
SELECT * FROM dba_scheduler_jobs WHERE JOB_CREATOR='ADMIN';