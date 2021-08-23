/*
Scott Peters
www.AdvancedSQLPuzzles.com
Creating a Calendar Table
*/

--Example usages
--DROP TABLE CalendarDays;

CREATE TABLE CalendarDays
(
DateKey INT NOT NULL PRIMARY KEY,
CalendarDate DATE NOT NULL
);

GO

-----------------------------------------------------
-- Populate the CalendarTable
DECLARE @vStartDate DATE = '2020-01-01';
WHILE @vStartDate <> '2021-01-01'
	BEGIN
	INSERT INTO CalendarDays(DateKey, CalendarDate) VALUES
		(
		CONVERT(INT,CONVERT(VARCHAR, @vStartDate, 112)),
		@vStartDate
		);
	SET @vStartDate = DATEADD(DAY,1,@vStartDate);
	END;



--Basic usage with CROSS APPLY
SELECT	ct.*
FROM	CalendarDays cd CROSS APPLY
		FnReturnCalendarTable(cd.CalendarDate) ct
WHERE	cd.DateKey = ct.DateKey;
GO		

--Create a view
ALTER VIEW VwCalendarTable AS
SELECT	ct.*
FROM	CalendarDays cd CROSS APPLY
		FnReturnCalendarTable(cd.CalendarDate) ct
WHERE	cd.DateKey = ct.DateKey;
GO

SELECT * FROM VwCalendarTable;