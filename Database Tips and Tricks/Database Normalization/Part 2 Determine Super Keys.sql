SET NOCOUNT ON;
GO

--------------------------------------------------
--Drop tables for part 2
DROP TABLE IF EXISTS SuperKeys1_SysColumns;
DROP TABLE IF EXISTS SuperKeys2_Permutations;
DROP TABLE IF EXISTS SuperKeys3_DynamicSQL;
DROP TABLE IF EXISTS SuperKeys4_Final;
DROP TABLE IF EXISTS SuperKeys5_StringSplit;
DROP TABLE IF EXISTS SuperKeys6_CandidateKey;
DROP TABLE IF EXISTS SuperKeys7_NonPrime;
GO
--Drop tables for part 3
DROP TABLE IF EXISTS Determinant_Dependent1_CrossJoin;
DROP TABLE IF EXISTS Determinant_Dependent2_StringSplit;
DROP TABLE IF EXISTS Determinant_Dependent3_SumPartOfDeterminant;
DROP TABLE IF EXISTS Determinant_Dependent4_TrivialDependency;
GO
--Drop tables for part 4
DROP TABLE IF EXISTS Determinant_Dependent5_DynamicSQL1;
DROP TABLE IF EXISTS Determinant_Dependent6_DynamicSQL2;
DROP TABLE IF EXISTS Determinant_Dependent7_FunctionalDependency;
GO
--Drop tables for part 5
DROP TABLE IF EXISTS PartialDependency;
DROP TABLE IF EXISTS FunctionalDependency;
GO

--------------
----Step 1----
--------------
--From the system tables, determines all the columns in the table NormalizationTest.   
SELECT  ROW_NUMBER() OVER(ORDER BY c.Name) AS RowNumber,
        CAST(c.Name AS VARCHAR(MAX)) AS ColumnName
INTO    SuperKeys1_SysColumns
FROM    sys.schemas s LEFT OUTER JOIN
        sys.tables t ON s.schema_id = t.schema_id INNER JOIN
        sys.columns c ON t.object_id = c.object_id INNER JOIN
        sys.types ty ON ty.user_type_id = c.user_type_id
WHERE   1=1 AND t.Name = 'NormalizationTest'
ORDER BY 1;
GO

--------------
----Step 2----
--------------
--Seed the SuperKeys2_Permutations table by a simple insert from SuperKeys1_SysColumns.  
SELECT  RowNumber AS MaxRowNumber,
        ColumnName AS ColumnList
INTO    SuperKeys2_Permutations
FROM    SuperKeys1_SysColumns;
GO

--------------
----Step 3----
--------------
--Loop through the table to determine the column list; column order is kept in alphabetical order.
DECLARE @vTotalElements INTEGER = (SELECT COUNT(*) FROM SuperKeys1_SysColumns);

WHILE @vTotalElements > 0
BEGIN
INSERT INTO SuperKeys2_Permutations
SELECT  b.RowNumber,
        CONCAT(a.ColumnList, ',', b.ColumnName)
FROM    SuperKeys2_Permutations a INNER JOIN
        SuperKeys1_SysColumns b ON a.MaxRowNumber < b.RowNumber;

SET @vTotalElements = @vTotalElements - 1;
END;
GO

--------------
----Step 4----
--------------
--Creates the SQL statements to determine record counts for Super Keys.  
WITH cte_ColumnListConcat AS
(
SELECT  DISTINCT
        ColumnList, 
        CASE WHEN CHARINDEX(',',ColumnList) > 0 THEN CONCAT('CONCAT(',ColumnList,')') ELSE ColumnList END AS ColumnListConcat,
        LEN(ColumnList) - LEN(REPLACE(ColumnList,',','')) + 1 AS ColumnCount
FROM    SuperKeys2_Permutations
)
SELECT  ROW_NUMBER() OVER (ORDER BY ColumnList) AS RowNumber,
        ColumnCount,
        ColumnList,
        CONCAT('UPDATE SuperKeys4_Final SET RecordCount = (SELECT COUNT(DISTINCT ' , ColumnListConcat , ') FROM dbo.NormalizationTest) WHERE RowNumber = vRowNumber') AS SQLStatement,
        CAST(NULL AS INTEGER) AS RecordCount,
        CAST(NULL AS INTEGER) AS IsSuperKey,
        CAST(NULL AS INTEGER) AS IsMinimalSuperKey,
        CAST(NULL AS INTEGER) AS IsCandidateKey,
        CAST(NULL AS VARCHAR(255)) AS NonPrimeAttributes
INTO    SuperKeys3_DynamicSQL
FROM    cte_ColumnListConcat;
GO

--------------
----Step 5----
--------------
--Create SuperKeys3_Final from SuperKeys3_DynamicSQL.   
SELECT  RowNumber,
        ColumnCount,
        ColumnList,
        RecordCount,
        IsSuperKey,
        IsMinimalSuperKey,
        IsCandidateKey,
        NonPrimeAttributes
INTO    SuperKeys4_Final
FROM    SuperKeys3_DynamicSQL;
GO

--------------
----Step 6----
--------------
--Using a cursor, loops through the SQL and updates the SuperKeys3_Final.RecordCount column.     
DECLARE @vRowNumber INTEGER;
DECLARE @vSQLStatement VARCHAR(8000);

DECLARE mycursor CURSOR FOR (SELECT RowNumber, SQLStatement FROM SuperKeys3_DynamicSQL);
OPEN mycursor;
SET NOCOUNT ON 
FETCH NEXT FROM mycursor INTO @vRowNumber, @vSQLStatement;
    WHILE @@FETCH_STATUS = 0
        BEGIN
        SET @vSQLStatement = REPLACE(@vSQLStatement,'vRowNumber',@vRowNumber)
        --PRINT(CONCAT('The value is ', @vSQLStatement));
        EXEC (@vSQLStatement);
        FETCH NEXT FROM mycursor INTO @vRowNumber, @vSQLStatement;
        END
