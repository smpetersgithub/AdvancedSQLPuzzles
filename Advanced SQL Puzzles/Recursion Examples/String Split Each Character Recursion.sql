/*----------------------------------------------------
Scott Peters
String Split Each Character
https://advancedsqlpuzzles.com
Last Updated: 01/13/2022
Microsoft SQL Server T-SQL

This script uses recursion to split a string into rows of substrings for each character in the string.

*/----------------------------------------------------

-------------------------------
-------------------------------
DROP TABLE IF EXISTS #Example;
GO

-------------------------------
-------------------------------
CREATE TABLE #Example
(
Id       INTEGER IDENTITY(1,1) PRIMARY KEY,
String VARCHAR(30) NOT NULL
);
GO

INSERT INTO #Example VALUES('123456789'),('abcdefghi');
GO

-------------------------------
-------------------------------
;WITH cte_Recursion AS
(
SELECT Id,
       String,
       STUFF(String,1,1,'') AS String_Stuff,
       LEFT(String,1) AS String_Left
FROM   #Example
UNION ALL
SELECT Id,
       String,
       STUFF(String_Stuff,1,1,'') String_Stuff,
       LEFT(String_Stuff,1) AS String_Left
FROM   cte_Recursion
WHERE  LEN(String_Stuff) > 0
)
SELECT
       Id,
       ROW_NUMBER() OVER (PARTITION BY Id ORDER BY GETDATE()) AS RowNumber,
       String,
       String_Left AS String_Value,
       ISNUMERIC(String_Left) AS [IsNumeric]
FROM   cte_Recursion
ORDER BY 1,2;
GO
