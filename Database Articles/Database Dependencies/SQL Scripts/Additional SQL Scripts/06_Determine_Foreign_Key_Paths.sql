/*----------------------------------------------------------------------------------------------------------

Determine Foreign Key Paths

📋 Instructions

Please visit the following URL for instructions
https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/06_determine_foreign_key_paths.md

1. Update the USE statement for the correct database
2. Create the temporary stored procedures
3. Execute the stored procedures

--------------------------------------------------------
--------------------------------------------------------

-- Use the following to execute the stored procedures

EXECUTE ##temp_sp_master_execution_foreign_key_paths 'Sales.Orders';
EXECUTE ##temp_sp_master_execution_foreign_key_reverse_paths 'Sales.Orders';

-- Use the following to view the foreign key mappings

SELECT * FROM ##foreign_keys_map;

----------------------------------------------------------------------------------------------------------*/

USE qa07_greg;
GO

-- Creates all temporary tables needed for foreign key path analysis
CREATE OR ALTER PROCEDURE ##temp_create_tables  AS
BEGIN

    PRINT('Executing ##temp_create_tables');

    -- Drop existing temporary tables to ensure clean state
    DROP TABLE IF EXISTS ##foreign_key_paths;
    DROP TABLE IF EXISTS ##foreign_key_reverse_paths;

    DROP TABLE IF EXISTS ##foreign_keys_map;

    -- Stores forward foreign key paths
    CREATE TABLE ##foreign_key_paths
    (
        [object_id] INT,
        table_name VARCHAR(256),
        object_name_path NVARCHAR(4000),
        object_id_path NVARCHAR(4000),
        depth INT,
        processed BIT DEFAULT 0
    );

    -- Stores reverse foreign key paths
    CREATE TABLE ##foreign_key_reverse_paths
    (
        [object_id] INT,
        table_name VARCHAR(256),
        object_name_path NVARCHAR(4000),
        object_id_path NVARCHAR(4000),
        depth INT,
        processed BIT DEFAULT 0
    );

    -- Build foreign key mapping table from system tables
    SELECT fk.[name] AS foreign_key_name,
           tp.[object_id] AS parent_object_id,
           s_tp.[name] AS parent_schema,
           CONCAT_WS('.', s_tp.[name], tp.[name]) AS parent_table,
           cp.[name] AS parent_column,
           refp.[object_id] AS child_id,
           s_ref.[name] AS child_schema,
           CONCAT_WS('.', s_ref.[name], refp.[name]) AS child_table,
           cref.[name] AS child_column
    INTO   ##foreign_keys_map
    FROM   sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc
        ON fkc.constraint_object_id = fk.[object_id]
    INNER JOIN sys.tables tp
        ON fkc.parent_object_id = tp.[object_id]
    INNER JOIN sys.schemas s_tp
        ON tp.[schema_id] = s_tp.[schema_id]
    INNER JOIN sys.columns cp
        ON fkc.parent_object_id = cp.[object_id]
       AND fkc.parent_column_id = cp.column_id
    INNER JOIN sys.tables refp
        ON fkc.referenced_object_id = refp.[object_id]
    INNER JOIN sys.schemas s_ref
        ON refp.[schema_id] = s_ref.[schema_id]
    INNER JOIN sys.columns cref
        ON fkc.referenced_object_id = cref.[object_id]
       AND fkc.referenced_column_id = cref.column_id;
    PRINT(CONCAT('Inserted into ##foreign_keys_map: ', @@ROWCOUNT));

END;
GO

