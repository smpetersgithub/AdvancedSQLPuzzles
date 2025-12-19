/*********************************************************************
Scott Peters
Growing Numbers
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL
**********************************************************************/

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Permutations;
GO

---------------------
---------------------
--Create #Permutations table
CREATE TABLE #Permutations
(
Number BIGINT UNIQUE NOT NULL
);
GO

---------------------
---------------------
--Declare and set variables
DECLARE @vStart INT = 1;
DECLARE @vEnd INT = 5;
DECLARE @number BIGINT;

---------------------
---------------------
--Populate the #Permutations table
WHILE @vStart <= @vEnd
	BEGIN

	SELECT @number = MAX(Number) FROM #Permutations;

	INSERT INTO	#Permutations
	SELECT CAST(CONCAT(@number,@vStart) AS BIGINT);

	SET @vStart = @vStart + 1;

	END
GO
---------------------
---------------------
--Display the results
SELECT * FROM #Permutations;
GO

