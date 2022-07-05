/*********************************************************************
Scott Peters
Non-Adjacent Numbers
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• This solution uses an initial numbers table (#Numbers) that must be populated
• The initial output is saved in the temporary table #Permutations
• The temporary table #PermutationsMaxCharIndex is populated with all adjacent numbers to check
• The #Permutations table is then updated with the logic from the #PermutationsMaxCharIndex

**********************************************************************/

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #Permutations;
DROP TABLE IF EXISTS #PermutationsMaxCharIndex;
GO

---------------------
---------------------
--For this puzzle I manually create the #Numbers table to provide special testing cases (rather than using recursion)
CREATE TABLE #Numbers
(
Number INT NOT NULL
);
GO

INSERT INTO #Numbers (Number) VALUES
--(1),(2),(3),(4);--,(4),(5),(6),(7),(8),(9),(10);  --Correct results
(5),(7),(9),(11);--,(4),(5),(6),(7),(8),(9),(10);  --Correct results
GO

---------------------
---------------------
--Create the #Permutations table using recursion
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
SELECT  Permutation,
        0 AS HasAdjacentNumbers
INTO    #Permutations
FROM    cte_Permutations
WHERE   Bitmask = POWER(2, (SELECT COUNT(*) FROM cte_Numbers)) - 1;

---------------------
---------------------
--Create the #PermutationsMaxCharIndex table
WITH cte_AdjacentNumbers AS
(
SELECT  'A' AS Id, CONCAT(a.Number,',',b.Number) AS AdjacentNumbers
FROM    #Numbers a INNER JOIN
        #Numbers b ON a.Number = (b.Number + 1)
UNION
SELECT  'B', CONCAT(b.Number,',',a.Number)  --note this is the reciprocal of the above AdjacentNumbers column
FROM    #Numbers a INNER JOIN
        #Numbers b ON a.Number = (b.Number + 1)
)
SELECT  a.Permutation,
        MAX(CHARINDEX(CONCAT(b.AdjacentNumbers,','),CONCAT(a.Permutation,','))) AS MaxCharIndex
INTO    #PermutationsMaxCharIndex
FROM    #Permutations a CROSS JOIN
        cte_AdjacentNumbers b
GROUP BY a.Permutation;

---------------------
---------------------
--Update the #Permutations table using #PermutationsMaxCharIndex
UPDATE  #Permutations
SET     HasAdjacentNumbers = 1
FROM    #Permutations a INNER JOIN
        #PermutationsMaxCharIndex b on a.Permutation = b.Permutation
WHERE   MaxCharIndex > 0;
GO

---------------------
---------------------
--View the results
SELECT *
FROM   #Permutations
ORDER BY 2;
GO
