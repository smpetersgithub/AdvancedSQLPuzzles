# Subtracting Two Dates

In this GitHub repository I have two stored procedures (one that returns a table, and one that returns a varchar) that can accurately return the difference between two dates.

Anyone who has used the DATEDIFF has probably been frustrated by its limitations. To solve this problem, I have created two functions to subtract dates. 

Same logic, one returns a table and the other returns a varchar. Passing two dates to either of the functions return the years, days, months, minutes, seconds and nano seconds between the two dates.

## Installation

Inside this GitHub repository you will find the following SQL scripts:

FnDateDiffPartsChar.sql  
A script that creates the stored procedure FnDateDiffPartsChar

FnDateDiffPartsTable.sql  
A script that creates the stored procedure FnDateDiffPartsTable

## Usage

Example usage of the scalar valued function FnDateDiffPartsChar.  
This function is used with in the SELECT statement.

```sql
SELECT dbo.FnDateDiffPartsChar('20110619 00:00:00.0000001', '20110619 00:00:00.0000000');
SELECT dbo.FnDateDiffPartsChar('20171231', '20160101 00:00:00.0000000');
SELECT dbo.FnDateDiffPartsChar('20170518 00:00:00.0000001','20110619 00:00:00.1110000');
```
Example usage of the table valued function FnDateDiffPartsTable.  
This function is used with in the FROM statement.

```sql
SELECT * FROM dbo.FnDateDiffPartsChar('20110619 00:00:00.0000001', '20110619 00:00:00.0000000');
SELECT * FROM dbo.FnDateDiffPartsChar('20171231', '20160101 00:00:00.0000000');
SELECT * FROM dbo.FnDateDiffPartsChar('20170518 00:00:00.0000001','20110619 00:00:00.1110000');
```
