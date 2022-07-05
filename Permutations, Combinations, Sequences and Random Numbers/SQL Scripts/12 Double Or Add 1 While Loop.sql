/*********************************************************************
Scott Peters
Double Or Add 1
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• I can make a safe assumption that less than the desired score (100) numbers are needed
• To double the number, a WHILE loop is needed
• To Add 1, we can use windowing
• The #Numbers table is the only table needed to solve this puzzle

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
SELECT Number,
       (CASE Number WHEN 1 THEN 1 ELSE NULL END) AS Calculation
INTO   #Numbers
FROM   cte_Number
OPTION (MAXRECURSION 0)--A value of 0 means no limit to the recursion level

-------------------------------
-------------------------------
--Update the #Numbers table with double calcualtion
WHILE (SELECT MAX(Calculation) * 2 FROM #Numbers) < 100

    BEGIN
    WITH cte_Min AS
    (
    (SELECT MIN(Number) AS MinNumber FROM #Numbers WHERE Calculation IS NULL)
    ),
    cte_Lag AS
    (
    SELECT Number, LAG(Calculation,1) OVER (ORDER BY Number) * 2 AS LagValue
    FROM #Numbers
    ),
    cte_Numbers AS
    (
    SELECT Number, LagValue 
    FROM   cte_Lag 
    WHERE Number = (SELECT MinNumber FROM cte_Min)
    )
    UPDATE  #Numbers
    SET     Calculation = b.LagValue
    FROM    #Numbers a INNER JOIN
            cte_Numbers b ON a.Number = b.Number

    IF @@ROWCOUNT = 0
        BEGIN
        PRINT '@@ROWCOUNT Returned 0.  Increase The Size Of The Numbers Table';
        RETURN
        END

    END;

-------------------------------
-------------------------------
--Update the #Numbers table with add 1 calculation
WITH cte_RowNumber AS
(
SELECT  ROW_NUMBER() OVER (ORDER BY Number) AS RowNumber2,
        (SELECT MAX(Calculation) FROM #Numbers) AS MaxNumber,
        *
FROM    #Numbers
WHERE   Calculation IS NULL
)
UPDATE  #Numbers
SET     Calculation = MaxNumber + RowNumber2
FROM    #Numbers a INNER JOIN
        cte_RowNumber b ON a.Number = b.Number;

-------------------------------
-------------------------------
--Display the results
SELECT * FROM #Numbers WHERE Calculation <= 100;