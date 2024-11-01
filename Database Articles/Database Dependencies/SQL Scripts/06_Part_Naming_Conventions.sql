-------------------------------------------------------
USE foo;
GO

DROP VIEW IF EXISTS dbo.vw_four_part_name_example_06;
DROP VIEW IF EXISTS dbo.vw_three_part_name_example_06;
DROP VIEW IF EXISTS dbo.vw_two_part_name_example_06;
DROP VIEW IF EXISTS dbo.vw_one_part_name_example_06;
DROP TABLE IF EXISTS dbo.tbl_example_06;
GO

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
USE foo;
GO

CREATE TABLE dbo.tbl_example_06
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE VIEW dbo.vw_one_part_name_example_06 AS
SELECT  *
FROM    tbl_example_06; --one-part
GO

CREATE VIEW dbo.vw_two_part_name_example_06 AS
SELECT  *
FROM    dbo.tbl_example_06; --two-part
GO

CREATE VIEW dbo.vw_three_part_name_example_06 AS
SELECT  *
FROM    foo.dbo.tbl_example_06; --three-part
GO

CREATE VIEW dbo.vw_four_part_name_example_06 AS
SELECT  *
FROM    [DESKTOP-D324ETP\SQLEXPRESS01].foo.dbo.tbl_example_06; --four-part
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
(database_name, example_number, referencing_object_type, referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous)
SELECT  'foo', '06', c.type AS referencing_object_type, c.name AS referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, b.type AS referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous
FROM    sys.sql_expression_dependencies a LEFT OUTER JOIN
        sys.objects b ON a.referenced_id = b.object_id LEFT OUTER JOIN
        sys.objects c ON a.referencing_id = c.object_id;
GO

-------------------------------------------------------
SELECT * FROM foo.dbo.sql_expression_dependencies ORDER BY example_number;
GO

-------------------------------------------------------
USE foo;
GO

DECLARE @vDropObjects SMALLINT = 1;
IF @vDropObjects = 1
BEGIN
     DROP VIEW IF EXISTS dbo.vw_four_part_name_example_06;
     DROP VIEW IF EXISTS dbo.vw_three_part_name_example_06;
     DROP VIEW IF EXISTS dbo.vw_two_part_name_example_06;
     DROP VIEW IF EXISTS dbo.vw_one_part_name_example_06;
     DROP TABLE IF EXISTS dbo.tbl_example_06;
END;
GO