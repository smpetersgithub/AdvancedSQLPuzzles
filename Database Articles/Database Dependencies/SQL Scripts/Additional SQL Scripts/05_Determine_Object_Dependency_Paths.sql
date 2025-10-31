/*----------------------------------------------------------------------------------------------------------

📋 Instructions

Please visit the following URL for instructions
https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/05_determine_object_dependency_paths.md

1. Create the temporary stored procedures
3. Execute the stored procedures

--------------------------------------------------------
--------------------------------------------------------

-- Use the following to execute the stored procedures

-- Forward dependencies
EXECUTE ##temp_sp_master_execution_paths 'WideWorldImporters', 'WideWorldImporters.Website.SearchForPeople';
GO

-- Reverse dependencies
EXECUTE ##temp_sp_master_execution_reverse_paths 'WideWorldImporters', 'WideWorldImporters.Sales.Customers';
GO

--------------------------------------------------------
--------------------------------------------------------

-- To trace dependencies across multiple databases, mofity the @v_database_ist as shown below
-- The following will trace the stored procedure foo.dbo.sp_InsertSales dependencies across the foo and bar databases

EXECUTE ##temp_sp_master_execution_paths 'foo,bar', 'foo.dbo.sp_InsertSales';
GO

-- The following will trace the foo.dbo.Sales table dependencies across the foo and bar databases

EXECUTE ##temp_sp_master_execution_reverse_paths 'foo,bar', 'foo.dbo.sp_InsertSales';
GO

----------------------------------------------------------------------------------------------------------*/

USE [master];
GO

