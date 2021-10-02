/*----------------------------------------------------
Scott Peters
https://advancedsqlpuzzles.com
*/----------------------------------------------------


/*----------------------------------------------------
DDL for Puzzle #1
Dance Partners
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#DancePartners','U') IS NOT NULL
	DROP TABLE #DancePartners;
GO

CREATE TABLE #DancePartners
(
StudentID	INTEGER,
Gender		VARCHAR(1)
);
GO

INSERT INTO #DancePartners VALUES
(1001,'M'),
(2002,'M'),
(3003,'M'),
(4004,'M'),
(5005,'M'),
(6006,'F'),
(7007,'F'),
(8008,'F'),
(9009,'F');
GO


/*----------------------------------------------------
DDL for Puzzle #2
Managers and Employees
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Employees','U') IS NOT NULL
	DROP TABLE #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID	INTEGER,
ManagerID	INTEGER,
JobTitle	VARCHAR(MAX),
Salary		INTEGER
);
GO

INSERT INTO #Employees VALUES
(1001,NULL,'President',185000),
(2002,1001,'Director',120000),
(3003,1001,'Office Manager',97000),
(4004,2002,'Engineer',110000),
(5005,2002,'Engineer',142000),
(6006,2002,'Engineer',160000);
GO


/*----------------------------------------------------
DDL for Puzzle #3
Fiscal Year Table Constraints
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#EmployeePayRecord','U') IS NOT NULL
	DROP TABLE #EmployeePayRecord;
GO

CREATE TABLE #EmployeePayRecord
(
EmployeeID	INTEGER,
FiscalYear	INTEGER,
StartDate	DATE,
EndDate		DATE,
PayRate		MONEY
);
GO


/*----------------------------------------------------
DDL for Puzzle #4
Two Predicates
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Orders','U')IS NOT NULL
	DROP TABLE #Orders;
GO

CREATE TABLE #Orders
(
CustomerID		INTEGER,
OrderID			VARCHAR(MAX),
DeliveryState	VARCHAR(MAX),
Amount			MONEY
);
GO

INSERT INTO #Orders VALUES
(1001,'Ord936254','CA',340),
(1001,'Ord143876','TX',950),
(1001,'Ord654876','TX',670),
(1001,'Ord814356','TX',860),
(2002,'Ord342176','WA',320),
(3003,'Ord265789','CA',650),
(3003,'Ord387654','CA',830),
(4004,'Ord476126','TX',120);
GO


/*----------------------------------------------------
DDL for Puzzle #5
Phone Directory
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#PhoneDirectory','U') IS NOT NULL
	DROP TABLE #PhoneDirectory;
GO

CREATE TABLE #PhoneDirectory
(
CustomerID	INTEGER,
Type		VARCHAR(MAX),
PhoneNumber	VARCHAR(MAX)
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


/*----------------------------------------------------
DDL for Puzzle #6
Workflow Steps
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#WorkflowSteps','U') IS NOT NULL
	DROP TABLE #WorkflowSteps;
GO

CREATE TABLE #WorkflowSteps
(
Workflow		VARCHAR(MAX),
StepNumber		INTEGER,
CompletionDate	DATE
);
GO

INSERT INTO #WorkflowSteps VALUES
('Alpha',1,'7/2/2018'),
('Alpha',2,'7/2/2018'),
('Alpha',3,'7/1/2018'),
('Bravo',1,'6/25/2018'),
('Bravo',2,NULL),
('Bravo',3,'6/27/2018'),
('Charlie',1,NULL),
('Charlie',2,'7/1/2018');
GO


/*----------------------------------------------------
DDL for Puzzle #7
Mission to Mars
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Candidates','U') IS NOT NULL
	DROP TABLE #Candidates;
GO

IF OBJECT_ID('tempdb.dbo.#Requirements','U') IS NOT NULL
	DROP TABLE #Requirements;
GO

CREATE TABLE #Candidates
(
CandidateID INTEGER,
Occupation	VARCHAR(MAX)
);
GO

INSERT INTO #Candidates VALUES
(1001,'Geologist'),
(1001,'Astrogator'),
(1001,'Biochemist'),
(1001,'Technician'),
(2002,'Surgeon'),
(2002,'Machinist'),
(3003,'Cryologist'),
(4004,'Selenologist');
GO

CREATE TABLE #Requirements
(
Requirement VARCHAR(MAX)
);
GO

INSERT INTO #Requirements VALUES
('Geologist'),('Astrogator'),('Technician');
GO


/*----------------------------------------------------
DDL for Puzzle #8
Workflow Cases
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#WorkflowCases','U') IS NOT NULL
	DROP TABLE #WorkflowCases;
GO

CREATE TABLE #WorkflowCases
(
Workflow	VARCHAR(MAX),
Case1		INTEGER,
Case2		INTEGER,
Case3		INTEGER
);
GO

INSERT INTO #WorkflowCases VALUES
('Alpha',0,0,0),
('Bravo',0,1,1),
('Charlie',1,0,0),
('Delta',0,0,0);
GO


/*----------------------------------------------------
DDL for Puzzle #9
Matching Sets
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Employees','U') IS NOT NULL
	DROP TABLE #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID	INTEGER,
License		VARCHAR(MAX)
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


/*----------------------------------------------------
DDL for Puzzle #10
Mean, Median, Mode and Range
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#SampleData','U') IS NOT NULL
	DROP TABLE #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue INTEGER
);
GO

INSERT INTO #SampleData VALUES
(5),(6),(10),(10),(13),(14),(17),(20),(81),(90),(76);
GO


/*----------------------------------------------------
DDL for Puzzle #11
Permutations
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#TestCases','U') IS NOT NULL
	DROP TABLE #TestCases;
GO

CREATE TABLE #TestCases
(
RowNumber INTEGER,
TestCase VARCHAR(1)
);
GO

INSERT INTO #TestCases VALUES
(1,'A'),(2,'B'),(3,'C');
GO


/*----------------------------------------------------
DDL for Puzzle #12
Average Days
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#ProcessLog','U') IS NOT NULL
	DROP TABLE #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
WorkFlow		VARCHAR(MAX),
ExecutionDate	DATE
);
GO

INSERT INTO #ProcessLog VALUES
('Alpha','6/01/2018'),
('Alpha','6/14/2018'),
('Alpha','6/15/2018'),
('Bravo','6/1/2018'),
('Bravo','6/2/2018'),
('Bravo','6/19/2018'),
('Charlie','6/1/2018'),
('Charlie','6/15/2018'),
('Charlie','6/30/2018');
GO


/*----------------------------------------------------
DDL for Puzzle #13
Inventory Tracking
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Inventory','U') IS NOT NULL
	DROP TABLE #Inventory;
GO

CREATE TABLE #Inventory
(
InventoryDate		DATE,
QuantityAdjustment	INTEGER
);
GO

INSERT INTO #Inventory VALUES
('7/1/2018',100),
('7/2/2018',75),
('7/3/2018',-150),
('7/4/2018',50),
('7/5/2018',-75);
GO


/*----------------------------------------------------
DDL for Puzzle #14
Indeterminate Process Log
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#ProcessLog','U') IS NOT NULL
	DROP TABLE #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow	VARCHAR(MAX),
StepNumber	INTEGER,
Status		VARCHAR(MAX)
);
GO

INSERT INTO #ProcessLog VALUES
('Alpha',1,'Error'),
('Alpha',2,'Complete'),
('Bravo',1,'Complete'),
('Bravo',2,'Complete'),
('Charlie',1,'Complete'),
('Charlie',2,'Error'),
('Delta',1,'Complete'),
('Delta',2,'Running'),
('Echo',1,'Running'),
('Echo',2,'Error'),
('Foxtrot',1,'Error'),
('Foxtrot',2,'Error');
GO

--Create a StatusRank table to solve the problem
IF OBJECT_ID('tempdb.dbo.#StatusRank','U') IS NOT NULL
  DROP TABLE #StatusRank;
GO

CREATE TABLE #StatusRank
(
Status	VARCHAR(MAX),
Rank	INTEGER
);
GO

INSERT INTO #StatusRank VALUES
('Error',1),
('Running',2),
('Complete',3);
GO


/*----------------------------------------------------
DDL for Puzzle #15
Group Concatenation
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#DMLTable','U') IS NOT NULL
	DROP TABLE #DMLTable;
GO

CREATE TABLE #DMLTable
(
SequenceNumber	INTEGER,
String			VARCHAR(MAX)
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


/*----------------------------------------------------
DDL for Puzzle #16
Reciprocals
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#PlayerScores','U') IS NOT NULL
	DROP TABLE #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
PlayerA	INTEGER,
PlayerB	INTEGER,
Score	INTEGER
);
GO

INSERT INTO #PlayerScores VALUES
(1001,2002,150),
(3003,4004,15),
(4004,3003,125),
(4004,1001,125);
GO


/*----------------------------------------------------
DDL for Puzzle #17
De-Grouping
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Ungroup','U') IS NOT NULL
	DROP TABLE #Ungroup;
GO

CREATE TABLE #Ungroup
(
ProductDescription	VARCHAR(MAX),
Quantity			INTEGER
);
GO

INSERT INTO #Ungroup VALUES
('Eraser',3),
('Pencil',4),
('Sharpener',2);
GO


/*----------------------------------------------------
DDL for Puzzle #18
Seating Chart
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#SeatingChart','U') IS NOT NULL
	DROP TABLE #SeatingChart;
GO

CREATE TABLE #SeatingChart
(
SeatNumber INTEGER
);
GO

INSERT INTO #SeatingChart VALUES
(7),(13),(14),(15),(27),(28),(29),(30),(31),(32),(33),(34),(35),(52),(53),(54);
GO


/*----------------------------------------------------
DDL for Puzzle #19
Back to the Future
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#TimePeriods','U') IS NOT NULL
  DROP TABLE #TimePeriods;
GO

CREATE TABLE #TimePeriods
(
StartDate	DATE,
EndDate		DATE
);
GO

INSERT INTO #TimePeriods VALUES
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

IF OBJECT_ID('tempdb.dbo.#ValidPrices','U') IS NOT NULL
  DROP TABLE #ValidPrices;
GO

CREATE TABLE #ValidPrices
(
ProductID		VARCHAR(MAX),
UnitPrice		MONEY,
EffectiveDate	DATE
);
GO

INSERT INTO #ValidPrices VALUES
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

IF OBJECT_ID('tempdb.dbo.#Orders','U') IS NOT NULL
  DROP TABLE #Orders;
GO

CREATE TABLE #Orders
(
OrderID		VARCHAR(MAX),
CustomerID	INTEGER,
OrderDate	DATE,
Amount		MONEY,
State		VARCHAR(MAX)
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


/*----------------------------------------------------
DDL for Puzzle #22
Occurrences
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#ProcessLog','U') IS NOT NULL
  DROP TABLE #ProcessLog;
GO

CREATE TABLE #ProcessLog
(
Workflow	VARCHAR(MAX),
Occurrences	INTEGER,
LogMessage	VARCHAR(MAX)
);
GO

INSERT INTO #ProcessLog VALUES
('Alpha',5,'Error: Conversion Failed'),
('Alpha',8,'Status Complete'),
('Alpha',9,'Error: Unidentified error occurred'),
('Bravo',3,'Error: Cannot Divide by 0'),
('Bravo',1,'Error: Unidentified error occurred'),
('Charlie',10,'Error: Unidentified error occurred'),
('Charlie',7,'Error: Conversion Failed'),
('Charlie',6,'Status Complete');
GO


/*----------------------------------------------------
DDL for Puzzle #23
Divide in Half
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#PlayerScores','U') IS NOT NULL
	DROP TABLE #PlayerScores;
GO

CREATE TABLE #PlayerScores
(
PlayerID	VARCHAR(MAX),
Score		INTEGER
);
GO

INSERT INTO #PlayerScores VALUES
(1001,2343),
(2002,9432),
(3003,6548),
(4004,1054),
(5005,6832);
GO


/*----------------------------------------------------
DDL for Puzzle #24
Page Views
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#SampleData','U') IS NOT NULL
	DROP TABLE #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue	INTEGER IDENTITY(1,1),
RowID			UNIQUEIDENTIFIER
);
GO

ALTER TABLE #SampleData DROP COLUMN IntegerValue;
GO

INSERT INTO #SampleData VALUES (NEWID());
GO 1000


/*----------------------------------------------------
DDL for Puzzle #25
Top Vendors
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Orders','U') IS NOT NULL
	DROP TABLE #Orders;
GO

CREATE TABLE #Orders
(
OrderID		VARCHAR(MAX),
CustomerID	INTEGER,
OrderCount	MONEY,
Vendor		VARCHAR(MAX)
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


/*----------------------------------------------------
DDL for Puzzle #26
Previous Years Sales
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Sales','U') IS NOT NULL
	DROP TABLE #Sales;
GO

CREATE TABLE #Sales
(
Year	INTEGER,
Amount	INTEGER
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


/*----------------------------------------------------
DDL for Puzzle #27
Delete the Duplicates
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#SampleData','U') IS NOT NULL
	DROP TABLE #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue INTEGER,
);
GO

INSERT INTO #SampleData VALUES
(1),
(1),
(2),
(3),
(3),
(4);
GO


/*----------------------------------------------------
DDL for Puzzle #28
Fill the Gaps
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Gaps','U') IS NOT NULL
	DROP TABLE #Gaps;
GO

CREATE TABLE #Gaps
(
RowNumber	INTEGER,
TestCase	VARCHAR(MAX)
);
GO

INSERT INTO #Gaps VALUES
(1,'Alpha'),
(2,NULL),
(3,NULL),
(4,NULL),
(5,'Bravo'),
(6,NULL),
(7,'Charlie'),
(8,NULL),
(9,NULL);
GO


/*----------------------------------------------------
DDL for Puzzle #29
Count the Groupings
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Groupings','U') IS NOT NULL
  DROP TABLE #Groupings;
GO

CREATE TABLE #Groupings
(
StepNumber	INTEGER,
TestCase	VARCHAR(MAX),
Status		VARCHAR(MAX)
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


/*----------------------------------------------------
DDL for Puzzle #30
Select Star
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Products','U') IS NOT NULL
  DROP TABLE #Products;
GO

CREATE TABLE #Products
(
ProductID	INTEGER,
ProductName	VARCHAR(MAX)
);
GO


/*----------------------------------------------------
DDL for Puzzle #31
Second Highest
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#SampleData','U') IS NOT NULL
	DROP TABLE #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue INTEGER
);
GO

INSERT INTO #SampleData VALUES
(3759),(3760),(3761),(3762),(3763);
GO


/*----------------------------------------------------
DDL for Puzzle #32
First and Last
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Personel','U') IS NOT NULL
	DROP TABLE #Personel;
GO

CREATE TABLE #Personel
(
SpacemanID		VARCHAR(MAX),
JobDescription	VARCHAR(MAX),
MissionCount	INTEGER
);
GO

INSERT INTO #Personel VALUES
(1001,'Astrogator',6),
(2002,'Astrogator',12),
(3003,'Astrogator',17),
(4004,'Geologist',21),
(5005,'Geologist',9),
(6006,'Geologist',8),
(7007,'Technician',13),
(8008,'Technician',2),
(9009,'Technician',7);
GO


/*----------------------------------------------------
DDL for Puzzle #33
Deadlines
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#OrderFullfillment','U') IS NOT NULL
	DROP TABLE #OrderFullfillment;
GO

IF OBJECT_ID('tempdb.dbo.#ManufactoringTime','U') IS NOT NULL
	DROP TABLE #ManufactoringTime;
GO

CREATE TABLE #OrderFullfillment
(
OrderID		VARCHAR(MAX),
ProductID	VARCHAR(MAX),
DaysToBuild	INTEGER
);
GO

CREATE TABLE #ManufactoringTime
(
PartID				VARCHAR(MAX),
ProductID			VARCHAR(MAX),
DaysToManufacture	INTEGER
);
GO

INSERT INTO #OrderFullfillment VALUES
('Ord893456','Widget',7),
('Ord923654','Gizmo',3),
('Ord187239','Doodad',9);
GO

INSERT INTO #ManufactoringTime VALUES
('AA-111','Widget',7),
('BB-222','Widget',2),
('CC-333','Widget',3),
('DD-444','Widget',1),
('AA-111','Gizmo',7),
('BB-222','Gizmo',2),
('AA-111','Doodad',7),
('DD-444','Doodad',1);
GO


/*----------------------------------------------------
DDL for Puzzle #34
Specific Exclusion
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Orders','U') IS NOT NULL
	DROP TABLE #Orders;
GO

CREATE TABLE #Orders
(
CustomerID	INTEGER,
OrderID		VARCHAR(MAX),
Amount		MONEY
);
GO

INSERT INTO #Orders VALUES
(1001,'Ord143937',25),
(1001,'Ord789765',50),
(2002,'Ord345434',65),
(3003,'Ord465633',50);
GO


/*----------------------------------------------------
DDL for Puzzle #35
International vs Domestic Sales
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Orders','U') IS NOT NULL
	DROP TABLE #Orders;
GO

CREATE TABLE #Orders
(
SalesRepID	INTEGER,
InvoiceID	VARCHAR(MAX),
Amount		MONEY,
SalesType	VARCHAR(MAX)
);
GO

INSERT INTO #Orders VALUES
(1001,'Inv345756',13454,'International'),
(2002,'Inv546744',3434,'International'),
(4004,'Inv234745',54645,'International'),
(5005,'Inv895745',234345,'International'),
(7007,'Inv006321',776,'International'),
(1001,'Inv734534',4564,'Domestic'),
(2002,'Inv600213',34534,'Domestic'),
(3003,'Inv757853',345,'Domestic'),
(6006,'Inv198632',6543,'Domestic'),
(8008,'Inv977654',67,'Domestic');
GO


/*----------------------------------------------------
DDL for Puzzle #36
Traveling Salesman
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#Graph','U') IS NOT NULL
  DROP TABLE #Graph;
GO

CREATE TABLE #Graph
(
DepartureCity	VARCHAR(MAX),
ArrivalCity		VARCHAR(MAX),
Cost			INTEGER
);
GO

INSERT INTO #Graph VALUES
('Austin','Dallas',100),
('Dallas','Austin',150),
('Dallas','Memphis',200),
('Memphis','Des Moines',300),
('Dallas','Des Moines',400);
GO


/*----------------------------------------------------
DDL for Puzzle #37
Group Criteria Keys
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#GroupCriteria','U') IS NOT NULL
	DROP TABLE #GroupCriteria;
GO

CREATE TABLE #GroupCriteria
(
OrderID		VARCHAR(MAX),
Distributor	VARCHAR(MAX),
Facility	INTEGER,
Zone		VARCHAR(MAX),
Amount		MONEY
);
GO

INSERT INTO #GroupCriteria VALUES
('Ord156795','ACME',123,'ABC',100),
('Ord826109','ACME',123,'ABC',75),
('Ord342876','Direct Parts',789,'XYZ',150),
('Ord994981','Direct Parts',789,'XYZ',125);
GO


/*----------------------------------------------------
DDL for Puzzle #38
Reporting Elements
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#RegionSales','U') IS NOT NULL
	DROP TABLE #RegionSales;
GO

CREATE TABLE #RegionSales
(
Region		VARCHAR(MAX),
Distributor	VARCHAR(MAX),
Sales		INTEGER
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
('West','ACME',1),
('West','ACME',7);
GO


/*----------------------------------------------------
DDL for Puzzle #39
Prime Numbers
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#SampleData ','U') IS NOT NULL
	DROP TABLE #SampleData;
GO

CREATE TABLE #SampleData
(
IntegerValue INTEGER
);
GO

INSERT INTO #SampleData VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);
GO


/*----------------------------------------------------
DDL for Puzzle #40
Sort Order
*/----------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#SortOrder','U') IS NOT NULL
	DROP TABLE #SortOrder;
GO

CREATE TABLE #SortOrder
(
City VARCHAR(MAX)
);
GO

--End

