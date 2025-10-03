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
SELECT  '17', c.type, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(c.schema_id), c.name, a.referencing_id, a.referencing_minor_id, a.referencing_class, a.referencing_class_desc, a.is_schema_bound_reference, a.referenced_class, a.referenced_class_desc, a.referenced_server_name, a.referenced_database_name, a.referenced_schema_name, a.referenced_entity_name, b.type, a.referenced_id, a.referenced_minor_id, a.is_caller_dependent, a.is_ambiguous, c.is_ms_shipped, b.is_ms_shipped, CASE WHEN a.referencing_id = a.referenced_id THEN 1 ELSE 0 END
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