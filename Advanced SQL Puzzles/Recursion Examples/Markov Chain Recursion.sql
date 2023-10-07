/*----------------------------------------------------
Scott Peters
Markov Chains
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL

This script uses recursion to solve a Markov Chain.
https://en.wikipedia.org/wiki/Markov_chain

In Probability Land, on a sunny day, there is an equal probability of the next day being sunny or rainy. 
On a rainy day, there is a 70% chance it will rain the next day and a 30% chance it will be sunny the next day.

On average, how many rainy days are there in Probability Land?

*/----------------------------------------------------

-------------------------------
-------------------------------

DROP TABLE IF EXISTS #Probabilities;
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #RandomNumbers;
DROP TABLE IF EXISTS #ProbabilitiesFinal;
GO

-------------------------------
-------------------------------
CREATE TABLE #Probabilities
(
CurrentState INTEGER NOT NULL,
FutureState INTEGER NOT NULL,
Probability INTEGER NOT NULL,
);
GO

--1 is Rainy, 2 is Sunny
INSERT INTO #Probabilities (CurrentState, FutureState, Probability) VALUES
(1,1,1),(1,1,2),(1,1,3),(1,1,4),(1,1,5),(1,1,6),(1,1,7),(1,2,8),(1,2,9),(1,2,10),
(2,2,1),(2,2,2),(2,2,3),(2,2,4),(2,2,5),(2,1,6),(2,1,7),(2,1,8),(2,1,9),(2,1,10);
GO

-------------------------------
-------------------------------
DECLARE @vTotalNumbers INTEGER = 10000;
-------------------------------
-------------------------------
WITH cte_Recursion (Number)
AS  (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Recursion
    WHERE  Number < @vTotalNumbers
    )
SELECT Number AS StepNumber
INTO   #Numbers
FROM   cte_Recursion
OPTION (MAXRECURSION 0);

-------------------------------
-------------------------------
SELECT  StepNumber,
        CAST(NULL AS INTEGER) AS CurrentState,
        ABS(CHECKSUM(NEWID()) % 10) + 1 AS Probability
INTO    #RandomNumbers
FROM    #Numbers;
GO

--Seed the first record in the #RandomNumbers table
--I'm arbitrarily setting this to 1 (Rain).
UPDATE  #RandomNumbers
SET     CurrentState = 1
WHERE   StepNumber = 1;
GO

-------------------------------
-------------------------------
WITH cte_Recursion AS
(
SELECT  StepNumber
        ,Probability
        ,CurrentState
FROM    #RandomNumbers a WHERE StepNumber = 1
UNION ALL
SELECT  n.StepNumber
        ,n.Probability
        ,CAST(p.FutureState AS INTEGER) AS CurrentState
FROM    cte_Recursion cte
        INNER JOIN
        #RandomNumbers n ON (cte.StepNumber + 1) = n.StepNumber
        INNER JOIN
        #Probabilities p ON cte.Probability = p.Probability AND cte.CurrentState = p.CurrentState
)
SELECT  StepNumber
        ,CurrentState
        ,(CASE CurrentState WHEN 1 THEN 'Rainy' WHEN 2 THEN 'Sunny' END) AS [Description]
        ,Probability
INTO    #ProbabilitiesFinal
FROM    cte_Recursion
ORDER BY StepNumber
OPTION (MAXRECURSION 0);
GO

-------------------------------
-------------------------------
SELECT  [Description],
        COUNT(*) AS [Count]
FROM    #ProbabilitiesFinal
GROUP BY [Description]
ORDER BY 1;
GO
