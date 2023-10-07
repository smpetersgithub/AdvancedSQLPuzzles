/*----------------------------------------------------
Scott Peters
Managers and Employees
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script uses recursion to display the depth given a managers and employees table.

*/----------------------------------------------------

---------------------
---------------------
DROP TABLE IF EXISTS #Employees;
GO

---------------------
---------------------
CREATE TABLE #Employees
(
EmployeeID  INTEGER PRIMARY KEY,
ManagerID   INTEGER,
JobTitle    VARCHAR(100),
Salary      INTEGER
);
GO

---------------------
---------------------
INSERT INTO #Employees VALUES
(1001,NULL,'President',185000),(2002,1001,'Director',120000),
(3003,1001,'Office Manager',97000),(4004,2002,'Engineer',110000),
(5005,2002,'Engineer',142000),(6006,2002,'Engineer',160000);
GO

---------------------
---------------------
WITH cte_Recursion AS
(
SELECT  EmployeeID,
        ManagerID,
        JobTitle,
        Salary,
        0 AS Depth
FROM    #Employees a
WHERE   ManagerID IS NULL
UNION ALL
SELECT  b.EmployeeID,
        b.ManagerID,
        b.JobTitle,
        b.Salary,
        a.Depth + 1 AS Depth
FROM    cte_Recursion a INNER JOIN
        #Employees b ON a.EmployeeID = b.ManagerID
)
SELECT  EmployeeID, ManagerID, JobTitle, Salary, Depth
FROM    cte_Recursion;
GO
