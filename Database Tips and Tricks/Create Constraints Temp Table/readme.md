# Create Constraints on a Temp Table

Often, I find myself in an environment where I have permission to create a temporary table, but not a persistent table.  To properly test any `UPDATE`, `INSERT`, `DELETE`, or `MERGE` statements on a table, I use this script to create a temporary table with the same constraints as the persistent table.  This way, I can check my SQL statements to ensure no constraints are violated.

⌨️&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This script is written in Microsoft SQL Server T-SQL.

## Overview

The script `Create Constraints Temp Table.sql` creates the constraints on a temporary table with the same constraints as the persistent table.  In the test script `EmployeePayRecords Sample Table.sql`, I create a temporary table `#EmployeePayRecords` with identical constraints to its matching persistent table.  The user should adjust the variables `@vschema_name` and `@vtable_name` to the appropriate names of the desired table to use.

The `EmployeePayRecords Sample Table.sql` script creates several temporary tables to store the SQL statements that will create the different types of constraints on the temporary table.
*  `#DynamicSQL`
*  `#PrimaryUniqueKeyConstraints`
*  `#NULLConstraints` 
*  `#CheckConstraints`
*  `#ForeignPrimaryUniqueKeyConstraints`

It populates the `#DynamicSQL` table with a set of SQL statements generated from information in the system tables of the SQL Server instance, such as `sys.tables`, `sys.indexes`, and `sys.key_constraints`.

The SQL statements in the `#DynamicSQL` table are then executed to create the `NOT NULL`, `UNIQUE`, `PRIMARY KEY`, and `CHECK CONSTRAINTS` on the temporary table. 

:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Creating FOREIGN KEY constraints is not possible on temporary tables, and temporary tables cannot be created using dynamic SQL.

## Installation

**To run this on a sample table:**    

**Step 1:**     
Create the `EmployeesRecords` sample table via the `EmployeePayRecords Sample Table.sql` script.  
This will create the permanent table `EmployeePayRecords` with `NOT NULL`, `UNIQUE`, `PRIMARY KEY`, and `CHECK CONSTRAINTS`.  

**Step 2**   
Run the script `Create Constraints Temp Table.sql` to create a temporary table with the same constraints on `EmployeeRecords`;

**Step 3**    
Test your `INSERT`, `UPDATE`, `DELETE`, `MERGE`, etc. statements on the temporary table.

--------------------------------------------

**To run on a user-defined table:**   

**Step 1:**  
Manually create the temp table from the persistent table using:
 
```sql
SELECT * INTO #<tablename> FROM <tablename>
```

**Step 2:**  
Within the 'Create Constraints Temp Table.sql' script, modify the variables `@vschema_name` and `@vtable_name` to the appropriate names.
 
```sql
DECLARE @vschema_name VARCHAR(100) = 'dbo';
DECLARE @vtable_name VARCHAR(100) = 'EmployeePayRecords';
```

**Step 3:**  
Execute the script.

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc. please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
