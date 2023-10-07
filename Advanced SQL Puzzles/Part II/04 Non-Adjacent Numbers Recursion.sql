/*********************************************************************
Scott Peters
Non-Adjacent Numbers
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script is used to find all permutations of a set of integers in a specific range that do not have any adjacent numbers. 
The script creates three temporary tables: #Numbers, #Permutations, and #PermutationsMaxCharIndex. It first populates the 
#Numbers table with a set of integers, and then uses a recursive CTE to generate all possible permutations of those integers 
and store them in the #Permutations table, along with a flag column indicating whether the permutation has any adjacent numbers or not.

The script then creates a new CTE called cte_AdjacentNumbers, which finds all pairs of adjacent numbers in the set. 
It then uses this CTE to populate the #PermutationsMaxCharIndex table with the maximum index of each adjacent number pair in each permutation.

Finally, the script updates the #Permutations table to set the flag column to 1 for any permutation with an adjacent number pair 
by joining it with the #PermutationsMaxCharIndex table and checking the MaxCharIndex column. The script then uses a SELECT statement 
to display the contents of the #Permutations table, ordered by the flag column.

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
--For this puzzle, I manually create the #Numbers table to provide special testing cases (rather than using recursion)
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
