/*
📋 Instructions

Please visit the following URL for instructions.
https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies

1. Create the temporary stored procedures
2. Set the variables
3. Execute the stored procedures in the same session.

--------------------------------------------------------
--------------------------------------------------------

--Please use the following to execute the stored procedures.

--Single Database
DECLARE @v_database VARCHAR(100) = '''WideWorldImporters''';
PRINT('Ensure the string has single quotes around each value: ' + @v_database);


--Multiple Databases
--DECLARE @v_database VARCHAR(100) = '''WideWorldImporters'',''AdventureWorks''';
--PRINT('Ensure the stings has single quotes around each value: ' + @v_database)
-------

EXECUTE ##temp_sp_create_tables @v_database;
EXECUTE ##temp_sp_insert_sql_statement;
EXECUTE ##temp_sp_cursor_insert_sql_expression_dependencies;
EXECUTE ##temp_sp_cursor_insert_sys_objects;
EXECUTE ##temp_sp_update_sql_expression_dependencies;

-------
DECLARE @v_object_name VARCHAR(100) = 'Website.SearchForPeople';
EXECUTE ##temp_sp_determine_paths @v_object_name;
-------
DECLARE @v_object_name_reverse_path VARCHAR(100) = 'Sales.Customers';
EXECUTE ##temp_sp_determine_reverse_paths @v_object_name_reverse_path;
-------

-------------------------------------
-------------------------------------
-------------------------------------
*/
USE [master];
GO

