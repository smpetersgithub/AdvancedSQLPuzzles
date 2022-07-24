/*----------------------------------------------------
Scott Peters
https://AdvancedSQLPuzzles.com

This recursive statement grows numbers.
1, 12, 123, 1234, 12345....

*/----------------------------------------------------

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #Permutations;
GO

---------------------
---------------------
--For this puzzle I manually create the #Numbers table to provide special testing cases (rather than using recursion)
CREATE TABLE #Numbers
(
Number INTEGER NOT NULL
);
GO

INSERT INTO #Numbers (Number) VALUES
(1),(2),(3),(4),(5); --Passes
--(6),(7),(8),(9),(10); --Passes
--(5),(7),(8),(9),(10); --Does Not Pass (Gap between 5 and 7)
--(7),(8),(9),(10),(11); --Does Not Pass (Two numbers greater than 10)
--(10),(11),(12); --Does Not Pass (Lowest number is not a single digit and the set contains two numbers greater than 10)
GO

---------------------
---------------------
--Declare and set variables
DECLARE @vTotalNumbers INTEGER = (SELECT COUNT(*) FROM #Numbers);

---------------------
---------------------
--Create the #Permutations table using recursion
WITH cte_Recursion (Permutation, Id, Depth)
AS
(
SELECT  CAST(Number AS VARCHAR(MAX)) AS Permutation,
        CAST(CONCAT(Number,'') AS VARCHAR(MAX)) AS Id,
        1 AS Depth
FROM    #Numbers
UNION ALL
SELECT  CONCAT(a.Permutation,b.Number),
        CONCAT(a.Id,b.Number),
        a.Depth + 1
FROM    cte_Recursion a,
        #Numbers b
WHERE   a.Depth < @vTotalNumbers AND
        CAST(RIGHT(a.Id,1) AS INTEGER) + 1  = b.Number
)
SELECT  Permutation
INTO    #Permutations
FROM    cte_Recursion;

---------------------
---------------------
--Display the results
SELECT  *
FROM    #Permutations
WHERE   LEFT(Permutation,1) = (SELECT MIN(Number) FROM #Numbers);