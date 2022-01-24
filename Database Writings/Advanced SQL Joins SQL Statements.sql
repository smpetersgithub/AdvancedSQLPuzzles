/*
Scott Peters
01/23/2022

The SQL statements from this document can be found in following Git repository.
https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Writings

The following examples are presented using SQL Servers TSQL.  You can easily modify the SQL statements to fit your flavor of SQL.

Please check out my website at:
https://advancedsqlpuzzles.com
*/

------------------------
--Create Sample Tables--
------------------------

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

INSERT INTO ##TableA 
VALUES (1,'Apple',17),(2,'Peach',20),(3,'Mango',11),(4,NULL,5);
GO

INSERT INTO ##TableB
VALUES (1,'Apple',17),(2,'Peach',25),(3,'Kiwi',20),(4,NULL,NULL);
GO

---------------------------
------INNER JOINS----------
---------------------------

--1.1
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit;

--1.2
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a,
        ##TableB b
WHERE   a.Fruit = b.Fruit;

--1.3
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   a.Fruit = b.Fruit;

--1.4
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit AND a.Quantity <> b.Quantity;

--1.5
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit <> b.Fruit OR a.Fruit = b.Fruit;

--1.6
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b;

--1.7
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Quantity >= b.Quantity;

--1.8
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit AND a.Quantity BETWEEN 10 AND 20;

--1.9
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON ISNULL(a.Fruit,'') = ISNULL(b.Fruit,'');

-------------------
--LEFT OUTER JOIN--
-------------------

--2.1
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a LEFT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit;

--2.2
SELECT  a.Fruit
FROM    ##TableA a LEFT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   b.Fruit IS NULL;

--2.3
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a LEFT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit AND b.Fruit = 'Apple';

--2.4
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a LEFT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   b.Fruit = 'Apple';

-------------------
--FULL OUTER JOIN--
-------------------

--3.1
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit;

--3.2
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.Fruit IS NULL OR b.Fruit IS NULL;

---------------
--CROSS JOINS--
---------------

--5.1
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b;

--5.2
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   (CASE a.Fruit WHEN 'Orange' THEN 'Tangerine' ELSE a.Fruit END) = b.Fruit;

--5.3
SELECT  a.Fruit,
        b.Fruit
FROM    ##TableA a,
        ##TableB b
WHERE   (CASE WHEN a.Quantity > 15 THEN a.Quantity ELSE a.ID END) = b.Quantity;

-----------------------
--SEMI AND ANTI JOINS--
-----------------------

--6.1
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB);

--6.2
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT ISNULL(Fruit,'') FROM ##TableB);

--6.3
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB WHERE Fruit IS NOT NULL);

--6.4
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN (SELECT Fruit FROM ##TableB);

--6.5
SELECT Fruit
FROM    ##TableA
WHERE   Fruit IN ('Apple','Kiwi',NULL);

--6.6
SELECT  Fruit
FROM    ##TableA a
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit AND a.Quantity = b.Quantity);

--6.7
SELECT  Fruit
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit AND a.Quantity = b.Quantity);

---------------------
--BEHAVIOR OF NULLS--
---------------------

--7.1
SELECT 1 WHERE NULL = NULL;
SELECT 1 WHERE 1 = NULL;
SELECT 1 WHERE NULL <> NULL;
SELECT 1 WHERE NULL = NULL;
SELECT 1 WHERE 1 = NULL;
SELECT 1 WHERE NULL <> NULL;
SELECT 1 WHERE 1 <> NULL;
SELECT 1 WHERE NULL > NULL;
SELECT 1 WHERE 1 > NULL;

--7.2
SELECT 1 WHERE NULL IS NULL;
SELECT 1 WHERE 1 IS NOT NULL;
SELECT 1 WHERE 1 = 1;

--7.3
SELECT 1 WHERE 1 IS NULL;
SELECT 1 WHERE NULL IS NOT NULL;
SELECT 1 WHERE 1 <> 1;

-------------------
-- VALUES KEYWORD--
-------------------

--8.1
SELECT a, b
FROM    (VALUES (1, 2), (3, 4), (5, 6), (7, 8), (9, 10)) AS MyTable(a, b);

