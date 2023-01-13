CREATE OR ALTER FUNCTION FnDateDiffPartsTable(@DateTime1 AS DATETIME2, @DateTime2 AS DATETIME2) 
RETURNS @DateDifference TABLE (
YearDifference INT,
MonthDifference INT,
DayDifference INT,
HourDifference INT,
MinuteDifference INT,
SecondDifference INT,
NanoDifference INT
)
/*********************************************************************
Scott Peters
Creates the FnDateDiffPartsTable function
https://advancedsqlpuzzles.com
Last Updated: 01/12/2023
Microsoft SQL Server T-SQL

This script creates a table valued function that returns the difference between two datetime values,
broken down into year, month, day, hour, minute, second and nano second parts.

Example usage:
SELECT * FROM dbo.FnDateDiffPartsTable('20130518 00:00:00.0000001','20110619 00:00:00.1110000');

**********************************************************************/
AS
BEGIN

        DECLARE @DateTime1_Low DATETIME2;
        DECLARE @DateTime2_High DATETIME2;

        IF @DateTime1 > @DateTime2
            BEGIN
                SET @DateTime1_Low = @DateTime2
                SET @DateTime2_High = @DateTime1
            END
        ELSE
            BEGIN
                SET @DateTime1_Low = @DateTime1
                SET @DateTime2_High = @DateTime2
            END

        INSERT INTO @DateDifference
        SELECT
                YearDifference - SubtractionYear AS YearDifference,
                (MonthDifference - SubtractionMonth) % 12 AS MonthDifference,
                DATEDIFF(DAY, DATEADD(mm, MonthDifference - SubtractionMonth, DateTime1), [DateTime2]) - SubtractionDay AS DayDifference,
                NanoSecondDifference / CAST(3600000000000 AS BIGINT) % 60 AS HourDifference,
                NanoSecondDifference / CAST(60000000000 AS BIGINT) % 60 AS MinuteDifference,
                NanoSecondDifference / 1000000000 % 60 AS SecondDifference,
                NanoSecondDifference % 1000000000 AS NanoDifference
        FROM    (VALUES(@DateTime1_Low, 
                        @DateTime2_High,
                        CAST(@DateTime1_Low AS TIME), 
                        CAST(@DateTime2_High AS TIME),
                        DATEDIFF(yy, @DateTime1_Low, @DateTime2_High),
                        DATEDIFF(mm, @DateTime1_Low, @DateTime2_High),
                        DATEDIFF(dd, @DateTime1_Low, @DateTime2_High)
                )) AS D(DateTime1, [DateTime2], Time1, Time2, YearDifference, MonthDifference, DateDifference)
                CROSS APPLY
                (VALUES(CASE WHEN DATEADD(yy, YearDifference, DateTime1)  > [DateTime2] THEN 1 ELSE 0 END,
                        CASE WHEN DATEADD(mm, MonthDifference, DateTime1) > [DateTime2] THEN 1 ELSE 0 END,
                        CASE WHEN DATEADD(dd, DateDifference, DateTime1)  > [DateTime2] THEN 1 ELSE 0 END
                )) AS A1(SubtractionYear, SubtractionMonth, SubtractionDay)
                CROSS APPLY
                (VALUES (CAST(86400000000000 AS BIGINT) * SubtractionDay
                    +   (CAST(1000000000 AS BIGINT) * DATEDIFF(ss, '00:00', Time2) + DATEPART(ns, Time2))
                    -   (CAST(1000000000 AS BIGINT) * DATEDIFF(ss, '00:00', Time1) + DATEPART(ns, Time1))
                )) AS A2(NanoSecondDifference);

        RETURN
    END
GO
