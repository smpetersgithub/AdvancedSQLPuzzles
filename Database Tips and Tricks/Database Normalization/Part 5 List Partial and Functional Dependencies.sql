SET NOCOUNT ON;
GO

--Part 5
DROP TABLE IF EXISTS PartialDependency;
DROP TABLE IF EXISTS FunctionalDependency;
GO

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

UPDATE 	PartialDependency	
SET     PartialDependency = CONCAT('{',CandidateKey,'} ----> {',TrivialDependency,'} ----> {',Dependent,'}');
GO

INSERT INTO PartialDependency (CandidateKey)
SELECT  ColumnList
FROM    SuperKeys4_Final a
WHERE   IsCandidateKey = 1
        AND NOT EXISTS (SELECT 1 FROM PartialDependency b WHERE a.ColumnList = b.CandidateKey);
GO
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
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

UPDATE FunctionalDependency
SET FunctionalDependency = CONCAT('{',CandidateKey,'} ----> {',Dependent1,'} ----> {',Dependent2,'}')
GO

INSERT INTO FunctionalDependency (CandidateKey)
SELECT  ColumnList
FROM    SuperKeys4_Final a
WHERE   IsCandidateKey = 1
        AND NOT EXISTS (SELECT 1 FROM FunctionalDependency b WHERE a.ColumnList = b.CandidateKey);
GO

SELECT * FROM PartialDependency;
SELECT * FROM FunctionalDependency;
GO
