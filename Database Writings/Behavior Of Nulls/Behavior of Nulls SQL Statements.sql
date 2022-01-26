/*
Scott Peters
01/16/2022

The SQL statements from this document can be found in following Git repository.
https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Writings

The following examples are presented using SQL Servers TSQL.  You can easily modify the SQL statements to fit your flavor of SQL.

Please check out my website at:
https://advancedsqlpuzzles.com
*/

--------------------
-- PREDICATE LOGIC--
--------------------

--1.1
--TRUE OR UNKNOWN = TRUE
SELECT 1 WHERE ((1=1) OR (NULL=1));

--1.2
--FALSE OR UNKNOWN = UNKNOWN
SELECT 1 WHERE ((1=2) OR (NULL=1));

--------------------------
-- IS NULL | IS NOT NULL--
--------------------------

--2.1
SET ANSI_NULLS ON;

--UNKNOWN
SELECT 1 WHERE NULL = NULL;
SELECT 1 WHERE 1 = NULL;
SELECT 1 WHERE NULL <> NULL;
SELECT 1 WHERE NULL = NULL;
SELECT 1 WHERE 1 = NULL;
SELECT 1 WHERE NULL <> NULL;
SELECT 1 WHERE 1 <> NULL;
SELECT 1 WHERE NULL > NULL;
SELECT 1 WHERE 1 > NULL;

--TRUE
SELECT 1 WHERE NULL IS NULL;
SELECT 1 WHERE 1 IS NOT NULL;

--FALSE
SELECT 1 WHERE 1 IS NULL;
SELECT 1 WHERE NULL IS NOT NULL;

----------------------
--CREATE SAMPLE DATA--
----------------------

DROP TABLE IF EXISTS ##TableA;
DROP TABLE IF EXISTS ##TableB;
GO

CREATE TABLE ##TableA
(
ID          TINYINT,
Fruit       VARCHAR(10),
Quantity    TINYINT
);
GO

CREATE TABLE ##TableB
(
ID          TINYINT,
Fruit       VARCHAR(10),
Quantity    TINYINT
);
GO

INSERT INTO ##TableA VALUES
(1,'Apple',17),
(2,'Peach',20),
(3,'Mango',11),
(4,'Mango',15),
(5,NULL,5),
(6,NULL,3);
GO

INSERT INTO ##TableB VALUES
(1,'Apple',17),
(2,'Peach',25),
(3,'Kiwi',20),
(4,NULL,NULL)
GO

----------------
-- INNER JOINS--
----------------

--3.1
SELECT  DISTINCT
        a.Fruit,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit OR a.Fruit <> b.Fruit;

------------------------
-- SEMI AND ANTI JOINS--
------------------------

--4.1
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB);

--4.2
SELECT  DISTINCT
        Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT ISNULL(Fruit,'') FROM ##TableB);

--4.3
SELECT  DISTINCT
        Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB WHERE Fruit IS NOT NULL);

--4.4
SELECT  DISTINCT
        Fruit
FROM    ##TableA
WHERE   Fruit IN (SELECT Fruit FROM ##TableB);

--4.5
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN ('Apple','Kiwi',NULL);

--4.6
SELECT  Fruit
FROM    ##TableA a
WHERE  EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);

--4.7
SELECT  Fruit
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);

------------------
-- SET OPERATORS--
------------------

--5.1
SELECT DISTINCT Fruit FROM ##TableA
UNION
SELECT DISTINCT Fruit FROM ##TableB;

--5.2
SELECT DISTINCT Fruit FROM ##TableA
UNION ALL
SELECT DISTINCT Fruit FROM ##TableB;

--5.3
SELECT DISTINCT Fruit FROM ##TableB
EXCEPT
SELECT DISTINCT Fruit FROM ##TableA;

--5.4
SELECT DISTINCT Fruit FROM ##TableA
INTERSECT
SELECT DISTINCT Fruit FROM ##TableB;

------------
--GROUP BY--
------------

--6.1
SELECT  Fruit,
        COUNT(*) AS Count_Star,
        COUNT(Fruit) AS Count_Fruit
FROM    ##TableA
GROUP BY Fruit;

------------------
--COUNT FUNCTION--
------------------
--7.1
SELECT  Fruit,
        COUNT(*) AS Count_Star,
        COUNT(Fruit) AS Count_Fruit
FROM    ##TableA
GROUP BY Fruit;

---------------
--CONSTRAINTS--
---------------

--8.1
ALTER TABLE ##TableA
ADD CONSTRAINT PK_NULLConstraints PRIMARY KEY NONCLUSTERED (Fruit);

--8.2
ALTER TABLE ##TableA
ADD CONSTRAINT PK_NULLConstraints PRIMARY KEY CLUSTERED (Fruit);

--8.3
ALTER TABLE ##TableB
ADD CONSTRAINT UNIQUE_NULLConstraints UNIQUE (Fruit);
GO

INSERT INTO ##TableB(Fruit) VALUES (NULL);
GO

--8.4
DROP TABLE IF EXISTS ##CheckConstraints;

CREATE TABLE ##CheckConstraints
(
MyField INTEGER,
CONSTRAINT Check_NULLConstraints CHECK (MyField > 0)
);

INSERT INTO ##CheckConstraints (MyField) VALUES (NULL);
GO

SELECT * FROM ##CheckConstraints;

-------------------------
--REFERENTIAL INTEGRITY--
-------------------------

--9.1
DROP TABLE IF EXISTS dbo.Parent;
DROP TABLE IF EXISTS dbo.Child;
GO

CREATE TABLE dbo.Parent
(
ParentID INTEGER PRIMARY KEY
);
GO

CREATE TABLE dbo.Child
(
ChildID INTEGER FOREIGN KEY REFERENCES dbo.Parent (ParentID)
);
GO

INSERT INTO dbo.Parent VALUES (1),(2),(3),(4),(5);
GO

INSERT INTO dbo.Child VALUES (1),(2),(NULL),(NULL);
GO

SELECT * FROM dbo.Parent;
SELECT * FROM dbo.Child;

-------------------
--COMPUTED COLUMN--
-------------------

--10.1
SELECT  Fruit,
        Quantity + 2 AS QuantityPlus2
FROM    ##TableB;

------------------
--NULL FUNCTIONS--
------------------

--11.1
DECLARE @test VARCHAR(3);
SELECT  'IsNull' AS Type,
        ISNULL(@test, 'ABCD') AS Result
UNION
SELECT  'Coalesce' AS Type,
        COALESCE(@test, 'ABCD') AS Result
UNION
SELECT  'NullIf' AS Type,
        NULLIF('ABCD', @test) AS Result;

----------------
--EMPTY STRING--
----------------

--12.1
SELECT ASCII('') AS ASCII;

--12.2
SELECT  DISTINCT
        a.Fruit,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON ISNULL(a.Fruit,'') = ISNULL(b.Fruit,'');
