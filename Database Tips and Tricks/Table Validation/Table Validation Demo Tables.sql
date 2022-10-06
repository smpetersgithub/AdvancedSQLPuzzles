/*********************************************************************
Scott Peters
https://advancedsqlpuzzles.com
Last Updated: 10/06/2022

This script is written in Microsoft SQL Server's T-SQL

See full instructions in PDF format at the following GitHub repository:
https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Tips%20and%20Tricks/Table%20Validation

**********************************************************************/

DROP TABLE IF EXISTS dbo.MyTable1;
DROP TABLE IF EXISTS dbo.MyTable2;
GO

CREATE TABLE dbo.MyTable1
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

CREATE TABLE dbo.MyTable2
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

INSERT INTO dbo.MyTable1 (CustID, Region, City, Sales, ManagerID, AwardStatus) VALUES 
(453,'Central','Chicago','71967.99',1324,'Gold'),
(532,'Central','Des Moines','65232.42',6453,'Gold'),
(643,'West','Spokane','44981.23',7542,'Silver'),
(643,'West','Spokane','44981.23',7542,'Silver'),--Duplicate Data
(732,'West','Helena','15232.19',8123,'Bronze'),
(732,'West','Helena','15232.19',8123,'Bronze');--Duplicate Data
GO

INSERT INTO dbo.MyTable2 (CustID, Region, City, Sales, ManagerID, AwardStatus) VALUES 
(453,'Central','Chicago','71967.99',1324,'Gold'),
(532,'Central','Des Moines','65232.00',6453,'Gold'),
(643,'West','Spokane','44981.23',7542,'Bronze'),
(643,'West','Spokane','44981.23',7542,'Bronze'),--Duplicate Data
(898,'East','Toledo','53432.78',9242,'Silver');
GO

SELECT 'Table1' AS ID, * FROM dbo.MyTable1
UNION ALL
SELECT 'Table2' AS ID, * FROM dbo.MyTable2;


SELECT * FROM dbo.MyTable1
UNION ALL
SELECT * FROM dbo.MyTable2;
