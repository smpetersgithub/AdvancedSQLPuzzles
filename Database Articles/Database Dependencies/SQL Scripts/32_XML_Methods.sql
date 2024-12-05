---------------------------------------------
USE foo;
GO

DROP PROCEDURE IF EXISTS dbo.sp_example_32;
DROP TABLE IF EXISTS dbo.tbl_example_32;
GO

---------------------------------------------
---------------------------------------------
---------------------------------------------
USE foo;
GO

CREATE TABLE dbo.tbl_example_32
(
ID INT,
column_xml_example_32 XML
);
GO

INSERT INTO dbo.tbl_example_32 (Id, column_xml_example_32) VALUES (1, '<Record id="1"><Message>Hello World</Message></Record>');
GO

CREATE PROCEDURE dbo.sp_example_32 AS
BEGIN

    -- value()
    SELECT t.column_xml_example_32.value('(./Record/@id)[1]', 'int')
    FROM dbo.tbl_example_32 t;

    -- exist()
    SELECT t.column_xml_example_32.exist('/Record[Message = "Hello World"]')
    FROM   dbo.tbl_example_32 t;

    -- query()
    SELECT t.column_xml_example_32.query('/Record/Message')
    FROM dbo.tbl_example_32 t;

    -- nodes()
    SELECT x.n.value('(text())[1]', 'NVARCHAR(100)')
    FROM   dbo.tbl_example_32 t CROSS APPLY 
           t.column_xml_example_32.nodes('/Record/Message') AS x(n);

    -- modify()
    UPDATE dbo.tbl_example_32
    SET column_xml_example_32.modify('replace value of (/Record/Message/text())[1] with "Goodbye World"')
    WHERE Id = 1;

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
SELECT  '32', COALESCE(c.type, d.type, e.type) AS referencing_object_type, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(c.schema_id), COALESCE(c.name, d.name, e.name) AS referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, b.type AS referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous
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
     DROP PROCEDURE IF EXISTS dbo.sp_example_32;
     DROP TABLE IF EXISTS dbo.tbl_example_32;
END;
GO