# Create Constraints on a Temp Table

Often I find myself in an environment where I have permissions to create a temporary table, but not a persistant table.  In order to properly test any `UPDATE`, `INSERT`, `DELETE` or `MERGE` statements on a table, I use this script to create a temporary table with the same constraints as the persistant table.  This way I can check my SQL statements to ensure no constraints are violated.

Currently this script creates several constraints on a sample temporary table, `#EmployeePayRecords`, that are identical to the constraints on the persistent table `EmployeePayRecords` in the `dbo` schema.  The user should adjust the variables `@vschema_name` and `@vtable_name` to the appropriate names of the desired table to use.

See the script `EmployeePayRecords Sample Table.sql` to create the sample data

Also, temporary tables are only available while the SQL Server instance is running, and the data is not persisted across restarts, therefore it should not be used for any type of permanent data storage or as a permanent solution.

## Overview   
The script creates several temporary tables to store the SQL statements that will create the different types of constraints on the temporary table.
*  `#DynamicSQL`
*  `#PrimaryUniqueKeyConstraints`
*  `#NULLConstraints` 
*  `#CheckConstraints`
*  `#ForeignPrimaryUniqueKeyConstraints`

It populates the `#DynamicSQL` table with a set of SQL statements generated from information in the system tables of the SQL Server instance, such as `sys.tables`, `sys.indexes` and `sys.key_constraints`.

The SQL statements in the `#DynamicSQL` table are then executed to create the `NOT NULL`, `UNIQUE`, `PRIMARY KEY`, and `CHECK CONSTRAINTS` on the temporary table. 

Note, `FOREIGN KEY` constraints cannot be created on temp tables.  And you cannot create a temp table via dynamic sql.  This is a limitation of TSQL.

## Installation

**Step 1:**  
Manually create the temp table from the persistent table using:
 
```sql
SELECT * INTO #<tablename> FROM <tablename>
```

**Step 2:**  
Modify the variables `@vschema_name` and `@vtable_name` to the appropriate names.
 
```sql
DECLARE @vschema_name VARCHAR(100) = 'dbo';
DECLARE @vtable_name VARCHAR(100) = 'EmployeePayRecords';
```

**Step 3:**  
Execute the script.
