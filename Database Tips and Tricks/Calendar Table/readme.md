# Creating a Calendar Table

Here is a nifty trick for creating a calendar table (or in this case, a Calendar view) using a table-valued function.

We typically use table-valued functions as parameterized views. In comparison with stored procedures, the table-valued functions are more flexible as we can use them wherever tables are used.

## Installation

Compile the **FnReturnCalendarTable.sql** script to create the function **FnReturnCalendarTable**.  

The **FnReturnCalendarTable Example Use.sql** script gives examples on how to use the function.

The basic usage is:
 
```sql
SELECT  *
FROM    FnReturnCalendarTable(GETDATE())
```
