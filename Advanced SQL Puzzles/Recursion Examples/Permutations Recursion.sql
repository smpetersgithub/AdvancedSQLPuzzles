/*----------------------------------------------------
Scott Peters
Permutations
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

Displays all permutations for the numbers 1 through n.

*/----------------------------------------------------

---------------------
---------------------
DROP TABLE IF EXISTS #Numbers;
GO

---------------------
---------------------
DECLARE @vTotalNumbers INTEGER = 3;

---------------------
---------------------
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
OPTION (MAXRECURSION 0);

---------------------
---------------------
WITH cte_Recursion (Permutation, Id, Depth)
AS
(
SELECT  CAST(Number AS VARCHAR(MAX)),
        CAST(CONCAT(Number,';') AS VARCHAR(MAX)),
        1 AS Depth
FROM    #Numbers
UNION ALL
SELECT  CONCAT(a.Permutation,',',b.Number),
        CONCAT(a.Id,b.Number,';'),
        a.Depth + 1
FROM    cte_Recursion a,
        #Numbers b
WHERE   a.Depth < @vTotalNumbers AND
        a.Id NOT LIKE CONCAT('%',b.Number,';%')
)
SELECT  Permutation
FROM    cte_Recursion;
GO
