/*--------------------------------------------------------------------------------------------------------
Scott Peters
Permutations 1 Through 10 (Bit Mask)
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script generates permutations of a set of numbers using a bitmask. The script starts by 
declaring a variable for the length of numbers that will be used in the permutations and then 
creates a table called #Numbers that is populated with a set of numbers. The script then uses 
common table expressions (CTEs) and bitwise operators to generate permutations of the numbers 
in the #Numbers table and stores them in a table called #Permutations. The script also creates 
another table called #PermutationsPosition that determines the position of commas in the permutations. 
Finally, the script selects distinct permutations of a specific length, specified by the @vLengthNumbers 
variable, and displays the results.

*/--------------------------------------------------------------------------------------------------------

-------------------------------
-------------------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #Permutations;
DROP TABLE IF EXISTS #PermutationsPosition;
GO

-------------------------------
-------------------------------
--Declare and set the variables
DECLARE @vLengthNumbers INTEGER = 3;

-------------------------------
-------------------------------
--Create #Numbers table and populate
SELECT  Number
INTO    #Numbers
FROM
--(VALUES (1), (2), (3)) n(Number);
--(VALUES (10), (21), (32)) n(Number);
(VALUES (1), (2), (3), (4)) n(Number);
--(VALUES (1), (2), (3), (4), (5)) n(Number);
--(VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)) n(Number);

-------------------------------
-------------------------------
--Create #Permutations table and populate
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
WHERE   Bitmask = POWER(2, (SELECT COUNT(*) FROM cte_Numbers)) - 1

-------------------------------
-------------------------------
--Creates table #PermutationsPosition
--Determines the position of commas
;WITH cte_CAST AS
(
SELECT Id, CAST(Permutation AS VARCHAR(20)) AS Permutation FROM #Permutations
),
cte_Anchor AS
(
SELECT Id,
       Permutation,
       1 AS Starts,
       CHARINDEX(',', Permutation) AS Position
FROM   cte_CAST
UNION ALL
SELECT Id,
       Permutation,
       Position + 1,
       CHARINDEX(',', Permutation, Position + 1)
FROM   cte_Anchor
WHERE  Position > 0
)
SELECT *,
       SUBSTRING(Permutation, Starts, CASE WHEN Position > 0 THEN Position - Starts ELSE LEN(Permutation) END) Token,
       ROW_NUMBER() OVER (PARTITION BY Id ORDER BY Starts) AS RowNumber
INTO   #PermutationsPosition
FROM   cte_Anchor
ORDER BY Permutation, Starts;

-------------------------------
-------------------------------
--Display the results
SELECT DISTINCT
       LEFT(Permutation,Starts) AS Permutation
FROM   #PermutationsPosition
WHERE  RowNumber = @vLengthNumbers;
GO
