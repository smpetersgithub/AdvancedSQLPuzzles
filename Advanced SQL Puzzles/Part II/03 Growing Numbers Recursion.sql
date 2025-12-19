/*********************************************************************
Scott Peters
Growing Numbers
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL
**********************************************************************/

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #GrowingNumbers;
GO

---------------------
---------------------
--For this puzzle, I manually create the #Numbers table to provide special testing cases (rather than using recursion)
CREATE TABLE #Numbers
(
Number INTEGER UNIQUE NOT NULL
);
GO

INSERT INTO #Numbers (Number) VALUES
(1),(2),(3),(4),(5); --Passes
--(6),(7),(8),(9),(10); --Passes
--(5),(7),(8),(9),(10); --Does Not Pass (Gap between 5 and 7)
--(7),(8),(9),(10),(11); --Does Not Pass (Two numbers greater than 10)
--(10),(11),(12); --Does Not Pass (The lowest number is not a single digit, and the set contains two numbers greater than 10)
GO

---------------------
---------------------
--Declare and set variables
DECLARE @vTotalNumbers INTEGER = (SELECT COUNT(*) FROM #Numbers);

---------------------
---------------------
--Create the #GrowingNumbers table using recursion
WITH cte_GrowingNumbers (Number, Ids, Depth)
AS
(
SELECT  CAST(Number AS VARCHAR(MAX)) AS Number,
        CAST(CONCAT(Number,'') AS VARCHAR(MAX)) AS Ids,
        1 AS Depth
FROM    #Numbers
UNION ALL
SELECT  CONCAT(a.Number,b.Number),
        CONCAT(a.Ids,b.Number),
        a.Depth + 1
FROM    cte_GrowingNumbers a,
        #Numbers b
WHERE   a.Depth < @vTotalNumbers AND
        CAST(RIGHT(a.Ids,1) AS INTEGER) + 1  = b.Number
)
SELECT  Number
INTO    #GrowingNumbers
FROM    cte_GrowingNumbers;
GO

---------------------
---------------------
--Display the results
SELECT  *
FROM    #GrowingNumbers
WHERE   LEFT(Number,1) = (SELECT MIN(Number) FROM #Numbers);
GO

