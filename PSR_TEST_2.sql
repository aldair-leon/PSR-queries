/*INGEST SERVICE*/

DECLARE @created_at datetime2;
DECLARE @created_at_end datetime2;

SET @created_at = '2021-08-20 14:10:00'
SET @created_at_end = '2021-08-20 15:00:00'


SELECT
    MSG_EVNT.MSG_EVNT_ID,
    MSG_EVNT.MSG_HDR_ID,
    MSG_EVNT.STATUS,
    MSG_EVNT.CRTD_AT,
    MSG_HDR.LST_UPDT_AT,
    MSG_HDR.DOC_TMSTMP ,
    MSG_HDR.CRNT_STATUS,
    MSG_HDR.END_PNT_TYPE,
    MSG_HDR.END_PNT_NAME,
    MSG_HDR.MDL_TYPE,
    MSG_HDR.MSG_TYPE,
    MSG_HDR.MSG_ID,
    MSG_HDR.MSG_SNDR,
    MSG_HDR.MSG_RCVRS,
    FORMAT( (MSG_HDR.LST_UPDT_AT) -  (MSG_EVNT.CRTD_AT), 'mm:ss.ff') AS TOTAL_TIME
FROM
    CONNECT_MS.MS_MSG_EVNT AS MSG_EVNT JOIN CONNECT_MS.MS_MSG_HDR AS MSG_HDR ON MSG_EVNT.MSG_HDR_ID = MSG_HDR.MSG_HDR_ID
        AND MSG_EVNT.STATUS = 'Received ' AND MSG_HDR.MDL_TYPE LIKE '%BYDM%'
WHERE MSG_EVNT.CRTD_AT > @created_at and MSG_EVNT.CRTD_AT < @created_at_end
order by MSG_EVNT.CRTD_AT DESC
;

DECLARE @created_at datetime2;
DECLARE @created_at_end datetime2;

SET @created_at = '2021-08-20 14:10:00'
SET @created_at_end = '2021-08-20 15:00:00'


SELECT
    COUNT(MSG_HDR.MSG_TYPE) AS NUMBER_PROCESS_MESSAGES,
    MSG_HDR.MSG_TYPE,
    MIN(MSG_EVNT.CRTD_AT) AS 'Ingestion Service started',
    MAX(MSG_HDR.LST_UPDT_AT) AS 'Ingestion Service finished',
    FORMAT(MAX(MSG_HDR.LST_UPDT_AT) -  MIN(MSG_EVNT.CRTD_AT), 'mm:ss.ff') AS TOTAL_TIME
FROM CONNECT_MS.MS_MSG_EVNT AS MSG_EVNT JOIN CONNECT_MS.MS_MSG_HDR AS MSG_HDR ON MSG_EVNT.MSG_HDR_ID = MSG_HDR.MSG_HDR_ID
WHERE MSG_EVNT.CRTD_AT >  @created_at and MSG_EVNT.CRTD_AT < @created_at_end AND MSG_EVNT.STATUS = 'Received' AND MSG_HDR.MDL_TYPE LIKE '%BYDM%'
group by MSG_HDR.MSG_TYPE,MSG_EVNT.STATUS
;

DECLARE @created_at datetime2;
DECLARE @created_at_end datetime2;

SET @created_at = '2021-08-20 14:10:00'
SET @created_at_end = '2021-08-20 15:00:00'


SELECT
    MSG_HDR.MSG_TYPE,
    MSG_HDR.CRNT_STATUS AS 'Ingestion Service Status',
    MSG_EVNT.CRTD_AT AS 'Ingest Service started',
    MSG_HDR.LST_UPDT_AT AS 'Ingest Service finished',
    MSG_HDR.MDL_TYPE AS 'Format File',
    MSG_HDR.MSG_ID,
    FORMAT( (MSG_HDR.LST_UPDT_AT) -  (MSG_EVNT.CRTD_AT), 'mm:ss.ff') AS TOTAL_TIME
FROM CONNECT_MS.MS_MSG_EVNT AS MSG_EVNT JOIN CONNECT_MS.MS_MSG_HDR AS MSG_HDR ON MSG_EVNT.MSG_HDR_ID = MSG_HDR.MSG_HDR_ID
        AND MSG_EVNT.STATUS = 'Received ' AND MSG_HDR.MDL_TYPE LIKE '%BYDM%'
