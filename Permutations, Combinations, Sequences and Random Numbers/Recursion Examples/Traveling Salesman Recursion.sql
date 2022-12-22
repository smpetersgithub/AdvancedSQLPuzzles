/*----------------------------------------------------
Scott Peters
https://AdvancedSQLPuzzles.com

Solves the traveling salesman problem
https://en.wikipedia.org/wiki/Travelling_salesman_problem

*/----------------------------------------------------
SET NOCOUNT ON;
DROP TABLE IF EXISTS #TravelingSalesman;
DROP TABLE IF EXISTS #Routes;
GO

----------------------
----------------------
----------------------

CREATE TABLE #Routes
(
FromNode VARCHAR(30) NOT NULL,
ToNode VARCHAR(30) NOT NULL,
Distance DECIMAL(28, 12) NOT NULL,
PRIMARY KEY (FromNode, ToNode)
);

INSERT #Routes (FromNode, ToNode, Distance)
OUTPUT inserted.ToNode AS FromNode,
       inserted.FromNode AS ToNode,
       inserted.Distance
INTO   #Routes (FromNode, ToNode, Distance)
VALUES
('Austin','Dallas', 100),
('Dallas','Memphis', 200),
('Memphis','Des Moines', 300),
('Dallas','Des Moines', 400);


WITH cteMap(Nodes, LastNode, NodeMap)
AS (
SELECT  2 AS Nodes,
        ToNode,
        CAST('\' + FromNode + '\' + ToNode + '\' AS VARCHAR(MAX)) AS NodeMap
FROM    #Routes
--WHERE   FromNode = 'Austin'

UNION ALL

SELECT  m.Nodes + 1 AS Nodes,
        r.ToNode AS LastNode,
        CAST(m.NodeMap + r.ToNode + '\' AS VARCHAR(MAX)) AS NodeMap
FROM    cteMap AS m INNER JOIN
        #Routes AS r ON r.FromNode = m.LastNode
WHERE   m.NodeMap NOT LIKE '\%' + r.ToNode + '%\'
        --AND m.NodeMap NOT LIKE '%Des Moines%'
)
SELECT  NodeMap
INTO    #TravelingSalesman
FROM    cteMap
OPTION (MAXRECURSION 0);


SELECT * FROM #TravelingSalesman;
