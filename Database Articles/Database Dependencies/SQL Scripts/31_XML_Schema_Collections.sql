---------------------------------------------
USE foo;
GO

DROP PROCEDURE IF EXISTS dbo.sp_example_31;
DROP TABLE IF EXISTS dbo.tbl_example_31;
GO

IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'xml_schema_collection_example_31' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
DROP XML SCHEMA COLLECTION dbo.xml_schema_collection_example_31;
END;
GO

---------------------------------------------
---------------------------------------------
---------------------------------------------
USE foo;
GO

CREATE XML SCHEMA COLLECTION dbo.xml_schema_collection_example_31 AS
N'
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Order">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="OrderID" type="xs:int"/>
        <xs:element name="Product" type="xs:string"/>
        <xs:element name="Quantity" type="xs:int"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>';
GO

CREATE TABLE dbo.tbl_example_31
(
OrderID INT PRIMARY KEY,
OrderDetails XML(dbo.xml_schema_collection_example_31)
);
GO

CREATE PROCEDURE dbo.sp_example_31
    @OrderID INT,
    @OrderDetails XML(dbo.xml_schema_collection_example_31)
AS
BEGIN
    INSERT INTO dbo.tbl_example_31 (OrderID, OrderDetails)
    VALUES (@OrderID, @OrderDetails);
END;
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
SELECT  '31', COALESCE(c.type, d.type, e.type) AS referencing_object_type, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(c.schema_id), COALESCE(c.name, d.name, e.name) AS referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, b.type AS referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous
FROM    sys.sql_expression_dependencies a LEFT OUTER JOIN
        sys.objects b ON a.referenced_id = b.object_id LEFT OUTER JOIN
        sys.objects c ON a.referencing_id = c.object_id LEFT OUTER JOIN
        sys.triggers d ON a.referencing_id = d.object_id LEFT OUTER JOIN
        sys.server_triggers e ON a.referencing_id = e.object_id;
GO

INSERT INTO foo.dbo.system_objects (table_name, object_id, server_name, database_name, schema_name, name, principal_id, schema_id, parent_object_id, type, type_desc, create_date, modify_date, is_ms_shipped, is_published, is_schema_published) 
SELECT 'sys.objects', object_id, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(schema_id), name, principal_id, schema_id, parent_object_id, type, type_desc, create_date, modify_date, is_ms_shipped, is_published, is_schema_published 
FROM   sys.objects
UNION ALL
SELECT 'sys.xml_schema_collections', xml_collection_id AS object_id, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(schema_id), name, principal_id, schema_id, NULL AS parent_object_id, 'XML' AS type, 'XML_SCHEMA_COLLECTION' AS type_desc, create_date, modify_date, NULL AS is_ms_shipped, NULL AS is_published, NULL AS is_schema_published
FROM sys.xml_schema_collections;
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
     DROP PROCEDURE IF EXISTS dbo.sp_example_31;
     DROP TABLE IF EXISTS dbo.tbl_example_31;
END;
GO

DECLARE @vDropObjects SMALLINT = 1;
IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'xml_schema_collection_example_31') AND @vDropObjects = 1
BEGIN
     DROP XML SCHEMA COLLECTION dbo.xml_schema_collection_example_31;
END;
GO

DECLARE @vDropObjects SMALLINT = 1;
IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'xml_schema_collection_example_31') AND @vDropObjects = 1
BEGIN
     DROP XML SCHEMA COLLECTION dbo.xml_schema_collection_example_31;
END;
GO