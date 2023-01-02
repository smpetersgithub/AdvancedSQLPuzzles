/*********************************************************************
Scott Peters
All Permutations
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• Determining permutations can be performed with a recursive CTE; this solution uses a WHILE loop
• This solution uses an initial numbers table (#Numbers) that must be populated
• The #Permutations table is initially seeded from the #Numbers table
• The #Numbers table could be eliminated and simply just seed the #Permutations table  
• To keep the record count manageable, a DELETE is performed on the #Permutations within the WHILE loop
• Output is saved in the temporary table #Permutations

**********************************************************************/

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #Permutations;
GO

---------------------
---------------------
--Set the number of permutations to create
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
--Create the #Permuations table and provide initial seed
SELECT  CAST(Number AS VARCHAR(100)) AS Permutation,
        GETDATE() AS InsertDate
INTO    #Permutations
FROM #Numbers;

---------------------
---------------------
--Populate the #Permutations table
WHILE @@ROWCOUNT > 0
    BEGIN

    --Used to keep the table record count to a minimal
    DELETE #Permutations WHERE InsertDate < (SELECT MAX(InsertDate) FROM #Permutations);

    INSERT INTO #Permutations (Permutation, InsertDate)
    SELECT  CONCAT(a.Permutation, ',', b.Number),
            GETDATE()
    FROM    #Permutations a CROSS JOIN
            #Numbers b
    WHERE   CAST(REPLACE(RIGHT(a.Permutation,2),',','') AS INTEGER) <> b.Number
            AND
            CHARINDEX(CONCAT(b.Number,','),CONCAT(a.Permutation,',')) = 0;
    END;

---------------------
---------------------
--Display the results
SELECT  @vTotalNumbers AS MaxNumber,
        Permutation
FROM    #Permutations
ORDER BY Permutation;
