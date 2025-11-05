/*----------------------------------------------------------------------------------------------------------

Determine Object Dependency Paths Addendum String Split

After running the 05_determine_object_dependency_paths.sql script to create the stored procedures, 
use the following script to split the output paths and identify all distinct objects.

----------------------------------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS ##dependency_analysis;
GO

CREATE TABLE ##dependency_analysis (
    server_name VARCHAR(256),
    object_name VARCHAR(256),
    object_name_path NVARCHAR(MAX),
    referencing_object_fullname NVARCHAR(500),
    depth INT,
    object_id_path NVARCHAR(MAX),
    object_type_desc_path NVARCHAR(MAX)
);
GO

-----------------------------
-----------------------------

-- Modify the following.

/*
-- Forward dependencies
INSERT INTO ##dependency_analysis 
EXECUTE ##temp_sp_master_execution_paths 'WideWorldImporters.Website.SearchForPeople';
GO

-- Reverse dependencies
INSERT INTO ##dependency_analysis
EXECUTE ##temp_sp_master_execution_reverse_paths 'WideWorldImporters.Sales.Customers';
GO
*/

-----------------------------
-----------------------------

-- String Split
SELECT DISTINCT
       [object_name], 
       [value] AS referenced_object_name
FROM ##dependency_analysis da
CROSS APPLY STRING_SPLIT(REPLACE(da.object_name_path, N' ⬅️ ', N'|'), N'|') AS split_values
ORDER BY 1 DESC;
GO