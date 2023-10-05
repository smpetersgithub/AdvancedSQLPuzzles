/*********************************************************************
Scott Peters
Seating Chart
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

The script then uses several SQL statements to analyze the data in the #SeatingChart table. 
The first query uses the LEAD() window function to find the gaps in the seat numbers and 
returns the gap start and gap end values. 

The second query uses a common table expression (CTE) and the ROW_NUMBER() function to find 
the missing seat numbers by ranking them and calculating the difference 
between each seat number and its rank. The last query uses the COUNT() function and 
a CASE statement to determine the number of odd and even seat numbers in the #SeatingChart table.

**********************************************************************/

--------------
--------------
--Tables Used
DROP TABLE IF EXISTS #SeatingChart;
GO

--------------
--------------
--Create and populate #SeatingChart
CREATE TABLE #SeatingChart
(
SeatNumber INTEGER PRIMARY KEY
);
GO

INSERT INTO #SeatingChart VALUES
(7),(13),(14),(15),(27),(28),(29),(30),(31),(32),(33),(34),(35),(52),(53),(54);
GO

--------------
--------------
--Place a value of 0 in the SeatingChart table
INSERT INTO #SeatingChart VALUES (0);
GO

--------------
--------------
--Gap start and gap end
SELECT  GapStart + 1 AS GapStart,
        GapEnd - 1 AS GapEnd
FROM
    (
    SELECT  SeatNumber AS GapStart,
        LEAD(SeatNumber,1,0) OVER (ORDER BY SeatNumber) AS GapEnd,
        LEAD(SeatNumber,1,0) OVER (ORDER BY SeatNumber) - SeatNumber AS Gap
    FROM #SeatingChart
    ) a
WHERE Gap > 1;

--Missing Numbers
WITH cte_Rank
AS
(
SELECT  SeatNumber,
        ROW_NUMBER() OVER (ORDER BY SeatNumber) AS RowNumber,
        SeatNumber - ROW_NUMBER() OVER (ORDER BY SeatNumber) AS Rnk
FROM    #SeatingChart
WHERE   SeatNumber > 0
)
SELECT MAX(Rnk) AS MissingNumbers FROM cte_Rank;

--Odd and even number count
SELECT  (CASE SeatNumber%2 WHEN 1 THEN 'Odd' WHEN 0 THEN 'Even' END) AS Modulus,
        COUNT(*) AS [Count]
FROM    #SeatingChart
GROUP BY (CASE SeatNumber%2 WHEN 1 THEN 'Odd' WHEN 0 THEN 'Even' END);
