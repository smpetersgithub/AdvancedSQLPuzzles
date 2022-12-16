
----------------------------
----------------------------
--The count of loops by loop cycle length
WITH cte_GroupCount AS
(
SELECT  DISTINCT
        Iteration,
        GroupNumber,
        MaxDepth
FROM    ##Results
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
FROM   ##Results
GROUP BY Iteration
)
SELECT MaxDepth,
       SUM(LargestLoop) AS LargestLoop
FROM   cte_MaxDepth
GROUP BY MaxDepth
ORDER BY 1 DESC;

----------------------------
----------------------------
--% of iterations that have a loop less thant 50
WITH cte_Iterations_Under50 AS
(
SELECT  Iteration,
        MAX(MaxDepth) AS LargestLoop
FROM    ##Results
GROUP BY Iteration
HAVING  MAX(MaxDepth) <= 50
)
SELECT CONCAT((COUNT(*)/ CAST((SELECT COUNT(DISTINCT Iteration) FROM ##Results) AS NUMERIC(10,2)) * 100), '%') AS WinPercentage 
FROM   cte_Iterations_Under50;

----------------------------
----------------------------
--Number of loops per iteration
WITH cte_CountLoops AS
(
SELECT  Iteration,
        COUNT(DISTINCT GroupNumber) AS CountLoops
FROM    ##Results
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
