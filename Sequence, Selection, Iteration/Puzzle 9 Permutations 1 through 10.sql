/*********************************************************************
Answer to Puzzle #9
Permutations 1 Through 10
https://AdvancedSQLPuzzles.com

This may be able to be solved via a single declarative statement using recursion.
However, it is very simple to solve with a single loop.

**********************************************************************/

IF OBJECT_ID('tempdb.dbo.##Values','U') IS NOT NULL
  DROP TABLE ##Values;
GO

IF OBJECT_ID('tempdb.dbo.##Permutations','U') IS NOT NULL
  DROP TABLE ##Permutations;
GO

CREATE TABLE ##Values
(
RowNumber INTEGER IDENTITY(1,1) NOT NULL,
MyValue VARCHAR(2)
);

CREATE TABLE ##Permutations
(
Permutation VARCHAR(10),
NumericDiffernece INTEGER
);
GO

INSERT INTO ##Values (MyValue)
VALUES ('1'),('2'),('3'),('4'),('5'),('6'),('7'),('8'),('9'),('10');
GO

DECLARE @vRowNumber INTEGER = 1;

WHILE @vRowNumber <= (SELECT MAX(RowNumber) FROM ##Values)
	BEGIN
	WITH cte_RowNumber AS
	(
	SELECT *
	FROM	##Values
	WHERE	RowNumber = @vRowNumber
	)
	INSERT INTO ##Permutations (Permutation, NumericDiffernece)
	SELECT	CONCAT(a.MyValue,', ',b.MyValue),
			ABS(CAST(a.MyValue AS INTEGER) - CAST(b.MyValue AS INTEGER))
	FROM	cte_RowNumber a CROSS JOIN
			##VALUES b
	WHERE	a.MyValue <> b.MyValue;
	
	SET @vRowNumber = @vRowNumber + 1;
	
	END

SELECT * FROM ##Permutations;