CREATE OR ALTER PROCEDURE ##temp_sp_create_tables (@v_database_list VARCHAR(8000)) AS
BEGIN
    
    -----------------------------------------------------------------
    DROP TABLE IF EXISTS ##databases;
    DROP TABLE IF EXISTS ##sql_statements;
    DROP TABLE IF EXISTS ##sql_expression_dependencies;
    DROP TABLE IF EXISTS ##sys_objects;
    DROP TABLE IF EXISTS ##self_referencing_objects;
    DROP TABLE IF EXISTS ##path_list;
    DROP TABLE IF EXISTS ##path_list_reverse;

    -- The following tables are created via SELECT INTO
    DROP TABLE IF EXISTS ##path;
    DROP TABLE IF EXISTS ##path_list_preprocess;
    DROP TABLE IF EXISTS ##path_list_report;

    DROP TABLE IF EXISTS ##path_reverse;
    DROP TABLE IF EXISTS ##path_list_preprocess_reverse;
    DROP TABLE IF EXISTS ##path_list_report_reverse;

    -----------------------------------------------------------------
    
    CREATE TABLE ##databases (
        database_id INT PRIMARY KEY,
        [database_name] VARCHAR(256)
    );

    -- Populate the ##databases table
    BEGIN

        -----------------------------------------------------------------
        -- Dynamic SQL for inserting into ##databases
        -----------------------------------------------------------------
        SET @v_database_list = '''' + REPLACE(@v_database_list, ',', ''',''') + '''';
        SET @v_database_list = REPLACE(@v_database_list,' ',''); 

        PRINT('@v_database_list = ' + @v_database_list);

        DECLARE @v_sql_statement NVARCHAR(MAX);
        SET @v_sql_statement = REPLACE('INSERT INTO ##databases (database_id, [database_name]) SELECT database_id, [name] FROM sys.databases WHERE NAME IN (<DATABASE_STRING>);','<DATABASE_STRING>', @v_database_list);
        EXEC sp_executesql @v_sql_statement;
        PRINT('EXEC sp_executesql (Insert into ##databases)' + CAST(@@ROWCOUNT AS VARCHAR(100)));
 
    END;

    CREATE TABLE ##sql_expression_dependencies (
        sql_expression_dependencies_id INT IDENTITY(1,1) PRIMARY KEY,
        referencing_id INT,
        referencing_database_name VARCHAR(256),
        referencing_schema_name VARCHAR(256),
        referencing_object_name VARCHAR(256),
        referencing_type_desc VARCHAR(256),
        referenced_id INT,
        referenced_database_name VARCHAR(256),
        referenced_schema_name VARCHAR(256),
        referenced_object_name VARCHAR(256),
        referenced_type_desc VARCHAR(256),
        depth INT,
        referencing_object_fullname VARCHAR(256),
        referenced_object_fullname VARCHAR(256),
        referencing_minor_id INT,
        referencing_class_desc VARCHAR(256),
        is_schema_bound_reference INT,
        referenced_class INT,
        referenced_class_desc VARCHAR(256),
        referenced_server_name VARCHAR(256),
        referenced_minor_id INT,
        is_caller_dependent INT,
        is_ambiguous INT
    );

    CREATE TABLE ##self_referencing_objects (
        sql_expression_dependencies_id INT, -- Populated from ##sql_expression_dependencies table
        referencing_id INT,
        referencing_database_name VARCHAR(256),
        referencing_schema_name VARCHAR(256),
        referencing_object_name VARCHAR(256),
        referencing_type_desc VARCHAR(256),
        referenced_id INT,
        referenced_database_name VARCHAR(256),
        referenced_schema_name VARCHAR(256),
        referenced_object_name VARCHAR(256),
        referenced_type_desc VARCHAR(256),
        depth INT,
        referencing_object_fullname VARCHAR(256),
        referenced_object_fullname VARCHAR(256),
        referencing_minor_id INT,
        referencing_class_desc VARCHAR(256),
        is_schema_bound_reference INT,
        referenced_class INT,
        referenced_class_desc VARCHAR(256),
        referenced_server_name VARCHAR(256),
        referenced_minor_id INT,
        is_caller_dependent INT,
        is_ambiguous INT
    );

    CREATE TABLE ##sys_objects (
        [object_id] INT,
        [database_name] VARCHAR(256),
        [schema_name] VARCHAR(256),
        [object_name] VARCHAR(256),
        [type_desc] VARCHAR(256),
        CONSTRAINT PK_sys_objects PRIMARY KEY ([object_id], [database_name])
        );

    CREATE TABLE ##path_list (
        depth INT,
        object_name_path VARCHAR(8000),
        object_type_path VARCHAR(8000),
        object_type_desc_path VARCHAR(8000),
        object_id_path VARCHAR(8000),
        referencing_object_fullname VARCHAR(256),
        referenced_object_fullname VARCHAR(256),
        referenced_type_desc VARCHAR(256)
    );

    CREATE TABLE ##path_list_reverse (
        depth INT,
        object_name_path VARCHAR(8000),
        object_type_path VARCHAR(8000),
        object_type_desc_path VARCHAR(8000),
        object_id_path VARCHAR(8000),
        referencing_object_fullname VARCHAR(256),
        referenced_object_fullname VARCHAR(256),
        referenced_type_desc VARCHAR(256)
    );

