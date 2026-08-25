
/*
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
*/



USE WideWorldImporters;
GO

/* Create the global temporary working tables. */
CREATE OR ALTER PROCEDURE ##temp_create_tables
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS ##foreign_key_paths;
    DROP TABLE IF EXISTS ##foreign_key_reverse_paths;
    DROP TABLE IF EXISTS ##foreign_key_table_map;
    DROP TABLE IF EXISTS ##foreign_keys_map;

    /* One row for each table reached during forward traversal. */
    CREATE TABLE ##foreign_key_paths
    (
        object_id        INT            NOT NULL PRIMARY KEY,
        table_name       NVARCHAR(257)  NOT NULL,
        object_name_path NVARCHAR(MAX)  NOT NULL,
        object_id_path   NVARCHAR(MAX)  NOT NULL,
        depth            INT            NOT NULL,
        processed        BIT            NOT NULL DEFAULT (0)
    );

    /* One row for each table reached during reverse traversal. */
    CREATE TABLE ##foreign_key_reverse_paths
    (
        object_id        INT            NOT NULL PRIMARY KEY,
        table_name       NVARCHAR(257)  NOT NULL,
        object_name_path NVARCHAR(MAX)  NOT NULL,
        object_id_path   NVARCHAR(MAX)  NOT NULL,
        depth            INT            NOT NULL,
        processed        BIT            NOT NULL DEFAULT (0)
    );

    /*
       Column-level foreign-key map. In sys.foreign_key_columns:
         parent_object_id     = referencing table
         referenced_object_id = referenced table
    */
    SELECT  fk.object_id AS foreign_key_id,
            fk.name AS foreign_key_name,
            fkc.constraint_column_id,
            referencing_table.object_id AS referencing_object_id,
            referencing_schema.name AS referencing_schema,
            CONCAT(referencing_schema.name, N'.', referencing_table.name) AS referencing_table,
            referencing_column.column_id AS referencing_column_id,
            referencing_column.name AS referencing_column,
            referenced_table.object_id AS referenced_object_id,
            referenced_schema.name AS referenced_schema,
            CONCAT(referenced_schema.name, N'.', referenced_table.name) AS referenced_table,
            referenced_column.column_id AS referenced_column_id,
            referenced_column.name AS referenced_column,
            fk.is_disabled,
            fk.is_not_trusted
    INTO ##foreign_keys_map
    FROM sys.foreign_keys AS fk
    INNER JOIN sys.foreign_key_columns AS fkc
        ON fkc.constraint_object_id = fk.object_id
    INNER JOIN sys.tables AS referencing_table
        ON referencing_table.object_id = fkc.parent_object_id
    INNER JOIN sys.schemas AS referencing_schema
        ON referencing_schema.schema_id = referencing_table.schema_id
    INNER JOIN sys.columns AS referencing_column
        ON referencing_column.object_id = fkc.parent_object_id
       AND referencing_column.column_id = fkc.parent_column_id
    INNER JOIN sys.tables AS referenced_table
        ON referenced_table.object_id = fkc.referenced_object_id
    INNER JOIN sys.schemas AS referenced_schema
        ON referenced_schema.schema_id = referenced_table.schema_id
    INNER JOIN sys.columns AS referenced_column
        ON referenced_column.object_id = fkc.referenced_object_id
       AND referenced_column.column_id = fkc.referenced_column_id;

    /*
       Table-level adjacency map used for traversal. Build it directly from the catalog views so
       procedure compilation cannot bind this statement to an older ##foreign_keys_map schema.
       DISTINCT collapses composite foreign keys and multiple constraints between the same tables.
    */
    SELECT DISTINCT
           referencing_table.object_id AS referencing_object_id,
           CONCAT(referencing_schema.name, N'.', referencing_table.name) AS referencing_table,
           referenced_table.object_id AS referenced_object_id,
           CONCAT(referenced_schema.name, N'.', referenced_table.name) AS referenced_table
    INTO ##foreign_key_table_map
    FROM sys.foreign_key_columns AS fkc
    INNER JOIN sys.tables AS referencing_table
        ON referencing_table.object_id = fkc.parent_object_id
    INNER JOIN sys.schemas AS referencing_schema
        ON referencing_schema.schema_id = referencing_table.schema_id
    INNER JOIN sys.tables AS referenced_table
        ON referenced_table.object_id = fkc.referenced_object_id
    INNER JOIN sys.schemas AS referenced_schema
        ON referenced_schema.schema_id = referenced_table.schema_id;

    CREATE UNIQUE CLUSTERED INDEX CIX_foreign_key_table_map
        ON ##foreign_key_table_map
           (referencing_object_id, referenced_object_id);

    CREATE NONCLUSTERED INDEX IX_foreign_key_table_map_reverse
        ON ##foreign_key_table_map
           (referenced_object_id, referencing_object_id)
        INCLUDE (referencing_table, referenced_table);