SET NOCOUNT ON; SET ANSI_WARNINGS OFF;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_create_tables (@vdatabaselist VARCHAR(1000)) AS
BEGIN

    DROP TABLE IF EXISTS ##databases;
    DROP TABLE IF EXISTS ##sql_statement;
    DROP TABLE IF EXISTS ##sql_expression_dependencies;
    DROP TABLE IF EXISTS ##self_referencing_objects;
    DROP TABLE IF EXISTS ##sys_objects;
    DROP TABLE IF EXISTS ##path;
    DROP TABLE IF EXISTS ##path_list;
    DROP TABLE IF EXISTS ##path_list_final;

    CREATE TABLE ##databases (
        database_id INT PRIMARY KEY,
        [database_name] VARCHAR(128)
    );

    DECLARE @v_sql_statement NVARCHAR(MAX);
    SET @v_sql_statement = REPLACE('INSERT INTO ##databases (database_id, [database_name]) SELECT database_id, [name] FROM sys.databases WHERE NAME IN (<DATABASE_STRING>);','<DATABASE_STRING>', @vDatabaseList);
    PRINT(@v_sql_statement);
    EXEC sp_executesql @v_sql_statement;

    CREATE TABLE ##sql_expression_dependencies 
    (
        sql_expression_dependencies_id INTEGER IDENTITY(1,1) PRIMARY KEY,
        referencing_id INTEGER NOT NULL,
        referencing_database_name VARCHAR(128),
        referencing_schema_name VARCHAR(128),
        referencing_object_name VARCHAR(128),
        referencing_type_desc VARCHAR(128),
        referenced_id INTEGER,
        referenced_database_name VARCHAR(128),
        referenced_schema_name VARCHAR(128),
        referenced_object_name VARCHAR(128),
        referenced_type_desc VARCHAR(128),
        depth INTEGER,
        referencing_object_fullname VARCHAR(128),
        referenced_object_fullname VARCHAR(128),
        referencing_minor_id INT,
        referencing_class_desc VARCHAR(128),
        is_schema_bound_reference INT,
        referenced_class INT,
        referenced_class_desc VARCHAR(128),
        referenced_server_name VARCHAR(128),
        referenced_minor_id INT,
        is_caller_dependent INT,
        is_ambiguous INT
    );

    CREATE TABLE ##self_referencing_objects 
    (
        sql_expression_dependencies_id INTEGER,
        referencing_id INTEGER NOT NULL,
        referencing_database_name VARCHAR(128),
        referencing_schema_name VARCHAR(128),
        referencing_object_name VARCHAR(128),
        referencing_type_desc VARCHAR(128),
        referenced_id INTEGER,
        referenced_database_name VARCHAR(128),
        referenced_schema_name VARCHAR(128),
        referenced_object_name VARCHAR(128),
        referenced_type_desc VARCHAR(128),
        depth INTEGER,
        referencing_object_fullname VARCHAR(100),
        referenced_object_fullname VARCHAR(100),
        referencing_minor_id INT,
        referencing_class_desc VARCHAR(128),
        is_schema_bound_reference INT,
        referenced_class INT,
        referenced_class_desc VARCHAR(128),
        referenced_server_name VARCHAR(128),
        referenced_minor_id INT,
        is_caller_dependent INT,
        is_ambiguous INT
    );

    CREATE TABLE ##sys_objects (
        [object_id] INTEGER NOT NULL,
        [database_name] VARCHAR(128),
        [schema_name] VARCHAR(128),
        [object_name] VARCHAR(128),
        [type_desc] VARCHAR(128),
        CONSTRAINT PK_sys_objects PRIMARY KEY ([object_id], [database_name])
        );
    
    CREATE TABLE ##path (
        path_id INTEGER IDENTITY(1,1) PRIMARY KEY,
        referencing_schema_name VARCHAR(128) NULL,
        referencing_object_name VARCHAR(128) NULL,
        referencing_object_fullname VARCHAR(128) NULL,
        referenced_object_name VARCHAR(128) NULL,
        referenced_object_fullname VARCHAR(128) NULL,
        referenced_type_desc VARCHAR(128) NULL
    );
    
    CREATE TABLE ##path_list (
        path_list_id INT NOT NULL,
        path VARCHAR(1000) PRIMARY KEY NOT NULL,
        referencing_object_fullname VARCHAR(128) NULL,
        referenced_object_fullname VARCHAR(128) NULL,
        referenced_type_desc VARCHAR(128) NULL
    );
    
    DROP TABLE IF EXISTS ##path_list_final;
    CREATE TABLE ##path_list_final (
        id INTEGER IDENTITY(1,1) PRIMARY KEY,
        path VARCHAR(4000) NOT NULL,
        referenced_object_fullname VARCHAR(128) NULL,
        referenced_type_desc VARCHAR(128) NULL
    );

    CREATE INDEX IX_sql_expression_dependencies_referencing_referenced 
    ON ##sql_expression_dependencies (referencing_object_fullname, referenced_object_fullname) 
    INCLUDE (referencing_id, referenced_id);
     
    CREATE INDEX IX_paths_referencing_referenced
    ON ##path (referencing_object_fullname, referenced_object_fullname)
    INCLUDE (referencing_object_name);
    
    CREATE INDEX IX_pathslist_path_list_id_path
    ON ##path_list (path)
    INCLUDE (referencing_object_fullname, referenced_object_fullname, referenced_type_desc);
    
    CREATE NONCLUSTERED INDEX IX_path_list_path_desc
    ON ##path_list (path, referenced_type_desc);

    CREATE INDEX IX_sys_objects_lookup
    ON ##sys_objects ([database_name], [schema_name], [object_name], [object_id])
    INCLUDE ([type_desc]);
    
    CREATE INDEX IX_sql_expression_dependencies_referenced_id
    ON ##sql_expression_dependencies (referenced_id, referencing_database_name);

END
GO

