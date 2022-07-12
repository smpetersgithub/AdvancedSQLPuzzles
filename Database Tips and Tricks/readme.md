# Database Tips and Tricks

----

Here are some additional resources for finding new tips, tricks and insights that will help you in your journey. 

For documentation please read **Database Tips and Tricks.pdf**.

----

## Creating a Calendar Table
My code for creating a table valued function for generating a calendar table. Once understood, I hope you find the table valued function to be more beneficial than the usual static calendar table.

----

## Pivoting Data
If you find the pivot table syntax to be a little frustrating, here you can implement a function to parameterize the pivot syntax. Very useful if you find yourself having to write a lot of pivot statements.

----

## Data Profiling
A robust SQL script to perform data profiling on a table using dynamic sql. The script can be used to quickly find minimum and maximum values, if NULLs or empty strings appear in the data, etc… I wouldn’t recommend this script on large tables, but its simple to us; just change the table name variable in the script.

----

## Subtracting Two Dates
Anyone who has used SQL Server’s date difference functions know they are severely limiting. Here I have a couple of functions (one table valued and one scalar) that can accurately subtract two dates.

----

## Full Outer Join
Here I have a script that compares two identical tables using dynamic SQL and a FULL OUTER JOIN. The SQL is auto generated dynamically and executed, where the user simply needs to provide the table names and join criteria. Work great when auditing data migrations!

----
