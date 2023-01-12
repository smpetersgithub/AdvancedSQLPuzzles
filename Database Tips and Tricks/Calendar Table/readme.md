# Creating a Calendar Table

Here is a nifty trick for creating a calendar table (or in this case, a Calendar view) using a table-valued function.

We typically use table-valued functions as parameterized views. In comparison with stored procedures, the table-valued functions are more flexible as we can use them wherever tables are used.

The concept behind a Calendar table is that each entry is a date and additional columns are provided that represent complex date calculations that you would otherwise need to perform manually in your SQL statement.

## Installation

Compile the **FnReturnCalendarTable.sql** script to create the function **FnReturnCalendarTable**.  

The **FnReturnCalendarTable Example Use.sql** script gives examples on how to use the function.

The basic usage is:
 
```sql
SELECT  *
FROM    FnReturnCalendarTable(GETDATE())
```
