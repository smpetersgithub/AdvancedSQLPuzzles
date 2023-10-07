/*********************************************************************
Scott Peters
All Permutations
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL

The script generates all the permutations of numbers from 1 to @vTotalNumbers (inclusive). 
It first creates a table called #Numbers, which contains a column of numbers from 1 to @vTotalNumbers. 
Then, it uses a recursive CTE to generate all the permutations by iterating through the #Numbers 
table and concatenating the numbers to form unique permutations. The output is saved in the temporary 
table #Permutations, and the results can be viewed by running a SELECT statement on it. The script 
uses bitwise operators to speed up the calculation, but it can take a significant amount of time 
to generate all permutations, especially with larger values of @vTotalNumbers.

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
WITH cte_Numbers (Number)
AS (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Numbers
    WHERE  Number < @vTotalNumbers
)
SELECT
       Number
INTO    #Numbers
FROM   cte_Numbers
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level

---------------------
---------------------
--Generate the Permutations using recursion
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
GO
