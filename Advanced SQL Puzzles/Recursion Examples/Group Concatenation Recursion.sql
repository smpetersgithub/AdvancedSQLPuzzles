/*----------------------------------------------------
Scott Peters
https://AdvancedSQLPuzzles.com

Same as the STRING_AGG funtion.
Concatenates the values of string expressions and places separator values between them.

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