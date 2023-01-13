/*----------------------------------------------------
Scott Peters
Double the Number
https://advancedsqlpuzzles.com
Last Updated: 01/13/2022

Begining at 1, this recursive statement will double the number for each record.
1, 2, 4, 8, 16, 32.....

*/----------------------------------------------------

---------------------
---------------------
DROP TABLE IF EXISTS #Numbers;
GO

---------------------
---------------------
CREATE TABLE #Numbers
(
Number INTEGER NOT NULL PRIMARY KEY
);

INSERT INTO #Numbers VALUES (1),(2),(3),(4),(5);
GO

---------------------
---------------------
;WITH cte_Numbers AS
(
SELECT  *
FROM    #Numbers
),
cte_Recursion AS
(
SELECT  Number,
        CASE WHEN Number = 1 THEN 1 ELSE Number * 2 END AS RunningSum
FROM    #Numbers
WHERE Number = 1
UNION ALL
SELECT  
        t.Number,
		(RunningSum * 2) AS RunningSum
FROM    cte_Recursion cte
        INNER JOIN
        cte_Numbers t ON t.Number = (cte.Number + 1)
)
SELECT   *
FROM     cte_Recursion
ORDER BY Number;
