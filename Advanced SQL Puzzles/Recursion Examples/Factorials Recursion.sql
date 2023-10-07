/*----------------------------------------------------
Scott Peters
Factorials
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to calculate factorials.

*/----------------------------------------------------

---------------------
---------------------
DECLARE @vTotalNumbers INTEGER = 10;

---------------------
---------------------
WITH cte_Recursion (Number, Factorial) AS
(
SELECT 1,
       1
UNION ALL
SELECT  Number + 1 AS Number,
       (Number + 1) * Factorial AS Factorial
FROM   cte_Recursion
WHERE  Number < @vTotalNumbers
)
SELECT Number,
       Factorial
FROM   cte_Recursion
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level;

