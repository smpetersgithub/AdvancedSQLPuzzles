/*

Before executing this script, ensure all connections are disconnected!!
Before executing this script, ensure all connections are disconnected!!
Before executing this script, ensure all connections are disconnected!!

*/

------------------------
USE foo;
GO

--drop service
IF EXISTS (SELECT 1 FROM sys.services WHERE [name] = 'service_example_19')
BEGIN
     DROP SERVICE service_example_19;
END;
GO

--drop queue
IF EXISTS (SELECT 1 FROM sys.service_queues WHERE [name] = 'queue_example_19')
BEGIN
     DROP QUEUE queue_example_19;
END;
GO

--drop contract
IF EXISTS (SELECT 1 FROM sys.service_contracts WHERE [name] = 'contract_example_19')
BEGIN
     DROP CONTRACT contract_example_19;
END;
GO

--drop message type
IF EXISTS (SELECT 1 FROM sys.service_message_types WHERE name = 'msg_type_example_19')
BEGIN
     DROP MESSAGE TYPE msg_type_example_19;
END;
GO

------------------------
USE master;
GO

-- Step 1: Enable Service Broker on the database
ALTER DATABASE foo SET ENABLE_BROKER;
GO

------------------------
USE foo;
GO

-- Step 2: Create a Message Type (No validation)
CREATE MESSAGE TYPE msg_type_example_19
VALIDATION = NONE;
GO

-- Step 3: Create a Contract (Message is sent by the initiator)
CREATE CONTRACT contract_example_19
(msg_type_example_19 SENT BY INITIATOR);
GO

-- Step 4: Create a Queue
CREATE QUEUE queue_example_19;
GO

-- Step 5: Create a Service (Bound to the Queue and Contract)
CREATE SERVICE service_example_19
    ON QUEUE queue_example_19
    (contract_example_19);
GO

---------------------------------
-- Step 6: Send a Message to the Queue
DECLARE @DialogHandle UNIQUEIDENTIFIER;

-- Begin a conversation
BEGIN DIALOG CONVERSATION @DialogHandle
    FROM SERVICE service_example_19  -- Initiating from service_example_19
    TO SERVICE 'service_example_19'  -- Target service is also service_example_19
    ON CONTRACT contract_example_19
    WITH ENCRYPTION = OFF;

-- Send a message to the queue as NVARCHAR to ensure proper encoding
SEND ON CONVERSATION @DialogHandle
    MESSAGE TYPE msg_type_example_19
    (N'Hello, this is a test message!');
GO

---------------------------------
-- Step 7: Receive the Message from the Queue
RECEIVE TOP(1) 
    CONVERT(NVARCHAR(MAX), message_body) AS MessageBody
FROM queue_example_19;
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
SELECT  '19', COALESCE(c.type, d.type, e.type) AS referencing_object_type, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(c.schema_id), COALESCE(c.name, d.name, e.name) AS referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, b.type AS referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous
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

--------------------------
USE foo;
GO

--drop service
DECLARE @vDropObjects SMALLINT = 1;
IF EXISTS (SELECT 1 FROM sys.services WHERE [name] = 'service_example_19')
BEGIN
     DROP SERVICE service_example_19;
END;
GO

--drop queue
DECLARE @vDropObjects SMALLINT = 1;
IF EXISTS (SELECT 1 FROM sys.service_queues WHERE [name] = 'queue_example_19') AND @vDropObjects = 1
BEGIN
     DROP QUEUE queue_example_19;
END;
GO

--drop contract
DECLARE @vDropObjects SMALLINT = 1;
IF EXISTS (SELECT 1 FROM sys.service_contracts WHERE [name] = 'contract_example_19') AND @vDropObjects = 1
BEGIN
     DROP CONTRACT contract_example_19;
END;
GO

--drop message type
DECLARE @vDropObjects SMALLINT = 1;
IF EXISTS (SELECT 1 FROM sys.service_message_types WHERE name = 'msg_type_example_19') AND @vDropObjects = 1
BEGIN
     DROP MESSAGE TYPE msg_type_example_19;
END;
GO