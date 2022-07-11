/*********************************************************************
Scott Peters
Creating a Calendar Table
https://advancedsqlpuzzles.com
Last Updated: 07/11/2022

This script is written in Microsoft SQL Server's T-SQL

This script shows example usage of the function FnReturnCalendarTable.
See full instructions in PDF format at the following GitHub repository:
https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Tips%20and%20Tricks

**********************************************************************/
SET NOCOUNT ON;
DROP TABLE IF EXISTS dbo.CalendarDaysTemp;
GO

--Create a temporary calendar table
CREATE TABLE dbo.CalendarDaysTemp
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
        dbo.FnReturnCalendarTable(cd.CalendarDate) ct
WHERE   cd.DateKey = ct.DateKey;
GO

--Create a view
CREATE OR ALTER VIEW dbo.VwCalendarTable AS
SELECT  ct.*
FROM    CalendarDaysTemp cd CROSS APPLY
        dbo.FnReturnCalendarTable(cd.CalendarDate) ct
WHERE   cd.DateKey = ct.DateKey;
GO


SELECT top 1 * FROM VwCalendarTable;
