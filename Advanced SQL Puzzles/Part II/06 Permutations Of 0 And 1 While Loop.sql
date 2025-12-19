/*********************************************************************
Scott Peters
Permutations of 0 and 1
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL
**********************************************************************/

-------------------------------
-------------------------------
--Tables used
DROP TABLE IF EXISTS #Permutations;
GO

-------------------------------
-------------------------------
--Create and Populate the #Permutations table
CREATE TABLE #Permutations
(
Permutation VARCHAR(MAX)
);
GO

INSERT INTO #Permutations (Permutation) VALUES ('0'),('1');
GO
-------------------------------
-------------------------------
--Declare and set variables
--Modify this variable with the length of the string you want.
DECLARE @vPermutationLength INTEGER = 3

-------------------------------
-------------------------------
--Populate the #Permutations using a WHILE loop
WHILE (SELECT MAX(LEN(Permutation)) FROM #Permutations) <= @vPermutationLength
        BEGIN

        INSERT INTO #Permutations (Permutation)
        SELECT CONCAT(a.Permutation,b.Permutation)
        FROM    #Permutations a CROSS JOIN
                #Permutations b;

        END;

-------------------------------
-------------------------------
--Display the Results
SELECT  DISTINCT LEFT(Permutation, @vPermutationLength) AS Permutation
FROM    #Permutations
WHERE   LEN(Permutation) = @vPermutationLength
ORDER BY 1;
