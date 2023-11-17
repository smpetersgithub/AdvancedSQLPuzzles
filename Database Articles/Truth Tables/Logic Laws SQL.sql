/*----------------------------------------------------
Scott Peters
Truth Tables
https://advancedsqlpuzzles.com
Last Updated 11/17/2023
Microsoft SQL Server T-SQL

*/----------------------------------------------------
DROP TABLE IF EXISTS #TruthTable;
GO

WITH cte_LogicValues AS
(
SELECT  CAST(p AS SMALLINT) AS p,
        CAST(q AS SMALLINT) AS q,
        CAST(1 AS SMALLINT) AS T,
        CAST(0 AS SMALLINT) AS F
FROM    (SELECT p FROM (VALUES (0),(1)) AS MyTable(p)) a CROSS JOIN
        (SELECT q FROM (VALUES (0),(1)) AS MyTable2(q)) b
)
SELECT  CONCAT('p = ',p,',',' q = ',q) AS RowId
        --------------------------------------------
       ,p
       ,q
       ,T
       ,F
       --------------------------------------------
       --Negation
       ,(CASE p WHEN 0 THEN T ELSE F END) AS [¬p]
       ,(CASE q WHEN 0 THEN T ELSE F END) AS [¬q]
       --------------------------------------------
       --Double Negation
       ,(CASE WHEN NOT(NOT(p = 1)) THEN T ELSE F END) AS [¬¬p]
       ,(CASE WHEN NOT(NOT(q = 1)) THEN T ELSE F END) AS [¬¬q]
       --------------------------------------------
       --And
       ,(CASE WHEN p + q = 2 THEN T ELSE F END) AS [p∧q]
       ,(CASE WHEN q + p = 2 THEN T ELSE F END) AS [q∧p]
       ,(CASE WHEN p + p = 2 THEN T ELSE F END) AS [p∧p]
       ,(CASE WHEN q + q = 2 THEN T ELSE F END) AS [q∧q]
       ,(CASE WHEN p + T = 2 THEN T ELSE F END) AS [p∧T]
       ,(CASE WHEN p + F = 2 THEN T ELSE F END) AS [p∧F]
       ,(CASE WHEN q + T = 2 THEN T ELSE F END) AS [q∧T]
       ,(CASE WHEN q + F = 2 THEN T ELSE F END) AS [q∧F]
       ,(CASE WHEN NOT(p = T  AND q = T) THEN T ELSE F END) AS [¬(p∧q)]
       ,(CASE WHEN NOT(p = T  AND p = T) THEN T ELSE F END) AS [¬(p∧p)]
       ,(CASE WHEN NOT(q = T  AND q = T) THEN T ELSE F END) AS [¬(q∧q)]
       ,(CASE WHEN NOT(p = T) AND p = T  THEN T ELSE F END) AS [¬p∧p]
       ,(CASE WHEN NOT(p = T) AND q = T  THEN T ELSE F END) AS [¬p∧q]
       ,(CASE WHEN NOT(q = T) AND q = T  THEN T ELSE F END) AS [¬q∧q]
       ,(CASE WHEN NOT(p = T) AND q = T  THEN T ELSE F END) AS [¬q∧p]
       ,(CASE WHEN NOT(p = T) AND NOT(q = T) THEN T ELSE F END) AS [¬p∧¬q]
        --------------------------------------------
       --Or
       ,(CASE WHEN p + q >= 1 THEN T ELSE F END) AS [p∨q]
       ,(CASE WHEN q + p >= 1 THEN T ELSE F END) AS [q∨p]
       ,(CASE WHEN p + p >= 1 THEN T ELSE F END) AS [p∨p]
       ,(CASE WHEN q + q >= 1 THEN T ELSE F END) AS [q∨q]
       ,(CASE WHEN p + T >= 1 THEN T ELSE F END) AS [p∨T]
       ,(CASE WHEN p + F >= 1 THEN T ELSE F END) AS [p∨F]
       ,(CASE WHEN q + T >= 1 THEN T ELSE F END) AS [q∨T]
       ,(CASE WHEN q + F >= 1 THEN T ELSE F END) AS [q∨F]
       ,(CASE WHEN NOT(p = T  OR q = T) THEN T ELSE F END) AS [¬(p∨q)]
       ,(CASE WHEN NOT(p = T  OR p = T) THEN T ELSE F END) AS [¬(p∨p)]
       ,(CASE WHEN NOT(q = T  OR q = T) THEN T ELSE F END) AS [¬(q∨q)]
       ,(CASE WHEN NOT(p = T) OR p = T  THEN T ELSE F END) AS [¬p∨p]
       ,(CASE WHEN NOT(p = T) OR q = T  THEN T ELSE F END) AS [¬p∨q]
       ,(CASE WHEN NOT(q = T) OR q = T  THEN T ELSE F END) AS [¬q∨q]
       ,(CASE WHEN NOT(q = T) OR p = T  THEN T ELSE F END) AS [¬q∨p]
       ,(CASE WHEN NOT(p = T) OR NOT(q = T) THEN T ELSE F END) AS [¬p∨¬q]
       --------------------------------------------
       --Implies (If..Then)
       ,(CASE WHEN p <= q THEN T ELSE F END) AS [p→q]
       ,(CASE WHEN q <= p THEN T ELSE F END) AS [q→p]
       ,(CASE WHEN p <= q AND q <= p THEN T ELSE F END) AS [p→q∧q→p]
       ,(CASE WHEN p <= q OR  q <= p THEN T ELSE F END) AS [p→q∨q→p]
       ,(CASE WHEN NOT(p <= q AND q <= p) THEN T ELSE F END) AS [¬(p→q∧q→p)]
       ,(CASE WHEN NOT(p <= q OR  q <= p) THEN T ELSE F END) AS [¬(p→q∨q→p)]
       ,(CASE WHEN (CASE WHEN p = T THEN 0 ELSE 1 END) <= (CASE WHEN q = T THEN 0 ELSE 1 END) THEN T ELSE F END) AS [¬p→¬q]
       ,(CASE WHEN (CASE WHEN q = T THEN 0 ELSE 1 END) <= (CASE WHEN p = T THEN 0 ELSE 1 END) THEN T ELSE F END) AS [¬q→¬p]	   
       --------------------------------------------
       --Biconditional (If And Only If)
       ,(CASE WHEN p = q THEN T ELSE F END) AS [p↔q]
       ,(CASE WHEN NOT(p = q) THEN T ELSE F END) AS [¬(p↔q)]
        --------------------------------------------
       --XOR (Exclusive OR)
       ,(CASE WHEN p + q = 1 THEN T ELSE F END) AS [p⊕q]
       ,(CASE WHEN NOT(p + q = 1) THEN T ELSE F END) AS [¬(p⊕q)]