WHERE MSG_EVNT.CRTD_AT > @created_at and MSG_EVNT.CRTD_AT < @created_at_end
order by MSG_EVNT.CRTD_AT
;


-- /*MESSAGE BROKER*/

/*Total time*/

SELECT
    COUNT(MSG_HDR.MSG_TYPE)/2 AS 'Total of Message',
    MSG_HDR.MSG_TYPE,
    MIN(BULK_EVENT.CRTD_AT) AS 'Transform Started',
    MAX(BULK_EVENT.CRTD_AT) AS 'Transform Finished',
    FORMAT(MAX(BULK_EVENT.CRTD_AT) -  MIN(BULK_EVENT.CRTD_AT), 'HH:mm.ss.ff') AS TOTAL_TIME
FROM CONNECT_MS.MS_BLK_EVNT AS BULK_EVENT JOIN CONNECT_MS.MS_BLK_HDR AS BLK_HDR ON  BULK_EVENT.BLK_HDR_ID =  BLK_HDR.BLK_HDR_ID JOIN CONNECT_MS.MS_MSG_HDR AS MSG_HDR ON BLK_HDR.BLK_SRC_ID LIKE CONCAT('%', MSG_HDR.MSG_ID,'%')
WHERE BULK_EVENT.CRTD_AT > '2021-08-20 14:10:00' and BULK_EVENT.CRTD_AT <  '2021-08-20 15:00:00' AND BULK_EVENT.STATUS != 'Processed'
GROUP BY MSG_HDR.MSG_TYPE
ORDER BY  COUNT(MSG_HDR.MSG_TYPE)/2 ASC;


SELECT
    MSG_HDR.MSG_TYPE,
    BULK_EVENT.BLK_HDR_ID,
    MIN(BULK_EVENT.CRTD_AT) AS 'Transform Started',
    MAX(BULK_EVENT.CRTD_AT) AS 'Transform Finished',
    BLK_HDR.BLK_ID AS 'MSG_IG',
    FORMAT(MAX(BULK_EVENT.CRTD_AT) -  MIN(BULK_EVENT.CRTD_AT), 'HH:mm.ss.ff') AS TOTAL_TIME
FROM CONNECT_MS.MS_BLK_EVNT AS BULK_EVENT JOIN CONNECT_MS.MS_BLK_HDR AS BLK_HDR ON  BULK_EVENT.BLK_HDR_ID =  BLK_HDR.BLK_HDR_ID JOIN CONNECT_MS.MS_MSG_HDR AS MSG_HDR ON BLK_HDR.BLK_SRC_ID LIKE CONCAT('%', MSG_HDR.MSG_ID,'%')
WHERE BULK_EVENT.CRTD_AT > '2021-08-20 14:10:00' and BULK_EVENT.CRTD_AT <  '2021-08-20 15:00:00' AND BULK_EVENT.STATUS != 'Processed'
GROUP BY BULK_EVENT.BLK_HDR_ID,BLK_HDR.BLK_ID,MSG_HDR.MSG_TYPE
ORDER BY BULK_EVENT.BLK_HDR_ID;



SELECT
    BULK_EVENT.BLK_EVNT_ID,
    BULK_EVENT.BLK_HDR_ID,
    BULK_EVENT.STATUS,
    BULK_EVENT.CRTD_AT,
    BULK_EVENT.BTCH_TASK,
    BLK_HDR.BLK_HDR_ID,
    BLK_HDR.CRTD_AT,
    BLK_HDR.LST_UPDT_AT,
    BLK_HDR.CRNT_STATUS,
    BLK_HDR.BLK_ID,
    BLK_HDR.BLK_TYPE,
    BLK_HDR.BLK_LOC
FROM CONNECT_MS.MS_BLK_EVNT AS BULK_EVENT JOIN CONNECT_MS.MS_BLK_HDR AS BLK_HDR ON  BULK_EVENT.BLK_HDR_ID =  BLK_HDR.BLK_HDR_ID
WHERE BULK_EVENT.CRTD_AT > '2021-08-20 14:19:00' and BULK_EVENT.CRTD_AT <  '2021-08-20 15:00:00'
order by BULK_EVENT.CRTD_AT ASC;

/*JSON API Message*/

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


