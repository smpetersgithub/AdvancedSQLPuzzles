/*********************************************************************
Answer to Puzzle #7
Pascal’s Triangle
https://AdvancedSQLPuzzles.com

Developer Notes:

Note the equation uses 0 based indexing.
The first row is row 0 and not row 1.
The first position is position 0 and not position 1.

Also, the factorial of 0! is 1.

Here is the first eight rows.  Remember the equation uses zero based indexing.
1		1 |
2		1 | 1 |
3		1 | 2 |  1 |
4		1 | 3 |  3 |  1 |
5		1 | 4 |  6 |  4 |  1 |
6		1 | 5 | 10 | 10 |  5 |  1 |
7		1 | 6 | 15 | 20 | 15 |  6 | 1 |
8		1 | 7 | 21 | 35 | 35 | 21 | 7 | 1 |

Pos.	1 | 2 |  3 |  4 |  5 |  6 | 7 | 8 |

Modify the following variables to determine the row and position
@vRowInput
@vPositionInput

**********************************************************************/

--Set your row and position.
--This does not use 0 based indexing.  I account for this below.
DECLARE @vRowInput INTEGER = 7;
DECLARE @vPositionInput INTEGER = 4;

PRINT 'Declare Variables'
------------
DECLARE @vRowNumber INTEGER = @vRowInput - 1;
DECLARE @vPositionNumber INTEGER = @vPositionInput - 1;
DECLARE @vPositionValue INTEGER;
------------
--Row
DECLARE @vRowFactorial INTEGER;
DECLARE @vRowFactorialIterator INTEGER = 1;
------------
--Position
DECLARE @vPositionFactorial INTEGER;
DECLARE @vPositionFactorialIterator INTEGER = 1;
------------
--Row Minus Position
DECLARE @vRowMinusPositionFactorial INTEGER;
DECLARE @vRowMinusPositionFactorialIterator INTEGER = 1;
DECLARE @vRowMinusPositionNumber INTEGER;

PRINT '--------------------'
PRINT CONCAT('The @vRowNumber is ',@vRowNumber);
PRINT CONCAT('The @vPositionNumber is ',@vPositionNumber);
PRINT '--------------------'
------------

IF @vRowNumber = 0 OR @vPositionNumber = 0
	BEGIN
	PRINT 'Setting @vPositionValue = 1';
	SET @vPositionValue = 1;
	RETURN;
	END;


------------
PRINT 'Determine Row Factorial'
SET @vRowFactorial = @vRowNumber;

WHILE @vRowFactorialIterator < @vRowNumber
	BEGIN

	SET @vRowFactorial = @vRowFactorial * @vRowFactorialIterator;
	SET @vRowFactorialIterator = @vRowFactorialIterator + 1
	END
PRINT CONCAT('@vRowFactorial is ',@vRowFactorial);
PRINT '-----------------------'


------------
PRINT 'Determine Position Factorial'
SET @vPositionFactorial = @vPositionNumber;

WHILE @vPositionFactorialIterator < @vPositionNumber
	BEGIN
	--PRINT '@vPositionFactorial is ' + CAST(@vPositionFactorial AS VARCHAR);
	--PRINT '@vPositionFactorialIterator is ' + CAST(@vPositionFactorialIterator AS VARCHAR);
	SET @vPositionFactorial = @vPositionFactorial * @vPositionFactorialIterator;
	SET @vPositionFactorialIterator = @vPositionFactorialIterator + 1
	END

PRINT CONCAT('@vPositionFactorial is ',@vPositionFactorial);
PRINT '-----------------------'
 
------------
PRINT 'Determine Row Minus Position Factorial'
SET @vRowMinusPositionFactorial = (CASE WHEN @vRowNumber - @vPositionNumber = 0 THEN 1 ELSE @vRowNumber - @vPositionNumber END);
SET @vRowMinusPositionNumber = @vRowMinusPositionFactorial;


PRINT CONCAT('@vRowMinusPositionFactorial is ',@vRowMinusPositionFactorial)
WHILE @vRowMinusPositionFactorialIterator < @vRowMinusPositionNumber
		BEGIN
		SET @vRowMinusPositionFactorial = @vRowMinusPositionFactorial * @vRowMinusPositionFactorialIterator;
		SET @vRowMinusPositionFactorialIterator = @vRowMinusPositionFactorialIterator + 1
		PRINT @vRowMinusPositionFactorial;
		END

PRINT '--------------------' 
PRINT @vPositionValue;
PRINT	CONCAT('The value for Row ',@vRowInput,' and Position ',@vPositionInput,' is ',(@vRowFactorial / (@vPositionFactorial * @vRowMinusPositionFactorial)));

