/*********************************************************************
Scott Peters
Birthday Problem
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL

This script runs a simulation of the Birthday Problem.
https://en.wikipedia.org/wiki/Birthday_problem

This script uses several tables, including #Birthdays, #BirthDaysHistory, #BirthdaysPercentile, and #Numbers. 
The script uses variables to set the total number of people in the simulation and the number of 
iterations to run the simulation. The script uses a while loop to run the simulation and check 
if the number of iterations has been reached. Within the while loop, the script uses recursion 
to create a table of random birthdays for a set number of people. It then uses a join to find 
the first pair of people with the same birthday and saves that information in the #BirthDaysHistory table. 
After completing the loop, it creates a percentile table using the information from #BirthDaysHistory, 
and fills in any missing values with a percentile of 0 or 100. The final table shows the number of people 
needed for the first pair to have the same birthday and the corresponding percentile for that number of people.

**********************************************************************/

---------------------
---------------------
--Tables used in script
DROP TABLE IF EXISTS #Birthdays;
DROP TABLE IF EXISTS #BirthDaysHistory;
DROP TABLE IF EXISTS #BirthdaysPercentile;
DROP TABLE IF EXISTS #Numbers;
GO

---------------------
---------------------
--Create #BirthDaysHistory table
CREATE TABLE #BirthDaysHistory
(
PersonWhoMatchesFill INTEGER IDENTITY(1,1) PRIMARY KEY,
PersonWhoMatches INTEGER
);
GO

---------------------
---------------------
--Declare and set and variables
DECLARE @vTotalNumbers INTEGER = 365;
DECLARE @vIterations INTEGER = 10000;

---------------------
---------------------
--Begin loop
WHILE (SELECT COUNT(*) FROM #BirthDaysHistory) < @vIterations 
     BEGIN

     -------------------------------
     -------------------------------
     --Create and populate a #Birthdays table using recursion
     DROP TABLE IF EXISTS #Birthdays;
     WITH cte_Number (Number)
     AS (
         SELECT 1 AS Number
         UNION ALL
         SELECT  Number + 1
         FROM   cte_Number
         WHERE  Number < @vTotalNumbers
         )
     SELECT Number AS Person,
            ABS(CHECKSUM(NEWID()) % 365) + 1 AS Birthday
     INTO   #Birthdays
     FROM   cte_Number
     OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level

	 -------------------------------
     -------------------------------
     --Create and populate a #BirthDaysHistory table
     WITH
     cte_Join 
     AS
     (
     SELECT  ROW_NUMBER() OVER (PARTITION BY a.Birthday ORDER BY a.Person) AS PersonWhoMatchesFill,
             a.*,
             b.Person as LinkingPerson,
             b.Person - a.Person AS Distance
     FROM    #Birthdays a INNER JOIN
             #Birthdays b ON a.BirthDay = b.Birthday AND a.Person < b.Person
     ),
     cte_Min AS
     (
     SELECT  DISTINCT
             Person,
             BirthDay,
             MIN(LinkingPerson) AS LinkingNumber,
             MIN(LinkingPerson) - Person AS Distance
     FROM    cte_Join
     GROUP BY Person,
             BirthDay
     )
     INSERT INTO #BirthDaysHistory (PersonWhoMatches)
     SELECT MIN(LinkingNumber) 
     FROM cte_Min;

     END;

-------------------------------
-------------------------------
--Create a #Numbers table
DROP TABLE IF EXISTS #Numbers;

WITH cte_Number (Number)
AS (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Number
    WHERE  Number < 365
    )
SELECT Number
INTO   #Numbers
FROM   cte_Number
OPTION (MAXRECURSION 0);--A value of 0 means no limit to the recursion level

---------------------
---------------------
--Create the #BirthdaysPercentile table
--Fill in missing PersonsWhoMatches from the #Numbers table
WITH cte_Percentile AS
(
SELECT  DISTINCT
        PersonWhoMatches,
        PERCENT_RANK() OVER (ORDER BY PersonWhoMatches) * 100 AS Percentile
FROM    #BirthDaysHistory b
)
SELECT	ROW_NUMBER() OVER (ORDER BY a.Number ASC) AS PersonWhoMatchesFill,
		a.Number,
		b.PersonWhoMatches,
		CAST(CASE	WHEN a.Number = 1 THEN 0 
					when a.Number = @vTotalNumbers THEN 100 
					ELSE b.Percentile END AS VARCHAR(500))
				AS Percentile
INTO	#BirthdaysPercentile
FROM	#Numbers A LEFT OUTER JOIN
		cte_Percentile b on a.Number = b.PersonWhoMatches
ORDER BY 1;

---------------------
---------------------
--Performs a flash fill
--Displays the results
SELECT  a.PersonWhoMatchesFill,
        (SELECT b.Percentile AS PercentileFill
        FROM    #BirthdaysPercentile b
        WHERE   b.PersonWhoMatchesFill =
                    (SELECT MAX(c.PersonWhoMatchesFill)
                    FROM #BirthdaysPercentile c
                    WHERE c.PersonWhoMatchesFill <= a.PersonWhoMatchesFill AND c.Percentile != '')
		) PercentileFill
FROM #BirthdaysPercentile a
ORDER BY 1;
GO
