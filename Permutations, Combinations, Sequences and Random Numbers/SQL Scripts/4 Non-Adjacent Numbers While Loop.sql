/*********************************************************************
Scott Peters
Non-Adjacent Numbers
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• This solution uses an initial numbers table (#Numbers) that must be populated
• The #Permutations table is initially seeded from the #Numbers table.  Technically, the #Numbers table could be eliminated and simply just seed the #Permutations table  
• To keep the record count manageable, a DELETE is performed on the #Permutations within the WHILE loop 
• Output is saved in the temporary table #Permutations
• Output displays only permutations with no adjacent numbers

**********************************************************************/

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #Permutations;
GO

---------------------
---------------------
--Create #Permutations table
CREATE TABLE #Permutations
(
InsertDate DATETIME DEFAULT GETDATE() NOT NULL,
Id INTEGER Identity(1,1) NOT NULL,
Permutation VARCHAR(100) NOT NULL
);
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
(1),(2),(3),(4);--,(4),(5),(6),(7),(8),(9),(10);  --Correct results
--(5),(7),(9),(11);--,(4),(5),(6),(7),(8),(9),(10);  --Correct results
GO

---------------------
---------------------
--Seed the #Permutations puzzle
INSERT INTO #Permutations (Permutation)
SELECT CAST(Number as VARCHAR(100)) FROM #Numbers;
GO

---------------------
---------------------
--Populate the #Permutations table
WHILE @@ROWCOUNT > 0
    BEGIN

    --Used to keep the table record count to a minimal
    DELETE #Permutations WHERE InsertDate < (SELECT MAX(InsertDate) FROM #Permutations);

    INSERT INTO #Permutations (Permutation)
    SELECT  CONCAT(a.Permutation, ',', b.Number)
    FROM    #Permutations a CROSS JOIN
            #Numbers b
    WHERE   
            CAST(REPLACE(RIGHT(a.Permutation,2),',','') AS INTEGER) <> b.Number + 1
            AND
            CAST(REPLACE(RIGHT(a.Permutation,2),',','') AS INTEGER) <> B.Number - 1
            --AND
            --CHARINDEX(CONCAT(',',b.Number,','),CONCAT(',',a.Permutation,',')) = 0;
            AND
            CHARINDEX(CONCAT(b.Number,','),CONCAT(a.Permutation,',')) = 0;--479306
    END

---------------------
---------------------
--Display the results
SELECT  *
FROM    #Permutations;