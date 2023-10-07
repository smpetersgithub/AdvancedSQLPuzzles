/*********************************************************************
Scott Peters
Dice Roll Game
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

The script simulates a game in which the player rolls a dice repeatedly and ends when the player 
reaches a certain score, which is set by the @vDesiredScore variable.

The script starts by declaring and setting some variables, including the desired 
score for the game, the number of iterations the game should run, and the assumption 
of the total number of rolls needed to achieve the desired score. The script then uses 
various temporary tables such as #Numbers, #DiceRolls, #DiceRolls_NotSixes, #DiceRolls_Modified 
and #DiceRollsResults to simulate the game. It uses CTEs, WHILE loops, and various INSERT and 
SELECT statements to perform calculations and store the results in the temporary tables. 
The script also uses a recursion method to ensure the sum of the rolls does not go below zero. 

**********************************************************************/

-------------------------------
-------------------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #DiceRolls;
DROP TABLE IF EXISTS #DiceRolls_NotSixes;
DROP TABLE IF EXISTS #DiceRolls_Modified;
DROP TABLE IF EXISTS #DiceRollsResults;
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
    WHERE  Number < 200 --@vDesiredScore * 2  --Assuming you will not need x times the desired score for the total number of rolls needed to achieve the desired score
    )
SELECT Number
INTO   #Numbers
FROM   cte_Number
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level

-------------------------------
-------------------------------
--Create and populate a #DiceRolls table
WITH cte_Random AS
(
SELECT  Number,
        ABS(CHECKSUM(NEWID()) % 6) + 1 AS DiceRoll,
        CAST(NULL AS INTEGER) AS DiceResult
FROM    #Numbers
)
SELECT  Number AS StepNumber
        ,DiceRoll
INTO    #DiceRolls
FROM    cte_Random;
GO

/***************************************
--If you need to create test data with multiple rolls of 6

UPDATE #DiceRolls
SET		DiceRoll = 6
WHERE	StepNumber in (1,3,4,6,7);
GO
	

UPDATE #DiceRolls
SET		DiceRoll = 5
WHERE	StepNumber in (2,5);
GO
***************************************/

-------------------------------
-------------------------------
--Create and populate a #DiceRolls_NotSixes table
SELECT  StepNumber
        ,LEAD(StepNumber) OVER (ORDER BY StepNumber) - 1 AS Lead_StepNumber
        ,DiceRoll
INTO    #DiceRolls_NotSixes
FROM    #DiceRolls
WHERE   DiceRoll <> 6;
GO

-------------------------------
-------------------------------
--Create and populate a #DiceRolls_Modified table
--Determines which StepNumbers need to be subtracted
WITH cte_DiceRolls AS
(
SELECT  a.Number as StepNumber,
        ISNULL(b.Lead_StepNumber,a.Number) AS Lead_StepNumber,
        c.DiceRoll AS DiceRoll_Actual,
        CASE WHEN a.Number = b.StepNumber THEN b.DiceRoll ELSE ISNULL(b.DiceRoll,0) * - 1 END AS DiceRoll_Modified
FROM    #Numbers a LEFT OUTER JOIN
        #DiceRolls_NotSixes b ON a.Number BETWEEN b.StepNumber AND b.Lead_StepNumber
        LEFT OUTER JOIN
        #DiceRolls c ON a.Number = c.StepNumber
)
SELECT  1 AS ID,
        StepNumber,
        Lead_StepNumber,
        DiceRoll_Actual,
        DiceRoll_Modified,
        SUM(DiceRoll_Modified) OVER (ORDER BY StepNumber) AS DiceRoll_Sum
INTO    #DiceRolls_Modified
FROM    cte_DiceRolls;
GO

-------------------------------
-------------------------------
--Create and populate a #DiceRollsResults table
--Uses recursion to account for the sum not allowed to go below 0
;WITH cte_DiceRolls_Modified AS
(
--Add a ranking function here if needed
--Test data has StepNumber to rank/sort the records.
SELECT  *
FROM    #DiceRolls_Modified
),
cte_Recursion AS
(
SELECT  ID,
        StepNumber,
        DiceRoll_Actual,
        DiceRoll_Modified,
        DiceRoll_Sum,
        CASE WHEN DiceRoll_Modified < 0 THEN 0
             WHEN DiceRoll_Modified > 1000 THEN 1000
             ELSE DiceRoll_Modified
        END AS DiceRoll_Sum_Modified 
FROM    #DiceRolls_Modified
WHERE StepNumber = 1
UNION ALL
SELECT  cte.ID,
        t.StepNumber,
        t.DiceRoll_Actual,
        t.DiceRoll_Modified,
        t.DiceRoll_Sum,
        (CASE WHEN t.DiceRoll_Modified + cte.DiceRoll_Sum_Modified < 0 THEN 0
              WHEN t.DiceRoll_Modified + cte.DiceRoll_Sum_Modified > 1000 THEN 1000
              ELSE t.DiceRoll_Modified + cte.DiceRoll_Sum_Modified
        END) AS RunningSum
FROM    cte_Recursion cte
        INNER JOIN
        cte_DiceRolls_Modified t ON t.StepNumber = (cte.StepNumber + 1) AND t.ID = cte.ID
)
SELECT   *
INTO     #DiceRollsResults
FROM     cte_Recursion
ORDER BY ID,
         StepNumber
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level;
GO

-------------------------------
-------------------------------
--Display the results
SELECT  * 
FROM    #DiceRollsResults
WHERE   StepNumber <= (SELECT MIN(StepNumber) FROM #DiceRollsResults WHERE DiceRoll_Sum_Modified >= 100)
ORDER BY StepNumber DESC;
GO
