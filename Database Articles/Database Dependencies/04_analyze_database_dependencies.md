#### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependency Examples](03_database_dependencies_examples.md)
4. [Analyze Database Dependencies](04_analyze_database_dependencies.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)
   
<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Database Dependency Analysis

Next, we'll analyze the results stored in the `sys.sql_expression_dependencies` view, based on the examples from the previous walkthrough.

This analysis uses the `foo.dbo.sql_expression_dependencies` table—a local table within the `foo` database—that has been populated with dependency data from each example. To populate this table, please review the SQL scripts located in the GitHub repository.

[📄 The corresponding scripts for this walkthrough are available here.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

***

### Key Insights from Dependency Analysis

From our previous walkthrough—where we created each example and reviewed the `sys.sql_expression_dependency` view—there are two key takeaways:

   * **`referencing_id` and `referenced_id` are not foreign keys to `sys.objects`**\
     Some dependencies listed in `sys.sql_expression_dependency`—such as XML schemas, user-defined table types, user-defined data types, server-level triggers, and database-level triggers—do not correspond to entries in `sys.objects`. To retrieve additional details about these objects, you’ll need to join with their respective system views (e.g., `sys.xml_schema_collections`, `sys.types`, etc.).
   * **Identifying invalid dependencies is not straightforward**\
     Invalid dependencies, such as a missing table referenced by a view or stored procedure (*Example 03*), are difficult to detect reliably. This is because certain patterns, such as cross-database dependencies (*Example 01*), stored procedures that call other stored procedures using only a one-part naming convention (*Example 06*), and object aliases (*Example 11*), can mimic the same behavior as broken or missing references.

To help identify invalid dependencies, the following SQL query can be used as a starting point. However, manual review of the results is necessary to determine which objects are truly invalid.

```sql
SELECT *
FROM   sys.sql_expression_dependencies
WHERE  referenced_id IS NULL;
```

🔍 In addition to identifying invalid objects, developers often need to understand object lineage and dependency depth. These topics will be covered in the next chapter.

***

### Additional Key Insights from the Analysis

Besides the previous key insights, I have found the following most relevant to understanding the `sys.sql_expression_dependencies` table.  These are presented in no particular order.

| Topic                         | Description                                                                                              | Examples          |
| ----------------------------- | -------------------------------------------------------------------------------------------------------- | ----------------- |
| Reference_ID Uniqueness       | `object_id` is unique only within a database. Use database, schema, and object name to match across DBs. | Example 01        |
| Stored Procedure Dependencies | Caller-dependent when using one-part naming, causing a NULL `referenced_id`.                             | Example 07        |
| Impossible Dependencies       | The table can report impossible dependencies, such as a view referencing a stored procedure.             | Example 09        |
| Object Aliases                | Show as invalid dependencies with NULL `referenced_id`.                                                  | Example 11        |
| Synonyms                      | Recorded only as referenced objects, not as referencing objects.                                         | Example 13        |
| Triggers in Dependencies      | DML, database-level, and server-level triggers are all recorded.                                         | Examples 14–16    |
| Sequences                     | Linked internally to a default constraint in the dependency table.                                       | Example 20        |
| Check Constraints / Computed  | Recorded as self-referencing objects.                                                                    | Examples 23,25    |
| Self-Referencing Tables       | Self-referencing objects are: computed columns, check constraints, filtered/XML indexes, and statistics. | Examples 25,28–30 |
| XML Methods                   | `value`, `exist`, `query`, `modify` repurpose dependency fields to show XML details.                     | Example 32        |
| Ambiguous Dependencies        | `is_ambiguous = 1` does not always mean unknown objects.                                                 | Examples 05,32    |
| Missing from `sys.objects`    | Database/server triggers, UDDTs, UDTTs, XML Schemas.                                                     | Multiple          |
| Missing from dependencies     | Synonyms (referencing), partition functions, defaults/rules, contracts/queues/message types, FKs, etc.   | Multiple          |

***

### Example List

The following list can be used to reference the corresponding example numbers.

| Number | File Name                                  | NULL Referencing ID | Self-Referencing |
| ------ | ------------------------------------------ | ------------------- | ---------------- |
| 01     | Cross Database Dependencies                | Yes                 | No               |
| 02     | Cross Schema Dependencies                  | No                  | No               |
| 03     | Invalid Stored Procedures                  | Yes                 | No               |
| 04     | Numbered Stored Procedures                 | No                  | No               |
| 05     | Ambiguous References                       | No                  | No               |
| 06     | Part Naming Conventions                    | No                  | No               |
| 07     | Part Naming Conventions - Caller Dependent | Yes                 | No               |
| 08     | Dropping Objects                           | Yes                 | No               |
| 09     | Dropping Objects Then Recreating           | No                  | No               |
| 10     | Self Referencing Objects                   | No                  | Yes              |
| 11     | Object Aliases                             | Yes                 | No               |
| 12     | Schemabindings                             | No                  | No               |
| 13     | Synonyms                                   | No                  | No               |
| 14     | Triggers - DML                             | Yes                 | No               |
| 15     | Triggers - DDL Database Level              | No                  | No               |
| 16     | Triggers - DDL Server Level - Table Insert | No                  | No               |
| 17     | Partition Functions                        | Not Represented     | Not Represented  |
| 18     | Defaults and Rules                         | Not Represented     | Not Represented  |
| 19     | Contracts and Queues and Message Types     | Not Represented     | Not Represented  |
| 20     | Sequences                                  | No                  | No               |
| 21     | User-Defined Data Types                    | No                  | No               |
| 22     | User-Defined Table Types                   | No                  | No               |
| 23     | Check Constraints                          | No                  | No               |
| 24     | Foreign Key Constraints                    | Not Represented     | Not Represented  |
| 25     | Computed Columns                           | No                  | Yes              |
| 26     | Masked Functions                           | Not Represented     | Not Represented  |
| 27     | Indexes - Table                            | Not Represented     | Not Represented  |
| 28     | Indexes - Filtered NonClustered            | No                  | Yes              |
| 29     | Indexes - Filtered XML                     | No                  | Yes              |
| 30     | Statistics Filtered                        | No                  | Yes              |
| 31     | XML Schema Collections                     | No                  | No               |
| 32     | XML Methods                                | Yes                 | No               |
| 33     | Feature Installed Procedures               | No                  | No               |
| 34     | Security Policies                          | No                  | No               |


***

