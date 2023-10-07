/*----------------------------------------------------
Scott Peters
Sudoku
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to solve a Sudoku puzzle.

*/----------------------------------------------------

-------------------------------
-------------------------------
DECLARE @vBoard VARCHAR(81) = '86....3...2...1..7....74...27.9..1...8.....7...1..7.95...56....4..1...5...3....81';

-------------------------------
-------------------------------
WITH cte_Recursion(Sudoku,IndexValue) AS
(
SELECT  Sudoku,
        CHARINDEX('.',Sudoku) AS IndexValue
FROM    (VALUES(@vBoard)) AS Input(Sudoku)
UNION ALL
SELECT  CONVERT(VARCHAR(81),CONCAT(SUBSTRING(Sudoku,1,IndexValue-1),myRecursion,SUBSTRING(Sudoku,IndexValue+1,81))) AS Sudoku,
        CHARINDEX('.',CONCAT(SUBSTRING(Sudoku,1,IndexValue-1),myRecursion,SUBSTRING(Sudoku,IndexValue+1,81))) AS IndexValue
FROM    cte_Recursion INNER JOIN (VALUES('1'),('2'),('3'),('4'),('5'),('6'),('7'),('8'),('9')
) AS Digits(myRecursion) ON NOT EXISTS (
                              SELECT  1
                              FROM    (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS Positions(lp)
                              WHERE   myRecursion = SUBSTRING(Sudoku, ((IndexValue-1)/9)*9 + lp, 1) OR
                                      myRecursion = SUBSTRING(Sudoku, ((IndexValue-1)%9) + (lp-1)*9 + 1, 1) OR
                                      myRecursion = SUBSTRING(Sudoku, (((IndexValue-1)/3) % 3) * 3 + ((IndexValue-1)/27) * 27 + lp + ((lp-1) / 3) * 6, 1)
                                        )
WHERE IndexValue > 0
)
SELECT 'One long line:' AS Type, Sudoku FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '1' AS Line, SUBSTRING(Sudoku,1,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '2' AS Type, SUBSTRING(Sudoku,10,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '3' AS Type, SUBSTRING(Sudoku,19,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '4' AS Type, SUBSTRING(Sudoku,29,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '5' AS Type, SUBSTRING(Sudoku,37,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '6' AS Type, SUBSTRING(Sudoku,46,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '7' AS Type, SUBSTRING(Sudoku,55,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '8' AS Type, SUBSTRING(Sudoku,64,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '9' AS Type, SUBSTRING(Sudoku,73,9) AS Line FROM cte_Recursion WHERE IndexValue = 0;
GO

/*
Here is the answer:

867295314
924381567
135674829
276953148
589416273
341827695
718569432
492138756
653742981
*/
