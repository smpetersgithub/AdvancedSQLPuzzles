/*********************************************************************
Scott Peters
Pascal’s Triangle
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script solves Pascal's Triangle.
https://en.wikipedia.org/wiki/Pascal%27s_triangle
**********************************************************************/

--Set your row and position
--Remember to use 0-based indexing
DECLARE @vRowNumber INTEGER = 4;
DECLARE @vPositionNumber INTEGER = 3;

-------------------------------
-------------------------------
--Variables to hold the Row, Position, and RowMinusPosition factorials
--Factorial examples : 3! is 6, 4! is 24
DECLARE @vRowFactorial INTEGER;
DECLARE @vPositionFactorial INTEGER;
DECLARE @vRowMinusPositionFactorial INTEGER;

--@vPositionValue is calculated by @vRowFactorial / (@vPositionFactorial * @vRowMinusPositionFactorial)
DECLARE @vPositionValue INTEGER;

-------------------------------
-------------------------------
--Return 1 if (@vRowNumber - @vPositionNumber = 0) OR @vPositionNumber = 0
--The factorial of 0! is 1
IF  (@vRowNumber - @vPositionNumber = 0) OR @vPositionNumber = 0
    BEGIN
    SET @vPositionValue = 1;
    RETURN;--------------------------------------------RETURN
    END;

-------------------------------
-------------------------------
--Determine Row Factorial
WITH cte_Factorial (Number, Factorial)
AS (
SELECT 1,
       1
UNION ALL
SELECT Number + 1, (Number + 1) * Factorial
FROM   cte_Factorial
WHERE  Number < @vRowNumber
)
SELECT @vRowFactorial = Factorial
FROM   cte_Factorial;

-------------------------------
-------------------------------
--Determine Position Factorial
WITH cte_Factorial (Number, Factorial)
AS (
SELECT 1,
       1
UNION ALL
SELECT Number + 1, (Number + 1) * Factorial
FROM   cte_Factorial
WHERE  Number < @vPositionNumber
)
SELECT @vPositionFactorial = Factorial
FROM   cte_Factorial;

-------------------------------
-------------------------------
--Determine Row Minus Position Factorial
WITH cte_Factorial (Number, Factorial)
AS (
SELECT 1,
       1
UNION ALL
SELECT Number + 1, (Number + 1) * Factorial
FROM   cte_Factorial
WHERE  Number < @vRowNumber - @vPositionNumber
)
SELECT @vRowMinusPositionFactorial = Factorial
FROM   cte_Factorial;

-------------------------------
-------------------------------
--Display the final results
PRINT	CONCAT('The value for Row ',@vRowNumber,' and Position ',@vPositionNumber,' is ',(@vRowFactorial / (@vPositionFactorial * @vRowMinusPositionFactorial)));
GO
