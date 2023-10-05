# Creating a Calendar Table

Here is a nifty trick for creating a calendar table (or in this case, a calendar view) using a table-valued function.

⌨️&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This script is written in Microsoft SQL Server T-SQL.

## Overview

We typically use table-valued functions as parameterized views. Compared with stored procedures, the table-valued functions are more flexible as we can use them wherever tables are used.

If you are unfamiliar with a calendar table, it is a type of database table that contains a record of dates and associated information, such as the day of the week, the week of the year, and whether the date is a holiday or a weekend. This table can be immensely useful for a variety of purposes, particularly in the context of reporting and data analysis.

A calendar table can also be useful for determining things like business days between two dates. By having a calendar table, it is easy to find the number of business days between two dates by simply counting the number of rows in the calendar table that have a specific status (business day) between the two given dates.

Additionally, with a calendar table in place, it's easy to generate reports that show data grouped by week, month, or quarter. This can be particularly useful in business scenarios where it's important to track trends and patterns over time.

## Installation

**Step 1:**  
Compile the `FnReturnCalendarTable.sql` script to create the function `FnReturnCalendarTable`.  

**Step 2:**  
View the `FnReturnCalendarTable Example Use.sql` script for an example that uses the table-valued function.


## Example Usage    

See the `FnReturnCalendarTable Example Use.sql` script for example usages.

The basic usage is below.

```sql
SELECT  *
FROM    FnReturnCalendarTable(GETDATE())
```

| DateKey  | CalendarDate | DateStyle1 | DateStyle2 | DateStyle3 | DateStyle4 | DateStyle5 | DateStyle6 | DateStyle7 | DateStyle10 | DateStyle11 | DateStyle12 | DateStyle23 | DateStyle101 | DateStyle102 | DateStyle103 | DateStyle104 | DateStyle105 | DateStyle106 | DateStyle107 | DateStyle110 | DateStyle111 | DateStyle112 | CalendarMonth | CalendarDay | CalendarYear | CalendarWeek | CalendarQuarter | FirstDayOfQuarter | LastDayOfQuarter | MonthLongName | MonthShortName | MonthOfQuarter | FirstDayOfMonth | LastDayOfMonth | WeekOfMonth | WeekOfQuarter | DayOfWeekName | DayOfWeekNameShort | DayOfWeekNumber | IsWeekday | DayOfQuarter | DayOfMonth | GovtFiscalYear | GovtFiscalYearStartDate | GovtFiscalYearEndDate | GovtFiscalQuarter | GovtFiscalMonth | GovtFiscalDay | ISOYear | ISOWeekNumber |
|----------|--------------|------------|------------|------------|------------|------------|------------|------------|-------------|-------------|-------------|-------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|---------------|-------------|--------------|--------------|-----------------|-------------------|------------------|---------------|----------------|----------------|-----------------|----------------|-------------|---------------|---------------|--------------------|-----------------|-----------|--------------|------------|----------------|-------------------------|-----------------------|-------------------|-----------------|---------------|---------|---------------|
| 20230206 | 2023-02-06   | 02/06/23   | 23.02.06   | 06/02/23   | 06.02.23   | 06-02-23   | 06 Feb 23  | Feb 06, 23 | 02-06-23    | 23/02/06    | 230206      | 2023-02-06  | 02/06/2023   | 2023.02.06   | 06/02/2023   | 06.02.2023   | 06-02-2023   | 06 Feb 2023  | Feb 06, 2023 | 02-06-2023   | 2023/02/06   | 20230206     | 2             | 37          | 2023         | 6            | 1               | 2023-01-01        | 2023-03-31       | February      | Feb            | 2              | 2023-02-01      | 2023-02-28     | 2           | 6             | Monday        | Mon                | 2               | 1         | 37           | 6          | 2023           | 2022-10-01              | 2023-09-30            | 2                 | 5               | 129           | 2023    | 6             |

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc., please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!

