/*********************************************************************
Scott Peters
Non-Adjacent Numbers
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script is used to find all permutations of a set of integers that are not 
adjacent to each other. The script creates a temporary table called #Permutations, 
which is initially seeded with the integers from a table called #Numbers. The script 
then enters a WHILE loop that runs as long as there are still permutations to be generated. 
In each iteration of the loop, it selects all permutations from the #Permutations table, 
concatenates them with the current value of a number from the #Numbers table, and insert the 
resulting value into the #Permutations table. It also checks to ensure that the new permutation 
doesn't have any adjacent numbers. The script uses a SELECT statement to display the contents of 
the #Permutations table after the loop has completed.

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
--For this puzzle, I manually create the #Numbers table to provide special testing cases (rather than using recursion)
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
GO
---------------------
---------------------
--Display the results
SELECT  *
FROM    #Permutations;
GO
