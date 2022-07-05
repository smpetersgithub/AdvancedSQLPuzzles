/*********************************************************************
Scott Peters
Factorials
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• Determining factorials can be done using a recursive common table expression
• The total numbers/rows to create is set in the variable @vTotalNumbers
• The #Numbers table is created dynamically in the recursive SQL statement

**********************************************************************/

---------------------
---------------------
--Tables used in script
DROP TABLE IF EXISTS #Numbers;
GO

---------------------
---------------------
--Declare and set and variables
DECLARE @vTotalNumbers INTEGER = 10;

---------------------
---------------------
--Create #Numbers table using recursion
WITH cte_Factorial (Number, Factorial) AS
(
SELECT 1,
       1
UNION ALL
SELECT  Number + 1 AS Number,
       (Number + 1) * Factorial AS Factorial
FROM   cte_Factorial
WHERE  Number < @vTotalNumbers
)
SELECT Number,
       Factorial
INTO   #Numbers
FROM   cte_Factorial
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level;

---------------------
---------------------
--Display the results
SELECT *
FROM   #Numbers;
GO

