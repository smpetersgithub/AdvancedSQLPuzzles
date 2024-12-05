USE foo;
GO

DROP TABLE IF EXISTS ##sql_expression_dependencies_analysis_temp;
GO

SELECT  CAST(NULL AS VARCHAR(5000)) AS dependency_description,
        CAST(NULL AS VARCHAR(5000)) AS referenced_object_exists_description,
--
        CAST(NULL AS VARCHAR(5000)) AS referencing_object_type_description,
        CAST(NULL AS VARCHAR(5000)) AS referenced_object_type_description,
--
        CAST(NULL AS VARCHAR(5000)) AS referencing_minor_description,
        CAST(NULL AS VARCHAR(5000)) AS referenced_minor_description,
--
        CAST(NULL AS VARCHAR(5000)) AS schema_bound_description,
        CAST(NULL AS VARCHAR(5000)) AS caller_dependent_description,
        CAST(NULL AS VARCHAR(5000)) AS ambiguous_description,
--
        (CASE WHEN referencing_id = referenced_id THEN 'Self-Referencing' END) AS self_referencing_description, 
        *
INTO   ##sql_expression_dependencies_analysis_temp
FROM   dbo.sql_expression_dependencies;
GO

--------------------------
DROP TABLE IF EXISTS #type_descriptions;
GO

SELECT DISTINCT type, type_desc
INTO  #type_descriptions
FROM  foo.dbo.system_objects;
GO
-------------------------

DROP TABLE IF EXISTS #example_lookup_table;
GO

CREATE TABLE #example_lookup_table 
(
ID INT PRIMARY KEY,
Description NVARCHAR(255) NOT NULL
);
GO

INSERT INTO #example_lookup_table (ID, Description)
VALUES
(1, 'Cross Database Dependencies'),
(2, 'Cross Schema Dependencies'),
(3, 'Invalid Stored Procedures'),
(4, 'Numbered Stored Procedures'),
(5, 'Ambiguous References'),
(6, 'Part Naming Conventions'),
(7, 'Part Naming Conventions - Caller Dependent'),
(8, 'Dropping Objects'),
(9, 'Dropping Objects Then Recreating'),
(10, 'Self Referencing Objects'),
(11, 'Object Aliases'),
(12, 'Schemabindings'),
(13, 'Synonyms'),
(14, 'Triggers - DML'),
(15, 'Triggers - DDL Database Level'),
(16, 'Triggers - DDL Server Level - Table Insert'),
(17, 'Partition Functions'),
(18, 'Defaults and Rules'),
(19, 'Contracts and Queues and Message Types'),
(20, 'Sequences'),
(21, 'User-Defined Data Types'),
(22, 'User-Defined Table Types'),
(23, 'Check Constraints'),
(24, 'Foreign Key Constraints'),
(25, 'Computed Columns'),
(26, 'Masked Functions'),
(27, 'Indexes - Table'),
(28, 'Indexes - Filtered NonClustered'),
(29, 'Indexes - Filtered XML'),
(30, 'Statistics Filtered'),
(31, 'XML Schema Collections'),
(32, 'XML Methods');
GO

----------------------------------------------------
----------------------------------------------------

-- 40 rows updated
-- This will update the database name and schema name for objects that used two-part or one-part naming conventions  
UPDATE ##sql_expression_dependencies_analysis_temp
SET    referenced_database_name = COALESCE(a.referenced_database_name, b.database_name),
       referenced_schema_name = COALESCE(a.referenced_schema_name, b.schema_name),
       dependency_description = 'Intra-Database Dependency',
       referenced_object_type = COALESCE(a.referenced_object_type, b.type)
FROM   ##sql_expression_dependencies_analysis_temp a INNER JOIN
       foo.dbo.system_objects b ON a.referencing_database_name = b.database_name and a.referenced_id = b.object_id;

-- 2 rows updated
-- This will update the referenced_id and referenced_object_type for cross-database dependencies
UPDATE ##sql_expression_dependencies_analysis_temp
SET    referenced_id = object_id,
       referenced_object_type = b.type,
       dependency_description = 'Cross-Database Dependency'
FROM   ##sql_expression_dependencies_analysis_temp a INNER JOIN
       foo.dbo.system_objects b ON CONCAT_WS('.', a.referenced_database_name, a.referenced_schema_name, a.referenced_entity_name) = CONCAT_WS('.',b.database_name, b.schema_name, b.name)
WHERE  a.referencing_database_name <> a.referenced_database_name;
GO

----------------------------------------------------
----------------------------------------------------