END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_insert_sql_statement AS
BEGIN

    SELECT sql_statement_id, row_id, sql_line
    INTO   ##sql_statements
    FROM (VALUES
    -----------------------------------------------------------------
    -- Dynamic SQL for inserting into ##sql_expression_dependencies
    -----------------------------------------------------------------
    (1, 10, 'WITH cte_sql_expression_dependencies AS'),
    (1, 20, '('),
    (1, 30, 'SELECT *'),
    (1, 40, 'FROM   vdatabase_name.sys.sql_expression_dependencies'),
    (1, 50, 'WHERE  1=1'), 
    (1, 60, ')'),
    -----------------------------------------------
    (1, 70, 'INSERT INTO ##sql_expression_dependencies ('),
    -----------------------------------------------
    (1, 80, 'referencing_id,'),
    (1, 90, 'referencing_database_name,'),
    (1, 100, 'referencing_schema_name,'),
    (1, 110, 'referencing_object_name,'),
    (1, 120, 'referencing_type_desc,'),
    (1, 130, 'referenced_database_name,'),
    (1, 140, 'referenced_schema_name,'),
    (1, 150, 'referenced_object_name,'),
    (1, 160, 'referenced_id,'),
    (1, 170, 'referencing_minor_id,'),
    (1, 180, 'referencing_class_desc,'),
    (1, 190, 'is_schema_bound_reference,'),
    (1, 200, 'referenced_class,'),
    (1, 210, 'referenced_class_desc,'),
    (1, 220, 'referenced_server_name,'),
    (1, 230, 'referenced_minor_id,'),
    (1, 240, 'is_caller_dependent,'),
    (1, 250, 'is_ambiguous'),
    (1, 260, ')'),
    -----------------------------------------------
    (1, 270, 'SELECT'),
    (1, 280, 'd.referencing_id,'),
    (1, 290, 'DB_NAME(vdatabase_id) AS referencing_database_name,'),
    (1, 300, 's.[name] AS referencing_schema_name,'),    
    (1, 310, 'o.name AS referencing_object_name,'),
    (1, 320, 'o.type_desc AS referencing_type_desc,'),
    (1, 330, 'd.referenced_database_name,'),
    (1, 340, 'd.referenced_schema_name,'),
    (1, 350, 'd.referenced_entity_name,'),
    (1, 360, 'd.referenced_id,'),
    (1, 370, 'referencing_minor_id,'),
    (1, 380, 'referencing_class_desc,'),
    (1, 390, 'is_schema_bound_reference,'),
    (1, 400, 'referenced_class,'),
    (1, 410, 'referenced_class_desc,'),
    (1, 420, 'referenced_server_name,'),
    (1, 430, 'referenced_minor_id,'),
    (1, 440, 'is_caller_dependent,'),
    (1, 450, 'is_ambiguous'),
    -----------------------------------------------
    (1, 460, 'FROM'),
    (1, 470, 'cte_sql_expression_dependencies d'),
    (1, 480, 'INNER JOIN vdatabase_name.sys.objects o ON d.referencing_id = o.object_id'),
    (1, 490, 'INNER JOIN vdatabase_name.sys.schemas s ON o.schema_id = s.schema_id;'),
    -----------------------------------------------------------------
    -- Dynamic SQL for inserting into ##sys_objects
    -----------------------------------------------------------------
    (2, 10, 'INSERT INTO ##sys_objects (object_id, database_name, schema_name, object_name, type_desc)'),
    (2, 20,  'SELECT'),
    (2, 25,  'o.object_id,'),
    (2, 30,  '''vdatabase_name'','),
    (2, 40,  's.name AS schema_name,'),
    (2, 50,  'o.name AS object_name,'),
    (2, 60,  'type_desc'),
    (2, 70,  'FROM vdatabase_name.sys.objects o INNER JOIN'),
    (2, 80,  'vdatabase_name.sys.schemas s ON o.schema_id = s.schema_id'),
    (2, 90,  'WHERE is_ms_shipped = 0;')
    ) AS a(sql_statement_id, row_id, sql_line);
    PRINT('Inserted into ##sql_statements: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_cursor_insert_sql_expression_dependencies AS
BEGIN

    DECLARE @v_database_id INT;
    DECLARE @v_database_name NVARCHAR(256);
    DECLARE @v_sql_statement NVARCHAR(MAX);

    DECLARE mycursor CURSOR FOR SELECT database_id, [database_name] FROM ##databases;

    OPEN mycursor;

    FETCH NEXT FROM mycursor INTO @v_database_id, @v_database_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        SELECT @v_sql_statement = STRING_AGG(sql_line, ' ')
        FROM   ##sql_statements
        WHERE  sql_statement_id = 1;
        
        SET @v_sql_statement = REPLACE(@v_sql_statement, 'vdatabase_name', @v_database_name);
        SET @v_sql_statement = REPLACE(@v_sql_statement, 'vdatabase_id', CAST(@v_database_id AS NVARCHAR));
        
        EXEC sp_executesql @v_sql_statement;
        PRINT('EXEC sp_executesql (Insert into ##sql_expression_dependencies): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

        FETCH NEXT FROM mycursor INTO @v_database_id, @v_database_name;

    END;

    -- Close and deallocate the cursor
    CLOSE mycursor;
    DEALLOCATE mycursor;

END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_cursor_insert_sys_objects AS
BEGIN
    
    DECLARE @v_database_id INT;
    DECLARE @v_database_name NVARCHAR(256);
    DECLARE @v_sql_statement NVARCHAR(MAX);

    DECLARE mycursor CURSOR FOR 
    SELECT database_id, [database_name]
    FROM   ##databases;

    OPEN mycursor;

    FETCH NEXT FROM mycursor INTO @v_database_id, @v_database_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        SELECT @v_sql_statement = STRING_AGG(sql_line, ' ') 
        FROM   ##sql_statements 
        WHERE  sql_statement_id = 2;

        SET @v_sql_statement = REPLACE(@v_sql_statement, 'vdatabase_name', @v_database_name);
        SET @v_sql_statement = REPLACE(@v_sql_statement, 'vdatabase_id', CAST(@v_database_id AS NVARCHAR));

        EXEC sp_executesql @v_sql_statement;
        PRINT('EXEC sp_executesql (Insert into ##sys_objects): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

        FETCH NEXT FROM mycursor INTO @v_database_id, @v_database_name;

    END;

    CLOSE mycursor;
    DEALLOCATE mycursor;

END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_update_sql_expression_dependencies AS
BEGIN
    
    -- Update (Delete) 1
    -- Remove self-referencing objects to prevent circular dependencies
    DELETE ##sql_expression_dependencies
    OUTPUT DELETED.* INTO ##self_referencing_objects
    WHERE  referenced_id = referencing_id;
    PRINT('Delete Statement - Count of self-referencing objects: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    -- Update 2
    -- Updates the referenced_id and referenced_type_desc for objects that are cross-database dependencies
    -- Cross-database dependencies will have a NULL referenced_id
    UPDATE ##sql_expression_dependencies
    SET    referenced_id = o.[object_id],
           referenced_type_desc = o.[type_desc]
    FROM   ##sql_expression_dependencies db INNER JOIN
           ##sys_objects o ON
               CONCAT('.',db.referenced_database_name, db.referenced_schema_name, db.referenced_object_name)
               =
               CONCAT('.',o.[database_name], o.[schema_name], o.[object_name])
    WHERE  db.referenced_database_name IS NOT NULL AND
           db.referenced_schema_name IS NOT NULL;
    PRINT('Update Statement - Count of cross-database dependencies: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));
    
    -- Update 3
    -- Update information from the ##sys_objects table
    -- This will update records where this information is already populated in the ##sql_expression_dependencies table,
    -- but the overwritten information will match the ##sys_objects table
    UPDATE ##sql_expression_dependencies
    SET    referenced_id = o.[object_id],
           referenced_type_desc = o.[type_desc],
           referenced_database_name = o.[database_name],
           referenced_schema_name = o.[schema_name]
    FROM   ##sql_expression_dependencies db INNER JOIN
           ##sys_objects o ON db.referenced_id = o.[object_id] AND db.referencing_database_name = o.[database_name];
    PRINT('Update Statement - Count of records that join to sys.objects: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    -- Update (Insert) 4
    -- Insert objects with no referenced objects
    -- Depth is set to 1; these objects are root nodes
    INSERT INTO ##sql_expression_dependencies
    (
    referencing_id,
    referencing_type_desc,
    referencing_database_name,
    referencing_schema_name,
    referencing_object_name,
    depth
    )
    SELECT [object_id],
           [type_desc],
           [database_name],
           [schema_name],
           [object_name],
           1 AS depth
    FROM   ##sys_objects
    WHERE  [object_id] NOT IN (SELECT referencing_id FROM ##sql_expression_dependencies);
    PRINT('Insert Statement - Count of objects not in ##sql_expression_dependencies (objects with no referenced objects): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    -- Update 5
    -- Update referenced_object_fullname and referencing_object_fullname columns
    UPDATE ##sql_expression_dependencies
    SET    referenced_object_fullname = CONCAT_WS('.',referenced_database_name, referenced_schema_name, referenced_object_name, ISNULL(referenced_type_desc,'UNKNOWN')),
           referencing_object_fullname = CONCAT_WS('.',referencing_database_name, referencing_schema_name, referencing_object_name, ISNULL(referencing_type_desc,'UNKNOWN'));
    PRINT('Update Statement - Update referenced_object_fullname and referencing_object_fullname columns: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));
    
    -- Update 6
    -- Sets the referenced_object_fullname to NULL for root node objects (depth of 1)
    UPDATE ##sql_expression_dependencies
    SET    referenced_object_fullname = NULL 
    WHERE  referenced_object_fullname = 'UNKNOWN';
    PRINT('Update Statement - Update referenced_object_fullname to NULL for root node objects: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_determine_paths (@v_object_name VARCHAR(256)) AS
BEGIN

    DROP TABLE IF EXISTS ##path;
    TRUNCATE TABLE ##path_list;
    DROP TABLE IF EXISTS ##path_list_preprocess;
    DROP TABLE IF EXISTS ##path_list_report;

    -- Seed the ##path table 
    -- This step accounts for any changes we want to make to the ##sql_expression_dependencies table
    -- Inserts all DISTINCT records from the ##sql_expression_dependencies table
    SELECT DISTINCT
           referencing_id,
           referenced_id,
           referencing_database_name,
           referencing_schema_name,
           referencing_type_desc,
           referencing_object_name,
           referencing_object_fullname,
           referenced_type_desc,
           referenced_object_name,
           referenced_object_fullname
    INTO   ##path
    FROM   ##sql_expression_dependencies;
    PRINT('Inserted into ##path: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    -- Seed the ##path_list table
    INSERT INTO ##path_list (depth, object_name_path, object_id_path, object_type_desc_path, referencing_object_fullname, referenced_object_fullname, referenced_type_desc)
    SELECT 1 AS depth,
           CONCAT(referencing_object_fullname,',',referenced_object_fullname) AS object_name_path,
           CONCAT(CAST(referencing_id AS VARCHAR(100)), ',', ISNULL(CAST(referenced_id AS VARCHAR(100)), 'UNKNOWN')) AS object_id_path,
           CONCAT(referencing_type_desc, ',', ISNULL(referenced_type_desc, 'UNKNOWN')) AS object_type_desc_path,
           referencing_object_fullname,
           referenced_object_fullname,
           referenced_type_desc
    FROM   ##path
    WHERE  CONCAT_WS('.',referencing_database_name, referencing_schema_name, referencing_object_name) = @v_object_name AND
           referenced_object_fullname IS NOT NULL;
    PRINT('Inserted into ##path_list (seed): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    DECLARE @v_row_count INTEGER = 1;
    DECLARE @v_depth INTEGER = 2;
    
    WHILE @v_row_count >= 1
    BEGIN

        WITH cte_determine_referenced_object AS
        (
        SELECT object_name_path,
               object_id_path,
               object_type_desc_path,
               REVERSE(SUBSTRING(REVERSE(object_name_path),0,CHARINDEX(',',REVERSE(object_name_path)))) AS referenced_object_fullname,
               referenced_type_desc
        FROM   ##path_list
        WHERE  depth = @v_depth - 1
        )
        INSERT INTO ##path_list 
        (depth, object_name_path, object_id_path, object_type_desc_path, referencing_object_fullname, referenced_object_fullname, 
        referenced_type_desc)
        SELECT @v_depth AS depth,
               CONCAT(a.object_name_path,',',b.referenced_object_fullname) AS object_name_path,
               CONCAT(a.object_id_path, ',', ISNULL(CAST(b.referenced_id AS VARCHAR(100)), 'UNKNOWN')) AS object_id_path,
               CONCAT(a.object_type_desc_path, ',', ISNULL(b.referenced_type_desc, 'UNKNOWN')) AS object_type_desc_path,
               a.referenced_object_fullname,
               b.referenced_object_fullname,
               b.referenced_type_desc
        FROM   cte_determine_referenced_object a INNER JOIN 
               ##path b ON a.referenced_object_fullname = b.referencing_object_fullname
                       AND b.referenced_object_fullname IS NOT NULL
                       AND CHARINDEX(b.referenced_object_fullname, a.object_name_path) = 0;

        SET @v_row_count = @@ROWCOUNT;
        PRINT('Inserted into ##path_list (WHILE loop): ' + CAST(@v_row_count AS VARCHAR(100)));
    
        SET @v_depth = @v_depth + 1;
    
    END;

    --------------------------
    -- Final output 
    -- Modify as needed
    --------------------------
    DROP TABLE IF EXISTS ##path_list_preprocess;
    DROP TABLE IF EXISTS ##path_list_report;

    SELECT object_name_path,
           referenced_object_fullname,
           referenced_type_desc,
           object_id_path,
           object_type_desc_path
    INTO   ##path_list_preprocess
    FROM   ##path_list r1
    WHERE  NOT EXISTS (SELECT 1 FROM ##path_list r2 WHERE r2.object_name_path LIKE r1.object_name_path + ',%');
    PRINT('Inserted into ##path_list_preprocess: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    SELECT REPLACE(object_name_path,',',N'   ➡️   ') AS object_name_path,
           referenced_object_fullname,
           (LEN(object_name_path) - LEN(REPLACE(object_name_path, ',', ''))) / LEN(',') AS depth,
           REPLACE(object_id_path,',',N'   ➡️   ') AS object_id_path,
           REPLACE(object_type_desc_path,',',N'   ➡️   ') AS object_type_desc_path
    INTO   ##path_list_report
    FROM   ##path_list_preprocess;
    PRINT('Inserted into ##path_list_report: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    SELECT * FROM ##path_list_report;
    PRINT('Select from ##path_list_report: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_determine_reverse_paths (@v_object_name VARCHAR(256)) AS
BEGIN

    DROP TABLE IF EXISTS ##path_reverse;
    TRUNCATE TABLE ##path_list_reverse;
    DROP TABLE IF EXISTS ##path_list_preprocess_reverse;
    DROP TABLE IF EXISTS ##path_list_report_reverse;

    -- Seed the ##path_reverse table 
    -- This step accounts for any changes we want to make to the ##sql_expression_dependencies table
    -- Inserts all DISTINCT records from the ##sql_expression_dependencies table
    SELECT DISTINCT
           referencing_id,
           referenced_id,
           referencing_database_name,
           referencing_schema_name,
           referencing_type_desc,
           referencing_object_name,
           referencing_object_fullname,
           referenced_database_name,
           referenced_schema_name,
           referenced_type_desc,
           referenced_object_name,
           referenced_object_fullname
    INTO   ##path_reverse
    FROM   ##sql_expression_dependencies;
    PRINT('Inserted into ##path_reverse: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    -- Seed the ##path_list_reverse table
    INSERT INTO ##path_list_reverse (depth, object_name_path, object_id_path, object_type_desc_path, referencing_object_fullname, referenced_object_fullname, referenced_type_desc)
    SELECT 1 AS depth,
           CONCAT(referencing_object_fullname,',',referenced_object_fullname) AS object_name_path,
           CONCAT(CAST(referencing_id AS VARCHAR(100)), ',', ISNULL(CAST(referenced_id AS VARCHAR(100)), 'UNKNOWN')) AS object_id_path,
           CONCAT(referencing_type_desc, ',', ISNULL(referenced_type_desc, 'UNKNOWN')) AS object_type_desc_path,
           referencing_object_fullname,
           referenced_object_fullname,
           referenced_type_desc
    FROM   ##path_reverse
    WHERE  CONCAT_WS('.',referenced_database_name, referenced_schema_name, referenced_object_name) = @v_object_name AND 
           referencing_object_fullname IS NOT NULL;
    PRINT('Inserted into ##path_list_reverse (seed): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));


    DECLARE @v_row_count INT = 1;
    DECLARE @v_depth INT = 2;

    WHILE @v_row_count >= 1
    BEGIN

        WITH cte_determine_referencing_object AS
        (
        SELECT object_name_path,
               object_id_path,
               object_type_desc_path,
               SUBSTRING(object_name_path, 1, CHARINDEX(',', object_name_path) - 1) AS referencing_object_fullname,
               referenced_type_desc
        FROM   ##path_list_reverse
        WHERE  depth = @v_depth - 1
        )
        INSERT INTO ##path_list_reverse (depth, object_name_path, object_id_path, object_type_desc_path, referencing_object_fullname, referenced_object_fullname, referenced_type_desc)
        SELECT @v_depth AS depth,
               CONCAT_WS(',', b.referencing_object_fullname, a.object_name_path) AS object_name_path,
               CONCAT_WS(',', b.referencing_id, a.object_id_path) AS object_id_path,
               CONCAT_WS(',', b.referencing_type_desc, a.object_type_desc_path) AS object_type_desc_path,
               b.referencing_object_fullname,
               a.referencing_object_fullname AS referenced_object_fullname,
               b.referenced_type_desc
       FROM    cte_determine_referencing_object a INNER JOIN 
               ##path_reverse b ON a.referencing_object_fullname = b.referenced_object_fullname
       WHERE   b.referencing_object_fullname IS NOT NULL AND 
               CHARINDEX(b.referencing_object_fullname, a.object_name_path) = 0;
       
       SET @v_row_count = @@ROWCOUNT;
       PRINT('Inserted into ##path_list_reverse (WHILE loop): ' + CAST(@v_row_count AS VARCHAR(100)));
       
       SET @v_depth = @v_depth + 1;

    END;

    --------------------------
    -- Final output 
    -- Modify as needed
    --------------------------
    SELECT object_name_path,
           object_id_path,
           object_type_desc_path,
           referenced_object_fullname,
           referenced_type_desc
    INTO   ##path_list_preprocess_reverse
    FROM   ##path_list_reverse r1
    WHERE  NOT EXISTS (SELECT 1 FROM ##path_list_reverse r2 WHERE r2.object_name_path LIKE r1.object_name_path + ',%');
    PRINT('Inserted into ##path_list_preprocess_reverse: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    SELECT DISTINCT
           REPLACE(CASE WHEN object_name_path LIKE '%,' THEN SUBSTRING(object_name_path, 1, LEN(object_name_path) - 1) ELSE object_name_path END, ',',  N'   ⬅️   ') AS object_name_path, 
           SUBSTRING(object_name_path, 1, CHARINDEX(',', object_name_path) - 1) AS referencing_object_fullname,
           (LEN(object_name_path) - LEN(REPLACE(object_name_path, ',', ''))) AS depth,
           REPLACE(CASE WHEN object_id_path LIKE '%,UNKNOWN' THEN LEFT(object_id_path, LEN(object_id_path) - LEN(',UNKNOWN')) ELSE object_id_path END, ',', N'   ⬅️   ') AS object_id_path,
           REPLACE(CASE WHEN object_type_desc_path LIKE '%,UNKNOWN' THEN LEFT(object_type_desc_path, LEN(object_type_desc_path) - LEN(',UNKNOWN')) ELSE object_type_desc_path END, ',', N'   ⬅️   ') AS object_type_desc_path
    INTO   ##path_list_report_reverse
    FROM   ##path_list_preprocess_reverse;
    PRINT('Inserted into ##path_list_report_reverse: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    SELECT * FROM ##path_list_report_reverse;
    PRINT('Select from ##path_list_report_reverse: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

END;
GO

----------------------------------------------------------------------
-- The following creates master execution temporary stored procedures
----------------------------------------------------------------------

CREATE OR ALTER PROCEDURE ##temp_sp_master_execution_paths (@v_database_list VARCHAR(8000), @v_object_name VARCHAR(256)) AS
BEGIN
    EXECUTE ##temp_sp_create_tables @v_database_list;
    EXECUTE ##temp_sp_insert_sql_statement;
    EXECUTE ##temp_sp_cursor_insert_sql_expression_dependencies;
    EXECUTE ##temp_sp_cursor_insert_sys_objects;
    EXECUTE ##temp_sp_update_sql_expression_dependencies;
    EXECUTE ##temp_sp_determine_paths @v_object_name;
END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_master_execution_reverse_paths (@v_database_list VARCHAR(8000), @v_object_name VARCHAR(256)) AS
BEGIN
    EXECUTE ##temp_sp_create_tables @v_database_list;
    EXECUTE ##temp_sp_insert_sql_statement;
    EXECUTE ##temp_sp_cursor_insert_sql_expression_dependencies;
    EXECUTE ##temp_sp_cursor_insert_sys_objects;
    EXECUTE ##temp_sp_update_sql_expression_dependencies;
    EXECUTE ##temp_sp_determine_reverse_paths @v_object_name;
END;
GO