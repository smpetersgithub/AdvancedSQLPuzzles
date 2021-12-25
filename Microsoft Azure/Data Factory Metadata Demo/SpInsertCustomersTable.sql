CREATE PROCEDURE demo.SpInsertCustomersTable
@pCustomersTableType demo.CustomersTableType READONLY,
@pInsertDate DATETIME
AS 
BEGIN

INSERT INTO demo.Customers (InsertDate, CustomerName)
SELECT	@pInsertDate, CustomerName 
FROM	@pCustomersTableType;

END;
GO


