/*----------------------------------------------------
Scott Peters
https://advancedsqlpuzzles.com
*/----------------------------------------------------


/*----------------------------------------------------
Answer to Puzzle #1
Shopping Carts
*/----------------------------------------------------

DROP TABLE IF EXISTS #Cart1;
DROP TABLE IF EXISTS #Cart2;
GO

CREATE TABLE #Cart1
(Item VARCHAR(100) PRIMARY KEY
);
GO

CREATE TABLE #Cart2
(
Item VARCHAR(100) PRIMARY KEY
);
GO

INSERT INTO #Cart1 (Item) VALUES
('Sugar'),('Bread'),('Juice'),('Soda'),('Flour');
GO

INSERT INTO #Cart2 VALUES
('Sugar'),('Bread'),('Butter'),('Cheese'),('Fruit');
GO

SELECT  a.Item AS ItemCart1,
        b.Item AS ItemCart2
FROM    #Cart1 a FULL OUTER JOIN
        #Cart2 b ON a.Item = b.Item;

/*----------------------------------------------------
Answer to Puzzle #2
Managers and Employees
*/----------------------------------------------------

DROP TABLE IF EXISTS #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID  INTEGER PRIMARY KEY,
ManagerID   INTEGER,
JobTitle    VARCHAR(100),
Salary      INTEGER
);
GO

INSERT INTO #Employees VALUES
(1001,NULL,'President',185000),(2002,1001,'Director',120000),
(3003,1001,'Office Manager',97000),(4004,2002,'Engineer',110000),
(5005,2002,'Engineer',142000),(6006,2002,'Engineer',160000);
GO

--Recursion
WITH cte_Recursion AS
(
SELECT  EmployeeID, ManagerID, JobTitle, Salary, 0 AS Depth
FROM    #Employees a
WHERE   ManagerID IS NULL
UNION ALL
SELECT  b.EmployeeID, b.ManagerID, b.JobTitle, b.Salary, a.Depth + 1 AS Depth
FROM    cte_Recursion a INNER JOIN 
        #Employees b ON a.EmployeeID = b.ManagerID
)
SELECT  EmployeeID, ManagerID, JobTitle, Salary, Depth
FROM    cte_Recursion;

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

ALTER TABLE #EmployeePayRecords ALTER COLUMN EmployeeID INTEGER NOT NULL;
ALTER TABLE #EmployeePayRecords ALTER COLUMN FiscalYear INTEGER NOT NULL;
ALTER TABLE #EmployeePayRecords ALTER COLUMN StartDate DATE NOT NULL;
ALTER TABLE #EmployeePayRecords ALTER COLUMN EndDate DATE NOT NULL;
ALTER TABLE #EmployeePayRecords ALTER COLUMN PayRate MONEY NOT NULL;
GO
ALTER TABLE #EmployeePayRecords ADD CONSTRAINT PK_FiscalYearCalendar
                                    PRIMARY KEY (EmployeeID,FiscalYear);
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
GO
ALTER TABLE #EmployeePayRecords ADD CHECK (PayRate > 0);
GO

/*----------------------------------------------------
Answer to Puzzle #4
Two Predicates
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
CustomerID      INTEGER,
OrderID         VARCHAR(100),
DeliveryState   VARCHAR(100),
Amount          MONEY,
PRIMARY KEY (CustomerID, OrderID)
);
GO

INSERT INTO #Orders VALUES
(1001,'Ord936254','CA',340),(1001,'Ord143876','TX',950),(1001,'Ord654876','TX',670),
(1001,'Ord814356','TX',860),(2002,'Ord342176','WA',320),(3003,'Ord265789','CA',650),
(3003,'Ord387654','CA',830),(4004,'Ord476126','TX',120);
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

--Solution 2
--IN
WITH cte_CA AS
(
SELECT  CustomerID
FROM    #Orders
WHERE   DeliveryState = 'CA'
)
SELECT  CustomerID, OrderID, DeliveryState, Amount
FROM    #Orders
WHERE   DeliveryState = 'TX' AND
        CustomerID IN (SELECT b.CustomerID FROM cte_CA b);

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
PhoneNumber VARCHAR(12),
PRIMARY KEY (CustomerID, [Type])
);
GO

INSERT INTO #PhoneDirectory VALUES
(1001,'Cellular','555-897-5421'),
(1001,'Work','555-897-6542'),
(1001,'Home','555-698-9874'),
(2002,'Cellular','555-963-6544'),
(2002,'Work','555-812-9856'),
(3003,'Cellular','555-987-6541');
GO

--Solution 1
--PIVOT
SELECT CustomerID,[Cellular],[Work],[Home] FROM #PhoneDirectory
PIVOT (MAX(PhoneNumber) FOR [Type] IN ([Cellular],[Work],[Home])) AS PivotClause;

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
SELECT  a.CustomerID,b.Cellular,c.Work,d.Home
FROM    (SELECT DISTINCT CustomerID FROM #Phonedirectory) a LEFT OUTER JOIN
        cte_Cellular b ON a.CustomerID = b.CustomerID LEFT OUTER JOIN
        cte_Work c ON a.CustomerID = c.CustomerID LEFT OUTER JOIN
        cte_Home d ON a.CustomerID = d.CustomerID;

--Solution 3
--MAX
WITH cte_PhoneNumbers AS
(
SELECT  CustomerID,
        PhoneNumber AS Cellular,
        NULL AS work,
        NULL AS home
FROM    #PhoneDirectory
WHERE   [Type] = 'CellPhone'
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
CompletionDate  DATE,
PRIMARY KEY (Workflow, StepNumber)
);
GO

INSERT INTO #WorkflowSteps VALUES
('Alpha',1,'7/2/2018'),('Alpha',2,'7/2/2018'),('Alpha',3,'7/1/2018'),
('Bravo',1,'6/25/2018'),('Bravo',2,NULL),('Bravo',3,'6/27/2018'),
('Charlie',1,NULL),('Charlie',2,'7/1/2018');
GO

SELECT  Workflow
FROM    #WorkflowSteps
GROUP BY Workflow
HAVING  COUNT(*) <> COUNT(CompletionDate);

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

INSERT INTO #Candidates VALUES
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

WITH cte_RequirementsCount
AS
(
SELECT COUNT(*) AS RequirementCount FROM #Requirements
)
SELECT  CandidateID
FROM    #Candidates a INNER JOIN
        #Requirements b ON a.Occupation = b.Requirement
GROUP BY CandidateID
HAVING COUNT(*) = (SELECT RequirementCount FROM cte_RequirementsCount);

/*----------------------------------------------------
Answer to Puzzle #8
Workflow Cases
*/----------------------------------------------------

DROP TABLE IF EXISTS #WorkflowCases;
GO

CREATE TABLE #WorkflowCases
(
Workflow    VARCHAR(100) PRIMARY KEY,
Case1       INTEGER,
Case2       INTEGER,
Case3       INTEGER
);
GO

INSERT INTO #WorkflowCases VALUES
('Alpha',0,0,0),('Bravo',0,1,1),('Charlie',1,0,0),('Delta',0,0,0);
GO

WITH cte_PassFail AS
(
SELECT  Workflow, CaseNumber, PassFail
FROM    (
        SELECT Workflow,Case1,Case2,Case3
        FROM #WorkflowCases
        ) p
UNPIVOT (PassFail FOR CaseNumber IN (Case1,Case2,Case3)) AS UNPVT
)
SELECT  Workflow, SUM(PassFail) AS PassFail
FROM    cte_PassFail
GROUP BY Workflow
ORDER BY 1;

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

