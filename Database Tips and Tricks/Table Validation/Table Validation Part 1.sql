/*----------------------------------------------------
Scott Peters
Dynamic Full Outer Joins
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL

This script creates and populates the ##TableInformation
with the necessary information to perform a dynamic full outer join.

*/----------------------------------------------------

DROP TABLE IF EXISTS ##TableInformation;
GO

CREATE TABLE ##TableInformation
(LookupID SMALLINT PRIMARY KEY,
Schema1Name VARCHAR(250) NOT NULL,
Schema2Name VARCHAR(250) NOT NULL,
Table1Name VARCHAR(250) NOT NULL,
Table2Name VARCHAR(250) NOT NULL,
Exists1 VARCHAR(1000) NOT NULL,    -- Join condition between Table 1 and Table 2
Exists2 VARCHAR(1000) NOT NULL);   -- Join condition between Table 1 and Table 2
GO

INSERT INTO ##TableInformation VALUES (
1---------------LookupID
,'dbo'----------Schema1Name
,'dbo'----------Schema2Name
,'Sales_New'-----Table1Name
,'Sales_Old'-----Table2Name
,'CONCAT(t1.CustID, t1.Region, t1.City)'--Exists1 (this must have the prefix "t1.")
,'CONCAT(t2.CustID, t2.Region, t2.City)'--Exists2 (this must have the prefix "t2.")
);
GO
