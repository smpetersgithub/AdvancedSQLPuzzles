USE WideWorldImporters;
GO

/*

📋 Instructions

Please vist the following URL for instructions.

1. Update the USE statement for the correct database
1. Create the temporary stored procedures
2. Set the variables
3. Execute the stored procedures in the same session.

--------------------------------------------------------
--------------------------------------------------------

Please use the following to execute the stored procedures.

EXECUTE ##temp_create_tables;
EXECUTE ##temp_sp_determine_fk_paths 'Orders';
EXECUTE ##temp_sp_determine_fk_paths_reverse 'Orders';


--View the FK mappings
SELECT * FROM ##Table_Foreign_Keys_Map;


*/

USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE ##temp_create_tables 
AS
BEGIN
    DROP TABLE IF EXISTS ##Paths;
    CREATE TABLE ##Paths
    (
        TableID   INTEGER,
        TableName SYSNAME,
        [Path]   NVARCHAR(MAX),
        Depth     INT,
        Processed BIT DEFAULT 0
    );
    
    DROP TABLE IF EXISTS ##Table_Foreign_Keys_Map;
    SELECT  
        fk.[name] AS ForeignKeyName,
        tp.[object_id] AS ParentTableID,
        s_tp.[name] AS ParentSchema,
        CONCAT_WS('.', s_tp.[name], tp.[name]) AS ParentTable,
        cp.[name] AS ParentColumn,
        refp.[object_id] AS ReferencedTableID,
        s_ref.[name] AS ReferencedSchema,
        CONCAT_WS('.', s_ref.[name], refp.[name]) AS ReferencedTable,
        cref.[name] AS ReferencedColumn
    INTO ##Table_Foreign_Keys_Map
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
    DECLARE @MaxIterations INT = 100;
    DECLARE @Iteration INT = 0;

    -- Seed with starting table
    INSERT INTO ##Paths (TableID, TableName, [Path], Depth, Processed)
    SELECT 
        t.object_id, 
        s.[name] + '.' + t.[name],
        s.[name] + '.' + t.[name],
        0, 
        0
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.[name] = @v_object_name;

    -- Loop until no more unprocessed or max iteration
    WHILE EXISTS (SELECT 1 FROM ##Paths WHERE Processed = 0) AND @Iteration < @MaxIterations
    BEGIN
        SET @Iteration += 1;

        DECLARE @CurrentTableID INT, @CurrentPath NVARCHAR(MAX), @CurrentDepth INT;
        SELECT TOP (1)
            @CurrentTableID = TableID,
            @CurrentPath = [Path],
            @CurrentDepth = Depth
        FROM ##Paths
        WHERE Processed = 0
        ORDER BY Depth;

        -- From parent -> child (referenced table)
        INSERT INTO ##Paths (TableID, TableName, [Path], Depth, Processed)
        SELECT fk.ReferencedTableID, fk.ReferencedTable,
               @CurrentPath + N'  ➡️  ' + fk.ReferencedTable,
               @CurrentDepth + 1, 0
        FROM ##Table_Foreign_Keys_Map fk
        WHERE fk.ParentTableID = @CurrentTableID
          AND NOT EXISTS (
              SELECT 1 FROM ##Paths 
              WHERE TableID = fk.ReferencedTableID 
              AND [Path] COLLATE DATABASE_DEFAULT LIKE '%' + fk.ReferencedTable COLLATE DATABASE_DEFAULT + '%'
          );

        -- From child -> parent (parent table)
        INSERT INTO ##Paths (TableID, TableName, [Path], Depth, Processed)
        SELECT fk.ParentTableID, fk.ParentTable,
               @CurrentPath + N' ➡️ ' + fk.ParentTable,
               @CurrentDepth + 1, 0
        FROM ##Table_Foreign_Keys_Map fk
        WHERE fk.ReferencedTableID = @CurrentTableID
          AND NOT EXISTS (
              SELECT 1 FROM ##Paths 
              WHERE TableID = fk.ParentTableID 
              AND [Path] COLLATE DATABASE_DEFAULT LIKE '%' + fk.ParentTable COLLATE DATABASE_DEFAULT + '%'
          );

        -- Mark processed
        UPDATE ##Paths
        SET Processed = 1
        WHERE TableID = @CurrentTableID AND [Path] = @CurrentPath;
    END;

    -- Final results
    SELECT DISTINCT @@SERVERNAME AS ServerName, TableName, [Path], Depth
    FROM ##Paths
    ORDER BY Path, Depth;
END;
GO


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ##temp_sp_determine_fk_paths_reverse (@v_object_name SYSNAME) AS
BEGIN
    DECLARE @MaxIterations INT = 100;
    DECLARE @Iteration INT = 0;

    IF OBJECT_ID('tempdb..##Paths') IS NOT NULL
        DELETE FROM ##Paths;

    -- Seed with starting table
    INSERT INTO ##Paths (TableID, TableName, [Path], Depth, Processed)
    SELECT 
        t.object_id, 
        s.[name] + '.' + t.[name],
        s.[name] + '.' + t.[name],
        0, 
        0
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.[name] = @v_object_name;

    -- Loop until no more unprocessed or max iteration
    WHILE EXISTS (SELECT 1 FROM ##Paths WHERE Processed = 0) AND @Iteration < @MaxIterations
    BEGIN
        SET @Iteration += 1;

        DECLARE @CurrentTableID INT, @CurrentPath NVARCHAR(MAX), @CurrentDepth INT;
        SELECT TOP (1)
            @CurrentTableID = TableID,
            @CurrentPath = [Path],
            @CurrentDepth = Depth
        FROM ##Paths
        WHERE Processed = 0
        ORDER BY Depth;

        -- From child → parent
        INSERT INTO ##Paths (TableID, TableName, [Path], Depth, Processed)
        SELECT fk.ParentTableID, fk.ParentTable,
               fk.ParentTable + N' ⬅️ ' + @CurrentPath,
               @CurrentDepth + 1, 0
        FROM ##Table_Foreign_Keys_Map fk
        WHERE fk.ReferencedTableID = @CurrentTableID
          AND NOT EXISTS (
              SELECT 1 FROM ##Paths 
              WHERE TableID = fk.ParentTableID 
              AND [Path] COLLATE DATABASE_DEFAULT LIKE '%' + fk.ParentTable COLLATE DATABASE_DEFAULT + '%'
          );

        -- Mark as processed
        UPDATE ##Paths
        SET Processed = 1
        WHERE TableID = @CurrentTableID AND [Path] = @CurrentPath;
    END;

    -- Final results
    SELECT DISTINCT @@SERVERNAME AS ServerName, TableName, [Path], Depth
    FROM ##Paths
    ORDER BY Depth, [Path];
END;
GO
