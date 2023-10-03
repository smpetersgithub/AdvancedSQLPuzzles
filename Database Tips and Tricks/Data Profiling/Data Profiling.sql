/*********************************************************************
Scott Peters
Data Profiling
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script is intended to update a temporary table called #DataProfiling with a user 
supplied metric (such as COUNT, AVG, MAX, MIN) for a user-specified schema and table name. 

The script uses a cursor to iterate through each column in the specified table, and 
execute an update statement for each column with a different metric specified. 

This script creates a temporary table called #DataProfilingSQL, which contains the 
SQL statements that are used to update the #DataProfiling table.

Example SQL statements are provided to find NULL markers, empty strings, keywords, etc.

**********************************************************************/

SET NOCOUNT ON;

DROP TABLE IF EXISTS #DataProfiling;
DROP TABLE IF EXISTS #DataProfilingSQL;
GO

CREATE TABLE #DataProfilingSQL
(
DataProfilingType INTEGER NOT NULL,
OrderID           INTEGER NOT NULL,
SQLLine           VARCHAR(100) NOT NULL,
PRIMARY KEY (DataProfilingType, OrderID)
);
GO

-----------------------------------------------------------------
-----------------------------------------------------------------

DECLARE @vSchemaName NVARCHAR(100) = 'Your Schema Name Here';---------------Need to set
DECLARE @vTableName NVARCHAR(100) = 'Your Table Name Here'; ----------------Need to set

----------------------------------------------------------------------------------------
--This SQL statement determines the record count of the column
INSERT INTO #DataProfilingSQL (DataProfilingType, OrderID, SQLLine) VALUES
(1,1,'UPDATE #DataProfiling SET RecordCount ='),
(1,2,'('),
(1,3,'SELECT  COUNT([ColumnName])'),
(1,4,'FROM    SchemaName.TableName'),
(1,5,')'),
(1,6,'WHERE RowNumber = vRowNumber');

----------------------------------------------------------------------------------------
--This SQL statement determines the count of empty strings in a column
INSERT INTO #DataProfilingSQL (DataProfilingType, OrderID, SQLLine) VALUES
(2,1,'UPDATE #DataProfiling SET RecordCount ='),
(2,2,'('),
(2,3,'SELECT  COUNT([ColumnName])'),
(2,4,'FROM    SchemaName.TableName'),
(2,5,'WHERE   [ColumnName] = '''''),
(2,6,')'),
(2,7,'WHERE RowNumber = vRowNumber');

----------------------------------------------------------------------------------------
--This SQL statement determines the count of NULL markers
INSERT INTO #DataProfilingSQL (DataProfilingType, OrderID, SQLLine) VALUES
(3,1,'UPDATE #DataProfiling SET RecordCount ='),
(3,2,'('),
(3,3,'SELECT  COUNT([ColumnName])'),
(3,4,'FROM    SchemaName.TableName'),
(3,5,'WHERE   [ColumnName] IS NULL'),
(3,6,')'),
(3,7,'WHERE RowNumber = vRowNumber');

----------------------------------------------------------------------------------------
--This SQL statement determines the count of records that have two spaces
INSERT INTO #DataProfilingSQL (DataProfilingType, OrderID, SQLLine) VALUES
(4,1,'UPDATE #DataProfiling SET RecordCount ='),
(4,2,'('),
(4,3,'SELECT  COUNT([ColumnName])'),
(4,4,'FROM    SchemaName.TableName'),
(4,5,'WHERE   [ColumnName] LIKE ''%  %'''),
(4,6,')'),
(4,7,'WHERE RowNumber = vRowNumber');

--This SQL statement determines the count of records that have two "demo" or "test" in the string
INSERT INTO #DataProfilingSQL (DataProfilingType, OrderID, SQLLine) VALUES
(5,1,'UPDATE #DataProfiling SET RecordCount ='),
(5,2,'('),
(5,3,'SELECT  COUNT([ColumnName])'),
(5,4,'FROM    SchemaName.TableName'),
(5,5,'WHERE   [ColumnName] LIKE ''%demo%'''),
(5,6,'        OR [ColumnName] LIKE ''%test%'''),
(5,7,')'),
(5,8,'WHERE RowNumber = vRowNumber');

--From the above #DataProfilingSQL table, choose which statement to run.  The default is 1.
DECLARE @vSQLStatement NVARCHAR(1000) = (SELECT STRING_AGG(SQLLine,' ') FROM #DataProfilingSQL WHERE DataProfilingType = 1); --default is 1
PRINT @vSQLStatement;
----------------------------------------------------------------------------------------

SET @vSQLStatement = REPLACE(@vSQLStatement,'SchemaName',@vSchemaName);
SET @vSQLStatement = REPLACE(@vSQLStatement,'TableName',@vTableName);

SELECT  ROW_NUMBER() OVER (ORDER BY t.[Name], c.[Name]) AS RowNumber,
        @@SERVERNAME AS ServerName,
        s.[Name] AS SchemaName, 
        t.[Name] AS TableName, 
        c.[Name] AS ColumnName, 
        ty.[Name] AS DataType,
        REPLACE(@vSQLStatement,'ColumnName',c.[Name]) AS SQLStatement,
        CAST(NULL AS BIGINT) AS RecordCount
INTO    #DataProfiling
FROM    sys.Schemas s LEFT OUTER JOIN
        sys.Tables t ON s.Schema_id = t.Schema_id INNER JOIN
        sys.Columns c ON t.Object_id = c.Object_id INNER JOIN
        sys.Types ty ON ty.User_Type_ID = c.User_Type_ID
WHERE   1=1 AND 
        s.[Name] = @vSchemaName AND 
        t.[Name] = @vTableName
        AND ty.Name NOT IN ('XML','uniqueidentifier')--------------------------------Modify as needed
ORDER BY 1,2,3,4,5;
GO

-----------------------------------------------------------------
-----------------------------------------------------------------

DECLARE @vRowNumber INTEGER;
DECLARE @vSQLStatement VARCHAR(8000);

DECLARE mycursor CURSOR FOR (SELECT RowNumber, SQLStatement FROM #DataProfiling);
OPEN mycursor;

FETCH NEXT FROM mycursor INTO @vRowNumber, @vSQLStatement;
    WHILE @@FETCH_STATUS = 0
        BEGIN
        SET @vSQLStatement = REPLACE(@vSQLStatement,'vRowNumber',@vRowNumber)
        EXEC (@vSQLStatement);
        FETCH NEXT FROM mycursor INTO @vRowNumber, @vSQLStatement;
        END;
CLOSE mycursor;
DEALLOCATE mycursor;

SELECT * FROM #DataProfiling ORDER BY 1;
