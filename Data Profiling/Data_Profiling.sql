/*
#####################################################################################################
-- Date: April 2020
-- Author: Scott Peters
-- https://advancedsqlpuzzles.com

-- Developer Notes

--Modify any variables as needed.
--You will need to input a schema name and table name
--see comments in the code

--The profile can take several minutes to run, even on small tables.
--For large tables, limit the dataset via 
1) the @vWhereClause variable.
2) the @vColumnsToProfiles variable
3) comment out unneeded output columns (for example 'SapleValue', or 'PercentInteger'

--Rule of thumb, limit the data first to a small set and check performance.

----------------------------------------------------------------------------------------------------
*/


IF OBJECT_ID('tempdb.dbo.#ColumnsToProfile') IS NOT NULL
DROP TABLE #ColumnsToProfile

IF OBJECT_ID('tempdb.dbo.#ProfileResults') IS NOT NULL
DROP TABLE #ProfileResults

IF OBJECT_ID('tempdb.dbo.#NumericColumns') IS NOT NULL
DROP TABLE #NumericColumns

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Step 1 - Define variables

--User Defined Varibles
DECLARE @vSchema VARCHAR(10) = 'sys'----------------------------------UserDefined, insert your schema name here
DECLARE @vTableName VARCHAR(255) = 'columns'--------------------------UserDefined, insert your table name here  

--Limit the data with a WHERE clause
--Use "WHERE 1=1" IF you do not want to limit the data
DECLARE @vWhereClause VARCHAR(MAX) = 'WHERE 1=1';------------------------UserDefined, limit your data via a WHERE clause.

--ColumnsToProfile
DECLARE @vColumnsToProfile TABLE (ColumnName VARCHAR(MAX))---------------UserDefined, limit to speicific columns in your table (See INSERT statement below)

--To profile all columns, set the @vColumnsToProfile variable to NULL/empty.
--To profile a selected list of columns, then use the following INSERT statement.
/*
INSERT INTO @vColumnsToProfile values
	('MyColumnHere'),
	('MyColumnHere2')
*/


--Variables
DECLARE @vDataType NVARCHAR(MAX)
DECLARE @vColumnName VARCHAR(MAX) = '';
DECLARE @vQuery NVARCHAR(MAX) = '';
DECLARE @vCount INTEGER
DECLARE @vStandardCharacters VARCHAR(MAX) = ''
DECLARE @vIterator INTEGER

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Step 2 - Determine columns to profile

--Columns
CREATE TABLE #ColumnsToProfile (
	ColumnName VARCHAR (MAX),
	DataType NVARCHAR(MAX));


INSERT INTO #ColumnsToProfile (ColumnName, DataType)
SELECT
		COLUMN_NAME,
		DATA_TYPE
FROM Information_Schema.Columns AS col_info
WHERE 
		TABLE_NAME = @vTableName AND 
		TABLE_SCHEMA = @vSchema AND 
		1 = CASE	WHEN (SELECT COUNT(*) FROM @vColumnsToProfile) = 0 THEN 1 -- all columns
					WHEN Column_Name IN (SELECT ColumnName FROM @vColumnsToProfile) THEN 1 -- included column
					ELSE 0
			END


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Step 3 - Create the #ProfileResults and #NumericColumns temporary tables

CREATE TABLE #ProfileResults (
	ColumnName VARCHAR(MAX),
	DataType NVARCHAR(MAX),
	IsCalculated VARCHAR(3),
	IsNullable VARCHAR(3),
	DefinedLength INTEGER,
	Nulls BIGINT,
	ZerosAndBlanks BIGINT,
	DistinctValues BIGINT,
	MinLength INTEGER,
	MaxLength INTEGER,
	AverageLength NUMERIC(6,2),
	ContainsCommaOrTab INTEGER,
	ContainsNewLine INTEGER,
	NeedsTrimmed INTEGER,
	ContainsOtherWhitespace INTEGER,
	ContainsNonStandardCharacters INTEGER,
	TotalSum NUMERIC(36,4),
	MinValue NUMERIC(30,4),
	MaxValue NUMERIC(30,4),
	Average NUMERIC(30,4),
	StandardDeviation NUMERIC(30,4),
	SampleValue VARCHAR(MAX),
	PercentBit NUMERIC(4,2),
	PercentDate NUMERIC(4,2),
	PercentInteger NUMERIC(4,2),
	PercentNumeric NUMERIC(4,2)
)

