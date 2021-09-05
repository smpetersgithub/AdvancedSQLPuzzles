/****************************************************************************************
Answer to Puzzle #3
Josephus Problem
https://advancedsqlpuzzles.com

https://en.wikipedia.org/wiki/Josephus_problem

Note that I do not try to solve the Josephus problem by mathematical reasons, 
but by performing the experiment round by round.

Modify the following variables in the declarations section
to determine the soldier count and the number of soldiers to skip
	@vSoldierCount
	@vSoldiersToSkip

****************************************************************************************/

IF OBJECT_ID('tempdb.dbo.##RomanSoldiers','U') IS NOT NULL
  DROP TABLE ##RomanSoldiers;
GO

IF OBJECT_ID('tempdb.dbo.##RomanSoldiersTemp','U') IS NOT NULL
  DROP TABLE ##RomanSoldiersTemp;
GO

CREATE TABLE ##RomanSoldiers
(
--RowNumber INTEGER IDENTITY(1,1) NOT NULL,
RomanSoldierNumber INTEGER NOT NULL,
KillRound INTEGER NOT NULL DEFAULT 0,
);
GO

CREATE TABLE ##RomanSoldiersTemp
(
RowNumber INTEGER IDENTITY(1,1) NOT NULL,
RomanSoldierNumber INTEGER NOT NULL,
KillRound INTEGER NOT NULL,
);
GO
--End
-----------------------------------------------------
-----------------------------------------------------
PRINT 'Declare the variables';
DECLARE @vSoldierCount INTEGER = 10;
DECLARE @vSoldiersToSkip INTEGER = 6;
DECLARE @vSoldierToKill INTEGER;
DECLARE @vKillRound INTEGER = 1;
DECLARE @vRomanSoldierStartingPoint INTEGER;
DECLARE @vTableRecordCount INTEGER;
DECLARE @vInteger INTEGER = 1;

------------------------------------
------------------------------------
Print 'Populate the ##RomanSoldiers table'
WHILE @vInteger <= @vSoldierCount
	BEGIN
	INSERT INTO ##RomanSoldiers (RomanSoldierNumber) VALUES (@vInteger);
	SET @vInteger = @vInteger + 1
	END;
-----------------------------------

PRINT 'Enter While Statement';
WHILE (SELECT COUNT(*) FROM ##RomanSoldiers WHERE KillRound = 0) > 1

	BEGIN

	PRINT 'Truncate table ##RomanSoldiersTemp';
	TRUNCATE TABLE ##RomanSoldiersTemp;

	PRINT 'Determine @vRomanSoldierStartingPoint'
	SELECT	@vRomanSoldierStartingPoint = (CASE WHEN @vKillRound = 1 THEN 1 ELSE MAX(RomanSoldierNumber) + 1 END)
	FROM	##RomanSoldiers
	WHERE	KillRound <> 0

	PRINT CONCAT('The RomanSoldierStartingPoint is ',@vRomanSoldierStartingPoint);

	IF @vRomanSoldierStartingPoint > @vSoldierCount
		BEGIN
		SELECT	@vRomanSoldierStartingPoint = MIN(RomanSoldierNumber)
		FROM	##RomanSoldiers WHERE KillRound = 0;
		
		PRINT CONCAT('The RomanSoldierStartingPoint has been modified to ',@vRomanSoldierStartingPoint);
		END

	----------------------------------
	--Populate the ##RomanSoldiersTemp
	PRINT 'Insert into ##RomanSoldiersTemp';
	INSERT INTO ##RomanSoldiersTemp (RomanSoldierNumber, KillRound)
	SELECT	RomanSoldierNumber,
			KillRound
	FROM	##RomanSoldiers
	WHERE	KillRound = 0 AND RomanSoldierNumber >= @vRomanSoldierStartingPoint
	ORDER BY RomanSoldierNumber;
	
	SELECT @vTableRecordCount = COUNT(*) FROM ##RomanSoldiersTemp;
	PRINT CONCAT('The @vTableRecordCount is ',@vTableRecordCount);

	WHILE @vTableRecordCount < @vSoldiersToSkip + 1
		BEGIN
		PRINT 'Insert into ##RomanSoldiersTemp to increase record count';
		INSERT INTO ##RomanSoldiersTemp (RomanSoldierNumber, KillRound)
		SELECT	RomanSoldierNumber,
				KillRound
		FROM	##RomanSoldiers
		WHERE	KillRound = 0
		ORDER BY RomanSoldierNumber;
	
		SELECT @vTableRecordCount = COUNT(*) FROM ##RomanSoldiersTemp;
		PRINT CONCAT('The @vTableRecordCount has been modified to ',@vTableRecordCount);
		END
	----------------------------------
	PRINT CONCAT('The @vKillRound number is ', @vKillRound);

	SET @vSoldierToKill =
		(
		SELECT	RomanSoldierNumber
		FROM	##RomanSoldiersTemp
		WHERE RowNumber = @vSoldiersToSkip + 1
		);
	
	PRINT CONCAT('The soldier to kill is ',@vSoldierToKill);

	PRINT 'Update ##RomanSoldiers'
	UPDATE	##RomanSoldiers
	SET		KillRound = @vKillRound
	WHERE	RomanSoldierNumber = @vSoldierToKill;

	SET @vKillRound = @vKillRound + 1;
	PRINT CONCAT('Kill round has been incremented to ',@vKillRound);

	END

SELECT	a.*,
		(CASE KillRound WHEN 0 THEN CONCAT('Roman Soldier ',RomanSoldierNumber,' has been spared death!!') ELSE 'Dead!' END) AS Note
FROM	##RomanSoldiers a;
