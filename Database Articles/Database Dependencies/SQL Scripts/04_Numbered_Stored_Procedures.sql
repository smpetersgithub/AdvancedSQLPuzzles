---------------------------------------------
USE foo;
GO

DROP TABLE IF EXISTS dbo.tbl_example_04_a;
DROP TABLE IF EXISTS dbo.tbl_example_04_b;
DROP PROCEDURE IF EXISTS dbo.sp_example_04;
GO

---------------------------------------------
---------------------------------------------
---------------------------------------------
USE foo;
GO

CREATE TABLE dbo.tbl_example_04_a
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE TABLE dbo.tbl_example_04_b
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE PROCEDURE dbo.sp_example_04;1 AS
BEGIN
     SELECT  *
     FROM    dbo.tbl_example_04_a;
END;
GO

CREATE PROCEDURE dbo.sp_example_04;2 AS
BEGIN
     SELECT  *
     FROM    dbo.tbl_example_04_b;
END;
GO

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
USE foo;
GO

DECLARE @vTruncate SMALLINT = 1;
IF @vTruncate = 1
BEGIN
     TRUNCATE TABLE foo.dbo.sql_expression_dependencies;
END;
GO

-------------------------------------------------------
USE foo;
GO

INSERT INTO foo.dbo.sql_expression_dependencies
(example_number, referencing_object_type, referencing_server_name, referencing_database_name, referencing_schema_name, referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous, referencing_is_ms_shipped, referenced_is_ms_shipped, is_self_referencing)
SELECT  '04', c.type, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(c.schema_id), c.name, a.referencing_id, a.referencing_minor_id, a.referencing_class, a.referencing_class_desc, a.is_schema_bound_reference, a.referenced_class, a.referenced_class_desc, a.referenced_server_name, a.referenced_database_name, a.referenced_schema_name, a.referenced_entity_name, b.type, a.referenced_id, a.referenced_minor_id, a.is_caller_dependent, a.is_ambiguous, c.is_ms_shipped, b.is_ms_shipped, CASE WHEN a.referencing_id = a.referenced_id THEN 1 ELSE 0 END
FROM    sys.sql_expression_dependencies a LEFT OUTER JOIN
        sys.objects b ON a.referenced_id = b.object_id LEFT OUTER JOIN
        sys.objects c ON a.referencing_id = c.object_id;
GO

-------------------------------------------------------
SELECT * FROM foo.dbo.sql_expression_dependencies ORDER BY example_number;
GO

---------------------------------------------
USE foo;
GO

DECLARE @vDropObjects SMALLINT = 1;
IF @vDropObjects = 1
BEGIN
     DROP TABLE IF EXISTS dbo.tbl_example_04_a;
     DROP TABLE IF EXISTS dbo.tbl_example_04_b;
     DROP PROCEDURE IF EXISTS dbo.sp_example_04;
END;
GO