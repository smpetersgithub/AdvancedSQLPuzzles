/*********************************************************************
Scott Peters
Create Constraints On A Temp Table
https://advancedsqlpuzzles.com
Last Updated: 03/10/2023
Microsoft SQL Server T-SQL

This script creates several constraints on a temporary table, #EmployeePayRecords, which is 
identical to the constraints on the persistent table EmployeePayRecords in the dbo schema.

It should be noted that the script uses the specific example table "EmployeePayRecords" and the schema "dbo". 
The user should adjust the variables @vschema_name and @vtable_name to the appropriate names of the desired table to use.

Also, temporary tables are only available while the SQL Server instance is running, and the data is not persisted across restarts, 
therefore, it should not be used for any type of permanent data storage or as a permanent solution.

The script creates several temporary tables to store the SQL statements that will create the different types of constraints on the temporary table.
#DynamicSQL
#PrimaryUniqueKeyConstraints
#NULLConstraints 
#CheckConstraints 
#ForeignPrimaryUniqueKeyConstraints

It then populates the #DynamicSQL table with a set of SQL statements generated from information 
in the system tables of the SQL Server instance, such as sys.tables, sys.indexes, and sys.key_constraints.

The SQL statements in the #DynamicSQL table are then executed to create the NOT NULL, UNIQUE, PRIMARY KEY, and CHECK constraints 
on the #EmployeePayRecords temporary table, though FOREIGN KEY constraints cannot be created on a temp table, 
due to the limitation of the temp table only being stored on the tempdb.

Instructions:
Step 1  Manually create the temp table from the persistent table using SELECT * INTO (you cannot create a temp table via dynamic sql).
Step 2  Change the variables @vschema_name and @vtable_name to the appropriate names.

----------------
Notes:
Temporary tables in SQL Server are stored in the tempdb database, which is a system database that 
is recreated every time the SQL Server instance is started. This means that the data in tempdb is 
only available while the SQL Server instance is running, and the data is not persisted across restarts.

The reason temp tables are stored in tempdb is to separate them from other user databases, as temporary 
tables are only used for the duration of a session or a transaction and are not meant to be permanent. 
For this reason, the metadata for temporary tables is not stored in the normal system tables.

Storing temporary tables in tempdb allows SQL Server to more easily manage and maintain them. It can 
also improve performance as it is separate from other databases, helping reduce resource contention. 
Additionally, Microsoft SQL Server uses tempdb to store various other internal objects such as temporary tables, 
temporary stored procedures, and intermediate results of queries.

**********************************************************************/

-----------------------------------------------
-----------------------------------------------
SET NOCOUNT ON;

DROP TABLE IF EXISTS #DynamicSQL;
DROP TABLE IF EXISTS #PrimaryUniqueKeyConstraints;
DROP TABLE IF EXISTS #NULLConstraints;
DROP TABLE IF EXISTS #CheckConstraints;
DROP TABLE IF EXISTS #ForeignPrimaryUniqueKeyConstraints;
GO

CREATE TABLE #DynamicSQL
(
RowNumber INTEGER IDENTITY(1,1) PRIMARY KEY,
SQLStatement VARCHAR(8000) UNIQUE NOT NULL
);
GO

--Insert the values for Schema Name and Table Name
DECLARE @vschema_name VARCHAR(100) = 'dbo';
DECLARE @vtable_name VARCHAR(100) = '__PayrollSummary';

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
--#PrimaryUniqueKeyConstraints
--Primary and Unique constraints
WITH cte_Constraints AS
(
SELECT    o.type AS object_type
        , t.type AS table_type
        , i.type AS index_type
        , c.type AS column_type
        , '--->' AS id
        , o.name AS [object_name]
        , s.name AS schema_name
        , t.name AS table_name
        , i.name AS index_name
        , c.name AS key_constraints_table_name
        , col.name AS column_name
       --Note you can also use this method
        --, OBJECT_NAME(ic.object_id) AS index_columns_name
        --, COL_NAME(ic.object_id,ic.column_id) AS column_name
FROM    sys.objects o
        LEFT OUTER JOIN
        sys.tables t ON o.object_id = t.object_id
        LEFT OUTER JOIN
        sys.indexes i ON t.object_id = i.object_id
        LEFT OUTER JOIN
        sys.key_constraints c ON i.object_id = c.parent_object_id AND i.index_id = c.unique_index_id
        LEFT OUTER JOIN
        sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        LEFT OUTER JOIN
        sys.columns col ON t.object_id = col.object_id
                                AND ic.column_id = col.column_id
        LEFT OUTER JOIN
        sys.schemas s on t.schema_id = s.schema_id
WHERE   t.name = @vtable_name and s.name = @vschema_name
)
SELECT object_type, table_type, index_type, column_type, object_name, schema_name, table_name, index_name, STRING_AGG(column_name,', ') AS column_name
INTO   #PrimaryUniqueKeyConstraints
FROM   cte_Constraints
GROUP BY object_type, table_type, index_type, column_type, object_name, schema_name, table_name, index_name;

SELECT * FROM #PrimaryUniqueKeyConstraints;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
--#CheckConstraints
SELECT  1 AS type
        ,s.name as schema_name
        ,t.name AS table_name
        ,col.name AS column_name
        ,con.name AS constraint_name
        ,con.definition AS constraint_definition
INTO   #CheckConstraints
FROM   sys.tables t INNER JOIN
       sys.columns col ON t.object_id = col.object_id INNER JOIN
       sys.check_constraints con ON con.parent_column_id = col.column_id AND
                             con.parent_object_id = col.object_id INNER JOIN
       sys.schemas s on t.schema_id = s.schema_id
