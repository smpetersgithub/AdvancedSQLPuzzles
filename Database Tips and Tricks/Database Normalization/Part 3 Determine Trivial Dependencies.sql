--Part 3
DROP TABLE IF EXISTS Determinant_Dependent1_CrossJoin;
DROP TABLE IF EXISTS Determinant_Dependent2_StringSplit;
DROP TABLE IF EXISTS Determinant_Dependent3_SumPartOfDeterminant;
DROP TABLE IF EXISTS Determinant_Dependent4_TrivialDependency;
GO
--Part 4
DROP TABLE IF EXISTS Determinant_Dependent5_DynamicSQL1;
DROP TABLE IF EXISTS Determinant_Dependent6_DynamicSQL2;
DROP TABLE IF EXISTS Determinant_Dependent7_FunctionalDependency;
GO
--Part 5
DROP TABLE IF EXISTS PartialDependency;
DROP TABLE IF EXISTS FunctionalDependency;
GO

----------
--STEP 1--
----------
--Create the table `Determinant_Dependent1_CrossJoin` of all possibilities of Determinants and Dependents.
SELECT  DISTINCT
        b.ColumnList AS Determinant
       ,a.ColumnList AS [Dependent]
       ,'------->' AS id
       ,b.ColumnCount AS DeterminantColumnCount
       ,a.ColumnCount AS DependentColumnCount
       ,b.IsSuperKey AS IsDeterminantSuperKey
       ,a.IsSuperKey AS IsDependentSuperKey
INTO    Determinant_Dependent1_CrossJoin --Determinant_Dependent1
FROM    SuperKeys4_Final a CROSS JOIN
        SuperKeys4_Final b;
GO

----------
--STEP 2--
----------
--Use `STRING_SPLIT` on the Dependent column.
WITH cte_StringSplit AS
(
SELECT  a.*
        ,b.value AS DependentValue
FROM    Determinant_Dependent1_CrossJoin a CROSS APPLY
        STRING_SPLIT(Dependent,',') b
)
SELECT  RANK() OVER (ORDER BY Determinant, Dependent) AS RowNumber1
        ,ROW_NUMBER() OVER (PARTITION BY Determinant, Dependent ORDER BY Determinant, DependentValue) AS RowNumber2
        ,Determinant
        ,Dependent
        ,DependentValue
        ,DeterminantColumnCount
        ,DependentColumnCount
        ,IsDeterminantSuperKey
        ,IsDependentSuperKey
INTO    Determinant_Dependent2_StringSplit
FROM    cte_StringSplit;
GO

----------
--STEP 3--
----------
--Determine the count of Dependent columns that are part of the the Super Key.
WITH cte_PartOfDeterminant AS
(
SELECT  RowNumber1
        ,RowNumber2
        ,Determinant
        ,Dependent
        ,DependentValue
        ,DeterminantColumnCount
        ,DependentColumnCount
        ,IsDeterminantSuperKey
        ,IsDependentSuperKey
        ,CASE WHEN CHARINDEX(DependentValue,Determinant) > 0 
             THEN 1 ELSE 0 END AS IsPartOfDeterminant
FROM    Determinant_Dependent2_StringSplit
)
SELECT   Determinant
        ,Dependent
        ,DeterminantColumnCount
        ,DependentColumnCount
        ,IsDeterminantSuperKey
        ,IsDependentSuperKey
        ,SUM(IsPartOfDeterminant) AS SumIsPartOfDeterminant
INTO    Determinant_Dependent3_SumPartOfDeterminant
FROM    cte_PartOfDeterminant
GROUP BY  Determinant
         ,Dependent
         ,DeterminantColumnCount
         ,DependentColumnCount
         ,IsDeterminantSuperKey
         ,IsDependentSuperKey;
GO

----------
--STEP 4--
----------
--Creates the `Determinant_Dependent4_TrivialDependency` table that determines if the Dependent is a Trivial or Semi Trivial dependency.
SELECT  Determinant
       ,Dependent
       ,CASE WHEN DependentColumnCount = SumIsPartOfDeterminant 
            THEN 1 ELSE 0 END AS IsTrivialDependency
       ,CASE WHEN SumIsPartOfDeterminant > 0 AND
                  DependentColumnCount <> SumIsPartOfDeterminant
             THEN 1 ELSE 0 END AS IsSemiTrivialDependency
       ,IsDeterminantSuperKey
       ,IsDependentSuperKey
INTO   Determinant_Dependent4_TrivialDependency
FROM   Determinant_Dependent3_SumPartOfDeterminant;
GO

----------------------
----------------------
----------------------
----------------------
SELECT  *
FROM    Determinant_Dependent4_TrivialDependency
ORDER BY 5 DESC,
         6 DESC,
         Determinant,
         Dependent;
GO
