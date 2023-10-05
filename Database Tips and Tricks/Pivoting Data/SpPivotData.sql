CREATE OR ALTER PROC SpPivotData
/*----------------------------------------------------
Scott Peters
Creates the procedure SpPivotData
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script creates the stored procedure "SpPivotData" that can be used to
automate the creation of pivoted data sets.

*/----------------------------------------------------

@vQuery    AS NVARCHAR(MAX),
@vOnRows  AS NVARCHAR(MAX),
@vOnColumns  AS NVARCHAR(MAX),
@vAggFunction AS NVARCHAR(257) = N'MAX',
@vAggColumns  AS NVARCHAR(MAX)
AS
BEGIN TRY

    -- Input validation
    IF @vQuery IS NULL OR @vOnRows IS NULL OR @vOnColumns IS NULL OR @vAggFunction IS NULL OR @vAggColumns IS NULL
         THROW 50001, 'Invalid input parameters.', 1;


    DECLARE
    @vSql AS NVARCHAR(MAX),
    @vColumns AS NVARCHAR(MAX),
    @vNewLine AS NVARCHAR(2) = NCHAR(13) + NCHAR(10);

    --If the input is a valid table or view, construct a SELECT statement
    IF COALESCE(OBJECT_ID(@vQuery, 'U'), OBJECT_ID(@vQuery, 'V')) IS NOT NULL
        SET @vQuery = 'SELECT * FROM ' + @vQuery;

    --Make the query a derived table
    SET @vQuery = '(' + @vQuery + N') AS Query';

    -- Handle * input in @vAggColumns
    IF @vAggColumns = '*' SET @vAggColumns = '1';

    -- Construct a column list
    SET @vSql =
                'SET @result = '                                      + @vNewLine +
                '  STUFF('                                            + @vNewLine +
                '    (SELECT '',['' + '                               +
                'CAST(pivot_col AS sysname) + '                       +
                ''']'' AS [text()]'                                   + @vNewLine +
                '     FROM (SELECT DISTINCT('                         +
                @vOnColumns + N') AS pivot_col'                       + @vNewLine +
                '           FROM' + @vQuery + N') AS DistinctCols'    + @vNewLine +
                '     ORDER BY pivot_col'                             + @vNewLine +
                '     FOR XML PATH('''')),'                           + @vNewLine +
                '    1, 1, '''');';

    EXEC SP_EXECUTESQL
        @stmt   = @vSql,
        @params = N'@result AS NVARCHAR(MAX) OUTPUT',
        @result = @vColumns OUTPUT;

    --Create the PIVOT query
    SET @vSql = 
                'SELECT *'                                           + @vNewLine +
                'FROM (SELECT '                                      +
                @vOnRows +
                ', ' + @vOnColumns + N' AS pivot_col'                +
                ', ' + @vAggColumns + N' AS agg_col'                 + @vNewLine +
                '      FROM ' + @vQuery + N')' +
                ' AS PivotInput'                                     + @vNewLine +
                '  PIVOT(' + @vAggFunction + N'(agg_col)'            + @vNewLine +
                '    FOR pivot_col IN(' + @vColumns + N')) AS PivotOutput;';

    EXEC SP_EXECUTESQL @vSql;

END TRY
BEGIN CATCH;
    THROW;
END CATCH;
GO
