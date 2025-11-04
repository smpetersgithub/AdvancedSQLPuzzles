USE foo;
GO

DROP TABLE IF EXISTS ##sql_expression_dependencies_analysis_temp;
GO

SELECT *
INTO   ##sql_expression_dependencies_analysis_temp
FROM   foo.dbo.sql_expression_dependencies;

--------
--------
--------

UPDATE ##sql_expression_dependencies_analysis_temp
SET referencing_entity_name = '1'
WHERE referencing_entity_name IS NOT NULL;

UPDATE ##sql_expression_dependencies_analysis_temp
SET referencing_id = 1
WHERE referencing_id IS NOT NULL;

UPDATE ##sql_expression_dependencies_analysis_temp
SET referencing_minor_id = 1
WHERE referencing_minor_id >= 1;


UPDATE ##sql_expression_dependencies_analysis_temp
SET referencing_database_name = '1'
WHERE referencing_database_name IN ('foo','bar');
GO

UPDATE ##sql_expression_dependencies_analysis_temp
SET referencing_schema_name = '1'
WHERE referencing_schema_name IN ('dbo');
GO

--------
--------
--------

UPDATE ##sql_expression_dependencies_analysis_temp
SET referenced_id = 1
WHERE referenced_id IS NOT NULL;
GO

UPDATE ##sql_expression_dependencies_analysis_temp
SET referenced_entity_name = '1'
WHERE referenced_entity_name IS NOT NULL;

UPDATE ##sql_expression_dependencies_analysis_temp
SET referenced_database_name = '1'
WHERE referenced_database_name IN ('foo','bar');

UPDATE ##sql_expression_dependencies_analysis_temp
SET referenced_schema_name = '1'
WHERE referenced_schema_name IN ('dbo');

UPDATE ##sql_expression_dependencies_analysis_temp
SET referenced_minor_id = 1
WHERE referenced_minor_id >= 1;

SELECT 
    COUNT(*) AS record_count,
    STRING_AGG(example_number,', ') AS examples,
    referencing_object_type,
    referencing_server_name,
    referencing_database_name,
    referencing_schema_name,
    referencing_entity_name,
    referencing_id,
    referencing_minor_id,
    referencing_class,
    referencing_class_desc,
    is_schema_bound_reference,
    referenced_class,
    referenced_class_desc,
    referenced_server_name,
    referenced_database_name,
    referenced_schema_name,
    referenced_entity_name,
    referenced_object_type,
    referenced_id,
    referenced_minor_id,
    is_caller_dependent,
    is_ambiguous,
    referencing_is_ms_shipped,
    referenced_is_ms_shipped,
    is_user_defined_data_type,
    is_self_referencing
FROM ##sql_expression_dependencies_analysis_temp
GROUP BY 
    referencing_object_type,
    referencing_server_name,
    referencing_database_name,
    referencing_schema_name,
    referencing_entity_name,
    referencing_id,
    referencing_minor_id,
    referencing_class,
    referencing_class_desc,
    is_schema_bound_reference,
    referenced_class,
    referenced_class_desc,
    referenced_server_name,
    referenced_database_name,
    referenced_schema_name,
    referenced_entity_name,
    referenced_object_type,
    referenced_id,
    referenced_minor_id,
    is_caller_dependent,
    is_ambiguous,
    referencing_is_ms_shipped,
    referenced_is_ms_shipped,
    is_user_defined_data_type,
    is_self_referencing
ORDER BY 1 DESC, 2;
GO
