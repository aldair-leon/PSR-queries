
DECLARE @created_at datetime2;
DECLARE @created_at_end datetime2;

SET @created_at = '2021-08-20 14:10:00'
SET @created_at_end = '2021-08-20 15:00:00'



SELECT
    AUDIT_TBL.GROUPED_BY,
    AUDIT_TBL.INGEST_STATUS_MSG,
    AUDIT_TBL.CREATED_DATETIME AS 'Ingestion Started SQL',
    CONVERT(datetime2(3), SUBSTRING(JSON_VALUE(value,'$.eventTime'),0,24)) AS 'API Ingestion Finished Time',
    AUDIT_TBL.MODIFIED_DATETIME AS 'Ingestion Finished SQL',
    FORMAT(CONVERT(datetime, SUBSTRING(JSON_VALUE(value,'$.eventTime'),0,24)) - AUDIT_TBL.CREATED_DATETIME , 'HH:mm.ss.ff') AS 'TOTAL TIME API VS SQL',
    FORMAT(AUDIT_TBL.MODIFIED_DATETIME -AUDIT_TBL.CREATED_DATETIME , 'HH:mm.ss.ff' ) AS 'TOTAL TIME SQL'
FROM  LCTA_MSG_AUDIT_TBL AS AUDIT_TBL CROSS APPLY OPENJSON(AUDIT_TBL.INGEST_STATUS_MSG, '$') 

WHERE AUDIT_TBL.CREATED_DATETIME  > @created_at AND AUDIT_TBL.CREATED_DATETIME < @created_at_end 
AND JSON_VALUE(value,'$.status') = 'COMPLETED' AND NOT JSON_VALUE(value,'$.service') = 'computation';

SELECT
    AUDIT_TBL.GROUPED_BY,
    MIN(AUDIT_TBL.CREATED_DATETIME) AS 'Ingestion Started SQL',
    MAX(CONVERT(datetime2(3), SUBSTRING(JSON_VALUE(value,'$.eventTime'),0,24))) AS 'API Ingestion Finished Time',
    MAX(AUDIT_TBL.MODIFIED_DATETIME) AS 'Ingestion Finished SQL',
    FORMAT(MAX(CONVERT(datetime, SUBSTRING(JSON_VALUE(value,'$.eventTime'),0,24))) - MIN(AUDIT_TBL.CREATED_DATETIME) , 'HH:mm.ss.ff') AS 'TOTAL TIME API VS SQL',
    FORMAT(MAX(AUDIT_TBL.MODIFIED_DATETIME) -MIN(AUDIT_TBL.CREATED_DATETIME) , 'HH:mm.ss.ff' ) AS 'TOTAL TIME SQL'
FROM  LCTA_MSG_AUDIT_TBL AS AUDIT_TBL CROSS APPLY OPENJSON(AUDIT_TBL.INGEST_STATUS_MSG, '$') 

WHERE AUDIT_TBL.CREATED_DATETIME  > @created_at AND AUDIT_TBL.CREATED_DATETIME < @created_at_end 
AND JSON_VALUE(value,'$.status') = 'COMPLETED' AND NOT JSON_VALUE(value,'$.service') = 'computation'
GROUP BY  AUDIT_TBL.GROUPED_BY;
