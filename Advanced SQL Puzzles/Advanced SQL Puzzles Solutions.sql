/*----------------------------------------------------
Scott Peters
Solutions for Advanced SQL Puzzles
https://advancedsqlpuzzles.com
Last Updated: 03/29/2023
Microsoft SQL Server T-SQL

*/----------------------------------------------------

SET NOCOUNT ON;
GO

/*----------------------------------------------------
Answer to Puzzle #1
Shopping Carts
*/----------------------------------------------------

DROP TABLE IF EXISTS #Cart1;
DROP TABLE IF EXISTS #Cart2;
GO

CREATE TABLE #Cart1
(
Item  VARCHAR(100) PRIMARY KEY
);
GO

CREATE TABLE #Cart2
(
Item  VARCHAR(100) PRIMARY KEY
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
Answer to Puzzle #2
Managers and Employees
*/----------------------------------------------------

DROP TABLE IF EXISTS #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID  INTEGER PRIMARY KEY,
ManagerID   INTEGER NULL,
JobTitle    VARCHAR(100) NOT NULL
);
GO

INSERT INTO #Employees (EmployeeID, ManagerID, JobTitle) VALUES
(1001,NULL,'President'),(2002,1001,'Director'),
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
Answer to Puzzle #3
Fiscal Year Table Constraints
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
Answer to Puzzle #4
Two Predicates
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
CustomerID     INTEGER,
OrderID        INTEGER,
DeliveryState  VARCHAR(100) NOT NULL,
Amount         MONEY NOT NULL,
PRIMARY KEY (CustomerID, OrderID)
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
WHERE   b.DeliveryState = 'TX';
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
        CustomerID IN (SELECT b.CustomerID FROM cte_CA b);
GO

/*----------------------------------------------------
Answer to Puzzle #5
Phone Directory
*/----------------------------------------------------

DROP TABLE IF EXISTS #PhoneDirectory;
GO

