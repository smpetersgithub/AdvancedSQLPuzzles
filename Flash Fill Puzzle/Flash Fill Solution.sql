/*----------------------------------------------------
Flash Fill / Data Smear

Scott Peters
https://advancedsqlpuzzles.com
*/----------------------------------------------------

/*
Here is an excellent post about this problem.
https://www.red-gate.com/simple-talk/sql/t-sql-programming/filling-in-missing-values-using-the-t-sql-window-frame/
*/


IF OBJECT_ID('tempdb.dbo.#Gaps','U') IS NOT NULL
	DROP TABLE #Gaps;
GO

IF OBJECT_ID('tempdb.dbo.#Gaps2','U') IS NOT NULL
	DROP TABLE #Gaps2;
GO


CREATE TABLE #Gaps
(
RowNumber	INTEGER,
TestCase	VARCHAR(MAX)
);
GO

INSERT INTO #Gaps VALUES
(1,'Alpha'),
(2,NULL),
(3,NULL),
(4,NULL),
(5,'Bravo'),
(6,NULL),
(7,'Charlie'),
(8,NULL),
(9,NULL);
GO

SELECT * INTO #Gaps2 FROM #Gaps;
GO

--Solution 1
SELECT	a.RowNumber,
		(SELECT	 b.TestCase
		 FROM	 #Gaps b
		 WHERE	 b.RowNumber =
					 (SELECT MAX(c.RowNumber)
					 FROM #Gaps c
					 WHERE c.RowNumber <= a.RowNumber AND c.TestCase != '')) TestCase
FROM #Gaps a;


--Solution 2
SELECT	RowNumber,
		MAX(TestCase) OVER (PARTITION BY DistinctCount) AS TestCase
FROM	(SELECT	RowNumber,
				TestCase,
				COUNT(TestCase) OVER (ORDER BY RowNumber) AS DistinctCount
		FROM #Gaps) a
ORDER BY RowNumber;

--Solution 3
--This type of update is called a "quirky update"
--https://ask.sqlservercentral.com/questions/5150/please-can-somebody-explain-how-quirky-updates-wor.html
--There is no guarantee that this UPDATE will always produce the correct result.  You must have another 
--method to validate the results.
BEGIN
	DECLARE @v VARCHAR(MAX);
	UPDATE #Gaps2 WITH(TABLOCKX)
	SET @v = TestCase = CASE WHEN TestCase IS NULL THEN @v ELSE TestCase END
	SELECT RowNumber, TestCase FROM #Gaps;
END

SELECT * FROM #Gaps2;
GO
