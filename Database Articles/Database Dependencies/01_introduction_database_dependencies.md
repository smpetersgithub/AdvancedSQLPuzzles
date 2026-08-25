# Section 1

### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependencies Examples](03_database_dependencies_examples.md)
4. [Database Dependencies Analysis](04_database_dependencies_analysis.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)

<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Introduction to SQL Server Object Dependencies

This documentation introduces the `sys.sql_expression_dependencies` catalog view in Microsoft SQL Server. The examples demonstrate how SQL Server records dependencies, how to interpret less-obvious dependency rows, and which relationships are not represented by the catalog view.

The accompanying scripts provide reproducible examples involving tables, views, stored procedures, functions, triggers, constraints, indexes, statistics, types, XML schema collections, partition functions, and other SQL Server features. Later sections use these relationships to construct object-dependency and foreign-key paths.

[🐙 The documentation and example scripts are available in the GitHub repository.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

---

### Understanding `sys.sql_expression_dependencies`

`sys.sql_expression_dependencies` is a system catalog view that reports by-name dependencies found in persisted SQL expressions. It can help answer questions such as:

* Which entities does this object reference?
* Which entities reference this object?
* Which references are unresolved, caller-dependent, schema-bound, or ambiguous?
* Which dependency paths connect one object to another?

A dependency consists of two roles:

* The **referencing entity** contains the persisted SQL expression.
* The **referenced entity** appears by name in that expression.

For example, if a view selects from a table, the view is the referencing entity and the table is the referenced entity. The dependency direction is therefore:

`view ➡️ table`

The most important columns include `referencing_id`, `referenced_id`, the corresponding class columns, multipart-name fields, and flags such as `is_schema_bound_reference`, `is_caller_dependent`, and `is_ambiguous`.

[Review Microsoft’s `sys.sql_expression_dependencies` documentation.](https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-sql-expression-dependencies-transact-sql?view=sql-server-ver17)

> The Microsoft documentation defines the supported entity classes and column semantics. The examples in this series supplement that documentation by demonstrating edge cases and feature-specific behavior.

---

### Scope and Limitations

`sys.sql_expression_dependencies` is not a complete inventory of every possible relationship in SQL Server. It records supported by-name dependencies in persisted SQL expressions.

Important limitations include:

* Foreign-key relationships are exposed through `sys.foreign_keys` and `sys.foreign_key_columns`, not through `sys.sql_expression_dependencies`.
* Object names assembled and executed through dynamic SQL are not generally recorded as dependencies because SQL Server does not treat the contents of a runtime string as a persisted by-name reference.
* Dependency information is not created or maintained for certain entities, including temporary tables, temporary stored procedures, rules, defaults, and system objects.
* A synonym can be recorded as a referenced entity, but the synonym is not recorded as a referencing entity. The catalog view therefore does not expose the synonym-to-base-object relationship.
* Cross-database and cross-server object names can be recorded, but their `referenced_id` values are not resolved.
* Metadata visibility is limited by the permissions of the current user.

For non-schema-bound modules, the `sys.dm_sql_referenced_entities` and `sys.dm_sql_referencing_entities` dynamic management functions can provide useful supplemental information. However, these functions have their own requirements and behaviors and should not be treated as identical replacements for the catalog view.

---

### Deferred Name Resolution

Deferred name resolution allows certain SQL Server modules—most notably stored procedures—to be created even when a referenced object does not exist at creation time. The missing object name can still be recorded in `sys.sql_expression_dependencies`, but SQL Server cannot resolve its identifier. In that case, `referenced_id` is `NULL`.

If the referenced object still does not exist when the module is executed, execution fails when SQL Server attempts to resolve the name.

Deferred name resolution does not apply uniformly to every module or every type of reference. For example, views normally require referenced objects to exist when the view is created. Validation behavior can also differ depending on whether the referenced object exists and whether SQL Server can validate its columns. Therefore, deferred name resolution should not be described as a universal behavior for all database objects.

Deferred name resolution can be useful during staged deployments, but it can also allow unresolved dependencies to remain unnoticed until runtime.

---

### Schema-Bound and Non-Schema-Bound Dependencies

SQL Server distinguishes between schema-bound and non-schema-bound dependencies.

With a **schema-bound dependency**, SQL Server prevents the referenced object from being dropped or changed in a way that would invalidate the referencing entity. Schema-bound views and functions are common examples. Schema binding also requires referenced objects to be named using two-part names and to reside in the same database.

With a **non-schema-bound dependency**, SQL Server can allow the referenced object to be dropped without automatically dropping the referencing module. For example, dropping a table can leave a non-schema-bound view or stored procedure unusable until the referenced object or module definition is corrected.

This behavior is not universal. SQL Server prevents some destructive operations when another enforced relationship exists. For example, a table referenced by a foreign-key constraint cannot be dropped until the constraint or referencing table is removed. A table referenced by a schema-bound view also cannot be dropped until the schema-bound dependency is removed.

The `is_schema_bound_reference` column identifies whether a row in `sys.sql_expression_dependencies` represents a schema-bound reference.

---

### Referencing and Referenced Entities

The rows in `sys.sql_expression_dependencies` can be treated as directed edges in a dependency graph:

`referencing entity ➡️ referenced entity`

For example:

```sql
CREATE VIEW dbo.EmployeeNames
AS
SELECT EmployeeID,
       FirstName,
       LastName
FROM dbo.Employees;
GO
```

In this dependency:

* `dbo.EmployeeNames` is the referencing entity.
* `dbo.Employees` is the referenced entity.

When querying the catalog view, keep this direction in mind during self-joins, recursive queries, grouping, and path construction. Reversing these roles changes the meaning of the analysis:

* Starting with `referencing_id` finds entities on which an object depends.
* Starting with `referenced_id` finds entities that depend on an object.

---

### Interpreting Dependency IDs

`sys.sql_expression_dependencies` should not be treated as though both ID columns were ordinary foreign keys to `sys.objects`.

`referencing_id` is not nullable, but its meaning depends on `referencing_class`. A referencing entity can be an object or column, a database-level DDL trigger, or a server-level DDL trigger.

`referenced_id` can be `NULL`, and its meaning depends on `referenced_class`. A referenced entity can be an object or column, user-defined type, index, XML schema collection, or partition function.

Use the class columns to determine which catalog view should be used to resolve an ID. Examples include:

| Dependency Class | Catalog View |
| ---------------- | ------------ |
| Object or column | `sys.objects` and `sys.columns` |
| Database-level trigger | `sys.triggers` |
| Server-level trigger | `sys.server_triggers` |
| User-defined type | `sys.types` |
| Index | `sys.indexes` |
| XML schema collection | `sys.xml_schema_collections` |
| Partition function | `sys.partition_functions` |

A `NULL` `referenced_id` does not always mean the same thing. Common causes include:

* The referenced object does not exist.
* The reference is caller-dependent and is resolved at runtime.
* The reference crosses a database or server boundary.

The multipart-name columns and flags must be evaluated together with `referenced_id` to determine why the value is unresolved.

---

### Identifier Scope

An `object_id` identifies an object only within its database. The same numeric value can identify unrelated objects in different databases. Consequently, a cross-database dependency cannot be matched safely using `object_id` alone.

When analyzing dependencies across databases, use the server, database, schema, and entity-name columns as appropriate. SQL Server always returns `NULL` for `referenced_id` on cross-database and cross-server references, even when the referenced object exists.

Identifiers for other dependency classes have different scopes. Always interpret an identifier together with its referencing or referenced class rather than assuming every ID is a database-scoped `object_id`.

---

### Metadata Visibility

Catalog-view results are affected by metadata permissions. A user may see only objects the user owns or on which the user has permission. Incomplete results therefore do not necessarily mean that no additional dependencies exist.

Viewing all rows in `sys.sql_expression_dependencies` generally requires `VIEW DEFINITION` permission on the database and `SELECT` permission on the catalog view.

---

### Dependency Data as a Graph

Dependency information can be modeled as a directed graph:

* **Nodes** represent entities such as tables, views, procedures, functions, types, and triggers.
* **Edges** represent directed relationships from referencing entities to referenced entities.
* **Paths** connect entities through one or more dependency edges.
* **Cycles** occur when a path eventually returns to an entity already encountered.
* **Reachability** describes whether one entity can be reached from another by following dependency edges.

This graph model supports impact analysis in both directions. Forward traversal identifies the entities on which an object depends. Reverse traversal identifies the entities that depend on an object.

Because dependency data can contain self-references, cycles, unresolved references, and cross-database names without resolved IDs, path-building queries must account for these conditions explicitly.

---

The following sections create a demonstration environment, examine individual dependency types, analyze the resulting catalog rows, and construct dependency paths.