CREATE OR ALTER PROCEDURE ##temp_sp_insert_sql_statement AS
BEGIN

    SELECT id, rowid, sqlline
    INTO   ##sql_statement
    FROM (VALUES
    -----------------------------------------------
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
    (1, 161, 'referencing_minor_id,'),
    (1, 162, 'referencing_class_desc,'),
    (1, 163, 'is_schema_bound_reference,'),
    (1, 164, 'referenced_class,'),
    (1, 165, 'referenced_class_desc,'),
    (1, 166, 'referenced_server_name,'),
    (1, 167, 'referenced_minor_id,'),
    (1, 168, 'is_caller_dependent,'),
    (1, 169, 'is_ambiguous'),
    (1, 170, ')'),
    -----------------------------------------------
    (1, 180, 'SELECT'),
    (1, 190, 'd.referencing_id,'),
    (1, 200, 'DB_NAME(vdatabase_id) AS referencing_database_name,'),
    (1, 210, 's.[name] AS referencing_schema_name,'),    
    (1, 220, 'o.name AS referencing_object_name,'),
    (1, 230, 'o.type_desc AS referencing_type_desc,'),
    (1, 240, 'd.referenced_database_name,'),
    (1, 250, 'd.referenced_schema_name,'),
    (1, 260, 'd.referenced_entity_name,'),
    (1, 270, 'd.referenced_id,'),
    (1, 271, 'referencing_minor_id,'),
    (1, 272, 'referencing_class_desc,'),
    (1, 273, 'is_schema_bound_reference,'),
    (1, 274, 'referenced_class,'),
    (1, 275, 'referenced_class_desc,'),
    (1, 276, 'referenced_server_name,'),
    (1, 277, 'referenced_minor_id,'),
    (1, 278, 'is_caller_dependent,'),
    (1, 279, 'is_ambiguous'),
    -----------------------------------------------
    (1, 280, 'FROM'),
    (1, 290, 'cte_sql_expression_dependencies d'),
    (1, 300, 'INNER JOIN vdatabase_name.sys.objects o ON d.referencing_id = o.object_id'),
    (1, 310, 'INNER JOIN vdatabase_name.sys.schemas s ON o.schema_id = s.schema_id;'),
    -----------------------------------------------
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
    ) AS a(id, RowID, SQLLine);

END
GO

CREATE OR ALTER PROCEDURE ##temp_sp_cursor_insert_sql_expression_dependencies AS
BEGIN

    DECLARE @v_database_id INT;
    DECLARE @v_database_name NVARCHAR(128);
    DECLARE @v_sql_statement NVARCHAR(MAX);

    DECLARE mycursor CURSOR FOR SELECT database_id, [database_name] FROM ##databases;

    OPEN mycursor;

    FETCH NEXT FROM mycursor INTO @v_database_id, @v_database_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        SELECT @v_sql_statement = STRING_AGG(sqlline, ' ')
        FROM   ##sql_statement
        WHERE  ID = 1;
        
        SET @v_sql_statement = REPLACE(@v_sql_statement, 'vdatabase_name', @v_database_name);
        SET @v_sql_statement = REPLACE(@v_sql_statement, 'vdatabase_id', CAST(@v_database_id AS NVARCHAR));
        
        EXEC sp_executesql @v_sql_statement;

        FETCH NEXT FROM mycursor INTO @v_database_id, @v_database_name;

    END

    -- Close and deallocate the cursor
    CLOSE mycursor;
    DEALLOCATE mycursor;

END
GO

CREATE OR ALTER PROCEDURE ##temp_sp_cursor_insert_sys_objects AS
BEGIN
    
    DECLARE @v_database_id INT;
    DECLARE @v_database_name NVARCHAR(128);
    DECLARE @v_sql_statement NVARCHAR(MAX);

    DECLARE mycursor CURSOR FOR 
    SELECT database_id, [database_name]
    FROM   ##databases;

    OPEN mycursor;

    FETCH NEXT FROM mycursor INTO @v_database_id, @v_database_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        SELECT @v_sql_statement = STRING_AGG(sqlline, ' ') 
        FROM   ##sql_statement 
        WHERE  ID = 2;

        SET @v_sql_statement = REPLACE(@v_sql_statement, 'vdatabase_name', @v_database_name);
        SET @v_sql_statement = REPLACE(@v_sql_statement, 'vdatabase_id', CAST(@v_database_id AS NVARCHAR));

        EXEC sp_executesql @v_sql_statement;

        FETCH NEXT FROM mycursor INTO @v_database_id, @v_database_name;

    END

    CLOSE mycursor;
    DEALLOCATE mycursor;

END
GO