--8.2
SELECT  a.Fruit
FROM    ##TableA a INNER JOIN
        (VALUES ('Kiwi'), ('Apple')) AS b(Fruit) ON a.Fruit = b.Fruit;

--8.3
SELECT  a.Fruit,
        b.New_ID
FROM    ##TableA a CROSS JOIN
        (VALUES (NEWID())) AS b(New_ID)

-----------------
--SET OPERATORS--
-----------------

--9.1
SELECT Fruit FROM ##TableA
UNION
SELECT Fruit FROM ##TableB;

--9.2
SELECT Fruit FROM ##TableA
UNION ALL
SELECT Fruit FROM ##TableB;

--9.3
SELECT Fruit FROM ##TableA
INTERSECT
SELECT Fruit FROM ##TableB;

--9.4
SELECT Fruit FROM ##TableA
EXCEPT
SELECT Fruit FROM ##TableB;

--------------
--SELF JOINS--
--------------
-------------
--Example 1--
-------------
DROP TABLE IF EXISTS #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID TINYINT NOT NULL,
[Name] VARCHAR(10),
Title VARCHAR(20),
ManagerID TINYINT
);
GO

INSERT INTO #Employees VALUES
(1,'Ramirez','President',NULL),
(2,'Baers','Vice President',1),
(3,'Santana','Vice President',1),
(4,'Perkins','Director',2),
(5,'Mercer','Director',3)

--10.1
SELECT  a.EmployeeID,
        a.[Name],
        a.Title,
        a.ManagerID,
        b.[Name] AS ManagerName,
        b.Title
FROM    #Employees a INNER JOIN
        #Employees b ON a.ManagerID = b.EmployeeID;

--10.2
WITH cte_Recursion AS
(
SELECT  EmployeeID,
        [Name],
        Title,
        ManagerID, 0 AS Depth
FROM    #Employees
WHERE   ManagerID IS NULL
UNION ALL
SELECT  b.EmployeeID,
        b.[Name],
        b.Title,
        b.ManagerID,
        a.Depth + 1 AS Depth
FROM    cte_Recursion a INNER JOIN
        #Employees b on a.EmployeeID = b.ManagerID
)
SELECT  a.EmployeeID,
        a.[Name],
        a.Title,
        a.ManagerID,
        b.[Name] AS ManagerName,
        b.Title AS ManagerTitle,
        a.Depth
FROM    cte_Recursion a LEFT JOIN
        #Employees b ON a.ManagerID = b.EmployeeID
ORDER BY 1;

-------------
--Example 2--
-------------

DROP TABLE IF EXISTS #Customers;
GO

CREATE TABLE #Customers
(
ID      TINYINT NOT NULL,
[Name]  VARCHAR(10) NOT NULL,
City    VARCHAR(10) NOT NULL
);
GO

INSERT INTO #Customers VALUES
(1,'Smith','Milwaukee'),
(2,'Harshaw','Detroit'),
(3,'Brown','Dallas'),
(4,'Williams','Detroit');
GO

--10.3
SELECT  a.ID,
        a.[Name],
        a.City
FROM    #Customers a INNER JOIN
        #Customers b ON a.City = b.City AND a.[Name] <> b.[Name];

-------------
--Example 3--
-------------

DROP TABLE IF EXISTS #Animals;
GO

CREATE TABLE #Animals
(
ID          TINYINT,
Animal      VARCHAR(20),
[Weight]    INTEGER
);
GO

INSERT INTO #Animals VALUES
(1,'Elephant',13000),
(2,'Rhinoceros',8000),
(3,'Hippopotamus',3000),
(4,'Giraffe',2000),
(5,'Water Buffalo',2000)
GO

--10.5
SELECT  a.ID,
        a.Animal,
        SUM(b.[Weight]) AS Cummulative_Weight
FROM    #Animals a CROSS JOIN
        #Animals b
WHERE   a.ID >= b.ID
GROUP BY a.ID, a.Animal;

