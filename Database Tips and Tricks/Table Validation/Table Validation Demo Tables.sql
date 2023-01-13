/*-----------------------------------------------------------------------
Scott Peters
Dynamic Full Outer Joins
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

Creates the demo tables Sales_New and Sales_Old.

*/-----------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Sales_New;
DROP TABLE IF EXISTS dbo.Sales_Old;
GO

CREATE TABLE dbo.Sales_New
(
TableID   INTEGER IDENTITY(1,1) PRIMARY KEY,
CustID    INTEGER,
Region    VARCHAR(500),
City      VARCHAR(500),
Sales     MONEY,
ManagerID INTEGER,
AwardStatus  VARCHAR(100)
);
GO

CREATE TABLE dbo.Sales_Old
(
TableID   INTEGER IDENTITY(1,1) PRIMARY KEY,
CustID    INTEGER,
Region    VARCHAR(500),
City      VARCHAR(500),
Sales     MONEY,
ManagerID INTEGER,
AwardStatus  VARCHAR(100)
);
GO

INSERT INTO dbo.Sales_New (CustID, Region, City, Sales, ManagerID, AwardStatus) VALUES 
(453,'Central','Chicago','71967.99',1324,'Gold'),
(532,'Central','Des Moines','65232.42',6453,'Gold'),
(643,'West','Spokane','44981.23',7542,'Silver'),
(643,'West','Spokane','44981.23',7542,'Silver'),--Duplicate Data
(732,'West','Helena','15232.19',8123,'Bronze'),
(732,'West','Helena','15232.19',8123,'Bronze');--Duplicate Data
GO

INSERT INTO dbo.Sales_Old (CustID, Region, City, Sales, ManagerID, AwardStatus) VALUES 
(453,'Central','Chicago','71967.99',1324,'Gold'),
(532,'Central','Des Moines','65232.00',6453,'Gold'),
(643,'West','Spokane','44981.23',7542,'Bronze'),
(643,'West','Spokane','44981.23',7542,'Bronze'),--Duplicate Data
(898,'East','Toledo','53432.78',9242,'Silver');
GO

--Review the tables
SELECT 'Sales_New' AS ID, * FROM dbo.Sales_New;
GO

SELECT 'Sales_Old' AS ID, * FROM dbo.Sales_Old;
GO