CREATE OR ALTER PROCEDURE ##temp_sp_update_sql_expression_dependencies AS
BEGIN

    SET NOCOUNT ON;
    
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
    PRINT('Update Statement - Count of cross-database dependencies: ' + CAST(@@ROWCOUNT AS VARCHAR(1000)));
    
    UPDATE ##sql_expression_dependencies
    SET    referenced_id = o.[object_id],
           referenced_type_desc = o.[type_desc],
           referenced_database_name = o.[database_name],
           referenced_schema_name = o.[schema_name]
    FROM   ##sql_expression_dependencies db INNER JOIN
           ##sys_objects o ON db.referenced_id = o.[object_id] AND db.referencing_database_name = o.[database_name];
    PRINT('Update Statement - Count of object_types for referenced_objects: ' + CAST(@@ROWCOUNT AS VARCHAR(1000)));
    
    -- remove self-referencing objects
    DELETE ##sql_expression_dependencies
    OUTPUT DELETED.* INTO ##self_referencing_objects
    WHERE  referenced_id = referencing_id;
    PRINT('Delete Statement - Count of self-referencing objects: ' + CAST(@@ROWCOUNT AS VARCHAR(1000)));
    
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
    
    UPDATE ##sql_expression_dependencies
    SET    referenced_object_fullname = CONCAT_WS('.',referenced_database_name, referenced_schema_name, referenced_object_name, ISNULL(referenced_type_desc,'UNKNOWN')),
           referencing_object_fullname = CONCAT_WS('.',referencing_database_name, referencing_schema_name, referencing_object_name, ISNULL(referencing_type_desc,'UNKNOWN'));
    PRINT('Update Statement - Update referenced_object_fullname and referencing_object_fullname columns: ' + CAST(@@ROWCOUNT AS VARCHAR(1000)));
    
END
GO

CREATE OR ALTER PROCEDURE ##temp_sp_determine_paths (@v_object_name VARCHAR(1000)) AS
BEGIN
   
    TRUNCATE TABLE ##path;
    TRUNCATE TABLE ##path_list;
    TRUNCATE TABLE ##path_list_final;

    INSERT INTO ##path (referencing_schema_name, referencing_object_name, referencing_object_fullname, referenced_object_name, referenced_object_fullname, referenced_type_desc)
    SELECT DISTINCT
           referencing_schema_name,
           referencing_object_name,
           referencing_object_fullname,
           referenced_object_name,
           (CASE referenced_object_fullname WHEN 'UNKNOWN' THEN NULL ELSE referenced_object_fullname END) AS referenced_object_fullname,
           referenced_type_desc
    FROM   ##sql_expression_dependencies;
    
    INSERT INTO ##path_list (path_list_id, [path], referencing_object_fullname, referenced_object_fullname, referenced_type_desc)
    SELECT  1 AS path_list_id,
            CONCAT(referencing_object_fullname,',',referenced_object_fullname) AS [path],
            referencing_object_fullname,
            referenced_object_fullname,
            referenced_type_desc
    FROM    ##path
    WHERE   1=1 
            AND CONCAT(referencing_schema_name, '.', referencing_object_name) = @v_object_name
            AND referenced_object_fullname IS NOT NULL;
    
    DECLARE @v_row_count INTEGER = 1;
    DECLARE @v_path_list_id INTEGER = 2;
    
    WHILE @v_row_count >= 1
    BEGIN

         WITH cte_determine_referenced_object AS
         (
         SELECT   [path],
                  REVERSE(SUBSTRING(REVERSE([path]),0,CHARINDEX(',',REVERSE([path])))) AS referenced_object_fullname,
                  referenced_type_desc
         FROM    ##path_list
         WHERE   path_list_id = @v_path_list_id - 1
         )
         INSERT INTO ##path_list (path_list_id, [path], referencing_object_fullname, referenced_object_fullname, referenced_type_desc)
         SELECT  @v_path_list_id,
                 CONCAT(a.[path],',',b.referenced_object_fullname),
                 a.referenced_object_fullname,
                 b.referenced_object_fullname,
                 b.referenced_type_desc
         FROM    cte_determine_referenced_object a
         INNER JOIN ##path b ON a.referenced_object_fullname = b.referencing_object_fullname
                 AND b.referenced_object_fullname IS NOT NULL
                 AND CHARINDEX(b.referenced_object_fullname, a.[path]) = 0;
    
         SET @v_row_count = @@ROWCOUNT;
         PRINT('@v_row_count: ' + CAST(@v_row_count AS VARCHAR(1000)));
    
         SET @v_path_list_id = @v_path_list_id + 1;
    
    END

    INSERT INTO ##path_list_final ([path], referenced_object_fullname, referenced_type_desc)
    SELECT  [path],
            referenced_object_fullname,
            referenced_type_desc
    FROM    ##path_list r1
    WHERE   1=1 AND
            NOT EXISTS (
                SELECT 1 FROM ##path_list r2
                WHERE r2.[path] LIKE r1.[path] + ',%');

    DROP TABLE IF EXISTS ##path_list_rpt;

    SELECT id,
           REPLACE([path],',',N'   ➡️   ') AS [path],
           referenced_object_fullname,
           (LEN([path]) - LEN(REPLACE([path], ',', ''))) / LEN(',') AS depth
    INTO   ##path_list_rpt
    FROM   ##path_list_final;

    SELECT * FROM ##path_list_rpt;