-- 17 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     referencing_object_type_description = (CASE WHEN referencing_class_desc IN ('DATABASE_DDL_TRIGGER','SERVER_DDL_TRIGGER') THEN referencing_class_desc ELSE b.type_desc END)
FROM    ##sql_expression_dependencies_analysis_temp a INNER JOIN
        #type_descriptions b ON a.referencing_object_type = b.type
WHERE   referencing_object_type NOT IN ('V','P','FN');

-- 2 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     referencing_object_type_description = CONCAT_WS(' - ', referencing_object_type_description, referenced_entity_name),
        dependency_description = 'Intra-Database Dependency'
FROM    ##sql_expression_dependencies_analysis_temp
WHERE   referencing_object_type_description = 'SQL_TRIGGER' AND referenced_id IS NULL;

-- 5 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     referenced_object_type_description = b.type_desc
FROM    ##sql_expression_dependencies_analysis_temp a INNER JOIN
        #type_descriptions b ON a.referenced_object_type = b.type
WHERE   referenced_object_type NOT IN ('V','P','U','FN');

-- 10 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     referenced_object_exists_description = 'False'
FROM    ##sql_expression_dependencies_analysis_temp a
WHERE   referenced_id IS NULL;

-- 9 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     referenced_object_type_description = referencing_object_type_description
FROM    ##sql_expression_dependencies_analysis_temp a
WHERE   self_referencing_description = 'Self-Referencing';

----------------------------------------------------
----------------------------------------------------

-- 12 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     referencing_minor_description = 'Referencing Minor ID'
WHERE   referenced_minor_id > 0;

--  8 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     referenced_minor_description = 'Referenced Minor ID'
WHERE   referencing_minor_id > 0;

----------------------------------------------------
----------------------------------------------------

-- 17 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     schema_bound_description = 'Schema Bound Reference'
WHERE   is_schema_bound_reference = 1;

-- 5 rows updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     ambiguous_description = 'Ambiguous Reference'
WHERE   is_ambiguous = 1;

-- 1 row updated
UPDATE  ##sql_expression_dependencies_analysis_temp
SET     caller_dependent_description = 'Caller Dependent'
WHERE   is_caller_dependent = 1;

----------------------------------------------------
----------------------------------------------------

-- 52 rows, 22 distinct
WITH cte_lookup AS
(
SELECT  b.description as example_description, 
        *
FROM    ##sql_expression_dependencies_analysis_temp a INNER JOIN
        #example_lookup_table b ON a.example_number = b.id
),
cte_distinct AS
(
SELECT 
      example_description
      ,COUNT(example_number) AS count_examples
      ,dependency_description
      ,referenced_object_exists_description
      ,self_referencing_description
      ,referencing_class_desc
      ,referenced_class_desc
      ,COALESCE(referencing_object_type_description, referencing_class_desc) AS referencing_object_type_description_mod
      ,COALESCE(referenced_object_type_description, referenced_class_desc) AS referenced_object_type_description_mod
      ,referencing_minor_description
      ,referenced_minor_description
      ,schema_bound_description
      ,caller_dependent_description
      ,ambiguous_description
FROM  cte_lookup
GROUP BY 
       example_description
      ,dependency_description
      ,referenced_object_exists_description
      ,self_referencing_description
      ,referencing_class_desc
      ,referenced_class_desc
      ,COALESCE(referencing_object_type_description, referencing_class_desc)
      ,COALESCE(referenced_object_type_description, referenced_class_desc)
      ,referencing_minor_description
      ,referenced_minor_description
      ,schema_bound_description
      ,caller_dependent_description
      ,ambiguous_description
)
SELECT  STRING_AGG(example_description, ', ') AS example_group
       ,SUM(count_examples) AS count_example_records
      ,dependency_description
      ,referenced_object_exists_description
      ,self_referencing_description
      --,referencing_class_desc
      --,referenced_class_desc
      ,referencing_object_type_description_mod
      ,referenced_object_type_description_mod
      ,referencing_minor_description
      ,referenced_minor_description
      ,schema_bound_description
      ,caller_dependent_description
      ,ambiguous_description
FROM    cte_distinct
GROUP BY
       dependency_description
       ,referenced_object_exists_description
       ,self_referencing_description
       --,referencing_class_desc
      --,referenced_class_desc
      ,referencing_object_type_description_mod
      ,referenced_object_type_description_mod
      ,referencing_minor_description
      ,referenced_minor_description
      ,schema_bound_description
      ,caller_dependent_description
      ,ambiguous_description
ORDER BY 1;
GO
