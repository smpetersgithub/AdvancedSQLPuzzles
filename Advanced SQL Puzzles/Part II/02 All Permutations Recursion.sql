/*********************************************************************
Scott Peters
All Permutations
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL
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
DECLARE @vTotalNumbers INTEGER = 3;

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
--Populate the #Permutations table with all possible permutations
WITH cte_Permutations (Permutation, Ids, Depth)
AS
(
SELECT  CAST(Number AS VARCHAR(MAX)),
        CAST(CONCAT(Number,';') AS VARCHAR(MAX)),
        1 AS Depth
FROM    #Numbers
UNION ALL
SELECT  CONCAT(a.Permutation,',',b.Number),
        CONCAT(a.Ids,b.Number,';'),
        a.Depth + 1
FROM    cte_Permutations a,
        #Numbers b
WHERE   a.Depth < @vTotalNumbers AND
        a.Ids NOT LIKE CONCAT('%',b.Number,';%')
)
SELECT  Permutation
INTO    #Permutations
FROM    cte_Permutations;
GO
---------------------
---------------------
--Display the results
SELECT  * 
FROM    #Permutations
WHERE   LEN(Permutation) = (SELECT MAX(LEN(Permutation)) FROM #Permutations)
ORDER BY 1;
GO
