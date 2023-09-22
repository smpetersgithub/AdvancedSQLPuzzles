# Subtracting Two Dates

Anyone who has used Microsoft SQL Server T-SQL's `DATEDIFF` function has probably been frustrated by its limitations. To solve this problem, I have created two functions (same logic, one returns a `TABLE` and the other returns a `VARCHAR`) to return the years, months, day, minutes, seconds, and nanoseconds between two dates.

⌨️&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This script is written in Microsoft SQL Server T-SQL.

## Overview 

This directory contains two functions, `FnDateDiffPartsChar.sql` and `FnDateDiffPartsTable.sql` to return the years, months, day, minutes, seconds, and nanoseconds between two dates.  One function is a table-valued function, and the other is a scalar value function.

## Installation

**Step 1:**   
Create the `FnDateDiffPartsChar` scalar-valued function via the `FnDateDiffPartsChar.sql` script.

**Step 2:**  
Create the `FnDateDiffPartsTable` table-valued function via the `FnDateDiffPartsTable.sql` script.


## Example Usage

Example usage of the scalar-valued function `FnDateDiffPartsChar`.

```sql
SELECT dbo.FnDateDiffPartsChar('20110619 00:00:00.0000001', '20110619 00:00:00.0000000') AS DateDifference
UNION
SELECT dbo.FnDateDiffPartsChar('20171231', '20160101 00:00:00.0000000')
UNION
SELECT dbo.FnDateDiffPartsChar('20170518 00:00:00.0000001','20110619 00:00:00.1110000');
```

|          DateDifference           |
|-----------------------------------|
| 100n                              |
| 1y 11m 30d 0h 0m 0s 0n            |
| 5y 10m 28d 23h 59m 59s 889000100n |

Example usage of the scalar-valued function `FnDateDiffPartsChar`.

```sql
SELECT * FROM dbo.FnDateDiffPartsTable('20110619 00:00:00.0000001', '20110619 00:00:00.0000000');
SELECT * FROM dbo.FnDateDiffPartsTable('20171231', '20160101 00:00:00.0000000');
SELECT * FROM dbo.FnDateDiffPartsTable('20170518 00:00:00.0000001','20110619 00:00:00.1110000');
```

| YearDifference | MonthDifference | DayDifference | HourDifference | MinuteDifference | SecondDifference | NanoDifference |
|----------------|-----------------|---------------|----------------|------------------|------------------|----------------|
|              0 |               0 |             0 |              0 |                0 |                0 |            100 |
|              1 |              11 |            30 |              0 |                0 |                0 |              0 |
|              5 |              10 |            28 |             23 |               59 |               59 |      889000100 |

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc. please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