INTO   #TruthTable
FROM   cte_LogicValues
ORDER BY p DESC, q DESC;
GO

SELECT * FROM #TruthTable;

----------------------------------------------------------
----------------------------------------------------------
DROP TABLE IF EXISTS #TruthTable_Pivot;
GO

--Pivot the data
;WITH cte_Pivot AS
(
SELECT  operation, [p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1]
FROM
    (SELECT RowId,
            operation,
            value
     FROM #TruthTable
     UNPIVOT
     (
         value
         FOR operation IN
        ([¬p], [¬q], [¬¬p], [¬¬q], [p∧q], [q∧p], [p∧p], [q∧q], [p∧T], [p∧F], [q∧T], [q∧F], [¬(p∧q)], [¬(p∧p)], [¬(q∧q)], [¬p∧p], [¬p∧q], [¬q∧q], [¬q∧p], [¬p∧¬q], [p∨q], [q∨p], [p∨p], [q∨q], [p∨T], [p∨F], [q∨T], [q∨F], [¬(p∨q)], [¬(p∨p)], [¬(q∨q)], [¬p∨p], [¬p∨q], [¬q∨q], [¬q∨p], [¬p∨¬q], [p→q], [q→p], 
         [p↔q], [p⊕q],[p→q∧q→p], [p→q∨q→p],[¬(p→q∧q→p)], [¬(p→q∨q→p)], [¬(p↔q)],[¬(p⊕q)],[¬p→¬q],[¬q→¬p]
        )
     ) AS unpvt) AS src
PIVOT
(
    MAX(value)
    FOR RowId IN ([p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1])
) AS pvt
),
cte_RowNumber AS
(
SELECT  ROW_NUMBER() OVER (ORDER BY [p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1], Operation) AS RowNumber,
        CONCAT([p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1]) AS LogicIdentity,
        *
FROM cte_Pivot
)
SELECT  DENSE_RANK() OVER (PARTITION BY LogicIdentity ORDER BY RowNumber) AS DenseRank
        ,*
INTO    #TruthTable_Pivot
FROM    cte_RowNumber;
GO

SELECT * FROM #TruthTable_Pivot;

----------------------------------------------------------
----------------------------------------------------------
