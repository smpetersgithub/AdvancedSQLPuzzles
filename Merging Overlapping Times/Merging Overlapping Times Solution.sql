/*----------------------------------------------------
Merging Overlapping Times

Scott Peters
https://advancedsqlpuzzles.com
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.##TimePeriods','U') IS NOT NULL
  DROP TABLE ##TimePeriods;
GO

CREATE TABLE ##TimePeriods
(
StartDate	DATE,
EndDate		DATE
);
GO

INSERT INTO ##TimePeriods VALUES
('1/1/2018','1/5/2018'),
('1/1/2018','1/3/2018'),
('1/1/2018','1/2/2018'),
('1/3/2018','1/9/2018'),
('1/10/2018','1/11/2018'),
('1/12/2018','1/16/2018'),
('1/15/2018','1/19/2018');
GO

WITH cte_TimePeriod_Merge AS
(
SELECT	a.StartDate, MIN(b.EndDate) AS EndDate
FROM	(SELECT	DISTINCT
				t1.StartDate
		FROM	 ##TimePeriods t1
		) AS a INNER JOIN
		(
		SELECT	t3.EndDate
		FROM	##TimePeriods AS t3 LEFT OUTER JOIN
				##TimePeriods AS t4 ON t3.EndDate >= t4.StartDate AND
										t3.EndDate < t4.EndDate
		GROUP BY t3.EndDate
		HAVING COUNT(t4.StartDate) = 0
		) AS b ON a.StartDate <= b.EndDate
GROUP BY a.StartDate
)
SELECT	MIN(StartDate) as StartDate,
		MAX(EndDate) as EndDate
FROM	cte_TimePeriod_Merge
GROUP BY EndDate;
