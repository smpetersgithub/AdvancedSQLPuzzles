USE WideWorldImporters;
GO

/*

📋 Instructions

Please visit the following URL for instructions.

https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies

1. Update the USE statement for the correct database
2. Create the temporary stored procedures
3. Execute the stored procedures

--------------------------------------------------------
--------------------------------------------------------

Please use the following to execute the stored procedures.

EXECUTE ##temp_create_tables;
GO
EXECUTE ##temp_sp_determine_fk_paths 'dbo.Orders';
GO
EXECUTE ##temp_sp_determine_fk_paths_reverse 'dbo.Orders';
GO

--View the FK mappings
SELECT * FROM ##table_foreign_keys_map;

*/

CREATE OR ALTER PROCEDURE ##temp_create_tables 
AS
BEGIN
    DROP TABLE IF EXISTS ##fk_paths;
    CREATE TABLE ##fk_paths
    (
        table_id   INTEGER,
        table_name SYSNAME,
        [path]     NVARCHAR(MAX),
        depth     INT,
        processed BIT DEFAULT 0
    );
    
    DROP TABLE IF EXISTS ##table_foreign_keys_map;
    SELECT  
        fk.[name] AS foreign_key_name,
        tp.[object_id] AS parent_table_id,
        s_tp.[name] AS parent_schema,
        CONCAT_WS('.', s_tp.[name], tp.[name]) AS parent_table,
        cp.[name] AS parent_column,
        refp.[object_id] AS referenced_table_id,
        s_ref.[name] AS referenced_schema,
        CONCAT_WS('.', s_ref.[name], refp.[name]) AS referenced_table,
        cref.[name] AS referenced_column
    INTO ##table_foreign_keys_map
    FROM sys.foreign_keys fk
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
END;
GO

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ##temp_sp_determine_fk_paths (@v_object_name VARCHAR(1000)) AS
BEGIN
    DECLARE @max_iterations INT = 100;
    DECLARE @iteration INT = 0;

    -- Seed with starting table
    INSERT INTO ##fk_paths (table_id, table_name, [path], depth, processed)
    SELECT 
        t.object_id, 
        s.[name] + '.' + t.[name],
        s.[name] + '.' + t.[name],
        0, 
        0
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.[name] + '.' + t.[name] = @v_object_name;

    -- Loop until no more unprocessed or max iteration
    WHILE EXISTS (SELECT 1 FROM ##fk_paths WHERE processed = 0) AND @iteration < @max_iterations
    BEGIN
        SET @iteration += 1;

        DECLARE @current_table_id INT, @current_path NVARCHAR(MAX), @current_depth INT;
        SELECT TOP (1)
            @current_table_id = table_id,
            @current_path = [path],
            @current_depth = depth
        FROM ##fk_paths
        WHERE processed = 0
        ORDER BY depth;

        -- From parent -> child (referenced table)
        INSERT INTO ##fk_paths (table_id, table_name, [path], depth, processed)
        SELECT fk.referenced_table_id, fk.referenced_table,
               @current_path + N'  ➡️  ' + fk.referenced_table,
               @current_depth + 1, 0
        FROM ##table_foreign_keys_map fk
        WHERE fk.parent_table_id = @current_table_id
          AND NOT EXISTS (
              SELECT 1 FROM ##fk_paths 
              WHERE table_id = fk.referenced_table_id 
              AND [path] COLLATE DATABASE_DEFAULT LIKE '%' + fk.referenced_table COLLATE DATABASE_DEFAULT + '%'
          );

        -- From child -> parent (parent table)
        INSERT INTO ##fk_paths (table_id, table_name, [path], depth, processed)
        SELECT fk.parent_table_id, fk.parent_table,
               @current_path + N' ➡️ ' + fk.parent_table,
               @current_depth + 1, 0
        FROM ##table_foreign_keys_map fk
        WHERE fk.referenced_table_id = @current_table_id
          AND NOT EXISTS (
              SELECT 1 FROM ##fk_paths 
              WHERE table_id = fk.parent_table_id 
              AND [path] COLLATE DATABASE_DEFAULT LIKE '%' + fk.parent_table COLLATE DATABASE_DEFAULT + '%'
          );

        -- Mark processed
        UPDATE ##fk_paths
        SET processed = 1
        WHERE table_id = @current_table_id AND [path] = @current_path;
    END;

    -- Final results
    SELECT DISTINCT @@SERVERNAME AS server_name, table_name, [path], depth
    FROM ##fk_paths
    ORDER BY [path], depth;
END;
GO


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ##temp_sp_determine_fk_paths_reverse (@v_object_name SYSNAME) AS
BEGIN
    DECLARE @max_iterations INT = 100;
    DECLARE @iteration INT = 0;

    IF OBJECT_ID('tempdb..##fk_paths') IS NOT NULL
        DELETE FROM ##fk_paths;

    -- Seed with starting table
    INSERT INTO ##fk_paths (table_id, table_name, [path], depth, processed)
    SELECT 
        t.object_id, 
        s.[name] + '.' + t.[name],
        s.[name] + '.' + t.[name],
        0, 
        0
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.[name] + '.' + t.[name] = @v_object_name;

    -- Loop until no more unprocessed or max iteration
    WHILE EXISTS (SELECT 1 FROM ##fk_paths WHERE processed = 0) AND @iteration < @max_iterations
    BEGIN
        SET @iteration += 1;

        DECLARE @current_table_id INT, @current_path NVARCHAR(MAX), @current_depth INT;
        SELECT TOP (1)
            @current_table_id = table_id,
            @current_path = [path],
            @current_depth = depth
        FROM ##fk_paths
        WHERE processed = 0
        ORDER BY depth;

        -- From child → parent
        INSERT INTO ##fk_paths (table_id, table_name, [path], depth, processed)
        SELECT fk.parent_table_id, fk.parent_table,
               fk.parent_table + N' ⬅️ ' + @current_path,
               @current_depth + 1, 0
        FROM ##table_foreign_keys_map fk
        WHERE fk.referenced_table_id = @current_table_id
          AND NOT EXISTS (
              SELECT 1 FROM ##fk_paths 
              WHERE table_id = fk.parent_table_id 
              AND [path] COLLATE DATABASE_DEFAULT LIKE '%' + fk.parent_table COLLATE DATABASE_DEFAULT + '%'
          );

        -- Mark as processed
        UPDATE ##fk_paths
        SET processed = 1
        WHERE table_id = @current_table_id AND [path] = @current_path;
    END;

    -- Final results
    SELECT DISTINCT @@SERVERNAME AS ServerName, table_name, [path], depth
    FROM ##fk_paths
    ORDER BY depth, [path];
END;
GO