-- Determines forward foreign key paths from a starting table
CREATE OR ALTER PROCEDURE ##temp_sp_determine_foreign_key_paths (@v_object_name VARCHAR(256)) AS
BEGIN

    PRINT('Executing ##temp_sp_determine_foreign_key_paths');

    TRUNCATE TABLE ##foreign_key_paths;

    DECLARE @max_iterations INT = 100;
    DECLARE @iteration INT = 0;

    -- Seed with starting table
    INSERT INTO ##foreign_key_paths ([object_id], table_name, object_name_path, object_id_path, depth, processed)
    SELECT t.[object_id],
           CONCAT_WS('.', s.[name], t.[name]) AS table_name,
           CONCAT_WS('.', s.[name], t.[name]) AS object_name_path,
           CAST(t.object_id AS NVARCHAR(100)) AS object_id_path,
           0 AS depth,
           0 AS processed
    FROM   sys.tables t INNER JOIN
           sys.schemas s ON t.[schema_id] = s.[schema_id]
    WHERE  s.[name] + '.' + t.[name] = @v_object_name;
    PRINT(CONCAT('Inserted into ##foreign_key_paths (seed): ', @@ROWCOUNT));

    -- Process unprocessed paths iteratively
    WHILE EXISTS (SELECT 1 FROM ##foreign_key_paths WHERE processed = 0) AND @iteration < @max_iterations
    BEGIN

        PRINT('Entering WHILE loop');
        SET @iteration += 1;
        PRINT(CONCAT('Current @iteration is ', @iteration));

        -- Get next unprocessed path
        DECLARE @current_object_id INT, @current_path NVARCHAR(MAX), @current_object_id_path NVARCHAR(MAX), @current_depth INT;
        SELECT TOP (1)
               @current_object_id = [object_id],
               @current_path = object_name_path,
               @current_object_id_path = object_id_path,
               @current_depth = depth
        FROM   ##foreign_key_paths
        WHERE  processed = 0
        ORDER BY depth;

        -- Add child tables (tables that reference current table)
        INSERT INTO ##foreign_key_paths ([object_id], table_name, object_name_path, object_id_path, depth, processed)
        SELECT fk.child_id AS [object_id],
               fk.child_table AS table_name,
               CONCAT_WS(N' ➡️ ', @current_path, fk.child_table) AS object_name_path,
               CONCAT_WS(N' ➡️ ', @current_object_id_path, fk.child_id) AS object_id_path,
               @current_depth + 1 AS depth,
               0 AS processed
        FROM ##foreign_keys_map fk
        WHERE fk.parent_object_id = @current_object_id
          AND NOT EXISTS (
              SELECT 1 FROM ##foreign_key_paths
              WHERE [object_id] = fk.child_id
              AND object_name_path COLLATE DATABASE_DEFAULT LIKE '%' + fk.child_table COLLATE DATABASE_DEFAULT + '%'
          );
        PRINT(CONCAT('Inserted into ##foreign_key_paths (WHILE loop): ', @@ROWCOUNT));

        -- Add parent tables (tables that current table references)
        INSERT INTO ##foreign_key_paths ([object_id], table_name, object_name_path, object_id_path, depth, processed)
        SELECT fk.parent_object_id AS [object_id],
               fk.parent_table AS table_name,
               CONCAT_WS(N' ➡️ ', @current_path, fk.parent_table) AS object_name_path,
               CONCAT_WS(N' ➡️ ', @current_object_id_path, fk.parent_object_id) AS object_id_path,
               @current_depth + 1 AS depth,
               0 AS processed
        FROM ##foreign_keys_map fk
        WHERE fk.child_id = @current_object_id
          AND NOT EXISTS (
              SELECT 1 FROM ##foreign_key_paths
              WHERE [object_id] = fk.parent_object_id
              AND object_name_path COLLATE DATABASE_DEFAULT LIKE '%' + fk.parent_table COLLATE DATABASE_DEFAULT + '%'
          );
        PRINT(CONCAT('Inserted into ##foreign_key_paths (WHILE loop): ', @@ROWCOUNT));

        -- Mark current path as processed
        UPDATE ##foreign_key_paths
        SET    processed = 1
        WHERE  [object_id] = @current_object_id AND object_name_path = @current_path;
        PRINT(CONCAT('Update ##foreign_key_paths (WHILE loop): ', @@ROWCOUNT));

    END;

    -- Return final results
    SELECT DISTINCT
           table_name,
           object_name_path,
           depth,
           object_id_path
    FROM   ##foreign_key_paths
    ORDER BY object_name_path, depth;
    PRINT(CONCAT('Select from ##foreign_key_paths: ', @@ROWCOUNT));
END;
GO

-- Determines reverse foreign key paths (what references the starting table)
CREATE OR ALTER PROCEDURE ##temp_sp_determine_foreign_key_paths_reverse (@v_object_name VARCHAR(256)) AS
BEGIN

    PRINT('Executing ##temp_sp_determine_foreign_key_paths_reverse');

    TRUNCATE TABLE ##foreign_key_reverse_paths;

    DECLARE @max_iterations INT = 100;
    DECLARE @iteration INT = 0;

    -- Seed the table with starting table
    INSERT INTO ##foreign_key_reverse_paths ([object_id], table_name, object_name_path, object_id_path, depth, processed)
    SELECT t.[object_id],
           CONCAT_WS('.', s.[name], t.[name]) AS table_name,
           CONCAT_WS('.', s.[name], t.[name]) AS object_name_path,
           CAST(t.[object_id] AS NVARCHAR(100)) AS object_id_path,
           0 AS depth,
           0 AS processed
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
    WHERE CONCAT_WS('.', s.[name], t.[name]) = @v_object_name;
    PRINT(CONCAT('Inserted into ##foreign_key_reverse_paths (seed): ', @@ROWCOUNT));

    -- Process unprocessed paths iteratively
    WHILE EXISTS (SELECT 1 FROM ##foreign_key_reverse_paths WHERE processed = 0) AND @iteration < @max_iterations
    BEGIN

        PRINT('Entering WHILE loop');
        SET @iteration += 1;
        PRINT(CONCAT('Current @iteration is ', @iteration));

        -- Get next unprocessed path
        DECLARE @current_object_id INT, @current_path NVARCHAR(MAX), @current_object_id_path NVARCHAR(MAX), @current_depth INT;
        SELECT TOP (1)
               @current_object_id = [object_id],
               @current_path = object_name_path,
               @current_object_id_path = object_id_path,
               @current_depth = depth
        FROM   ##foreign_key_reverse_paths
        WHERE  processed = 0
        ORDER BY depth;

        -- Add parent tables (tables that reference current table)
        INSERT INTO ##foreign_key_reverse_paths ([object_id], table_name, object_name_path, object_id_path, depth, processed)
        SELECT fk.parent_object_id AS [object_id],
               fk.parent_table AS table_name,
               CONCAT_WS(N' ⬅️ ', fk.parent_table, @current_path) AS object_name_path,
               CONCAT_WS(N' ⬅️ ', fk.parent_object_id, @current_object_id_path) AS object_id_path,
               @current_depth + 1 AS depth,
               0 AS processed
        FROM ##foreign_keys_map fk
        WHERE fk.child_id = @current_object_id
          AND NOT EXISTS (
              SELECT 1 FROM ##foreign_key_reverse_paths
              WHERE [object_id] = fk.parent_object_id
              AND object_name_path COLLATE DATABASE_DEFAULT LIKE '%' + fk.parent_table COLLATE DATABASE_DEFAULT + '%'
          );
        PRINT(CONCAT('Inserted into ##foreign_key_reverse_paths (WHILE loop): ', @@ROWCOUNT));

        -- Mark current path as processed
        UPDATE ##foreign_key_reverse_paths
        SET    processed = 1
        WHERE  object_id = @current_object_id AND object_name_path = @current_path;
        PRINT(CONCAT('Update ##foreign_key_reverse_paths (WHILE loop): ', @@ROWCOUNT));
    END;

    -- Return final results
    SELECT DISTINCT
           table_name,
           object_name_path,
           depth,
           object_id_path
    FROM   ##foreign_key_reverse_paths
    ORDER BY depth, object_name_path;
    PRINT(CONCAT('Select from ##foreign_key_reverse_paths: ', @@ROWCOUNT));

END;
GO

-- Master procedure to execute forward foreign key path analysis
CREATE OR ALTER PROCEDURE ##temp_sp_master_execution_foreign_key_paths (@v_object_name VARCHAR(256)) AS
BEGIN

    PRINT('Executing ##temp_sp_master_execution_fk_paths');

    EXECUTE ##temp_create_tables;
    EXECUTE ##temp_sp_determine_foreign_key_paths @v_object_name;
END;
GO

-- Master procedure to execute reverse foreign key path analysis
CREATE OR ALTER PROCEDURE ##temp_sp_master_execution_foreign_key_reverse_paths (@v_object_name VARCHAR(256)) AS
BEGIN

    PRINT('Executing ##temp_sp_master_execution_fk_reverse_paths');

    EXECUTE ##temp_create_tables;
    EXECUTE ##temp_sp_determine_foreign_key_paths_reverse @v_object_name;
END;
GO

SELECT * FROM ##foreign_keys_map;

EXECUTE ##temp_sp_master_execution_foreign_key_paths 'dbo.Patient';
EXECUTE ##temp_sp_master_execution_foreign_key_reverse_paths 'dbo.Patient';


