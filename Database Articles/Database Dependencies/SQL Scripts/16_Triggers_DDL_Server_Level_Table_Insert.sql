---------------------------------------------
USE master;

DROP TRIGGER IF EXISTS trg_example_16 ON ALL SERVER;
GO
DROP DATABASE IF EXISTS db_example_16;
GO

---------------------------------------------
USE foo;
GO

DROP TABLE IF EXISTS dbo.tbl_example_16;
GO

---------------------------------------------
---------------------------------------------
---------------------------------------------
USE foo;
GO

CREATE TABLE dbo.tbl_example_16
(
EventID INT IDENTITY(1,1) PRIMARY KEY,
EventType VARCHAR(100),
ObjectName VARCHAR(255),
ObjectType VARCHAR(100),
EventDate DATETIME,
LoginName VARCHAR(255),
UserName VARCHAR(255),
CommandText VARCHAR(MAX)
);
GO

-- Create the trigger
CREATE TRIGGER trg_example_16 ON ALL SERVER 
FOR CREATE_DATABASE
AS
BEGIN
    DECLARE @EventData XML;
    SET @EventData = EVENTDATA();

    INSERT INTO foo.dbo.tbl_example_16 (EventType,ObjectName,ObjectType,EventDate,LoginName,UserName,CommandText)
    VALUES
    (
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        GETDATE(),
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(255)'),
        @EventData.value('(/EVENT_INSTANCE/UserName)[1]', 'NVARCHAR(255)'),
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
    );
END;
GO

-- Create a new database and trigger the event
CREATE DATABASE db_example_16;
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
USE master;
GO

INSERT INTO foo.dbo.sql_expression_dependencies
(database_name, example_number, referencing_object_type, referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous)
SELECT  'foo', '16', c.type AS referencing_object_type, c.name AS referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, b.type AS referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous
FROM    sys.sql_expression_dependencies a LEFT OUTER JOIN
        sys.objects b ON a.referenced_id = b.object_id LEFT OUTER JOIN
        sys.objects c ON a.referencing_id = c.object_id;
GO

/*
UPDATE  dbo.sql_expression_dependencies
SET     referencing_object_type = b.type,
        referencing_entity_name = b.name
FROM    dbo.sql_expression_dependencies a INNER JOIN
        sys.server_triggers b ON a.referencing_id = b.object_id
WHERE   referencing_class_desc = 'SERVER_DDL_TRIGGER';
GO
*/

-------------------------------------------------------
SELECT * FROM foo.dbo.sql_expression_dependencies ORDER BY example_number;
GO

---------------------------------------------
USE master;

DECLARE @vDropObjects SMALLINT = 0;
IF @vDropObjects = 1
BEGIN
     DROP TRIGGER IF EXISTS trg_example_16 ON ALL SERVER;
     DROP DATABASE IF EXISTS db_example_16;
END;
GO

---------------------------------------------
USE foo;
GO

DECLARE @vDropObjects SMALLINT = 0;
IF @vDropObjects = 1
BEGIN
     DROP TABLE IF EXISTS dbo.tbl_example_16;
END;
GO