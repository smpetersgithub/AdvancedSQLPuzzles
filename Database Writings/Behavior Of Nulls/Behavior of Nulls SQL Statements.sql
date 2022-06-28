/*
CREATE DATABASE BehaviorNulls;
GO

USE BehaviorNulls
GO
*/

/*
Scott Peters
Last Updated: 05/09/2022

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
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN (SELECT Fruit FROM ##TableB);

--4.5
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN ('Apple','Kiwi',NULL);

--4.6
SELECT  Fruit
FROM    ##TableA a
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit AND a.Quantity = b.Quantity);

--4.7
SELECT  DISTINCT
        Fruit
FROM    ##TableA a
WHERE  NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit AND a.Quantity = b.Quantity);


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

------------------------------
--COUNT AND AVERAGE FUNCTION--
------------------------------
--7.1
SELECT  Fruit,
        COUNT(*) AS Count_Star
FROM    ##TableA
GROUP BY Fruit;

--7.2
WITH cte_Average AS
(
SELECT 1 AS Id, 150 AS MyValue
UNION 
SELECT 2 AS Id, 150 AS MyValue
UNION 
SELECT 3 AS Id, NULL AS MyValue
UNION 
SELECT NULL AS Id, 150 AS MyValue
)
SELECT SUM(MyValue) / CAST(COUNT(*) AS NUMERIC(5,2)) AS Average_CountStar,
       SUM(MyValue) / CAST(COUNT(Id) AS NUMERIC(5,2)) AS Average_CountId,
       AVG(CAST(MyValue AS NUMERIC(5,2))) AS Average_AvgFunction
FROM   cte_Average;

---------------
--CONSTRAINTS--
---------------

--8.1
--Msg 8111, Level 16, State 1, Line nnn
--Cannot define PRIMARY KEY constraint on nullable column in table '##TableA'.
--Msg 1750, Level 16, State 0, Line nnn
--Could not create constraint or index. See previous errors.
ALTER TABLE ##TableA
ADD CONSTRAINT PK_NULLConstraints PRIMARY KEY NONCLUSTERED (Fruit);

--8.2
--Msg 8111, Level 16, State 1, Line nnn
--Cannot define PRIMARY KEY constraint on nullable column in table '##TableA'.
--Msg 1750, Level 16, State 0, Line nnn
--Could not create constraint or index. See previous errors.
ALTER TABLE ##TableA
ADD CONSTRAINT PK_NULLConstraints PRIMARY KEY CLUSTERED (Fruit);

--8.3
--Msg 1505, Level 16, State 1, Line 205
--The CREATE UNIQUE INDEX statement terminated because a duplicate key was found for the object name 'dbo.##TableB' and the index name 'UNIQUE_NULLConstraints'. The duplicate key value is (<NULL>).
--Msg 1750, Level 16, State 1, Line 205
--Could not create constraint or index. See previous errors.
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
DROP TABLE IF EXISTS dbo.Child;
DROP TABLE IF EXISTS dbo.Parent;
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

--10.2
DROP TABLE IF EXISTS MyComputed;
GO

CREATE TABLE MyComputed
(
Int1 INTEGER NOT NULL,
Int2 INTEGER NOT NULL,
Int3 AS Int1 + Int2 PERSISTED NOT NULL
);

ALTER TABLE MyComputed ADD PRIMARY KEY CLUSTERED (Int3);

DROP TABLE IF EXISTS MyComputed;
GO


------------------
--NULL FUNCTIONS--
------------------

DECLARE @test VARCHAR(3);

--11.1
WITH cte_functions AS
(
SELECT  1 AS Id,
        'IsNull' AS Type,
        ISNULL(@test, 'ABCD') AS Result--truncates ABCD to ABC.
UNION
SELECT  2 AS Id,
        'Coalesce_3Parameters' AS Type,
        COALESCE(@test, 'ABCD', 'EFGH') AS Result1--accepts three parameters, does not truncate ABCD
UNION
SELECT  3 AS Id,
        'Coalesce_NULL' AS Type,
        COALESCE(@test, NULL, NULL) AS Result1--Returns a NULL
UNION
SELECT  4 AS Id,
       'NullIf' AS Type,
        NULLIF('ABCD', @test) AS Result--The first argument needs to be a NON-NULL
)
SELECT   *
FROM     cte_functions
ORDER BY 1;

----------------
--EMPTY STRING--
----------------

--12.1
SELECT ASCII('') AS ASCII_EmptyString,
       ASCII(NULL) AS ASCII_NULL;

--12.2
SELECT  DISTINCT
        a.Fruit,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON ISNULL(a.Fruit,'') = ISNULL(b.Fruit,'');

----------
--CONCAT--
----------

--13.1
SELECT CONCAT(NULL,NULL,NULL) AS ConcatFunc;

--13.2
WITH
cte_NULL AS 
(
SELECT 'NULL' AS MyType,
		NULL AS A,
		NULL AS B,
		NULL AS C
)
,
cte_EmptyString AS 
(
SELECT 'EmptyString' AS MyType,
       '' AS A,
       '' AS B,
       '' AS C
)
SELECT  *
FROM    cte_NULL a INNER JOIN 
        cte_EmptyString b ON CONCAT(a.A, a.B, a.C) = CONCAT(b.A, b.B, b.C);

----------
--VIEWS---
----------

--14.1
DROP TABLE IF EXISTS MyTable;
GO

CREATE TABLE MyTable
(
MyInteger INT NOT NULL,
MyVarchar Varchar(100) NOT NULL,
MyDate Date NOT NULL
);
GO

CREATE OR ALTER VIEW vwMyTable AS
SELECT MyInteger,
       MyVarchar,
       MyDate,
       CAST(MyInteger AS INT) AS MyInteger_Cast,
       CAST(MyVarchar AS VARCHAR(100)) AS MyVarchar_Cast,
       CAST(MyDate AS DATETIME) AS MyDate_Cast,
       MyInteger * 10 AS MyInteger_Computed
FROM   MyTable;
GO

DROP TABLE IF EXISTS MyTable;
DROP VIEW IF EXISTS vwMyTable;
GO

---------------
----BOOLEAN----
---------------

--15.1
SELECT CAST(NULL AS BIT) AS MyBit
UNION
SELECT CAST(3 AS BIT);

--15.2
SELECT  *
FROM    ##TableA
WHERE   NOT(FRUIT = 'Mango');

--------------
----RETURN----
--------------
--16.1
GO
CREATE OR ALTER PROCEDURE SpReturnStatement
AS
IF  1=2
    RETURN 1
ELSE
    RETURN NULL;
GO

DECLARE @return_status INT;

EXEC @return_status = SpReturnStatement;
SELECT 'Return Status' = @return_status;
GO

DROP PROCEDURE SpReturnStatement;
GO




---------------
----THE END----
---------------
