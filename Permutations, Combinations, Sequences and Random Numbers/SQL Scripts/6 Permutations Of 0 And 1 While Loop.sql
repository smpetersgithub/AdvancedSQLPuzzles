/*********************************************************************
Scott Peters
Permutations of 0 and 1
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• This puzzle can easily be solved using a WHILE loop
• A #Permutations table is created and seeded with the values 0 and 1
• The variable @vPermutationLength is set to the length of the string you want
• A WHILE loop is then executed until the maximum length of the Permutation column equals the variable @vPermutationLength
• The results from the #Permutations table are then limited to the strings that meet the @vPermutationLength variable

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