INSERT INTO #Employees VALUES
(1001,'Class A'),
(1001,'Class B'),
(1001,'Class C'),
(2002,'Class A'),
(2002,'Class B'),
(2002,'Class C'),
(3003,'Class A'),
(3003,'Class D');
GO

WITH cte_EmployeeCount AS
(
SELECT  EmployeeID,
        COUNT(*) AS LicenseCount
FROM    #Employees
GROUP BY EmployeeID
),
cte_EmployeeCountCombined AS
(
SELECT  a.EmployeeID AS EmployeeID,
        b.EmployeeID AS EmployeeID2,
        COUNT(*) AS LicenseCountCombo
FROM    #Employees a INNER JOIN
        #Employees b ON a.License = b.License
WHERE   a.EmployeeID <> b.EmployeeID
GROUP BY a.EmployeeID, b.EmployeeID
)
SELECT  a.EmployeeID, a.EmployeeID2, a.LicenseCountCombo
FROM    cte_EmployeeCountCombined a INNER JOIN
        cte_EmployeeCount b ON  a.LicenseCountCombo = b.LicenseCount AND
                                a.EmployeeID <> b.EmployeeID;

/*----------------------------------------------------
Answer to Puzzle #10
Mean, Median, Mode and Range
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue INTEGER
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
        ) * 1.0 /2 AS Median

--Mean and Range
SELECT  AVG(IntegerValue) AS Mean,
        MAX(IntegerValue) - MIN(IntegerValue) AS [Range]
FROM    #SampleData;

--Mode
SELECT  TOP 1
        IntegerValue AS Mode,
        COUNT(*) AS ModeCount
FROM    #SampleData
GROUP BY IntegerValue
ORDER BY ModeCount DESC;

/*----------------------------------------------------
Answer to Puzzle #11
*/----------------------------------------------------

DROP TABLE IF EXISTS #TestCases;
GO

CREATE TABLE #TestCases
(
RowNumber INTEGER,
TestCase VARCHAR(1),
PRIMARY KEY (RowNumber, TestCase)
);
GO

INSERT INTO #TestCases VALUES
(1,'A'),(2,'B'),(3,'C');
GO

DECLARE @vTotalElements INTEGER = (SELECT COUNT(*) FROM #TestCases);

--Recursion
WITH cte_Permutations (Permutation, Ids, Depth)
AS
(
SELECT  CAST(TestCase AS VARCHAR(MAX)),
        CONCAT(CAST(RowNumber AS VARCHAR(MAX)),';'),
        1 AS Depth
FROM    #TestCases
UNION ALL
SELECT  CONCAT(a.Permutation,',',b.TestCase),
        CONCAT(a.Ids,b.RowNumber,';'),
        a.Depth + 1
FROM    cte_Permutations a,
        #TestCases b
WHERE   a.Depth < @vTotalElements AND
        a.Ids NOT LIKE CONCAT('%',b.RowNumber,';%')
)
SELECT  Permutation
FROM    cte_Permutations
WHERE   Depth = @vTotalElements;

/*----------------------------------------------------
Answer to Puzzle #12
Average Days
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
WorkFlow        VARCHAR(100),
ExecutionDate   DATE,
PRIMARY KEY (WorkFlow, ExecutionDate)
);
GO

INSERT INTO #ProcessLog VALUES
('Alpha','6/01/2018'),('Alpha','6/14/2018'),('Alpha','6/15/2018'),
('Bravo','6/1/2018'),('Bravo','6/2/2018'),('Bravo','6/19/2018'),
('Charlie','6/1/2018'),('Charlie','6/15/2018'),('Charlie','6/30/2018');
GO

WITH cte_DayDiff AS
(
SELECT  WorkFlow,
        (DATEDIFF(DD,LAG(ExecutionDate,1,NULL) OVER
                (PARTITION BY WorkFlow ORDER BY ExecutionDate),ExecutionDate)) AS DateDifference
FROM    #ProcessLog
)
SELECT  WorkFlow, AVG(DateDifference)
FROM    cte_DayDiff
WHERE   DateDifference IS NOT NULL
GROUP BY Workflow;

/*----------------------------------------------------
Answer to Puzzle #13
Inventory Tracking
*/----------------------------------------------------

DROP TABLE IF EXISTS #Inventory;
GO

CREATE TABLE #Inventory
(
InventoryDate       DATE PRIMARY KEY,
QuantityAdjustment  INTEGER
);
GO

INSERT INTO #Inventory VALUES
('7/1/2018',100),('7/2/2018',75),('7/3/2018',-150),
('7/4/2018',50),('7/5/2018',-75);
GO

SELECT  InventoryDate,
        QuantityAdjustment,
        SUM(QuantityAdjustment) OVER (ORDER BY InventoryDate)
FROM    #Inventory;


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
[Status]    VARCHAR(100),
PRIMARY KEY (Workflow, StepNumber)
);
GO

INSERT INTO #ProcessLog VALUES
('Alpha',1,'Error'),('Alpha',2,'Complete'),('Bravo',1,'Complete'),('Bravo',2,'Complete'),
('Charlie',1,'Complete'),('Charlie',2,'Error'),('Delta',1,'Complete'),('Delta',2,'Running'),
('Echo',1,'Running'),('Echo',2,'Error'),('Foxtrot',1,'Error'),('Foxtrot',2,'Error');
GO

--Create a StatusRank table to solve the problem
DROP TABLE IF EXISTS #StatusRank;
GO

CREATE TABLE #StatusRank
(
[Status]    VARCHAR(100),
[Rank]      INTEGER,
PRIMARY KEY ([Status], [Rank])
);
GO

INSERT INTO #StatusRank VALUES
('Error',1),
('Running',2),
('Complete',3);
GO

WITH cte_CountExistsError AS
(
SELECT  Workflow, COUNT(DISTINCT [Status]) AS DistinctCount
FROM    #ProcessLog a
WHERE   EXISTS  (SELECT 1
                FROM    #ProcessLog b
                WHERE   [Status] = 'Error' AND a.Workflow = b.Workflow)
GROUP BY Workflow
),
cte_ErrorWorkflows AS
(
SELECT  a.Workflow,
        (CASE WHEN DistinctCount > 1 THEN 'Indeterminate' ELSE a.[Status] END) AS [Status]
FROM    #ProcessLog a INNER JOIN
        cte_CountExistsError b ON a.WorkFlow = b.WorkFlow
GROUP BY a.WorkFlow, (CASE WHEN DistinctCount > 1 THEN 'Indeterminate' ELSE a.[Status] END)
)
SELECT  DISTINCT
        a.Workflow,
        FIRST_VALUE(a.[Status]) OVER (PARTITION  BY a.Workflow ORDER BY b.[Rank]) AS [Status]
FROM    #ProcessLog a INNER JOIN
        #StatusRank b ON a.[Status] = b.[Status]
WHERE   a.Workflow NOT IN (SELECT Workflow FROM cte_ErrorWorkflows)
UNION
SELECT  Workflow,
        [Status]
FROM    cte_ErrorWorkflows
ORDER BY a.Workflow;

/*----------------------------------------------------
Answer to Puzzle #15
Group Concatenation
*/----------------------------------------------------

DROP TABLE IF EXISTS #DMLTable;
GO

CREATE TABLE #DMLTable
(
SequenceNumber  INTEGER PRIMARY KEY,
String          VARCHAR(100)
);
GO

INSERT INTO #DMLTable VALUES
(1,'SELECT'),
(5,'FROM'),
(7,'WHERE'),
(2,'Product'),
(6,'Products'),
(3,'UnitPrice'),
(9,'> 100'),
(4,'EffectiveDate'),
(8,'UnitPrice');
GO

--Solution 1
--STRING_AGG
SELECT  
        STRING_AGG(CONVERT(NVARCHAR(max),String), ' ')
