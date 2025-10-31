/*----------------------------------------------------------------------------------------------------------

📋 Instructions

Please visit the following URL for instructions
https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Articles/Database%20Dependencies/06_determine_foreign_key_paths.md

1. Update the USE statement for the correct database
2. Create the temporary stored procedures
3. Execute the stored procedures

--------------------------------------------------------
--------------------------------------------------------

-- Use the following to execute the stored procedures

EXECUTE ##temp_sp_master_execution_fk_paths 'Sales.Orders'
EXECUTE ##temp_sp_master_execution_fk_reverse_paths 'Sales.Orders'

-- Use the following to view the foreign key mappings

SELECT * FROM ##table_foreign_keys_map;

----------------------------------------------------------------------------------------------------------*/

USE WideWorldImporters;
GO


CREATE OR ALTER PROCEDURE ##temp_create_tables  AS
BEGIN

    DROP TABLE IF EXISTS ##object_name_paths;
    DROP TABLE IF EXISTS ##table_foreign_keys_map;

    CREATE TABLE ##object_name_paths
    (
        [object_id] INT,
        table_name VARCHAR(256),
        object_name_path NVARCHAR(4000),
        object_id_path NVARCHAR(4000),
        depth INT,
        processed BIT DEFAULT 0
    );
    
    SELECT fk.[name] AS foreign_key_name,
           tp.[object_id] AS parent_object_id,
           s_tp.[name] AS parent_schema,
           CONCAT_WS('.', s_tp.[name], tp.[name]) AS parent_table,
           cp.[name] AS parent_column,
           refp.[object_id] AS referenced_object_id,
           s_ref.[name] AS referenced_schema,
           CONCAT_WS('.', s_ref.[name], refp.[name]) AS referenced_table,
           cref.[name] AS referenced_column
    INTO   ##table_foreign_keys_map
    FROM   sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc 
        ON fkc.constraint_object_id = fk.[object_id]
    INNER JOIN sys.tables tp 
        ON fkc.parent_object_id = tp.[object_id]
    INNER JOIN sys.schemas s_tp 
        ON tp.schema_id = s_tp.schema_id
    INNER JOIN sys.columns cp 
        ON fkc.parent_object_id = cp.[object_id] 
       AND fkc.parent_column_id = cp.column_id
    INNER JOIN sys.tables refp 
        ON fkc.referenced_object_id = refp.[object_id]
    INNER JOIN sys.schemas s_ref 
        ON refp.schema_id = s_ref.schema_id
    INNER JOIN sys.columns cref 
        ON fkc.referenced_object_id = cref.[object_id]
       AND fkc.referenced_column_id = cref.column_id;
    PRINT('Inserted into ##table_foreign_keys_map: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_determine_object_name_paths (@v_object_name VARCHAR(256)) AS
BEGIN
    
    TRUNCATE TABLE ##object_name_paths;

    DECLARE @max_iterations INT = 100;
    DECLARE @iteration INT = 0;

    -- Seed with starting table
    INSERT INTO ##object_name_paths (object_id, table_name, object_name_path, object_id_path, depth, processed)
    SELECT t.object_id,
           CONCAT_WS('.', s.[name], t.[name]) AS table_name,
           CONCAT_WS('.', s.[name], t.[name]) AS object_name_path,
           CAST(t.object_id AS NVARCHAR(100)) AS object_id_path,
           0 AS depth,
           0 AS processed
    FROM   sys.tables t INNER JOIN
           sys.schemas s ON t.schema_id = s.schema_id
    WHERE  s.[name] + '.' + t.[name] = @v_object_name;
    PRINT('Inserted into ##object_name_paths (seed): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    WHILE EXISTS (SELECT 1 FROM ##object_name_paths WHERE processed = 0) AND @iteration < @max_iterations
    BEGIN

        SET @iteration += 1;

        DECLARE @current_object_id INT, @current_path NVARCHAR(MAX), @current_object_id_path NVARCHAR(MAX), @current_depth INT;
        SELECT TOP (1)
               @current_object_id = object_id,
               @current_path = object_name_path,
               @current_object_id_path = object_id_path,
               @current_depth = depth
        FROM   ##object_name_paths
        WHERE  processed = 0
        ORDER BY depth;

        INSERT INTO ##object_name_paths (object_id, table_name, object_name_path, object_id_path, depth, processed)
        SELECT fk.referenced_object_id AS object_id,
               fk.referenced_table AS table_name,
               @current_path + N'  ➡️  ' + fk.referenced_table AS object_name_path,
               @current_object_id_path + N'  ➡️  ' + CAST(fk.referenced_object_id AS NVARCHAR(100)) AS object_id_path,
               @current_depth + 1 AS depth,
               0 AS processed
        FROM ##table_foreign_keys_map fk
        WHERE fk.parent_object_id = @current_object_id
          AND NOT EXISTS (
              SELECT 1 FROM ##object_name_paths
              WHERE object_id = fk.referenced_object_id
              AND object_name_path COLLATE DATABASE_DEFAULT LIKE '%' + fk.referenced_table COLLATE DATABASE_DEFAULT + '%'
          );
        PRINT('Inserted into ##object_name_paths (WHILE loop): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

        INSERT INTO ##object_name_paths (object_id, table_name, object_name_path, object_id_path, depth, processed)
        SELECT fk.parent_object_id AS object_id,
               fk.parent_table AS table_name,
               @current_path + N'  ➡️  ' + fk.parent_table AS object_name_path,
               @current_object_id_path + N'  ➡️  ' + CAST(fk.parent_object_id AS NVARCHAR(100)) AS object_id_path,
               @current_depth + 1 AS depth, 
               0 AS processed
        FROM ##table_foreign_keys_map fk
        WHERE fk.referenced_object_id = @current_object_id
          AND NOT EXISTS (
              SELECT 1 FROM ##object_name_paths
              WHERE object_id = fk.parent_object_id
              AND object_name_path COLLATE DATABASE_DEFAULT LIKE '%' + fk.parent_table COLLATE DATABASE_DEFAULT + '%'
          );
        PRINT('Inserted into ##object_name_paths (WHILE loop): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

        UPDATE ##object_name_paths
        SET    processed = 1
        WHERE  object_id = @current_object_id AND object_name_path = @current_path;
        PRINT('Update ##object_name_paths (WHILE loop): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

    END;

    SELECT DISTINCT
           table_name,
           object_name_path,
           depth,
           object_id_path
    FROM ##object_name_paths
    ORDER BY object_name_path, depth;
    PRINT('Select from ##object_name_paths: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));
END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_determine_object_name_paths_reverse (@v_object_name VARCHAR(256)) AS
BEGIN

    TRUNCATE TABLE ##object_name_paths;

    DECLARE @max_iterations INT = 100;
    DECLARE @iteration INT = 0;
    
    -- Seed the table
    INSERT INTO ##object_name_paths (object_id, table_name, object_name_path, object_id_path, depth, processed)
    SELECT t.object_id,
           CONCAT_WS('.', s.[name], t.[name]) AS table_name,
           CONCAT_WS('.', s.[name], t.[name]) AS object_name_path,
           CAST(t.object_id AS NVARCHAR(100)) AS object_id_path,
           0 AS depth,
           0 AS processed
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.[name] + '.' + t.[name] = @v_object_name;
    PRINT('Inserted into ##object_name_paths (seed): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));
    
    WHILE EXISTS (SELECT 1 FROM ##object_name_paths WHERE processed = 0) AND @iteration < @max_iterations
    BEGIN

        SET @iteration += 1;

        DECLARE @current_object_id INT, @current_path NVARCHAR(MAX), @current_object_id_path NVARCHAR(MAX), @current_depth INT;
        SELECT TOP (1)
               @current_object_id = object_id,
               @current_path = object_name_path,
               @current_object_id_path = object_id_path,
               @current_depth = depth
        FROM   ##object_name_paths
        WHERE  processed = 0
        ORDER BY depth;

        INSERT INTO ##object_name_paths (object_id, table_name, object_name_path, object_id_path, depth, processed)
        SELECT fk.parent_object_id AS object_id,
               fk.parent_table AS table_name,
               fk.parent_table + N' ⬅️ ' + @current_path AS object_name_path,
               CAST(fk.parent_object_id AS NVARCHAR(100)) + N' ⬅️ ' + @current_object_id_path AS object_id_path,
               @current_depth + 1 AS depth,
               0 AS processed
        FROM ##table_foreign_keys_map fk
        WHERE fk.referenced_object_id = @current_object_id
          AND NOT EXISTS (
              SELECT 1 FROM ##object_name_paths
              WHERE object_id = fk.parent_object_id
              AND object_name_path COLLATE DATABASE_DEFAULT LIKE '%' + fk.parent_table COLLATE DATABASE_DEFAULT + '%'
          );
        PRINT('Inserted into ##object_name_paths (WHILE loop): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));
        
        UPDATE ##object_name_paths
        SET    processed = 1
        WHERE  object_id = @current_object_id AND object_name_path = @current_path;
        PRINT('Update ##object_name_paths (WHILE loop): ' + CAST(@@ROWCOUNT AS VARCHAR(100)));
    END;

    SELECT DISTINCT
           table_name,
           object_name_path,
           depth,
           object_id_path
    FROM   ##object_name_paths
    ORDER BY depth, object_name_path;
    PRINT('Select from ##object_name_paths: ' + CAST(@@ROWCOUNT AS VARCHAR(100)));

END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_master_execution_fk_paths (@v_object_name VARCHAR(256)) AS
BEGIN
    EXECUTE ##temp_create_tables;
    EXECUTE ##temp_sp_determine_object_name_paths @v_object_name;
END;
GO

CREATE OR ALTER PROCEDURE ##temp_sp_master_execution_fk_reverse_paths (@v_object_name VARCHAR(256)) AS
BEGIN
    EXECUTE ##temp_create_tables;
    EXECUTE ##temp_sp_determine_object_name_paths_reverse @v_object_name;
END;
GO
