
/***********************************************************************
Scott Peters

www.AdvancedSQLPuzzles.com

The following code simulates the Monty Hall problem
and determines if switching doors is the correct action.
https://en.wikipedia.org/wiki/Monty_Hall_problem

This code takes it a step further and completely paramaterizes the problem.

***********************************************************************/

------------------------------------------------------------------------
------------------------------------------------------------------------
--Table creations 

IF OBJECT_ID('tempdb.dbo.##DoorPrizes') IS NOT NULL
DROP TABLE ##DoorPrizes;

IF OBJECT_ID('tempdb.dbo.##WinningProbability') IS NOT NULL
DROP TABLE ##WinningProbability;

CREATE TABLE ##DoorPrizes
(
RandomNumber UNIQUEIDENTIFIER DEFAULT NEWID(),
RowNumber INTEGER NULL,
Prize VARCHAR(100) NOT NULL,
ContestantPick BIT NULL,
ContestantPickSwitch BIT NULL,
HostPick BIT NULL
);
GO

CREATE TABLE ##WinningProbability
(
IterationNumber INT NOT NULL,
SwitchType VARCHAR(100) NOT NULL,
Prize VARCHAR(100) NOT NULL
);
GO

------------------------------------------------------------------------
------------------------------------------------------------------------

PRINT 'Input your variables here'

DECLARE @vNumberOfSimulations INTEGER = 10000 --Number of simulations to run


DECLARE @vNumberDoors INTEGER = 3;--The number of doors needs to be greater than or equal to the sum of the 1) host doors 2) contestant doors 3) door switches
DECLARE @vNumberGoats INTEGER = 2;
DECLARE @vNumberHostDoors INTEGER = 1; --The number of doors the host will reveal to be goats
DECLARE @vNumberContestantDoors INTEGER = 1; -- The number of doors the contestant will choose
DECLARE @vNumberOfDoorsSwitch INTEGER = @vNumberContestantDoors;  --When the contestant switches doors, they will switch ALL currently selected doors for new doors
DECLARE @vNumberofPrizeDoorsSelectedNeededToWin INTEGER = 1; --Determines the number of doors needed to be selected with prizes behind them for the contestant to be considered an overall winner 

PRINT 'Constants'
DECLARE @vIterator INTEGER = 1;
DECLARE @vIterationNumber INTEGER = 1;

-----------------------------------------------------------
-----------------------------------------------------------
PRINT 'Validation checks'

--The number of doors needs to be greater than or equal to the sum of the 1) host doors 2) contestant doors 3) door switches
IF	NOT(@vNumberDoors >= @vNumberHostDoors + @vNumberContestantDoors + @vNumberOfDoorsSwitch)
	BEGIN
	PRINT 'Fail 1'
	GOTO EndProcess
	END

--The number of goats needs to be greater than or equal to the sum of the 
--1) host doors 2) contestant doors AND less than the total number of doors
--There has to be enough goats in order to ensure the host can reveal the needed number of goats
--Remember, the contestant gets first choice of which door to choose, which may be a goat.
IF	NOT(@vNumberGoats >=  @vNumberHostDoors + @vNumberContestantDoors) OR NOT(@vNumberGoats <  @vNumberDoors)
	BEGIN
	PRINT 'Fail 2'
	GOTO EndProcess
	END

--The number of selected prize doors needed to win must be less than or equal to 1) the number of doors the contestant can choose
--Also, to ensure the simulation can be won, the number of prize doors needed to win must be less than the difference of 
--1) number of doors 2) number of goats
IF	NOT(@vNumberofPrizeDoorsSelectedNeededToWin <= @vNumberContestantDoors) AND 
	NOT(@vNumberofPrizeDoorsSelectedNeededToWin <= @vNumberDoors - @vNumberGoats)
	BEGIN
	PRINT 'Fail 3'
	GOTO EndProcess
	END

