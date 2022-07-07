/*********************************************************************
Scott Peters
Find The Spaces
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• The following code uses recursion and determines start and position points of a specified character
• A #Strings table is the only table needed to solve this puzzle

**********************************************************************/

-------------------------------
-------------------------------
--Tables Used
DROP TABLE IF EXISTS #Strings;
GO

-------------------------------
-------------------------------
--Create table #Quotes
SELECT *
INTO #Strings
FROM (VALUES(1,'SELECT EmpID, MngrID FROM Employees;'),(2,'SELECT * FROM Transactions;')) n(Id,String);
GO

-------------------------------
-------------------------------
--Dispaly the results using recursion
;WITH cte_CAST AS
(
SELECT Id, CAST(String AS VARCHAR(200)) AS String FROM #Strings
),
cte_Anchor AS
(
SELECT Id,
       String,
       1 AS Starts,
       CHARINDEX(' ', String) AS Position
FROM   cte_CAST
UNION ALL
SELECT Id,
       String,
       Position + 1,
       CHARINDEX(' ', String, Position + 1)
FROM   cte_Anchor
WHERE  Position > 0
)
SELECT  ROW_NUMBER() OVER (PARTITION BY Id ORDER BY Starts) AS RowNumber,
        *,
        SUBSTRING(String, Starts, CASE WHEN Position > 0 THEN Position - Starts ELSE LEN(String) END) Word,
        LEN(String) - LEN(REPLACE(String,' ','')) AS TotalSpaces
FROM   cte_Anchor
ORDER BY Id, Starts;