WHERE   t.name = @vtable_name AND s.name = @vschema_name
UNION
SELECT  2 AS type
        ,s.name as schema_name
        ,t.name AS table_name
        ,NULL AS column_name
        ,con.name AS constraint_name
        ,con.definition AS constraint_definition
FROM    sys.tables t INNER JOIN
        sys.columns col ON t.object_id = col.object_id INNER JOIN
        sys.check_constraints con ON col.object_id = con.parent_object_id INNER JOIN
        sys.schemas s on t.schema_id = s.schema_id
WHERE   con.parent_column_id = 0 AND
        t.name = @vtable_name AND s.name = @vschema_name;

SELECT * FROM #CheckConstraints;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
--#NULLConstraints
--Not NULL constraints
SELECT  s.name AS schema_name
        ,t.name AS table_name
        ,c.Name AS column_name
        ,c.is_nullable
        ,ty.name AS date_type
INTO    #NULLConstraints
FROM    sys.tables t INNER JOIN
        sys.columns c ON t.object_id = c.object_id INNER JOIN
        sys.schemas s ON t.schema_id = s.schema_id INNER JOIN
        sys.types ty ON c.user_type_id = ty.user_type_id
WHERE   t.name = @vtable_name AND s.name = @vschema_name AND c.is_nullable = 0;

SELECT * FROM #NULLConstraints;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
--#ForeignPrimaryUniqueKeyConstraints   
SELECT  o.name AS object_name
       ,s.name AS schema_name
       ,t1.name AS table_name
       ,c1.name AS column1_name
       ,t2.name AS t2_name_referenced_table
       ,c2.name AS c2_name_referenced_column
INTO   #ForeignPrimaryUniqueKeyConstraints
FROM
       sys.foreign_key_columns f INNER JOIN
       sys.objects o ON f.constraint_object_id = o.object_id INNER JOIN
       sys.tables t1 ON f.parent_object_id = t1.object_id INNER JOIN
       sys.schemas s ON t1.schema_id = s.schema_id INNER JOIN
       sys.columns c1 ON parent_column_id = c1.column_id AND t1.object_id = c1.object_id INNER JOIN
       sys.tables t2 ON f.referenced_object_id = t2.object_id INNER JOIN
       sys.columns c2 ON c2.column_id = f.referenced_column_id AND t2.object_id = c2.object_id
WHERE  t1.name = @vtable_name AND s.name = @vschema_name;

SELECT * FROM #ForeignPrimaryUniqueKeyConstraints;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

--SELECT * FROM #NULLConstraints;
INSERT INTO #DynamicSQL (SQLStatement)
SELECT CONCAT('ALTER TABLE #', table_name, ' ALTER COLUMN ', column_name, ' ', date_type, ' NOT NULL;') FROM #NULLConstraints;

--SELECT * FROM #PrimaryUniqueKeyConstraints;
INSERT INTO #DynamicSQL (SQLStatement)
SELECT CONCAT('ALTER TABLE #', table_name, ' ADD PRIMARY KEY (', column_name, ');') FROM #PrimaryUniqueKeyConstraints WHERE index_type = 1;
INSERT INTO #DynamicSQL (SQLStatement)
SELECT CONCAT('ALTER TABLE #', table_name, ' ADD UNIQUE (', column_name, ');') FROM #PrimaryUniqueKeyConstraints WHERE index_type = 2;

--SELECT * FROM #CheckConstraints;
INSERT INTO #DynamicSQL (SQLStatement)
SELECT CONCAT('ALTER TABLE #', table_name, ' ADD CHECK (', constraint_definition, ');') FROM #CheckConstraints;

--SELECT * FROM #ForeignPrimaryUniqueKeyConstraints;
--FOREIGN KEY constraints are not enforced on local or global temporary tables.
INSERT INTO #DynamicSQL (SQLStatement)
SELECT CONCAT('ALTER TABLE #', Table_Name, ' ADD FOREIGN KEY (', Column1_Name, ') REFERENCES ', t2_name_referenced_table, '(',c2_name_referenced_column,');') FROM #ForeignPrimaryUniqueKeyConstraints;
GO

-----------------------------------------------------------------
-----------------------------------------------------------------

DECLARE @vRowNumber INTEGER;
DECLARE @vSQLStatement VARCHAR(8000);

DECLARE mycursor CURSOR FOR (SELECT * FROM (SELECT TOP 100000 RowNumber, SQLStatement FROM #DynamicSQL WHERE 1=1 ORDER BY RowNumber) AS tmp);
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

SELECT * FROM #EmployeePayRecords;
/*
--Test 

INSERT INTO #EmployeePayRecords (EmployeeID, EmployeeID_Unique_NotNull, FiscalYear, StartDate, EndDate, PayRate)
VALUES (NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO #EmployeePayRecords (EmployeeID, EmployeeID_Unique_NotNull, FiscalYear, StartDate, EndDate, PayRate)
VALUES (1,1,'2023','01/01/1900','12/31/2023',100000);

--The INSERT statement conflicted with the CHECK constraint "CK__#Employee__EndDa__A82DED14". The conflict occurred in database "tempdb", table "dbo.#EmployeePayRecords_________________________________________________________________________________________________000000000167", column 'EndDate'.
INSERT INTO #EmployeePayRecords (EmployeeID, EmployeeID_Unique_NotNull, FiscalYear, StartDate, EndDate, PayRate)
VALUES (1,1,'2023','01/01/2023','01/31/2023',100000);

*/
