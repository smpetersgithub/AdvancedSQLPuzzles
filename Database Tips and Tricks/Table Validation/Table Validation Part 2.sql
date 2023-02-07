/*----------------------------------------------------
Scott Peters
Dynamic Full Outer Join
https://advancedsqlpuzzles.com
Last Updated: 01/13/2022
Microsoft SQL Server T-SQL

This script creates a dynamic SQL statement for performing a full outer join between two tables, 
with the ability to compare column counts, row counts, and distinct row counts between the two tables.
The script also includes the ability to join on specific columns, with results sorted by level of validation (100-900).

Instructions:

1) Set the LookupID variable to match the ID of the desired tables to compare in the ##TableInformation table.
2) Execute the script.
3) The final dynamic SQL statement will be located in the #SQLStatementFinal table.

*/----------------------------------------------------

SET NOCOUNT ON;

----------------------------------------
----------------------------------------
--Tables are created in this order, which I have defined as levels
--The levels are used in the creation of the dynamic SQL for sorting
DROP TABLE IF EXISTS #Select;-------------Level 100
DROP TABLE IF EXISTS #Exists;-------------Level 200
DROP TABLE IF EXISTS #RowNumber;----------Level 300
DROP TABLE IF EXISTS #Count;--------------Level 400
DROP TABLE IF EXISTS #Distinct_Count;-----Level 500
DROP TABLE IF EXISTS #Compare;------------Level 600
DROP TABLE IF EXISTS #Columns;------------Level 600 (Set the QueryOrder to the same value as #Compare to project the _Compare field next to the _Table1 and _Table2 fields)
DROP TABLE IF EXISTS #Into;---------------Level 700
DROP TABLE IF EXISTS #From;---------------Level 800
DROP TABLE IF EXISTS #FullOuterJoin;------Level 900
DROP TABLE IF EXISTS #SQLStatementTemp;-------Used to create dynamic SQL statement
DROP TABLE IF EXISTS #SQLStatementFinal;--Used to create dynamic SQL statement
GO

----------------------------------------
----------------------------------------
--Set this value!!
--It is used to query the ##TableInformation table
DECLARE @LookupID AS INTEGER = 1;-----------------Set this value!!!!!!

