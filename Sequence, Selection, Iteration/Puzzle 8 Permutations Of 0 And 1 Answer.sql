/*********************************************************************
Answer to Puzzle #8
Permutations of 0 and 1
https://advancedsqlpuzzles.com

Developer Notes:

This may be able to be solved via a single declarative statement using recursion.
However, it is very simple to solve with a single loop.

**********************************************************************/

IF OBJECT_ID('tempdb.dbo.##Permutations','U') IS NOT NULL
  DROP TABLE ##Permutations;
GO

CREATE TABLE ##Permutations
(
Permutation VARCHAR(MAX)
);
GO

INSERT INTO ##Permutations (Permutation) VALUES ('0'),('1');
GO

--Modify this variable with the length of the string you want.
DECLARE @vPermutationLength INTEGER = 6

WHILE (SELECT MAX(LEN(Permutation)) FROM ##Permutations) <= @vPermutationLength
		BEGIN

		INSERT INTO ##Permutations (Permutation)
		SELECT CONCAT(a.Permutation,b.Permutation)
		FROM	##Permutations a CROSS JOIN
				##Permutations b;

		END;

SELECT	DISTINCT LEFT(Permutation, @vPermutationLength) AS ZeroAndOne
FROM	##Permutations
WHERE	LEN(Permutation) = @vPermutationLength;