FROM    #DMLTable;

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

--Solution 3
--XML Path
SELECT DISTINCT
        STUFF((
            SELECT  CAST(' ' AS VARCHAR(MAX)) + String
            FROM    #DMLTable U
            ORDER BY SequenceNumber
        FOR XML PATH('')), 1, 1, '') AS DML_String
FROM    #DMLTable;

/*----------------------------------------------------
Answer to Puzzle #16
Reciprocals
*/----------------------------------------------------

DROP TABLE IF EXISTS #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
PlayerA INTEGER,
PlayerB INTEGER,
Score   INTEGER,
PRIMARY KEY (PlayerA, PlayerB)
);
GO

INSERT INTO #PlayerScores VALUES
(1001,2002,150),(3003,4004,15),
(4004,3003,125),(4004,1001,125);
GO

--The functions LEAST and GREATEST are available if using and Azure SQL Database, Azure SQL Managed Instance,
--or Azure Synapse Analytics (serverless SQL pool only)
SELECT  a.PlayerA, a.PlayerB, SUM(Score)
FROM    (
        SELECT
                (CASE WHEN PlayerA <= PlayerB THEN PlayerA ELSE PlayerB END) PlayerA,
                (CASE WHEN PlayerA <= PlayerB THEN PlayerB ELSE PlayerA END) PlayerB,
                Score
        FROM    #PlayerScores 
        ) a
GROUP BY PlayerA, PlayerB;

/*----------------------------------------------------
Answer to Puzzle #17
De-Grouping
*/----------------------------------------------------

DROP TABLE IF EXISTS #Ungroup;
GO

CREATE TABLE #Ungroup
(
ProductDescription  VARCHAR(100) PRIMARY KEY,
Quantity            INTEGER
);
GO

INSERT INTO #Ungroup VALUES
('Eraser',3),('Pencil',4),('Sharpener',2);
GO

--Numbers Table
DROP TABLE IF EXISTS #Numbers;
GO

CREATE TABLE #Numbers
(
IntegerValue    INTEGER IDENTITY(1,1),
RowID           UNIQUEIDENTIFIER
);
GO

INSERT INTO #Numbers VALUES (NEWID());
GO 1000

SELECT  a.ProductDescription, 1 AS Quantity
FROM    #Ungroup a CROSS JOIN
        #Numbers b
WHERE   a.Quantity >= b. IntegerValue;

/*----------------------------------------------------
Answer to Puzzle #18
Seating Chart
*/----------------------------------------------------

DROP TABLE IF EXISTS #SeatingChart;
GO

CREATE TABLE #SeatingChart
(
SeatNumber INTEGER PRIMARY KEY
);
GO

INSERT INTO #SeatingChart VALUES
(7),(13),(14),(15),(27),(28),(29),(30),(31),(32),(33),(34),(35),(52),(53),(54);
GO

--Place a value of 0 in the SeatingChart table
INSERT INTO #SeatingChart VALUES (0);
GO

--Gap start and gap end
SELECT  GapStart + 1 AS GapStart,
        GapEnd - 1 AS GapEnd
FROM
    (
    SELECT  SeatNumber AS GapStart,
        LEAD(SeatNumber,1,0) OVER (ORDER BY SeatNumber) AS GapEnd,
        LEAD(SeatNumber,1,0) OVER (ORDER BY SeatNumber) - SeatNumber AS Gap
    FROM #SeatingChart
    ) a
WHERE Gap > 1;

--Missing Numbers
WITH cte_Rank
AS
(
SELECT  SeatNumber,
        ROW_NUMBER() OVER (ORDER BY SeatNumber) AS RowNumber,
        SeatNumber - ROW_NUMBER() OVER (ORDER BY SeatNumber) AS Rnk
FROM    #SeatingChart
WHERE   SeatNumber > 0
)
SELECT MAX(Rnk) AS MissingNumbers FROM cte_Rank;

--Odd and even number count
SELECT  (CASE SeatNumber%2 WHEN 1 THEN 'Odd' WHEN 0 THEN 'Even' END) AS Modulus,
        COUNT(*) AS [Count]
FROM    #SeatingChart
GROUP BY (CASE SeatNumber%2 WHEN 1 THEN 'Odd' WHEN 0 THEN 'Even' END);

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
StartDate   DATE,
EndDate     DATE
);
GO

INSERT INTO #TimePeriods VALUES
('1/1/2018','1/5/2018'),('1/1/2018','1/3/2018'),
('1/1/2018','1/2/2018'),('1/3/2018','1/9/2018'),
('1/10/2018','1/11/2018'),('1/12/2018','1/16/2018'),
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
GROUP BY a.StartDate
GO

--Results
SELECT  MIN(StartDate) AS StartDate,
        MAX(MinEndDate_A) AS EndDate
FROM    #DetermineValidEndDates2
GROUP BY MinEndDate_A;

/*----------------------------------------------------
Answer to Puzzle #20
Price Points
*/----------------------------------------------------

DROP TABLE IF EXISTS #ValidPrices;
GO

CREATE TABLE #ValidPrices
(
ProductID       INTEGER,
UnitPrice       MONEY,
EffectiveDate   DATE,
PRIMARY KEY (ProductID, UnitPrice, EffectiveDate)
);
GO

INSERT INTO #ValidPrices VALUES
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
WHERE NOT EXISTS (SELECT    1
                  FROM      #Validprices AS ppl
                  WHERE     ppl.ProductID = pp.ProductID AND
                            ppl.EffectiveDate > pp.EffectiveDate);

--Solution 2
--RANK
WITH cte_validprices AS
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

/*----------------------------------------------------
Answer to Puzzle #21
Average Monthly Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     VARCHAR(100) PRIMARY KEY,
CustomerID  INTEGER,
OrderDate   DATE,
Amount      MONEY,
[State]     VARCHAR(2)
);
GO

INSERT INTO #Orders VALUES
('Ord145332',1001,'1/1/2018',100,'TX'),
('Ord657895',1001,'1/1/2018',150,'TX'),
('Ord887612',1001,'1/1/2018',75,'TX'),
('Ord654374',1001,'2/1/2018',100,'TX'),
('Ord345362',1001,'3/1/2018',100,'TX'),
('Ord912376',2002,'2/1/2018',75,'TX'),
('Ord543219',2002,'2/1/2018',150,'TX'),
('Ord156357',3003,'1/1/2018',100,'IA'),
('Ord956541',3003,'2/1/2018',100,'IA'),
('Ord856993',3003,'3/1/2018',100,'IA'),
('Ord864573',4004,'4/1/2018',100,'IA'),
('Ord654525',4004,'5/1/2018',50,'IA'),
('Ord987654',4004,'5/1/2018',100,'IA');
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

/*----------------------------------------------------
Answer to Puzzle #22
Occurrences
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow    VARCHAR(100),
LogMessage  VARCHAR(100),
Occurrences INTEGER,
PRIMARY KEY (Workflow, LogMessage)
);
GO

INSERT INTO #ProcessLog VALUES
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

/*----------------------------------------------------
Answer to Puzzle #23
Divide in Half
*/----------------------------------------------------

DROP TABLE IF EXISTS #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
PlayerID    INTEGER PRIMARY KEY,
Score       INTEGER
);
GO

INSERT INTO #PlayerScores VALUES
(1001,2343),(2002,9432),
(3003,6548),(4004,1054),
(5005,6832);
GO

SELECT  NTILE(2) OVER (ORDER BY Score DESC) as Quartile,
        PlayerID,
        Score
FROM    #PlayerScores a
ORDER BY Score DESC;

