/*********************************************************************
Scott Peters
100 Prisoners Problem
https://advancedsqlpuzzles.com
Last Updated: 12/20/2022

This script is written in SQL Server's T-SQL

• Run n iterations of the 100 Prisoners Problem
• https://en.wikipedia.org/wiki/100_prisoners_problem
**********************************************************************/

DROP TABLE IF EXISTS #Drawers;
DROP TABLE IF EXISTS #Drawers2;
DROP TABLE IF EXISTS #Drawers3;
DROP TABLE IF EXISTS #Results;
GO

CREATE TABLE #Results
(
Iteration     INT NOT NULL,
Drawer        INT NOT NULL,
Prisoner      INT NOT NULL,
Depth         INT NOT NULL,
MaxDepth      INT NOT NULL,
GroupNumber   INT NOT NULL);
GO

--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------

DECLARE @vIterator INTEGER = 10;--This will do n iterations of the simulation
DECLARE @vStartNumber INTEGER = 1;
DECLARE @vEndNumber INTEGER = 100;

---------------------
---------------------

WHILE @vIterator <> 0
BEGIN
PRINT CONCAT('@vIterator ',@vIterator);

    DROP TABLE IF EXISTS #Drawers;
    WITH cte_Recursion (Number)
    AS 
    (
    SELECT @vStartNumber AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Recursion
    WHERE  Number < @vEndNumber
    )
    SELECT ROW_NUMBER() OVER (ORDER BY NEWID() ASC) as Drawer,
           Number AS Prisoner
    INTO   #Drawers
    FROM   cte_Recursion
    OPTION (MAXRECURSION 100);

    ---------------------
    ---------------------
    DECLARE @vPrisoner INTEGER = 1;

    WHILE @vPrisoner IS NOT NULL
    BEGIN
    PRINT CONCAT('@vPrisoner ', @vPrisoner);

        DROP TABLE IF EXISTS #Drawers2;
        DROP TABLE IF EXISTS #Drawers3;

        SELECT  (CASE WHEN Drawer = @vPrisoner THEN NULL ELSE Drawer end) as Drawer,
                Prisoner
        INTO    #Drawers2
        FROM    #Drawers;

        WITH
        cte_Recursion AS
        (
        SELECT  Drawer,
                Prisoner,
                1 AS Depth
        FROM    #Drawers2 a
        WHERE   Drawer IS NULL
        UNION ALL
        SELECT  b.Drawer,
                b.Prisoner,
                a.Depth + 1 AS Depth
        FROM    cte_Recursion a INNER JOIN
                #Drawers2 b ON a.Prisoner = b.Drawer
        )
        SELECT  *
        INTO    #Drawers3
        FROM    cte_Recursion;

        INSERT INTO #Results
        SELECT  @vIterator
                ,(CASE WHEN Drawer IS NULL THEN @vPrisoner ELSE Drawer END) AS Drawer
                ,Prisoner
                ,Depth
                ,MAX(Depth) OVER (ORDER BY Depth DESC) AS MaxDepth
                ,@vPrisoner AS GroupNumber 
        FROM    #Drawers3

        SELECT  @vPrisoner = MIN(Prisoner) 
        FROM    #Drawers 
        WHERE   Prisoner NOT IN (SELECT Prisoner FROM #Results WHERE Iteration = @vIterator);

    END;


    SET @vIterator = @vIterator - 1;

END;


----------------------------
----------------------------
--The count of loops by loop cycle length
WITH cte_GroupCount AS
(
SELECT  DISTINCT
        Iteration,
        GroupNumber,
        MaxDepth
FROM    #Results
)
SELECT MaxDepth AS LengthLoopCycle,
       COUNT(DISTINCT Iteration) AS CountLoops
FROM   cte_GroupCount
GROUP BY MaxDepth
ORDER BY 1 DESC;

----------------------------
----------------------------
--Count of largest loop cycle for each iteration
WITH cte_MaxDepth AS
(
SELECT Iteration,
       MAX(MaxDepth) AS LargestLoop
FROM   #Results
GROUP BY Iteration
)
SELECT LargestLoop,
       SUM(LargestLoop) AS LargestLoop
FROM   cte_MaxDepth
GROUP BY LargestLoop
ORDER BY 1 DESC;

----------------------------
----------------------------
--% of iterations that have a loop less thant 50
WITH cte_Iterations_Under50 AS
(
SELECT  Iteration,
        MAX(MaxDepth) AS LargestLoop
FROM    #Results
GROUP BY Iteration
HAVING  MAX(MaxDepth) <= 50
)
SELECT CONCAT((COUNT(*)/ CAST((SELECT COUNT(DISTINCT Iteration) FROM #Results) AS NUMERIC(10,2)) * 100), '%') AS WinPercentage 
FROM   cte_Iterations_Under50;

----------------------------
----------------------------
--Number of loops per iteration
WITH cte_CountLoops AS
(
SELECT  Iteration,
        COUNT(DISTINCT GroupNumber) AS CountLoops
FROM    #Results
GROUP BY Iteration
),
cte_CountIterations AS
(
SELECT  CountLoops
       ,COUNT(Iteration) AS CountIterations
FROM   cte_CountLoops
GROUP BY CountLoops
)
SELECT  *
       ,(SELECT SUM(CountIterations) FROM cte_CountIterations)
        ,CONCAT((CountIterations/ CAST((SELECT SUM(CountIterations) FROM cte_CountIterations) AS NUMERIC(10,2)) * 100), '%') AS Percentage
FROM    cte_CountIterations
ORDER BY 1 DESC;

----------------------------
----------------------------
--The count of loops by loop cycle length
WITH cte_GroupCount AS
(
SELECT  DISTINCT
        Iteration,
        GroupNumber,
        MaxDepth
FROM    #Results
)
SELECT MaxDepth AS LengthLoopCycle,
       COUNT(DISTINCT Iteration) AS CountLoops
FROM   cte_GroupCount
GROUP BY MaxDepth
ORDER BY 1 DESC;

----------------------------
----------------------------
--Count of largest loop cycle for each iteration
WITH cte_MaxDepth AS
(
SELECT Iteration,
       MAX(MaxDepth) AS LargestLoop
FROM   #Results
GROUP BY Iteration
)
SELECT LargestLoop,
       SUM(LargestLoop) AS LargestLoop
FROM   cte_MaxDepth
GROUP BY LargestLoop
ORDER BY 1 DESC;

----------------------------
----------------------------
--% of iterations that have a loop less thant 50
WITH cte_Iterations_Under50 AS
(
SELECT  Iteration,
        MAX(MaxDepth) AS LargestLoop
FROM    #Results
GROUP BY Iteration
HAVING  MAX(MaxDepth) <= 50
)
SELECT CONCAT((COUNT(*)/ CAST((SELECT COUNT(DISTINCT Iteration) FROM #Results) AS NUMERIC(10,2)) * 100), '%') AS WinPercentage 
FROM   cte_Iterations_Under50;

----------------------------
----------------------------
--Number of loops per iteration
WITH cte_CountLoops AS
(
SELECT  Iteration,
        COUNT(DISTINCT GroupNumber) AS CountLoops
FROM    #Results
GROUP BY Iteration
),
cte_CountIterations AS
(
SELECT  CountLoops
       ,COUNT(Iteration) AS CountIterations
FROM   cte_CountLoops
GROUP BY CountLoops
)
SELECT  *
       ,(SELECT SUM(CountIterations) FROM cte_CountIterations)
        ,CONCAT((CountIterations/ CAST((SELECT SUM(CountIterations) FROM cte_CountIterations) AS NUMERIC(10,2)) * 100), '%') AS Percentage
FROM    cte_CountIterations
ORDER BY 1 DESC;
