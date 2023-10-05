/*-----------------------------------------------------------------------
Scott Peters
Creating a Calendar Table
https://advancedsqlpuzzles.com
Last Updated: 01/11/2023
Microsoft SQL Server T-SQL

This script shows an example usage of the function FnReturnCalendarTable.

*/-----------------------------------------------------------------------

SET NOCOUNT ON;
DROP TABLE IF EXISTS CalendarDaysTemp;
GO

--Create a temporary calendar table
CREATE TABLE CalendarDaysTemp
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
    INSERT INTO CalendarDaysTemp(DateKey, CalendarDate) VALUES
        (
        CONVERT(INT,CONVERT(VARCHAR, @vStartDate, 112)),
        @vStartDate
        );

    SET @vStartDate = DATEADD(DAY,1,@vStartDate);
    END;

-----------------------------------------------------
-----------------------------------------------------

--Basic usage with CROSS APPLY
SELECT  ct.*
FROM    CalendarDaysTemp cd CROSS APPLY
        FnReturnCalendarTable(cd.CalendarDate) ct
WHERE   cd.DateKey = ct.DateKey;
GO

--Create a view
CREATE OR ALTER VIEW VwCalendarTable AS
SELECT  ct.*
FROM    CalendarDaysTemp cd CROSS APPLY
        FnReturnCalendarTable(cd.CalendarDate) ct
WHERE   cd.DateKey = ct.DateKey;
GO


SELECT top 1 * FROM VwCalendarTable;
