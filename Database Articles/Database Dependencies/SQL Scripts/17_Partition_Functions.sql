---------------------------------------------
USE foo;
GO

DROP TABLE IF EXISTS dbo.tbl_example_17;
GO

-- drop scheme
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'ps_example_17')
BEGIN
     DROP PARTITION SCHEME ps_example_17;
END;
GO

-- drop function
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'pf_example_17')
BEGIN
     DROP PARTITION FUNCTION pf_example_17;
END;
GO

---------------------------------------------
USE foo;
GO

-- add filegroups to your database

-- fg1
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'fg1')
BEGIN
    ALTER DATABASE foo ADD FILEGROUP fg1;
END;
GO

-- fg2
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'fg2')
BEGIN
    ALTER DATABASE foo ADD FILEGROUP fg2;
END;
GO

-- fg3
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'fg3')
BEGIN
    ALTER DATABASE foo ADD FILEGROUP fg3;
END;
GO

-- fg4
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'fg4')
BEGIN
    ALTER DATABASE foo ADD FILEGROUP fg4;
END;
GO

-- add a file to the fg4 file group
ALTER DATABASE foo
ADD FILE 
(
    NAME = 'foo_fg4_data',
    FILENAME = 'C:\data\foo_fg4_data.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP fg4;
GO

---------------------------------------------
-- create a partition function
CREATE PARTITION FUNCTION pf_example_17 (DATE) AS 
RANGE LEFT FOR VALUES ('2020-12-31', '2021-12-31', '2022-12-31');
GO

---------------------------------------------
-- create a partition scheme
CREATE PARTITION SCHEME ps_example_17 AS 
PARTITION pf_example_17 TO (fg1, fg2, fg3, fg4);
GO

---------------------------------------------
-- create a table using a partition scheme
CREATE TABLE dbo.tbl_example_17
(
OrderID INT,
OrderDate DATE,
ProductID INT,
Quantity INT,
UnitPrice MONEY,
CONSTRAINT PK_tbl_example_17 PRIMARY KEY (OrderID, OrderDate)
)
ON ps_example_17(OrderDate);
GO

INSERT INTO dbo.tbl_example_17 VALUES (1, '2024-10-10', 3, 4, 5);
GO

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
USE foo;
GO

DECLARE @vTruncate SMALLINT = 0;
IF @vTruncate = 1
BEGIN
     TRUNCATE TABLE foo.dbo.sql_expression_dependencies;
END;
GO

-------------------------------------------------------
USE foo;
GO

INSERT INTO foo.dbo.sql_expression_dependencies
(example_number, referencing_object_type, referencing_server_name, referencing_database_name, referencing_schema_name, referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous)
SELECT  '17', COALESCE(c.type, d.type, e.type) AS referencing_object_type, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(c.schema_id), COALESCE(c.name, d.name, e.name) AS referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, b.type AS referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous
FROM    sys.sql_expression_dependencies a LEFT OUTER JOIN
        sys.objects b ON a.referenced_id = b.object_id LEFT OUTER JOIN
        sys.objects c ON a.referencing_id = c.object_id LEFT OUTER JOIN
        sys.triggers d ON a.referencing_id = d.object_id LEFT OUTER JOIN
        sys.server_triggers e ON a.referencing_id = e.object_id;
GO

INSERT INTO foo.dbo.system_objects (table_name, object_id, server_name, database_name, schema_name, name, principal_id, schema_id, parent_object_id, type, type_desc, create_date, modify_date, is_ms_shipped, is_published, is_schema_published) 
SELECT 'sys.objects', object_id, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(schema_id), name, principal_id, schema_id, parent_object_id, type, type_desc, create_date, modify_date, is_ms_shipped, is_published, is_schema_published 
FROM   sys.objects
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
     DROP TABLE IF EXISTS dbo.tbl_example_17;
END;
GO

-- drop scheme
DECLARE @vDropObjects SMALLINT = 1;
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'ps_example_17') AND @vDropObjects = 1
BEGIN
     DROP PARTITION SCHEME ps_example_17;
END;
GO

-- drop function
DECLARE @vDropObjects SMALLINT = 1;
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'pf_example_17') AND @vDropObjects = 1
BEGIN
     DROP PARTITION FUNCTION pf_example_17;
END;
GO