-------------------------------------------
-------------------------------------------
--Set variables from the ##TableInformation table
DECLARE @MySQLStatement AS VARCHAR(MAX);
DECLARE @TempTable AS VARCHAR(MAX) = (SELECT CONCAT('##',Table1Name,'_TemporaryTable') FROM ##TableInformation WHERE LookupID = @LookupID);
DECLARE @DropTable AS VARCHAR(MAX) = CONCAT('DROP TABLE IF EXISTS ',@TempTable);
DECLARE @Table1 AS VARCHAR(MAX) = (SELECT Table1Name FROM ##TableInformation WHERE LookupID = @LookupID);
DECLARE @Table2 AS VARCHAR(MAX) = (SELECT Table2Name FROM ##TableInformation WHERE LookupID = @LookupID);
DECLARE @Schema1 AS VARCHAR(MAX) = (SELECT Schema1Name FROM ##TableInformation WHERE LookupID = @LookupID);
DECLARE @Schema2 AS VARCHAR(MAX) = (SELECT Schema2Name FROM ##TableInformation WHERE LookupID = @LookupID);
DECLARE @Exists1 AS VARCHAR(MAX) = (SELECT Exists1 FROM ##TableInformation WHERE LookupID = @LookupID);
DECLARE @Exists2 AS VARCHAR(MAX) = (SELECT Exists2 FROM ##TableInformation WHERE LookupID = @LookupID);
DECLARE @JoinSyntax AS VARCHAR(MAX) = (SELECT CONCAT(Exists1, ' = ', Exists2) FROM ##TableInformation WHERE LookupID = @LookupID);
DECLARE @RowNumberSyntax AS VARCHAR(MAX) = (SELECT Exists1 FROM ##TableInformation WHERE LookupID = @LookupID);

--Drop the temporary table
EXECUTE(@DropTable);

-----------------------------
-----------------------------
--Level_100
--SELECT statement
SELECT  100 AS QueryOrder
        ,'SELECT ''Start Compare-->'' AS CompareStart' AS SQLStatement
INTO    #Select
UNION ALL
SELECT 101, CONCAT(',''',@Schema1, ',', @Table1, ''' AS TableName1')
UNION ALL
SELECT 102, CONCAT(',''',@Schema1, ',', @Table2, ''' AS TableName2')
UNION ALL
SELECT 103, CONCAT(',''',@@SERVERNAME, ''' AS ServerName')
UNION ALL
SELECT 104, CONCAT(',''',@Exists1, ''' AS JoinSyntax_Table1')
UNION ALL
SELECT 105, CONCAT(',''',@Exists2, ''' AS JoinSyntax_Table2');

-----------------------------
-----------------------------
--Level 200
--Exists
SELECT  200 AS QueryOrder
        ,CONCAT(',CASE WHEN ', @Exists1, ' = '''' THEN 1 ELSE 0 END AS NotExists_Table1') AS SQLStatement
INTO    #Exists
UNION ALL
SELECT  210 AS QueryOrder
        ,CONCAT(',CASE WHEN ', @Exists2, ' = '''' THEN 1 ELSE 0 END AS NotExists_Table2') AS SQLStatement

-----------------------------
-----------------------------
--Level_300
--RowNumber_Table1 (Find Duplicates)
SELECT  300 AS QueryOrder
        ,CONCAT(',ROW_NUMBER() OVER (PARTITION BY ', @RowNumberSyntax, ' ORDER BY ',@RowNumberSyntax,') AS RowNumber_Table1') AS SQLStatement
INTO    #RowNumber

-----------------------------
-----------------------------
--Level 400
--Count_Table1, Count_Table2
SELECT  400 AS QueryOrder
        ,CONCAT(',', '(SELECT COUNT(*) FROM ',CONCAT(@Schema1,'.',@Table1),') AS Count_Table1') AS SQLStatement
INTO    #Count
UNION ALL
SELECT  410 AS QueryOrder
        ,CONCAT(',', '(SELECT COUNT(*) FROM ',CONCAT(@Schema2,'.',@Table2),') AS Count_Table2') AS SQLStatement

-----------------------------
-----------------------------
--Level 500
--DistinctCount fields
SELECT  500 AS QueryOrder
        ,CONCAT(',', '(SELECT COUNT(DISTINCT ', @Exists1, ') FROM ',CONCAT(@Schema1,'.',@Table1),' AS t1) AS DistinctCount_Table1') AS SQLStatement
INTO    #DISTINCT_COUNT
UNION ALL
SELECT  510 AS QueryOrder
        ,CONCAT(',', '(SELECT COUNT(DISTINCT ', @Exists2, ') FROM ',CONCAT(@Schema2,'.',@Table2),' AS t2) AS DistinctCount_Table2') AS SQLStatement
UNION ALL
SELECT 520
        ,CONCAT(',', '(SELECT COUNT(*) FROM ',CONCAT(@Schema1,'.',@Table1),' AS t1 INNER JOIN ',CONCAT(@Schema2,'.',@Table2),' AS t2 ON ',@Joinsyntax,') AS DistinctIntersect')

-----------------------------
-----------------------------
--Level 600
--Compare fields
SELECT  DISTINCT
        600 AS QueryOrder
        ,c.Name AS ColumnName
        ,CONCAT('OR ',c.Name, '_Compare = 1') AS ColumnName_Compare
        ,CONCAT(',CASE WHEN t1.[',c.name, '] IS NULL AND t2.[',c.name, '] IS NULL THEN 0 WHEN t1.[',c.name, '] = ', 't2.[', c.name, '] THEN 0 ELSE 1 END AS [', c.name,'_Compare]')
            AS SQLStatement
INTO    #Compare
FROM    sys.schemas s LEFT OUTER JOIN
        sys.tables t ON s.schema_id = t.schema_id INNER JOIN
        sys.columns c ON t.object_id = c.object_id INNER JOIN
        sys.types ty ON ty.user_type_id = c.user_type_id
WHERE   (t.name = @Table1  AND s.name = @Schema1) OR 
        (t.name = @Table2 AND s.name = @Schema2);

-----------------------------
-----------------------------
--Level 600
--Creates the Column fields
SELECT  600 AS QueryOrder --Set this value to the same as #Compare to project the _Compare field next to the _Table1 and _Table2 fields
        ,c.Name AS ColumnName
        ,CASE WHEN t.name = @Table1 THEN CONCAT(',t1.[',c.name,'] AS [',c.name, '_Table1]')
             WHEN t.name = @Table2 THEN CONCAT(',t2.[',c.name,'] AS [',c.name, '_Table2]') END AS SQLStatement
INTO    #Columns
FROM    sys.schemas s LEFT OUTER JOIN
        sys.tables t ON s.schema_id = t.schema_id INNER JOIN
        sys.columns c ON t.object_id = c.object_id INNER JOIN
        sys.types ty ON ty.user_type_id = c.user_type_id
WHERE   (t.name = @Table1 AND s.name = @Schema1)
         OR
        (t.name = @Table2 AND s.name = @Schema2);

-----------------------------
-----------------------------
--Level 700
--INTO Statement
SELECT 700 AS QueryOrder
        ,CONCAT('INTO ',@TempTable) AS SQLStatement
INTO    #Into;

-----------------------------
-----------------------------
--Level 800
--FROM Statement
SELECT  800 AS QueryOrder
        ,'FROM' AS SQLStatement
INTO    #From;

-----------------------------
-----------------------------
--Level 900
--FULL OUTER JOIN
SELECT  900 AS QueryOrder
        ,CONCAT(@Schema1,'.',@Table1, ' t1 FULL OUTER JOIN ') AS SQLStatement
INTO    #FullOuterJoin
UNION
SELECT  950 AS QueryOrder
        ,CONCAT(@Schema2,'.',@Table2, ' t2 ON  ',@JoinSyntax);

-----------------------------
-----------------------------
--Create table #SQLStatement
--This is then used to create the #SQLStatementFinal table
;WITH CTE_SQLStatement_A AS
(
SELECT  QueryOrder
        ,SQLStatement
FROM    #Select
UNION ALL
SELECT  QueryOrder
        ,SQLStatement
FROM    #Exists
UNION ALL
SELECT  QueryOrder
        ,SQLStatement
FROM    #Distinct_Count
UNION ALL
SELECT  QueryOrder
        ,SQLStatement
FROM    #Count
UNION ALL
SELECT  QueryOrder
        ,SQLStatement
FROM    #From
UNION ALL
SELECT  QueryOrder
        ,SQLStatement
FROM    #FullOuterJoin
),
CTE_SQLStatement_B AS
(
SELECT  QueryOrder
        ,ColumnName AS SortID
        ,SQLStatement
FROM    #Columns
UNION ALL
SELECT  QueryOrder
        ,ColumnName AS SortID
        ,SQLStatement
FROM    #Compare
UNION ALL
SELECT  QueryOrder
        ,CONVERT(VARCHAR(255), NEWID()) SortID
        ,SQLStatement
FROM    CTE_SQLStatement_A
)
SELECT  ROW_NUMBER() OVER (ORDER BY QueryOrder, SortID, SQLStatement) AS QueryOrder
        ,SQLStatement
INTO    #SQLStatementTemp
FROM    CTE_SQLStatement_B
ORDER BY QueryOrder, SortID, SQLStatement;

-----------------------------
-----------------------------
--Create table #SQLStatementFinal
SELECT 'WITH CTE_SQLStatement AS ( ' AS SQLStatement
INTO    #SQLStatementFinal
UNION ALL
SELECT SQLStatement FROM #SQLStatementTemp
UNION ALL
SELECT ') SELECT '
UNION ALL
SELECT 'CASE WHEN '
UNION ALL
SELECT SUBSTRING(STRING_AGG(ColumnName_Compare,' '),4,LEN(STRING_AGG(ColumnName_Compare,' ')))-- REMOVES THE INITIAL 'OR' IN THE CASE STATEMENT
FROM    #Compare
UNION ALL
SELECT ' THEN 1 ELSE 0 END AS [Compare_Summary]'
UNION ALL
SELECT ',* '
UNION ALL
SELECT  SQLStatement
FROM    #Into
UNION ALL
SELECT 'FROM CTE_SQLStatement;'

-----------------------------
-----------------------------
--Places the SQL statement into one line
SELECT  @MySQLStatement = STRING_AGG(SQLStatement,' ')
FROM    #SQLStatementFinal;

/*
--Display the SQL Statement
SELECT  * FROM #SQLStatementFinal;
*/

EXECUTE(@MySQLStatement);
EXECUTE('SELECT DISTINCT * FROM ' + @TempTable + ' ORDER BY 1 DESC, 2,3,4,5');      --The CONCAT function does not work for dynamic sql.
GO
-------------------------------
