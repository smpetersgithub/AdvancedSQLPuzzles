-------------------------------------------------------
USE foo;
GO

DROP TABLE IF EXISTS dbo.table_example_39;
GO

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
USE foo;
GO

-- Step 1: Create the table
CREATE TABLE dbo.table_example_39
(
OrderID     INT,
CustomerID  INT,
ProductName NVARCHAR(100),
Quantity    INT,
UnitPrice   MONEY,
OrderDate   DATE,
CONSTRAINT pk_example_39 PRIMARY KEY (OrderID)
);
GO

-- Step 2: Add extended properties to the table
EXEC sys.sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Stores order transactions for customers.',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39';
GO

-- Step 3: Add extended properties to individual columns
EXEC sys.sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Primary key. Unique identifier for each order.',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39',
    @level2type = N'COLUMN',   @level2name = N'OrderID';
GO

EXEC sys.sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Foreign key reference to the customer placing the order.',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39',
    @level2type = N'COLUMN',   @level2name = N'CustomerID';
GO

EXEC sys.sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Name of the product ordered.',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39',
    @level2type = N'COLUMN',   @level2name = N'ProductName';
GO

EXEC sys.sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Number of units ordered. Must be greater than zero.',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39',
    @level2type = N'COLUMN',   @level2name = N'Quantity';
GO

EXEC sys.sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Price per unit at the time of the order.',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39',
    @level2type = N'COLUMN',   @level2name = N'UnitPrice';
GO

EXEC sys.sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Date the order was placed.',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39',
    @level2type = N'COLUMN',   @level2name = N'OrderDate';
GO

-- Step 4: Add a custom property (non MS_Description) to the table
EXEC sys.sp_addextendedproperty
    @name       = N'Author',
    @value      = N'Scott Peters',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39';
GO

EXEC sys.sp_addextendedproperty
    @name       = N'CreatedDate',
    @value      = N'2026-06-12',
    @level0type = N'SCHEMA',   @level0name = N'dbo',
    @level1type = N'TABLE',    @level1name = N'table_example_39';
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
SELECT  '39', c.type, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(c.schema_id), c.name, a.referencing_id, a.referencing_minor_id, a.referencing_class, a.referencing_class_desc, a.is_schema_bound_reference, a.referenced_class, a.referenced_class_desc, a.referenced_server_name, a.referenced_database_name, a.referenced_schema_name, a.referenced_entity_name, b.type, a.referenced_id, a.referenced_minor_id, a.is_caller_dependent, a.is_ambiguous, c.is_ms_shipped, b.is_ms_shipped, CASE WHEN a.referencing_id = a.referenced_id THEN 1 ELSE 0 END
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
    -- Remove extended properties before dropping the table
    EXEC sys.sp_dropextendedproperty
        @name       = N'MS_Description',
        @level0type = N'SCHEMA',   @level0name = N'dbo',
        @level1type = N'TABLE',    @level1name = N'table_example_39';

    DROP TABLE IF EXISTS dbo.table_example_39;
END
GO
