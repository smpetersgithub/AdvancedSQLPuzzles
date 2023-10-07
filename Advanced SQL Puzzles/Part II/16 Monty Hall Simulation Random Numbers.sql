/*********************************************************************
Scott Peters
Monty Hall Simulation
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL

This script creates a simulation of the Monty Hall problem.
https://en.wikipedia.org/wiki/Monty_Hall_problem

The script creates a table called #WinningProbability and uses a while loop to simulate 
the game for a set number of iterations. Before the loop, the script declares and sets 
several variables.  The script uses various conditional statements to 
check if the variables are valid. It then uses various INSERT and SELECT statements
to perform the simulation and store the results in the #WinningProbability table.

**********************************************************************/

---------------
---------------
--Tables Used
DROP TABLE IF EXISTS #Doors;
DROP TABLE IF EXISTS #WinningProbability
GO

---------------
---------------
--#WinningProbability
CREATE TABLE #WinningProbability
(
IterationNumber INT IDENTITY(1,1) PRIMARY KEY,
NumberOfDoorsNeededToWin INT NOT NULL,
BeforeSwitchPrizeDoors INT NOT NULL,
AfterSwitchPrizeDoors INT NOT NULL
);
GO

---------------------
---------------------
--Declare and set variables

--Number of simulations
DECLARE @vNumberOfSimulations INTEGER = 100 --Number of simulations to run
---------------------
--Number of doors in the simulation
DECLARE @vNumberDoors INTEGER = 3;

--Number of doors that have goats
DECLARE @vNumberGoats INTEGER = 2;

--Number of doors that have prizes
DECLARE @vNumberCars INTEGER = @vNumberDoors - @vNumberGoats;

--The number of doors the host will reveal to be goats
DECLARE @vNumberHostDoors INTEGER = 1;

--The number of doors the contestant will choose
DECLARE @vNumberContestantDoors INTEGER = 1; 

--The number of doors the contestant will switch
--When the contestant switches doors, they will switch ALL currently selected doors for new doors
DECLARE @vNumberOfDoorsSwitch INTEGER = @vNumberContestantDoors;

--The number of prize doors in the final selection for the contestant to be considered a winner
DECLARE @vNumberOfPrizeDoorsSelectedNeededToWin INTEGER = 1; 
---------------------
---------------------

--Validation checks
--The number of doors needs to be greater than or equal to the sum of the 
--1) the number of doors the host will reveal
--2) the number of doors the contestant will choose 
--3) the number of doors the contestant will switch
IF  NOT(@vNumberDoors >= @vNumberHostDoors + @vNumberContestantDoors + @vNumberOfDoorsSwitch)
    BEGIN
    PRINT 'Fail 1'
    RETURN
    END

--The number of goats needs to be less than 
--1) the number of doors in the simulation
IF  NOT(@vNumberGoats <  @vNumberDoors)
    BEGIN
    PRINT 'Fail 2'
    RETURN
    END

--There has to be enough goats to ensure the host can reveal the needed number of goats
--The number of goats needs to be greater than or equal to the sum of 
--1) the number of doors the host will reveal
--2) the number of doors the contestant will choose 
IF  NOT(@vNumberGoats >=  @vNumberHostDoors + @vNumberContestantDoors)
    BEGIN
    PRINT 'Fail 3'
    RETURN
    END

--The number of prize doors needed to win must be less than or equal to 
--1) the number of doors the contestant can choose
IF  NOT(@vNumberOfPrizeDoorsSelectedNeededToWin <= @vNumberContestantDoors)
    BEGIN
    PRINT 'Fail 4'
    RETURN
    END

--To ensure the simulation can be won, the number of prize doors needed to win must be less than the difference of 
--1) the number of doors in the simulation 
--2) the number of goats in the simulation
IF  NOT(@vNumberOfPrizeDoorsSelectedNeededToWin <= @vNumberDoors - @vNumberGoats)
    BEGIN
    PRINT 'Fail 5'
    RETURN
    END

---------------
---------------
--Perform the simulation
WHILE (SELECT COUNT(*) FROM #WinningProbability) < @vNumberOfSimulations
BEGIN

    DROP TABLE IF EXISTS #Doors;

    WITH cte_Number (Number)
    AS (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Number
    WHERE  Number < @vNumberDoors
    )
SELECT NEWID() AS PrizeID,
       NEWID() AS ContestantChooseID,
       NEWID() AS HostRevealID,
       NEWID() AS ContestantSwitchID,
       'Goat' AS PrizeFlag, --I auto set all doors to goat and then update to the number of cars
       0 AS ContestantChooseFlag,
       0 AS HostRevealFlag,
       0 AS ContestantSwitchFlag,
       Number AS Door
INTO   #Doors
FROM   cte_Number
OPTION (MAXRECURSION 101);--A value of 0 means no limit to the recursion level

-----------------------------------------------------------
-----------------------------------------------------------
--Update for cars
WITH cte_Doors AS
(
SELECT ROW_NUMBER() OVER (ORDER BY PrizeID) AS RowNumber,
        *
FROM    #Doors
)
UPDATE cte_Doors
SET     PrizeFlag = 'Car'
WHERE   RowNumber <= @vNumberCars;

--Update ContestantChooseFlag
;WITH cte_Doors AS
(
SELECT ROW_NUMBER() OVER (ORDER BY ContestantChooseID) AS RowNumber,
        *
FROM    #Doors
)
UPDATE cte_Doors
SET     ContestantChooseFlag = 1
WHERE   RowNumber <= @vNumberContestantDoors;

--Update HostRevealFlag
;WItH cte_Doors AS
(
SELECT ROW_NUMBER() OVER (ORDER BY HostRevealID) AS RowNumber,
        *
FROM    #Doors
WHERE   ContestantChooseFlag = 0 and PrizeFlag = 'Goat'
)
UPDATE cte_Doors
SET     HostRevealFlag = 1
WHERE   RowNumber <= @vNumberHostDoors;

--Update ContestantSwitchFlag
WITH cte_Doors AS
(
SELECT  ROW_NUMBER() OVER (ORDER BY ContestantSwitchID) AS RowNumber,
        *
FROM    #Doors
WHERE   ContestantChooseFlag = 0 AND HostRevealFlag = 0
)
UPDATE  cte_Doors
SET     ContestantSwitchFlag = 1
WHERE   RowNumber <= @vNumberHostDoors;


--Determine winning probability
INSERT INTO #WinningProbability
(
NumberOfDoorsNeededToWin,
BeforeSwitchPrizeDoors,
AfterSwitchPrizeDoors
)
SELECT
        @vNumberOfPrizeDoorsSelectedNeededToWin,
        (SELECT COUNT(*) FROM #Doors WHERE PrizeFlag = 'Car' AND ContestantChooseFlag = 1),
        (SELECT COUNT(*) FROM #Doors WHERE PrizeFlag = 'Car' AND ContestantSwitchFlag = 1)

END;

---------------
---------------
--Print Results
SELECT  'Before Switch' as Type,
        SUM(CASE WHEN NumberOfDoorsNeededToWin <= BeforeSwitchPrizeDoors THEN 1 END) / CAST(@vNumberOfSimulations AS FLOAT)
FROM    #WinningProbability
UNION
SELECT  'After Switch' as Type,
        SUM(CASE WHEN NumberOfDoorsNeededToWin <= AfterSwitchPrizeDoors THEN 1 END) / cast(@vNumberOfSimulations AS FLOAT)
FROM    #WinningProbability;
GO
