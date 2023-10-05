/*----------------------------------------------------
Scott Peters
Permutations (using Bit Mask)
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to display all permutations for the numbers 1 through n.

*/----------------------------------------------------

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
GO

---------------------
---------------------
--Declare and set variables
DECLARE @vTotalNumbers BIGINT = 3;

---------------------
---------------------
--Create a #Numbers table using recursion
WITH cte_Recursion (Number) AS 
(
SELECT 1 AS Number
UNION ALL
SELECT  Number + 1
FROM   cte_Recursion
WHERE  Number < @vTotalNumbers
)
SELECT
       Number
INTO   #Numbers
FROM   cte_Recursion
OPTION (MAXRECURSION 0);

---------------------
---------------------
WITH cte_Numbers AS
(
SELECT  CAST(Number AS VARCHAR(MAX)) AS Number
FROM    #Numbers
),
cte_Bitmasks AS
(
SELECT
        Number,
        CAST(POWER(2, ROW_Number() OVER (ORDER BY Number) - 1) AS INT) AS Bitmask
FROM    cte_Numbers
),
cte_Recursion AS
(
SELECT  Number AS Permutation,
        Bitmask
FROM    cte_Bitmasks
UNION ALL
SELECT  p.Permutation + ',' + b.Number,
        p.Bitmask ^ b.Bitmask
FROM    cte_Recursion p INNER JOIN
        cte_Bitmasks b ON p.Bitmask ^ b.Bitmask > p.Bitmask
)
SELECT  ROW_NUMBER() OVER (ORDER BY GETDATE()) AS Id,
        Permutation
FROM    cte_Recursion
WHERE   Bitmask = POWER(2, (SELECT COUNT(*) FROM cte_Numbers)) - 1;
GO