/*----------------------------------------------------
Answer to Puzzle #24
Page Views
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue    INTEGER IDENTITY(1,1),
RowID           UNIQUEIDENTIFIER
);
GO

ALTER TABLE #SampleData DROP COLUMN IntegerValue;
GO

INSERT INTO #SampleData VALUES (NEWID());
GO 1000

SELECT  RowID
FROM    #SampleData
ORDER BY RowID
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

/*----------------------------------------------------
Answer to Puzzle #25
Top Vendors
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     VARCHAR(100) PRIMARY KEY,
CustomerID  INTEGER,
OrderCount  MONEY,
Vendor      VARCHAR(100)
);
GO

INSERT INTO #Orders VALUES
('Ord195342',1001,12,'Direct Parts'),
('Ord245532',1001,54,'Direct Parts'),
('Ord344394',1001,32,'ACME'),
('Ord442423',2002,7,'ACME'),
('Ord524232',2002,16,'ACME'),
('Ord645363',2002,5,'Direct Parts');
GO

WITH cte_Rank AS
(
SELECT  CustomerID,
        Vendor,
        RANK() OVER (PARTITION BY CustomerID ORDER BY COUNT(OrderCount) DESC) AS Rnk
FROM    #Orders
GROUP BY CustomerID, Vendor
)
SELECT  DISTINCT b.CustomerID, b.Vendor
FROM    #Orders a INNER JOIN
        cte_Rank b ON a.CustomerID = b.CustomerID AND a.Vendor = b.Vendor
WHERE   Rnk = 1;

/*----------------------------------------------------
Answer to Puzzle #26
Previous Years Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Sales;
GO

CREATE TABLE #Sales
(
[Year]  INTEGER,
Amount  INTEGER
);
GO

INSERT INTO #Sales VALUES
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
IntegerValue INTEGER,
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
*/----------------------------------------------------

/*
Here is an excellent post about this problem.
https://www.red-gate.com/simple-talk/sql/t-sql-programming/filling-in-missing-values-using-the-t-sql-window-frame/
*/

DROP TABLE IF EXISTS #Gaps;
DROP TABLE IF EXISTS #Gaps2;
GO

CREATE TABLE #Gaps
(
RowNumber   INTEGER PRIMARY KEY,
TestCase    VARCHAR(100)
);
GO

INSERT INTO #Gaps VALUES
(1,'Alpha'),(2,NULL),(3,NULL),(4,NULL),
(5,'Bravo'),(6,NULL),(7,'Charlie'),(8,NULL),(9,NULL);
GO

SELECT * INTO #Gaps2 FROM #Gaps;
GO

--Solution 1
--SELECT within a SELECT with a Correlated Subquery
SELECT  a.RowNumber,
        (SELECT b.TestCase
        FROM    #Gaps b
        WHERE   b.RowNumber =
                    (SELECT MAX(c.RowNumber)
                    FROM #Gaps c
                    WHERE c.RowNumber <= a.RowNumber AND c.TestCase != '')) TestCase
FROM #Gaps a;

--Solution 2
--MAX
SELECT  RowNumber,
        MAX(TestCase) OVER (PARTITION BY DistinctCount) AS TestCase
