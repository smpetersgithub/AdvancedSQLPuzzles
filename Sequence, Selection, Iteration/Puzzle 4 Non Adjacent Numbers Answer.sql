/*********************************************************************
Answer to Puzzle #4
Non-Adjacent Numbers
https://advancedsqlpuzzles.com

Developer Notes:

The number of possible permutations for the numbers 1 through 10 with
no adjacent numbers is 424,807 out of a total possible 3,628,800 permutations.
This equates to 12% of the permutations do not have adjacent numbers.

This code takes approx. 3 minutes to run (on my fancy laptop of course).

**********************************************************************/
IF OBJECT_ID('tempdb.dbo.##InitialValues','U') IS NOT NULL
  DROP TABLE ##InitialValues;
GO

IF OBJECT_ID('tempdb.dbo.##Permutations','U') IS NOT NULL
  DROP TABLE ##Permutations;
GO

CREATE TABLE ##InitialValues
(
RowNumber INTEGER IDENTITY(1,1),
Element VARCHAR(100)
);
GO

INSERT INTO ##InitialValues (Element) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);
GO

CREATE TABLE ##Permutations
(
RowNumber INTEGER IDENTITY(1,1) NOT NULL,
Permutation VARCHAR(1000) NOT NULL,
AdjacentNumbers BIT NULL
);
GO

DECLARE @vTotalElements INTEGER = (SELECT COUNT(*) FROM ##InitialValues);
DECLARE @vIntegerterator INTEGER = 1;
DECLARE @vElementValue VARCHAR(100);

--Populate the ##Permutations table with all possible permutations
WITH cte_Permutations (Permutation, Ids, Depth)
AS
(
SELECT	CAST(Element AS VARCHAR(MAX)),
		CAST(RowNumber AS VARCHAR(MAX)) + ';',
		1 AS Depth
FROM	##InitialValues
UNION ALL
SELECT	a.Permutation + ',' + b.Element,
		a.Ids + CAST(b.RowNumber AS VARCHAR) + ';',
		a.Depth + 1
FROM	cte_Permutations a,
		##InitialValues b
WHERE	a.Depth < @vTotalElements AND
		a.Ids NOT LIKE '%' + CAST(b.RowNumber AS VARCHAR) + ';%'
)
INSERT INTO ##Permutations (Permutation)
SELECT	Permutation
FROM	cte_Permutations;

------------------------------------------------------------
------------------------------------------------------------
--Determines permutations with adjacent numbers
WHILE @vIntegerterator <= @vTotalElements
	BEGIN

	SELECT	@vElementValue = Element 
	FROM	##InitialValues 
	WHERE	RowNumber = @vIntegerterator;

	PRINT CONCAT('@vElementValue is ',@vElementValue);

	UPDATE	##Permutations
	SET		AdjacentNumbers = 1
	WHERE	Permutation LIKE CONCAT('%',@vElementValue,',',(@vElementValue + 1),'%')
			OR
			Permutation LIKE CONCAT('%',@vElementValue,',',(@vElementValue - 1),'%');

	SET @vIntegerterator = @vIntegerterator + 1;

	END

--View the results
SELECT * FROM ##Permutations WHERE AdjacentNumbers IS NULL;

