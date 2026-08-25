# Section 5

### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependencies Examples](03_database_dependencies_examples.md)
4. [Database Dependencies Analysis](04_database_dependencies_analysis.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)
   
<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Determine Object Dependency Paths

[🐙 The documentation and example scripts are available in the GitHub repository.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

[🔍 The script used to determine object dependency paths is available here.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/SQL%20Scripts/Additional%20SQL%20Scripts/05_Determine_Object_Dependency_Paths.sql)

---

This section explains how to determine dependency paths between SQL Server objects.

The script creates a collection of global temporary stored procedures that construct dependency paths beginning with a user-supplied database object. Because object dependencies can cross database boundaries, the script can analyze all databases included in a user-supplied database list.

The arrows in the output show the direction of each dependency path.

🔍 Before running the script, review the concepts described below. Because of its length, the complete script is not included in this document. Download it from the GitHub repository using the link above. Additional dependency analyses are included as addenda.

---

### Example Output

The following examples use Microsoft’s publicly available `WideWorldImporters` sample database.

The first example shows the dependency paths originating from the stored procedure `WideWorldImporters.Website.SearchForPeople`. The results identify the objects referenced directly or indirectly by the procedure.

🔍 Each object is displayed using the following label format:

`<database_name>.<schema_name>.<object_name>.<object_type>`

The object type is included as descriptive information and is not part of a standard SQL Server multipart object name.

| Path | Referenced Object Full Name | Depth | Object ID Path | Type Path |
| ---- | --------------------------- | ----: | -------------- | --------- |
| WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE ➡️ WideWorldImporters.Purchasing.Suppliers.USER_TABLE | WideWorldImporters.Purchasing.Suppliers.USER_TABLE | 1 | 910626287 ➡️ 610101214 | SQL_STORED_PROCEDURE ➡️ USER_TABLE |
| WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE ➡️ WideWorldImporters.Sales.Customers.USER_TABLE | WideWorldImporters.Sales.Customers.USER_TABLE | 1 | 910626287 ➡️ 802101898 | SQL_STORED_PROCEDURE ➡️ USER_TABLE |
| WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE ➡️ WideWorldImporters.Application.People.USER_TABLE | WideWorldImporters.Application.People.USER_TABLE | 1 | 910626287 ➡️ 1301579675 | SQL_STORED_PROCEDURE ➡️ USER_TABLE |

---

We can also trace dependencies in the opposite direction. The following example identifies the objects that depend directly or indirectly on the `WideWorldImporters.Sales.Customers` table.

In this output, the dependent object is the referencing object, while `Sales.Customers` is the referenced object.

| Path                                                                                                                                                                                           | Dependent Object Full Name                                                         | Depth | Object ID Path                       | Type Path                                                |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------|-------|--------------------------------------|----------------------------------------------------------|
| WideWorldImporters.Application.FilterCustomersBySalesTerritoryRole.SECURITY_POLICY ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                            | WideWorldImporters.Application.FilterCustomersBySalesTerritoryRole.SECURITY_POLICY | 1     | 784721848 ⬅️ 802101898               | SECURITY_POLICY ⬅️ USER_TABLE                             |
| WideWorldImporters.Integration.GetCustomerUpdates.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                        | WideWorldImporters.Integration.GetCustomerUpdates.SQL_STORED_PROCEDURE             | 1     | 1774629365 ⬅️ 802101898              | SQL_STORED_PROCEDURE ⬅️ USER_TABLE                        |
| WideWorldImporters.Integration.GetOrderUpdates.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                           | WideWorldImporters.Integration.GetOrderUpdates.SQL_STORED_PROCEDURE                | 1     | 1886629764 ⬅️ 802101898              | SQL_STORED_PROCEDURE ⬅️ USER_TABLE                        |
| WideWorldImporters.Integration.GetSaleUpdates.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                            | WideWorldImporters.Integration.GetSaleUpdates.SQL_STORED_PROCEDURE                 | 1     | 1918629878 ⬅️ 802101898              | SQL_STORED_PROCEDURE ⬅️ USER_TABLE                        |
| WideWorldImporters.Website.CalculateCustomerPrice.SQL_SCALAR_FUNCTION ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                         | WideWorldImporters.Website.CalculateCustomerPrice.SQL_SCALAR_FUNCTION              | 1     | 1310627712 ⬅️ 802101898              | SQL_SCALAR_FUNCTION ⬅️ USER_TABLE                         |
| WideWorldImporters.Website.Customers.VIEW ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                                                     | WideWorldImporters.Website.Customers.VIEW                                          | 1     | 1694629080 ⬅️ 802101898              | VIEW ⬅️ USER_TABLE                                        |
| WideWorldImporters.Website.InsertCustomerOrders.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Website.CalculateCustomerPrice.SQL_SCALAR_FUNCTION ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE | WideWorldImporters.Website.InsertCustomerOrders.SQL_STORED_PROCEDURE               | 2     | 2004202190 ⬅️ 1310627712 ⬅️ 802101898 | SQL_STORED_PROCEDURE ⬅️ SQL_SCALAR_FUNCTION ⬅️ USER_TABLE |
| WideWorldImporters.Website.InvoiceCustomerOrders.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                         | WideWorldImporters.Website.InvoiceCustomerOrders.SQL_STORED_PROCEDURE              | 1     | 1972202076 ⬅️ 802101898              | SQL_STORED_PROCEDURE ⬅️ USER_TABLE                        |
| WideWorldImporters.Website.SearchForCustomers.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                            | WideWorldImporters.Website.SearchForCustomers.SQL_STORED_PROCEDURE                 | 1     | 942626401 ⬅️ 802101898               | SQL_STORED_PROCEDURE ⬅️ USER_TABLE                        |
| WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE ⬅️ WideWorldImporters.Sales.Customers.USER_TABLE                                                                               | WideWorldImporters.Website.SearchForPeople.SQL_STORED_PROCEDURE                    | 1     | 910626287 ⬅️ 802101898               | SQL_STORED_PROCEDURE ⬅️ USER_TABLE                        |

---

### Key Details Before Running the Script

Review the following considerations before executing the script.

1. **Cross-Database Dependencies**

   The script can trace dependency paths across multiple databases, as demonstrated in *Example 01*. Supply every database that should participate in the analysis. If a referenced database is omitted, the script cannot continue tracing dependencies inside that database.

2. **Unresolved Dependencies**

   Invalid object references and certain object-alias references, as demonstrated in *Examples 03, 08, and 11*, may appear as `UNKNOWN` because SQL Server cannot resolve their `referenced_id`.

3. **Self-Referencing Objects**

   Self-referencing dependency edges, as demonstrated in *Example 10*, are excluded from path traversal to prevent infinite recursion.

4. **Synonyms**

   A synonym can be recorded as a referenced entity, but it is not recorded as a referencing entity in `sys.sql_expression_dependencies`. Consequently, the catalog view identifies the dependency on the synonym but does not provide the relationship between the synonym and its base object. The script cannot continue beyond the synonym unless that relationship is resolved separately.

5. **Caller-Dependent References**

   Caller-dependent procedure references, as demonstrated in *Example 07*, have a `NULL` `referenced_id` because their schema is resolved at runtime. The script attempts to resolve these references by object name and assumes the `dbo` schema. This is a script-specific assumption and may produce an incorrect result when the caller’s default schema is not `dbo`.

6. **Metadata Visibility**

   Results from `sys.sql_expression_dependencies` are affected by metadata permissions. A user may not see all dependency information unless the appropriate `VIEW DEFINITION` and catalog-view permissions have been granted.

---

### Global Temporary Stored Procedures

The script creates the following global temporary stored procedures. The logic is divided among several procedures to improve readability and maintainability.

The `##temp_sp_update_sql_expression_dependencies` procedure centralizes the rules used to populate `##sys_sql_expression_dependencies`, which is then used to construct the dependency paths.

```text
##temp_sp_create_tables
##temp_sp_insert_sql_statement
##temp_sp_cursor_insert_sql_expression_dependencies
##temp_sp_cursor_insert_sys_objects
##temp_sp_update_sql_expression_dependencies
##temp_sp_determine_paths
##temp_sp_determine_reverse_paths

-- Master procedures that call the supporting procedures

##temp_sp_master_execution_paths
##temp_sp_master_execution_reverse_paths
```

> Because these are global temporary stored procedures, SQL Server creates them in `tempdb`. They remain available while the session that created them is active and while another session is actively executing them.

---

### Example Execution

🔍 The following example traces dependency paths within a single database.

```sql
-- Forward dependencies: objects referenced by the procedure
EXECUTE ##temp_sp_master_execution_paths
    'WideWorldImporters.Website.SearchForPeople';
GO

-- Reverse dependencies: objects that depend on the table
EXECUTE ##temp_sp_master_execution_reverse_paths
    'WideWorldImporters.Sales.Customers';
GO
```

---

🔍 The following example traces dependency paths across multiple databases.

The second parameter contains a comma-separated list of databases that should participate in the analysis.

```sql
-- Forward dependencies
EXECUTE ##temp_sp_master_execution_paths
    'WideWorldImporters.Website.SearchForPeople',
    'WideWorldImporters,AdventureWorks';
GO

-- Reverse dependencies
EXECUTE ##temp_sp_master_execution_reverse_paths
    'WideWorldImporters.Sales.Customers',
    'WideWorldImporters,AdventureWorks';
GO
```

---

### Selecting a Dependency-Path Procedure

Select the procedure based on the direction of the analysis:

* `##temp_sp_master_execution_paths` traces forward dependencies—objects that the target object depends on.
* `##temp_sp_master_execution_reverse_paths` traces reverse dependencies—objects that depend on the target object.

Pass the target object using a three-part name:

`<database_name>.<schema_name>.<object_name>`

---

[🔍 Access the dependency-path script in the GitHub repository.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/SQL%20Scripts/Additional%20SQL%20Scripts/05_Determine_Object_Dependency_Paths.sql)


