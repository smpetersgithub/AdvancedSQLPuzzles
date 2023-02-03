# Subtracting Two Dates

In this GitHub repository I have two stored procedures (one that returns a `TABLE`, and one that returns a `VARCHAR`) that can accurately return the difference between two dates.

Anyone who has used the `DATEDIFF` has probably been frustrated by its limitations. To solve this problem, I have created two functions to subtract dates. 

Same logic, one returns a `TABLE` and the other returns a `VARCHAR`. Passing two dates to either of the functions return the years, days, months, minutes, seconds and nano seconds between the two dates.

## Installation


**Step 1:**   
Create the `FnDateDiffPartsChar` scalar valued function via the `FnDateDiffPartsChar.sql` script.

Example usage of the scalar valued function `FnDateDiffPartsChar`.

```sql
SELECT dbo.FnDateDiffPartsChar('20110619 00:00:00.0000001', '20110619 00:00:00.0000000');
SELECT dbo.FnDateDiffPartsChar('20171231', '20160101 00:00:00.0000000');
SELECT dbo.FnDateDiffPartsChar('20170518 00:00:00.0000001','20110619 00:00:00.1110000');
```
------------------------------------------------------------
**Step 2:**  
Create the `FnDateDiffPartsTable` table-valued function via the `FnDateDiffPartsTable.sql` script.

Example usage of the table valued function `FnDateDiffPartsTable`.  

```sql
SELECT * FROM dbo.FnDateDiffPartsChar('20110619 00:00:00.0000001', '20110619 00:00:00.0000000');
SELECT * FROM dbo.FnDateDiffPartsChar('20171231', '20160101 00:00:00.0000000');
SELECT * FROM dbo.FnDateDiffPartsChar('20170518 00:00:00.0000001','20110619 00:00:00.1110000');
```
