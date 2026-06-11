/*----------------------------------------------------
Scott Peters
Solutions for Advanced SQL Puzzles
https://advancedsqlpuzzles.com
Last Updated: 06/11/2026
Microsoft SQL Server T-SQL

*/----------------------------------------------------

SET NOCOUNT ON;
GO

/*----------------------------------------------------
Puzzle #1 - Shopping Carts
*/----------------------------------------------------

DROP TABLE IF EXISTS #Cart1;
DROP TABLE IF EXISTS #Cart2;
GO

CREATE TABLE #Cart1
(
Item  VARCHAR(100)
);
GO

CREATE TABLE #Cart2
(
Item  VARCHAR(100)
);
GO

INSERT INTO #Cart1 (Item) VALUES
('Sugar'),('Bread'),('Juice'),('Soda'),('Flour');
GO

INSERT INTO #Cart2 (Item) VALUES
('Sugar'),('Bread'),('Butter'),('Cheese'),('Fruit');
GO

--Solution 1
--FULL OUTER JOIN
SELECT  a.Item AS ItemCart1,
        b.Item AS ItemCart2
FROM    #Cart1 a FULL OUTER JOIN
        #Cart2 b ON a.Item = b.Item;
GO

--Solution 2
--LEFT JOIN, UNION and RIGHT JOIN
SELECT  a.Item AS Item1,
        b.Item AS Item2
FROM    #Cart1 a 
        LEFT JOIN #Cart2 b ON a.Item = b.Item
UNION
SELECT  a.Item AS Item1,
        b.Item AS Item2
FROM    #Cart1 a 
        RIGHT JOIN #Cart2 b ON a.Item = b.Item;

--Solution 3
--This solution does not use a FULL OUTER JOIN
SELECT  a.Item AS Item1,
        b.Item AS Item2
FROM    #Cart1 a INNER JOIN
        #Cart2 b ON a.Item = b.Item
UNION
SELECT  a.Item AS Item1,
        NULL AS Item2