-----------------------------------------------------------
-----------------------------------------------------------
PRINT 'Begin Loop'
--Loop 1
WHILE @vIterationNumber <= @vNumberOfSimulations
	BEGIN
	
	PRINT @vIterationNumber

	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	PRINT 'Set the Prizes!'
	--Each door needs to be assigned either 1) Goat 2) Prize
	--The table ##DoorPrizes has a RandomNumber column that is populated with a UNIQUEIDENTIFIER that can be sorted to randomize the doors
	TRUNCATE TABLE ##DoorPrizes;

	--Loop 2
	SET @vIterator = 1;	
	WHILE @vIterator <= @vNumberGoats
	BEGIN
	
	INSERT INTO ##DoorPrizes (Prize) VALUES ('Goat');
	SET @vIterator = @vIterator + 1 
	
	END
	--End Loop 2

	--Loop 3
	SET @vIterator = 1;
	WHILE @vIterator <= @vNumberDoors - @vNumberGoats
	BEGIN
	
	INSERT INTO ##DoorPrizes (Prize) VALUES ('Prize');
	SET @vIterator = @vIterator + 1;
	END
	--End Loop 3

	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------	
	PRINT 'Create a Row Number from the Random Number'
	--This assigns the door number from the RandomNumber (UNIQUEIDENTIFIER) using the ORDER BY
	;WITH cte_RowNumber AS
		(
		SELECT	RandomNumber,
				ROW_NUMBER() OVER (ORDER BY RandomNumber) AS RowNumber
		FROM	##DoorPrizes
		)
		UPDATE ##DoorPrizes
		SET		RowNumber = b.RowNumber
		FROM	##DoorPrizes a INNER JOIN
				cte_RowNumber b on a.RandomNumber = b.RandomNumber;

	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	
	PRINT 'Contestant chooses a door'
	--Contestant chooses the number of selected doors via a random number generator
	--Note I need to change this random number generator, as its not really random 
	--Loop 4
	WHILE (SELECT COUNT(*) FROM ##DoorPrizes WHERE ContestantPick = 1) < @vNumberContestantDoors
	BEGIN
		DECLARE @ContestantRandom INT;
		DECLARE @ContestantUpper INT = @vNumberDoors; -- One more than the highest random number;
		DECLARE @ContestantLower INT = 1; -- The lowest random number
	

		/*
		Random Integer Range
		To create a random integer number between two values (range), you can use the following formula:

		SELECT FLOOR(RAND()*(b-a+1))+a;
		Where a is the smallest number and b is the largest number that you want to generate a random number for.

		SELECT FLOOR(RAND()*(25-10+1))+10;
		The formula above would generate a random integer number between 10 and 25, inclusive.
		*/
		SELECT @ContestantRandom = FLOOR(RAND()*(@ContestantUpper - @ContestantLower+1)) + @ContestantLower;
		
		PRINT '@ContestantRandom is ' + CAST(@ContestantRandom AS VARCHAR(100));

		;WITH cte_DoorPrizes AS
			(
			SELECT	ROW_NUMBER() OVER (ORDER BY RandomNumber) AS RowNumber,
					ContestantPick
			FROM	##DoorPrizes
			)
			UPDATE	cte_DoorPrizes
			SET		ContestantPick = 1
			FROM	cte_DoorPrizes
			WHERE	RowNumber = @ContestantRandom;

	END
	--End Loop 4

	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	PRINT 'Host chooses a door'
	--Host reveals the number of selected doors via a random number generator
	WHILE (SELECT COUNT(*) FROM ##DoorPrizes WHERE HostPick = 1) < @vNumberHostDoors
		
		BEGIN
		
		DECLARE @HostRandom INT;

		DECLARE @HostUpper INT = @vNumberDoors; -- One more than the highest random number;
		DECLARE @HostLower INT = 1; -- The lowest random number

		--SELECT @HostRandom = FLOOR((@HostUpper - @HostLower + 1) * RAND() + @HostLower);		
		SELECT @HostRandom = FLOOR(RAND()*(@HostUpper - @HostLower + 1)) + @HostLower;

		PRINT '@HostRandom is ' + CAST(@HostRandom AS VARCHAR(1000));

		--If the random number (door) generated is not a contestant door, then update the table as a host revealed door
		--Note the above loop accounts for the random number generator choosing a contestant door, and the below logic determines
		--if that door should be assigned to be a host revealed door. 
		IF (SELECT COUNT(*) FROM ##DoorPrizes WHERE (ContestantPick IS NULL AND HostPick IS NULL) AND Prize = 'Goat' AND RowNumber = @HostRandom) = 1
			BEGIN
			
			UPDATE	##DoorPrizes
			SET		HostPick = 1
			FROM	##DoorPrizes
			WHERE	RowNumber = @HostRandom;		
			
			END;

		END
		--End Loop 5
		
		-------------------------------------------------------------------------------
		-------------------------------------------------------------------------------
		PRINT 'Contestant Switches'
		--Note this logic is the same as above, I keep selecting doors and then making a logic
		--determination if that door is available to be set as a switched door
		WHILE (SELECT COUNT(*) FROM ##DoorPrizes WHERE ContestantPickSwitch = 1) < @vNumberContestantDoors
	
		BEGIN
		
		DECLARE @ContestantSwitchRandom INT;
		DECLARE @ContestantSwitchUpper INT = @vNumberDoors; -- One more than the highest random number;
		DECLARE @ContestantSwitchLower INT = 1; -- The lowest random number
	
		
		SELECT @ContestantSwitchRandom = FLOOR(RAND()*(@ContestantSwitchUpper - @ContestantSwitchLower + 1)) + + @ContestantSwitchLower;		
		PRINT '@ContestantSwitchRandom is ' + CAST(@ContestantSwitchRandom AS VARCHAR(1000));
		
		--If the door is available (not a currently chosen contestant door or a host revealed door), then update the door to be a switched door
		IF (SELECT COUNT(*) FROM ##DoorPrizes WHERE (ContestantPick IS NULL AND HostPick IS NULL AND ContestantPickSwitch IS NULL) AND RowNumber = @ContestantSwitchRandom) = 1
			BEGIN
			
			UPDATE	##DoorPrizes
			SET		ContestantPickSwitch = 1
			FROM	##DoorPrizes
			WHERE	RowNumber = @ContestantSwitchRandom;
			
			END
				
	END
	--End Loop 5

	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	PRINT 'Insert into ##WinningProbability'

	--Result when the contestant would not have switched doors
	--Note the difference between the fields ContestantPickSwitch and ContestantPick
	DECLARE @vNumberDoorPrizesSelectedNotSwitch INTEGER
	DECLARE @vNumberDoorPrizesSelectedSwitch INTEGER
	
		
	SELECT @vNumberDoorPrizesSelectedNotSwitch = COUNT(*) FROM ##DoorPrizes WHERE ContestantPick = 1 AND Prize = 'Prize';
	PRINT '@vNumberDoorPrizesSelectedNotSwitch'
	PRINT @vNumberDoorPrizesSelectedNotSwitch

	INSERT INTO ##WinningProbability (IterationNumber, SwitchType, Prize) 
	SELECT	@vIterationNumber, 
			'Stay', 
			(CASE WHEN @vNumberDoorPrizesSelectedNotSwitch >= @vNumberofPrizeDoorsSelectedNeededToWin THEN 'Prize' ELSE 'Goat' END)
	
	
	--Result when the contestant switches doors
	--Note the difference between the fields ContestantPickSwitch and ContestantPick
	SELECT @vNumberDoorPrizesSelectedSwitch = COUNT(*) FROM ##DoorPrizes WHERE ContestantPickSwitch = 1 AND Prize = 'Prize';
	PRINT '@vNumberDoorPrizesSelectedSwitch'
	PRINT @vNumberDoorPrizesSelectedSwitch

	INSERT INTO ##WinningProbability (IterationNumber, SwitchType, Prize) 
	SELECT	@vIterationNumber, 
			'Switch',
			(CASE WHEN @vNumberDoorPrizesSelectedSwitch >= @vNumberofPrizeDoorsSelectedNeededToWin THEN 'Prize' ELSE 'Goat' END)
		
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	PRINT 'Increment @vIterationNumber'
	SET @vIterationNumber = @vIterationNumber + 1
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	END;				
	--End Loop 1

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
SELECT * FROM ##DoorPrizes
SELECT * FROM ##WinningProbability

--Print the results
SELECT	'Stay :',
		(SELECT CAST(COUNT(*) AS FLOAT) FROM ##WinningProbability WHERE SwitchType = 'Stay' AND Prize = 'Prize') / (SELECT CAST(MAX(IterationNumber) AS FLOAT) FROM ##WinningProbability)AS [Percentage],
		'Swtich :',
		(SELECT CAST(COUNT(*) AS FLOAT) FROM ##WinningProbability WHERE SwitchType = 'Switch' AND Prize = 'Prize') / (SELECT CAST(MAX(IterationNumber) AS FLOAT) FROM ##WinningProbability) AS [Percentage]
		
EndProcess:
