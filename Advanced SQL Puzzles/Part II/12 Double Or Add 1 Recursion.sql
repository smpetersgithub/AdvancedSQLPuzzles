/*********************************************************************
Scott Peters
Double Or Add 1
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL
**********************************************************************/

-------------------------------
-------------------------------
--Tables Used
DROP TABLE IF EXISTS #Numbers;
GO

-------------------------------
-------------------------------
--Declare variables
--Set @vTotalNumbers to the desired score
DECLARE @vTotalNumbers INTEGER = 100;

-------------------------------
-------------------------------
--Create and populate a #Numbers table
WITH cte_Number (Number)
AS (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Number
    WHERE  Number < @vTotalNumbers
    )
SELECT CAST(Number AS bigint) AS Number,
       (CASE Number WHEN 1 THEN 1 ELSE NULL END) AS Calculation
INTO   #Numbers
FROM   cte_Number
OPTION (MAXRECURSION 101)--A value of 0 means no limit to the recursion level

-------------------------------
-------------------------------

WITH cte_Numbers AS
(
--Add a ranking function here if needed
--Test data has StepNumber to rank/sort the records.
SELECT  number
FROM    #Numbers
),
cte_Recursion AS
(
SELECT  Number,
        CASE WHEN Number = 1 THEN 1 ELSE Number * 2 END AS RunningSum
FROM    #Numbers
WHERE   Number = 1
UNION ALL
SELECT
        t.Number,
        CASE WHEN (RunningSum * 2) < 101 THEN (RunningSum * 2) ELSE RunningSum + 1 END AS RunningSum
FROM    cte_Recursion cte
        INNER JOIN
        cte_Numbers t ON t.Number = (cte.Number + 1)
)
SELECT   *
FROM     cte_Recursion
WHERE    RunningSum <= 100
ORDER BY Number DESC;
GO
