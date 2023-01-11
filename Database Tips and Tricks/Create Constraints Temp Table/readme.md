# Create Constraints on a Temp Table

This script creates several constraints on a sample temporary table, #EmployeePayRecords, that are identical to the constraints on the persistent table EmployeePayRecords in the dbo schema.

The script uses the specific example table EmployeePayRecords and Schema dbo, and the user should adjust the variables @vschema_name and @vtable_name to the appropriate names of the desired table to use.

See the script "EmployeePayRecords Sample Table.sql" to create the sample data

Also, temporary tables are only available while the SQL Server instance is running, and the data is not persisted across restarts, therefore it should not be used for any type of permanent data storage or as a permanent solution.

## Installation

Step 1:  
Manually create the temp table from the persistent table using:
 
```sql
SELECT * INTO #<tablename> FROM <tablename>
```

Step 2:  
Change the variables @vschema_name and @vtable_name to the appropriate names.

----

The script creates several temporary tables to store the SQL statements that will create the different types of constraints on the temporary table.
*  #DynamicSQL
*  #PrimaryUniqueKeyConstraints
*  #NULLConstraints 
*  #CheckConstraints 
*  #ForeignPrimaryUniqueKeyConstraints

It then populates the #DynamicSQL table with a set of SQL statements generated from information in the system tables of the SQL Server instance, such as sys.tables, sys.indexes and sys.key_constraints.

The SQL statements in the #DynamicSQL table are then executed to create the NOT NULL, UNIQUE, PRIMARY KEY, and CHECK constraints on the #EmployeePayRecords temporary table, though FOREIGN KEY constraints cannot be created on temp tables.

Note, you cannot create a temp table via dynamic sql.  This is a limitation of TSQL.