FROM    (SELECT RowNumber,
                TestCase,
                COUNT(TestCase) OVER (ORDER BY RowNumber) AS DistinctCount
        FROM #Gaps) a
ORDER BY RowNumber;

--Solution 3
--This type of update is called a "quirky update"
--https://ask.sqlservercentral.com/questions/5150/please-can-somebody-explain-how-quirky-updates-wor.html
--There is no guarantee that this UPDATE will always produce the correct result.  You must have another 
--method to validate the results.
BEGIN
    DECLARE @v VARCHAR(MAX);
    UPDATE  #Gaps2
    SET     @v = TestCase = (CASE WHEN TestCase IS NULL THEN @v ELSE TestCase END)
END
GO

SELECT * FROM #Gaps2;

/*----------------------------------------------------
Answer to Puzzle #29
Count the Groupings
*/----------------------------------------------------
DROP TABLE IF EXISTS #Groupings;
DROP TABLE IF EXISTS #Groupings2;
GO

CREATE TABLE #Groupings
(
StepNumber  INTEGER PRIMARY KEY,
TestCase    VARCHAR(100),
[Status]    VARCHAR(100)
);
GO

INSERT INTO #Groupings VALUES
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

SELECT  StepNumber,
        [Status],
        StepNumber - ROW_NUMBER() OVER (PARTITION BY [Status] ORDER BY StepNumber) AS Rnk
INTO    #Groupings2
FROM    #Groupings
ORDER BY 2;
GO

SELECT  MIN(StepNumber) AS MinStepNumber,
        MAX(StepNumber) as MaxStepNumber,
        [Status],
        MAX(StepNumber) - MIN(StepNumber) + 1 AS ConsecutiveCount
FROM    #Groupings2
GROUP BY Rnk,
        [Status]
ORDER BY 1, 2;

/*----------------------------------------------------
Answer to Puzzle #30
Select Star
*/----------------------------------------------------

DROP TABLE IF EXISTS #Products;
GO

CREATE TABLE #Products
(
ProductID   INTEGER PRIMARY KEY,
ProductName VARCHAR(100)
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
IntegerValue INTEGER PRIMARY KEY
);
GO

INSERT INTO #SampleData VALUES
(3759),(3760),(3761),(3762),(3763);
GO

--Solution 1
--Correlated Subquery
SELECT  IntegerValue
FROM    #SampleData a
WHERE   2 = (SELECT COUNT(IntegerValue)
            FROM    #SampleData b
            WHERE   a.IntegerValue <= b.IntegerValue);

--Solution 2
--OFFSET
SELECT  IntegerValue
FROM    #SampleData a
ORDER BY IntegerValue DESC
OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY;

--Solution 3
--MAX
SELECT  MAX(IntegerValue)
FROM    #SampleData
WHERE   IntegerValue < (SELECT MAX(IntegerValue) FROM #SampleData);

--Solution 4
--TOP
WITH cte_Top2 AS
(
SELECT  TOP(2) IntegerValue
FROM    #SampleData
ORDER BY IntegerValue DESC
)
SELECT  MIN(IntegerValue) FROM cte_Top2;

/*----------------------------------------------------
Answer to Puzzle #32
First and Last
*/----------------------------------------------------

DROP TABLE IF EXISTS #Personel;
GO

CREATE TABLE #Personel
(
SpacemanID      INTEGER PRIMARY KEY,
JobDescription  VARCHAR(100),
MissionCount    INTEGER
);
GO

INSERT INTO #Personel VALUES
(1001,'Astrogator',6),(2002,'Astrogator',12),(3003,'Astrogator',17),
(4004,'Geologist',21),(5005,'Geologist',9),(6006,'Geologist',8),
(7007,'Technician',13),(8008,'Technician',2),(9009,'Technician',7);
GO

SELECT  DISTINCT
        JobDescription,
        FIRST_VALUE(SpacemanID) OVER
            (PARTITION  BY JobDescription ORDER BY MissionCount DESC) AS MostExperienced,
        LAST_VALUE(SpacemanID)  OVER 
            (PARTITION  BY JobDescription ORDER BY MissionCount DESC
            RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS LeastExperienced
FROM    #Personel
ORDER BY 1,2,3;

/*----------------------------------------------------
Answer to Puzzle #33
Deadlines
*/----------------------------------------------------

DROP TABLE IF EXISTS #OrderFulfillments;
DROP TABLE IF EXISTS #ManufacturingTimes;
GO

CREATE TABLE #OrderFulfillments
(
OrderID     VARCHAR(100) PRIMARY KEY,
ProductID   VARCHAR(100),
DaysToBuild INTEGER
);
GO

CREATE TABLE #ManufacturingTimes
(
PartID              VARCHAR(100),
ProductID           VARCHAR(100),
DaysToManufacture   INTEGER,
PRIMARY KEY (PartID, ProductID)
);
GO

INSERT INTO #OrderFulfillments VALUES
('Ord893456','Widget',7),
('Ord923654','Gizmo',3),
('Ord187239','Doodad',9);
GO

INSERT INTO #ManufacturingTimes VALUES
('AA-111','Widget',7),
('BB-222','Widget',2),
('CC-333','Widget',3),
('DD-444','Widget',1),
('AA-111','Gizmo',7),
('BB-222','Gizmo',2),
('AA-111','Doodad',7),
('DD-444','Doodad',1);
GO

--Solution 1
--MAX
WITH cte_Max AS
(
SELECT  ProductID, MAX(DaysToManufacture) AS MaxDaysToManufacture
FROM    #ManufacturingTimes b
GROUP BY ProductID
)
SELECT  a.*
FROM    #OrderFulfillments a INNER JOIN
        cte_Max b ON a.ProductID = b.ProductID AND a.DaysToBuild >= b.MaxDaysToManufacture

--Solution 2
--ALL
SELECT  a.*
FROM    #OrderFulfillments a
WHERE   DaysToBuild >= ALL( SELECT  DaysToManufacture 
                            FROM    #ManufacturingTimes b 
                            WHERE   a.ProductID = b.ProductID);

/*----------------------------------------------------
Answer to Puzzle #34
Specific Exclusion
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     VARCHAR(100) PRIMARY KEY,
CustomerID  INTEGER,
Amount      MONEY
);
GO

INSERT INTO #Orders VALUES
('Ord143937',1001,25),('Ord789765',1001,50),
('Ord345434',2002,65),('Ord465633',3003,50);
GO

SELECT  OrderID,CustomerID, Amount
FROM    #Orders
WHERE   NOT(CustomerID = 1001 AND OrderID = 'Ord789765');

/*----------------------------------------------------
Answer to Puzzle #35
International vs Domestic Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
InvoiceID   VARCHAR(100) PRIMARY KEY,
SalesRepID  INTEGER,
Amount      MONEY,
SalesType   VARCHAR(100)
);
GO

INSERT INTO #Orders VALUES
('Inv345756',1001,13454,'International'),
('Inv546744',2002,3434,'International'),
('Inv234745',4004,54645,'International'),
('Inv895745',5005,234345,'International'),
('Inv006321',7007,776,'International'),
('Inv734534',1001,4564,'Domestic'),
('Inv600213',2002,34534,'Domestic'),
('Inv757853',3003,345,'Domestic'),
('Inv198632',6006,6543,'Domestic'),
('Inv977654',8008,67,'Domestic');
GO

WITH cte_Domestic AS
(
SELECT  InvoiceID,
        SalesRepID
FROM    #Orders
WHERE   SalesType = 'Domestic'
),
cte_International AS
(
SELECT  InvoiceID,
        SalesRepID
FROM    #Orders
WHERE   SalesType = 'International'
)
SELECT  ISNULL(a.SalesRepID,b.SalesRepID)
FROM    cte_Domestic a FULL OUTER JOIN
        cte_International b ON a.SalesRepID = b.SalesRepID
WHERE   a.InvoiceID IS NULL OR b.InvoiceID IS NULL;

/*----------------------------------------------------
Answer to Puzzle #36
Traveling Salesman

The Traveling Salesman is a popular puzzle in optimization.
https://en.wikipedia.org/wiki/Travelling_salesman_problem

For this puzzle, I solve it by hardcoding the number of connections to 4.
You may wish to use recursion and set a maximum number of recursions, as
their is the possibility of the traveling salesman traveling back and forth 
between the same cities.

Alternatively, you could try and solve it with the rule that the traveling
salesman cannot visit each city twice.
----
Tags:
Recursion
UNION ALL
*/----------------------------------------------------

DROP TABLE IF EXISTS #Graph;
GO

CREATE TABLE #Graph
(
DepartureCity   VARCHAR(100),
ArrivalCity     VARCHAR(100),
Cost            INTEGER,
PRIMARY KEY (DepartureCity, ArrivalCity)
);
GO

INSERT INTO #Graph VALUES
('Austin','Dallas',100),
('Dallas','Austin',150),
('Dallas','Memphis',200),
('Memphis','Des Moines',300),
('Dallas','Des Moines',400);
GO

--Making the assumption the maximum number of layovers is four
WITH cte_Graph AS
(
SELECT DepartureCity, ArrivalCity, Cost FROM #Graph
UNION ALL
SELECT ArrivalCity, DepartureCity, Cost FROM #Graph
UNION ALL
SELECT ArrivalCity, ArrivalCity, 0 FROM #Graph
UNION ALL
SELECT DepartureCity, DepartureCity, 0 FROM #Graph
)
SELECT  DISTINCT
        g1.DepartureCity,
        g2.DepartureCity,
        g3.DepartureCity,
        g4.DepartureCity,
        g4.ArrivalCity,
        (g1.Cost + g2.Cost + g3.Cost + g4.Cost) AS TotalCost
FROM    cte_Graph AS g1 INNER JOIN
        cte_Graph AS g2 ON g1.ArrivalCity = g2.DepartureCity INNER JOIN
        cte_Graph AS g3 ON g2.ArrivalCity = g3.DepartureCity INNER JOIN
        cte_Graph AS g4 ON g3.ArrivalCity = g4.DepartureCity
WHERE   g1.DepartureCity = 'Austin' AND
        g4.ArrivalCity = 'Des Moines'
ORDER BY 6,1,2,3,4;

/*----------------------------------------------------
Answer to Puzzle #37
Group Criteria Keys
*/----------------------------------------------------

DROP TABLE IF EXISTS #GroupCriteria;
GO

CREATE TABLE #GroupCriteria
(
OrderID     VARCHAR(100) PRIMARY KEY,
Distributor VARCHAR(100),
Facility    INTEGER,
[Zone]      VARCHAR(100),
Amount      MONEY
);
GO

INSERT INTO #GroupCriteria VALUES
('Ord156795','ACME',123,'ABC',100),
('Ord826109','ACME',123,'ABC',75),
('Ord342876','Direct Parts',789,'XYZ',150),
('Ord994981','Direct Parts',789,'XYZ',125);
GO

SELECT  DENSE_RANK() OVER (ORDER BY Distributor, Facility, [Zone]) AS CriteriaID,
        OrderID,
        Distributor,
        Facility,
        [Zone],
        Amount
FROM    #GroupCriteria;

/*----------------------------------------------------
Answer to Puzzle #38
Reporting Elements
*/----------------------------------------------------

DROP TABLE IF EXISTS #RegionSales;
GO

CREATE TABLE #RegionSales
(
Region      VARCHAR(100),
Distributor VARCHAR(100),
Sales       INTEGER,
PRIMARY KEY (Region, Distributor)
);
GO

INSERT INTO #RegionSales VALUES
('North','ACE',10),
('South','ACE',67),
('East','ACE',54),
('North','Direct Parts',8),
('South','Direct Parts',7),
('West','Direct Parts',12),
('North','ACME',65),
('South','ACME',9),
('East','ACME',1),
('West','ACME',7);
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
SELECT  a.Region, a.Distributor, ISNULL(b.Sales,0) AS Sales
FROM    cte_CrossJoin a LEFT OUTER JOIN
        #RegionSales b ON a.Region = b.Region and a.Distributor = b.Distributor
ORDER BY a.Distributor,
        (CASE a.Region  WHEN 'North' THEN 1
                        WHEN 'South' THEN 2
                        WHEN 'East'  THEN 3
                        WHEN 'West'  THEN 4 END);

/*----------------------------------------------------
Answer to Puzzle #39
Prime Numbers
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue INTEGER PRIMARY KEY
);
GO

INSERT INTO #SampleData VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);
GO

SELECT  IntegerValue,
        IntegerValue%2,
        (CASE WHEN IntegerValue%2 > 0 OR IntegerValue <= 2 THEN 'Prime Number' ELSE NULL END) AS PrimeNumber
FROM    #SampleData;

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

INSERT INTO #SortOrder VALUES
('Atlanta'),('Baltimore'),('Chicago'),('Denver');
GO

SELECT  City
FROM    #SortOrder
ORDER BY (CASE City WHEN 'Atlanta' THEN 2 WHEN 'Baltimore' THEN 1 WHEN 'Chicago' THEN 4 WHEN 'Denver' THEN 1 END);

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
Associate1 VARCHAR(100),
Associate2 VARCHAR(100),
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
SELECT  *
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

/*----------------------------------------------------
Answer to Puzzle #42
Mutual Friends
*/----------------------------------------------------

DROP TABLE IF EXISTS #Friends;
DROP TABLE IF EXISTS #Distinct_Friends_Full_1;
DROP TABLE IF EXISTS #Mutual_Friend_Check_2;
DROP TABLE IF EXISTS #Reciprocal_Mutual_Friend_Check_3;
DROP TABLE IF EXISTS #Reciprocal_Mutual_Friend_Check_Count_4;
DROP TABLE IF EXISTS #Reciprocal_Mutual_Friend_Check_Count_Modified_5;
GO

CREATE TABLE #Friends
(
Friend1 VARCHAR(100),
Friend2 VARCHAR(100),
PRIMARY KEY (Friend1, Friend2)
);
GO

INSERT INTO #Friends VALUES 
('Jason','Mary'),('Mike','Mary'),('Mike','Jason'),
('Susan','Jason'),('John','Mary'),('Susan','Mary')
GO

--Step 1
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
FROM    cte_Reciprocal_Friends
ORDER BY 1,2;
GO

--Step 2
SELECT  a.*,
        b.Friend2 AS Mutual_Friend_Check
INTO    #Mutual_Friend_Check_2
FROM    #Distinct_Friends_Full_1 a INNER JOIN
        #Distinct_Friends_Full_1 b ON a.Friend2 = b.Friend1
WHERE   a.Friend1 <> b.Friend2
ORDER BY 1,2;
GO

--Step 3
SELECT  (CASE WHEN Friend1 < Friend2 THEN Friend1 ELSE Friend2 END) AS Friend1,
        (CASE WHEN Friend1 < Friend2 THEN Friend2 ELSE Friend1 END) AS Friend2,
        a.Mutual_Friend_Check
INTO    #Reciprocal_Mutual_Friend_Check_3
FROM    #Mutual_Friend_Check_2 a;
GO

--Step 4
SELECT  Friend1,
        Friend2,
        Mutual_Friend_Check,
        COUNT(*) AS Grouping_Count
INTO    #Reciprocal_Mutual_Friend_Check_Count_4
FROM    #Reciprocal_Mutual_Friend_Check_3
GROUP BY Friend1, Friend2, Mutual_Friend_Check;
GO

--Step 5
SELECT  Friend1,
        Friend2,
        Mutual_Friend_Check,
        (CASE Grouping_Count WHEN 1 THEN 0 WHEN 2 THEN 1 END) AS Friend_Count
INTO    #Reciprocal_Mutual_Friend_Check_Count_Modified_5
FROM    #Reciprocal_Mutual_Friend_Check_Count_4
GO

--Results
SELECT  Friend1,
        Friend2,
        SUM(Friend_Count) AS Total_Mutual_Friends
FROM    #Reciprocal_Mutual_Friend_Check_Count_Modified_5
GROUP BY Friend1, Friend2
ORDER BY 1,2;

/*----------------------------------------------------
Answer to Puzzle #43
Unbounded Preceding
*/----------------------------------------------------

DROP TABLE IF EXISTS #CustomerOrders;
GO

CREATE TABLE #CustomerOrders
(
[Order] INTEGER,
CustomerID INTEGER,
Quantity INTEGER,
PRIMARY KEY ([Order], CustomerID)
);
GO

INSERT INTO #CustomerOrders VALUES (1,1001,5);
INSERT INTO #CustomerOrders VALUES (2,1001,8);
INSERT INTO #CustomerOrders VALUES (3,1001,3);
INSERT INTO #CustomerOrders VALUES (4,1001,7);
INSERT INTO #CustomerOrders VALUES (1,2002,4);
INSERT INTO #CustomerOrders VALUES (2,2002,9);
GO

SELECT  [Order],
        CustomerID,
        Quantity,
        MIN(Quantity) OVER (PARTITION by CustomerID ORDER BY [Order]
                ROWS UNBOUNDED PRECEDING) AS MinQuantity
FROM    #CustomerOrders;

/*----------------------------------------------------
Answer to Puzzle #44
Slowly Changing Dimension Part I
*/----------------------------------------------------

DROP TABLE IF EXISTS #Balances;
GO

CREATE TABLE #Balances
(
CustomerID INTEGER,
BalanceDate DATE,
Amount MONEY,
PRIMARY KEY (CustomerID, BalanceDate)
);
GO

INSERT INTO #Balances VALUES
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

/*----------------------------------------------------
Answer to Puzzle #45
Slowly Changing Dimension Part 2
*/----------------------------------------------------

DROP TABLE IF EXISTS #Balances;
GO

CREATE TABLE #Balances
(
CustomerID INTEGER,
StartDate DATE,
EndDate DATE,
Amount MONEY
);
GO

INSERT INTO #Balances VALUES
(1001,'10/11/2021','12/31/9999',54.32),
(1001,'10/10/2021','10/10/2021',17.65),
(1001,'9/18/2021','10/12/2021',65.56),
(2002,'9/12/2021','9/17/2021',56.23),
(2002,'9/1/2021','9/17/2021',42.12),
(2002,'8/15/2021','8/31/2021',16.32);
GO

WITH cte_Lag AS
(
SELECT  *,
        LAG(StartDate) OVER 
            (PARTITION BY CustomerID ORDER BY StartDate DESC) AS StartDate_Lag
FROM    #Balances
)
SELECT  *
FROM    cte_Lag
WHERE   EndDate >= StartDate_Lag
ORDER BY CustomerID, StartDate DESC;

/*----------------------------------------------------
Answer to Puzzle #46
Positive Account Balances
*/----------------------------------------------------

DROP TABLE IF EXISTS #AccountBalances;
GO

CREATE TABLE #AccountBalances
(
AccountID   INTEGER,
Balance     MONEY,
PRIMARY KEY (AccountID, Balance)
);
GO

INSERT INTO #AccountBalances VALUES
(1001,234.45),(1001,-23.12),(2002,-93.01),(2002,-120.19),
(3003,186.76), (3003,90.23), (3003,10.11);
GO

--Solution 1
--SET Operators
SELECT DISTINCT AccountID FROM #AccountBalances WHERE Balance < 0
EXCEPT
SELECT DISTINCT AccountID FROM #AccountBalances WHERE Balance > 0;

--Solution 2
--MAX
SELECT  AccountID
FROM    #AccountBalances
GROUP BY AccountID
HAVING  MAX(Balance) < 0;

--Solution 3
--NOT IN
SELECT  DISTINCT AccountID
FROM    #AccountBalances
WHERE   AccountID NOT IN (SELECT AccountID FROM #AccountBalances WHERE Balance > 0);

--Solution 4
--NOT EXISTS
SELECT  DISTINCT AccountID
FROM    #AccountBalances a
WHERE   NOT EXISTS (SELECT AccountID FROM #AccountBalances b WHERE Balance > 0 AND a.AccountID = b.AccountID);

--Solution 5
--LEFT OUTER JOIN
SELECT  DISTINCT a.AccountID
FROM    #AccountBalances a LEFT OUTER JOIN
        #AccountBalances b ON a.AccountID = b.AccountID AND b.Balance > 0
WHERE   b.AccountID IS NULL;

/*----------------------------------------------------
Answer to Puzzle #47
Work Schedule
*/----------------------------------------------------

DROP TABLE IF EXISTS #CalendarTable;
DROP TABLE IF EXISTS #Schedule;
DROP TABLE IF EXISTS #Activity;
DROP TABLE IF EXISTS #ActivityDetail;
DROP TABLE IF EXISTS #ActivityGroupings1;
DROP TABLE IF EXISTS #ActivityGroupings2
DROP TABLE IF EXISTS #ActivityGroupings3;
DROP TABLE IF EXISTS #ActivityGroupings4;
GO

CREATE TABLE #CalendarTable
(
MyDateTime DATETIME PRIMARY KEY
);
GO

INSERT INTO #CalendarTable
VALUES
(CAST('10/01/2021 09:45 AM' AS DATETIME)),
(CAST('10/01/2021 10:00 AM' AS DATETIME)),
(CAST('10/01/2021 10:15 AM' AS DATETIME)),
(CAST('10/01/2021 10:30 AM' AS DATETIME)),
(CAST('10/01/2021 10:45 AM' AS DATETIME)),
(CAST('10/01/2021 11:00 AM' AS DATETIME)),
(CAST('10/01/2021 11:15 AM' AS DATETIME)),
(CAST('10/01/2021 11:30 AM' AS DATETIME)),
(CAST('10/01/2021 11:45 AM' AS DATETIME)),
(CAST('10/01/2021 12:00 PM' AS DATETIME)),
(CAST('10/01/2021 12:15 PM' AS DATETIME)),
(CAST('10/01/2021 12:30 PM' AS DATETIME)),
(CAST('10/01/2021 12:45 PM' AS DATETIME)),
(CAST('10/01/2021 1:00 PM' AS DATETIME)),
(CAST('10/01/2021 1:15 PM' AS DATETIME)),
(CAST('10/01/2021 1:30 PM' AS DATETIME)),
(CAST('10/01/2021 1:45 PM' AS DATETIME)),
(CAST('10/01/2021 2:00 PM' AS DATETIME)),
(CAST('10/01/2021 2:15 PM' AS DATETIME)),
(CAST('10/01/2021 2:30 PM' AS DATETIME)),
(CAST('10/01/2021 2:45 PM' AS DATETIME)),
(CAST('10/01/2021 3:00 PM' AS DATETIME)),
(CAST('10/01/2021 3:15 PM' AS DATETIME));
GO

CREATE TABLE #Schedule
(
ScheduleId CHAR(1) PRIMARY KEY,
StartTime DATETIME,
EndTime DATETIME
);
GO

CREATE TABLE #Activity
(
ScheduleID CHAR(1),
ActivityName VARCHAR(100),
StartTime DATETIME,
EndTime DATETIME,
PRIMARY KEY (ScheduleID, ActivityName, StartTime, EndTime)
);
GO

INSERT INTO #Schedule
VALUES
('A',CAST('2021-10-01 10:00:00' AS DATETIME),CAST('2021-10-01 15:00:00' AS DATETIME)),
('B',CAST('2021-10-01 10:15:00' AS DATETIME),CAST('2021-10-01 12:15:00' AS DATETIME));
GO

INSERT INTO #Activity
VALUES
('A','Meeting',CAST('2021-10-01 10:00:00' AS DATETIME),CAST('2021-10-01 10:30:00' AS DATETIME)),
('A','Break',CAST('2021-10-01 12:00:00' AS DATETIME),CAST('2021-10-01 12:30:00' AS DATETIME)),
('A','Meeting',CAST('2021-10-01 13:00:00' AS DATETIME),CAST('2021-10-01 13:30:00' AS DATETIME)),
('B','Break',CAST('2021-10-01 11:00:00'AS DATETIME),CAST('2021-10-01 11:15:00' AS DATETIME));
GO

--Step 1
WITH cte_Work AS
(
SELECT  ScheduleID
        ,'Work' AS ActivityName
        ,MyDateTime
FROM    #Schedule s INNER JOIN
        #CalendarTable c ON c.MyDateTime >= s.StartTime AND c.MyDateTime <= s.EndTime
)
,cte_Activity AS
(
SELECT  c.ScheduleID
        ,COALESCE(s.ActivityName, c.ActivityName) AS ActivityName
        ,c.MyDateTime
FROM    cte_Work c LEFT OUTER JOIN
        #Activity s ON c.MyDateTime >= s.StartTime AND c.MyDateTime <= s.EndTime
                        AND s.ScheduleID = c.ScheduleID
)
SELECT  ROW_NUMBER() OVER (PARTITION BY ScheduleID ORDER BY ScheduleID, MyDateTime ASC) AS StepNumber
        ,*
INTO    #ActivityDetail
FROM    cte_Activity;
GO

--Step 2
SELECT  ScheduleID
        ,ActivityName
        ,StepNumber
        ,ROW_NUMBER() OVER (PARTITION BY ScheduleID, ActivityName ORDER BY StepNumber) AS RowNumber
        ,StepNumber - ROW_NUMBER() OVER (PARTITION BY ScheduleId, ActivityName ORDER BY StepNumber) AS Rnk
INTO    #ActivityGroupings1
FROM    #ActivityDetail
ORDER BY StepNumber;
GO

--Step 3
SELECT  ROW_NUMBER() OVER (ORDER BY ScheduleId, Rnk) AS StepOrder
        ,ScheduleID
        ,ActivityName
        ,MAX(StepNumber) - MIN(StepNumber) + 1 AS ConsecutiveCount
        ,MIN(StepNumber) AS MinStepNumber
        ,MAX(StepNumber) AS MaxStepNumber
INTO    #ActivityGroupings2
FROM    #ActivityGroupings1
GROUP BY
        Rnk,
        ScheduleID,
        ActivityName;
GO

--Step 4
SELECT  a.*,
        b.StepOrder AS DistinctGroupingSet
INTO    #ActivityGroupings3
FROM    #ActivityDetail a INNER JOIN
        #ActivityGroupings2 b ON a.StepNumber BETWEEN b.MinStepNumber AND b.MaxStepNumber
                                    AND A.ScheduleID = b.ScheduleID
ORDER BY 1;
GO

--Step 5
SELECT  MIN(StepNumber) AS MinStepNumber
        ,MAX(StepNumber) AS MaxStepNumber
        ,ScheduleID
        ,ActivityName
        ,DistinctGroupingSet
        ,MIN(MyDateTime) AS StartTime
        ,MAX(MyDateTime) AS EndTime
INTO    #ActivityGroupings4
FROM    #ActivityGroupings3
GROUP BY ScheduleId
        ,ActivityName
        ,DistinctGroupingSet
ORDER BY 1;
GO

--Results
SELECT  ScheduleID
        ,ActivityName
        ,(CASE  WHEN ActivityName = 'Work' 
                THEN LAG(EndTime,1,StartTime) OVER (PARTITION BY ScheduleID ORDER BY MinStepNumber) ELSE StartTime END) StartTime2
        ,(CASE  WHEN ActivityName = 'Work' 
                THEN LEAD(StartTime,1,EndTime) OVER (PARTITION BY ScheduleID ORDER BY MinStepNumber) ELSE EndTime END) EndTime2
FROM    #ActivityGroupings4
ORDER BY ScheduleID, MinStepNumber;

/*----------------------------------------------------
Answer to Puzzle #48
Consecutive Sales
*/----------------------------------------------------

DROP TABLE IF EXISTS #Sales;
GO

CREATE TABLE #Sales
(
SalesID INTEGER,
[Year]  INTEGER,
PRIMARY KEY (SalesID, [Year])
);
GO

INSERT INTO #Sales
VALUES
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
SELECT  a.SalesID
        ,b.[Year]
        ,DATEPART(YY,GETDATE()) - 2 AS Year_Start
FROM    cte_Current_Year a INNER JOIN
        #Sales b on a.SalesID = b.SalesID
WHERE   b.[Year] = DATEPART(YY,GETDATE()) - 2
)
SELECT DISTINCT SalesID FROM cte_Determine_Lag;

/*----------------------------------------------------
Answer to Puzzle #49
Sumo Wrestlers
*/----------------------------------------------------

DROP TABLE IF EXISTS #ElevatorOrder;
GO

CREATE TABLE #ElevatorOrder
(
[Name] VARCHAR(100) PRIMARY KEY,
[Weight] INTEGER,
LineOrder INTEGER
);
GO

INSERT INTO #ElevatorOrder
VALUES
('Haruto',611,1),('Minato',533,2),('Haruki',623,3),
('Sota',569,4),('Aoto',610,5),('Hinata',525,6);
GO

WITH cte_Running_Total AS
(
SELECT  *,
        SUM(Weight) OVER (ORDER BY LineOrder) AS Running_Total
FROM    #ElevatorOrder
)
SELECT  TOP 1
        *
FROM    cte_Running_Total
WHERE   Running_Total <= 2000
ORDER BY Running_Total DESC;

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
BatterID INTEGER,
PitchNumber INTEGER,
Result VARCHAR(100),
PRIMARY KEY (BatterID, PitchNumber)
);
GO

INSERT INTO #Pitches VALUES
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

SELECT  *,
        SUM(Ball) OVER (PARTITION BY BatterID ORDER BY PitchNumber) AS SumBall,
        SUM(Strike) OVER (PARTITION BY BatterID ORDER BY PitchNumber) AS SumStrike
INTO    #BallsStrikesSumWidow
FROM    #BallsStrikes;
GO

SELECT  *,
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

INSERT INTO #Assembly VALUES
(1001,'Bolt'),(1001,'Screw'),(2002,'Nut'),
(2002,'Washer'),(3003,'Toggle'),(3003,'Bolt');
GO

SELECT  HASHBYTES('SHA2_512',CONCAT(AssemblyID, Part)) AS ExampleUniqueID1, 
        CHECKSUM(CONCAT(AssemblyID, Part)) AS ExampleUniqueID1,
        *
FROM    #Assembly;

/*----------------------------------------------------
Answer to Puzzle #52
Phone Numbers Table
*/----------------------------------------------------

DROP TABLE IF EXISTS #CustomerInfo;
GO

CREATE TABLE #CustomerInfo
(
CustomerID INTEGER PRIMARY KEY,
PhoneNumber VARCHAR(14),
CONSTRAINT ckPhoneNumber CHECK (LEN(PhoneNumber) = 14
                            AND SUBSTRING(PhoneNumber,1,1)= '('
                            AND SUBSTRING(PhoneNumber,5,1)= ')'
                            AND SUBSTRING(PhoneNumber,6,1)= '-'
                            AND SUBSTRING(PhoneNumber,10,1)= '-')
);
GO

INSERT INTO #CustomerInfo VALUES
(1001,'(555)-555-5555'),(2002,'(555)-555-5555'), (3003,'(555)-555-5555');
GO

SELECT * FROM #CustomerInfo;

/*----------------------------------------------------
Answer to Puzzle #53
Spouse IDs
*/----------------------------------------------------

DROP TABLE IF EXISTS #Spouses;
GO

CREATE TABLE #Spouses
(
PrimaryID VARCHAR(100) PRIMARY KEY,
SpouseID  VARCHAR(100) UNIQUE NOT NULL
);
GO

INSERT INTO #Spouses VALUES
('Pat','Charlie'),('Jordan','Casey'),
('Ashley','Dee'),('Charlie','Pat'),
('Casey','Jordan'),('Dee','Ashley')
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
        *
FROM    cte_Reciprocals
)
SELECT  GroupID,
        b.PrimaryID,
        b.SpouseID
FROM    cte_DenseRank a INNER JOIN
        #Spouses b ON a.PrimaryID = b.PrimaryID AND a.SpouseID = b.SpouseID

/*----------------------------------------------------
Answer to Puzzle #54
Winning Numbers
*/----------------------------------------------------

DROP TABLE IF EXISTS #WinningNumbers;
DROP TABLE IF EXISTS #LotteryTickets;
GO

CREATE TABLE #WinningNumbers
(
Number INTEGER
);
GO

INSERT INTO #WinningNumbers VALUES(25),(45),(78);
GO

CREATE TABLE #LotteryTickets
(
TicketID    VARCHAR(100),
Number      INTEGER,
PRIMARY KEY (TicketID, Number)
);
GO

INSERT INTO #LotteryTickets VALUES
('A23423',25),('A23423',45),('A23423',78),
('B35643',25),('B35643',45),('B35643',98),
('C98787',67),('C98787',86),('C98787',91);
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

/*----------------------------------------------------
Answer to Puzzle #55
Table Audit
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProductsA;
DROP TABLE IF EXISTS #ProductsB;
DROP TABLE IF EXISTS #Results1;
DROP TABLE IF EXISTS #Results2;
DROP TABLE IF EXISTS #Results3;
DROP TABLE IF EXISTS #Results4;
GO

CREATE TABLE #ProductsA
(
ProductName VARCHAR(100),
Quantity    INTEGER
);
GO

CREATE TABLE #ProductsB
(
ProductName VARCHAR(100),
Quantity    INTEGER
);
GO

INSERT INTO #ProductsA VALUES
('Widget',7),
('Doodad',9),
('Gizmo',3);
GO

INSERT INTO #ProductsB VALUES
('Widget',7),
('Doodad',6),
('Dingbat',9);
GO

--Matches In both tables
SELECT  *
INTO    #Results1
FROM    #ProductsA
INTERSECT
SELECT  *
FROM    #ProductsB;
GO

--Product does not exist in Table B
SELECT  ProductName,
        NULL AS Quantity
INTO    #Results2
FROM    #ProductsA
EXCEPT
SELECT  ProductName,
        NULL AS Quantity
FROM    #ProductsB;
GO

--Product does not exist in Table A
SELECT  ProductName
INTO    #Results3
FROM    #ProductsB
EXCEPT
SELECT  ProductName
FROM    #ProductsA;
GO

--Quantity in Table A and Table B do not match
SELECT  *
INTO    #Results4
FROM    #ProductsA
WHERE   ProductName IN (SELECT ProductName FROM #ProductsB)
EXCEPT
SELECT  *
FROM    #ProductsB;
GO

SELECT  'Matches In both tables' AS [Type],
        ProductName
FROM    #Results1
UNION
SELECT  'Product does not exist in Table B' AS [Type],
        ProductName
FROM    #Results2
UNION
SELECT  'Product does not exist in Table A' AS [Type],
        ProductName
FROM    #Results3
UNION
SELECT  'Quantities in Table A and Table B do not match' AS [Type],
        ProductName
FROM    #Results4;

/*----------------------------------------------------
The End
*/----------------------------------------------------