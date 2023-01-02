/*********************************************************************
Scott Peters
Merge Overlapping Records
https://advancedsqlpuzzles.com
Last Updated: 07/25/2022

This script is written in SQL Server's T-SQL

---------------------------------------------------------------------

Script merges overlapping records
I have broken the script into multiple steps to aid in understanding

**********************************************************************/
---------------------
---------------------
--Tables used in script
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #Distinct_StartIntegers;
DROP TABLE IF EXISTS #OuterJoin;
DROP TABLE IF EXISTS #DetermineValidEndIntegers;
DROP TABLE IF EXISTS #DetermineValidEndIntegers2;
GO

---------------------
---------------------
--Create and populate #Numbers table
CREATE TABLE #Numbers
(
StartInteger   INTEGER,
EndInteger     INTEGER
);
GO

INSERT INTO #Numbers VALUES
(1,5),
(1,3),
(1,2),
(3,9),
(10,11),
(12,16),
(15,19);
GO

---------------------
---------------------
--Create and populate #Distinct_StartIntegers table
--Step 1
SELECT  DISTINCT
        StartInteger
INTO    #Distinct_StartIntegers
FROM    #Numbers;
GO

---------------------
---------------------
--Create and populate #OuterJoin table
--Step 2
SELECT  a.StartInteger AS StartInteger_A,
        a.EndInteger AS EndInteger_A,
        b.StartInteger AS StartInteger_B,
        b.EndInteger AS EndInteger_B
INTO    #OuterJoin
FROM    #Numbers AS a LEFT OUTER JOIN
        #Numbers AS b ON a.EndInteger >= b.StartInteger AND
                                a.EndInteger < b.EndInteger;
GO

---------------------
---------------------
--Create and populate #DetermineValidEndIntegers table
--Step 3
SELECT  EndInteger_A
INTO    #DetermineValidEndIntegers
FROM    #OuterJoin
WHERE   StartInteger_B IS NULL
GROUP BY EndInteger_A;
GO

---------------------
---------------------
--Create and populate #DetermineValidEndIntegers2 table
--Step 4
SELECT  a.StartInteger, MIN(b.EndInteger_A) AS MinEndInteger_A
INTO    #DetermineValidEndIntegers2
FROM    #Distinct_StartIntegers a INNER JOIN
        #DetermineValidEndIntegers b ON a.StartInteger <= b.EndInteger_A
GROUP BY a.StartInteger
GO

---------------------
---------------------
--Display the results
--Step 5
SELECT  MIN(StartInteger) AS StartInteger,
        MAX(MinEndInteger_A) AS EndInteger
FROM    #DetermineValidEndIntegers2
GROUP BY MinEndInteger_A;
GO