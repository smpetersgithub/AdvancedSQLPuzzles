/*********************************************************************
Scott Peters
Growing Numbers
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL

This script finds all possible growing numbers from a set of integers within a specified range. 
For example, given the inputs 1, 2, 3, 4, and 5.  It will produce the following output:
1
12
123
1234
12345

The script creates a temporary table called #GrowingNumbers and uses a WHILE loop to populate it. 
The script initializes two variables, @vStart and @vEnd, to represent the range of integers  
used in the permutations. It then enters a WHILE loop that runs as long as @vStart is less than or 
equal to @vEnd. In each iteration of the loop, it selects the maximum value from the #GrowingNumbers table, 
concatenates it with the current value of @vStart, and inserts the resulting value into the #GrowingNumbers table. 
It then increments @vStart by 1. After the loop has completed, the script uses a SELECT statement to display 
the contents of the #GrowingNumbers table.

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
