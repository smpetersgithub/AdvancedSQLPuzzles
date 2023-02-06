# Subtracting Two Dates

Anyone who has used Microsoft SQL Server T-SQL'S `DATEDIFF` function has probably been frustrated by its limitations. To solve this problem, I have created two functions (same logic, one returns a `TABLE` and the other returns a `VARCHAR`) to return the  years, months, day, minutes, seconds and nano seconds between two dates.

⌨️&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This script is written in Microsoft SQL Server T-SQL.

## Overview 

This directory contains two function, `FnDateDiffPartsChar.sql` and `FnDateDiffPartsTable.sql` to return the years, months, day, minutes, seconds and nano seconds between two dates.  One function is a table-valued function, and the other is a scalar value function.

## Installation

**Step 1:**   
Create the `FnDateDiffPartsChar` scalar valued function via the `FnDateDiffPartsChar.sql` script.

**Step 2:**  
Create the `FnDateDiffPartsTable` table-valued function via the `FnDateDiffPartsTable.sql` script.


## Example Usage

Example usage of the scalar valued function `FnDateDiffPartsChar`.

```sql
SELECT dbo.FnDateDiffPartsChar('20110619 00:00:00.0000001', '20110619 00:00:00.0000000');
SELECT dbo.FnDateDiffPartsChar('20171231', '20160101 00:00:00.0000000');
SELECT dbo.FnDateDiffPartsChar('20170518 00:00:00.0000001','20110619 00:00:00.1110000');
```
**add output here**

Example usage of the scalar valued function `FnDateDiffPartsChar`.

```sql
SELECT * FROM dbo.FnDateDiffPartsTable('20110619 00:00:00.0000001', '20110619 00:00:00.0000000');
SELECT * FROM dbo.FnDateDiffPartsTable('20171231', '20160101 00:00:00.0000000');
SELECT * FROM dbo.FnDateDiffPartsTable('20170518 00:00:00.0000001','20110619 00:00:00.1110000');
```

**add output here**

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc. please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
