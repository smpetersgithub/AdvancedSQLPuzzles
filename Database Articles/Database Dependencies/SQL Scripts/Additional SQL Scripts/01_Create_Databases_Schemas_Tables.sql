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
is_ambiguous INT NOT NULL,
referencing_is_ms_shipped INT NULL,
referenced_is_ms_shipped INT NULL,
is_user_defined_data_type INT NULL,
is_self_referencing INT NOT NULL
);
GO