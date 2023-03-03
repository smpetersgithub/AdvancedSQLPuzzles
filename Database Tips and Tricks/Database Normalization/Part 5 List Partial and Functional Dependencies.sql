/*----------------------------------------------------------------------------------------------------------------------------
Scott Peters
Database Normalization
https://advancedsqlpuzzles.com
Last Updated: 03/03/2023
Microsoft SQL Server T-SQL
*/----------------------------------------------------------------------------------------------------------------------------

SET NOCOUNT ON;
GO

--------------------------------------------------
--Drop tables for part 5
DROP TABLE IF EXISTS PartialDependency;
DROP TABLE IF EXISTS FunctionalDependency;
GO

--------------
----Step 1----
--------------
--Creates the table PartialDependency for which you can make deductions about 2NF.
WITH cte_CandidateKeys AS
(
SELECT  ColumnList
FROM    SuperKeys4_Final
WHERE   IsCandidateKey = 1
),
cte_TrivialDependencies AS
(
SELECT  Determinant, Dependent
FROM    Determinant_Dependent7_FunctionalDependency
WHERE   Determinant <> Dependent
        AND
        IsTrivialDependency = 1
        AND
        IsDeterminantCandidateKey = 1
)
SELECT  a.ColumnList as CandidateKey,
        b.Dependent AS TrivialDependency,
        c.Dependent AS Dependent,
        CAST(NULL AS VARCHAR(255)) AS PartialDependency
INTO    PartialDependency
FROM    cte_CandidateKeys a INNER JOIN
        cte_TrivialDependencies b ON a.ColumnList = b.Determinant
        INNER JOIN
        Determinant_Dependent7_FunctionalDependency c ON b.Dependent = c.Determinant
WHERE   c.IsFunctionalDependency = 1
        AND c.Determinant <> c.Dependent
        AND c.IsSemiTrivialDependency = 0;
GO

--------------
----Step 2----
--------------
--Updates the PartialDependency.PartialDependency column that gives a description of the dependency.
UPDATE  PartialDependency
SET     PartialDependency = CONCAT('{',CandidateKey,'} ----> {',TrivialDependency,'} ----> {',Dependent,'}');
GO

--------------
----Step 3----
--------------
--Inserts into the PartialDependency table any candidate keys that are currently not present.  These are keys that do not have any partial dependencies.
INSERT INTO PartialDependency (CandidateKey)
SELECT  ColumnList
FROM    SuperKeys4_Final a
WHERE   IsCandidateKey = 1
        AND NOT EXISTS (SELECT 1 FROM PartialDependency b WHERE a.ColumnList = b.CandidateKey);
GO

--------------
----Step 4----
--------------
--Creates the table FunctionalDependency for which you can make deductions about 3NF, BCNF, 4NF, and 5NF.
WITH cte_CandidateKeys AS
(
SELECT  ColumnList
FROM    SuperKeys4_Final
WHERE   IsCandidateKey = 1
)
SELECT  a.ColumnList AS CandidateKey
        ,b.Dependent AS Dependent1
        ,c.Dependent AS Dependent2
        ,CAST(NULL AS VARCHAR(255)) AS FunctionalDependency
INTO    FunctionalDependency
FROM    cte_CandidateKeys a INNER JOIN
        Determinant_Dependent7_FunctionalDependency b ON a.ColumnList = b.Determinant
        INNER JOIN
        Determinant_Dependent7_FunctionalDependency c ON b.Dependent = c.Determinant
WHERE   b.IsTrivialDependency = 0 AND b.IsFunctionalDependency = 1 AND b.IsSemiTrivialDependency = 0 AND
        c.IsTrivialDependency = 0 AND c.IsFunctionalDependency = 1 AND c.IsSemiTrivialDependency = 0 AND
        b.Dependent <> c.Dependent;
GO

--------------
----Step 5----
--------------
--Update the FunctionalDependency.FunctionalDependency column that gives a description of the functional dependency.
UPDATE FunctionalDependency
SET FunctionalDependency = CONCAT('{',CandidateKey,'} ----> {',Dependent1,'} ----> {',Dependent2,'}')
GO

--------------
----Step 6----
--------------
--Inserts into the FunctionalDependency table any candidate keys that are currently not present.  These are keys that do not have any functional dependencies.
INSERT INTO FunctionalDependency (CandidateKey)
SELECT  ColumnList
FROM    SuperKeys4_Final a
WHERE   IsCandidateKey = 1
        AND NOT EXISTS (SELECT 1 FROM FunctionalDependency b WHERE a.ColumnList = b.CandidateKey);
GO

---------------------
----Final Queries----
---------------------
SELECT * FROM PartialDependency;
SELECT * FROM FunctionalDependency;
GO
