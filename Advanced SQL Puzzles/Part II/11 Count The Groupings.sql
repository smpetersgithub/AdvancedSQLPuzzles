/*********************************************************************
Scott Peters
Count the Groupings
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

The script creates two temporary tables: #Groupings and #Groupings2. 
The #Groupings table contains test case information, including a step number, 
test case name, and status (Passed or Failed).

The script then uses a SELECT statement to insert data into the #Groupings2 table, 
which includes the StepNumber, Status, and a calculated column Rnk. 
The Rnk column is calculated using the ROW_NUMBER() function with a window frame 
defined by the "PARTITION BY [Status] ORDER BY StepNumber" clause. 
This results in a unique ranking for each group of test cases with the same status.

Finally, the script uses a SELECT statement with GROUP BY and aggregate functions to 
group the results in #Groupings2 by the Rnk column and the status. The query returns the minimum and 
maximum step numbers, the status, and the number of consecutive test cases in each group. 
The results are ordered by the minimum step number and status.

**********************************************************************/

--------------
--------------
--Tables Used
DROP TABLE IF EXISTS #Groupings;
DROP TABLE IF EXISTS #Groupings2;
GO

--------------
--------------
--Groupings
CREATE TABLE #Groupings
(
StepNumber  INTEGER PRIMARY KEY,
TestCase    VARCHAR(100),
[Status]    VARCHAR(100)
);
GO

INSERT INTO #Groupings VALUES
(1,'Test Case 1','Passed'),
(2,'Test Case 2','Passed'),
(3,'Test Case 3','Passed'),
(4,'Test Case 4','Passed'),
(5,'Test Case 5','Failed'),
(6,'Test Case 6','Failed'),
(7,'Test Case 7','Failed'),
(8,'Test Case 8','Failed'),
(9,'Test Case 9','Failed'),
(10,'Test Case 10','Passed'),
(11,'Test Case 11','Passed'),
(12,'Test Case 12','Passed');
GO

--------------
--------------
--Create and insert into #Groupings2
SELECT  StepNumber,
        [Status],
        StepNumber - ROW_NUMBER() OVER (PARTITION BY [Status] ORDER BY StepNumber) AS Rnk
INTO    #Groupings2
FROM    #Groupings
ORDER BY 2;
GO

--------------
--------------
--Display the results
SELECT  MIN(StepNumber) AS MinStepNumber,
        MAX(StepNumber) as MaxStepNumber,
        [Status],
        MAX(StepNumber) - MIN(StepNumber) + 1 AS ConsecutiveCount
FROM    #Groupings2
GROUP BY Rnk,
        [Status]
ORDER BY 1, 2;
GO