CREATE TABLE #NumericColumns (
	ColumnName VARCHAR(MAX),
	MinValue NUMERIC(30,4),
	MaxValue NUMERIC(30,4),
	Average NUMERIC(30,4),
	StandardDeviation NUMERIC(30,4),
	TotalSum NUMERIC(36,4)
	)

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Step 4 - Populate the @vStandardCharacters variable.  Used for column [ContainsNonStandardCharacters]

--@vStandardCharacters
--Ascii character set 32 through 127.  See http://www.asciitable.com/
SET @vIterator = 32
WHILE @vIterator <= 127
	BEGIN
		--Uses | to escape, could be any character
		SET @vStandardCharacters = @vStandardCharacters + '|' + CHAR(@vIterator)
		IF CHAR(@vIterator) = ''''
			SET @vStandardCharacters = @vStandardCharacters + CHAR(@vIterator)
		SET @vIterator = @vIterator + 1
	END

--The value of @vStandardCharacters is 
--| |!|"|#|$|%|&|''|(|)|*|+|,|-|.|/|0|1|2|3|4|5|6|7|8|9|:|;|<|=|>|?|@|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|[|\|]|^|_|`|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|{|||}|~|
PRINT 'The value of @vStandardCharacters is '
PRINT @vStandardCharacters;

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Step 5 - INSERT into #ProfileResults and #NumericColumns

DECLARE c CURSOR READ_ONLY FAST_FORWARD FOR
	SELECT ColumnName FROM #ColumnsToProfile

OPEN c

FETCH NEXT FROM c INTO @vColumnName
WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT @vDataType = DataType
	FROM #ColumnsToProfile
	WHERE ColumnName = @vColumnName

	SELECT @vQuery = 
	'SELECT
		''' + @vColumnName + ''' AS ColumnName,
		''' + @vDataType + ''' AS DataType,
		SUM(CASE WHEN ['+@vColumnName+'] IS NULL THEN 1 ELSE 0 END) AS Nulls,
		SUM(CASE WHEN LEN(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR))) = 0 OR LOWER(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR)))) IN (''NULL'', ''N/A'') OR TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(8000)) AS NUMERIC) = 0 THEN 1 ELSE 0 END) AS ZerosAndBlanks,
		COUNT(distinct CAST(['+@vColumnName+'] AS VARCHAR(MAX))) AS DistinctValues,
		MIN(LEN(CAST(['+@vColumnName+'] AS VARCHAR))) AS MinLength,
		MAX(LEN(CAST(['+@vColumnName+'] AS VARCHAR))) AS MaxLength,
		AVG(CAST(LEN(CAST(['+@vColumnName+'] AS VARCHAR)) AS FLOAT)) AS AvgLength,
		SUM(CASE WHEN ['+@vColumnName+'] LIKE ''%,%'' OR ['+@vColumnName+'] LIKE ''%	%'' THEN 1 ELSE 0 END) AS ContainsCommaOrTab,
		SUM(CASE WHEN CAST(['+@vColumnName+'] AS VARCHAR(MAX)) != REPLACE(REPLACE(CAST(['+@vColumnName+'] AS VARCHAR(MAX)), CHAR(10), '' ''), CHAR(13), '' '') THEN 1 ELSE 0 END) AS ContainsNewLine,
		SUM(CASE WHEN ['+@vColumnName+'] LIKE ''%[^' + @vStandardCharacters + ']%'' escape ''|'' THEN 1 ELSE 0 END) AS ContainsNonStandardCharacters,
		SUM(CASE WHEN ['+@vColumnName+'] LIKE ''%  %'' THEN 1 ELSE 0 END) AS ContainsOtherWhitespace,
		SUM(CASE WHEN CAST(['+@vColumnName+'] AS VARCHAR(MAX)) != RTRIM(LTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX)))) THEN 1 ELSE 0 END) AS NeedsTrimmed,
		CAST((SELECT top 1 REPLACE(REPLACE(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)), CHAR(10), '' ''), CHAR(13), '' '') FROM '+@vSchema+'.['+@vTableName+'] WHERE ['+@vColumnName+'] IS NOT NULL AND LEN(CAST(['+@vColumnName+'] AS VARCHAR(MAX))) > 0 ORDER BY newid()) AS VARCHAR(MAX)) AS SampleValue,' +
		--0.00000001 to prevent divide-by-zero errors
		' CAST(SUM(CASE WHEN TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(8000)) AS date) IS NOT NULL AND TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(8000)) AS date) between ''1950-01-01'' AND ''2049-12-31'' AND LEN(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX)))) > 0 THEN 1 ELSE 0 END) AS NUMERIC(25,2))/(CAST(SUM(CASE WHEN ['+@vColumnName+'] IS NOT NULL AND LOWER(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX))))) not IN (''null'', ''n/a'') AND LEN(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX))))) > 0 THEN 1 ELSE 0 END) AS NUMERIC(25,2))+0.00000001) AS PercentDate,
		CAST(SUM(CASE WHEN TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(8000)) AS FLOAT) IS NOT NULL AND LEN(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX)))) > 0 THEN 1 ELSE 0 END) AS NUMERIC(25,2))/(CAST(SUM(CASE WHEN ['+@vColumnName+'] IS NOT NULL AND LOWER(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX))))) not IN (''null'', ''n/a'') AND LEN(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX))))) > 0 THEN 1 ELSE 0 END) AS NUMERIC(25,2))+0.00000001) AS PercentNumeric,
		CAST(SUM(CASE WHEN TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(8000)) AS BIGINT) IS NOT NULL AND LEN(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX)))) > 0 THEN 1 ELSE 0 END) AS NUMERIC(25,2))/(CAST(SUM(CASE WHEN ['+@vColumnName+'] IS NOT NULL AND LOWER(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX))))) not IN (''null'', ''n/a'') AND LEN(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX))))) > 0 THEN 1 ELSE 0 END) AS NUMERIC(25,2))+0.00000001) AS PercentInteger,
		CAST(SUM(CASE WHEN LOWER(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX))) IN (''1'', ''0'', ''t'', ''f'', ''y'', ''n'', ''true'', ''false'', ''yes'', ''no'') THEN 1 ELSE 0 END) AS NUMERIC(25,2))/(CAST(SUM(CASE WHEN ['+@vColumnName+'] IS NOT NULL AND LOWER(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX))))) not IN (''null'', ''n/a'') AND LEN(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR(MAX))))) > 0 THEN 1 ELSE 0 END) AS NUMERIC(25,2))+0.00000001) AS PercentBit
	FROM '+@vSchema+'.['+@vTableName+'] (NOLOCK) ' + @vWhereClause

	BEGIN TRY
		--INSERT INTO #ProfileResults
		INSERT INTO #ProfileResults (ColumnName, DataType, Nulls, ZerosAndBlanks, DistinctValues, MinLength, MaxLength, AverageLength, ContainsCommaOrTab, 
								ContainsNewLine, NeedsTrimmed, ContainsOtherWhitespace, ContainsNonStandardCharacters, SampleValue,
								PercentDate, PercentNumeric, PercentInteger, PercentBit)
		EXECUTE sp_executesql @vQuery
	END TRY
	BEGIN CATCH
		PRINT 'The following query resulted in an error:'
		PRINT @vQuery
	END CATCH


	IF @vDataType IN ('BIGINT','NUMERIC','SMALLINT','DECIMAL','SMALLMONEY','INTEGER','INT','TINYINT','MONEY','FLOAT','REAL')
	BEGIN TRY
		SELECT @vQuery = 
			'SELECT
				''' + @vColumnName + ''' AS ColumnName,
				MIN(TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)) AS NUMERIC(30,4))) AS MinValue,
				MAX(TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)) AS NUMERIC(30,4))) AS MaxValue,
				AVG(TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)) AS NUMERIC(30,4))) AS AvgValue,
				STDEV(TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)) AS NUMERIC(30,4))) AS StandardDeviation,
				SUM(TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)) AS NUMERIC(30,4))) AS TotalSum
			FROM '+@vSchema+'.['+@vTableName+'] (NOLOCK) ' + @vWhereClause

		--INSERT into #NumericColumns
		INSERT INTO #NumericColumns
		EXECUTE sp_executesql @vQuery
	END TRY
	BEGIN CATCH
		PRINT 'The following query resulted in an error:'
		PRINT @vQuery
	END CATCH

FETCH NEXT FROM c INTO @vColumnName
END
CLOSE c
DEALLOCATE c;

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Step 5 - UPDATE Results, given the #NumericColumns table
UPDATE #ProfileResults
SET
		MinValue = subset.MinValue,
		MaxValue = subset.MaxValue,
		Average = subset.Average,
		StandardDeviation = subset.StandardDeviation,
		TotalSum = subset.TotalSum
FROM	#ProfileResults AS results inner join 
		#NumericColumns AS subset ON subset.ColumnName = results.ColumnName

UPDATE #ProfileResults
SET		IsNullable = CASE WHEN c.Is_Nullable = 1 THEN 'Yes' ELSE 'No' END,
		IsCalculated = CASE WHEN c.Is_Computed = 1 THEN 'Yes' ELSE 'No' END,
		DefinedLength = c.Max_Length
FROM	sys.columns AS c inner join 
		sys.tables AS t ON t.Object_id = c.Object_id inner join
		sys.schemas AS s ON s.Schema_id = t.Schema_id inner join
		#ProfileResults AS r ON r.ColumnName = c.[Name]
WHERE	s.[Name] = @vSchema AND
		t.[Name] = @vTableName


--Print the results to the results window
SELECT * FROM #ProfileResults


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Determine record count of the table (given the provided @vWhere variable)
--Print the results to the results window
SELECT @vQuery = 'SELECT COUNT(*) AS TableRowCount FROM '+@vSchema+'.['+@vTableName+'] (NOLOCK) ' + @vWhereClause
EXECUTE sp_executesql @vQuery


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Determine the occurences of the date fields
DECLARE c CURSOR READ_ONLY FAST_FORWARD FOR
SELECT ColumnName FROM #ColumnsToProfile

OPEN c

FETCH NEXT FROM c INTO @vColumnName
WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT @vDataType = DataType FROM #ColumnsToProfile WHERE ColumnName = @vColumnName

	IF	@vDataType IN ('DATE', 'DATETIME', 'DATETIME2', 'SMALLDATETIME')
	BEGIN TRY
		
		PRINT 'The date column being profiled for number of occurences is' + @vColumnName
		SELECT @vQuery = 'SELECT TRY_CAST(CASE WHEN LEN(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR))) = 0 OR LOWER(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR)))) IN (''null'', ''n/a'') OR TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)) AS NUMERIC) = 0 THEN null ELSE LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR))) END AS DATE) AS ['+@vColumnName+'], 
		COUNT(*) AS OccurencesCount
		FROM '+@vSchema+'.['+@vTableName+'] (NOLOCK) 
		' + @vWhereClause + ' 
		GROUP BY TRY_CAST(CASE WHEN LEN(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR))) = 0 OR LOWER(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR)))) IN (''null'', ''n/a'') OR TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)) AS NUMERIC) = 0 THEN null ELSE LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR))) END AS date) 
		ORDER BY TRY_CAST(CASE WHEN LEN(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR))) = 0 OR LOWER(LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR)))) IN (''null'', ''n/a'') OR TRY_CAST(TRY_CAST(['+@vColumnName+'] AS VARCHAR(MAX)) AS NUMERIC) = 0 THEN null ELSE LTRIM(RTRIM(CAST(['+@vColumnName+'] AS VARCHAR))) END AS date)'

		--Print the results to the results window
		EXECUTE sp_executesql @vQuery
	END TRY
	BEGIN CATCH
		PRINT 'The following query resulted in an error:'
		PRINT @vQuery
	END CATCH

	FETCH NEXT FROM c INTO @vColumnName
END
CLOSE c
DEALLOCATE c;
