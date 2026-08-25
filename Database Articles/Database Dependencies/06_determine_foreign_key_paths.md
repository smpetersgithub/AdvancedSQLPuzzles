# Section 6

### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependencies Examples](03_database_dependencies_examples.md)
4. [Database Dependencies Analysis](04_database_dependencies_analysis.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)

<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Determine Foreign Key Paths

[🐙 The documentation and example scripts are available in the GitHub repository.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

[🔍 The script used to determine foreign-key paths is available here.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/SQL%20Scripts/Additional%20SQL%20Scripts/06_Determine_Foreign_Key_Paths.sql)

---

This section explains how to determine paths between tables connected by foreign-key constraints.

SQL Server exposes foreign-key metadata through the `sys.foreign_keys` and `sys.foreign_key_columns` catalog views. Foreign-key relationships are not recorded in `sys.sql_expression_dependencies`.

A foreign-key constraint cannot reference a table in another database. Therefore, unlike general object-dependency paths, foreign-key paths are limited to the current database. Before running the script, update its `USE` statement to select the database you want to analyze.

The script supports two directions of analysis:

* **Forward paths** move from a referencing table to the tables it references.
* **Reverse paths** move from a referenced table to the tables that reference it.

The script returns one discovered path to each reachable table. If multiple paths lead to the same table, only the first discovered path is retained.

🔍 Because of its length, the complete script is not included in this document. Download it from the GitHub repository using the link above.

---

### Forward Foreign-Key Paths

The following example begins with `Sales.Orders` in Microsoft’s publicly available `WideWorldImporters` sample database. It identifies the tables referenced directly or indirectly by `Sales.Orders`.

The arrow points from the referencing table to the referenced table:

`<referencing_table> ➡️ <referenced_table>`

For example, `Sales.Orders` contains foreign keys that reference `Application.People` and `Sales.Customers`. The traversal then continues through foreign keys defined on those referenced tables.

Tables in the output are displayed using a two-part name:

`<schema_name>.<table_name>`

| Table Name | Object Name Path | Depth | Object ID Path |
| ---------- | ---------------- | ----: | -------------- |
| Sales.Orders | Sales.Orders | 0 | 1154103152 |
| Application.People | Sales.Orders ➡️ Application.People | 1 | 1154103152 ➡️ 1301579675 |
| Sales.Customers | Sales.Orders ➡️ Sales.Customers | 1 | 1154103152 ➡️ 802101898 |
| Application.Cities | Sales.Orders ➡️ Sales.Customers ➡️ Application.Cities | 2 | 1154103152 ➡️ 802101898 ➡️ 402100473 |
| Application.DeliveryMethods | Sales.Orders ➡️ Sales.Customers ➡️ Application.DeliveryMethods | 2 | 1154103152 ➡️ 802101898 ➡️ 1573580644 |
| Sales.BuyingGroups | Sales.Orders ➡️ Sales.Customers ➡️ Sales.BuyingGroups | 2 | 1154103152 ➡️ 802101898 ➡️ 1957582012 |
| Sales.CustomerCategories | Sales.Orders ➡️ Sales.Customers ➡️ Sales.CustomerCategories | 2 | 1154103152 ➡️ 802101898 ➡️ 2053582354 |
| Application.StateProvinces | Sales.Orders ➡️ Sales.Customers ➡️ Application.Cities ➡️ Application.StateProvinces | 3 | 1154103152 ➡️ 802101898 ➡️ 402100473 ➡️ 290100074 |
| Application.Countries | Sales.Orders ➡️ Sales.Customers ➡️ Application.Cities ➡️ Application.StateProvinces ➡️ Application.Countries | 4 | 1154103152 ➡️ 802101898 ➡️ 402100473 ➡️ 290100074 ➡️ 1461580245 |

---

### Reverse Foreign-Key Paths

Reverse traversal begins with a referenced table and identifies tables that reference it directly or indirectly. The following output shows tables that have a foreign-key path to `Sales.Orders`.

The reverse-path display places each newly discovered referencing table on the left:

`<referencing_table> ⬅️ <referenced_table>`

For example, `Sales.Invoices` and `Sales.OrderLines` contain foreign keys that reference `Sales.Orders`.

| Table Name | Object Name Path | Depth | Object ID Path |
| ---------- | ---------------- | ----: | -------------- |
| Sales.Orders | Sales.Orders | 0 | 1154103152 |
| Sales.Invoices | Sales.Invoices ⬅️ Sales.Orders | 1 | 2018106230 ⬅️ 1154103152 |
| Sales.OrderLines | Sales.OrderLines ⬅️ Sales.Orders | 1 | 94623380 ⬅️ 1154103152 |
| Sales.CustomerTransactions | Sales.CustomerTransactions ⬅️ Sales.Invoices ⬅️ Sales.Orders | 2 | 366624349 ⬅️ 2018106230 ⬅️ 1154103152 |
| Sales.InvoiceLines | Sales.InvoiceLines ⬅️ Sales.Invoices ⬅️ Sales.Orders | 2 | 510624862 ⬅️ 2018106230 ⬅️ 1154103152 |
| Warehouse.StockItemTransactions | Warehouse.StockItemTransactions ⬅️ Sales.Invoices ⬅️ Sales.Orders | 2 | 638625318 ⬅️ 2018106230 ⬅️ 1154103152 |

---

### Key Details Before Running the Script

1. **Foreign-Key Direction**

   The table containing the foreign-key column is the referencing table. The table containing the candidate key is the referenced table.

2. **Database Scope**

   Foreign-key constraints cannot cross database boundaries. The script analyzes relationships in the database selected by its `USE` statement.

3. **Starting-Table Name**

   The starting table can be supplied using either of these formats:

   * `<schema_name>.<table_name>`
   * `<database_name>.<schema_name>.<table_name>`

   If a database name is supplied, it must match the current database.

4. **Cycles and Self-References**

   A foreign-key graph can contain self-references and cycles. The script visits each table only once in each direction, preventing infinite processing.

5. **Multiple Paths**

   Multiple foreign-key paths can lead to the same table. This script retains one discovered path per table rather than returning every possible path.

6. **Composite Foreign Keys**

   `sys.foreign_key_columns` returns one row for each column in a foreign-key constraint. The script creates a separate table-level map for traversal so that composite foreign keys do not create duplicate paths.

7. **Metadata Visibility**

   Catalog-view results are affected by metadata permissions. A user may not see every foreign-key relationship unless the user owns the associated objects or has permission to view their metadata.

---

### Global Temporary Objects

The script creates the following global temporary stored procedures:

```text
##temp_create_tables
##temp_sp_determine_foreign_key_paths
##temp_sp_determine_foreign_key_paths_reverse

-- Master procedures that call the supporting procedures

##temp_sp_master_execution_foreign_key_paths
##temp_sp_master_execution_foreign_key_reverse_paths
```

The script also creates these global temporary tables:

```text
##foreign_key_paths
##foreign_key_reverse_paths
##foreign_keys_map
##foreign_key_table_map
```

`##foreign_keys_map` contains column-level details for each foreign-key constraint. `##foreign_key_table_map` contains distinct table-to-table relationships and is used to construct the paths.

> SQL Server creates global temporary procedures and tables in `tempdb`. Their names are visible to other sessions, so simultaneous executions can interfere with each other. They remain available while the session that created them is active and, where applicable, while another session is actively using them.

---

### Usage Notes

First, change the script’s `USE` statement to the database you want to analyze. Run the complete script to create the global temporary procedures, and then execute the appropriate master procedure.

Performance depends on the number of foreign keys, the number of reachable tables, and the structure of the foreign-key graph. Review the execution plan and temporary-table indexes when analyzing large or highly connected schemas.

### Example Execution

Use the following procedure to trace forward foreign-key paths—tables referenced directly or indirectly by `Sales.Orders`:

```sql
EXECUTE ##temp_sp_master_execution_foreign_key_paths
    N'Sales.Orders';
GO
```

Use the following procedure to trace reverse foreign-key paths—tables that reference `Sales.Orders` directly or indirectly:

```sql
EXECUTE ##temp_sp_master_execution_foreign_key_reverse_paths
    N'Sales.Orders';
GO
```

The matching three-part name can also be used:

```sql
EXECUTE ##temp_sp_master_execution_foreign_key_paths
    N'WideWorldImporters.Sales.Orders';
GO
```

To view the column-level foreign-key mappings collected by the most recent execution, run:

```sql
SELECT  foreign_key_name,
        referencing_schema,
        referencing_table,
        referencing_column,
        referenced_schema,
        referenced_table,
        referenced_column,
        is_disabled,
        is_not_trusted
FROM ##foreign_keys_map
ORDER BY referencing_schema,
         referencing_table,
         foreign_key_name,
         constraint_column_id;
GO
```

---

### Selecting a Foreign-Key Path Procedure

Select the procedure based on the direction of analysis:

* `##temp_sp_master_execution_foreign_key_paths` traces forward paths from referencing tables to referenced tables.
* `##temp_sp_master_execution_foreign_key_reverse_paths` traces reverse paths from referenced tables to referencing tables.

---

[🔍 Access the foreign-key path script in the GitHub repository.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/SQL%20Scripts/Additional%20SQL%20Scripts/06_Determine_Foreign_Key_Paths.sql)
