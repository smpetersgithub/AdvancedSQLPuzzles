# Section 4

### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependencies Examples](03_database_dependencies_examples.md)
4. [Database Dependencies Analysis](04_database_dependencies_analysis.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)
   
<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Database Dependency Analysis

[🐙 The documentation and example scripts can be found in the GitHub repository.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

Next, we'll analyze the dependency metadata reported by the `sys.sql_expression_dependencies` catalog view, based on the examples from the previous walkthrough.

***

### Key Insights from Dependency Analysis

From our previous walkthrough—where we created each example and reviewed the `sys.sql_expression_dependencies` view—there are a few key takeaways:

   * **`referencing_id` and `referenced_id` are not foreign keys to `sys.objects`**\
     Some dependencies listed in `sys.sql_expression_dependencies`—such as XML schemas, user-defined table types, user-defined data types, server-level triggers, and database-level triggers—do not correspond to entries in `sys.objects`. To retrieve additional details about these objects, you’ll need to join with their respective system views (e.g., `sys.xml_schema_collections`, `sys.types`, etc.). 
   * **Identifying invalid dependencies is not straightforward**\
     Invalid dependencies, such as a missing table referenced by a view or stored procedure (*Example 03*), are difficult to detect reliably. This is because specific patterns, such as cross-database dependencies (*Example 01*), stored procedures that call other stored procedures using only a one-part naming convention (*Example 07*), and object aliases (*Example 11*), can mimic the same behavior as broken or missing references.
   * **Feature installed components may exist in the `sys.sql_expression_dependencies` view**\
     Certain feature-installed components—such as Database Diagrams and Change Data Capture (CDC)—create entries in the `sys.sql_expression_dependencies` view. This list is not exhaustive; other components may also do the same.

### Helpful Scripts

🔍 In addition to the following scripts, developers often need to understand object lineage and dependency depth—topics that will be covered in the next section.

To help identify invalid dependencies, the following SQL query can be used as a starting point. However, manual review of the results is necessary to determine which objects are truly invalid.

```sql
SELECT *
FROM   sys.sql_expression_dependencies
WHERE  referenced_id IS NULL;
```

Reviewing caller-dependent dependencies (*Example 07*) is always a good practice. Caller-dependent references are resolved according to the caller’s schema at runtime. This commonly occurs when a stored procedure is invoked using a one-part name, but it can also apply to extended stored procedures and non-schema-bound functions invoked through `EXECUTE`.
```sql 
SELECT * 
FROM   sys.sql_expression_dependencies
WHERE  is_caller_dependent = 1;
```

The following will identify cross-database dependencies (*Example 01*).

```sql
SELECT *
FROM sys.sql_expression_dependencies
WHERE referenced_database_name IS NOT NULL
  AND referenced_database_name <> DB_NAME();
```

This should give you a start at analyzing the `sys.sql_expression_dependencies` view.


***

### Additional Key Insights from the Analysis

Besides the previous key insights, I have found the following most relevant to understanding the `sys.sql_expression_dependencies` view.  These are presented in no particular order.

| Topic | Description | Examples |
|---|---|---|
| Object ID Scope | An `object_id` is unique only within its database. Use the database, schema, and entity names when identifying objects across databases. Cross-database and cross-server references do not have a resolved `referenced_id`. | Example 01 |
| Caller-Dependent References | Executing an object with a one-part name can defer schema resolution until runtime, resulting in `is_caller_dependent = 1` and a `NULL referenced_id`. | Example 07 |
| Incompatible Object Types | A name-based dependency can resolve to an incompatible object type, such as a view reference resolving to a stored procedure after the original table is dropped and replaced. | Example 09 |
| Object Aliases | Object aliases can produce unresolved dependency entries with a `NULL referenced_id`. | Example 11 |
| Synonyms | Synonyms can be recorded as referenced entities, but the synonym’s dependency on its underlying base object is not recorded. | Example 13 |
| Trigger Dependencies | Transact-SQL DML, database-level DDL, and server-level DDL triggers can be recorded as referencing entities. CLR triggers are not tracked. | Examples 14–16 |
| Sequences | A default constraint that uses `NEXT VALUE FOR` references the sequence. Stored procedures and other modules can also reference sequences directly. | Example 20 |
| Check Constraints | Check constraints produce dependencies on referenced table columns and, when applicable, user-defined functions. | Example 23 |
| Computed Columns | Dependencies on columns within the same table can produce rows in which `referencing_id` and `referenced_id` identify the same table. Dependencies on user-defined functions are also recorded. | Example 25 |
| Self-Referencing Table Rows | Computed columns, filtered nonclustered indexes, and filtered statistics can produce dependency rows in which `referencing_id` and `referenced_id` identify the same table. | Examples 25, 28, 30 |
| XML Methods | XML method syntax can be interpreted as an ambiguous multipart reference, causing parts of the expression to appear in the referenced-name columns. | Example 32 |
| Ambiguous Dependencies | `is_ambiguous = 1` indicates that the reference can be resolved in more than one way at runtime. It does not necessarily mean that the referenced object is missing or invalid. | Examples 05, 32 |
| Entities Outside `sys.objects` | Types, XML schema collections, database-level triggers, and server-level triggers require catalog views other than `sys.objects`. Use the class columns to determine the appropriate catalog view. | Multiple |
| Untracked Relationships | Synonyms as referencing entities, standalone defaults and rules, foreign-key relationships, and the Service Broker relationships demonstrated in Example 19 are not recorded. Queues can nevertheless appear as referenced entities. | Multiple |
| Feature-Installed Components | Some installed features, such as Database Diagrams and Change Data Capture, create dependencies in `sys.sql_expression_dependencies`, while other features do not. | Multiple |
***

### Example List

The following list can be used to reference the corresponding example numbers.

| Example | File Name                                  | NULL Referenced ID  | Self-Referencing |
|---------|--------------------------------------------|---------------------|------------------|
| 01      | Cross Database Dependencies                | Yes                 | No               |
| 02      | Cross Schema Dependencies                  | No                  | No               |
| 03      | Invalid Stored Procedures                  | Yes                 | No               |
| 04      | Numbered Stored Procedures                 | No                  | No               |
| 05      | Ambiguous References                       | No                  | No               |
| 06      | Part Naming Conventions                    | No                  | No               |
| 07      | Part Naming Conventions - Caller Dependent | Yes                 | No               |
| 08      | Dropping Objects                           | Yes                 | No               |
| 09      | Dropping Objects Then Recreating           | No                  | No               |
| 10      | Self Referencing Objects                   | No                  | Yes              |
| 11      | Object Aliases                             | Yes                 | No               |
| 12      | Schemabindings                             | No                  | No               |
| 13      | Synonyms                                   | No                  | No               |
| 14      | Triggers - DML                             | Yes                 | No               |
| 15      | Triggers - DDL Database Level              | No                  | No               |
| 16      | Triggers - DDL Server Level - Table Insert | No                  | No               |
| 17      | Partition Functions                        | No                  | No               |
| 18      | Defaults and Rules                         | Not Represented     | Not Represented  |
| 19      | Contracts and Queues and Message Types     | Not Represented     | Not Represented  |
| 20      | Sequences                                  | No                  | No               |
| 21      | User-Defined Data Types                    | No                  | No               |
| 22      | User-Defined Table Types                   | No                  | No               |
| 23      | Check Constraints                          | No                  | No               |
| 24      | Foreign Key Constraints                    | Not Represented     | Not Represented  |
| 25      | Computed Columns                           | No                  | Yes              |
| 26      | Masked Functions                           | Not Represented     | Not Represented  |
| 27      | Indexes - Table                            | Not Represented     | Not Represented  |
| 28      | Indexes - Filtered NonClustered            | No                  | Yes              |
| 29      | JSON Functions and Indexes                 | Not Represented     | Not Represented  |
| 30      | Statistics Filtered                        | No                  | Yes              |
| 31      | XML Schema Collections                     | No                  | No               |
| 32      | XML Methods                                | Yes                 | No               |
| 33      | Database Diagrams                          | No                  | No               |
| 34      | Security Policies                          | No                  | No               |
| 35      | Change Data Capture (CDC)                  | No                  | No               |
| 36      | Temporal Tables                            | Not Represented     | Not Represented  |
| 37      | Change Tracking                            | Not Represented     | Not Represented  |
| 36      | In-Memory OLTP                             | Not Represented     | Not Represented  |
| 37      | Extended Properties                        | Not Represented     | Not Represented  |
| 38      | In-Memory OLTP                             | Not Represented     | Not Represented  |
| 39      | Extended Properties                        | Not Represented     | Not Represented  |


***

