/*********************************************************************
Scott Peters
Monty Hall Simulation
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• This script creates a simulation of the Monty Hall Problem
• It uses NEWID() to randomize the doors
• Determining valid inputs into the variables is the most difficult part of this puzzle

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

---------------
---------------
--Declare and set variables
DECLARE @vNumberOfSimulations INTEGER = 100 --Number of simulations to run
DECLARE @vNumberDoors INTEGER = 10;--The number of doors needs to be greater than or equal to the sum of the 1) host doors 2) contestant doors 3) door switches
DECLARE @vNumberGoats INTEGER = 8;
DECLARE @vNumberCars INTEGER = @vNumberDoors - @vNumberGoats;
DECLARE @vNumberHostDoors INTEGER = 2; --The number of doors the host will reveal to be goats
DECLARE @vNumberContestantDoors INTEGER = 2; -- The number of doors the contestant will choose
DECLARE @vNumberOfDoorsSwitch INTEGER = @vNumberContestantDoors;  --When the contestant switches doors, they will switch ALL currently selected doors for new doors

DECLARE @vNumberofPrizeDoorsSelectedNeededToWin INTEGER = 1; --Determines the number of doors needed to be selected with prizes behind them for the contestant to be considered an overall winner

-----------------------------------------------------------
-----------------------------------------------------------
--Validation checks
--The number of doors needs to be greater than or equal to the sum of the 
--1) host doors 2) contestant doors 3) door switches
IF  NOT(@vNumberDoors >= @vNumberHostDoors + @vNumberContestantDoors + @vNumberOfDoorsSwitch)
    BEGIN
    PRINT 'Fail 1'
    RETURN
    END

--The number of goats needs to be greater than or equal to the sum of the 
--1) host doors 2) contestant doors AND less than the total number of doors
--There has to be enough goats in order to ensure the host can reveal the needed number of goats
IF  NOT(@vNumberGoats >=  @vNumberHostDoors + @vNumberContestantDoors) OR NOT(@vNumberGoats <  @vNumberDoors)
    BEGIN
    PRINT 'Fail 2'
    RETURN
    END

--The number of selected prize doors needed to win must be less than or equal to 
--1) the number of doors the contestant can choose
--Also, to ensure the simulation can be won, the number of prize doors needed to win must be less 
--than the difference of 1) number of doors 2) number of goats
IF  NOT(@vNumberofPrizeDoorsSelectedNeededToWin <= @vNumberContestantDoors) AND 
    NOT(@vNumberofPrizeDoorsSelectedNeededToWin <= @vNumberDoors - @vNumberGoats)
    BEGIN
    PRINT 'Fail 3'
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
SELECT  ROW_NUMBER() OVER (ORDER BY ContestantSwitchID) AS rownumber,
        *
FROM    #Doors
WHERE   ContestantChooseFlag = 0 AND HostRevealFlag = 0
)
UPDATE cte_Doors
SET     ContestantSwitchFlag = 1
WHERE   RowNumber <= @vNumberHostDoors;


--Determine WinningProbability
INSERT INTO #WinningProbability
(
NumberOfDoorsNeededToWin,
BeforeSwitchPrizeDoors,
AfterSwitchPrizeDoors
)
SELECT
        @vNumberofPrizeDoorsSelectedNeededToWin,
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