CLOSE mycursor;
DEALLOCATE mycursor;
GO

--------------
----Step 7----
--------------
--Updates the IsSuperKey and IsMinimalSuperKey columns.  
DECLARE @vRecordCount INTEGER = (SELECT COUNT(*) FROM NormalizationTest);

UPDATE SuperKeys4_Final
SET   IsSuperKey = (CASE WHEN RecordCount = @vRecordCount THEN 1 ELSE 0 END);

UPDATE SuperKeys4_Final
SET   IsMinimalSuperKey = (CASE WHEN RecordCount = @vRecordCount AND 
                          ColumnCount IN (SELECT  MIN(ColumnCount) 
                                          FROM    SuperKeys4_Final 
                                          WHERE   IsSuperKey = 1)
                                THEN 1 ELSE 0 END);
GO

--------------
----Step 8----
--------------
--This step uses the STRING_SPLIT function for use in determining the Candidate Keys.   
WITH cte_StringSplit AS
(
SELECT  a.ColumnCount,
        a.ColumnList,
        b.Value,
        a.RecordCount,
        a.IsSuperKey,
        a.IsMinimalSuperKey,
        CAST(NULL AS INTEGER) AS IsCandidateKeyTemp
FROM    SuperKeys4_Final a CROSS APPLY
        STRING_SPLIT(a.ColumnList,',') b
WHERE   IsSuperKey = 1
)
SELECT  DENSE_RANK() OVER (ORDER BY ColumnCount, ColumnList) AS DenseRank
       ,ROW_NUMBER() OVER (PARTITION BY ColumnList ORDER BY ColumnCount, ColumnList) AS RowNumber		
       ,ColumnCount
       ,ColumnList
       ,Value
       ,RecordCount
       ,IsSuperKey
       ,IsMinimalSuperKey
       ,IsCandidateKeyTemp
       ,CAST(NULL AS INTEGER) AS ColumnMatchCount
INTO   SuperKeys5_StringSplit
FROM   cte_StringSplit
GO

--------------
----Step 9----
--------------
--Creates the dataset to determine the Candidate Keys. 
WITH cte_StringSplitMatch AS
(
SELECT a.DenseRank as DenseRank_A,
       a.ColumnCount as ColumnCount_A,
      a.ColumnList as ColumnList_A,
      '----->' AS id,
       b.DenseRank AS DenseRank_B,
       b.ColumnList as ColumnList_B,
       b.Value,
       1 AS IsMatch
FROM   SuperKeys5_StringSplit a CROSS JOIN
       SuperKeys5_StringSplit b
WHERE  a.DenseRank < b.DenseRank AND
       a.ColumnCount < b.ColumnCount AND
       a.IsSuperKey = 1 AND
       a.Value = b.Value
),
cte_SumMatches AS
(
SELECT  DenseRank_A,
        ColumnCount_A,
        ColumnList_A,
        DenseRank_B,
        ColumnList_B,
        SUM(IsMatch) AS SumMatches
FROM    cte_StringSplitMatch
GROUP BY DenseRank_A, ColumnCount_A, ColumnList_A, DenseRank_B, ColumnList_B
)
SELECT  *
INTO    SuperKeys6_CandidateKey
FROM    cte_SumMatches
WHERE   SumMatches = ColumnCount_A;
GO

-------------
---Step 10---
-------------
--Updates the SuperKeys5_Final table with the Candidate Keys. 
UPDATE  SuperKeys4_Final
SET     IsCandidateKey = 1
WHERE   ColumnList NOT IN (SELECT ColumnList_B FROM SuperKeys6_CandidateKey) AND
        ColumnList IN (SELECT ColumnList_A FROM SuperKeys6_CandidateKey);

UPDATE  SuperKeys4_Final
SET     IsCandidateKey = 0
WHERE   IsCandidateKey IS NULL;
GO

-------------
---Step 11---
-------------
--Using the STRING_AGG function, determine non-prime attributes of the Candidate Keys     
WITH cte_SuperKeys AS
(
SELECT  ColumnList AS SuperKey
FROM    SuperKeys4_Final
WHERE   IsSuperKey = 1
)
SELECT  b.SuperKey,
        STRING_AGG(a.ColumnName,',') WITHIN GROUP (ORDER BY a.ColumnName ASC)AS NonPrimeAttributes
INTO    SuperKeys7_NonPrime
FROM    SuperKeys1_SysColumns a CROSS JOIN
        cte_SuperKeys b
WHERE   CHARINDEX(a.ColumnName,b.SuperKey) = 0
GROUP BY b.SuperKey
ORDER BY SuperKey;
GO

--------------
----Step 12---
--------------
--Update the `NonPrimeAttributes` column in the final table
UPDATE  SuperKeys4_Final
SET     NonPrimeAttributes = b.NonPrimeAttributes
FROM    SuperKeys4_Final a INNER JOIN
        SuperKeys7_NonPrime b ON a.ColumnList = b.SuperKey
GO

-----------------
---Final Query---
-----------------
--Display the results
SELECT  ColumnList,
        IsSuperKey,
        IsMinimalSuperKey,
        IsCandidateKey,
        NonPrimeAttributes
FROM    SuperKeys4_Final
ORDER BY IsCandidateKey DESC,
         IsMinimalSuperKey DESC,
         IsSuperKey DESC,
         ColumnCount;
GO
