/*********************************************************************
Scott Peters
Dice Roll Game
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• Because you cannot go below 0, a WHILE loop is created to account for this scenario
• You will need to make an assumption how many possible numbers you need in the #Numbers table, as this solution uses windowing

**********************************************************************/

-------------------------------
-------------------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #DiceRolls;
DROP TABLE IF EXISTS #DiceRolls_Sixes
DROP TABLE IF EXISTS #DiceRollsResults;
DROP TABLE IF EXISTS #DiceRollsHistory;
GO

-------------------------------
-------------------------------
--Create table #DiceRollResults
CREATE TABLE #DiceRollsResults
(
Iteration   INT IDENTITY(1,1) PRIMARY KEY,
StepNumber  INT
);
GO

-------------------------------
-------------------------------
--Declare and set variables
--Make an assumption on the total number of rolls needed
DECLARE @vDesiredScore INTEGER = 100;
DECLARE @vIterations INTEGER = 100;

-------------------------------
-------------------------------
--Create and populate a #Numbers table
WITH cte_Number (Number)
AS (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Number
    WHERE  Number < @vDesiredScore * 3  --Assuming you will not need x times the desired score for the total number of rolls needed to achieve the desired score
    )
SELECT Number AS StepNumber
INTO   #Numbers
FROM   cte_Number
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level

-------------------------------
-------------------------------

WHILE (SELECT COUNT(*) FROM #DiceRollsResults) <= @vIterations
    BEGIN

    DROP TABLE IF EXISTS #DiceRolls_Sixes;
    DROP TABLE IF EXISTS #DiceRolls;

    SELECT  StepNumber,
            ABS(CHECKSUM(NEWID()) % 6) + 1 AS DiceRoll,
            CAST(NULL AS INTEGER) AS DiceResult
    INTO    #DiceRolls
    FROM    #Numbers;

    --Determines dice rolls that result in a 6 and the next dice roll (LEAD function)
    SELECT  StepNumber AS StepNumber,
            DiceRoll AS DiceRoll,
            '<----->' AS Div,
            LEAD(StepNumber,1) OVER (ORDER BY StepNumber) AS StepNumber_Lead,
            LEAD(DiceRoll,1) OVER (ORDER BY StepNumber) AS DiceRoll_Lead
    INTO    #DiceRolls_Sixes
    FROM    #DiceRolls
    WHERE   DiceRoll = 6;

    --Determines the dice roll to subtract from the score
    --This uses a semi-join with an anti-join subquery
    UPDATE  #DiceRolls
    SET     DiceRoll = DiceRoll * -1
    WHERE   StepNumber IN (SELECT StepNumber_Lead FROM #DiceRolls_Sixes WHERE StepNumber_Lead NOT IN (SELECT StepNumber FROM #DiceRolls_Sixes));
    
    --Sum the DiceResults up
    WITH cte_Sum AS
    (
    SELECT  StepNumber,
            DiceRoll,
            SUM(DiceRoll) OVER (ORDER BY StepNumber) AS DiceResult
    FROM    #DiceRolls
    WHERE   DiceRoll <> 6
    )
    UPDATE  #DiceRolls
    SET     DiceResult = a.DiceResult
    FROM    cte_Sum a INNER JOIN
            #DiceRolls b ON a.StepNumber = b.StepNumber;

    -------------------------------
    -------------------------------
    --The cumulative sum of the dice cannot go below 0
    --I setup a loop to ensure that I properly handle this situation.
    WHILE 0 > (SELECT MIN(DiceResult) FROM #DiceRolls WHERE DiceResult < 0)
        BEGIN
        WITH cte_Sum AS
        (
        SELECT  StepNumber,
                DiceRoll,
                SUM(DiceRoll) OVER (ORDER BY StepNumber) AS DiceResult
        FROM    #DiceRolls
        WHERE   DiceRoll <> 6 AND StepNumber > (SELECT MIN(StepNumber) FROM #DiceRolls WHERE DiceResult < 0) 
        )
        UPDATE  #DiceRolls
        SET     DiceResult = a.DiceResult
        FROM    cte_Sum a INNER JOIN
                #DiceRolls b ON a.StepNumber = b.StepNumber;

        UPDATE  #DiceRolls
        SET     DiceResult = 0
        WHERE   StepNumber = (SELECT MIN(StepNumber) FROM #DiceRolls WHERE DiceResult < 0);

        END--End Loop <Inner>

-------------------------------
-------------------------------
    INSERT INTO #DiceRollsResults (StepNumber)
    SELECT
            MIN(StepNumber)
    FROM    #DiceRolls
    WHERE   DiceResult > 100;

    END--End Loop <Outer>
-------------------------------
-------------------------------
--Display the results
SELECT  *
FROM    #DiceRollsResults
ORDER BY 2 DESC;