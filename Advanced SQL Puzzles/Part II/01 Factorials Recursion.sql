/*********************************************************************
Scott Peters
Factorials
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

The script creates a temporary table called #Numbers that contains the 
factorials of a range of numbers specified by the variable @vTotalNumbers. 
The script uses a common table expression (CTE) with recursion to calculate the factorials, 
starting with the number one and incrementing by one until the value of @vTotalNumbers is reached. 
The results of the CTE are then inserted into the #Numbers table and displayed at the end. 
The OPTION (MAXRECURSION 0) setting ensures that there is no limit to the recursion level.

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
GO

---------------------
---------------------
--Display the results
SELECT *
FROM   #Numbers;
GO

