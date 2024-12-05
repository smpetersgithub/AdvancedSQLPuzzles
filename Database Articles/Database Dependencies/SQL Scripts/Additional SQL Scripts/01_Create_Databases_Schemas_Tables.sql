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
referenced_minor_id INT NOT NULL,
is_caller_dependent INT NOT NULL,
is_ambiguous INT NOT NULL
);
GO

----------------------------------------
USE foo;
GO

DROP TABLE IF EXISTS dbo.system_objects;
GO

CREATE TABLE dbo.system_objects (
table_name NVARCHAR(128) NULL,
object_id INT NOT NULL,
server_name NVARCHAR(128) NULL,
database_name NVARCHAR(128) NOT NULL,
schema_name NVARCHAR(128) NULL,
name NVARCHAR(128) NULL,
principal_id INT NULL,
schema_id INT NULL,
parent_object_id INT NULL,
type VARCHAR(200) NULL,
type_desc NVARCHAR(60) NULL,
create_date DATETIME NULL,
modify_date DATETIME NULL,
is_ms_shipped BIT NULL,
is_published BIT NULL,
is_schema_published BIT NULL,
CONSTRAINT PK_sys_objects PRIMARY KEY (object_id, database_name) WITH (IGNORE_DUP_KEY = ON)
);
