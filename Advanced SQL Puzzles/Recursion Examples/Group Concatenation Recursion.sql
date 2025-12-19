/*----------------------------------------------------
Scott Peters
Group Concatenation
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL
*/----------------------------------------------------

-------------------------------
-------------------------------
DROP TABLE IF EXISTS #Example;
GO

-------------------------------
-------------------------------
CREATE TABLE #Example
(
SequenceNumber  INTEGER PRIMARY KEY,
String          VARCHAR(100)
);
GO

INSERT INTO #Example VALUES
(1,'Hello'),
(2,'World!');
GO

-------------------------------
-------------------------------
WITH
cte_Recursion(String2,Depth) AS
(
SELECT  CAST('' AS NVARCHAR(MAX)),
        CAST(MAX(SequenceNumber) AS INTEGER)
FROM    #Example
UNION ALL
SELECT  e.String + ' ' + r.String2, r.Depth - 1
FROM    cte_Recursion r INNER JOIN
        #Example e ON r.Depth = e.SequenceNumber
)
SELECT  String2
FROM    cte_Recursion
WHERE   Depth = 0;
GO
