/*********************************************************************
Scott Peters
Growing Numbers
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• Determining permutations can be performed with a recursive CTE; this solution uses a WHILE loop
• This solution simply initializes a start and end variable and uses a WHILE loop
• Output is saved in the temporary table #Permutations

**********************************************************************/

---------------------
---------------------
--Tables used
DROP TABLE IF EXISTS #Permutations;
GO

---------------------
---------------------
--Create #Permuations table
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
--Populate the #Permuations table
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
