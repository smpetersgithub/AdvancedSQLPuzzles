CREATE OR ALTER FUNCTION FnReturnCalendarTable
/*----------------------------------------------------------------------------------------------------------------------------
Scott Peters
Creating a Calendar Table
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script creates a table-valued function called "FnReturnCalendarTable" that takes a date as input, 
and returns a table with various date-related information.

The table returned by the function includes various date-related columns such as the date key, calendar date, 
different date styles, and month/year/week-related columns. It also includes some calculated columns, like 
First day of Quarter, Last Day of Quarter, Month Long and Short Name, and Month of the Quarter.

It also uses some date-related T-SQL functions such as MONTH, YEAR, DATEPART, DATEDIFF, DATEADD, and EOMONTH 
to calculate the values of these columns.  It is important to note that the specific date style columns 
may not be necessary for all use cases. Feel free to remove any column you do not need and use the function that suits your needs.

*/----------------------------------------------------------------------------------------------------------------------------
(@vInputDate DATE) RETURNS TABLE AS
RETURN
SELECT
         CONVERT(INT,CONVERT(VARCHAR, @vInputDate, 112)) AS DateKey
        ,CAST(CONVERT(VARCHAR, @vInputDate, 1) AS DATE) AS CalendarDate
        ,CONVERT(VARCHAR, @vInputDate, 1) AS DateStyle1
        ,CONVERT(VARCHAR, @vInputDate, 2) AS DateStyle2
        ,CONVERT(VARCHAR, @vInputDate, 3) AS DateStyle3
        ,CONVERT(VARCHAR, @vInputDate, 4) AS DateStyle4
        ,CONVERT(VARCHAR, @vInputDate, 5) AS DateStyle5
        ,CONVERT(VARCHAR, @vInputDate, 6) AS DateStyle6
        ,CONVERT(VARCHAR, @vInputDate, 7) AS DateStyle7
        ,CONVERT(VARCHAR, @vInputDate, 10) AS DateStyle10
        ,CONVERT(VARCHAR, @vInputDate, 11) AS DateStyle11
        ,CONVERT(VARCHAR, @vInputDate, 12) AS DateStyle12
        ,CONVERT(VARCHAR, @vInputDate, 23) AS DateStyle23
        ,CONVERT(VARCHAR, @vInputDate, 101) AS DateStyle101
        ,CONVERT(VARCHAR, @vInputDate, 102) AS DateStyle102
        ,CONVERT(VARCHAR, @vInputDate, 103) AS DateStyle103
        ,CONVERT(VARCHAR, @vInputDate, 104) AS DateStyle104
        ,CONVERT(VARCHAR, @vInputDate, 105) AS DateStyle105
        ,CONVERT(VARCHAR, @vInputDate, 106) AS DateStyle106
        ,CONVERT(VARCHAR, @vInputDate, 107) AS DateStyle107
        ,CONVERT(VARCHAR, @vInputDate, 110) AS DateStyle110
        ,CONVERT(VARCHAR, @vInputDate, 111) AS DateStyle111
        ,CONVERT(VARCHAR, @vInputDate, 112) AS DateStyle112
        -------------------------------------------------------------
        ,MONTH(@vInputDate)  AS CalendarMonth
        ,DATEPART(y, @vInputDate) AS CalendarDay
        ,YEAR(@vInputDate) AS CalendarYear
        ,DATEPART(ww, @vInputDate) AS CalendarWeek
        ,DATEPART(QUARTER,@vInputDate) AS CalendarQuarter
        ------------------------------------------------
        ,CAST(DATEADD(qq,DATEDIFF(qq, 0, @vInputDate),0) AS DATE) AS FirstDayOfQuarter
        ,CAST(DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @vInputDate) +1, 0)) AS DATE) AS LastDayOfQuarter
        -------------------------------------------------
        ,DATENAME(MONTH,@vInputDate) AS MonthLongName
        ,FORMAT(@vInputDate,'MMM') AS MonthShortName

        ,(CASE  WHEN MONTH(@vInputDate) IN (1,4,7,10) THEN 1
                WHEN MONTH(@vInputDate) IN (2,5,8,11) THEN 2
                WHEN MONTH(@vInputDate) IN (3,6,9,12) THEN 3 END) AS MonthOfQuarter

        --------------------------------------------------
        ,CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, @vInputDate), 0) AS DATE) AS FirstDayOfMonth
        ,EOMONTH(@vInputDate) AS LastDayOfMonth

        --------------------------------------------------
        ,DATEDIFF(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, @vInputDate), 0), @vInputDate) + 1 AS WeekOfMonth
        ,(DATEDIFF(dd, DATEADD(qq, DATEDIFF(qq, 0, @vInputDate), 0), @vInputDate) / 7) + 1 AS WeekOfQuarter
        --------------------------------------------------
        ,DATENAME(dw, @vInputDate) AS DayOfWeekName
        ,FORMAT(@vInputDate,'ddd') AS DayOfWeekNameShort
        ,DATEPART(dw,GETDATE()) AS DayOfWeekNumber
        ,CAST(CASE WHEN DATEPART(dw, @vInputDate) IN (2,3,4,5,6) THEN 1 ELSE 0 END AS BIT) AS IsWeekday
        ,DATEDIFF(d, DATEADD(qq, DATEDIFF(qq, 0, @vInputDate), 0), @vInputDate) + 1 AS DayOfQuarter
        ,DAY(@vInputDate) AS [DayOfMonth]
        --------------------------------------------------
        --------------------------------------------------
        --------------------------------------------------
        ,(CASE WHEN MONTH(@vInputDate) BETWEEN 10 AND 12 THEN YEAR(@vInputDate) + 1 ELSE YEAR(@vInputDate) END) AS GovtFiscalYear
        
        ,CAST(CAST(CASE WHEN MONTH(@vInputDate) BETWEEN 10 AND 12 THEN YEAR(@vInputDate) ELSE YEAR(@vInputDate) - 1 END AS VARCHAR)
                + '-10-01' AS DATE) AS GovtFiscalYearStartDate
        
        ,CAST(CAST(CASE WHEN MONTH(@vInputDate) BETWEEN 10 AND 12 THEN YEAR(@vInputDate) + 1 ELSE YEAR(@vInputDate) END AS VARCHAR)
                + '-09-30' AS DATE) AS GovtFiscalYearEndDate
        
        ,(CASE DATEPART(QUARTER,@vInputDate) WHEN 4 THEN 1 ELSE DATEPART(QUARTER,@vInputDate) + 1 END) AS GovtFiscalQuarter
        
        ,(CASE  WHEN MONTH(@vInputDate) BETWEEN 1 AND 9 THEN MONTH(@vInputDate) + 3
                        WHEN MONTH(@vInputDate) BETWEEN 10 AND 12 THEN MONTH(@vInputDate) - 9
                        END) AS GovtFiscalMonth
        ,(CASE  WHEN    YEAR(@vInputDate) % 4 <> 0 AND
                        DATEPART(y, @vInputDate) BETWEEN 1 AND 273 THEN  DATEPART(y, @vInputDate) + 92
                WHEN    YEAR(@vInputDate) % 4 <> 0 AND
                        DATEPART(y, @vInputDate) >= 274 THEN DATEPART(y, @vInputDate) - 273
                WHEN    YEAR(@vInputDate) % 4 = 0  AND
                        DATEPART(y, @vInputDate) BETWEEN 1 AND 274 THEN DATEPART(y, @vInputDate) + 92
                WHEN    YEAR(@vInputDate) % 4 = 0 AND
                        DATEPART(y, @vInputDate) >= 275 THEN DATEPART(y, @vInputDate) - 274 END) AS GovtFiscalDay
            ----------------------------------------------------------------------------------------------------
            ----------------------------------------------------------------------------------------------------
            ----------------------------------------------------------------------------------------------------
            ,(CASE  WHEN DATEPART(ISO_WEEK, @vInputDate) > 50 AND MONTH(@vInputDate) = 1 THEN YEAR(@vInputDate) - 1
                    WHEN DATEPART(ISO_WEEK, @vInputDate) = 1 AND MONTH(@vInputDate) = 12 THEN YEAR(@vInputDate) + 1
                    ELSE YEAR(@vInputDate) END) AS ISOYear
            ,DATEPART(ISO_WEEK, @vInputDate) AS ISOWeekNumber;
GO
