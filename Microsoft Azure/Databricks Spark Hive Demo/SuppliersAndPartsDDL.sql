CREATE SCHEMA supp_parts_hive;
GO

DROP TABLE IF EXISTS supp_parts_hive.Shipments;
DROP TABLE IF EXISTS supp_parts_hive.Suppliers;
DROP TABLE IF EXISTS supp_parts_hive.Parts;
GO


CREATE TABLE supp_parts_hive.Suppliers
(
SupplierId int NOT NULL PRIMARY KEY,
SupplierName varchar(16) NOT NULL,
Status int NOT NULL,
City varchar(20) NOT NULL,
InsertDate DATETIME DEFAULT GETDATE() NOT NULL
);
GO


CREATE TABLE supp_parts_hive.Parts
(
PartId int NOT NULL PRIMARY KEY,
PartName varchar(18) NOT NULL,
Color varchar(10) NOT NULL,
Weight decimal(4,1) NOT NULL,
City varchar(20) NOT NULL,
InsertDate DATETIME DEFAULT GETDATE() NOT NULL
);
GO


CREATE TABLE supp_parts_hive.Shipments
(
ShipmentId int NOT NULL PRIMARY KEY,
SupplierId int,
PartId int,
Quantity int NOT NULL,
InsertDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO