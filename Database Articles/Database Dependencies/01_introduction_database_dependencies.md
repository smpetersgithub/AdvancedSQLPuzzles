# Section 1

#### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependencies Examples](03_database_dependencies_examples.md)
4. [Database Dependencies Analysis](04_database_dependencies_analysis.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)
   
<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Introduction to SQL Server Object Dependencies

The following documentation is designed to help developers understand the `sys.sql_expression_dependencies` table in Microsoft SQL Server. This repository includes an example walkthrough of various dependencies, how they interact with the `sys.sql_expression_dependencies` table, and the corresponding scripts essential for grasping this table's functionality and data representation. These scripts also serve as a comprehensive repository of dependencies, including some you may not have yet encountered or considered.

[📄 The corresponding scripts for this walkthrough are available here.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

***

### Understanding the `sys.sql_expression_dependencies` Table

The `sys.sql_expression_dependencies` view is a system catalog view that details the dependencies of SQL expressions on database objects. It helps analyze the relationships between different database objects (tables, views, procedures, functions, etc.) and assess how modifications to one object could affect others.

The `sys.sql_expression_dependencies` table is an adjacency table that shows how objects relate to each other. A dependency between two entities is created when one entity, referred to as the referenced entity, appears by name in a persisted SQL expression of another entity, known as the referencing entity. At the heart of this table are the `referencing_id` and `referenced_id` columns, along with several other columns that help describe the relationship and further details of the referenced object. These columns will become apparent once we begin working through examples.

***

**⚠️ Warning!**

The Microsoft documentation contains some inaccuracies and provides limited examples. I recommend reviewing the provided scripts for a clearer understanding of how to use this table effectively.

[The Microsoft documentation can be found here](https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-sql-expression-dependencies-transact-sql?view=sql-server-ver16).

***

### Deferred Name Resolution and Non-Strict Dependency Enforcement

Before beginning, I would like to briefly cover the concepts of deferred name resolution and non-strict dependency enforcement.

Deferred name resolution is a feature in SQL Server that allows the creation of specific database objects, even if the objects they reference, such as tables or views, do not exist at the time of creation.

When these database objects are created, SQL Server does not immediately check for the existence of the referenced objects; instead, it defers this validation until the object is executed or used. This feature facilitates the development process by allowing developers to write and compile these objects without worrying about the immediate availability of all referenced entities.

This is particularly useful in scenarios where object dependencies are created at different stages of the database deployment process. However, an error will occur if the referenced objects do not exist when the deferred name resolution object is executed.

Alternatively, there is the concept of non-strict dependency enforcement.

In SQL Server, the ability to drop an object referenced by another drop without cascading the drop is a behavior known as non-strict dependency enforcement. While a view may depend on the table, SQL Server allows you to drop the table without immediately dropping or updating the dependent view. However, this will result in the view becoming invalid. In SQL Server, the `CREATE OR ALTER` statement can be used to update an object's DDL, which otherwise could not be deployed using a `DROP` and then a `CREATE` statement separately on an object.

These concepts will come into play as we find objects referencing invalid objects and how these are represented in the `sys.sql_expression_dependencies` table. A quick internet search will provide ample documentation and examples of how deferred name resolution and non-strict dependency enforcement behave within SQL Server. It is also important to note that different vendors (such as Oracle, DB2, and PostgreSQL) have different behaviors regarding these concepts. Therefore, the behavior of SQL Server in these contexts does not necessarily apply to other database systems.

***

### Referenced and Referencing Identities

The `sys.sql_expression_dependencies` table is an adjacency list table containing `referencing_id` and `referenced_id` columns. These columns can be used to determine hierarchies and levels of depth for objects starting from a base object.

The Microsoft documentation best defines referencing versus referenced entities:

**"A dependency between two entities is created when one entity, called the referenced entity, appears by name in a persisted SQL expression of another entity, called the referencing entity."**

For example, consider a view that references a table. The view will be the referencing entity, and the table will be the referenced entity.

The `referencing_id` and `referenced_id` columns are **not** foreign keys to the `sys.objects` table.  

The table contains dependencies for database-level triggers, server-level triggers, XML schema collections, user-defined data types (UDDT), and user-defined table types (UDTT), all of which are not referenced in the `sys.objects` table.  

Also, when querying the dependency table, it is easy to misuse these columns during self-joins, grouping, and other operations. If you have trouble, please step back and ensure you understand the definition of these terms and can logically join a referenced entity to a referencing entity.

***

**⚠️ Warning!**

**The `object_id` is unique only within a single database. The same `object_id` can be used in different databases to reference different objects.**

***

Lastly, a basic understanding of graph theory will help you comprehend how the data is represented and the potential reporting capabilities. Familiarity with terms such as nodes, edges, walks, paths, and routes will be beneficial when discussing and analyzing the data. Nodes represent entities; edges indicate relationships between those entities, and walks, paths, and routes describe how entities can be connected.

***
