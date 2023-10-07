/*----------------------------------------------------
Scott Peters
Numbers Table
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to build a numbers table.
Set the start and end numbers via the variables @vStartNumber and @vEndNumber.

*/----------------------------------------------------

---------------------
---------------------
DECLARE @vStartNumber INTEGER = -8;
DECLARE @vEndNumber INTEGER = 10;

---------------------
---------------------
WITH cte_Recursion (Number)
AS 
(
SELECT @vStartNumber AS Number
UNION ALL
SELECT  Number + 1
FROM   cte_Recursion
WHERE  Number < @vEndNumber
)
SELECT Number
FROM   cte_Recursion
OPTION (MAXRECURSION 100);
GO