END;
GO

/* Resolve and validate a starting table, then trace tables that it references. */
CREATE OR ALTER PROCEDURE ##temp_sp_determine_foreign_key_paths
    @v_object_name NVARCHAR(776)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @database_name SYSNAME = PARSENAME(@v_object_name, 3);
    DECLARE @schema_name   SYSNAME = PARSENAME(@v_object_name, 2);
    DECLARE @table_name    SYSNAME = PARSENAME(@v_object_name, 1);

    IF PARSENAME(@v_object_name, 4) IS NOT NULL
        THROW 50001, 'Use a two-part or three-part table name.', 1;

    IF @schema_name IS NULL OR @table_name IS NULL
        THROW 50002, 'Specify the table as schema.table or database.schema.table.', 1;

    IF @database_name IS NOT NULL
       AND @database_name COLLATE DATABASE_DEFAULT
           <> DB_NAME() COLLATE DATABASE_DEFAULT
        THROW 50003, 'The database in the table name must match the current database.', 1;

    TRUNCATE TABLE ##foreign_key_paths;

    INSERT INTO ##foreign_key_paths
    (
        object_id,
        table_name,
        object_name_path,
        object_id_path,
        depth,
        processed
    )
    SELECT  t.object_id,
            CONCAT(s.name, N'.', t.name),
            CONCAT(s.name, N'.', t.name),
            CONVERT(NVARCHAR(20), t.object_id),
            0,
            0
    FROM sys.tables AS t
    INNER JOIN sys.schemas AS s
        ON s.schema_id = t.schema_id
    WHERE s.name COLLATE DATABASE_DEFAULT = @schema_name COLLATE DATABASE_DEFAULT
      AND t.name COLLATE DATABASE_DEFAULT = @table_name COLLATE DATABASE_DEFAULT;

    IF @@ROWCOUNT = 0
        THROW 50004, 'The starting table was not found in the current database.', 1;

    WHILE EXISTS (SELECT 1 FROM ##foreign_key_paths WHERE processed = 0)
    BEGIN
        DECLARE @current_object_id      INT;
        DECLARE @current_path           NVARCHAR(MAX);
        DECLARE @current_object_id_path NVARCHAR(MAX);
        DECLARE @current_depth          INT;

        SELECT TOP (1)
               @current_object_id = object_id,
               @current_path = object_name_path,
               @current_object_id_path = object_id_path,
               @current_depth = depth
        FROM ##foreign_key_paths
        WHERE processed = 0
        ORDER BY depth, table_name, object_id;

        /* Forward: referencing table -> referenced table. */
        INSERT INTO ##foreign_key_paths
        (
            object_id,
            table_name,
            object_name_path,
            object_id_path,
            depth,
            processed
        )
        SELECT  fk.referenced_object_id,
                fk.referenced_table,
                CONCAT(@current_path, N' ➡️ ', fk.referenced_table),
                CONCAT(@current_object_id_path, N' ➡️ ', fk.referenced_object_id),
                @current_depth + 1,
                0
        FROM ##foreign_key_table_map AS fk
        WHERE fk.referencing_object_id = @current_object_id
          AND NOT EXISTS
              (
                  SELECT 1
                  FROM ##foreign_key_paths AS existing
                  WHERE existing.object_id = fk.referenced_object_id
              );

        UPDATE ##foreign_key_paths
        SET processed = 1
        WHERE object_id = @current_object_id;
    END;

    SELECT  table_name,
            object_name_path,
            depth,
            object_id_path
    FROM ##foreign_key_paths
    ORDER BY depth, object_name_path;
END;
GO

/* Resolve and validate a starting table, then trace tables that reference it. */
CREATE OR ALTER PROCEDURE ##temp_sp_determine_foreign_key_paths_reverse
    @v_object_name NVARCHAR(776)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @database_name SYSNAME = PARSENAME(@v_object_name, 3);
    DECLARE @schema_name   SYSNAME = PARSENAME(@v_object_name, 2);
    DECLARE @table_name    SYSNAME = PARSENAME(@v_object_name, 1);

    IF PARSENAME(@v_object_name, 4) IS NOT NULL
        THROW 50011, 'Use a two-part or three-part table name.', 1;

    IF @schema_name IS NULL OR @table_name IS NULL
        THROW 50012, 'Specify the table as schema.table or database.schema.table.', 1;

    IF @database_name IS NOT NULL
       AND @database_name COLLATE DATABASE_DEFAULT
           <> DB_NAME() COLLATE DATABASE_DEFAULT
        THROW 50013, 'The database in the table name must match the current database.', 1;

    TRUNCATE TABLE ##foreign_key_reverse_paths;

    INSERT INTO ##foreign_key_reverse_paths
    (
        object_id,
        table_name,
        object_name_path,
        object_id_path,
        depth,
        processed
    )
    SELECT  t.object_id,
            CONCAT(s.name, N'.', t.name),
            CONCAT(s.name, N'.', t.name),
            CONVERT(NVARCHAR(20), t.object_id),
            0,
            0
    FROM sys.tables AS t
    INNER JOIN sys.schemas AS s
        ON s.schema_id = t.schema_id
    WHERE s.name COLLATE DATABASE_DEFAULT = @schema_name COLLATE DATABASE_DEFAULT
      AND t.name COLLATE DATABASE_DEFAULT = @table_name COLLATE DATABASE_DEFAULT;

    IF @@ROWCOUNT = 0
        THROW 50014, 'The starting table was not found in the current database.', 1;

    WHILE EXISTS (SELECT 1 FROM ##foreign_key_reverse_paths WHERE processed = 0)
    BEGIN
        DECLARE @current_object_id      INT;
        DECLARE @current_path           NVARCHAR(MAX);
        DECLARE @current_object_id_path NVARCHAR(MAX);
        DECLARE @current_depth          INT;

        SELECT TOP (1)
               @current_object_id = object_id,
               @current_path = object_name_path,
               @current_object_id_path = object_id_path,
               @current_depth = depth
        FROM ##foreign_key_reverse_paths
        WHERE processed = 0
        ORDER BY depth, table_name, object_id;

        /* Reverse: referenced table -> referencing table. */
        INSERT INTO ##foreign_key_reverse_paths
        (
            object_id,
            table_name,
            object_name_path,
            object_id_path,
            depth,
            processed
        )
        SELECT  fk.referencing_object_id,
                fk.referencing_table,
                CONCAT(fk.referencing_table, N' ⬅️ ', @current_path),
                CONCAT(fk.referencing_object_id, N' ⬅️ ', @current_object_id_path),
                @current_depth + 1,
                0
        FROM ##foreign_key_table_map AS fk
        WHERE fk.referenced_object_id = @current_object_id
          AND NOT EXISTS
              (
                  SELECT 1
                  FROM ##foreign_key_reverse_paths AS existing
                  WHERE existing.object_id = fk.referencing_object_id
              );

        UPDATE ##foreign_key_reverse_paths
        SET processed = 1
        WHERE object_id = @current_object_id;
    END;

    SELECT  table_name,
            object_name_path,
            depth,
            object_id_path
    FROM ##foreign_key_reverse_paths
    ORDER BY depth, object_name_path;
END;
GO

/* Master procedure for forward traversal. */
CREATE OR ALTER PROCEDURE ##temp_sp_master_execution_foreign_key_paths
    @v_object_name NVARCHAR(776)
AS
BEGIN
    SET NOCOUNT ON;

    EXECUTE ##temp_create_tables;
    EXECUTE ##temp_sp_determine_foreign_key_paths @v_object_name;
END;
GO

/* Master procedure for reverse traversal. */
CREATE OR ALTER PROCEDURE ##temp_sp_master_execution_foreign_key_reverse_paths
    @v_object_name NVARCHAR(776)
AS
BEGIN
    SET NOCOUNT ON;

    EXECUTE ##temp_create_tables;
    EXECUTE ##temp_sp_determine_foreign_key_paths_reverse @v_object_name;
END;
GO

/*--------------------------------------------------------------------------------------------------
Example executions
--------------------------------------------------------------------------------------------------*/

/* Forward: tables referenced by Sales.Orders. */
EXECUTE ##temp_sp_master_execution_foreign_key_paths N'Sales.Orders';
GO

/* Reverse: tables that reference Sales.Orders. */
EXECUTE ##temp_sp_master_execution_foreign_key_reverse_paths N'Sales.Orders';
GO

/* Column-level foreign-key details. */
SELECT *
FROM ##foreign_keys_map
ORDER BY referencing_schema,
         referencing_table,
         foreign_key_name,
         constraint_column_id;
GO