FROM    #Cart1 a
WHERE   a.Item NOT IN (SELECT b.Item FROM #Cart2 b)
UNION
SELECT  NULL AS Item1, 
        b.Item AS Item2
FROM    #Cart2 b
WHERE b.Item NOT IN (SELECT a.Item FROM #Cart1 a)
ORDER BY 1,2;
GO

/*----------------------------------------------------
Puzzle #2 - Managers and Employees
*/----------------------------------------------------

DROP TABLE IF EXISTS #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID  INTEGER,
ManagerID   INTEGER,
JobTitle    VARCHAR(100)
);
GO

INSERT INTO #Employees (EmployeeID, ManagerID, JobTitle) VALUES
(1001,NULL,'CEO'),(2002,1001,'Director'),
(3003,1001,'Office Manager'),(4004,2002,'Engineer'),
(5005,2002,'Engineer'),(6006,2002,'Engineer');
GO

--Recursion
WITH cte_Recursion AS
(
SELECT  EmployeeID, ManagerID, JobTitle, 0 AS Depth
FROM    #Employees a
WHERE   ManagerID IS NULL
UNION ALL
SELECT  b.EmployeeID, b.ManagerID, b.JobTitle, a.Depth + 1 AS Depth
FROM    cte_Recursion a INNER JOIN 
        #Employees b ON a.EmployeeID = b.ManagerID
)
SELECT  EmployeeID,
        ManagerID,
        JobTitle,
        Depth
FROM    cte_Recursion;
GO

/*----------------------------------------------------
Puzzle #3 - Fiscal Year Table Constraints
*/----------------------------------------------------

DROP TABLE IF EXISTS #EmployeePayRecords;
GO

CREATE TABLE #EmployeePayRecords
(
EmployeeID  INTEGER,
FiscalYear  INTEGER,
StartDate   DATE,
EndDate     DATE,
PayRate     MONEY
);
GO

--NOT NULL
ALTER TABLE #EmployeePayRecords ALTER COLUMN EmployeeID INTEGER NOT NULL;
ALTER TABLE #EmployeePayRecords ALTER COLUMN FiscalYear INTEGER NOT NULL;
ALTER TABLE #EmployeePayRecords ALTER COLUMN StartDate DATE NOT NULL;
ALTER TABLE #EmployeePayRecords ALTER COLUMN EndDate DATE NOT NULL;
ALTER TABLE #EmployeePayRecords ALTER COLUMN PayRate MONEY NOT NULL;
GO
--PRIMARY KEY
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT PK_FiscalYearCalendar
                                    PRIMARY KEY (EmployeeID,FiscalYear);
--CHECK CONSTRAINTS
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT Check_Year_StartDate
                                    CHECK (FiscalYear = DATEPART(YYYY,StartDate));
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT Check_Month_StartDate 
                                    CHECK (DATEPART(MM,StartDate) = 01);
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT Check_Day_StartDate 
                                    CHECK (DATEPART(DD,StartDate) = 01);
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT Check_Year_EndDate
                                    CHECK (FiscalYear = DATEPART(YYYY,EndDate));
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT Check_Month_EndDate 
                                    CHECK (DATEPART(MM,EndDate) = 12);
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT Check_Day_EndDate 
                                    CHECK (DATEPART(DD,EndDate) = 31);
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT Check_Payrate
                                    CHECK (PayRate > 0);
GO

/*----------------------------------------------------
Puzzle #4 - Two Predicates
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
CustomerID     INTEGER,
OrderID        INTEGER,
DeliveryState  VARCHAR(100),
Amount         MONEY
);
GO

INSERT INTO #Orders (CustomerID, OrderID, DeliveryState, Amount) VALUES
(1001,1,'CA',340),(1001,2,'TX',950),(1001,3,'TX',670),
(1001,4,'TX',860),(2002,5,'WA',320),(3003,6,'CA',650),
(3003,7,'CA',830),(4004,8,'TX',120);
GO

--Solution 1
--INNER JOIN
WITH cte_CA AS
(
SELECT  DISTINCT CustomerID
FROM    #Orders
WHERE   DeliveryState = 'CA'
)
SELECT  b.CustomerID, b.OrderID, b.DeliveryState, b.Amount
FROM    cte_CA a INNER JOIN
        #Orders b ON a.CustomerID = B.CustomerID
WHERE   b.DeliveryState = 'TX'
ORDER BY b.CustomerID, b.OrderID;
GO

--Solution 2
--IN
WITH cte_CA AS
(
SELECT  CustomerID
FROM    #Orders
WHERE   DeliveryState = 'CA'
)
SELECT  CustomerID,
        OrderID,
        DeliveryState,
        Amount
FROM    #Orders
WHERE   DeliveryState = 'TX' AND
        CustomerID IN (SELECT b.CustomerID FROM cte_CA b)
ORDER BY CustomerID, OrderID;
GO

--Solution 3
--EXISTS
SELECT  CustomerID,
        OrderID,
        DeliveryState,
        Amount
FROM    #Orders o
WHERE   DeliveryState = 'TX'
  AND   EXISTS (SELECT 1
                FROM #Orders o2
                WHERE o2.CustomerID = o.CustomerID AND 
                      o2.DeliveryState = 'CA')
ORDER BY CustomerID, OrderID;
GO

/*----------------------------------------------------
Puzzle #5 - Phone Directory
*/----------------------------------------------------

DROP TABLE IF EXISTS #PhoneDirectory;
GO

CREATE TABLE #PhoneDirectory
(
CustomerID   INTEGER,
[Type]       VARCHAR(100),
PhoneNumber  VARCHAR(12)
);
GO

INSERT INTO #PhoneDirectory (CustomerID, [Type], PhoneNumber) VALUES
(1001,'Cellular','555-897-5421'),
(1001,'Work','555-897-6542'),
(1001,'Home','555-698-9874'),
(2002,'Cellular','555-963-6544'),
(2002,'Work','555-812-9856'),
(3003,'Cellular','555-987-6541');
GO

--Solution 1
--PIVOT
SELECT  CustomerID,[Cellular],[Work],[Home]
FROM    #PhoneDirectory PIVOT
       (MAX(PhoneNumber) FOR [Type] IN ([Cellular],[Work],[Home])) AS PivotClause;
GO

--Solution 2
--MAX and CASE
SELECT  CustomerID,
        MAX(CASE [Type] WHEN 'Cellular' THEN PhoneNumber END) AS Cellular,
        MAX(CASE [Type] WHEN 'Work' THEN PhoneNumber END)     AS Work,
        MAX(CASE [Type] WHEN 'Home' THEN PhoneNumber END)     AS Home
FROM    #PhoneDirectory
GROUP BY CustomerID;
GO

--Solution 3
--OUTER JOIN
WITH cte_Cellular AS
(
SELECT  CustomerID, PhoneNumber AS Cellular
FROM    #PhoneDirectory
WHERE   [Type] = 'Cellular'
),
cte_Work AS
(
SELECT  CustomerID, PhoneNumber AS Work
FROM    #PhoneDirectory
WHERE   [Type] = 'Work'
),
cte_Home AS
(
SELECT  CustomerID, PhoneNumber AS Home
FROM    #PhoneDirectory
WHERE   [Type] = 'Home'
)
SELECT  a.CustomerID,
        b.Cellular,
        c.Work,
        d.Home
FROM    (SELECT DISTINCT CustomerID FROM #PhoneDirectory) a LEFT OUTER JOIN
        cte_Cellular b ON a.CustomerID = b.CustomerID LEFT OUTER JOIN
        cte_Work c ON a.CustomerID = c.CustomerID LEFT OUTER JOIN
        cte_Home d ON a.CustomerID = d.CustomerID;
GO

--Solution 4
--MAX
WITH cte_PhoneNumbers AS
(
SELECT  CustomerID,
        PhoneNumber AS Cellular,
        NULL AS work,
        NULL AS home
FROM    #PhoneDirectory
WHERE   [Type] = 'Cellular'
UNION
SELECT  CustomerID,
        NULL Cellular,
        PhoneNumber AS Work,
        NULL home
FROM    #PhoneDirectory
WHERE   [Type] = 'Work'
UNION
SELECT  CustomerID,
        NULL Cellular,
        NULL Work,
        PhoneNumber AS Home
FROM    #PhoneDirectory
WHERE   [Type] = 'Home'
)
SELECT  CustomerID,
        MAX(Cellular),
        MAX(Work),
        MAX(Home)
FROM    cte_PhoneNumbers
GROUP BY CustomerID;
GO

/*----------------------------------------------------
Puzzle #6 - Workflow Steps
*/----------------------------------------------------

DROP TABLE IF EXISTS #WorkflowSteps;
GO

CREATE TABLE #WorkflowSteps
(
Workflow        VARCHAR(100),
StepNumber      INTEGER,
CompletionDate  DATE
);
GO

INSERT INTO #WorkflowSteps (Workflow, StepNumber, CompletionDate) VALUES
('Alpha',1,'7/2/2018'),('Alpha',2,'7/2/2018'),('Alpha',3,'7/1/2018'),
('Bravo',1,'6/25/2018'),('Bravo',2,NULL),('Bravo',3,'6/27/2018'),
('Charlie',1,NULL),('Charlie',2,'7/1/2018'),
('Delta',1,NULL),('Delta',2,NULL);
GO

--NULL operators
SELECT  DISTINCT Workflow
FROM    #WorkflowSteps
WHERE   Workflow IN (SELECT Workflow FROM #WorkflowSteps WHERE CompletionDate IS NULL) 
  AND   CompletionDate IS NOT NULL;
GO

/*----------------------------------------------------
Puzzle #7 - Mission to Mars
*/----------------------------------------------------

DROP TABLE IF EXISTS #Candidates;
DROP TABLE IF EXISTS #Requirements;
GO

CREATE TABLE #Candidates
(
CandidateID  INTEGER,
Occupation   VARCHAR(100)
);
GO

INSERT INTO #Candidates (CandidateID, Occupation) VALUES
(1001,'Geologist'),(1001,'Astrogator'),(1001,'Biochemist'),
(1001,'Technician'),(2002,'Surgeon'),(2002,'Machinist'),(2002,'Geologist'),
(3003,'Geologist'),(3003,'Astrogator'),(4004,'Selenologist');
GO

CREATE TABLE #Requirements
(
Requirement  VARCHAR(100)
);
GO

INSERT INTO #Requirements (Requirement) VALUES
('Geologist'),('Astrogator'),('Technician');
GO

SELECT  CandidateID
FROM    #Candidates
WHERE   Occupation IN (SELECT Requirement FROM #Requirements)
GROUP BY CandidateID
HAVING COUNT(*) = (SELECT COUNT(*) FROM #Requirements);
GO

/*----------------------------------------------------
Puzzle #8 - Workflow Cases
*/----------------------------------------------------

DROP TABLE IF EXISTS #WorkflowCases;
GO

CREATE TABLE #WorkflowCases
(
Workflow  VARCHAR(100),
Case1     INTEGER,
Case2     INTEGER,
Case3     INTEGER,
);
GO

INSERT INTO #WorkflowCases (Workflow, Case1, Case2, Case3) VALUES
('Alpha',0,0,0),('Bravo',0,1,1),('Charlie',1,0,0),('Delta',0,0,0);
GO

--Solution 1
--Add each column
SELECT  Workflow,
        Case1 + Case2 + Case3 AS PassFail
FROM    #WorkflowCases;
GO

--Solution 2
--UNPIVOT operator
WITH cte_PassFail AS
(
SELECT  Workflow, CaseNumber, PassFail
FROM    (
        SELECT Workflow,Case1,Case2,Case3
        FROM #WorkflowCases
        ) p UNPIVOT (PassFail FOR CaseNumber IN (Case1,Case2,Case3)) AS UNPVT
)
SELECT  Workflow,
        SUM(PassFail) AS PassFail
FROM    cte_PassFail
GROUP BY Workflow
ORDER BY 1;
GO

/*----------------------------------------------------
Puzzle #9 - Matching Sets
*/----------------------------------------------------

DROP TABLE IF EXISTS #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID  INTEGER,
License     VARCHAR(100)
);
GO

INSERT INTO #Employees (EmployeeID, License) VALUES
(1001,'Class A'),(1001,'Class B'),(1001,'Class C'),
(2002,'Class A'),(2002,'Class B'),(2002,'Class C'),
(3003,'Class A'),(3003,'Class D'),
(4004,'Class A'),(4004,'Class B'),(4004,'Class D'),
(5005,'Class A'),(5005,'Class B'),(5005,'Class D');
GO

--Solution 1
WITH cte_Count AS
(
SELECT  EmployeeID,
        COUNT(*) AS LicenseCount
FROM    #Employees
GROUP BY EmployeeID
),
cte_CountWindow AS
(
SELECT  a.EmployeeID AS EmployeeID_A,
        b.EmployeeID AS EmployeeID_B,
        COUNT(*) OVER (PARTITION BY a.EmployeeID, b.EmployeeID) AS CountWindow
FROM    #Employees a CROSS JOIN
        #Employees b
WHERE   a.EmployeeID <> b.EmployeeID and a.License = b.License
)
SELECT  DISTINCT
        a.EmployeeID_A,
        a.EmployeeID_B,
        a.CountWindow AS LicenseCount
FROM    cte_CountWindow a INNER JOIN
        cte_Count b ON a.CountWindow = b.LicenseCount AND a.EmployeeID_A = b.EmployeeID INNER JOIN
        cte_Count c ON a.CountWindow = c.LicenseCount AND a.EmployeeID_B = c.EmployeeID;
GO

--Solution 2
WITH EmployeeLicenseCounts AS
(
SELECT  EmployeeID,
        COUNT(*) AS LicenseCount
FROM    #Employees
GROUP BY EmployeeID
)
SELECT  e1.EmployeeID AS Employee_A,
        e2.EmployeeID AS Employee_B,
        COUNT(*) AS LicenseCount
FROM #Employees e1 INNER JOIN 
     #Employees e2 ON e1.License = e2.License AND e1.EmployeeID <> e2.EmployeeID INNER JOIN
     EmployeeLicenseCounts c1 ON e1.EmployeeID = c1.EmployeeID INNER JOIN
     EmployeeLicenseCounts c2 ON e2.EmployeeID = c2.EmployeeID
GROUP BY
    e1.EmployeeID,
    e2.EmployeeID,
    c1.LicenseCount,
    c2.LicenseCount
HAVING
    COUNT(*) = c1.LicenseCount
    AND COUNT(*) = c2.LicenseCount;
GO

/*----------------------------------------------------
Puzzle #10 - Mean, Median, Mode, and Range
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue  INTEGER
);
GO

INSERT INTO #SampleData (IntegerValue) VALUES
(5),(6),(10),(10),(13),(14),(17),(20),(81),(90),(76);
GO

WITH ModeValue AS
(
    SELECT TOP (1)
        IntegerValue
    FROM #SampleData
    GROUP BY IntegerValue
    ORDER BY COUNT(*) DESC, IntegerValue
)
SELECT DISTINCT
    CAST(AVG(CAST(IntegerValue AS DECIMAL(10,2))) OVER () AS DECIMAL(10,2)) AS Mean,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY IntegerValue)
        OVER () AS Median,
    (SELECT IntegerValue FROM ModeValue) AS Mode,
    MAX(IntegerValue) OVER () - MIN(IntegerValue) OVER () AS [Range]
FROM #SampleData;
GO

/*----------------------------------------------------
Puzzle #11 - Permutations
*/----------------------------------------------------

DROP TABLE IF EXISTS #TestCases;
GO

CREATE TABLE #TestCases
(
TestCase  VARCHAR(1)
);
GO

INSERT INTO #TestCases (TestCase) VALUES
('A'),('B'),('C');
GO

WITH Permutations AS
(
    -- Anchor
    SELECT
        CAST(TestCase AS VARCHAR(MAX)) AS Permutation,
        CAST(',' + TestCase + ',' AS VARCHAR(MAX)) AS UsedValues,
        1 AS Level
    FROM #TestCases

    UNION ALL

    -- Recursive
    SELECT
        p.Permutation + ',' + t.TestCase,
        p.UsedValues + t.TestCase + ',',
        p.Level + 1
    FROM Permutations p
    JOIN #TestCases t
        ON p.UsedValues NOT LIKE '%,' + t.TestCase + ',%'
)
SELECT
    Permutation AS [Test Cases]
FROM Permutations
WHERE Level = (SELECT COUNT(*) FROM #TestCases)
ORDER BY Permutation
OPTION (MAXRECURSION 0);
GO

/*----------------------------------------------------
Puzzle #12 - Average Days
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow       VARCHAR(100),
ExecutionDate  DATE
);
GO

INSERT INTO #ProcessLog (Workflow, ExecutionDate) VALUES
('Alpha','6/01/2018'),('Alpha','6/14/2018'),('Alpha','6/15/2018'),
('Bravo','6/1/2018'),('Bravo','6/2/2018'),('Bravo','6/19/2018'),
('Charlie','6/1/2018'),('Charlie','6/15/2018'),('Charlie','6/30/2018');
GO

WITH cte_DayDiff AS
(
SELECT  Workflow,
        (DATEDIFF(DD,LAG(ExecutionDate,1,NULL) OVER
                (PARTITION BY Workflow ORDER BY ExecutionDate),ExecutionDate)) AS DateDifference
FROM    #ProcessLog
)
SELECT  Workflow,
        AVG(DateDifference)
FROM    cte_DayDiff
WHERE   DateDifference IS NOT NULL
GROUP BY Workflow;
GO

/*----------------------------------------------------
Puzzle #13 - Inventory Tracking
*/----------------------------------------------------

DROP TABLE IF EXISTS #Inventory;
GO

CREATE TABLE #Inventory
(
InventoryDate       DATE,
QuantityAdjustment  INTEGER
);
GO

INSERT INTO #Inventory (InventoryDate, QuantityAdjustment) VALUES
('7/1/2018',100),('7/2/2018',75),('7/3/2018',-150),
('7/4/2018',50),('7/5/2018',-100);
GO

SELECT  InventoryDate,
        QuantityAdjustment,
        SUM(QuantityAdjustment) OVER (ORDER BY InventoryDate ROWS UNBOUNDED PRECEDING) AS Inventory
FROM    #Inventory;
GO

/*----------------------------------------------------
Puzzle #14 - Indeterminate Process Log
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow    VARCHAR(100),
StepNumber  INTEGER,
RunStatus   VARCHAR(100)
);
GO

INSERT INTO #ProcessLog (Workflow, StepNumber, RunStatus) VALUES
('Alpha',1,'Error'),('Alpha',2,'Complete'),('Alpha',3,'Running'),
('Bravo',1,'Complete'),('Bravo',2,'Complete'),
('Charlie',1,'Running'),('Charlie',2,'Running'),
('Delta',1,'Error'),('Delta',2,'Error'),
('Echo',1,'Running'),('Echo',2,'Complete');
GO

--Solution 1
--Conditional with CASE
SELECT  Workflow,
        CASE
        WHEN COUNT(DISTINCT RunStatus) = 1
            THEN MAX(RunStatus)

        WHEN SUM(CASE WHEN RunStatus = 'Error' THEN 1 ELSE 0 END) > 0
            THEN 'Indeterminate'

        WHEN SUM(CASE WHEN RunStatus = 'Running' THEN 1 ELSE 0 END) > 0
             AND SUM(CASE WHEN RunStatus = 'Complete' THEN 1 ELSE 0 END) > 0
            THEN 'Running'
        END AS RunStatus
FROM #ProcessLog
GROUP BY Workflow
ORDER BY Workflow;
GO

--Solution 2
--MIN and MAX
WITH cte_MinMax AS
(
SELECT  Workflow,
        MIN(RunStatus) AS MinStatus,
        MAX(RunStatus) AS MaxStatus
FROM    #ProcessLog
GROUP BY Workflow
),
cte_Error AS
(
SELECT  Workflow,
        MAX(CASE RunStatus WHEN 'Error' THEN RunStatus END) AS ErrorState,
        MAX(CASE RunStatus WHEN 'Running' THEN RunStatus END) AS RunningState
FROM    #ProcessLog
WHERE   RunStatus IN ('Error','Running')
GROUP BY Workflow
)
SELECT  a.Workflow,
        CASE WHEN a.MinStatus = a.MaxStatus THEN a.MinStatus
             WHEN b.ErrorState = 'Error' THEN 'Indeterminate'
             WHEN b.RunningState = 'Running' THEN b.RunningState END AS RunStatus
FROM    cte_MinMax a LEFT OUTER JOIN
        cte_Error b ON a.WorkFlow = b.WorkFlow
ORDER BY 1;
GO

--Solution 3
--COUNT and STRING_AGG
WITH cte_Distinct AS
(
SELECT DISTINCT
       Workflow,
       RunStatus
FROM   #ProcessLog
),
cte_StringAgg AS
(
SELECT  Workflow,
        STRING_AGG(RunStatus,', ') AS RunStatus_Agg,
        COUNT(DISTINCT RunStatus) AS DistinctCount
FROM    cte_Distinct
GROUP BY Workflow
)
SELECT  Workflow,
        CASE WHEN DistinctCount = 1 THEN RunStatus_Agg
             WHEN RunStatus_Agg LIKE '%Error%' THEN 'Indeterminate'
             WHEN RunStatus_Agg LIKE '%Running%' THEN 'Running' END AS RunStatus
FROM    cte_StringAgg
ORDER BY 1;

/*----------------------------------------------------
Puzzle #15 - Group Concatenation
*/----------------------------------------------------

DROP TABLE IF EXISTS #DMLTable;
GO

CREATE TABLE #DMLTable
(
SequenceNumber  INTEGER,
String          VARCHAR(100)
);
GO

INSERT INTO #DMLTable (SequenceNumber, String) VALUES
(1,'SELECT'),
(2,'Product,'),
(3,'UnitPrice,'),
(4,'EffectiveDate'),
(5,'FROM'),
(6,'Products'),
(7,'WHERE'),
(8,'UnitPrice'),
(9,'> 100');
GO

--Solution 1
--STRING_AGG
SELECT  STRING_AGG(CONVERT(NVARCHAR(MAX),String), ' ') WITHIN GROUP (ORDER BY SequenceNumber ASC)
FROM    #DMLTable;
GO

--Solution 2
--Recursion
WITH cte_DMLGroupConcat(String2,Depth) AS
(
SELECT  CAST('' AS NVARCHAR(MAX)),
        CAST(MAX(SequenceNumber) AS INTEGER)
FROM    #DMLTable
UNION ALL
SELECT  cte_Ordered.String + ' ' + cte_Concat.String2, cte_Concat.Depth-1
FROM    cte_DMLGroupConcat cte_Concat INNER JOIN
        #DMLTable cte_Ordered ON cte_Concat.Depth = cte_Ordered.SequenceNumber
)
SELECT  String2
FROM    cte_DMLGroupConcat
WHERE   Depth = 0;
GO

--Solution 3
--XML Path
SELECT  STUFF((SELECT ' ' + [String]
               FROM #DMLTable
               ORDER BY SequenceNumber FOR XML PATH(''), TYPE
              ).value('.', 'varchar(max)'),
             1,
             1,
             ''
             ) AS [Syntax];


/*----------------------------------------------------
Puzzle #16 - Reciprocals
*/----------------------------------------------------

DROP TABLE IF EXISTS #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
PlayerA  INTEGER,
PlayerB  INTEGER,
Score    INTEGER
);
GO

INSERT INTO #PlayerScores (PlayerA, PlayerB, Score) VALUES
(1001,2002,150),(3003,4004,15),(4004,3003,125);
GO

SELECT  PlayerA,
        PlayerB,
        SUM(Score) AS Score
FROM    (
        SELECT
                (CASE WHEN PlayerA <= PlayerB THEN PlayerA ELSE PlayerB END) PlayerA,
                (CASE WHEN PlayerA <= PlayerB THEN PlayerB ELSE PlayerA END) PlayerB,
                Score
        FROM    #PlayerScores
        ) a
GROUP BY PlayerA, PlayerB;
GO

/*----------------------------------------------------
Puzzle #17 - De-Grouping
*/----------------------------------------------------

DROP TABLE IF EXISTS #Ungroup;
DROP TABLE IF EXISTS #Numbers;
GO

CREATE TABLE #Ungroup
(
ProductDescription  VARCHAR(100),
Quantity            INTEGER
);
GO

INSERT INTO #Ungroup (ProductDescription, Quantity) VALUES
('Pencil',3),('Eraser',4),('Notebook',2);
GO

--Solution 1
--Numbers Table
SELECT IntegerValue
INTO   #Numbers
FROM   (VALUES(1),(2),(3),(4)) a(IntegerValue) 
GO

SELECT  a.ProductDescription,
        1 AS Quantity
FROM    #Ungroup a CROSS JOIN
        #Numbers b
WHERE   a.Quantity >= b.IntegerValue;
GO

--Solution 2
--Recursion
WITH cte_Recursion AS
(
SELECT  ProductDescription,Quantity 
FROM    #Ungroup
UNION ALL
SELECT  ProductDescription,Quantity-1 
FROM    cte_Recursion
WHERE   Quantity >= 2
    )
SELECT  ProductDescription,1 AS Quantity
FROM   cte_Recursion
ORDER BY ProductDescription DESC;
GO

/*----------------------------------------------------
Puzzle #18 - Seating Chart
*/----------------------------------------------------

DROP TABLE IF EXISTS #SeatingChart;
GO

CREATE TABLE #SeatingChart
(
SeatNumber  INTEGER
);
GO

INSERT INTO #SeatingChart (SeatNumber) VALUES
(7),(13),(14),(15),(27),(28),(29),(30),(31),(32),(33),(34),(35),(52),(53),(54);
GO

-------------------
--Gap start and gap end
--Solution 1
WITH SeatRanges AS
(
    SELECT
        SeatNumber,
        LAG(SeatNumber) OVER (ORDER BY SeatNumber) AS PreviousSeat
    FROM #SeatingChart
)
SELECT
    1 AS GapStart,
    MIN(SeatNumber) - 1 AS GapEnd
FROM #SeatingChart
WHERE (SELECT MIN(SeatNumber) FROM #SeatingChart) > 1

UNION ALL

SELECT
    PreviousSeat + 1,
    SeatNumber - 1
FROM SeatRanges
WHERE SeatNumber - PreviousSeat > 1
ORDER BY GapStart;

--Solution 2
--Place a value of 0 in the SeatingChart table
INSERT INTO #SeatingChart (SeatNumber) VALUES (0);
GO

WITH cte_Gaps AS 
(
SELECT  SeatNumber AS GapStart,
        LEAD(SeatNumber,1,0) OVER (ORDER BY SeatNumber) AS GapEnd,
        LEAD(SeatNumber,1,0) OVER (ORDER BY SeatNumber) - SeatNumber AS Gap
FROM    #SeatingChart
)
SELECT  GapStart + 1 AS GapStart,
        GapEnd - 1 AS GapEnd
FROM    cte_Gaps
WHERE Gap > 1;
GO

DELETE #SeatingChart WHERE SeatNumber = 0;
GO

-------------------
--Sequence start and sequence end
WITH cte_Sequences AS 
(
SELECT  SeatNumber,
        SeatNumber - ROW_NUMBER() OVER (ORDER BY SeatNumber) AS GroupID
FROM    #SeatingChart
)
SELECT  MIN(SeatNumber) AS SequenceStart,
        MAX(SeatNumber) AS SequenceEnd
FROM    cte_Sequences
GROUP BY GroupID
ORDER BY SequenceStart;
GO

DELETE #SeatingChart WHERE SeatNumber = 0;

-------------------
--Missing Numbers
--Solution 1
--This solution provides a method if you need to window/partition the records
WITH cte_Rank
AS
(
SELECT  SeatNumber,
        ROW_NUMBER() OVER (ORDER BY SeatNumber) AS RowNumber,
        SeatNumber - ROW_NUMBER() OVER (ORDER BY SeatNumber) AS Rnk
FROM    #SeatingChart
WHERE   SeatNumber > 0
)
SELECT  MAX(Rnk) AS MissingNumbers
FROM    cte_Rank;
GO

--Solution 2
SELECT  MAX(SeatNumber) - COUNT(SeatNumber) AS MissingNumbers
FROM    #SeatingChart
WHERE   SeatNumber <> 0;
GO

-------------------
--Odd and even number count
WITH cte_Seats AS
(
SELECT  *
FROM    #SeatingChart
WHERE   SeatNumber > 0
)
SELECT  (CASE SeatNumber%2 WHEN 1 THEN 'Odd' WHEN 0 THEN 'Even' END) AS Modulus,
        COUNT(*) AS [Count]
FROM    cte_Seats
GROUP BY (CASE SeatNumber%2 WHEN 1 THEN 'Odd' WHEN 0 THEN 'Even' END);
GO

/*----------------------------------------------------
Puzzle #19 - Back to the Future
*/----------------------------------------------------

DROP TABLE IF EXISTS #TimePeriods;
DROP TABLE IF EXISTS #Distinct_StartDates;
DROP TABLE IF EXISTS #OuterJoin;
DROP TABLE IF EXISTS #DetermineValidEndDates;
DROP TABLE IF EXISTS #DetermineValidEndDates2;
GO

CREATE TABLE #TimePeriods
(
StartDate  DATE,
EndDate    DATE
);
GO

INSERT INTO #TimePeriods (StartDate, EndDate) VALUES
('1/1/2018','1/5/2018'),
('1/3/2018','1/9/2018'),
('1/10/2018','1/11/2018'),
('1/12/2018','1/16/2018'),
('1/15/2018','1/19/2018');
GO

WITH cte_Lag AS
(
SELECT  StartDate,
        EndDate,
        LAG(EndDate) OVER (ORDER BY StartDate) AS PreviousEndDate
FROM #TimePeriods
),
cte_Islands AS
(
SELECT  StartDate,
        EndDate,
        SUM(CASE WHEN StartDate <= ISNULL(PreviousEndDate, StartDate) THEN 0 ELSE 1 
        END) OVER (ORDER BY StartDate ROWS UNBOUNDED PRECEDING) AS IslandID
FROM cte_Lag
)
SELECT  MIN(StartDate) AS StartDate,
        MAX(EndDate)   AS EndDate
FROM    cte_Islands
GROUP BY IslandID
ORDER BY StartDate;
GO

/*----------------------------------------------------
Puzzle #20 - Price Points
*/----------------------------------------------------

DROP TABLE IF EXISTS #ValidPrices;
GO

CREATE TABLE #ValidPrices
(
ProductID      INTEGER,
UnitPrice      MONEY,
EffectiveDate  DATE
);
GO

INSERT INTO #ValidPrices (ProductID, UnitPrice, EffectiveDate) VALUES
(1001,1.99,'1/01/2018'),
(1001,2.99,'4/15/2018'),
(1001,3.99,'6/8/2018'),
(2002,1.99,'4/17/2018'),
(2002,2.99,'5/19/2018');
GO

--Solution 1
--NOT EXISTS
SELECT  ProductID,
        EffectiveDate,
        COALESCE(UnitPrice,0) AS UnitPrice
FROM    #ValidPrices AS pp
WHERE   NOT EXISTS (SELECT 1
                    FROM   #ValidPrices AS ppl
                    WHERE  ppl.ProductID = pp.ProductID AND
                           ppl.EffectiveDate > pp.EffectiveDate);
GO

--Solution 2
--RANK
WITH cte_ValidPrices AS
(
SELECT  ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY EffectiveDate DESC) AS Rnk,
        ProductID,
        EffectiveDate,
        UnitPrice
FROM    #ValidPrices
)
SELECT  Rnk, ProductID, EffectiveDate, UnitPrice
FROM    cte_ValidPrices
WHERE   Rnk = 1;
GO

--Solution 3
--MAX
WITH cte_MaxEffectiveDate AS
(
SELECT  ProductID,
        MAX(EffectiveDate) AS MaxEffectiveDate
FROM    #ValidPrices
GROUP BY ProductID
)
SELECT  a.*
FROM    #ValidPrices a INNER JOIN
        cte_MaxEffectiveDate b ON a.EffectiveDate = b.MaxEffectiveDate AND a.ProductID = b.ProductID;
GO

/*----------------------------------------------------
Puzzle #21 - Average Monthly Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER,
CustomerID  INTEGER,
OrderDate   DATE,
Amount      MONEY,
[State]     VARCHAR(2)
);
GO

INSERT INTO #Orders (OrderID, CustomerID, OrderDate, Amount, [State]) VALUES
(1,1001,'1/1/2018',100,'TX'),
(2,1001,'1/1/2018',150,'TX'),
(3,1001,'1/1/2018',75,'TX'),
(4,1001,'2/1/2018',100,'TX'),
(5,1001,'3/1/2018',100,'TX'),
(6,2002,'2/1/2018',75,'TX'),
(7,2002,'2/1/2018',150,'TX'),
(8,3003,'1/1/2018',100,'IA'),
(9,3003,'2/1/2018',100,'IA'),
(10,3003,'3/1/2018',100,'IA'),
(11,4004,'4/1/2018',100,'IA'),
(12,4004,'5/1/2018',50,'IA'),
(13,4004,'5/1/2018',100,'IA');
GO

WITH cte_MonthlyAverages AS
(
SELECT  [State],
        CustomerID,
        YEAR(OrderDate)  AS OrderYear,
        MONTH(OrderDate) AS OrderMonth,
        AVG(CAST(Amount AS DECIMAL(10,2))) AS MonthlyAverage
FROM #Orders
GROUP BY [State], CustomerID, YEAR(OrderDate), MONTH(OrderDate)
)
SELECT  [State]
FROM    cte_MonthlyAverages
GROUP BY [State]
HAVING MIN(MonthlyAverage) >= 100;
GO

/*----------------------------------------------------
Puzzle #22 - Occurrences
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow     VARCHAR(100),
LogMessage   VARCHAR(100),
Occurrences  INTEGER
);
GO

INSERT INTO #ProcessLog (Workflow, LogMessage, Occurrences) VALUES
('Alpha','Error: Conversion Failed',5),
('Alpha','Status Complete',8),
('Alpha','Error: Unidentified error occurred',9),
('Bravo','Error: Cannot Divide by 0',3),
('Bravo','Error: Unidentified error occurred',1),
('Charlie','Error: Unidentified error occurred',10),
('Charlie','Error: Conversion Failed',7),
('Charlie','Status Complete',6);
GO

--Solution 1
--Row Number
WITH cte_RankedMessages AS 
(
SELECT  Workflow,
        LogMessage,
        Occurrences,
        ROW_NUMBER() OVER (PARTITION BY LogMessage ORDER BY Occurrences DESC) AS rnk
FROM #ProcessLog
)
SELECT Workflow, LogMessage, Occurrences
FROM   cte_RankedMessages
WHERE rnk = 1
ORDER BY 1
GO

--Solution 2
--MAX
WITH cte_LogMessageCount AS
(
SELECT  LogMessage,
        MAX(Occurrences) AS MaxOccurrences
FROM    #ProcessLog
GROUP BY LogMessage
)
SELECT  a.Workflow,
        a.LogMessage,
        a.Occurrences
FROM    #ProcessLog a INNER JOIN
        cte_LogMessageCount b ON a.LogMessage = b.LogMessage AND
                                 a.Occurrences = b.MaxOccurrences
ORDER BY 1;
GO

--Solution 3
--Correlated Subquery
SELECT Workflow, LogMessage, Occurrences
FROM #ProcessLog p
WHERE Occurrences = (SELECT MAX(Occurrences) FROM #ProcessLog WHERE LogMessage = p.LogMessage)
ORDER BY 1;
GO

--Solution 4
--ALL
--Correlated Subquery
SELECT  WorkFlow,
        LogMessage,
        Occurrences
FROM    #ProcessLog AS e1
WHERE   Occurrences > ALL(SELECT e2.Occurrences
                            FROM #ProcessLog AS e2
                           WHERE e2.LogMessage = e1.LogMessage AND
                                 e2.WorkFlow <> e1.WorkFlow)
ORDER BY 1;
GO

/*----------------------------------------------------
Puzzle #23 - Divide in Half
*/----------------------------------------------------

DROP TABLE IF EXISTS #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
PlayerID  INTEGER,
Score     INTEGER
);
GO

INSERT INTO #PlayerScores (PlayerID, Score) VALUES
(1001,2343),(2002,9432),
(3003,6548),(4004,1054),
(5005,6832);
GO

SELECT  NTILE(2) OVER (ORDER BY Score DESC) AS Quartile,
        PlayerID,
        Score
FROM    #PlayerScores a
ORDER BY Score DESC;
GO

/*----------------------------------------------------
Puzzle #24 - Page Views
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER,
CustomerID  INTEGER,
OrderDate   DATE,
Amount      MONEY,
[State]     VARCHAR(2)
);
GO

INSERT INTO #Orders (OrderID, CustomerID, OrderDate, Amount, [State]) VALUES
(1, 1001, '2018-01-01', 100, 'TX'),
(2, 3003, '2018-01-01', 100, 'IA'),
(3, 1001, '2018-03-01', 100, 'TX'),
(4, 2002, '2018-02-01', 150, 'TX'),
(5, 1001, '2018-02-01', 100, 'TX'),
(6, 4004, '2018-05-01', 50,  'IA'),
(7, 1001, '2018-01-01', 150, 'TX'),
(8, 3003, '2018-03-01', 100, 'IA'),
(9, 4004, '2018-04-01', 100, 'IA'),
(10, 1001, '2018-01-01', 75,  'TX'),
(11, 2002, '2018-02-01', 75,  'TX'),
(12, 3003, '2018-02-01', 100, 'IA'),
(13, 4004, '2018-05-01', 100, 'IA');
GO

--Solution 1
--OFFSET FETCH NEXT
SELECT  OrderID, CustomerID, OrderDate, Amount, [State]
FROM    #Orders
ORDER BY OrderID
OFFSET 4 ROWS FETCH NEXT 6 ROWS ONLY;
GO

--Solution 2
--RowNumber
WITH cte_RowNumber AS
(
SELECT  ROW_NUMBER() OVER (ORDER BY OrderID) AS RowNumber,
        OrderID, CustomerID, OrderDate, Amount, [State]
FROM    #Orders
)
SELECT  OrderID, CustomerID, OrderDate, Amount, [State]
FROM    cte_RowNumber
WHERE   RowNumber BETWEEN 5 AND 10;
GO

/*----------------------------------------------------
Puzzle #25 - Top Vendors
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER,
CustomerID  INTEGER,
[Count]     INTEGER,
Vendor      VARCHAR(100)
);
GO

INSERT INTO #Orders (OrderID, CustomerID, [Count], Vendor)
VALUES
-- Customer 1001
(1,1001,35,'Direct Parts'),
(2,1001,35,'Direct Parts'),
(3,1001,50,'ACME'),

-- Customer 2002
(4,2002,10,'ACME'),
(5,2002,10,'ACME'),
(6,2002,15,'Direct Parts');
GO

WITH cte_VendorTotals AS
(
SELECT  CustomerID,
        Vendor,
        SUM([Count]) AS TotalOrders
FROM    #Orders
GROUP BY CustomerID, Vendor
),
cte_Ranked AS
(
SELECT  CustomerID,
        Vendor,
        TotalOrders,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY TotalOrders DESC ) AS rn
FROM    cte_VendorTotals
)
SELECT  CustomerID,
        Vendor
FROM    cte_Ranked
WHERE   rn = 1;
GO

/*----------------------------------------------------
Puzzle #26 - Previous Year's Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Sales;
GO

CREATE TABLE #Sales
(
[Year]  INTEGER,
Amount  INTEGER
);
GO

INSERT INTO #Sales ([Year], Amount) VALUES
(YEAR(GETDATE()),352645),
(YEAR(DATEADD(YEAR,-1,GETDATE())),165565),
(YEAR(DATEADD(YEAR,-1,GETDATE())),254654),
(YEAR(DATEADD(YEAR,-2,GETDATE())),159521),
(YEAR(DATEADD(YEAR,-2,GETDATE())),251696),
(YEAR(DATEADD(YEAR,-3,GETDATE())),111894);
GO

--Solution 1 (This has hardcoded dates)
--PIVOT
SELECT [2023],[2022],[2021] FROM #Sales
PIVOT (SUM(Amount) FOR [Year] IN ([2023],[2022],[2021])) AS PivotClause;
GO

--Solution 2 (This has hardcoded dates)
--LAG
WITH cte_AggregateTotal AS
(
SELECT  [Year],
        SUM(Amount) AS Amount
FROM    #Sales
GROUP BY [Year]
),
cte_Lag AS
(
SELECT  [Year],
        Amount,
        LAG(Amount,1,0) OVER (ORDER BY Year) AS Lag1,
        LAG(Amount,2,0) OVER (ORDER BY Year) AS Lag2
FROM    cte_AggregateTotal
)
SELECT  Amount AS '2023',
        Lag1 AS '2022',
        Lag2 AS '2021'
FROM    cte_Lag
WHERE   [Year] = 2023;
GO

--Solution 3
--Dynamic SQL without hardcoded dates
BEGIN
    
    DECLARE @CurrentYear VARCHAR(MAX) =
                CAST(YEAR(GETDATE()) AS VARCHAR);
    DECLARE @CurrentYearLag1 VARCHAR(MAX) =
                CAST(YEAR(DATEADD(YEAR,-1,GETDATE())) AS VARCHAR);
    DECLARE @CurrentYearLag2 VARCHAR(MAX) =
                CAST(YEAR(DATEADD(YEAR,-2,GETDATE())) AS VARCHAR);
    DECLARE @DynamicSQL NVARCHAR(MAX);

    SET @DynamicSQL =
    'SELECT [' + @CurrentYear + '],
            [' + @CurrentYearLag1 + '],
            [' + @CurrentYearLag2 + ']
    FROM #Sales 
    PIVOT (SUM(AMOUNT) FOR YEAR IN (
            [' + @CurrentYear + '],
            [' + @CurrentYearLag1 + '],
            [' + @CurrentYearLag2 + '])) AS PivotClause;'

    PRINT @DynamicSQL;
    EXECUTE SP_EXECUTESQL @DynamicSQL;

END;
GO

/*----------------------------------------------------
Puzzle #27 - Delete the Duplicates
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue  INTEGER
);
GO

INSERT INTO #SampleData (IntegerValue) VALUES
(1),(1),(2),(3),(3),(4);
GO

WITH cte_Duplicates AS
(
SELECT  ROW_NUMBER() OVER (PARTITION BY IntegerValue ORDER BY (SELECT NULL)) AS Rn
FROM    #SampleData
)
DELETE FROM cte_Duplicates WHERE Rn > 1
GO

SELECT * FROM #SampleData;
GO

/*----------------------------------------------------
Puzzle #28 - Fill the Gaps
*/----------------------------------------------------

DROP TABLE IF EXISTS #Gaps;
GO

CREATE TABLE #Gaps
(
RowNumber  INTEGER,
TestCase   VARCHAR(100)
);
GO

INSERT INTO #Gaps (RowNumber, TestCase) VALUES
(1,'Alpha'),(2,NULL),(3,NULL),(4,NULL),
(5,'Bravo'),(6,NULL),(7,'Charlie'),(8,NULL),(9,NULL);
GO

--Solution 1
--MAX and COUNT function
WITH cte_Count AS
(
SELECT RowNumber,
       TestCase,
       COUNT(TestCase) OVER (ORDER BY RowNumber) AS DistinctCount
FROM #Gaps
)
SELECT  RowNumber,
        MAX(TestCase) OVER (PARTITION BY DistinctCount) AS TestCase
FROM    cte_Count
ORDER BY RowNumber;
GO

--Solution 2
--MAX function without windowing
SELECT  a.RowNumber,
        (SELECT b.TestCase
        FROM    #Gaps b
        WHERE   b.RowNumber =
                    (SELECT MAX(c.RowNumber)
                       FROM #Gaps c
                      WHERE c.RowNumber <= a.RowNumber 
                        AND c.TestCase IS NOT NULL)) TestCase
FROM #Gaps a;
GO

--Solution 3
--LAG with IGNORE NULLS
WITH cte_Lag AS
(
SELECT  *,
         LAG(TestCase) IGNORE NULLS OVER (ORDER BY RowNumber) AS LagIgnoreNulls
FROM    #Gaps
)
SELECT  RowNumber,
        (CASE WHEN TestCase IS NOT NULL THEN TestCase ELSE LagIgnoreNulls END) AS TestCase
FROM    cte_Lag;
GO

/*----------------------------------------------------
Puzzle #29 - Count the Groupings
*/----------------------------------------------------
DROP TABLE IF EXISTS #Groupings;
GO

CREATE TABLE #Groupings
(
StepNumber  INTEGER,
TestCase    VARCHAR(100),
[Status]    VARCHAR(100)
);
GO

INSERT INTO #Groupings (StepNumber, TestCase, [Status]) VALUES
(1,'Test Case 1','Passed'),
(2,'Test Case 2','Passed'),
(3,'Test Case 3','Passed'),
(4,'Test Case 4','Passed'),
(5,'Test Case 5','Failed'),
(6,'Test Case 6','Failed'),
(7,'Test Case 7','Failed'),
(8,'Test Case 8','Failed'),
(9,'Test Case 9','Failed'),
(10,'Test Case 10','Passed'),
(11,'Test Case 11','Passed'),
(12,'Test Case 12','Passed');
GO

--Solution 1
WITH cte_Groupings AS
(
SELECT  StepNumber,
        [Status],
        StepNumber - ROW_NUMBER() OVER (PARTITION BY [Status] ORDER BY StepNumber) AS Rn
FROM    #Groupings
)
SELECT  MIN(StepNumber) AS MinStepNumber,
        MAX(StepNumber) AS MaxStepNumber,
        [Status],
        COUNT(*) AS ConsecutiveCount,
        MAX(StepNumber) - MIN(StepNumber) + 1 AS ConsecutiveCount_MinMax
FROM    cte_Groupings
GROUP BY Rn,
        [Status]
ORDER BY 1, 2;
GO

--Solution 2
WITH cte_Lag AS
(
SELECT  *,
        LAG([Status]) OVER(ORDER BY StepNumber) AS PreviousStatus
FROM    #Groupings
),
cte_Groupings AS
(
SELECT  *,
        SUM(CASE WHEN PreviousStatus <> [Status] THEN 1 ELSE 0 END) OVER (ORDER BY StepNumber) AS GroupNumber
FROM    cte_Lag
)
SELECT  MIN(StepNumber) AS MinStepNumber,
        MAX(StepNumber) AS MaxStepNumber,
        [Status],
        COUNT(*) AS ConsecutiveCount,
        MAX(StepNumber) - MIN(StepNumber) + 1 AS ConsecutiveCount_MinMax
FROM    cte_Groupings
GROUP BY [Status], GroupNumber;
GO

/*----------------------------------------------------
Puzzle #30 - Select Star
*/----------------------------------------------------

DROP TABLE IF EXISTS #Products;
GO

CREATE TABLE #Products
(
ProductID    INTEGER,
ProductName  VARCHAR(100)
);
GO

--Add the following constraint
ALTER TABLE #Products ADD ComputedColumn AS (0/0);
GO

/*----------------------------------------------------
Puzzle #31 - Second Highest
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue  INTEGER
);
GO

INSERT INTO #SampleData (IntegerValue) VALUES
(3759),(3760),(3761),(3762),(3763);
GO

--Solution 1
--RANK
--This will handle duplicate values
WITH cte_Rank AS
(
SELECT  RANK() OVER (ORDER BY IntegerValue DESC) AS MyRank,
        *
FROM    #SampleData
)
SELECT  IntegerValue
FROM    cte_Rank
WHERE   MyRank = 2;
GO

--Solution 2
--Top 1 and Max
--This will NOT handle duplicate values
SELECT  TOP 1
        IntegerValue
FROM    #SampleData
WHERE   IntegerValue <> (SELECT MAX(IntegerValue) FROM #SampleData)
ORDER BY IntegerValue DESC;
GO

--Solution 3
--Offset and Fetch
--This will NOT handle duplicate values
SELECT  IntegerValue
FROM    #SampleData
ORDER BY IntegerValue DESC
OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY;
GO

--Solution 4
--Top 1 and Top 2
--This will NOT handle duplicate values
SELECT  TOP 1
        IntegerValue
FROM    (
        SELECT  TOP 2 *
        FROM    #SampleData
        ORDER BY IntegerValue DESC
        ) a
ORDER BY IntegerValue ASC;
GO

--Solution 5
--Min and Top 2
--This will NOT handle duplicate values
WITH cte_TopMin AS
(
SELECT  MIN(IntegerValue) AS MinIntegerValue
FROM   (
       SELECT  TOP 2 *
       FROM    #SampleData
       ORDER BY IntegerValue DESC
       ) a
)
SELECT  IntegerValue
FROM    #SampleData
WHERE   IntegerValue IN (SELECT MinIntegerValue FROM cte_TopMin);
GO

--Solution 6
--Correlated Sub-Query
--This will handle duplicate values
SELECT  IntegerValue
FROM    #SampleData a
WHERE   2 = (SELECT COUNT(DISTINCT b.IntegerValue)
             FROM #SampleData b
             WHERE a.IntegerValue <= b.IntegerValue);
GO

--Solution 7
--Top 1 and Lag
--This will NOT handle duplicate values
WITH cte_LeadLag AS
(
SELECT  *,
        LAG(IntegerValue, 1, NULL) OVER (ORDER BY IntegerValue DESC) AS PreviousValue
FROM    #SampleData
)
SELECT  TOP 1
        IntegerValue
FROM    cte_LeadLag
WHERE   PreviousValue IS NOT NULL
ORDER BY IntegerValue DESC;
GO

/*----------------------------------------------------
Puzzle #32 - First and Last
*/----------------------------------------------------

DROP TABLE IF EXISTS #Personal;
GO

CREATE TABLE #Personal
(
SpacemanID      INTEGER,
JobDescription  VARCHAR(100),
MissionCount    INTEGER
);
GO

INSERT INTO #Personal (SpacemanID, JobDescription, MissionCount) VALUES
(1001,'Astrogator',6),(2002,'Astrogator',12),(3003,'Astrogator',17),
(4004,'Geologist',21),(5005,'Geologist',9),(6006,'Geologist',8),
(7007,'Technician',13),(8008,'Technician',2),(9009,'Technician',7);
GO

--Solution 1
--ROW_NUMBER, MAX, CASE
WITH RankedExperience AS 
(
SELECT  JobDescription,
        SpacemanID,
        MissionCount,
        ROW_NUMBER() OVER (PARTITION BY JobDescription ORDER BY MissionCount DESC) AS rn_max,
        ROW_NUMBER() OVER (PARTITION BY JobDescription ORDER BY MissionCount ASC) AS rn_min
FROM #Personal
)
SELECT  JobDescription,
        MAX(CASE WHEN rn_max = 1 THEN SpacemanID END) AS MostExperienced,
        MAX(CASE WHEN rn_min = 1 THEN SpacemanID END) AS LeastExperienced
FROM    RankedExperience
GROUP BY JobDescription;
GO

--Solution 2
--MIN and MAX
WITH cte_MinMax AS
(
SELECT  JobDescription,
        MAX(MissionCount) AS MaxMissionCount,
        MIN(MissionCount) AS MinMissionCount
FROM    #Personal
GROUP BY JobDescription
)
SELECT  a.JobDescription,
        b.SpacemanID AS MostExperienced,
        c.SpacemanID AS LeastExperienced
FROM    cte_MinMax a INNER JOIN
        #Personal b ON a.JobDescription = b.JobDescription AND
                       a.MaxMissionCount = b.MissionCount  INNER JOIN
        #Personal c ON a.JobDescription = c.JobDescription AND
                       a.MinMissionCount = c.MissionCount;
GO

--Solution 3
--Correlated Subquery
SELECT  s.JobDescription,
        -- Most Experienced
        (SELECT  TOP 1 SpacemanID 
         FROM    #Personal 
         WHERE   JobDescription = s.JobDescription 
         ORDER BY MissionCount DESC) AS [Most Experienced],
     
        -- Least Experienced
        (SELECT TOP 1 SpacemanID 
         FROM #Personal 
         WHERE JobDescription = s.JobDescription 
         ORDER BY MissionCount ASC) AS [Least Experienced]
FROM     #Personal s
GROUP BY s.JobDescription;
GO

/*----------------------------------------------------
Puzzle #33 - Deadlines
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
DROP TABLE IF EXISTS #ManufacturingTimes;
GO

CREATE TABLE #Orders
(
OrderID        INTEGER,
Product        VARCHAR(100),
DaysToDeliver  INTEGER
);
GO

CREATE TABLE #ManufacturingTimes
(
Product            VARCHAR(100),
Component          VARCHAR(100),
DaysToManufacture  INTEGER
);
GO

INSERT INTO #Orders (OrderID, Product, DaysToDeliver) VALUES
(1, 'Aurora', 7),
(2, 'Twilight', 3),
(3, 'SunRay', 9);
GO

INSERT INTO #ManufacturingTimes (Product, Component, DaysToManufacture) VALUES
('Aurora', 'Photon Coil', 7),
('Aurora', 'Filament', 2),
('Aurora', 'Shine Capacitor', 3),
('Aurora', 'Glow Sphere', 1),
('Twilight', 'Photon Coil', 7),
('Twilight', 'Filament', 2),
('SunRay', 'Shine Capacitor', 3),
('SunRay', 'Photon Coil', 1);
GO

WITH cte_Max AS
(
SELECT  Product,
        MAX(DaysToManufacture) AS DaysToBuild
FROM    #ManufacturingTimes b
GROUP BY Product
)
SELECT  a.OrderID,
        a.Product,
        b.DaystoBuild,
        a.DaysToDeliver,
        CASE WHEN b.DaystoBuild = DaystoDeliver THEN 'On Schedule'
             WHEN b.DaystoBuild < DaystoDeliver THEN 'Ahead of Schedule'
             WHEN b.DaystoBuild > DaystoDeliver THEN 'Behind Schedule' END AS Schedule  --You can use ELSE here as well
FROM    #Orders a INNER JOIN
        cte_Max b ON a.Product = b.Product;
GO

/*----------------------------------------------------
Puzzle #34
Specific Exclusion
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER,
CustomerID  INTEGER,
Amount      MONEY
);
GO

INSERT INTO #Orders (OrderID, CustomerID, Amount) VALUES
(1,1001,25),(2,1001,50),(3,2002,65),(4,3003,50);
GO

--Solutions 1 and 2 show Morgan's Law.
--Solution 1
--NOT
SELECT  OrderID,
        CustomerID,
        Amount
FROM    #Orders
WHERE   NOT(CustomerID = 1001 AND Amount = 50);
GO

--Solution 2 
--OR
SELECT  OrderID,
        CustomerID,
        Amount
FROM    #Orders
WHERE   CustomerID <> 1001 OR Amount <> 50;
GO

--Solution 3
--EXCEPT
SELECT  OrderID,
        CustomerID,
        Amount
FROM    #Orders
EXCEPT
SELECT  OrderID,
        CustomerID,
        Amount
FROM    #Orders
WHERE   CustomerID = 1001 AND Amount = 50;
GO

/*----------------------------------------------------
Puzzle #35 - International vs Domestic Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
InvoiceID   INTEGER,
SalesRepID  INTEGER,
Amount      MONEY,
SalesType   VARCHAR(100)
);
GO

INSERT INTO #Orders (InvoiceId, SalesRepID, Amount, SalesType) VALUES
(1,1001,13454,'International'),
(2,2002,3434,'International'),
(3,4004,54645,'International'),
(4,5005,234345,'International'),
(5,1001,4564,'Domestic'),
(6,2002,34534,'Domestic'),
(7,3003,345,'Domestic'),
(8,6006,6543,'Domestic');
GO

SELECT  SalesRepID
FROM    #Orders
GROUP BY SalesRepID
HAVING   COUNT(DISTINCT SalesType) = 1;
GO

/*----------------------------------------------------
Puzzle #36 - Traveling Salesman
*/----------------------------------------------------

DROP TABLE IF EXISTS #Routes;
GO

CREATE TABLE #Routes
(
RouteID        INTEGER,
DepartureCity  VARCHAR(30),
ArrivalCity    VARCHAR(30),
Cost           MONEY
);
GO

INSERT INTO #Routes (RouteID, DepartureCity, ArrivalCity, Cost) VALUES
(1,'Austin','Dallas',100),
(2,'Dallas','Memphis',200),
(3,'Memphis','Des Moines',300),
(4,'Dallas','Des Moines',400);
GO

--Solution 1
--Recursion
DROP TABLE IF EXISTS #TravelingSalesman;
GO

WITH cte_Map (Nodes, LastNode, NodeMap, Cost) AS 
(
SELECT  2 AS Nodes,
        ArrivalCity,
        CAST('\' + DepartureCity + '\' + ArrivalCity + '\' AS VARCHAR(MAX)) AS NodeMap,
        Cost
FROM    #Routes
WHERE   DepartureCity = 'Austin'
UNION ALL
SELECT  m.Nodes + 1 AS Nodes,
        r.ArrivalCity AS LastNode,
        CAST(m.NodeMap + r.ArrivalCity + '\' AS VARCHAR(MAX)) AS NodeMap,
        m.Cost + r.Cost AS Cost
FROM    cte_Map AS m INNER JOIN
        #Routes AS r ON r.DepartureCity = m.LastNode
WHERE   m.NodeMap NOT LIKE '\%' + r.ArrivalCity + '%\'
)
SELECT  NodeMap, Cost
INTO    #TravelingSalesman
FROM    cte_Map
OPTION (MAXRECURSION 0);
GO

WITH cte_LeftReplace AS
(
SELECT  LEFT(NodeMap,LEN(NodeMap)-1) AS RoutePath,
        Cost
FROM    #TravelingSalesman
WHERE   RIGHT(NodeMap,11) = 'Des Moines\'
),
cte_RightReplace AS
(
SELECT  SUBSTRING(RoutePath,2,LEN(RoutePath)-1) AS RoutePath,
        Cost
FROM    cte_LeftReplace
)
SELECT  REPLACE(RoutePath,'\', ' -->') AS RoutePath,
        Cost AS TotalCost
FROM    cte_RightReplace;
GO

--Solution 2
--WHILE Loop
DROP TABLE IF EXISTS #RoutesList;
GO

CREATE TABLE #RoutesList
(
InsertDate      DATETIME DEFAULT GETDATE(),
RouteInsertID   INTEGER,
RoutePath       VARCHAR(8000),
TotalCost       MONEY,
LastArrival     VARCHAR(100)
);
GO

INSERT INTO #RoutesList (RouteInsertID, RoutePath, TotalCost, LastArrival)
SELECT  1,
        CONCAT(DepartureCity,',',ArrivalCity),
        Cost,
        ArrivalCity
FROM    #Routes
WHERE   DepartureCity = 'Austin';
GO

DECLARE @vRowCount INTEGER = 1;
DECLARE @vRouteInsertID INTEGER = 2;

WHILE @vRowCount >= 1
BEGIN

     WITH cte_LastArrival AS
     (
     SELECT   RoutePath
             ,TotalCost
             ,REVERSE(SUBSTRING(REVERSE(RoutePath),0,CHARINDEX(',',REVERSE(RoutePath)))) AS LastArrival
     FROM    #RoutesList
     WHERE   LastArrival <> 'Des Moines'
     )
     INSERT INTO #RoutesList (RouteInsertID, RoutePath, TotalCost, LastArrival)
     SELECT  @vRouteInsertID
             ,CONCAT(a.RoutePath,',',b.ArrivalCity)
             ,a.TotalCost + b.Cost
             ,b.ArrivalCity
     FROM    cte_LastArrival a INNER JOIN
             #Routes b ON a.LastArrival = b.DepartureCity AND CHARINDEX(b.ArrivalCity,RoutePath) = 0;

     SET @vRowCount = @@ROWCOUNT;

     DELETE  #RoutesList
     WHERE   RouteInsertID < @vRouteInsertID
             AND LastArrival <> 'Des Moines';

     SET @vRouteInsertID = @vRouteInsertID + 1;
END;
GO

SELECT  REPLACE(RoutePath,',',' --> ') AS RoutePath,
        TotalCost
FROM    #RoutesList
ORDER BY 1;
GO

/*----------------------------------------------------
Puzzle #37 - Group Criteria Keys
*/----------------------------------------------------

DROP TABLE IF EXISTS #GroupCriteria;
GO

CREATE TABLE #GroupCriteria
(
OrderID      INTEGER,
Distributor  VARCHAR(100),
Facility     INTEGER,
[Zone]       VARCHAR(100),
Amount       MONEY
);
GO

INSERT INTO #GroupCriteria (OrderID, Distributor, Facility, [Zone], Amount) VALUES
(1,'ACME',123,'ABC',100),
(2,'ACME',123,'ABC',75),
(3,'Direct Parts',789,'XYZ',150),
(4,'Direct Parts',789,'XYZ',125);
GO

SELECT  DENSE_RANK() OVER (ORDER BY Distributor, Facility, [Zone]) AS CriteriaID,
        OrderID,
        Distributor,
        Facility,
        [Zone],
        Amount
FROM    #GroupCriteria
ORDER BY OrderID;
GO

/*----------------------------------------------------
Puzzle #38 - Reporting Elements
*/----------------------------------------------------

DROP TABLE IF EXISTS #RegionSales;
GO

CREATE TABLE #RegionSales
(
Region       VARCHAR(100),
Distributor  VARCHAR(100),
Sales        INTEGER
);
GO

INSERT INTO #RegionSales (Region, Distributor, Sales) VALUES
('North','ACE',10),
('South','ACE',67),
('East','ACE',54),
('North','ACME',65),
('South','ACME',9),
('East','ACME',1),
('West','ACME',7),
('North','Direct Parts',8),
('South','Direct Parts',7),
('West','Direct Parts',12);
GO

WITH cte_DistinctRegion AS
(
SELECT  DISTINCT Region
FROM    #RegionSales
),
cte_DistinctDistributor AS
(
SELECT  DISTINCT Distributor
FROM    #RegionSales
),
cte_CrossJoin AS
(
SELECT  Region, Distributor
FROM    cte_DistinctRegion a CROSS JOIN
        cte_DistinctDistributor b
)
SELECT  a.Region,
        a.Distributor,
        ISNULL(b.Sales,0) AS Sales
FROM    cte_CrossJoin a LEFT OUTER JOIN
        #RegionSales b ON a.Region = b.Region and a.Distributor = b.Distributor
ORDER BY a.Distributor,
        (CASE a.Region  WHEN 'North' THEN 1
                        WHEN 'South' THEN 2
                        WHEN 'East'  THEN 3
                        WHEN 'West'  THEN 4 END);
GO

/*----------------------------------------------------
Puzzle #39 - Prime Numbers
*/----------------------------------------------------

DROP TABLE IF EXISTS #PrimeNumbers;
GO

CREATE TABLE #PrimeNumbers
(
IntegerValue  INTEGER
);
GO

INSERT INTO #PrimeNumbers (IntegerValue) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);
GO

SELECT  IntegerValue
FROM    #PrimeNumbers p
WHERE   IntegerValue > 1
AND NOT EXISTS (
    SELECT  1
    FROM    #PrimeNumbers d
    WHERE   d.IntegerValue > 1
      AND   d.IntegerValue < p.IntegerValue
      AND   p.IntegerValue % d.IntegerValue = 0);

/*----------------------------------------------------
Puzzle #40 - Sort Order
*/----------------------------------------------------

DROP TABLE IF EXISTS #SortOrder;
GO

CREATE TABLE #SortOrder
(
City  VARCHAR(100)
);
GO

INSERT INTO #SortOrder (City) VALUES
('Atlanta'),('Baltimore'),('Chicago'),('Denver');
GO

SELECT  City
FROM    #SortOrder
ORDER BY (CASE City WHEN 'Atlanta' THEN 2
                    WHEN 'Baltimore' THEN 1
                    WHEN 'Chicago' THEN 4
                    WHEN 'Denver' THEN 1 END);
GO

/*----------------------------------------------------
Puzzle #41 - Associate IDs
*/----------------------------------------------------

DROP TABLE IF EXISTS #Associates;
DROP TABLE IF EXISTS #Associates2;
DROP TABLE IF EXISTS #Associates3;
GO

CREATE TABLE #Associates
(
Associate1  VARCHAR(100),
Associate2  VARCHAR(100)
);
GO

INSERT INTO #Associates (Associate1, Associate2) VALUES
('Anne','Betty'),('Anne','Charles'),('Betty','Dan'),('Charles','Emma'),
('Francis','George'),('George','Harriet');
GO

--Step 1
--Recursion
WITH cte_Recursive AS
(
SELECT  Associate1,
        Associate2
FROM    #Associates
UNION ALL
SELECT  a.Associate1,
        b.Associate2
FROM    #Associates a INNER JOIN
        cte_Recursive b ON a.Associate2 = b.Associate1
)
SELECT  Associate1,
        Associate2
INTO    #Associates2
FROM    cte_Recursive
UNION ALL
SELECT  Associate1,
        Associate1
FROM    #Associates;
GO

--Step 2
SELECT  MIN(Associate1) AS Associate1,
        Associate2
INTO    #Associates3
FROM    #Associates2
GROUP BY Associate2;
GO

--Results
SELECT  DENSE_RANK() OVER (ORDER BY Associate1) AS GroupingNumber,
        Associate2 AS Associate
FROM    #Associates3;
GO

/*----------------------------------------------------
Puzzle #42 - Mutual Friends
*/----------------------------------------------------

DROP TABLE IF EXISTS #Friends;
DROP TABLE IF EXISTS #Edges;
GO

CREATE TABLE #Friends
(
Friend1  VARCHAR(100),
Friend2  VARCHAR(100)
);
GO

INSERT INTO #Friends (Friend1, Friend2) VALUES
('Jason','Mary'),('Mike','Mary'),('Mike','Jason'),
('Susan','Jason'),('John','Mary'),('Susan','Mary');
GO

--Create reciprocals (Edges)
SELECT  Friend1, Friend2
INTO    #Edges
FROM    #Friends
UNION
SELECT  Friend2, Friend1
FROM    #Friends;
GO

WITH cte_MutualFriends AS
(
SELECT  a.Friend1,
        a.Friend2,
        b.Friend2 AS MutualFriend
FROM    #Edges a INNER JOIN
        #Edges b ON a.Friend1 = b.Friend1 INNER JOIN
        #Edges c ON a.Friend2 = c.Friend1
                 AND b.Friend2 = c.Friend2
WHERE   b.Friend2 <> a.Friend1
AND     b.Friend2 <> a.Friend2
),
cte_Count AS
(
SELECT  Friend1,
        Friend2,
        COUNT(*) AS CountMutualFriends
FROM    cte_MutualFriends
GROUP BY Friend1,
         Friend2
)
SELECT  DISTINCT
        CASE WHEN e.Friend1 < e.Friend2 THEN e.Friend1 ELSE e.Friend2 END AS Friend1,
        CASE WHEN e.Friend1 < e.Friend2 THEN e.Friend2 ELSE e.Friend1 END AS Friend2,
        ISNULL(c.CountMutualFriends,0) AS CountMutualFriends
FROM    #Edges e LEFT OUTER JOIN
        cte_Count c ON e.Friend1 = c.Friend1 AND e.Friend2 = c.Friend2
ORDER BY 1,2;
GO

/*----------------------------------------------------
Puzzle #43 - Unbounded Preceding
*/----------------------------------------------------

DROP TABLE IF EXISTS #CustomerOrders;
GO

CREATE TABLE #CustomerOrders
(
OrderID     INTEGER,
CustomerID  INTEGER,
Quantity    INTEGER
);
GO

INSERT INTO #CustomerOrders (OrderID, CustomerID, Quantity) VALUES 
(1,1001,5),(2,1001,8),(3,1001,3),(4,1001,7),
(1,2002,4),(2,2002,9);
GO

SELECT  OrderID,
        CustomerID,
        Quantity,
        MIN(Quantity) OVER (PARTITION by CustomerID ORDER BY OrderID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MinQuantity
FROM    #CustomerOrders
ORDER BY CustomerID, OrderID;
GO

/*----------------------------------------------------
Puzzle #44 - Slowly Changing Dimension Part I
*/----------------------------------------------------

DROP TABLE IF EXISTS #Balances;
GO

CREATE TABLE #Balances
(
CustomerID   INTEGER,
BalanceDate  DATE,
Amount       MONEY
);
GO

INSERT INTO #Balances (CustomerID, BalanceDate, Amount) VALUES
(1001,'10/11/2021',54.32),
(1001,'10/10/2021',17.65),
(1001,'9/18/2021',65.56),
(1001,'9/12/2021',56.23),
(1001,'9/1/2021',42.12),
(2002,'10/15/2021',46.52),
(2002,'10/13/2021',7.65),
(2002,'9/15/2021',75.12),
(2002,'9/10/2021',47.34),
(2002,'9/2/2021',11.11);
GO

WITH cte_Customers AS
(
SELECT  CustomerID,
        BalanceDate,
        LAG(BalanceDate) OVER (PARTITION BY CustomerID ORDER BY BalanceDate DESC) AS EndDate,
        Amount
FROM    #Balances
)
SELECT  CustomerID,
        BalanceDate AS StartDate,
        ISNULL(DATEADD(DAY,-1,EndDate),'12/31/9999') AS EndDate,
        Amount
FROM    cte_Customers
ORDER BY CustomerID, BalanceDate DESC;
GO

/*----------------------------------------------------
Puzzle #45 - Slowly Changing Dimension Part II
*/----------------------------------------------------

DROP TABLE IF EXISTS #Balances;
GO

CREATE TABLE #Balances
(
CustomerID  INTEGER,
StartDate   DATE,
EndDate     DATE,
Amount      MONEY
);
GO

INSERT INTO #Balances (CustomerID, StartDate, EndDate, Amount) VALUES
(1001,'10/11/2021','12/31/9999',54.32),
(1001,'10/10/2021','10/10/2021',17.65),
(1001,'9/18/2021','10/12/2021',65.56),
(2002,'9/12/2021','9/17/2021',56.23),
(2002,'9/1/2021','9/17/2021',42.12),
(2002,'8/15/2021','8/31/2021',16.32);
GO

--Solution 1
--LAG
WITH cte_Lag AS
(
SELECT  CustomerID, StartDate, EndDate, Amount,
        LAG(StartDate) OVER (PARTITION BY CustomerID ORDER BY StartDate DESC) AS StartDate_Lag
FROM    #Balances
)
SELECT  CustomerID, StartDate, EndDate, Amount, StartDate_Lag
FROM    cte_Lag
WHERE   EndDate >= StartDate_Lag
ORDER BY CustomerID, StartDate DESC;
GO

--Solution 2
--Self Join
SELECT DISTINCT
       a.CustomerID,
       a.StartDate,
       a.EndDate,
       a.Amount
FROM   #Balances a INNER JOIN
       #Balances b ON a.CustomerID = b.CustomerID
                  AND a.StartDate < b.StartDate
                  AND a.EndDate >= b.StartDate
ORDER BY CustomerID,
         StartDate;
GO

/*----------------------------------------------------
Puzzle #46 - Negative Account Balances
*/----------------------------------------------------

DROP TABLE IF EXISTS #AccountBalances;
GO

CREATE TABLE #AccountBalances
(
AccountID  INTEGER,
Balance    MONEY
);
GO

INSERT INTO #AccountBalances (AccountID, Balance) VALUES
(1001,234.45),(1001,-23.12),(2002,-93.01),(2002,-120.19),
(3003,186.76), (3003,90.23), (3003,10.11);
GO

--Solution 1
--SET Operators
SELECT DISTINCT AccountID FROM #AccountBalances WHERE Balance < 0
EXCEPT
SELECT DISTINCT AccountID FROM #AccountBalances WHERE Balance > 0;
GO

--Solution 2
--MAX
SELECT  AccountID
FROM    #AccountBalances
GROUP BY AccountID
HAVING  MAX(Balance) <= 0;
GO

--Solution 3
--NOT IN
SELECT  DISTINCT AccountID
FROM    #AccountBalances
WHERE   AccountID NOT IN (SELECT AccountID FROM #AccountBalances WHERE Balance > 0);
GO

--Solution 4
--NOT EXISTS with Correlated Subquery
SELECT  DISTINCT AccountID
FROM    #AccountBalances a
WHERE   NOT EXISTS (SELECT AccountID FROM #AccountBalances b WHERE Balance > 0 AND a.AccountID = b.AccountID);
GO

--Solution 5
--LEFT OUTER JOIN
SELECT  DISTINCT a.AccountID
FROM    #AccountBalances a LEFT OUTER JOIN
        #AccountBalances b ON a.AccountID = b.AccountID AND b.Balance > 0
WHERE   b.AccountID IS NULL;
GO

--Solution 6
--COUNT with CASE
SELECT  AccountID
FROM    #AccountBalances
GROUP BY AccountID
HAVING  COUNT(CASE WHEN Balance > 0 THEN 1 END) = 0;
GO

--Solution 7
--SUM with CASE
SELECT  AccountID
FROM    #AccountBalances
GROUP BY AccountID
HAVING  SUM(CASE WHEN Balance > 0 THEN 1 ELSE 0 END) = 0;
GO

--Solution 8
--ALL Operator
SELECT  DISTINCT AccountID
FROM    #AccountBalances a
WHERE   0 >= ALL
        (
        SELECT  Balance
        FROM    #AccountBalances b
        WHERE   a.AccountID = b.AccountID
        );
GO

--Solution 9
--Window Function
WITH cte_Max AS
(
SELECT  AccountID,
        MAX(Balance) OVER (PARTITION BY AccountID) AS MaxBalance
FROM    #AccountBalances
)
SELECT  DISTINCT AccountID
FROM    cte_Max
WHERE   MaxBalance <= 0;
GO

--Solution 10
--Correlated COUNT
SELECT  DISTINCT AccountID
FROM    #AccountBalances a
WHERE   0 =
        (
        SELECT  COUNT(*)
        FROM    #AccountBalances b
        WHERE   a.AccountID = b.AccountID
        AND     b.Balance > 0
        );
GO

--Solution 11
--HAVING MIN(SIGN())
SELECT  AccountID
FROM    #AccountBalances
GROUP BY AccountID
HAVING  MAX(SIGN(Balance)) <= 0;
GO

--Solution 12
--OUTER APPLY
SELECT  DISTINCT a.AccountID
FROM    #AccountBalances a
OUTER APPLY
(
    SELECT TOP 1 1 AS PositiveBalanceExists
    FROM   #AccountBalances b
    WHERE  a.AccountID = b.AccountID
    AND    b.Balance > 0
) x
WHERE   x.PositiveBalanceExists IS NULL;
GO

/*----------------------------------------------------
Puzzle #47 - Work Schedule
*/----------------------------------------------------

DROP TABLE IF EXISTS #Schedule;
DROP TABLE IF EXISTS #Activity;
DROP TABLE IF EXISTS #ScheduleTimes;
DROP TABLE IF EXISTS #ActivityCoalesce;
GO

CREATE TABLE #Schedule
(
ScheduleId  CHAR(1),
StartTime   DATETIME,
EndTime     DATETIME
);
GO

CREATE TABLE #Activity
(
ScheduleID   CHAR(1) REFERENCES #Schedule (ScheduleID),
ActivityName VARCHAR(100),
StartTime    DATETIME,
EndTime      DATETIME
);
GO

INSERT INTO #Schedule (ScheduleID, StartTime, EndTime) VALUES
('A',CAST('2021-10-01 10:00:00' AS DATETIME),CAST('2021-10-01 15:00:00' AS DATETIME)),
('B',CAST('2021-10-01 10:15:00' AS DATETIME),CAST('2021-10-01 12:15:00' AS DATETIME));
GO

INSERT INTO #Activity (ScheduleID, ActivityName, StartTime, EndTime) VALUES
('A','Meeting',CAST('2021-10-01 10:00:00' AS DATETIME),CAST('2021-10-01 10:30:00' AS DATETIME)),
('A','Break',CAST('2021-10-01 12:00:00' AS DATETIME),CAST('2021-10-01 12:30:00' AS DATETIME)),
('A','Meeting',CAST('2021-10-01 13:00:00' AS DATETIME),CAST('2021-10-01 13:30:00' AS DATETIME)),
('B','Break',CAST('2021-10-01 11:00:00'AS DATETIME),CAST('2021-10-01 11:15:00' AS DATETIME));
GO

WITH cte_TimePoints AS
(
        -- Schedule boundaries
        SELECT  ScheduleID,
                StartTime AS TimePoint
        FROM    #Schedule

        UNION

        SELECT  ScheduleID,
                EndTime
        FROM    #Schedule

        UNION

        -- Activity boundaries
        SELECT  ScheduleID,
                StartTime
        FROM    #Activity

        UNION

        SELECT  ScheduleID,
                EndTime
        FROM    #Activity
),
cte_TimeSlices AS
(
SELECT  ScheduleID,
        TimePoint AS StartTime,
        LEAD(TimePoint) OVER (PARTITION BY ScheduleID ORDER BY TimePoint) AS EndTime
FROM    cte_TimePoints
)
SELECT  t.ScheduleID,
        ISNULL(a.ActivityName,'Work') AS Activity,
        t.StartTime,
        t.EndTime
FROM    cte_TimeSlices t LEFT OUTER JOIN
        #Activity a ON t.ScheduleID = a.ScheduleID
                   AND t.StartTime >= a.StartTime
                   AND t.EndTime <= a.EndTime
WHERE   t.EndTime IS NOT NULL
ORDER BY t.ScheduleID,
         t.StartTime;
GO

/*----------------------------------------------------
Puzzle #48 - Consecutive Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Sales;
GO

CREATE TABLE #Sales
(
SalesID  INTEGER,
[Year]   INTEGER
);
GO

INSERT INTO #Sales (SalesID, [Year]) VALUES
(1001,2018),(1001,2019),(1001,2020),(2002,2020),(2002,2021),
(3003,2018),(3003,2020),(3003,2021),(4004,2019),(4004,2020),(4004,2021);
GO

--Solution 1
--Conditional Aggregation
SELECT  SalesID
FROM    #Sales
GROUP BY SalesID
HAVING  COUNT(DISTINCT CASE WHEN [Year] IN (2021,2020,2019) THEN [Year] END) = 3
   AND  MAX(CASE WHEN [Year] = 2021 THEN 1 ELSE 0 END) = 1;
GO


--Solution 2
--Self Join
SELECT DISTINCT
       a.SalesID
FROM   #Sales a INNER JOIN 
       #Sales b ON a.SalesID = b.SalesID INNER JOIN 
       #Sales c ON a.SalesID = c.SalesID
WHERE  a.[Year] = 2021
AND    b.[Year] = 2020
AND    c.[Year] = 2019;
GO

--Solution 3
--INTERSECT
SELECT SalesID
FROM #Sales
WHERE [Year] = 2021

INTERSECT

SELECT SalesID
FROM #Sales
WHERE [Year] = 2020

INTERSECT

SELECT SalesID
FROM #Sales
WHERE [Year] = 2019;
GO

--Solution 4
--EXISTS

SELECT DISTINCT
       SalesID
FROM   #Sales a
WHERE  EXISTS
       (
           SELECT 1
           FROM #Sales b
           WHERE b.SalesID = a.SalesID
           AND b.[Year] = 2021
       )
AND    EXISTS
       (
           SELECT 1
           FROM #Sales b
           WHERE b.SalesID = a.SalesID
           AND b.[Year] = 2020
       )
AND    EXISTS
       (
           SELECT 1
           FROM #Sales b
           WHERE b.SalesID = a.SalesID
           AND b.[Year] = 2019
       );
GO

--Solution 5
--ROW_NUMBER
WITH cte_Consecutive AS
(
SELECT  SalesID,
        [Year],
        [Year] - ROW_NUMBER() OVER (PARTITION BY SalesID ORDER BY [Year]) AS grp
FROM    #Sales
)
SELECT  SalesID
FROM    cte_Consecutive
GROUP BY SalesID,
         grp
HAVING  COUNT(*) >= 3
AND     MAX([Year]) = 2021;
GO

--Solution 6
DECLARE @CurrentYear INTEGER = 2021;

SELECT  SalesID
FROM    #Sales
WHERE   [Year] BETWEEN @CurrentYear - 2
                   AND @CurrentYear
GROUP BY SalesID
HAVING  MIN([Year]) = @CurrentYear - 2
AND     MAX([Year]) = @CurrentYear
AND     COUNT(DISTINCT [Year]) = 3;
GO

/*----------------------------------------------------
Puzzle #49 - Sumo Wrestlers
*/----------------------------------------------------

DROP TABLE IF EXISTS #ElevatorOrder;
GO

CREATE TABLE #ElevatorOrder
(
LineOrder  INTEGER,
[Name]     VARCHAR(100),
[Weight]   INTEGER
);
GO

INSERT INTO #ElevatorOrder ([Name], [Weight], LineOrder)
VALUES
('Haruto',611,1),('Minato',533,2),('Haruki',623,3),
('Sota',569,4),('Aoto',610,5),('Hinata',525,6);
GO

WITH cte_Running_Total AS
(
SELECT  [Name], [Weight], LineOrder,
        SUM(Weight) OVER (ORDER BY LineOrder ROWS UNBOUNDED PRECEDING) AS Running_Total
FROM    #ElevatorOrder
)
SELECT  TOP 1
        [Name], [Weight], LineOrder, Running_Total
FROM    cte_Running_Total
WHERE   Running_Total <= 2000
ORDER BY Running_Total DESC;
GO

/*----------------------------------------------------
Puzzle #50 - Baseball Balls and Strikes
*/----------------------------------------------------

DROP TABLE IF EXISTS #Pitches;
DROP TABLE IF EXISTS #BallsStrikes;
DROP TABLE IF EXISTS #BallsStrikesSumWidow;
DROP TABLE IF EXISTS #BallsStrikesLag;
GO

CREATE TABLE #Pitches
(
BatterID     INTEGER,
PitchNumber  INTEGER,
Result       VARCHAR(100)
);
GO

INSERT INTO #Pitches (BatterID, PitchNumber, Result) VALUES
(1001,1,'Foul'), (1001,2,'Foul'),(1001,3,'Ball'),(1001,4,'Ball'),(1001,5,'Strike'),
(2002,1,'Ball'),(2002,2,'Strike'),(2002,3,'Foul'),(2002,4,'Foul'),(2002,5,'Foul'),
(2002,6,'In Play'),(3003,1,'Ball'),(3003,2,'Ball'),(3003,3,'Ball'),
(3003,4,'Ball'),(4004,1,'Foul'),(4004,2,'Foul'),(4004,3,'Foul'),
(4004,4,'Foul'),(4004,5,'Foul'),(4004,6,'Strike');
GO

SELECT  BatterID,
        PitchNumber,
        Result,
        (CASE WHEN  Result = 'Ball' THEN 1 ELSE 0 END) AS Ball,
        (CASE WHEN  Result IN ('Foul','Strike') THEN 1 ELSE 0 END) AS Strike
INTO    #BallsStrikes
FROM    #Pitches;
GO

SELECT  BatterID,
        PitchNumber,
        Result,
        SUM(Ball) OVER (PARTITION BY BatterID ORDER BY PitchNumber) AS SumBall,
        SUM(Strike) OVER (PARTITION BY BatterID ORDER BY PitchNumber) AS SumStrike
INTO    #BallsStrikesSumWidow
FROM    #BallsStrikes;
GO

SELECT  BatterID,
        PitchNumber,
        Result,
        SumBall,
        SumStrike,
        LAG(SumBall,1,0) OVER (PARTITION BY BatterID ORDER BY PitchNumber) AS SumBallLag,
        (CASE   WHEN    Result IN ('Foul','In-Play') AND
                        LAG(SumStrike,1,0) OVER (PARTITION BY BatterID ORDER BY PitchNumber) >= 3 THEN 2
                WHEN    Result = 'Strike' AND SumStrike >= 2 THEN 2
                ELSE    LAG(SumStrike,1,0) OVER (PARTITION BY BatterID ORDER BY PitchNumber)
        END) AS SumStrikeLag
INTO    #BallsStrikesLag
FROM    #BallsStrikesSumWidow;
GO

SELECT  BatterID,
        PitchNumber,
        Result,
        CONCAT(SumBallLag, ' - ', SumStrikeLag) AS StartOfPitchCount,
        (CASE WHEN Result = 'In Play' THEN Result
                ELSE CONCAT(SumBall, ' - ', (CASE   WHEN Result = 'Foul' AND SumStrike >= 3 THEN 2
                                                    WHEN Result = 'Strike' AND SumStrike >= 2 THEN 3
                                                    ELSE SumStrike END))
        END) AS EndOfPitchCount
FROM    #BallsStrikesLag
ORDER BY 1,2;
GO

/*----------------------------------------------------
Puzzle #51 - Primary Key Creation
*/----------------------------------------------------

DROP TABLE IF EXISTS #Assembly;
GO

CREATE TABLE #Assembly
(
AssemblyID  INTEGER,
Part        VARCHAR(100)
);
GO

INSERT INTO #Assembly (AssemblyID, Part) VALUES
(1001,'Bolt'),(1001,'Screw'),(2002,'Nut'),
(2002,'Washer'),(3003,'Toggle'),(3003,'Bolt');
GO

SELECT  HASHBYTES('SHA2_512',CONCAT(AssemblyID, Part)) AS ExampleUniqueID1,
        CHECKSUM(CONCAT(AssemblyID, Part)) AS ExampleUniqueID12,
        AssemblyID,
        Part
FROM    #Assembly;
GO

/*----------------------------------------------------
Puzzle #52 - Phone Numbers Table
*/----------------------------------------------------

DROP TABLE IF EXISTS #CustomerInfo;
GO

CREATE TABLE #CustomerInfo
(
CustomerID   INTEGER,
PhoneNumber  VARCHAR(14),
CONSTRAINT ckPhoneNumber CHECK (LEN(PhoneNumber) = 14
                            AND SUBSTRING(PhoneNumber,1,1)= '('
                            AND SUBSTRING(PhoneNumber,5,1)= ')'
                            AND SUBSTRING(PhoneNumber,6,1)= '-'
                            AND SUBSTRING(PhoneNumber,10,1)= '-')
);
GO

INSERT INTO #CustomerInfo (CustomerID, PhoneNumber) VALUES
(1001,'(555)-555-5555'),(2002,'(555)-555-5555'), (3003,'(555)-555-5555');
GO

SELECT  CustomerID, PhoneNumber
FROM    #CustomerInfo;
GO

/*----------------------------------------------------
Puzzle #53 - Spouse IDs
*/----------------------------------------------------

DROP TABLE IF EXISTS #Spouses;
GO

CREATE TABLE #Spouses
(
PrimaryID  VARCHAR(100),
SpouseID   VARCHAR(100)
);
GO

INSERT INTO #Spouses (PrimaryID, SpouseID) VALUES
('Pat','Charlie'),('Jordan','Casey'),
('Ashley','Dee'),('Charlie','Pat'),
('Casey','Jordan'),('Dee','Ashley');
GO

WITH cte_Reciprocals AS
(
SELECT
        (CASE WHEN PrimaryID < SpouseID THEN PrimaryID ELSE SpouseID END) AS ID1,
        (CASE WHEN PrimaryID > SpouseID THEN PrimaryID ELSE SpouseID END) AS ID2,
        PrimaryID,
        SpouseID
FROM    #Spouses
),
cte_DenseRank AS
(
SELECT  DENSE_RANK() OVER (ORDER BY ID1) AS GroupID,
        ID1, ID2, PrimaryID, SpouseID
FROM    cte_Reciprocals
)
SELECT  GroupID,
        b.PrimaryID,
        b.SpouseID
FROM    cte_DenseRank a INNER JOIN
        #Spouses b ON a.PrimaryID = b.PrimaryID AND a.SpouseID = b.SpouseID;
GO

/*----------------------------------------------------
Puzzle #54 - Winning the Lottery
*/----------------------------------------------------

DROP TABLE IF EXISTS #WinningNumbers;
DROP TABLE IF EXISTS #LotteryTickets;
GO

CREATE TABLE #WinningNumbers
(
Number  INTEGER
);
GO

INSERT INTO #WinningNumbers (Number) VALUES
(25),(45),(78);
GO

CREATE TABLE #LotteryTickets
(
TicketID  VARCHAR(3),
Number    INTEGER
);
GO

INSERT INTO #LotteryTickets (TicketID, Number) VALUES
('AAA',25),('AAA',45),('AAA',78),
('BBB',25),('BBB',45),('BBB',98),
('CCC',67),('CCC',86),('CCC',91);
GO

WITH cte_Ticket AS
(
SELECT  TicketID,
        COUNT(*) AS MatchingNumbers
FROM    #LotteryTickets a INNER JOIN
        #WinningNumbers b ON a.Number = b.Number
GROUP BY TicketID
),
cte_Payout AS
(
SELECT  (CASE WHEN MatchingNumbers = (SELECT COUNT(*) FROM #WinningNumbers) THEN 100 ELSE 10 END) AS Payout
FROM    cte_Ticket
)
SELECT  SUM(Payout) AS TotalPayout
FROM    cte_Payout;
GO

/*----------------------------------------------------
Puzzle #55 - Table Audit
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProductsA;
DROP TABLE IF EXISTS #ProductsB;
GO

CREATE TABLE #ProductsA
(
ProductName  VARCHAR(100),
Quantity     INTEGER
);
GO

CREATE TABLE #ProductsB
(
ProductName  VARCHAR(100),
Quantity     INTEGER
);
GO

INSERT INTO #ProductsA (ProductName, Quantity) VALUES
('Widget',7),
('Doodad',9),
('Gizmo',3);
GO

INSERT INTO #ProductsB (ProductName, Quantity) VALUES
('Widget',7),
('Doodad',6),
('Dingbat',9);
GO

--Solution 1
--UNION
WITH cte_FullOuter AS
(
SELECT  a.ProductName AS ProductNameA,
        b.ProductName AS ProductNameB,
        a.Quantity AS QuantityA,
        b.Quantity AS QuantityB
FROM    #ProductsA a FULL OUTER JOIN
        #ProductsB b ON a.ProductName = b.ProductName
)
SELECT  'Matches in both table A and table B' AS [Type],
        ProductNameA
FROM    cte_FullOuter
WHERE   ProductNameA = ProductNameB AND QuantityA = QuantityB
UNION
SELECT  'Product does not exist in table B' AS [Type],
        ProductNameA
FROM    cte_FullOuter
WHERE   ProductNameB IS NULL
UNION
SELECT  'Product does not exist in table A' AS [Type],
        ProductNameB
FROM   cte_FullOuter
WHERE  ProductNameA IS NULL
UNION
SELECT  'Quantities in table A and table B do not match' AS [Type],
        ProductNameA
FROM    cte_FullOuter
WHERE   ProductNameA = ProductNameB AND QuantityA <> QuantityB;
GO

--Solution 2
--CASE statement
SELECT  CASE WHEN a.ProductName IS NOT NULL AND b.ProductName IS NOT NULL AND a.Quantity = b.Quantity
             THEN 'Matches in both table A and table B'
             WHEN a.ProductName IS NULL
             THEN 'Product does not exist in table A'
             WHEN b.ProductName IS NULL
             THEN 'Product does not exist in table B'
             WHEN a.Quantity <> b.Quantity
             THEN 'Quantity in table A and table B do not match'
             END AS [Type],
        COALESCE(a.ProductName,b.ProductName) AS ProductName
FROM    #ProductsA a
FULL OUTER JOIN #ProductsB b ON a.ProductName = b.ProductName
ORDER BY 1;

/*----------------------------------------------------
Puzzle #56 - Numbers Using Recursion
*/----------------------------------------------------

DECLARE @vTotalNumbers INTEGER = 10;

--Solution 1
--SQL Server has GENERATE SERIES begining with version 2022
SELECT value
FROM GENERATE_SERIES(1, 10);

--Solution 2
--Recursion
WITH cte_Number (Number) AS 
(
SELECT  1 AS Number
UNION ALL
SELECT  Number + 1
FROM    cte_Number
WHERE   Number < @vTotalNumbers
)
SELECT  Number
FROM    cte_Number
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level
GO

/*----------------------------------------------------
Puzzle #57 - Find the Spaces
*/----------------------------------------------------

DROP TABLE IF EXISTS #Strings;
GO

CREATE TABLE #Strings
(
QuoteId  INTEGER IDENTITY(1,1) PRIMARY KEY,
String   VARCHAR(100)
);
GO

INSERT INTO #Strings (String) VALUES
('SELECT EmpID FROM Employees;'),('SELECT * FROM Transactions;');
GO


--Solution 1
WITH cte_StringSplit AS
(
SELECT b.Ordinal AS RowNumber,
       a.QuoteId,
       a.String,
       b.[Value] AS Word,
       LEN(b.[Value]) AS WordLength
FROM   #Strings a CROSS APPLY
       STRING_SPLIT(String,' ', 1) b
)
SELECT RowNumber,
       QuoteID,
       String,
       CHARINDEX(Word, String) AS Starts,
       (CHARINDEX(Word, String) + WordLength) - 1 AS Ends,
       Word
FROM   cte_StringSplit;
GO

/*----------------------------------------------------
Puzzle #58 - Add Them Up
*/----------------------------------------------------

DROP TABLE IF EXISTS #Equations;
GO

CREATE TABLE #Equations
(
Equation  VARCHAR(200),
TotalSum  INTEGER
);
GO

INSERT INTO #Equations (Equation) VALUES
('123'),('1+2+3'),('1+2-3'),('1+23'),('1-2+3'),('1-2-3'),('1-23'),('12+3'),('12-3');
GO

--Solution 1
--CURSOR and DYNAMIC SQL
--Use this solution if you have to multiple and divide
DECLARE @vSQLStatement NVARCHAR(1000);
DECLARE c_cursor CURSOR FOR (SELECT Equation FROM #Equations);
DECLARE @vEquation NVARCHAR(1000);
DECLARE @vSum BIGINT;

OPEN c_cursor;

FETCH NEXT FROM c_cursor INTO @vEquation;

WHILE @@FETCH_STATUS = 0
    BEGIN

    SELECT  @vSQLStatement = CONCAT('SELECT @var = ',@vEquation);

    EXECUTE sp_executesql @vSQLStatement, N'@var BIGINT OUTPUT', @var = @vSum OUTPUT;

    UPDATE  #Equations
    SET     TotalSum = @vSum
    WHERE   Equation = @vEquation;

    FETCH NEXT FROM c_cursor INTO @vEquation;
    END

CLOSE c_cursor;
DEALLOCATE c_cursor;

SELECT  Equation, TotalSum
FROM    #Equations
ORDER BY 1;
GO

--Solution 2
--STRING_SPLIT
WITH cte_ReplacePositive AS
(
SELECT  Equation,
        REPLACE(Equation,'+',',') AS EquationReplace
FROM    #Equations
),
cte_ReplaceNegative AS
(
SELECT  Equation,
        REPLACE(EquationReplace,'-',',-') AS EquationReplace
FROM    cte_ReplacePositive
),
cte_StringSplit AS
(
SELECT  a.Equation, CAST([Value] AS INTEGER) AS [Value]
FROM    cte_ReplaceNegative a CROSS APPLY
        STRING_SPLIT(EquationReplace,',')
)
SELECT Equation, SUM([Value]) AS EquationSum
FROM   cte_StringSplit
GROUP BY Equation
ORDER BY 1;
GO

--Solution 3
--XML
WITH cte_Expressions AS
(
SELECT  Equation,
        CAST('<x>' + REPLACE(REPLACE(REPLACE(Equation,'-','</x><x>-'),'+','</x><x>'),'<x></x>','') + '</x>' AS XML) AS XmlData
FROM    #Equations
)
SELECT  Equation AS Permutation,
        (SELECT SUM(CAST(N.value('.','varchar(20)') AS int))
         FROM XmlData.nodes('/x') AS T(N)) AS [Sum]
FROM    cte_Expressions
ORDER BY 1;
GO

/*----------------------------------------------------
Puzzle #59 - Balanced String
*/----------------------------------------------------

DROP TABLE IF EXISTS #BalancedString;
GO

CREATE TABLE #BalancedString
(
RowNumber        INTEGER IDENTITY(1,1) PRIMARY KEY,
ExpectedOutcome  VARCHAR(50),
MatchString      VARCHAR(50),
UpdateString     VARCHAR(50)
);
GO

INSERT INTO #BalancedString (ExpectedOutcome, MatchString) VALUES
('Balanced','( )'),
('Balanced','[]'),
('Balanced','{}'),
('Balanced','( ( { [] } ) )'),
('Balanced','( ) [ ]'),
('Balanced','( { } )'),
('Unbalanced','( { ) }'),
('Unbalanced','( { ) }}}()'),
('Unbalanced','}{()][');
GO

--Remove any spaces
--Populates the column UpdateString that we will manipulate with the below UPDATE statements
UPDATE #BalancedString
SET MatchString = REPLACE(MatchString,' ',''),
    UpdateString = REPLACE(MatchString,' ','');

--Set a Loop Counter
DECLARE @vLoop INTEGER = 1;
WHILE @vLoop <> 0

    --Update the UpdateString column to remove any matching objects
    BEGIN
    ------------------
    UPDATE  #BalancedString
    SET UpdateString = REPLACE(UpdateString,'()','');
    ------------------
    UPDATE  #BalancedString
    SET UpdateString = REPLACE(UpdateString,'[]','');
    -------------------
    UPDATE  #BalancedString
    SET UpdateString = REPLACE(UpdateString,'{}','');
    -------------------

    --Determine if there are any more matching objects to update
    SELECT @vLoop =
           CASE WHEN EXISTS
               (
                SELECT 1
                FROM #BalancedString
                WHERE UpdateString LIKE '%()%'
                   OR UpdateString LIKE '%[]%'
                   OR UpdateString LIKE '%{}%'
               )
               THEN 1 ELSE 0 END;

    -------------------

    END;

--If the UpdateString column is empty, then it is a balanced string 
SELECT  *, CASE WHEN UpdateString = '' THEN 'Balanced' ELSE 'Unbalanced' END AS FinalResult 
FROM    #BalancedString
ORDER BY 1;
GO

/*----------------------------------------------------
Puzzle #60 - Products Without Duplicates
*/----------------------------------------------------

DROP TABLE IF EXISTS #Products;
GO

CREATE TABLE #Products
(
Product      VARCHAR(10),
ProductCode  VARCHAR(2)
);
GO

INSERT INTO #Products (Product, ProductCode) VALUES
('Alpha','01'),
('Alpha','02'),
('Bravo','03'),
('Charlie','02');
GO

SELECT ProductCode
FROM   #Products
GROUP BY ProductCode
HAVING COUNT(DISTINCT Product) = 1
ORDER BY 1;
GO

/*----------------------------------------------------
Puzzle #61 - Player Scores
*/----------------------------------------------------

DROP TABLE IF EXISTS #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
AttemptID  INTEGER,
PlayerID   INTEGER,
Score      INTEGER
);
GO

INSERT INTO #PlayerScores (AttemptID, PlayerID, Score) VALUES
(1,1001,2),(2,1001,7),(3,1001,8),(1,2002,6),(2,2002,9),(3,2002,7);
GO

WITH cte_FirstLastValues AS
(
SELECT  *
        ,FIRST_VALUE(Score) OVER (PARTITION BY PlayerID ORDER BY AttemptID) AS FirstValue
        ,LAST_VALUE(Score) OVER  (PARTITION BY PlayerID ORDER BY AttemptID ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LastValue
        ,LAG(Score,1,99999999) OVER (PARTITION BY PlayerID ORDER BY AttemptID) AS LagScore
        ,CASE WHEN Score - LAG(Score,1,0) OVER (PARTITION BY PlayerID ORDER BY AttemptID) > 0 THEN 1 ELSE 0 END AS IsImproved
FROM    #PlayerScores
)
SELECT  AttemptID
       ,PlayerID
       ,Score
       ,Score - FirstValue AS Difference_First
       ,Score - LastValue AS Difference_Last
       ,IsImproved AS IsPreviousScoreLower
       ,MIN(IsImproved) OVER (PARTITION BY PlayerID) AS IsOverallImproved
FROM   cte_FirstLastValues
ORDER BY 1;
GO

/*----------------------------------------------------
Puzzle #62 - Car and Boat Purchase
*/----------------------------------------------------

DROP TABLE IF EXISTS #Vehicles;
GO

CREATE TABLE #Vehicles (
VehicleID  INTEGER,
[Type]     VARCHAR(20),
Model      VARCHAR(20),
Price      MONEY
);
GO

INSERT INTO #Vehicles (VehicleID, [Type], Model, Price) VALUES
(1, 'Car','Rolls-Royce Phantom', 460000),
(2, 'Car','Cadillac CT5', 39000),
(3, 'Car','Porsche Boxster', 63000),
(4, 'Car','Lamborghini Spyder', 290000),
(5, 'Boat','Malibu', 210000),
(6, 'Boat', 'ATX 22-S', 85000),
(7, 'Boat', 'Sea Ray SLX', 520000),
(8, 'Boat', 'Mastercraft', 25000);
GO

SELECT  a.Model AS Car,
        b.Model AS Boat
FROM    #Vehicles a CROSS JOIN
        #Vehicles B
WHERE   a.Type = 'Car' AND
        b.Type = 'Boat' AND
        a.Price > b.Price + 200000
ORDER BY 1,2;
GO

/*----------------------------------------------------
Puzzle #63 - Promotion Codes
*/----------------------------------------------------

DROP TABLE IF EXISTS #Promotions;
GO

CREATE TABLE #Promotions (
OrderID   INTEGER,
Product   VARCHAR(255),
Discount  VARCHAR(255)
);
GO

INSERT INTO #Promotions (OrderID, Product, Discount) VALUES 
(1, 'Item1', 'PROMO'),
(1, 'Item1', 'PROMO'),
(1, 'Item1', 'MARKDOWN'),
(1, 'Item2', 'PROMO'),
(2, 'Item2', NULL),
(2, 'Item3', 'MARKDOWN'),
(2, 'Item3', NULL),
(3, 'Item1', 'PROMO'),
(3, 'Item1', 'PROMO'),
(3, 'Item1', 'PROMO'),
(4, 'Item1', 'PROMO'),
(4, 'Item1', 'MARKDOWN');
GO

--Solution 1
--HAVING
SELECT  OrderID
FROM    #Promotions
GROUP BY OrderID
HAVING  COUNT(DISTINCT Product) = 1
AND     SUM(CASE WHEN Discount = 'PROMO' THEN 1 ELSE 0 END) > 0
AND     SUM(CASE WHEN Discount <> 'PROMO'
                  OR Discount IS NULL
                 THEN 1 ELSE 0 END) = 0;
GO

--Solution 2
--Correlated Subquery
SELECT  DISTINCT a.OrderID
FROM    #Promotions a
WHERE   NOT EXISTS
(
    SELECT 1
    FROM #Promotions b
    WHERE b.OrderID = a.OrderID AND 
          (b.Discount <> 'PROMO' OR b.Discount IS NULL)
)
GROUP BY a.OrderID
HAVING COUNT(DISTINCT Product) = 1
ORDER BY 1;
GO

/*----------------------------------------------------
Puzzle #64 - Between Quotes
*/----------------------------------------------------

DROP TABLE IF EXISTS #Strings;
GO

CREATE TABLE #Strings
(
ID      INTEGER IDENTITY(1,1) PRIMARY KEY,
String  VARCHAR(256)
);
GO

INSERT INTO #Strings (String) VALUES
('"12345678901234"'),
('1"2345678901234"'),
('123"45678"901234"'),
('123"45678901234"'),
('12345678901"234"'),
('12345678901234');
GO

WITH cte_CharIndex AS
(
SELECT  ID,
        String,
        LEN(String) - LEN(REPLACE(String,'"','')) AS QuoteCount,
        CASE WHEN LEN(String) - LEN(REPLACE(String,'"','')) = 2
             THEN CHARINDEX('"',String, CHARINDEX('"',String) + 1) - CHARINDEX('"',String) - 1
             END AS CharactersBetweenQuotes
FROM #Strings
)
SELECT  ID,
        String,
        CASE WHEN QuoteCount <> 2 THEN 'Error'
             WHEN CharactersBetweenQuotes > 10 THEN 'True'
             ELSE 'False' END AS Result
FROM cte_CharIndex
ORDER BY ID;
GO

/*----------------------------------------------------
Puzzle #65 - Home Listings
*/----------------------------------------------------

DROP TABLE IF EXISTS #HomeListings;
GO

CREATE TABLE #HomeListings
(
ListingID  INTEGER,
HomeID     VARCHAR(100),
[Status]   VARCHAR(100)
);
GO

INSERT INTO #HomeListings (ListingID, HomeID, [Status]) VALUES 
(1, 'Home A', 'New Listing'),
(2, 'Home A', 'Pending'),
(3, 'Home A', 'Relisted'),
(4, 'Home B', 'New Listing'),
(5, 'Home B', 'Under Contract'),
(6, 'Home B', 'Relisted'),
(7, 'Home C', 'New Listing'),
(8, 'Home C', 'Under Contract'),
(9, 'Home C', 'Closed');
GO

--Solution 1
--SUM
WITH cte_Case AS
(
SELECT  *,
        (CASE WHEN Status IN ('New Listing', 'Relisted') THEN 1 ELSE 0 END) AS IsNewOrRelisted
FROM    #HomeListings
)
SELECT  ListingID, HomeID, Status,
        SUM(IsNewOrRelisted) OVER (ORDER BY ListingID ROWS UNBOUNDED PRECEDING) AS GroupingID
FROM    cte_Case
ORDER BY ListingID;
GO

--Solution 2
--SUM with Window
WITH cte_Groupings AS
(
SELECT  ListingID,
        HomeID,
        [Status],
        SUM(CASE WHEN [Status] IN ('New Listing', 'Relisted') THEN 1 ELSE 0 END) OVER (ORDER BY ListingID ROWS UNBOUNDED PRECEDING) AS GroupingID
FROM    #HomeListings
)
SELECT  ListingID,
        HomeID,
        [Status],
        GroupingID
FROM    cte_Groupings
ORDER BY ListingID;
GO

/*----------------------------------------------------
Puzzle #66 - Matching Parts
*/----------------------------------------------------

DROP TABLE IF EXISTS #Parts;
GO

CREATE TABLE #Parts
(
SerialNumber    VARCHAR(100),
ManufactureDay  INTEGER,
Product         VARCHAR(100)
);
GO

INSERT INTO #Parts (SerialNumber, ManufactureDay, Product) VALUES
('A111', 1, 'Bolt'),
('B111', 3, 'Bolt'),
('C111', 5, 'Bolt'),
('D222', 2, 'Washer'),
('E222', 4, 'Washer'),
('F222', 6, 'Washer'),
('G333', 3, 'Nut'),
('H333', 5, 'Nut'),
('I333', 7, 'Nut');
GO

--Solution 1
--ROW_NUMBER
WITH cte_RowNumber AS
(
SELECT  ROW_NUMBER() OVER (PARTITION BY Product ORDER BY ManufactureDay) AS RowNumber,
        *
FROM    #Parts
)
SELECT  a.SerialNumber AS Bolt,
        b.SerialNumber AS Washer,
        c.SerialNumber AS Nut
FROM    (SELECT * FROM cte_RowNumber WHERE Product = 'Bolt') a INNER JOIN
        (SELECT * FROM cte_RowNumber WHERE Product = 'Washer') b ON a.RowNumber = b.RowNumber INNER JOIN
        (SELECT * FROM cte_RowNumber WHERE Product = 'Nut') c ON a.RowNumber = c.RowNumber
ORDER BY a.SerialNumber;
GO

--Solution 2
--ROW_NUMBER with MAX
WITH cte_RowNumber AS
(
SELECT  SerialNumber,
        Product,
        ROW_NUMBER() OVER (PARTITION BY Product ORDER BY ManufactureDay) AS RN
FROM    #Parts
)
SELECT  MAX(CASE WHEN Product = 'Bolt'   THEN SerialNumber END) AS Bolt,
        MAX(CASE WHEN Product = 'Washer' THEN SerialNumber END) AS Washer,
        MAX(CASE WHEN Product = 'Nut'    THEN SerialNumber END) AS Nut
FROM    cte_RowNumber
GROUP BY RN
ORDER BY RN;
GO

--Solution 3
--PIVOT
WITH cte_RowNumber AS
(
SELECT  SerialNumber,
        Product,
        ROW_NUMBER() OVER (PARTITION BY Product ORDER BY ManufactureDay) AS RN
FROM    #Parts
)
SELECT  Bolt,
        Washer,
        Nut
FROM    (SELECT RN,
                Product,
                SerialNumber
         FROM cte_RowNumber
) a
PIVOT (MAX(SerialNumber) FOR Product IN ([Bolt],[Washer],[Nut])) p
ORDER BY RN;
GO

/*----------------------------------------------------
Puzzle #67 - Matching Birthdays
*/----------------------------------------------------

DROP TABLE IF EXISTS #Students;
GO

CREATE TABLE #Students
(
StudentName  VARCHAR(50),
Birthday     DATE
);
GO

INSERT INTO #Students (StudentName, Birthday) VALUES
('Susan', '2015-04-15'),
('Tim', '2015-04-15'),
('Jacob', '2015-04-15'),
('Earl', '2015-02-05'),
('Mike', '2015-05-23'),
('Angie', '2015-05-23'),
('Jenny', '2015-11-19'),
('Michelle', '2015-12-12'),
('Aaron', '2015-12-18');
GO

--Solution 1
--STRING_AGG
SELECT  Birthday, STRING_AGG(StudentName, ', ') WITHIN GROUP (ORDER BY StudentName) AS Students
FROM    #Students
GROUP BY Birthday
HAVING  COUNT(*) > 1
ORDER BY BirthDay;
GO

--Solution 2
--XML Path
SELECT  a.Birthday,
        STUFF
        (
            (
                SELECT ', ' + b.StudentName
                FROM #Students b
                WHERE a.Birthday = b.Birthday
                ORDER BY b.StudentName
                FOR XML PATH(''), TYPE
            ).value('.','varchar(max)')
            ,1,2,''
        ) AS Students
FROM    #Students a
GROUP BY a.Birthday
HAVING  COUNT(*) > 1
ORDER BY a.Birthday;
GO

/*----------------------------------------------------
Puzzle #68 - Removing Outliers
*/----------------------------------------------------

DROP TABLE IF EXISTS #Teams;
GO

CREATE TABLE #Teams (
Team    VARCHAR(50),
[Year]  INTEGER,
Score   INTEGER
);
GO

INSERT INTO #Teams (Team, [Year], Score) VALUES 
('Cougars', 2015, 50),
('Cougars', 2016, 45),
('Cougars', 2017, 65),
('Cougars', 2018, 92),
('Bulldogs', 2015, 65),
('Bulldogs', 2016, 60),
('Bulldogs', 2017, 58),
('Bulldogs', 2018, 12);
GO

WITH
cte_SummaryStatistics AS
(
SELECT  AVG(Score) OVER (PARTITION BY Team) AS AverageScore
       ,a.*
FROM   #Teams a
),
cte_RowNumber AS
(
SELECT  ROW_NUMBER() OVER (PARTITION BY Team ORDER BY ABS(Score - AverageScore) DESC, Score DESC) AS RowNumber,
        *
FROM    cte_SummaryStatistics
)
SELECT Team, CAST(AVG(Score) AS INT) AS Score
FROM   cte_RowNumber
WHERE  RowNumber <> 1
GROUP BY Team;
GO

/*----------------------------------------------------
Puzzle #69 - Splitting a Hierarchy
*/----------------------------------------------------

DROP TABLE IF EXISTS #OrganizationChart;
GO

CREATE TABLE #OrganizationChart
(
ManagerID   CHAR(1),
EmployeeID  CHAR(1)
);
GO

INSERT INTO #OrganizationChart (ManagerID, EmployeeID) VALUES
(NULL, 'A'),
('A', 'B'),
('A', 'C'),
('B', 'D'),
('B', 'E'),
('D', 'G'),
('C', 'F');
GO

DROP TABLE IF EXISTS #OrganizationChartSummary;
GO

CREATE TABLE #OrganizationChartSummary
(
Summary  VARCHAR(5000)
);
GO


--This solution uses a WHILE loop.  Recursion can also be used.

--Seed the table
INSERT INTO #OrganizationChartSummary (Summary)
SELECT  EmployeeID
FROM    #OrganizationChart 
WHERE   ManagerID IS NULL;
GO

WHILE @@RowCount >= 1
BEGIN
    INSERT INTO #OrganizationChartSummary (Summary)
    SELECT  CONCAT(a.Summary, ' / ', b.EmployeeID)
    FROM    #OrganizationChartSummary a INNER JOIN
            #OrganizationChart b ON RIGHT(a.Summary,1) = b.ManagerID 
    WHERE   CONCAT(a.Summary, ' / ', b.EmployeeID) NOT IN (SELECT Summary FROM #OrganizationChartSummary);
    END;
GO

WITH cte_GroupID AS
(
SELECT  ROW_NUMBER() OVER (ORDER BY Summary) AS GroupID,
        *
FROM    #OrganizationChartSummary
WHERE   LEN(Summary) = LEN(REPLACE(Summary,'/','')) + 1 AND
        LEN(Summary) > 1
),
cte_Like AS
(
SELECT  a.GroupID, b.*
FROM    cte_GroupID a INNER JOIN
        #OrganizationChartSummary b ON b.Summary LIKE a.Summary + ' / %'
)
SELECT  DISTINCT
        a.GroupID,
        TRIM(b.value) AS EmployeeID
FROM    cte_Like a
        CROSS APPLY STRING_SPLIT(a.Summary, '/') b
ORDER BY 1,2;
GO

/*----------------------------------------------------
Puzzle #70 - Student Facts
*/----------------------------------------------------

DROP TABLE IF EXISTS #Students;
GO

CREATE TABLE #Students
(
ParentID  INTEGER,
ChildID   CHAR(1),
Age       INTEGER,
Gender    CHAR(1)
);
GO

INSERT INTO #Students (ParentID, ChildID, Age, Gender)
VALUES 
    (1001, 'A', 8, 'M'),
    (1001, 'B', 12, 'F'),
    (2002, 'C', 7, 'F'),
    (2002, 'D', 9, 'F'),
    (2002, 'E', 14, 'M'),
    (3003, 'F', 12, 'F'),
    (3003, 'G', 14, 'M'),
    (4004, 'H', 7, 'M');
GO

WITH cte_LagAgeGap AS
(
SELECT  ParentID,
        AGE - LAG(AGE,1) OVER (PARTITION BY ParentID ORDER BY AGE) AS AgeDifference
FROM    #Students
GROUP BY ParentID, Age
),
cte_MaxAgeGap AS
(
SELECT  ParentID,
        MAX(AgeDifference) AS MaxAgeDifference
FROM    cte_LagAgeGap
GROUP BY ParentID
HAVING COUNT(*) >= 2
)
SELECT  a.ParentID,
        COUNT(*) AS NumberChildren,
        AVG(CAST(a.Age AS FLOAT)) AS AverageAge,
        ISNULL(CASE WHEN COUNT(*) = 1 THEN NULL ELSE MAX(a.Age) - MIN(Age) END,0) AS AgeDifference,
        ISNULL(b.MaxAgeDifference,0) AS MaxAgeDifference,
        MIN(a.Age) AS YoungestAge,
        MAX(a.Age) AS OldestAge,
        STRING_AGG(a.Gender, ', ') WITHIN GROUP (ORDER BY ChildID) AS Genders
FROM    #Students a LEFT OUTER JOIN
        cte_MaxAgeGap b ON a.ParentID = b.ParentID
GROUP BY a.ParentID, b.MaxAgeDifference
ORDER BY a.ParentID;
GO

/*----------------------------------------------------
Puzzle #71 - Employee Validation
*/----------------------------------------------------

--Note this puzzle uses permanant tables
--Setting the database to use "test" to avoid possible issues

--USE test;
GO

DROP TABLE IF EXISTS TemporaryEmployees;
DROP TABLE IF EXISTS PermanentEmployees;
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE TemporaryEmployees
(
EmployeeID  INTEGER PRIMARY KEY,
Department  VARCHAR(50)
);
GO

CREATE TABLE PermanentEmployees
(
EmployeeID  INTEGER PRIMARY KEY,
Department  VARCHAR(50)
);
GO

CREATE TABLE Employees
(
EmployeeID  INTEGER PRIMARY KEY,
[Name]      VARCHAR(50)
);
GO

INSERT INTO TemporaryEmployees (EmployeeID, Department) VALUES
(1001, 'Engineering'),
(2002, 'Sales'),
(3003, 'Marketing');
GO

INSERT INTO PermanentEmployees (EmployeeID, Department) VALUES
(4004, 'Marketing'),
(5005, 'Accounting'),
(6006, 'Accounting');
GO

INSERT INTO Employees (EmployeeID, [Name]) VALUES
(1001, 'John'),
(2002, 'Eric'),
(3003, 'Jennifer'),
(4004, 'Bob'),
(5005, 'Stuart'),
(6006, 'Angie');
GO

CREATE TRIGGER trg_CheckPermanentBeforeInsertOnTemporary
ON TemporaryEmployees
AFTER INSERT
AS
BEGIN
    -- Check if the inserted Employee ID exists in PermanentEmployees
    IF EXISTS (SELECT 1 FROM PermanentEmployees WHERE EmployeeID IN (SELECT EmployeeID FROM inserted))
    BEGIN
        RAISERROR ('Employee ID already exists in PermanentEmployees.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TRIGGER trg_CheckTemporaryBeforeInsertOnPermanant
ON PermanentEmployees
AFTER INSERT
AS
BEGIN
    -- Check if the inserted Employee ID exists in TemporaryEmployees
    IF EXISTS (SELECT 1 FROM TemporaryEmployees WHERE EmployeeID IN (SELECT EmployeeID FROM inserted))
    BEGIN
        RAISERROR ('Employee ID already exists in TemporaryEmployees.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

ALTER TABLE PermanentEmployees
ADD CONSTRAINT FK_PermanentEmployees
FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID);
GO

ALTER TABLE TemporaryEmployees
ADD CONSTRAINT FK_TemporaryEmployees
FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID);
GO

--The following statements will successfully fail.

/*
INSERT INTO TemporaryEmployees (EmployeeID, Department) VALUES (4004,'Marketing');
GO
INSERT INTO PermanentEmployees (EmployeeID, Department)VALUES (1001,'Engineering');
GO
INSERT INTO TemporaryEmployees (EmployeeID, Department) VALUES (7007,'Sales');
GO
INSERT INTO PermanentEmployees (EmployeeID, Department) VALUES (7007,'Sales');
GO
*/

/*----------------------------------------------------
Puzzle #72 - Under Warranty
*/----------------------------------------------------

DROP TABLE IF EXISTS #Repairs;
GO

CREATE TABLE #Repairs (
RepairID    INTEGER,
CustomerID  CHAR(1),
RepairDate  DATE
);
GO

INSERT INTO #Repairs (RepairID, CustomerID, RepairDate) VALUES
(1001,'A','2023-01-01'),
(2002,'A','2023-01-15'),
(3003,'A','2023-01-17'),
(4004,'A','2023-03-24'),
(5005,'A','2023-04-01'),
(6006,'B','2023-06-22'),
(7007,'B','2023-06-23'),
(8008,'B','2023-09-01');
GO


WITH cte_Lag AS
(
SELECT  CustomerID,
        RepairID,
        RepairDate,
        LAG(RepairID) OVER (PARTITION BY CustomerID ORDER BY RepairDate) AS PreviousRepairID,
        LAG(RepairDate) OVER (PARTITION BY CustomerID ORDER BY RepairDate) AS PreviousRepairDate
FROM    #Repairs
),
cte_Groups AS
(
SELECT  *,
        DATEDIFF(DAY, PreviousRepairDate, RepairDate) AS RepairGapDays,
        SUM(CASE WHEN PreviousRepairDate IS NULL OR DATEDIFF(DAY, PreviousRepairDate, RepairDate) > 30 THEN 1 ELSE 0 END) 
            OVER (PARTITION BY CustomerID ORDER BY RepairDate ROWS UNBOUNDED PRECEDING) AS GroupID
FROM    cte_Lag
)
SELECT  CustomerID,
        RepairID,
        PreviousRepairID,
        RepairDate,
        PreviousRepairDate,
        ROW_NUMBER() OVER (PARTITION BY CustomerID, GroupID ORDER BY RepairDate) AS SequenceNumber,
        RepairGapDays
FROM    cte_Groups
WHERE   RepairGapDays <= 30
ORDER BY CustomerID, RepairDate;
GO

/*----------------------------------------------------
Puzzle #73 - Distinct Statuses
*/----------------------------------------------------
DROP TABLE IF EXISTS #WorkflowSteps;
GO

CREATE TABLE #WorkflowSteps
(
StepID    INTEGER,
Workflow  VARCHAR(50),
[Status]  VARCHAR(50)
);
GO

INSERT INTO #WorkflowSteps (StepID, Workflow, [Status]) VALUES
(1, 'Alpha', 'Open'),
(2, 'Alpha', 'Open'),
(3, 'Alpha', 'Inactive'),
(4, 'Alpha', 'Open'),
(5, 'Bravo', 'Closed'),
(6, 'Bravo', 'Closed'),
(7, 'Bravo', 'Open'),
(8, 'Bravo', 'Inactive');
GO

--Solution 1
--COUNT DISTINCT
SELECT  a.StepID,
        a.Workflow,
        a.[Status],
        COUNT(DISTINCT b.[Status]) AS [Count]
FROM    #WorkflowSteps a INNER JOIN
        #WorkflowSteps b ON a.StepID >= b.StepID AND a.Workflow = b.Workflow
GROUP BY a.StepID, a.Workflow, a.[Status]
ORDER BY a.StepID;
GO

--Solution 2
--Windowing
WITH cte_FirstOccurrence AS
(
SELECT  StepID,
        Workflow,
        Status,
        CASE WHEN ROW_NUMBER() OVER (PARTITION BY Workflow, Status ORDER BY StepID) = 1
             THEN 1 ELSE 0 END AS IsFirstOccurrence
FROM    #WorkflowSteps
)
SELECT  StepID,
        Workflow,
        Status,
        SUM(IsFirstOccurrence) OVER (PARTITION BY Workflow ORDER BY StepID ROWS UNBOUNDED PRECEDING) AS [Count]
FROM    cte_FirstOccurrence
ORDER BY StepID;
GO

/*----------------------------------------------------
Puzzle #74 - Bowling League
*/----------------------------------------------------
DROP TABLE IF EXISTS #BowlingResults;
GO

CREATE TABLE #BowlingResults 
(
GameID  INTEGER,
Bowler  VARCHAR(50),
Score   INTEGER
);
GO

INSERT INTO #BowlingResults (GameID, Bowler, Score) VALUES
(1, 'John', 167),
(1, 'Susan', 139),
(1, 'Ralph', 95),
(1, 'Mary', 90),
(2, 'Susan', 187),
(2, 'John', 155),
(2, 'Dennis', 100),
(2, 'Anthony', 78);
GO

WITH cte_Lead AS
(
SELECT  *,
        LEAD(Bowler) OVER (PARTITION BY GameID ORDER BY Score DESC) AS LeadBowler
FROM    #BowlingResults
)
SELECT  LEAST(Bowler,LeadBowler) AS Bowler1,
        GREATEST(Bowler,LeadBowler) AS Bowler2,
        COUNT(*) AS [Count]
FROM    cte_Lead
WHERE   LeadBowler IS NOT NULL
GROUP BY LEAST(Bowler,LeadBowler),
         GREATEST(Bowler,LeadBowler)
ORDER BY [Count] DESC;
GO

/*----------------------------------------------------
Puzzle #75 - Symmetric Matches
*/----------------------------------------------------
DROP TABLE IF EXISTS #Boxes;
GO

CREATE TABLE #Boxes 
(
Box      CHAR(1),
[Length] INTEGER,
Width    INTEGER,
Height   INTEGER
);
GO

INSERT INTO #Boxes (Box, [Length], Width, Height) VALUES
('A', 10, 25, 15),
('B', 15, 10, 25),
('C', 10, 16, 24);
GO

WITH cte_LeastGreatest AS
(
SELECT  Box,
        LEAST(Length, Width, Height) AS Dim1,
        Length + Width + Height
            - LEAST(Length, Width, Height)
            - GREATEST(Length, Width, Height) AS Dim2,
        GREATEST(Length, Width, Height) AS Dim3
FROM    #Boxes
)
SELECT  Box,
        DENSE_RANK() OVER
        (
            ORDER BY Dim1, Dim2, Dim3
        ) AS GroupingID
FROM    cte_LeastGreatest
ORDER BY GroupingID, Box;
GO

/*----------------------------------------------------
Puzzle #76 - Determine Batches
*/----------------------------------------------------
DROP TABLE IF EXISTS #BatchStarts;
DROP TABLE IF EXISTS #BatchLines;
GO

CREATE TABLE #BatchStarts
(
Batch       CHAR(1),
BatchStart  INTEGER
);
GO

CREATE TABLE #BatchLines
(
Batch   CHAR(1),
Line    INTEGER,
Syntax  VARCHAR(MAX)
);
GO

INSERT INTO #BatchStarts (Batch, BatchStart) VALUES
('A', 1),
('A', 5);
GO

INSERT INTO #BatchLines (Batch, Line, Syntax) VALUES
('A', 1, 'SELECT *'),
('A', 2, 'FROM Account;'),
('A', 3, 'GO'),
('A', 4, ''),
('A', 5, 'TRUNCATE TABLE Accounts;'),
('A', 6, 'GO');
GO

--Solution 1
--CTE with MIN
WITH cte_BatchLines_Go AS
(
SELECT  *
FROM    #BatchLines
WHERE   Syntax = 'GO'
)
SELECT  a.Batch, a.BatchStart, MIN(b.Line) AS MinLine
FROM    #BatchStarts a LEFT JOIN
        cte_BatchLines_Go b ON b.Line >= a.BatchStart AND a.Batch = b.Batch
GROUP BY a.Batch, a.BatchStart
ORDER BY Batch, BatchStart;
GO

--Solution 2
--Correlated Subquery
SELECT  a.*,
        b.MinLine
FROM    #BatchStarts a CROSS APPLY
        (SELECT  MIN(Line) AS MinLine
         FROM    #BatchLines b
         WHERE   b.Line >= a.BatchStart AND Syntax = 'GO' AND a.Batch = b.Batch) b
ORDER BY Batch, BatchStart;
GO

--Solution 3
--CROSS APPLY
SELECT  a.Batch,
        a.BatchStart,
        b.BatchEnd
FROM    #BatchStarts a
        CROSS APPLY
        (
            SELECT TOP (1)
                   Line AS BatchEnd
            FROM   #BatchLines
            WHERE  Batch = a.Batch
            AND    Line >= a.BatchStart
            AND    Syntax = 'GO'
            ORDER BY Line
        ) b
ORDER BY a.Batch,
         a.BatchStart;
GO

/*----------------------------------------------------
Puzzle #77 - Temperature Readings
*/----------------------------------------------------
DROP TABLE IF EXISTS #TemperatureData;
GO

CREATE TABLE #TemperatureData
(
TempID     INTEGER,
TempValue  INTEGER
);
GO

INSERT INTO #TemperatureData (TempID, TempValue) VALUES
(1,52),(2,NULL),(3,NULL),(4,65),(5,NULL),(6,72),
(7,NULL),(8,70),(9,NULL),(10,75),(11,NULL),(12,80);
GO

--Solution 1
--This may give a wrong answer based upon your SQL Server version
--LAG and LEAD
WITH cte_Fill AS
(
SELECT  TemperatureID,
        TemperatureValue,

        LAG(TemperatureValue)
            IGNORE NULLS
            OVER (ORDER BY TemperatureID) AS PreviousValue,

        LEAD(TemperatureValue)
            IGNORE NULLS
            OVER (ORDER BY TemperatureID) AS NextValue
FROM    #Temperature
)
SELECT  TemperatureID,
        COALESCE
        (
            TemperatureValue,
            GREATEST(PreviousValue, NextValue)
        ) AS TemperatureValue
FROM    cte_Fill
ORDER BY TemperatureID;
GO

--Solution 2
--OUTER APPLY
WITH cte_Apply AS
(
SELECT  a.TemperatureID,
        a.TemperatureValue,
        p.TemperatureValue AS PreviousValue,
        n.TemperatureValue AS NextValue
FROM    #Temperature a
OUTER APPLY
(
    SELECT TOP (1) TemperatureValue
    FROM #Temperature
    WHERE TemperatureID < a.TemperatureID
      AND TemperatureValue IS NOT NULL
    ORDER BY TemperatureID DESC
) p
OUTER APPLY
(
    SELECT TOP (1) TemperatureValue
    FROM #Temperature
    WHERE TemperatureID > a.TemperatureID
      AND TemperatureValue IS NOT NULL
    ORDER BY TemperatureID
) n
)
SELECT  TemperatureID,
        COALESCE
        (
            TemperatureValue,
            GREATEST(PreviousValue, NextValue)
        ) AS TemperatureValue
FROM    cte_Apply
ORDER BY TemperatureID;
GO

/*----------------------------------------------------
The End
*/----------------------------------------------------