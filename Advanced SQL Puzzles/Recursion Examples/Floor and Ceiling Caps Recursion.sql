/*----------------------------------------------------
Scott Peters
Floor and Ceiling Caps
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to display a running total where the sum 
cannot go higher than 10 or lower than 0.

*/----------------------------------------------------


DROP TABLE IF EXISTS #Numbers;
GO

CREATE TABLE #Numbers
(
Id         INTEGER,
StepNumber INTEGER,
[Count]    INTEGER
);
GO

INSERT INTO #Numbers VALUES
 (1,1,1) 
,(1,2,-2)
,(1,3,-1)
,(1,4,12)
,(1,5,-2)
,(2,1,7)
,(2,2,-3);
GO

WITH cte_Numbers AS
(
SELECT  *
FROM    #Numbers
),
cte_Recursion AS
(
SELECT  Id,
        [Count],
		[Count] as RunningSum,
        CASE WHEN [Count] < 0 THEN 0
             WHEN [Count] > 10 THEN 10
             ELSE [Count]
        END AS RunningSumFloorCap,
        StepNumber
FROM    #Numbers
WHERE StepNumber = 1
UNION ALL
SELECT  cte.ID,
        t.[Count],
		t.[Count] + cte.[Count],
        (CASE WHEN t.[Count] + cte.RunningSumFloorCap < 0 THEN 0
              WHEN t.[Count] + cte.RunningSumFloorCap > 10 THEN 10
              ELSE t.[Count] + cte.RunningSumFloorCap
        END) AS RunningSumFloorCap,
        t.StepNumber
FROM    cte_Recursion cte
        INNER JOIN
        cte_Numbers t ON t.StepNumber = (cte.StepNumber + 1) AND t.ID = cte.ID
)
SELECT   *
FROM     cte_Recursion
ORDER BY ID,
         StepNumber;