END
GO

CREATE OR ALTER PROCEDURE ##temp_sp_determine_reverse_paths (@v_object_name VARCHAR(1000)) AS
BEGIN

    TRUNCATE TABLE ##path;
    TRUNCATE TABLE ##path_list;
    TRUNCATE TABLE ##path_list_final;

    INSERT INTO ##path (referencing_schema_name, referencing_object_name, referencing_object_fullname, referenced_object_name, referenced_object_fullname, referenced_type_desc)
    SELECT DISTINCT
           referencing_schema_name,
           referencing_object_name,
           referencing_object_fullname,
           referenced_object_name,
           (CASE referenced_object_fullname WHEN 'UNKNOWN' THEN NULL ELSE referenced_object_fullname END) AS referenced_object_fullname,
           referenced_type_desc
    FROM   ##sql_expression_dependencies;

    INSERT INTO ##path_list (path_list_id, [path], referencing_object_fullname, referenced_object_fullname, referenced_type_desc)
    SELECT  1 AS path_list_id,
            CONCAT(referencing_object_fullname,',',referenced_object_fullname) AS [path],
            referencing_object_fullname,
            referenced_object_fullname,
            referenced_type_desc
    FROM    ##path
    WHERE   1=1
            AND CONCAT(referencing_schema_name, '.', referencing_object_name) = @v_object_name
            AND referencing_object_fullname IS NOT NULL;
    
    DECLARE @v_row_count INTEGER = 1;
    DECLARE @v_path_list_id INTEGER = 2;

    WHILE @v_row_count >= 1
    BEGIN

         WITH cte_determine_referencing_object AS
         (
         SELECT   [path],
                  SUBSTRING([path], 1, CHARINDEX(',', [path]) - 1) AS referencing_object_fullname,
                  referenced_type_desc
         FROM    ##path_list
         WHERE   path_list_id = @v_path_list_id - 1
         )
         INSERT INTO ##path_list (path_list_id, [path], referencing_object_fullname, referenced_object_fullname, referenced_type_desc)
         SELECT  @v_path_list_id,
                 CONCAT(b.referencing_object_fullname,',',a.[path]),
                 b.referencing_object_fullname,
                 a.referencing_object_fullname,
                 b.referenced_type_desc
         FROM    cte_determine_referencing_object a
         INNER JOIN ##path b ON a.referencing_object_fullname = b.referenced_object_fullname
                 AND b.referencing_object_fullname IS NOT NULL
                 AND CHARINDEX(b.referencing_object_fullname, a.[path]) = 0;

         SET @v_row_count = @@ROWCOUNT;
         PRINT('@v_row_count: ' + CAST(@v_row_count AS VARCHAR(1000)));

         SET @v_path_list_id = @v_path_list_id + 1;

    END

    INSERT INTO ##path_list_final (path, referenced_object_fullname, referenced_type_desc)
    SELECT  path,
            referenced_object_fullname,
            referenced_type_desc
    FROM    ##path_list r1
    WHERE   1=1 AND
            NOT EXISTS (
                SELECT 1 FROM ##path_list r2
                WHERE r2.[path] LIKE r1.[path] + ',%'
            );

    SELECT  DISTINCT 
            id,
            REPLACE(CASE WHEN [path] LIKE '%,' THEN SUBSTRING([path], 1, LEN([path]) - 1) ELSE [path] END, ',',  N'   ⬅️   ') AS [path], 
            SUBSTRING([path], 1, CHARINDEX(',', [path]) - 1) AS referencing_object_fullname,
            (LEN([path]) - LEN(REPLACE([path], ',', ''))) AS depth            
    FROM    ##path_list_final

END
GO