CREATE TABLE #PhoneDirectory
(
CustomerID  INTEGER,
[Type]      VARCHAR(100),
PhoneNumber VARCHAR(12) NOT NULL,
PRIMARY KEY (CustomerID, [Type])
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

--Solution 3
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

--Solution 4
--MAX and CASE
SELECT  CustomerID,
        MAX(CASE [Type] WHEN 'Cellular' THEN PhoneNumber END),
        MAX(CASE [Type] WHEN 'Work' THEN PhoneNumber END),
        MAX(CASE [Type] WHEN 'Home' THEN PhoneNumber END)
FROM    #PhoneDirectory
GROUP BY CustomerID;
GO

/*----------------------------------------------------
Answer to Puzzle #6
Workflow Steps
*/----------------------------------------------------

DROP TABLE IF EXISTS #WorkflowSteps;
GO

CREATE TABLE #WorkflowSteps
(
Workflow        VARCHAR(100),
StepNumber      INTEGER,
CompletionDate  DATE NULL,
PRIMARY KEY (Workflow, StepNumber)
);
GO

INSERT INTO #WorkflowSteps (Workflow, StepNumber, CompletionDate) VALUES
('Alpha',1,'7/2/2018'),('Alpha',2,'7/2/2018'),('Alpha',3,'7/1/2018'),
('Bravo',1,'6/25/2018'),('Bravo',2,NULL),('Bravo',3,'6/27/2018'),
('Charlie',1,NULL),('Charlie',2,'7/1/2018');
GO

--Solution 1
--NULL operators
WITH cte_NotNull AS
(
SELECT  DISTINCT
        Workflow
FROM    #WorkflowSteps
WHERE   CompletionDate IS NOT NULL
),
cte_Null AS
(
SELECT  Workflow
FROM    #WorkflowSteps
WHERE   CompletionDate IS NULL
)
SELECT  Workflow
FROM    cte_NotNull
WHERE   Workflow IN (SELECT Workflow FROM cte_Null);
GO

--Solution 2
--HAVING clause and COUNT functions
SELECT  Workflow
FROM    #WorkflowSteps
GROUP BY Workflow
HAVING  COUNT(*) <> COUNT(CompletionDate);
GO

--Solution 3
--HAVING clause with MAX function
SELECT  Workflow
FROM    #WorkflowSteps
GROUP BY Workflow
HAVING  MAX(CASE WHEN CompletionDate IS NULL THEN 1 ELSE 0 END) = 1;
GO

/*----------------------------------------------------
Answer to Puzzle #7
Mission to Mars
*/----------------------------------------------------

DROP TABLE IF EXISTS #Candidates;
DROP TABLE IF EXISTS #Requirements;
GO

CREATE TABLE #Candidates
(
CandidateID INTEGER,
Occupation  VARCHAR(100),
PRIMARY KEY (CandidateID, Occupation)
);
GO

INSERT INTO #Candidates (CandidateID, Occupation) VALUES
(1001,'Geologist'),(1001,'Astrogator'),(1001,'Biochemist'),
(1001,'Technician'),(2002,'Surgeon'),(2002,'Machinist'),
(3003,'Cryologist'),(4004,'Selenologist');
GO

CREATE TABLE #Requirements
(
Requirement VARCHAR(100) PRIMARY KEY
);
GO

INSERT INTO #Requirements VALUES
('Geologist'),('Astrogator'),('Technician');
GO

SELECT  CandidateID
FROM    #Candidates
WHERE   Occupation IN (SELECT Requirement FROM #Requirements)
GROUP BY CandidateID
HAVING COUNT(*) = (SELECT COUNT(*) FROM #Requirements);
GO

/*----------------------------------------------------
Answer to Puzzle #8
Workflow Cases
*/----------------------------------------------------

DROP TABLE IF EXISTS #WorkflowCases;
GO

CREATE TABLE #WorkflowCases
(
Workflow  VARCHAR(100) PRIMARY KEY,
Case1     INTEGER NOT NULL DEFAULT 0,
Case2     INTEGER NOT NULL DEFAULT 0,
Case3     INTEGER NOT NULL DEFAULT 0
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
Answer to Puzzle #9
Matching Sets
*/----------------------------------------------------

DROP TABLE IF EXISTS #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID  INTEGER,
License     VARCHAR(100),
PRIMARY KEY (EmployeeID, License)
);
GO

INSERT INTO #Employees (EmployeeID, License) VALUES
(1001,'Class A'),(1001,'Class B'),(1001,'Class C'),
(2002,'Class A'),(2002,'Class B'),(2002,'Class C'),
(3003,'Class A'),(3003,'Class D'),
(4004,'Class A'),(4004,'Class B'),(4004,'Class D'),
(5005,'Class A'),(5005,'Class B'),(5005,'Class D');
GO

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

/*----------------------------------------------------
Answer to Puzzle #10
Mean, Median, Mode and Range
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue  INTEGER NOT NULL
);
GO

INSERT INTO #SampleData VALUES
(5),(6),(10),(10),(13),(14),(17),(20),(81),(90),(76);
GO

--Median
SELECT
        ((SELECT TOP 1 IntegerValue
        FROM    (
                SELECT  TOP 50 PERCENT IntegerValue
                FROM    #SampleData
                ORDER BY IntegerValue
                ) a
        ORDER BY IntegerValue DESC) +  --Add the Two Together
        (SELECT TOP 1 IntegerValue
        FROM (
            SELECT  TOP 50 PERCENT IntegerValue
            FROM    #SampleData
            ORDER BY IntegerValue DESC
            ) a
        ORDER BY IntegerValue ASC)
        ) * 1.0 /2 AS Median;
GO

--Mean and Range
SELECT  AVG(IntegerValue) AS Mean,
        MAX(IntegerValue) - MIN(IntegerValue) AS [Range]
FROM    #SampleData;
GO

--Mode
SELECT  TOP 1
        IntegerValue AS Mode,
        COUNT(*) AS ModeCount
FROM    #SampleData
GROUP BY IntegerValue
ORDER BY ModeCount DESC;
GO

/*----------------------------------------------------
Answer to Puzzle #11
Permutations
*/----------------------------------------------------

DROP TABLE IF EXISTS #TestCases;
GO

CREATE TABLE #TestCases
(
TestCase   VARCHAR(1) PRIMARY KEY
);
GO

INSERT INTO #TestCases (TestCase) VALUES
('A'),('B'),('C');
GO

DECLARE @vTotalElements INTEGER = (SELECT COUNT(*) FROM #TestCases);

--Recursion
WITH cte_Permutations (Permutation, Id, Depth)
AS
(
SELECT  CAST(TestCase AS VARCHAR(MAX)),
        CONCAT(CAST(TestCase AS VARCHAR(MAX)),';'),
        1 AS Depth
FROM    #TestCases
UNION ALL
SELECT  CONCAT(a.Permutation,',',b.TestCase),
        CONCAT(a.Id,b.TestCase,';'),
        a.Depth + 1
FROM    cte_Permutations a,
        #TestCases b
WHERE   a.Depth < @vTotalElements AND
        a.Id NOT LIKE CONCAT('%',b.TestCase,';%')
)
SELECT  Permutation
FROM    cte_Permutations
WHERE   Depth = @vTotalElements;
GO

/*----------------------------------------------------
Answer to Puzzle #12
Average Days
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow       VARCHAR(100),
ExecutionDate  DATE,
PRIMARY KEY (Workflow, ExecutionDate)
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
Answer to Puzzle #13
Inventory Tracking
*/----------------------------------------------------

DROP TABLE IF EXISTS #Inventory;
GO

CREATE TABLE #Inventory
(
InventoryDate       DATE PRIMARY KEY,
QuantityAdjustment  INTEGER NOT NULL
);
GO

INSERT INTO #Inventory (InventoryDate, QuantityAdjustment) VALUES
('7/1/2018',100),('7/2/2018',75),('7/3/2018',-150),
('7/4/2018',50),('7/5/2018',-75);
GO

SELECT  InventoryDate,
        QuantityAdjustment,
        SUM(QuantityAdjustment) OVER (ORDER BY InventoryDate)
FROM    #Inventory;
GO

/*----------------------------------------------------
Answer to Puzzle #14
Indeterminate Process Log
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow    VARCHAR(100),
StepNumber  INTEGER,
RunStatus   VARCHAR(100) NOT NULL,
PRIMARY KEY (Workflow, StepNumber)
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
        cte_Error b on a.WorkFlow = b.WorkFlow
ORDER BY 1;
GO

--Solution 2
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
FROM	cte_Distinct
GROUP BY Workflow
)
SELECT  Workflow,
        CASE WHEN DistinctCount = 1 THEN RunStatus_Agg
             WHEN RunStatus_Agg LIKE '%Error%' THEN 'Indeterminate'
             WHEN RunStatus_Agg LIKE '%Running%' THEN 'Running' END AS RunStatus
FROM    cte_StringAgg
ORDER BY 1;
GO

/*----------------------------------------------------
Answer to Puzzle #15
Group Concatenation
*/----------------------------------------------------

DROP TABLE IF EXISTS #DMLTable;
GO

CREATE TABLE #DMLTable
(
SequenceNumber  INTEGER PRIMARY KEY,
String          VARCHAR(100) NOT NULL
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
WITH
cte_DMLGroupConcat(String2,Depth) AS
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
SELECT  DISTINCT
        STUFF((
            SELECT  CAST(' ' AS VARCHAR(MAX)) + String
            FROM    #DMLTable U
            ORDER BY SequenceNumber
        FOR XML PATH('')), 1, 1, '') AS DML_String
FROM    #DMLTable;
GO

/*----------------------------------------------------
Answer to Puzzle #16
Reciprocals
*/----------------------------------------------------

DROP TABLE IF EXISTS #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
PlayerA  INTEGER,
PlayerB  INTEGER,
Score    INTEGER NOT NULL,
PRIMARY KEY (PlayerA, PlayerB)
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
Answer to Puzzle #17
De-Grouping
*/----------------------------------------------------

DROP TABLE IF EXISTS #Ungroup;
DROP TABLE IF EXISTS #Numbers;
GO

CREATE TABLE #Ungroup
(
ProductDescription  VARCHAR(100) PRIMARY KEY,
Quantity            INTEGER NOT NULL
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

ALTER TABLE #Ungroup ADD FOREIGN KEY (Quantity) REFERENCES #Numbers(IntegerValue);
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
Answer to Puzzle #18
Seating Chart
*/----------------------------------------------------

DROP TABLE IF EXISTS #SeatingChart;
GO

CREATE TABLE #SeatingChart
(
SeatNumber  INTEGER PRIMARY KEY
);
GO

INSERT INTO #SeatingChart (SeatNumber) VALUES
(7),(13),(14),(15),(27),(28),(29),(30),(31),(32),(33),(34),(35),(52),(53),(54);
GO

--Place a value of 0 in the SeatingChart table
INSERT INTO #SeatingChart VALUES (0);
GO

-------------------
--Gap start and gap end
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
SELECT  (CASE SeatNumber%2 WHEN 1 THEN 'Odd' WHEN 0 THEN 'Even' END) AS Modulus,
        COUNT(*) AS [Count]
FROM    #SeatingChart
GROUP BY (CASE SeatNumber%2 WHEN 1 THEN 'Odd' WHEN 0 THEN 'Even' END);
GO

/*----------------------------------------------------
Answer to Puzzle #19
Back to the Future
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
EndDate    DATE,
PRIMARY KEY (StartDate, EndDate)
);
GO

INSERT INTO #TimePeriods (StartDate, EndDate) VALUES
('1/1/2018','1/5/2018'),
('1/3/2018','1/9/2018'),
('1/10/2018','1/11/2018'),
('1/12/2018','1/16/2018'),
('1/15/2018','1/19/2018');
GO

--Step 1
SELECT  DISTINCT
        StartDate
INTO    #Distinct_StartDates
FROM    #TimePeriods;
GO

--Step 2
SELECT  a.StartDate AS StartDate_A,
        a.EndDate AS EndDate_A,
        b.StartDate AS StartDate_B,
        b.EndDate AS EndDate_B
INTO    #OuterJoin
FROM    #TimePeriods AS a LEFT OUTER JOIN
        #TimePeriods AS b ON a.EndDate >= b.StartDate AND
                                a.EndDate < b.EndDate;
GO

--Step 3
SELECT  EndDate_A
INTO    #DetermineValidEndDates
FROM    #OuterJoin
WHERE   StartDate_B IS NULL
GROUP BY EndDate_A;
GO

--Step 4
SELECT  a.StartDate, MIN(b.EndDate_A) AS MinEndDate_A
INTO    #DetermineValidEndDates2
FROM    #Distinct_StartDates a INNER JOIN
        #DetermineValidEndDates b ON a.StartDate <= b.EndDate_A
GROUP BY a.StartDate;
GO

--Results
SELECT  MIN(StartDate) AS StartDate,
        MAX(MinEndDate_A) AS EndDate
FROM    #DetermineValidEndDates2
GROUP BY MinEndDate_A;
GO

/*----------------------------------------------------
Answer to Puzzle #20
Price Points
*/----------------------------------------------------

DROP TABLE IF EXISTS #ValidPrices;
GO

CREATE TABLE #ValidPrices
(
ProductID      INTEGER,
UnitPrice      MONEY,
EffectiveDate  DATE,
PRIMARY KEY (ProductID, UnitPrice, EffectiveDate)
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
WHERE   NOT EXISTS (SELECT    1
                    FROM      #ValidPrices AS ppl
                    WHERE     ppl.ProductID = pp.ProductID AND
                              ppl.EffectiveDate > pp.EffectiveDate);
GO

--Solution 2
--RANK
WITH cte_ValidPrices AS
(
SELECT  RANK() OVER (PARTITION BY ProductID ORDER BY EffectiveDate DESC) AS Rnk,
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
        cte_MaxEffectiveDate b on a.EffectiveDate = b.MaxEffectiveDate AND a.ProductID = b.ProductID;
GO

/*----------------------------------------------------
Answer to Puzzle #21
Average Monthly Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER PRIMARY KEY,
CustomerID  INTEGER NOT NULL,
OrderDate   DATE NOT NULL,
Amount      MONEY NOT NULL,
[State]     VARCHAR(2) NOT NULL
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

WITH cte_AvgMonthlySalesCustomer AS
(
SELECT  CustomerID,
        AVG(b.Amount) AS AverageValue,
        [State]
FROM    #Orders b
GROUP BY CustomerID,OrderDate,[State]
),
cte_MinAverageValueState AS
(
SELECT  [State]
FROM    cte_AvgMonthlySalesCustomer
GROUP BY [State]
HAVING  MIN(AverageValue) >= 100
)
SELECT  [State]
FROM    cte_MinAverageValueState;
GO

/*----------------------------------------------------
Answer to Puzzle #22
Occurrences
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow     VARCHAR(100),
LogMessage   VARCHAR(100),
Occurrences  INTEGER NOT NULL,
PRIMARY KEY (Workflow, LogMessage)
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

--Solution 2
--ALL
SELECT  WorkFlow,
        LogMessage,
        Occurrences
FROM    #ProcessLog AS e1
WHERE   Occurrences > ALL(SELECT    e2.Occurrences
                            FROM    #ProcessLog AS e2
                            WHERE   e2.LogMessage = e1.LogMessage AND
                                    e2.WorkFlow <> e1.WorkFlow);
GO

/*----------------------------------------------------
Answer to Puzzle #23
Divide in Half
*/----------------------------------------------------

DROP TABLE IF EXISTS #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
PlayerID  INTEGER PRIMARY KEY,
Score     INTEGER NOT NULL
);
GO

INSERT INTO #PlayerScores (PlayerID, Score) VALUES
(1001,2343),(2002,9432),
(3003,6548),(4004,1054),
(5005,6832);
GO

SELECT  NTILE(2) OVER (ORDER BY Score DESC) as Quartile,
        PlayerID,
        Score
FROM    #PlayerScores a
ORDER BY Score DESC;
GO

/*----------------------------------------------------
Answer to Puzzle #24
Page Views
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER PRIMARY KEY,
CustomerID  INTEGER NOT NULL,
OrderDate   DATE NOT NULL,
Amount      MONEY NOT NULL,
[State]     VARCHAR(2) NOT NULL
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
Answer to Puzzle #25
Top Vendors
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER PRIMARY KEY,
CustomerID  INTEGER NOT NULL,
[Count]     INTEGER NOT NULL,
Vendor      VARCHAR(100) NOT NULL
);
GO

INSERT INTO #Orders (OrderID, CustomerID, [Count], Vendor) VALUES
(1,1001,12,'Direct Parts'),
(2,1001,54,'Direct Parts'),
(3,1001,32,'ACME'),
(4,2002,7,'ACME'),
(5,2002,16,'ACME'),
(6,2002,5,'Direct Parts');
GO

--Solution 1
--MAX window function
WITH cte_Max AS
(
SELECT  OrderID, CustomerID, [Count], Vendor,
        MAX([Count]) OVER (PARTITION BY CustomerID ORDER BY CustomerID) AS MaxCount
FROM    #Orders
)
SELECT  CustomerID, Vendor
FROM    cte_Max
WHERE   [Count] = MaxCount
ORDER BY 1, 2;
GO

--Solution 1
--RANK function
WITH cte_Rank AS
(
SELECT  CustomerID,
        Vendor,
        RANK() OVER (PARTITION BY CustomerID ORDER BY [Count] DESC) AS Rnk
FROM    #Orders
GROUP BY CustomerID, Vendor, [Count]
)
SELECT  DISTINCT b.CustomerID, b.Vendor
FROM    #Orders a INNER JOIN
        cte_Rank b ON a.CustomerID = b.CustomerID AND a.Vendor = b.Vendor
WHERE   Rnk = 1
ORDER BY 1, 2;
GO

--Solution 3
--MAX with Correlated SubQuery
WITH cte_Max AS
(
SELECT  CustomerID,
        MAX([Count]) AS MaxOrderCount
FROM    #Orders
GROUP BY CustomerID
)
SELECT  CustomerID, Vendor
FROM    #Orders a
WHERE   EXISTS (SELECT 1 FROM cte_Max b WHERE a.CustomerID = b.CustomerID and a.[Count] = MaxOrderCount)
ORDER BY 1, 2;
GO

--Solution 4
--ALL Operator
SELECT  CustomerID, Vendor
FROM    #Orders a
WHERE   [Count] >= ALL(SELECT [Count] FROM #Orders b WHERE a.CustomerID = b.CustomerID)
ORDER BY 1, 2;
GO

--Solution 5
--MAX Function
SELECT  CustomerID, Vendor
FROM    #Orders a
WHERE   [Count] >= (SELECT MAX([Count]) FROM #Orders b WHERE a.CustomerID = b.CustomerID)
ORDER BY 1, 2;
GO

/*----------------------------------------------------
Answer to Puzzle #26
Previous Years Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Sales;
GO

CREATE TABLE #Sales
(
[Year]  INTEGER NOT NULL,
Amount  INTEGER NOT NULL
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

--Solution 1
--PIVOT
SELECT [2018],[2017],[2016] FROM #Sales
PIVOT (SUM(Amount) FOR [Year] IN ([2018],[2017],[2016])) AS PivotClause;
GO

--Solution 2
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
SELECT  Amount AS '2018',
        Lag1 AS '2017',
        Lag2 AS '2016'
FROM    cte_Lag
WHERE   [Year] = 2018;
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
Answer to Puzzle #27
Delete the Duplicates
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue  INTEGER NOT NULL,
);
GO

INSERT INTO #SampleData VALUES
(1),(1),(2),(3),(3),(4);
GO

WITH cte_Duplicates AS
(
SELECT  ROW_NUMBER() OVER (PARTITION BY IntegerValue ORDER BY IntegerValue) AS Rnk
FROM    #SampleData
)
DELETE FROM cte_Duplicates WHERE Rnk > 1
GO

/*----------------------------------------------------
Answer to Puzzle #28
Fill the Gaps

This is often called a Flash Fill or a Data Smudge
*/----------------------------------------------------

DROP TABLE IF EXISTS #Gaps;
GO

CREATE TABLE #Gaps
(
RowNumber   INTEGER PRIMARY KEY,
TestCase    VARCHAR(100) NULL
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
                    WHERE c.RowNumber <= a.RowNumber AND c.TestCase != '')) TestCase
FROM #Gaps a;
GO

/*----------------------------------------------------
Answer to Puzzle #29
Count the Groupings
*/----------------------------------------------------
DROP TABLE IF EXISTS #Groupings;
GO

CREATE TABLE #Groupings
(
StepNumber  INTEGER PRIMARY KEY,
TestCase    VARCHAR(100) NOT NULL,
[Status]    VARCHAR(100) NOT NULL
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

WITH cte_Groupings AS
(
SELECT  StepNumber,
        [Status],
        StepNumber - ROW_NUMBER() OVER (PARTITION BY [Status] ORDER BY StepNumber) AS Rnk
FROM    #Groupings
)
SELECT  MIN(StepNumber) AS MinStepNumber,
        MAX(StepNumber) AS MaxStepNumber,
        [Status],
        COUNT(*) AS ConsecutiveCount,
        MAX(StepNumber) - MIN(StepNumber) + 1 AS ConsecutiveCount_MinMax
FROM    cte_Groupings
GROUP BY Rnk,
        [Status]
ORDER BY 1, 2;
GO

/*----------------------------------------------------
Answer to Puzzle #30
Select Star
*/----------------------------------------------------

DROP TABLE IF EXISTS #Products;
GO

CREATE TABLE #Products
(
ProductID    INTEGER PRIMARY KEY,
ProductName  VARCHAR(100) NOT NULL
);
GO

--Add the following constraint
ALTER TABLE #Products ADD ComputedColumn AS (0/0);
GO

/*----------------------------------------------------
Answer to Puzzle #31
Second Highest
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue  INTEGER PRIMARY KEY
);
GO

INSERT INTO #SampleData (IntegerValue) VALUES
(3759),(3760),(3761),(3762),(3763);
GO

--Solution 1
--Correlated Subquery
SELECT  IntegerValue
FROM    #SampleData a
WHERE   2 = (SELECT COUNT(IntegerValue)
            FROM    #SampleData b
            WHERE   a.IntegerValue <= b.IntegerValue);
GO

--Solution 2
--OFFSET
SELECT  IntegerValue
FROM    #SampleData a
ORDER BY IntegerValue DESC
OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY;
GO

--Solution 3
--MAX
SELECT  MAX(IntegerValue)
FROM    #SampleData
WHERE   IntegerValue < (SELECT MAX(IntegerValue) FROM #SampleData);
GO

--Solution 4
--TOP
WITH cte_Top2 AS
(
SELECT  TOP(2) IntegerValue
FROM    #SampleData
ORDER BY IntegerValue DESC
)
SELECT  MIN(IntegerValue) FROM cte_Top2;
GO

/*----------------------------------------------------
Answer to Puzzle #32
First and Last
*/----------------------------------------------------

DROP TABLE IF EXISTS #Personal;
GO

CREATE TABLE #Personal
(
SpacemanID      INTEGER PRIMARY KEY,
JobDescription  VARCHAR(100) NOT NULL,
MissionCount    INTEGER NOT NULL
);
GO

INSERT INTO #Personal (SpacemanID, JobDescription, MissionCount) VALUES
(1001,'Astrogator',6),(2002,'Astrogator',12),(3003,'Astrogator',17),
(4004,'Geologist',21),(5005,'Geologist',9),(6006,'Geologist',8),
(7007,'Technician',13),(8008,'Technician',2),(9009,'Technician',7);
GO

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

/*----------------------------------------------------
Answer to Puzzle #33
Deadlines
*/----------------------------------------------------

DROP TABLE IF EXISTS #ManufacturingTimes;
DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #ManufacturingTimes
(
PartID             VARCHAR(100),
Product            VARCHAR(100),
DaysToManufacture  INTEGER NOT NULL,
PRIMARY KEY (PartID, Product)
);
GO

CREATE TABLE #Orders
(
OrderID    INTEGER PRIMARY KEY,
Product    VARCHAR(100) NOT NULL REFERENCES #ManufacturingTimes (Product),
DaysToDeliver INTEGER NOT NULL
);
GO

INSERT INTO #ManufacturingTimes (PartID, Product, DaysToManufacture) VALUES
('AA-111','Widget',7),
('BB-222','Widget',2),
('CC-333','Widget',3),
('DD-444','Widget',1),
('AA-111','Gizmo',7),
('BB-222','Gizmo',2),
('AA-111','Doodad',7),
('DD-444','Doodad',1);
GO

INSERT INTO #Orders (OrderID, Product, DaysToDeliver) VALUES
(1,'Widget',7),
(2,'Gizmo',3),
(3,'Doodad',9);
GO

--Solution 1
--MAX with INNER JOIN
WITH cte_Max AS
(
SELECT  Product,
        MAX(DaysToManufacture) AS MaxDaysToManufacture
FROM    #ManufacturingTimes b
GROUP BY Product
)
SELECT  a.OrderID,
        a.Product
FROM    #Orders a INNER JOIN
        cte_Max b ON a.Product = b.Product AND a.DaysToDeliver >= b.MaxDaysToManufacture;
GO

--Solution 2
--MAX with correlated subquery
WITH cte_Max AS
(
SELECT  Product, MAX(DaysToManufacture) AS MaxDaysToManufacture
FROM    #ManufacturingTimes b
GROUP BY Product
)
SELECT  OrderID,
        Product
FROM    #Orders a
WHERE   EXISTS (SELECT  1
                FROM    cte_Max b 
                WHERE   a.Product = b.Product AND
                        a.DaysToDeliver >= b.MaxDaysToManufacture);
GO

--Solution 3
--ALL
SELECT  OrderID,
        Product
FROM    #Orders a
WHERE   DaysToDeliver >= ALL(SELECT  DaysToManufacture 
                              FROM    #ManufacturingTimes b 
                              WHERE   a.Product = b.Product);
GO

/*----------------------------------------------------
Answer to Puzzle #34
Specific Exclusion
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER PRIMARY KEY,
CustomerID  INTEGER NOT NULL,
Amount      MONEY NOT NULL
);
GO

INSERT INTO #Orders (OrderID, CustomerID, Amount) VALUES
(1,1001,25),(2,1001,50),(3,2002,65),(4,3003,50);
GO

SELECT  OrderID,
        CustomerID,
        Amount
FROM    #Orders
WHERE   NOT(CustomerID = 1001 AND Amount = 50);
GO

SELECT  OrderID,
        CustomerID,
        Amount
FROM    #Orders
WHERE   CONCAT(CustomerID, Amount)  <> '100150.00'
ORDER BY 2
GO

/*----------------------------------------------------
Answer to Puzzle #35
International vs Domestic Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
InvoiceID   INTEGER PRIMARY KEY,
SalesRepID  INTEGER NOT NULL,
Amount      MONEY NOT NULL,
SalesType   VARCHAR(100) NOT NULL
);
GO

INSERT INTO #Orders VALUES
(1,1001,13454,'International'),
(2,2002,3434,'International'),
(3,4004,54645,'International'),
(4,5005,234345,'International'),
(5,7007,776,'International'),
(6,1001,4564,'Domestic'),
(7,2002,34534,'Domestic'),
(8,3003,345,'Domestic'),
(9,6006,6543,'Domestic'),
(10,8008,67,'Domestic');
GO

--Solution 1 
--NOT
SELECT  InvoiceID,
        SalesRepID,
        Amount
FROM    #Orders
WHERE   NOT(SalesRepID = 1001 AND Amount = 50);
GO

--Solution 2
--EXCEPT
SELECT  InvoiceID,
        SalesRepID,
        Amount
FROM    #Orders
EXCEPT
SELECT  InvoiceID,
        SalesRepID,
        Amount
FROM    #Orders
WHERE   SalesRepID = 1001 AND Amount = 50;

/*----------------------------------------------------
Answer to Puzzle #36
Traveling Salesman
*/----------------------------------------------------

DROP TABLE IF EXISTS #TravelingSalesman;
DROP TABLE IF EXISTS #Routes;
GO

CREATE TABLE #Routes
(
RouteID        INTEGER NOT NULL,
DepartureCity  VARCHAR(30) NOT NULL,
ArrivalCity    VARCHAR(30) NOT NULL,
Cost           MONEY NOT NULL,
PRIMARY KEY (DepartureCity, ArrivalCity)
);
GO

INSERT #Routes (RouteID, DepartureCity, ArrivalCity, Cost)
OUTPUT INSERTED.RouteID AS RouteID,
       INSERTED.ArrivalCity AS DepartureCity,
       INSERTED.DepartureCity AS ArrivalCity,
       INSERTED.Cost
INTO   #Routes (RouteID, DepartureCity, ArrivalCity, Cost)
VALUES
(1,'Austin','Dallas',100),
(2,'Dallas','Memphis',200),
(3,'Memphis','Des Moines',300),
(4,'Dallas','Des Moines',400);
GO

--Solution 1
--Recursion
WITH cteMap(Nodes, LastNode, NodeMap, Cost)
AS (
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
FROM    cteMap AS m INNER JOIN
        #Routes AS r ON r.DepartureCity = m.LastNode
WHERE   m.NodeMap NOT LIKE '\%' + r.ArrivalCity + '%\'
)
SELECT  NodeMap, Cost
INTO    #TravelingSalesman
FROM    cteMap
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
InsertDate      DATETIME DEFAULT GETDATE() NOT NULL,
RouteInsertID   INTEGER NOT NULL,
RoutePath       VARCHAR(8000) NOT NULL,
TotalCost       MONEY NOT NULL,
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
     INSERT INTO #RoutesList  (RouteInsertID, RoutePath, TotalCost, LastArrival)
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
Answer to Puzzle #37
Group Criteria Keys
*/----------------------------------------------------

DROP TABLE IF EXISTS #GroupCriteria;
GO

CREATE TABLE #GroupCriteria
(
OrderID      INTEGER PRIMARY KEY,
Distributor  VARCHAR(100) NOT NULL,
Facility     INTEGER NOT NULL,
[Zone]       VARCHAR(100) NOT NULL,
Amount       MONEY NOT NULL
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
FROM    #GroupCriteria;
GO

/*----------------------------------------------------
Answer to Puzzle #38
Reporting Elements
*/----------------------------------------------------

DROP TABLE IF EXISTS #RegionSales;
GO

CREATE TABLE #RegionSales
(
Region       VARCHAR(100),
Distributor  VARCHAR(100),
Sales        INTEGER NOT NULL,
PRIMARY KEY (Region, Distributor)
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
Answer to Puzzle #39
Prime Numbers
*/----------------------------------------------------

DROP TABLE IF EXISTS #PrimeNumbers;
GO

CREATE TABLE #PrimeNumbers
(
IntegerValue  INTEGER PRIMARY KEY
);
GO

INSERT INTO #PrimeNumbers VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);
GO

WITH cte_Mod AS
(
SELECT  a.IntegerValue, a.IntegerValue % b.IntegerValue AS Modulus
FROM    #PrimeNumbers a INNER JOIN
        #PrimeNumbers b ON a.IntegerValue >= b.IntegerValue
)
SELECT IntegerValue AS PrimeNumber
FROM   cte_Mod
WHERE  Modulus = 0
GROUP BY IntegerValue
HAVING COUNT(*) = 2;
GO

/*----------------------------------------------------
Answer to Puzzle #40
Sort Order
*/----------------------------------------------------

DROP TABLE IF EXISTS #SortOrder;
GO

CREATE TABLE #SortOrder
(
City VARCHAR(100) PRIMARY KEY
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
Answer to Puzzle #41
Associate IDs
*/----------------------------------------------------

DROP TABLE IF EXISTS #Associates;
DROP TABLE IF EXISTS #Associates2;
DROP TABLE IF EXISTS #Associates3;
GO

CREATE TABLE #Associates
(
Associate1  VARCHAR(100),
Associate2  VARCHAR(100),
PRIMARY KEY (Associate1, Associate2)
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
Answer to Puzzle #42
Mutual Friends
*/----------------------------------------------------

DROP TABLE IF EXISTS #Friends;
DROP TABLE IF EXISTS #Nodes;
DROP TABLE IF EXISTS #Edges;
DROP TABLE IF EXISTS Nodes_Edges_To_Evaluate;
GO

CREATE TABLE #Friends
(
Friend1  VARCHAR(100),
Friend2  VARCHAR(100),
PRIMARY KEY (Friend1, Friend2)
);
GO

INSERT INTO #Friends VALUES
('Jason','Mary'),('Mike','Mary'),('Mike','Jason'),
('Susan','Jason'),('John','Mary'),('Susan','Mary');
GO

--Create reciprocals (Edges)
SELECT  Friend1, Friend2
INTO    #Edges
FROM    #Friends
UNION
SELECT  Friend2, Friend1
FROM #Friends;
GO

--Created Nodes
SELECT Friend1 AS Person
INTO   #Nodes
FROM   #Friends
UNION
SELECT  Friend2
FROM    #Friends;
GO

--Cross join all Edges and Nodes
SELECT  a.Friend1, a.Friend2, b.Person
INTO    Nodes_Edges_To_Evaluate
FROM    #Edges a CROSS JOIN
        #Nodes b
ORDER BY 1,2,3;
GO

--Evaluates the cross join to the edges
WITH cte_JoinLogic AS
(
SELECT  a.Friend1
        ,a.Friend2
        ,'---' AS Id1
        ,b.Friend2 AS MutualFriend1
        ,'----' AS Id2
        ,c.Friend2 AS MutualFriend2
FROM   Nodes_Edges_To_Evaluate a LEFT OUTER JOIN
       #Edges b ON a.Friend1 = b.Friend1 and a.Person = b.Friend2 LEFT OUTER JOIN
       #Edges c ON a.Friend2 = c.Friend1 and a.Person = c.Friend2
),
cte_Predicate AS
(
--Apply predicate logic
SELECT  Friend1, Friend2, MutualFriend1 AS MutualFriend
FROM    cte_JoinLogic
WHERE   MutualFriend1 = MutualFriend2 AND MutualFriend1 IS NOT NULL AND MutualFriend2 IS NOT NULL
),
cte_Count AS
(
SELECT  Friend1, Friend2, COUNT(*) AS CountMutualFriends
FROM    cte_Predicate
GROUP BY Friend1, Friend2
)
SELECT  DISTINCT
        (CASE WHEN Friend1 < Friend2 THEN Friend1 ELSE Friend2 END) AS Friend1,
        (CASE WHEN Friend1 < Friend2 THEN Friend2 ELSE Friend1 END) AS Friend2,
        CountMutualFriends
FROM    cte_Count
ORDER BY 1,2;
GO

/*----------------------------------------------------
Answer to Puzzle #43
Unbounded Preceding
*/----------------------------------------------------

DROP TABLE IF EXISTS #CustomerOrders;
GO

CREATE TABLE #CustomerOrders
(
OrderID     INTEGER,
CustomerID  INTEGER,
Quantity    INTEGER NOT NULL,
PRIMARY KEY (OrderID, CustomerID)
);
GO

INSERT INTO #CustomerOrders (OrderID, CustomerID, Quantity) VALUES 
(1,1001,5),(2,1001,8),(3,1001,3),(4,1001,7),
(1,2002,4),(2,2002,9);
GO

SELECT  OrderID,
        CustomerID,
        Quantity,
        MIN(Quantity) OVER (PARTITION by CustomerID ORDER BY OrderID) AS MinQuantity
FROM    #CustomerOrders;
GO

/*----------------------------------------------------
Answer to Puzzle #44
Slowly Changing Dimension Part I
*/----------------------------------------------------

DROP TABLE IF EXISTS #Balances;
GO

CREATE TABLE #Balances
(
CustomerID   INTEGER,
BalanceDate  DATE,
Amount       MONEY NOT NULL,
PRIMARY KEY (CustomerID, BalanceDate)
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
        LAG(BalanceDate) OVER 
                (PARTITION BY CustomerID ORDER BY BalanceDate DESC)
                    AS EndDate,
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
Answer to Puzzle #45
Slowly Changing Dimension Part 2
*/----------------------------------------------------

DROP TABLE IF EXISTS #Balances;
GO

CREATE TABLE #Balances
(
CustomerID  INTEGER,
StartDate   DATE,
EndDate     DATE,
Amount      MONEY,
PRIMARY KEY (CustomerID, StartDate)
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

WITH cte_Lag AS
(
SELECT  CustomerID, StartDate, EndDate, Amount,
        LAG(StartDate) OVER 
            (PARTITION BY CustomerID ORDER BY StartDate DESC) AS StartDate_Lag
FROM    #Balances
)
SELECT  CustomerID, StartDate, EndDate, Amount, StartDate_Lag
FROM    cte_Lag
WHERE   EndDate >= StartDate_Lag
ORDER BY CustomerID, StartDate DESC;
GO

/*----------------------------------------------------
Answer to Puzzle #46
Positive Account Balances
*/----------------------------------------------------

DROP TABLE IF EXISTS #AccountBalances;
GO

CREATE TABLE #AccountBalances
(
AccountID  INTEGER,
Balance    MONEY,
PRIMARY KEY (AccountID, Balance)
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
HAVING  MAX(Balance) < 0;
GO

--Solution 3
--NOT IN
SELECT  DISTINCT AccountID
FROM    #AccountBalances
WHERE   AccountID NOT IN (SELECT AccountID FROM #AccountBalances WHERE Balance > 0);
GO

--Solution 4
--NOT EXISTS
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

/*----------------------------------------------------
Answer to Puzzle #47
Work Schedule
*/----------------------------------------------------

DROP TABLE IF EXISTS #Schedule;
DROP TABLE IF EXISTS #Activity;
DROP TABLE IF EXISTS #ScheduleTimes;
DROP TABLE IF EXISTS #ActivityCoalesce
GO

CREATE TABLE #Schedule
(
ScheduleId  CHAR(1) PRIMARY KEY,
StartTime   DATETIME NOT NULL,
EndTime     DATETIME NOT NULL
);
GO

CREATE TABLE #Activity
(
ScheduleID   CHAR(1) REFERENCES #Schedule (ScheduleID),
ActivityName VARCHAR(100),
StartTime    DATETIME,
EndTime      DATETIME,
PRIMARY KEY (ScheduleID, ActivityName, StartTime, EndTime)
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

--Step 1
SELECT  ScheduleID, StartTime AS ScheduleTime 
INTO    #ScheduleTimes
FROM    #Schedule
UNION
SELECT  ScheduleID, EndTime FROM #Schedule
UNION
SELECT  ScheduleID, StartTime FROM #Activity
UNION
SELECT  ScheduleID, EndTime FROM #Activity;
GO

--Step 2
SELECT  a.ScheduleID
        ,a.ScheduleTime
        ,COALESCE(b.ActivityName, c.ActivityName, 'Work') AS ActivityName
INTO    #ActivityCoalesce
FROM    #ScheduleTimes a LEFT OUTER JOIN
        #Activity b ON a.ScheduleTime = b.StartTime AND a.ScheduleId = b.ScheduleID LEFT OUTER JOIN
        #Activity c ON a.ScheduleTime = c.EndTime AND a.ScheduleId = b.ScheduleID LEFT OUTER JOIN
        #Schedule d ON a.ScheduleTime = d.StartTime AND a.ScheduleId = b.ScheduleID LEFT OUTER JOIN
        #Schedule e ON a.ScheduleTime = e.EndTime AND a.ScheduleId = b.ScheduleID 
ORDER BY a.ScheduleID, a.ScheduleTime;
GO

--Step 3
WITH cte_Lead AS
(
SELECT  ScheduleID,
        ActivityName,
        ScheduleTime as StartTime,
        LEAD(ScheduleTime) OVER (PARTITION BY ScheduleID ORDER BY ScheduleTime) AS EndTime
FROM    #ActivityCoalesce
)
SELECT  ScheduleID, ActivityName, StartTime, EndTime
FROM    cte_Lead
WHERE   EndTime IS NOT NULL;
GO

/*----------------------------------------------------
Answer to Puzzle #48
Consecutive Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Sales;
GO

CREATE TABLE #Sales
(
SalesID  INTEGER,
[Year]   INTEGER,
PRIMARY KEY (SalesID, [Year])
);
GO

INSERT INTO #Sales (SalesID, [Year]) VALUES
(1001,2018),(1001,2019),(1001,2020),(2002,2020),(2002,2021),
(3003,2018),(3003,2020),(3003,2021),(4004,2019),(4004,2020),(4004,2021);
GO

--Current Year
WITH cte_Current_Year AS
(
SELECT  SalesID,
        [Year]
FROM    #Sales
WHERE   [Year] = DATEPART(YY,GETDATE())
GROUP BY SalesID, [Year]
)
--Previous Years
,cte_Determine_Lag AS
(
SELECT  a.SalesID,
        b.[Year],
        DATEPART(YY,GETDATE()) - 2 AS Year_Start
FROM    cte_Current_Year a INNER JOIN
        #Sales b on a.SalesID = b.SalesID
WHERE   b.[Year] = DATEPART(YY,GETDATE()) - 2
)
SELECT  DISTINCT SalesID
FROM    cte_Determine_Lag;
GO

/*----------------------------------------------------
Answer to Puzzle #49
Sumo Wrestlers
*/----------------------------------------------------

DROP TABLE IF EXISTS #ElevatorOrder;
GO

CREATE TABLE #ElevatorOrder
(
LineOrder  INTEGER PRIMARY KEY,
[Name]     VARCHAR(100) NOT NULL,
[Weight]   INTEGER NOT NULL,

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
        SUM(Weight) OVER (ORDER BY LineOrder) AS Running_Total
FROM    #ElevatorOrder
)
SELECT  TOP 1
        [Name], [Weight], LineOrder, Running_Total
FROM    cte_Running_Total
WHERE   Running_Total <= 2000
ORDER BY Running_Total DESC;
GO

/*----------------------------------------------------
Answer to Puzzle #50
Baseball Balls and Strikes
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
Result       VARCHAR(100) NOT NULL,
PRIMARY KEY (BatterID, PitchNumber)
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
        (CASE   WHEN    Result IN ('Foul','In Play') AND
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
Answer to Puzzle #51
Primary Key Creation
*/----------------------------------------------------

DROP TABLE IF EXISTS #Assembly;
GO

CREATE TABLE #Assembly
(
AssemblyID  INTEGER,
Part        VARCHAR(100),
PRIMARY KEY (AssemblyID, Part)
);
GO

INSERT INTO #Assembly (AssemblyID, Part) VALUES
(1001,'Bolt'),(1001,'Screw'),(2002,'Nut'),
(2002,'Washer'),(3003,'Toggle'),(3003,'Bolt');
GO

SELECT  HASHBYTES('SHA2_512',CONCAT(AssemblyID, Part)) AS ExampleUniqueID1,
        CHECKSUM(CONCAT(AssemblyID, Part)) AS ExampleUniqueID1,
        AssemblyID,
        Part
FROM    #Assembly;
GO

/*----------------------------------------------------
Answer to Puzzle #52
Phone Numbers Table
*/----------------------------------------------------

DROP TABLE IF EXISTS #CustomerInfo;
GO

CREATE TABLE #CustomerInfo
(
CustomerID   INTEGER PRIMARY KEY,
PhoneNumber  VARCHAR(14) NOT NULL,
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
Answer to Puzzle #53
Spouse IDs
*/----------------------------------------------------

DROP TABLE IF EXISTS #Spouses;
GO

CREATE TABLE #Spouses
(
PrimaryID  VARCHAR(100),
SpouseID   VARCHAR(100),
PRIMARY KEY (PrimaryID, SpouseID)
);
GO

INSERT INTO #Spouses VALUES
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
Answer to Puzzle #54
Winning Numbers
*/----------------------------------------------------

DROP TABLE IF EXISTS #WinningNumbers;
DROP TABLE IF EXISTS #LotteryTickets;
GO

CREATE TABLE #WinningNumbers
(
Number  INTEGER PRIMARY KEY
);
GO

INSERT INTO #WinningNumbers (Number) VALUES
(25),(45),(78);
GO

CREATE TABLE #LotteryTickets
(
TicketID    VARCHAR(3),
Number      INTEGER,
PRIMARY KEY (TicketID, Number)
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
        #WinningNumbers b on a.Number = b.Number
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
Answer to Puzzle #55
Table Audit
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProductsA;
DROP TABLE IF EXISTS #ProductsB;
GO

CREATE TABLE #ProductsA
(
ProductName  VARCHAR(100) PRIMARY KEY,
Quantity     INTEGER NOT NULL
);
GO

CREATE TABLE #ProductsB
(
ProductName  VARCHAR(100) PRIMARY KEY,
Quantity     INTEGER NOT NULL
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

WITH cte_FullOuter AS
(
SELECT  a.ProductName AS ProductNameA,
        b.ProductName AS ProductNameB,
        a.Quantity AS QuantityA,
        b.Quantity AS QuantityB
FROM    #ProductsA a FULL OUTER JOIN
        #ProductsB b ON a.ProductName = b.ProductName
)
SELECT  'Matches In both tables' AS [Type],
        ProductNameA
FROM    cte_FullOuter
WHERE   ProductNameA = ProductNameB
UNION
SELECT  'Product does not exist in Table B' AS [Type],
        ProductNameA
FROM    cte_FullOuter
WHERE   ProductNameB IS NULL
UNION
SELECT  'Product does not exist in Table A' AS [Type],
        ProductNameB
FROM   cte_FullOuter
WHERE  ProductNameA IS NULL
UNION
SELECT  'Quantities in Table A and Table B do not match' AS [Type],
        ProductNameA
FROM    cte_FullOuter
WHERE   QuantityA <> QuantityB;
GO

/*----------------------------------------------------
Answer to Puzzle #56
Numbers Using Recursion
*/----------------------------------------------------

DROP TABLE IF EXISTS #Numbers;
DECLARE @vTotalNumbers INTEGER = 10;

WITH cte_Number (Number)
AS  (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM    cte_Number
    WHERE   Number < @vTotalNumbers
    )
SELECT  Number
INTO    #Numbers
FROM    cte_Number
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level
GO

SELECT Number
FROM   #Numbers;
GO

/*----------------------------------------------------
Answer to Puzzle #57
Find The Spaces
*/----------------------------------------------------

DROP TABLE IF EXISTS #Strings;
GO

CREATE TABLE #Strings
(
QuoteId  INTEGER IDENTITY(1,1) PRIMARY KEY,
String   VARCHAR(100) NOT NULL
);
GO

INSERT INTO #Strings (String) VALUES
('SELECT EmpID, MngrID FROM Employees;'),('SELECT * FROM Transactions;');
GO

--Display the results using recursion
;WITH cte_CAST AS
(
SELECT QuoteID, CAST(String AS VARCHAR(200)) AS String FROM #Strings
),
cte_Anchor AS
(
SELECT QuoteID,
       String,
       1 AS Starts,
       CHARINDEX(' ', String) AS Position
FROM   cte_CAST
UNION ALL
SELECT QuoteID,
       String,
       Position + 1,
       CHARINDEX(' ', String, Position + 1)
FROM   cte_Anchor
WHERE  Position > 0
)
SELECT  ROW_NUMBER() OVER (PARTITION BY QuoteID ORDER BY Starts) AS RowNumber,
        QuoteID,
        String,
        Starts,
        Position,
        SUBSTRING(String, Starts, CASE WHEN Position > 0 THEN Position - Starts ELSE LEN(String) END) Word,
        LEN(String) - LEN(REPLACE(String,' ','')) AS TotalSpaces
FROM    cte_Anchor
ORDER BY QuoteID, Starts;
GO

/*----------------------------------------------------
Answer to Puzzle #58
Add Them Up
*/----------------------------------------------------

DROP TABLE IF EXISTS #Equations;
GO

CREATE TABLE #Equations
(
Equation  VARCHAR(200) PRIMARY KEY,
TotalSum  INT NULL
);
GO

INSERT INTO #Equations (Equation) VALUES
('123'),('1+2+3'),('1+2-3'),('1+23'),('1-2+3'),('1-2-3'),('1-23'),('12+3'),('12-3');
GO

--Solution 1
--CURSOR and DYNAMIC SQL
--This solution if you have to multiple and divide
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
FROM    #Equations;
GO

--Solution 2
--STRING_SPLIT
--This solution will work if you need to only add and subtract.
--Note that STRING_SPLIT does not guarantee order.  Use enable_oridinal if you need to order the output.
--The enable_ordinal argument and ordinal output column are currently supported in Azure SQL Database, Azure SQL Managed Instance, 
--and Azure Synapse Analytics (serverless SQL pool only). Beginning with SQL Server 2022 (16.x), the argument and output column are available in SQL Server.
	
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
GROUP BY Equation;
GO

/*----------------------------------------------------
DDL for Puzzle #59
Balanced String
*/----------------------------------------------------

DROP TABLE IF EXISTS #BalancedString;
GO

CREATE TABLE #BalancedString
(
RowNumber        INT IDENTITY(1,1) PRIMARY KEY,
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

/*----------------------------------------------------
DDL for Puzzle #60
Products Without Duplicates
*/----------------------------------------------------

DROP TABLE IF EXISTS #Products;
GO

CREATE TABLE #Products
(
Product     VARCHAR(10),
ProductCode VARCHAR(2),
PRIMARY KEY (Product, ProductCode)
);
GO

INSERT INTO #Products VALUES
('Alpha','01'),
('Alpha','02'),
('Bravo','03'),
('Bravo','04'),
('Charlie','02'),
('Delta','01'),
('Echo','EE'),
('Foxtrot','EE'),
('Gulf','GG');
GO

WITH cte_Duplicates AS
(
SELECT Product
FROM   #Products
GROUP BY Product
HAVING COUNT(*) >= 2
),
cte_ProductCodes AS
(
SELECT  ProductCode
FROM    #Products
WHERE   Product IN (SELECT Product FROM cte_Duplicates)
)
SELECT  DISTINCT ProductCode
FROM    #Products
WHERE   ProductCode NOT IN (SELECT ProductCode FROM cte_ProductCodes);
GO

/*----------------------------------------------------
DDL for Puzzle #61
Player Scores
*/----------------------------------------------------

DROP TABLE IF EXISTS #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
AttemptID  INTEGER,
PlayerID   INTEGER,
Score      INTEGER,
PRIMARY KEY (AttemptID, PlayerID)
);
GO

INSERT INTO #PlayerScores (AttemptID, PlayerID, Score) VALUES
(1,1001,2),(2,1001,7),(3,1001,8),(1,2002,6),(2,2002,9),(3,2002,7);
GO

WITH cte_FirstLastValues AS
(
SELECT  *
        ,FIRST_VALUE(Score) OVER (PARTITION BY PlayerID ORDER BY AttemptID) AS FirstValue
        ,LAST_VALUE(Score) OVER  (PARTITION BY PlayerID ORDER BY AttemptID
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LastValue
        ,LAG(Score,1,99999999) OVER (PARTITION BY PlayerID ORDER BY AttemptID) AS LagScore
        ,CASE WHEN Score - LAG(Score,1,0) OVER (PARTITION BY PlayerID ORDER BY AttemptID) > 0 THEN 1 ELSE 0 END AS IsImproved
FROM    #PlayerScores
)
SELECT
        AttemptID
       ,PlayerID
       ,Score
       ,Score - FirstValue AS Difference_First
       ,Score - LastValue AS Difference_Last
       ,IsImproved AS IsPreviousScoreLower
       ,MIN(IsImproved) OVER (PARTITION BY PlayerID) AS IsOverallImproved
FROM   cte_FirstLastValues;
GO

/*----------------------------------------------------
DDL for Puzzle #62
Car and Boat Purchase
*/----------------------------------------------------

DROP TABLE IF EXISTS #Vehicles;
GO

CREATE TABLE #Vehicles (
VehicleID  INTEGER PRIMARY KEY,
Type       VARCHAR(20),
Model      VARCHAR(20),
Price      MONEY
);
GO

INSERT INTO #Vehicles (VehicleID, Type, Model, Price) VALUES
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
DDL for Puzzle #63
Promotions
*/----------------------------------------------------

DROP TABLE IF EXISTS #Promotions;
GO

CREATE TABLE #Promotions (
OrderID   INTEGER NOT NULL,
Product   VARCHAR(255) NOT NULL,
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
(3, 'Item1', 'PROMO');
GO

SELECT OrderID
FROM   #Promotions
WHERE  Discount = ALL(SELECT 'PROMO')
GROUP BY OrderID
HAVING COUNT(DISTINCT Product) = 1;
GO

/*----------------------------------------------------
Answer to Puzzle #64
Between Quotes
*/----------------------------------------------------

DROP TABLE IF EXISTS #Strings;
GO

CREATE TABLE #Strings
(
ID  INTEGER IDENTITY(1,1),
String VARCHAR(256) NOT NULL
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

--Note that STRING_SPLIT does not guarantee order.  Use enable_oridinal if you need to order the output.
--The enable_ordinal argument and ordinal output column are currently supported in Azure SQL Database, Azure SQL Managed Instance, 
--and Azure Synapse Analytics (serverless SQL pool only). Beginning with SQL Server 2022 (16.x), the argument and output column are available in SQL Server.
WITH cte_Strings AS
(
SELECT  ID,
        String,
        (CASE WHEN LEN(String) - LEN(REPLACE(String,'"','')) <> 2 THEN 'Error' END) AS Result
FROM    #Strings
),
cte_StringSplit AS
(
SELECT  ROW_NUMBER() OVER (PARTITION BY String ORDER BY GETDATE()) AS RowNumber,
        *
FROM    cte_Strings CROSS APPLY
        STRING_SPLIT(String,'"')
)
SELECT  ID,
        String,
        (CASE WHEN LEN(Value) > 10 THEN 'True' ELSE 'False' END) AS Result
FROM    cte_StringSplit
WHERE   Result IS NULL AND 
        RowNumber = 2
UNION
SELECT  ID,
        String,
        Result
FROM    cte_Strings
WHERE  Result = 'Error'
ORDER BY 1;
GO

/*----------------------------------------------------
The End
*/----------------------------------------------------
