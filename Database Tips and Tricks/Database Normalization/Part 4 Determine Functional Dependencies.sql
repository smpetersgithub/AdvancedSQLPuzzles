SET NOCOUNT ON
GO

--------------------------------------------------
--Drop tables for part 4
DROP TABLE IF EXISTS Determinant_Dependent5_DynamicSQL1;
DROP TABLE IF EXISTS Determinant_Dependent6_DynamicSQL2;
DROP TABLE IF EXISTS Determinant_Dependent7_FunctionalDependency;
GO
--Drop tables for part 5
DROP TABLE IF EXISTS PartialDependency;
DROP TABLE IF EXISTS FunctionalDependency;
GO

----------
--STEP 1--
----------
SELECT  *,
        CONCAT('SELECT COUNT(DISTINCT(CONCAT(', [Dependent], ',''''))) AS Count FROM NormalizationTest GROUP BY ', Determinant) AS SQLStatementTemp
INTO    Determinant_Dependent5_DynamicSQL1
FROM    Determinant_Dependent4_TrivialDependency;
GO

----------
--STEP 2--
----------
SELECT ROW_NUMBER() OVER (ORDER BY [Dependent]) AS RowNumber
       ,*
       ,CONCAT('IF 1 = ALL(',SQLStatementTemp,') UPDATE Determinant_Dependent6_DynamicSQL2 SET IsFunctionalDependency = 1 WHERE RowNumber = vRowNumber') AS SQLStatement
       ,CAST(0 AS INTEGER) AS IsFunctionalDependency
INTO   Determinant_Dependent6_DynamicSQL2
FROM   Determinant_Dependent5_DynamicSQL1
GO

----------
--STEP 3--
----------
SET NOCOUNT ON;
DECLARE @vRowNumber INTEGER;
DECLARE @vSQLStatement VARCHAR(8000);

DECLARE mycursor CURSOR FOR (SELECT RowNumber, SQLStatement FROM Determinant_Dependent6_DynamicSQL2);
OPEN mycursor;

FETCH NEXT FROM mycursor INTO @vRowNumber, @vSQLStatement
    WHILE @@FETCH_STATUS = 0
        BEGIN
        SET @vSQLStatement = REPLACE(@vSQLStatement,'vRowNumber',@vRowNumber)
        --PRINT(@vSQLStatement);
        EXEC (@vSQLStatement);
        FETCH NEXT FROM mycursor INTO @vRowNumber, @vSQLStatement;
        END
CLOSE mycursor;
DEALLOCATE mycursor;
GO

----------
--STEP 4--
----------
SELECT  a.Determinant,
        a.Dependent,
        'Determinant Info ------->' AS ID1,
        b.IsSuperKey AS IsDeterminantSperKey,
        b.IsMinimalSuperKey AS IsDeterminantMinimalSuperKey,
        b.IsCandidateKey AS IsDeterminantCandidateKey,
        b.ColumnCount AS DeterminantColumnCount,
        'Dependent Info------>' AS ID2,
        a.IsTrivialDependency,
        a.IsSemiTrivialDependency,
        a.IsFunctionalDependency,
        c.IsSuperKey AS IsDependentSuperKey,
        c.IsMinimalSuperKey AS IsDependentMinimalSuperKey,
        c.IsCandidateKey AS IsDependentCandidateKey,
        c.ColumnCount AS DependentColumnCount
INTO    Determinant_Dependent7_FunctionalDependency
FROM    Determinant_Dependent6_DynamicSQL2 a LEFT JOIN
        SuperKeys4_Final b ON a.Determinant = b.ColumnList LEFT JOIN
        SuperKeys4_Final c ON a.Dependent = c.ColumnList;
GO

-----------------
--Final Queries--
-----------------
SELECT  *
FROM    Determinant_Dependent7_FunctionalDependency
ORDER BY IsDeterminantCandidateKey DESC;
GO
