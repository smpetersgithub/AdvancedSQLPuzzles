/*----------------------------------------------------
Scott Peters
DDL for Advanced SQL Puzzles
https://advancedsqlpuzzles.com
Last Updated 03/29/2023
Microsoft SQL Server T-SQL

*/----------------------------------------------------
SET NOCOUNT ON;
GO

/*----------------------------------------------------
DDL for Puzzle #1
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

/*----------------------------------------------------
DDL for Puzzle #2
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


/*----------------------------------------------------
DDL for Puzzle #3
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

/*----------------------------------------------------
DDL for Puzzle #4
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

/*----------------------------------------------------
DDL for Puzzle #5
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

/*----------------------------------------------------
DDL for Puzzle #6
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

/*----------------------------------------------------
DDL for Puzzle #7
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

/*----------------------------------------------------
DDL for Puzzle #8
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

/*----------------------------------------------------
DDL for Puzzle #9
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

/*----------------------------------------------------
DDL for Puzzle #10
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

/*----------------------------------------------------
DDL for Puzzle #11
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

/*----------------------------------------------------
DDL for Puzzle #12
Average Days
*/----------------------------------------------------

DROP TABLE IF EXISTS #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
WorkFlow       VARCHAR(100),
ExecutionDate  DATE,
PRIMARY KEY (WorkFlow, ExecutionDate)
);
GO

INSERT INTO #ProcessLog (WorkFlow, ExecutionDate) VALUES
('Alpha','6/01/2018'),('Alpha','6/14/2018'),('Alpha','6/15/2018'),
('Bravo','6/1/2018'),('Bravo','6/2/2018'),('Bravo','6/19/2018'),
('Charlie','6/1/2018'),('Charlie','6/15/2018'),('Charlie','6/30/2018');
GO

/*----------------------------------------------------
DDL for Puzzle #13
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

/*----------------------------------------------------
DDL for Puzzle #14
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

/*----------------------------------------------------
DDL for Puzzle #15
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

/*----------------------------------------------------
DDL for Puzzle #16
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

/*----------------------------------------------------
DDL for Puzzle #17
De-Grouping
*/----------------------------------------------------

DROP TABLE IF EXISTS #Ungroup;
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

/*----------------------------------------------------
DDL for Puzzle #18
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

/*----------------------------------------------------
DDL for Puzzle #19
Back to the Future
*/----------------------------------------------------

DROP TABLE IF EXISTS #TimePeriods;
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

/*----------------------------------------------------
DDL for Puzzle #20
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

/*----------------------------------------------------
DDL for Puzzle #21
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

/*----------------------------------------------------
DDL for Puzzle #22
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

/*----------------------------------------------------
DDL for Puzzle #23
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

/*----------------------------------------------------
DDL for Puzzle #24
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

/*----------------------------------------------------
DDL for Puzzle #25
Top Vendors
*/----------------------------------------------------

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
OrderID     INTEGER PRIMARY KEY,
CustomerID  INTEGER NOT NULL,
[Count]  MONEY NOT NULL,
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

/*----------------------------------------------------
DDL for Puzzle #26
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

/*----------------------------------------------------
DDL for Puzzle #27
Delete the Duplicates
*/----------------------------------------------------

DROP TABLE IF EXISTS #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue  INTEGER NOT NULL
);
GO

INSERT INTO #SampleData VALUES
(1),(1),(2),(3),(3),(4);
GO

/*----------------------------------------------------
DDL for Puzzle #28
Fill the Gaps
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

/*----------------------------------------------------
DDL for Puzzle #29
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

/*----------------------------------------------------
DDL for Puzzle #30
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

/*----------------------------------------------------
DDL for Puzzle #31
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

/*----------------------------------------------------
DDL for Puzzle #32
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

/*----------------------------------------------------
DDL for Puzzle #33
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

/*----------------------------------------------------
DDL for Puzzle #34
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

/*----------------------------------------------------
DDL for Puzzle #35
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

/*----------------------------------------------------
DDL for Puzzle #36
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

/*----------------------------------------------------
DDL for Puzzle #37
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

/*----------------------------------------------------
DDL for Puzzle #38
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

/*----------------------------------------------------
DDL for Puzzle #39
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

/*----------------------------------------------------
DDL for Puzzle #40
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

/*----------------------------------------------------
DDL for Puzzle #41
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

/*----------------------------------------------------
DDL for Puzzle #42
Mutual Friends
*/----------------------------------------------------

DROP TABLE IF EXISTS #Friends;
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

/*----------------------------------------------------
DDL for Puzzle #43
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

/*----------------------------------------------------
DDL for Puzzle #44
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

/*----------------------------------------------------
DDL for Puzzle #45
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

/*----------------------------------------------------
DDL for Puzzle #46
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

/*----------------------------------------------------
DDL for Puzzle #47
Work Schedule
*/----------------------------------------------------

DROP TABLE IF EXISTS #Schedule;
DROP TABLE IF EXISTS #Activity;
DROP TABLE IF EXISTS #ScheduleTimes;
DROP TABLE IF EXISTS #ActivityCoalesce
GO

CREATE TABLE #Schedule
(
ScheduleID  CHAR(1) PRIMARY KEY,
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

/*----------------------------------------------------
DDL for Puzzle #48
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

/*----------------------------------------------------
DDL for Puzzle #49
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

/*----------------------------------------------------
DDL for Puzzle #50
Baseball Balls and Strikes
*/----------------------------------------------------

DROP TABLE IF EXISTS #Pitches;
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

/*----------------------------------------------------
DDL for Puzzle #51
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

/*----------------------------------------------------
DDL for Puzzle #52
Phone Numbers Table
*/----------------------------------------------------

/*
No DDL provided

You are creating a table that customer agents will use to enter customer information and their phone numbers.
Create a table with the fields Customer ID and Phone Number, where the Phone Number field must be inserted with the format (999)-999-9999.
Agents will enter phone numbers into this table via a form, and it is imperative that phone numbers are formatted correctly when inputted.  
Create a table that meets these requirements. 
*/

/*----------------------------------------------------
DDL for Puzzle #53
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

/*----------------------------------------------------
DDL for Puzzle #54
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

/*----------------------------------------------------
DDL for Puzzle #55
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

/*----------------------------------------------------
DDL for Puzzle #56
Numbers Using Recursion
*/----------------------------------------------------

/*
No DDL provided

Create a numbers table using recursion
*/

/*----------------------------------------------------
DDL for Puzzle #57
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

/*----------------------------------------------------
DDL for Puzzle #58
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

/*----------------------------------------------------
DDL for Puzzle #59
Balanced String
*/----------------------------------------------------

DROP TABLE IF EXISTS #BalancedString;
GO

CREATE TABLE #BalancedString
(
RowNumber       INT IDENTITY(1,1) PRIMARY KEY,
ExpectedOutcome VARCHAR(50),
MatchString     VARCHAR(50),
UpdateString    VARCHAR(50)
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

/*----------------------------------------------------
The End
*/----------------------------------------------------
