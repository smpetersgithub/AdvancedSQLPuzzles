CREATE TABLE demo.Customers(
	InsertDate datetime NULL,
	CustomerName varchar(100) NULL
) ON PRIMARY
GO

ALTER TABLE demo.Customers ADD  DEFAULT (getdate()) FOR InsertDate
GO


