/*----------------------------------------------------
Scott Peters
Fibonacci Sequence
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to calculate Fibonacci numbers.

*/----------------------------------------------------

WITH cte_Recursion (PrevNumber, Number) AS
(
SELECT  0, 1
UNION ALL
SELECT  Number, PrevNumber + Number
FROM    cte_Recursion
WHERE   Number < 1000000000
)
SELECT PrevNumber AS Fibonacci
FROM   cte_Recursion
OPTION (MAXRECURSION 0);
GO
