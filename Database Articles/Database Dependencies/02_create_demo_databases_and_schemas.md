#### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependency Examples](03_database_dependencies_examples.md)
4. [Analyze Database Dependencies](04_analyze_database_dependencies.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)
   
<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Create the Databases and Schemas

Before diving into examples of each type of dependency and how they are recorded in the `sys.sql_expression_dependency` table, I’d like to first share the GitHub repository containing the scripts used for this analysis.

[📄 The corresponding scripts for this walkthrough are available here.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)


This repository includes two folders containing SQL scripts:

* SQL Scripts: Contains scripts for each example dependency.
* Additional SQL Scripts: Includes scripts to drop and recreate the `foo` and `bar` databases, terminate active sessions if needed, run scripts via SQLCMD mode, and perform analysis on the `sys.sql_expression_dependency` table.

For analysis purposes, it's often easier to drop and recreate the databases rather than removing individual objects. Since open sessions can prevent this, I've included a script to automatically terminate them. There's also a script to execute the dependency examples using SQLCMD mode.

Also included in the database drop-and-create script is the creation of a table in the `foo` database named `dbo.sql_expression_dependencies`. This table is used to help decode and analyze the contents of the `sys.sql_expression_dependency` system view.

To create the databases, along with the `dbo.sql_expression_dependencies` table, the following script can be used.

```sql
USE master;
GO

----------------------------------------
DROP TRIGGER IF EXISTS trg_example_16 ON ALL SERVER;
GO
DROP DATABASE IF EXISTS db_example_16;
GO

----------------------------------------
DROP DATABASE IF EXISTS foo;
DROP DATABASE IF EXISTS bar;
GO

----------------------------------------
CREATE DATABASE foo;
GO
CREATE DATABASE bar;
GO

----------------------------------------
USE foo;
GO

CREATE SCHEMA schemaA;
GO
CREATE SCHEMA schemaB;
GO

----------------------------------------
USE foo;
GO

DROP TABLE IF EXISTS dbo.sql_expression_dependencies;
GO

CREATE TABLE dbo.sql_expression_dependencies
(
--insertdate DATETIME NOT NULL DEFAULT GETDATE(),
--servername VARCHAR(100) NOT NULL,
example_number  VARCHAR(100) NULL,
referencing_object_type VARCHAR(100) NULL,
referencing_server_name VARCHAR(100) NULL,
referencing_database_name VARCHAR(100) NULL,
referencing_schema_name VARCHAR(100) NULL,
referencing_entity_name VARCHAR(500) NULL,
referencing_id INT NULL,
referencing_minor_id INT NULL,
referencing_class INT NULL,
referencing_class_desc VARCHAR(60) NULL,
is_schema_bound_reference INT NOT NULL,
referenced_class INT NULL,
referenced_class_desc VARCHAR(60) NULL,
referenced_server_name VARCHAR(128) NULL,
referenced_database_name VARCHAR(128) NULL,
referenced_schema_name VARCHAR(128) NULL,
referenced_entity_name VARCHAR(128) NULL,
referenced_object_type VARCHAR(100) NULL,
referenced_id INT NULL,
referenced_minor_id INT NULL,
is_caller_dependent INT NULL,
is_ambiguous INT NULL,
referencing_is_ms_shipped INT NULL,
referenced_is_ms_shipped INT NULL,
is_user_defined_data_type INT NULL,
is_self_referencing INT NULL
);
GO
```
