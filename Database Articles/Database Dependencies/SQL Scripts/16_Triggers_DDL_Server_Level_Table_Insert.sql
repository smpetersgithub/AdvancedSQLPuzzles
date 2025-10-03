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

DECLARE @vTruncate SMALLINT = 1;
IF @vTruncate = 1
BEGIN
     TRUNCATE TABLE foo.dbo.sql_expression_dependencies;
END;
GO

-------------------------------------------------------
USE master;
GO

--Note the trigger exists in the master datbase and references a cross-database object
INSERT INTO foo.dbo.sql_expression_dependencies
(example_number, referencing_object_type, referencing_server_name, referencing_database_name, referencing_schema_name, referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous, referencing_is_ms_shipped, referenced_is_ms_shipped, is_self_referencing)
SELECT  '16', e.type, @@SERVERNAME, DB_NAME(), NULL, e.name, a.referencing_id, a.referencing_minor_id, a.referencing_class, a.referencing_class_desc, a.is_schema_bound_reference, a.referenced_class, a.referenced_class_desc, a.referenced_server_name, a.referenced_database_name, a.referenced_schema_name, a.referenced_entity_name, b.type AS referenced_object_type, a.referenced_id, a.referenced_minor_id, a.is_caller_dependent, a.is_ambiguous, e.is_ms_shipped, b.is_ms_shipped, CASE WHEN a.referencing_id = a.referenced_id THEN 1 ELSE 0 END
FROM    sys.sql_expression_dependencies a LEFT OUTER JOIN
        sys.objects b ON a.referenced_id = b.object_id LEFT OUTER JOIN
        sys.server_triggers e ON a.referencing_id = e.object_id;
GO

-------------------------------------------------------
SELECT * FROM foo.dbo.sql_expression_dependencies ORDER BY example_number;
GO

---------------------------------------------
USE master;

DECLARE @vDropObjects SMALLINT = 1;
IF @vDropObjects = 1
BEGIN
     DROP TRIGGER IF EXISTS trg_example_16 ON ALL SERVER;
     DROP DATABASE IF EXISTS db_example_16;
END;
GO

---------------------------------------------
USE foo;
GO

DECLARE @vDropObjects SMALLINT = 1;
IF @vDropObjects = 1
BEGIN
     DROP TABLE IF EXISTS dbo.tbl_example_16;
END;
GO