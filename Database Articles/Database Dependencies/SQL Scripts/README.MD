# Database Dependencies SQL Scripts

Here are the thirty-two scripts I used to analyze the different database dependencies that can present themselves in SQL Server.

These scripts include the additional logic I used to perform the analysis, which I demonstrate below. This logic contains two boolean statements you can manipulate depending on your workflow.  

*  `IF @vTruncate = 1`
*  `IF @vDropObjects = 1`

One allows you to determine if you want to truncate the `foo.dbo.sql_expression_dependency` table, and the second determines if you wish to drop the created objects at the end of the script.  When performing the analysis, I found it easiest to create the objects, then insert the information into the local table `foo.dbo.sql_expression_dependency` and the `foo.dbo.system_objects` table, and then lastly delete the objects.  

Also of note, the `foo.dbo.system_objects` table has the `IGNORE_DUP_KEY = ON`, where the primary key is `object_id` and `database_name`.  Remember that `object_id` is only unique to the database, and the combination of `object_id` and `database_name` is the primary key!

The scripts to create the above tables are included and located in the Additional SQL Scripts folder.    

Included in this folder are scripts to:
1) Create the database, schemas, and tables     
2) Deploy the scripts via `sqlcmd` mode    
3) A script to kill any open sessions (which I needed to perform regularly when dropping and recreating the databases in my development work).

------

Here is the additional logic that I have included in each script.  

```sql
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
SELECT  '<example_number>, COALESCE(c.type, d.type, e.type) AS referencing_object_type, @@SERVERNAME, DB_NAME(), SCHEMA_NAME(c.schema_id), COALESCE(c.name, d.name, e.name) AS referencing_entity_name, referencing_id, referencing_minor_id, referencing_class, referencing_class_desc, is_schema_bound_reference, referenced_class, referenced_class_desc, referenced_server_name, referenced_database_name, referenced_schema_name, referenced_entity_name, b.type AS referenced_object_type, referenced_id, referenced_minor_id, is_caller_dependent, is_ambiguous
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
     DROP FUNCTION IF EXISTS dbo.fn_example_05;
     DROP PROCEDURE IF EXISTS dbo.sp_example_05;
     DROP TABLE IF EXISTS dbo.tbl_example_05;
END;
GO
```








