# Section 2

### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependencies Examples](03_database_dependencies_examples.md)
4. [Database Dependencies Analysis](04_database_dependencies_analysis.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)

<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Create the Demo Databases and Schemas

[🐙 The documentation and example scripts are available in the GitHub repository.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

[🔍 The script used to create the demonstration databases and schemas is available here.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/SQL%20Scripts/Additional%20SQL%20Scripts/02_Create_Demo_Databases_and_Schemas.sql)

---

The GitHub repository contains two SQL script folders:

* **SQL Scripts** contains the scripts for the individual dependency examples.
* **Additional SQL Scripts** contains supporting scripts used to create or reset the demonstration environment, execute examples in SQLCMD mode, and analyze the contents of `sys.sql_expression_dependencies`.

For repeatable testing, it is often easier to recreate the demonstration databases than to remove every object individually. The setup script creates the `foo` and `bar` databases and the `schemaA` and `schemaB` schemas. It also removes objects from earlier executions that could interfere with database creation.

> **Warning:** The following script permanently drops the `foo`, `bar`, and `db_example_16` databases if they exist. It also disconnects active sessions from those databases and rolls back their open transactions. Run it only in a disposable development or test environment.

---

### Analysis Table

The setup script creates the user table `foo.dbo.sql_expression_dependencies`. This table stores dependency rows collected and enriched by the analysis scripts.

Despite its similar name, `dbo.sql_expression_dependencies` is not the SQL Server catalog view. The system catalog view is named `sys.sql_expression_dependencies`. The custom table contains additional fields, including object-type descriptions, metadata flags, and a self-reference indicator.

The custom table is used throughout the examples to consolidate dependency information into a consistent format for analysis and reporting.

---

### Create the Demonstration Environment

Run the following script from a connection with sufficient permission to create and drop databases and server-level triggers.

```sql
USE master;
GO

/*
Remove server-level DDL triggers created by Example 16. These triggers must
be removed before CREATE DATABASE is executed because an earlier trigger
definition may reference an object in the database being recreated.
*/
DROP TRIGGER IF EXISTS trg_example_16 ON ALL SERVER;
DROP TRIGGER IF EXISTS trg_example_16_b ON ALL SERVER;
GO

/* Drop the database created by Example 16. */
IF DB_ID(N'db_example_16') IS NOT NULL
BEGIN
    ALTER DATABASE db_example_16
        SET SINGLE_USER
        WITH ROLLBACK IMMEDIATE;

    DROP DATABASE db_example_16;
END;
GO

/* Drop and recreate the primary demonstration databases. */
IF DB_ID(N'foo') IS NOT NULL
BEGIN
    ALTER DATABASE foo
        SET SINGLE_USER
        WITH ROLLBACK IMMEDIATE;

    DROP DATABASE foo;
END;
GO

IF DB_ID(N'bar') IS NOT NULL
BEGIN
    ALTER DATABASE bar
        SET SINGLE_USER
        WITH ROLLBACK IMMEDIATE;

    DROP DATABASE bar;
END;
GO

CREATE DATABASE foo;
GO

CREATE DATABASE bar;
GO

/* Create the schemas used by the dependency examples. */
USE foo;
GO

CREATE SCHEMA schemaA;
GO

CREATE SCHEMA schemaB;
GO

/* Create the custom dependency-analysis table. */
CREATE TABLE dbo.sql_expression_dependencies
(
    example_number                   VARCHAR(3)    NULL,
    referencing_object_type          VARCHAR(100)  NULL,
    referencing_server_name          SYSNAME       NULL,
    referencing_database_name        SYSNAME       NULL,
    referencing_schema_name          SYSNAME       NULL,
    referencing_entity_name          SYSNAME       NULL,
    referencing_id                   INT           NULL,
    referencing_minor_id             INT           NULL,
    referencing_class                TINYINT       NULL,
    referencing_class_desc           NVARCHAR(60)  NULL,
    is_schema_bound_reference         BIT           NOT NULL,
    referenced_class                 TINYINT       NULL,
    referenced_class_desc            NVARCHAR(60)  NULL,
    referenced_server_name           SYSNAME       NULL,
    referenced_database_name         SYSNAME       NULL,
    referenced_schema_name           SYSNAME       NULL,
    referenced_entity_name           SYSNAME       NULL,
    referenced_object_type           VARCHAR(100)  NULL,
    referenced_id                    INT           NULL,
    referenced_minor_id              INT           NULL,
    is_caller_dependent              BIT           NULL,
    is_ambiguous                     BIT           NULL,
    referencing_is_ms_shipped        BIT           NULL,
    referenced_is_ms_shipped         BIT           NULL,
    is_user_defined_data_type         BIT           NULL,
    is_self_referencing              BIT           NULL
);
GO
```

---

### What the Script Creates

After the script finishes successfully, the following objects are available:

| Database | Object | Purpose |
| -------- | ------ | ------- |
| `foo` | Database | Contains most dependency examples and the consolidated analysis table. |
| `bar` | Database | Supports cross-database dependency examples. |
| `foo.schemaA` | Schema | Supports cross-schema and multipart-name examples. |
| `foo.schemaB` | Schema | Supports cross-schema and multipart-name examples. |
| `foo.dbo.sql_expression_dependencies` | User table | Stores dependency rows collected and enriched by the analysis scripts. |

The script removes `db_example_16` but does not recreate it. Example 16 creates that database when demonstrating server-level DDL trigger dependencies.

---

### Verify the Environment

Use the following queries to confirm that the databases, schemas, and analysis table were created:

```sql
SELECT name
FROM sys.databases
WHERE name IN (N'foo', N'bar');
GO

USE foo;
GO

SELECT name
FROM sys.schemas
WHERE name IN (N'schemaA', N'schemaB');
GO

SELECT  SCHEMA_NAME(schema_id) AS schema_name,
        name AS table_name
FROM sys.tables
WHERE object_id = OBJECT_ID(N'dbo.sql_expression_dependencies');
GO
```

---

### SQLCMD Mode

SQL Server Management Studio’s SQLCMD mode can execute a sequence of script files by using commands such as `:r`. This is useful when the dependency examples are stored in separate files and must be executed in a specific order.

SQLCMD mode is not enabled automatically in a standard SSMS query window. Enable it from **Query → SQLCMD Mode** before running a script that contains SQLCMD commands.

---

[🔍 Access the demonstration database and schema setup script in the GitHub repository.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/SQL%20Scripts/Additional%20SQL%20Scripts/02_Create_Demo_Databases_and_Schemas.sql)
