/*********************************************************************
Scott Peters
Find The Spaces
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL

This script uses recursion to find the spaces in a given string and determine their start and position points. 
The script starts by creating a table called #Strings that stores a set of strings.  The script then uses a common 
table expression (CTE) called cte_CAST to cast the strings in the #Strings table to VARCHAR(200) and a CTE called 
cte_Anchor to find the spaces in the strings recursively. The cte_Anchor CTE uses the CHARINDEX function to find 
the position of the space character in the string and the Position column to find the next space in the
string recursively. The script also uses the SUBSTRING function to extract the word between spaces and the LEN function and REPLACE 
function to find the total number of spaces in the string. The script then uses the ROW_NUMBER() function to assign 
a unique row number to each space found and displays the results.

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
--Display the results using recursion
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
GO
