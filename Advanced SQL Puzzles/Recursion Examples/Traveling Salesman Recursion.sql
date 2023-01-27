/*----------------------------------------------------
Scott Peters
Traveling Salesman
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to solve the Traveling Salesman Problem
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
ToNode   VARCHAR(30) NOT NULL,
Cost     MONEY NOT NULL,
PRIMARY KEY (FromNode, ToNode)
);
GO

INSERT #Routes (FromNode, ToNode, Cost)
OUTPUT INSERTED.ToNode AS FromNode,
       INSERTED.FromNode AS ToNode,
       INSERTED.Cost
INTO   #Routes (FromNode, ToNode, Cost)
VALUES
('Austin','Dallas',100),
('Dallas','Memphis',200),
('Memphis','Des Moines',300),
('Dallas','Des Moines',400);
GO

WITH cteMap(Nodes, LastNode, NodeMap, Cost)
AS (
SELECT  2 AS Nodes,
        ToNode,
        CAST('\' + FromNode + '\' + ToNode + '\' AS VARCHAR(MAX)) AS NodeMap,
        Cost
FROM    #Routes
WHERE   FromNode = 'Austin'
UNION ALL
SELECT  m.Nodes + 1 AS Nodes,
        r.ToNode AS LastNode,
        CAST(m.NodeMap + r.ToNode + '\' AS VARCHAR(MAX)) AS NodeMap,
		m.Cost + r.Cost AS Cost
FROM    cteMap AS m INNER JOIN
        #Routes AS r ON r.FromNode = m.LastNode
WHERE   m.NodeMap NOT LIKE '\%' + r.ToNode + '%\'
)
SELECT  NodeMap, Cost
INTO    #TravelingSalesman
FROM    cteMap
OPTION (MAXRECURSION 0);
GO
