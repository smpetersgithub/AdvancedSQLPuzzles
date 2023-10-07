/*----------------------------------------------------
Scott Peters
Associates
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to group hierarchies together.

*/----------------------------------------------------

---------------------
---------------------
DROP TABLE IF EXISTS #Associates;
GO

---------------------
---------------------
CREATE TABLE #Associates
(
Associate1 VARCHAR(100),
Associate2 VARCHAR(100),
PRIMARY KEY (Associate1, Associate2)
);
GO

---------------------
---------------------
INSERT INTO #Associates (Associate1, Associate2) VALUES
('Anne','Betty'),
('Anne','Charles'),
('Betty','Dan'),
('Charles','Emma'),
('Francis','George'),
('George','Harriet');
GO

---------------------
---------------------
WITH cte_Recursion AS
(
SELECT  Associate1,
        Associate2,
        1 AS Depth
FROM    #Associates
UNION ALL
SELECT  a.Associate1,
        b.Associate2,
        Depth + 1 AS Depth
FROM    #Associates a INNER JOIN
        cte_Recursion b ON a.Associate2 = b.Associate1
)
SELECT  *
FROM    cte_Recursion
UNION ALL
SELECT  Associate1,
        Associate1,
        0 AS Depth
FROM    #Associates;
GO