--10.6
SELECT  ID,
        Animal,
        SUM(Weight) OVER(ORDER BY ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cummulative_Weight
FROM    #Animals;

---------------------
--Positive Balances--
---------------------

DROP TABLE IF EXISTS #AccountBalances;
GO

CREATE TABLE #AccountBalances
(
ID      INTEGER NOT NULL,
Balance MONEY NOT NULL
);
GO

INSERT INTO #AccountBalances VALUES
(45643,-123),(45643,-343),(45643,-34),(18797,-45),(18797,-56),
(18797,67),(18797,78),(87765,12),(87765,567),(87765,343);
GO

--11.1
SELECT DISTINCT ID FROM #AccountBalances WHERE Balance < 0
EXCEPT
SELECT DISTINCT ID FROM #AccountBalances WHERE Balance > 0;

--11.2
SELECT  ID
FROM    #AccountBalances
GROUP BY ID
HAVING  MAX(Balance) < 0;

--11.3
SELECT  DISTINCT
        ID
FROM    #AccountBalances
WHERE   ID NOT IN (SELECT ID FROM #AccountBalances WHERE Balance > 0);

--11.4
SELECT  DISTINCT ID
FROM    #AccountBalances a
WHERE   NOT EXISTS (SELECT 1 FROM #AccountBalances b WHERE Balance > 0 AND a.ID = b.ID);

--11.5
SELECT  DISTINCT
        a.ID
FROM    #AccountBalances a LEFT OUTER JOIN
        #AccountBalances b ON a.ID = b.ID AND b.Balance > 0
WHERE   b.ID IS NULL;

-------------------------
-------------------------
--Mutual Friends Puzzle--
-------------------------
------------------------

DROP TABLE IF EXISTS #Friends;
GO

CREATE TABLE #Friends
(
Friend1 VARCHAR(10) NOT NULL,
Friend2 VARCHAR(10) NOT NULL,
);
GO

INSERT INTO #Friends VALUES
('Jason','Mary'),
('Mike','Mary'),
('Mike','Jason'),
('Susan','Jason'),
('John','Mary'),
('Susan','Mary');
GO

--Step 1
--12.1
WITH cte_Reciprocal_Friends AS
(
SELECT  Friend1,
        Friend2
FROM    #Friends
UNION
SELECT  Friend2,
        Friend1
FROM    #Friends
)
SELECT  *
INTO    #Distinct_Friends_Full_1
FROM    cte_Reciprocal_Friends;

--Step 2
--12.2
SELECT  a.*
        ,b.Friend2 AS Mutual_Friend_Check
INTO    #Mutual_Friend_Check_2
FROM    #Distinct_Friends_Full_1 a INNER JOIN
        #Distinct_Friends_Full_1 b ON a.Friend2 = b.Friend1
WHERE   a.Friend1 <> b.Friend2;

--Step 3
--12.3
SELECT  (CASE WHEN Friend1 < Friend2 THEN Friend1 ELSE Friend2 END) AS Friend1
        ,(CASE WHEN Friend1 < Friend2 THEN Friend2 ELSE Friend1 END) AS Friend2
        ,Mutual_Friend_Check
INTO    #Reciprocal_Mutual_Friend_Check_3
FROM    #Mutual_Friend_Check_2;

--Step 4
--12.4
SELECT  Friend1
        ,Friend2
        ,Mutual_Friend_Check
        ,COUNT(*) AS Grouping_Count
INTO    #Reciprocal_Mutual_Friend_Check_Count_4
FROM    #Reciprocal_Mutual_Friend_Check_3
GROUP BY Friend1, Friend2, Mutual_Friend_Check;

--Step 5
--12.5
SELECT  Friend1
        ,Friend2
        ,Mutual_Friend_Check
        ,(CASE Grouping_Count WHEN 1 THEN 0 WHEN 2 THEN 1 END) AS Friend_Count
INTO    #Reciprocal_Mutual_Friend_Check_Count_Modified_5
FROM    #Reciprocal_Mutual_Friend_Check_Count_4;

--Step 6
--12.6
SELECT  Friend1
        ,Friend2
        ,SUM(Friend_Count) AS Total_Mutual_Friends 
FROM    #Reciprocal_Mutual_Friend_Check_Count_Modified_5
GROUP BY Friend1, Friend2;
