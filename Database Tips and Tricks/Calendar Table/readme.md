# Creating a Calendar Table

Here is a nifty trick for creating a calendar table (or in this case, a calendar view) using a **table-valued function**.

We typically use **table-valued functions** as parameterized views. In comparison with stored procedures, the table-valued functions are more flexible as we can use them wherever tables are used.

If you are unfamiliar with a calendar table, it is a type of database table that contains a record of dates and associated information, such as the day of the week, the week of the year, and whether the date is a holiday or a weekend. This table can be immensely useful for a variety of purposes, particularly in the context of reporting and data analysis.

A calendar table can also be useful for determining things like business days between two dates. By having a calendar table, it is easy to find the number of business days between two dates by simply counting the number of rows in the calendar table that have a specific status (business day) between the two given dates.

Additionally, with a calendar table in place, it's easy to generate reports that show data grouped by week, month, or quarter. This can be particularly useful in business scenarios where it's important to track trends and patterns over time.

## Installation

**Step 1**  
Compile the **FnReturnCalendarTable.sql** script to create the function **FnReturnCalendarTable**.  

**Step 2**  
View the **FnReturnCalendarTable Example Use.sql** script for example uses of the **table-valued function**.

The basic usage is:
```sql
SELECT  *
FROM    FnReturnCalendarTable(GETDATE())
```
