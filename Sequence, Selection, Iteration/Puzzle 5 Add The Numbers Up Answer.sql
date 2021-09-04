/*********************************************************************
Answer to Puzzle #5
Add The Numbers Up
https://AdvancedSQLPuzzles.com

Runs in approximately 2 minutes.
19,683 different permutations.

I have 4 WHILE loops needed to complete the puzzle.

To sum the equation, I use dynamic SQL and a RBAR approach.  
If anyone can do this as a set operation, please contact me!

**********************************************************************/


IF OBJECT_ID('tempdb.dbo.##InitialValues','U') IS NOT NULL
  DROP TABLE ##InitialValues;
GO

IF OBJECT_ID('tempdb.dbo.##PossibleValues','U') IS NOT NULL
  DROP TABLE ##PossibleValues;
GO

IF OBJECT_ID('tempdb.dbo.##Equations','U') IS NOT NULL
  DROP TABLE ##Equations;
GO

IF OBJECT_ID('tempdb.dbo.##EquationsFinal','U') IS NOT NULL
  DROP TABLE ##EquationsFinal;
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

CREATE TABLE ##PossibleValues
(
RowNumber INTEGER IDENTITY(1,1) NOT NULL,
ElementOriginal INTEGER NOT NULL,
ElementAdded INTEGER NOT NULL,
ElementModified BIGINT NOT NULL
);
GO

CREATE TABLE ##Equations
(
RowNumber INTEGER IDENTITY(1,1) NOT NULL,
InsertIterator INTEGER,
ElementOriginal INTEGER,
ElementOriginal2 INTEGER,
ElementAdded bigint,
ElementAddedLastNumber BIGINT,
ElementModifiedVarchar VARCHAR(1000)
);
GO

CREATE TABLE ##EquationsFinal
(
RowNumber INTEGER IDENTITY(1,1) NOT NULL,
ElementModifiedVarchar VARCHAR(1000),
TotalSumInteger BIGINT,
);
GO

--Declare your variables
DECLARE @vIntegerterator1 INTEGER = 1;
DECLARE @vIntegerterator2 INTEGER;
DECLARE @vIntegerterator3 INTEGER = 2;
DECLARE @vElementValue VARCHAR(100);
DECLARE @vElementValueOriginal VARCHAR(100);
DECLARE @vElementValueAdded VARCHAR(100);
DECLARE @vElementValueModified VARCHAR(100);


--Populates the ##PossibleValues table
--WHILE loop within a WHILE loop
PRINT 'Entering While Loop 1'
WHILE @vIntegerterator1 <= (SELECT COUNT(*) FROM ##InitialValues)
	BEGIN
	SELECT @vElementValueOriginal = Element FROM ##InitialValues WHERE RowNumber = @vIntegerterator1;
	PRINT @vElementValue
	
	INSERT INTO ##PossibleValues(ElementOriginal,ElementAdded,ElementModified)
	VALUES(@vElementValueOriginal,@vElementValueOriginal,@vElementValueOriginal)
	
	SET @vElementValueModified = @vElementValueOriginal;

	SET @vIntegerterator2 = @vIntegerterator1
	PRINT 'Entering While Loop 2'
	WHILE @vIntegerterator2 < (SELECT COUNT(*) FROM ##InitialValues)
		BEGIN

		SELECT	@vElementValueAdded = Element
		FROM	##InitialValues 
		WHERE	RowNumber = @vIntegerterator2 + 1;

		SET @vElementValueModified = CONCAT(@vElementValueModified,@vElementValueAdded) 
		
		PRINT @vElementValueModified
		
		INSERT INTO ##PossibleValues(ElementOriginal,ElementAdded,ElementModified)
		VALUES (@vElementValueOriginal, @vElementValueAdded,@vElementValueModified)
		
		SET	@vIntegerterator2 = @vIntegerterator2 + 1
		END;
		
		PRINT 'End While Loop 2'
		SET	@vIntegerterator1 = @vIntegerterator1 + 1
END


--Seeds The ##Equations table
INSERT INTO ##Equations (InsertIterator,ElementOriginal,ElementOriginal2,ElementAdded,ElementAddedLastNumber,ElementModifiedVarchar)
SELECT	1,
		ElementOriginal,
		ElementOriginal,
		ElementModified,
		ElementAdded,
		CAST(ElementModified AS VARCHAR) AS ElementModifiedVarchar
FROM	##PossibleValues
WHERE	ElementOriginal = '1';


--Builds The ##Equations table Of all possible permuations
WHILE @vIntegerterator3 <= (SELECT COUNT(*) FROM ##InitialValues)
	BEGIN
	INSERT INTO ##Equations
	(InsertIterator,ElementOriginal,ElementOriginal2,ElementAdded,ElementAddedLastNumber,ElementModifiedVarchar)
	SELECT	@vIntegerterator3 AS InsertIterator,
			a.ElementOriginal AS ElementOriginal,
			b.ElementOriginal AS ElementOriginal2,
			b.ElementModified AS ElementAdded,
			b.ElementAdded AS ElementAddedLastNumber,
			CONCAT(a.ElementModifiedVarchar,'+', CAST(b.ElementModified AS VARCHAR))
	FROM	##Equations a INNER JOIN
			##PossibleValues b ON a.ElementAddedLastNumber + 1 = b.ElementOriginal
	WHERE	a.InsertIterator = @vIntegerterator3 - 1
	UNION
	SELECT	@vIntegerterator3,
			a.ElementOriginal,
			b.ElementOriginal AS ElementOriginal2,
			b.ElementModified AS ElementAdded,
			b.ElementAdded,
			CONCAT(a.ElementModifiedVarchar,'-', CAST(b.ElementModified AS VARCHAR))
	FROM	##Equations a INNER JOIN
			##PossibleValues b ON a.ElementAddedLastNumber + 1 = b.ElementOriginal
	WHERE	a.InsertIterator = @vIntegerterator3 - 1;


	SET @vIntegerterator3 = @vIntegerterator3 + 1;
	END;

--Populates The ##EquationsFinal table
INSERT INTO ##EquationsFinal (ElementModifiedVarchar)
SELECT	ElementModifiedVarchar
FROM	##Equations
WHERE	ElementModifiedVarchar LIKE CONCAT('%',(SELECT MAX(Element) FROM ##InitialValues),'')
GO

-----------------------------------------
--Add the Numbers Up
--This processes goes row by row to add the numbers up
--Updates the TotalSum field in the ##EquationsFinal table
DECLARE @vRowNumber INTEGER = 1;
DECLARE @vEquation VARCHAR(1000);
DECLARE @vSum BIGINT;
DECLARE @vSQLStatement NVARCHAR(1000);

WHILE @vRowNumber <= (SELECT COUNT(*) FROM ##EquationsFinal)
	BEGIN
	
	SELECT	@vEquation = ElementModifiedVarchar
	FROM	##EquationsFinal
	WHERE	RowNumber = @vRowNumber;
	
	PRINT CONCAT('@vEquation is ',@vEquation);

	SELECT	@vSQLStatement = CONCAT('SELECT @var = ',@vEquation);
	EXECUTE sp_executesql @vSQLStatement, N'@var BIGINT OUTPUT', @var = @vSum OUTPUT
	
	PRINT CONCAT('@vSum is ',@vSum);

	UPDATE ##EquationsFinal
	SET		TotalSumInteger = @vSum
	WHERE	RowNumber = @vRowNumber;

	SET @vRowNumber = @vRowNumber + 1
	PRINT CONCAT('@vRowNumber is ',@vRowNumber);
	END


SELECT * FROM ##EquationsFinal;