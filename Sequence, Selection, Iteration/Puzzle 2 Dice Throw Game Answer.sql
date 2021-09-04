/*********************************************************************
Answer to Puzzle #2
Dice Throw Game
https://AdvancedSQLPuzzles.com

Modify the following variable to change the number of trials
@vNumberOfTrials

**********************************************************************/

IF OBJECT_ID('tempdb.dbo.##Results','U') IS NOT NULL
  DROP TABLE ##Results;
GO

CREATE TABLE ##Results
(
IterationNumber INTEGER IDENTITY(1,1),
DiceThrowCount	INTEGER
);

--Modify the number of trials
DECLARE @vNumberOfTrials INTEGER = 1000

DECLARE @vNumberOfSteps INTEGER = 100;
DECLARE @vStepCount INTEGER;
DECLARE @vDiceThrow SMALLINT;
DECLARE @vDiceResult SMALLINT;
DECLARE @vDiceThrowCount SMALLINT;
DECLARE @vIntegerterationNumber INTEGER = 1

WHILE @vIntegerterationNumber <= @vNumberOfTrials
BEGIN

	SET @vStepCount = 0;
	SET @vDiceThrowCount = 1;
	SET @vIntegerterationNumber = @vIntegerterationNumber + 1;

	WHILE @vStepCount < @vNumberOfSteps
		BEGIN
	
		SET @vDiceThrowCount =  @vDiceThrowCount + 1
	
		SELECT @vDiceResult = ABS(CHECKSUM(NEWID()) % 6) + 1;

		IF @vDiceResult BETWEEN 1 AND 5
			BEGIN
			SET @vStepCount = @vStepCount + @vDiceResult;
			END

		IF @vDiceResult = 6
			BEGIN
			SELECT @vDiceResult = ABS(CHECKSUM(NEWID()) % 6) + 1;
			SET @vStepCount =(CASE 	WHEN @vStepCount - @vDiceResult < 0 THEN 0 ELSE @vStepCount - @vDiceResult END);
			END
	
	END

INSERT INTO ##Results (DiceThrowCount)
SELECT	@vDiceThrowCount;

END;


SELECT	MAX(IterationNumber) as MaxIterationNumber,
		AVG(DiceThrowCount) AS AverageThrowsNeeded,
		MIN(DiceThrowCount) AS MinThrowsNeeded,
		MAX(DiceThrowCount) AS MaxThrowsNeeded,
		(
		SELECT	TOP 1 DiceThrowCount
		FROM	##Results
		GROUP BY DiceThrowCount
		ORDER BY COUNT(*) DESC) AS Most_Occuring,
		(
		SELECT	TOP 1 COUNT(*)
		FROM	##Results
		GROUP BY DiceThrowCount
		ORDER BY COUNT(*) DESC
		) AS Most_Occuring_Count
FROM	##Results;

SELECT	*
FROM	##Results;
GO