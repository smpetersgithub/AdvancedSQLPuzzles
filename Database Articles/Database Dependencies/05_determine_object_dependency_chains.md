<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Object Dependency Chain Analysis Script
With an understanding of the sys.sql_expression_dependencies table, we can generate dependency chains to trace how objects relate to one another, determine their depth, and follow their paths back to root nodes.
This script automates the process by creating a series of temporary stored procedures. Once created, you can analyze dependencies by passing in a set of databases and an object name. Because objects may span multiple databases, the script is designed to trace dependencies across all databases you provide.

👍 The corresponding scripts for this walkthrough, along with this documentation, are available in the following GitHub repository:    
[📂 AdvancedSQLPuzzles → Database Dependencies](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

----

### Example Output

To understand the script’s purpose, consider the following example of its output. 

For these examples, I use Microsoft's `WorldWideImporters` database, which can be found online.

Note, the objects are labeled using a four-part naming convention:  <servername>.<schema>.<object_name>.<object_type>

Example dependency chain for the stored procedure, `WideWorldImporters.Website.SearchForPeople`

| ID | Path                                                                                                                   | Referenced Object Fullname                           | Referenced Type Desc | Depth |
|----|------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------|----------------------|-------|
| 1  | WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE ➡️ WideWorldImporters.Application.People.USER_TABLE   | WideWorldImporters.Application.People.USER_TABLE     | USER_TABLE            | 1    |
| 2  | WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE ➡️ WideWorldImporters.Purchasing.Suppliers.USER_TABLE | WideWorldImporters.Purchasing.Suppliers.USER_TABLE   | USER_TABLE            | 1    |
| 3  | WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE ➡️ WideWorldImporters.Sales.Customers.USER_TABLE      | WideWorldImporters.Sales.Customers.USER_TABLE        | USER_TABLE            | 1    |


We can also determine reverse dependencies.  In this example, we determine all objects that depend on the table `Customers`.

| id  | path                                                                                                                                                                                           | Referencing Object Fullname                                                        | depth |
|-----|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|-------|
| 1   | WideWorldImporters.Application.FilterCustomersBySalesTerritoryRole.SECURITY_POLICY ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                            | WideWorldImporters.Application.FilterCustomersBySalesTerritoryRole.SECURITY_POLICY | 1     |
| 2   | WideWorldImporters.Integration.GetCustomerUpdates.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                        | WideWorldImporters.Integration.GetCustomerUpdates.SQL_STORED_PROCEDURE             | 1     |
| 3   | WideWorldImporters.Integration.GetOrderUpdates.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                           | WideWorldImporters.Integration.GetOrderUpdates.SQL_STORED_PROCEDURE                | 1     |
| 4   | WideWorldImporters.Integration.GetSaleUpdates.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                            | WideWorldImporters.Integration.GetSaleUpdates.SQL_STORED_PROCEDURE                 | 1     |
| 5   | WideWorldImporters.Website.CalculateCustomerPrice.SQL_SCALAR_FUNCTION ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                         | WideWorldImporters.Website.CalculateCustomerPrice.SQL_SCALAR_FUNCTION              | 1     |
| 6   | WideWorldImporters.Website.Customers.VIEW ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                                                     | WideWorldImporters.Website.Customers.VIEW                                          | 1     |
| 7   | WideWorldImporters.Website.InsertCustomerOrders.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Website.CalculateCustomerPrice.SQL_SCALAR_FUNCTION ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE | WideWorldImporters.Website.InsertCustomerOrders.SQL_STORED_PROCEDURE               | 2     |
| 8   | WideWorldImporters.Website.InvoiceCustomerOrders.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                         | WideWorldImporters.Website.InvoiceCustomerOrders.SQL_STORED_PROCEDURE              | 1     |
| 9   | WideWorldImporters.Website.SearchForCustomers.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                            | WideWorldImporters.Website.SearchForCustomers.SQL_STORED_PROCEDURE                 | 1     |
| 10  | WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                               | WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE                    | 1     |


### Key Details Before Running the Script
1. Cross-Database Dependencies    
The script can trace dependencies across multiple databases. Pass the list of databases as parameters to capture the full chain.

2. Unknown Dependencies    
Objects with a NULL referencing_id in sys.sql_expression_dependencies are not resolved by the script. These are typically stored procedures that reference other procedures using a one-part naming convention. Such objects are labeled as UNKNOWN.
⚠️ Recommendation: Identify and update stored procedures to use two-part naming conventions.

3. Self-Referencing Objects    
Self-referencing objects are removed to prevent infinite loops. They are stored in the table ##self-referencing_objects if you need to review them.

-----

### Temporary Stored Procedures Created

The script generates the following temporary stored procedures:

`##temp_sp_create_tables @v_database`
`##temp_sp_insert_sql_statement`
`##temp_sp_cursor_insert_sql_expression_dependencies`
`##temp_sp_cursor_insert_sys_objects`
`##temp_sp_update_sql_expression_dependencies`
`##temp_sp_determine_paths`
`##temp_sp_determine_reverse_paths`

These must be executed in the same session in which they are created. Although they are global temporary procedures, running them in a new session will result in an error (to be documented).

----

### Usage Notes

Database Parameter Format
When passing the database list, ensure the format is correct for dynamic SQL:

```sql
DECLARE @v_database VARCHAR(100) = '''foo'''
PRINT('Ensure this string is correct: ' + @v_database);
```sql

Running Dependency Analysis
Choose one of the following procedures depending on the direction of analysis:

`##temp_sp_determine_paths` determines all objects that the provided object references.
`##temp_sp_determine_reverse_paths` determines all objects that depend on the provided object
```


Output Format
The script uses non-Unicode output by default. You may adjust this or modify any part of the code to fit your needs.

----

#### Current Limitation

The script determines dependencies for a single object at a time, not all objects in a database. Running dependency chains across all objects is computationally intensive and may take hours.
If you need a full dependency list for an entire database, consider modifying ##temp_sp_determine_paths to:
1.	Retrieve all objects in the database.
2.	Loop through each object, determining each chain independently.
3.	

