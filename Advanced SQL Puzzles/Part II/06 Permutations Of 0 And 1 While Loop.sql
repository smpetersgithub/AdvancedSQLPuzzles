/*********************************************************************
Scott Peters
Permutations of 0 and 1
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script creates a temporary table #Permutations and inserts 0 and 1 as initial values. 
It then declares a variable @vPermutationLength, which is used to set the length of the permutation string.
Then, using a while loop, it repeatedly concatenates the current permutations in the table 
to create new permutations until the maximum length of the permutation column in the table 
equals the value of @vPermutationLength. Finally, it selects and displays distinct permutations 
of the desired length from the #Permutations table, ordered by the permutation values.

Given the input of 0 and 1 and a @vPermutationLength of 3, it will produce the following output:
000, 001, 010, 011, 100, 101, 110, 111

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
