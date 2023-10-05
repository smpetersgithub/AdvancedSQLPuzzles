/*********************************************************************
Scott Peters
Pascal’s Triangle
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script solves Pascal's Triangle.
https://en.wikipedia.org/wiki/Pascal%27s_triangle

The position is determined by the user-specified variables @vRowNumber and @vPositionNumber, 
which correspond to the row and position of the value in the triangle, respectively. 
The script uses zero-based indexing, so the first row is row 0, and the first position is position 0.

The script first checks if the value of the position is one. If the value is 1, it will return 1. 
If the value is not 1, the script uses common table expressions (CTEs) and the recursion to 
calculate the factorials of the specified row, position, and row minus position. 
Then the script calculates the final value of the position using the formula (Row! / (Position! * (Row-Position)!)). 
Finally, the script prints the final result of the calculated value of the position in Pascal's Triangle.


Pascal's Triangle uses 0-based indexing.
The first row is row 0.
The first position is position 0.
The factorial of 0! is 1.
------

Here are the first eight rows.

0   |   1  |
1   |   1  |  1  |
2   |   1  |  2  |  1  |
3   |   1  |  3  |  3  |  1  |
4   |   1  |  4  |  6  |  4  |  1  |
5   |   1  |  5  | 10  | 10  |  5  |  1  |
6   |   1  |  6  | 15  | 20  | 15  |  6  | 1  |
7   |   1  |  7  | 21  | 35  | 35  | 21  | 7  | 1  |
-------------------------------------------
Pos.    0  |  1  |  2  |  3  |  4  |  5  | 6  | 7  |
-------------------------------------------


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
