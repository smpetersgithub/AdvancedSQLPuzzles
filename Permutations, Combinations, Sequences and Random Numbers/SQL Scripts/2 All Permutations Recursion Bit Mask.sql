/*********************************************************************
Scott Peters
All Permutations
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• Determining permutations can be done with a recursive CTE
• This solution uses an initial numbers table (#Numbers) that must be populated
• Output is saved in the temporary table #Permutations
• This script is sourced from the internet and uses bitwise operators to help speed up the calculation, with 10 digits taking roughly 15 minutes to complete

**********************************************************************/

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #Permutations;
GO

---------------------
---------------------
--Declare and set variables
DECLARE @vTotalNumbers BIGINT = 3;

---------------------
---------------------
--Create a #Numbers table using recursion
WITH cte_Factorial (Number)
AS (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Factorial
    WHERE  Number < @vTotalNumbers
)
SELECT
       Number
INTO    #Numbers
FROM   cte_Factorial
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level

---------------------
---------------------
--Generate the Permuations using recursion
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
cte_Permutations AS
(
SELECT  Number AS Permutation,
        Bitmask
FROM    cte_Bitmasks

UNION ALL

SELECT  p.Permutation + ',' + b.Number,
        p.Bitmask ^ b.Bitmask
FROM    cte_Permutations p INNER JOIN
        cte_Bitmasks b ON p.Bitmask ^ b.Bitmask > p.Bitmask
)
SELECT  ROW_NUMBER() OVER (ORDER BY GETDATE()) AS Id,
        Permutation
INTO    #Permutations
FROM    cte_Permutations
WHERE   Bitmask = POWER(2, (SELECT COUNT(*) FROM cte_Numbers)) - 1;

---------------------
---------------------
--Display the results
SELECT @vTotalNumbers AS MaxNumber,
        Permutation
FROM   #Permutations
ORDER BY 2;