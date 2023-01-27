/*----------------------------------------------------
Scott Peters
Sudoku
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to solve a Sodoku puzzle.

*/----------------------------------------------------

-------------------------------
-------------------------------
DECLARE @vBoard VARCHAR(81) = '86....3...2...1..7....74...27.9..1...8.....7...1..7.95...56....4..1...5...3....81';

-------------------------------
-------------------------------
WITH cte_Recursion(Sodoku,IndexValue) AS
(
SELECT  Sodoku,
        CHARINDEX('.',Sodoku) AS IndexValue
FROM    (VALUES(@vBoard)) AS Input(Sodoku)
UNION ALL
SELECT  CONVERT(VARCHAR(81),CONCAT(SUBSTRING(Sodoku,1,IndexValue-1),myRecursion,SUBSTRING(Sodoku,IndexValue+1,81))) AS Sodoku,
        CHARINDEX('.',CONCAT(SUBSTRING(Sodoku,1,IndexValue-1),myRecursion,SUBSTRING(Sodoku,IndexValue+1,81))) AS IndexValue
FROM    cte_Recursion INNER JOIN (VALUES('1'),('2'),('3'),('4'),('5'),('6'),('7'),('8'),('9')
) AS Digits(myRecursion) ON NOT EXISTS (
                              SELECT  1
                              FROM    (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS Positions(lp)
                              WHERE   myRecursion = SUBSTRING(Sodoku, ((IndexValue-1)/9)*9 + lp, 1) OR
                                      myRecursion = SUBSTRING(Sodoku, ((IndexValue-1)%9) + (lp-1)*9 + 1, 1) OR
                                      myRecursion = SUBSTRING(Sodoku, (((IndexValue-1)/3) % 3) * 3 + ((IndexValue-1)/27) * 27 + lp + ((lp-1) / 3) * 6, 1)
                                        )
WHERE IndexValue > 0
)
SELECT 'One long line:' AS Type, Sodoku FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '1' AS Line, SUBSTRING(Sodoku,1,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '2' AS Type, SUBSTRING(Sodoku,10,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '3' AS Type, SUBSTRING(Sodoku,19,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '4' AS Type, SUBSTRING(Sodoku,29,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '5' AS Type, SUBSTRING(Sodoku,37,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '6' AS Type, SUBSTRING(Sodoku,46,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '7' AS Type, SUBSTRING(Sodoku,55,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '8' AS Type, SUBSTRING(Sodoku,64,9) AS Line FROM cte_Recursion WHERE IndexValue = 0 UNION
SELECT '9' AS Type, SUBSTRING(Sodoku,73,9) AS Line FROM cte_Recursion WHERE IndexValue = 0;
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
