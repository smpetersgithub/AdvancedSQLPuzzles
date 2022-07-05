/*********************************************************************
Scott Peters
Permutations 1 Through 10
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• This puzzle can more easily be solved using simple CROSS JOINS if the number of digits in the permutation is fixed
• This solution uses an initial numbers table (#Numbers) that must be populated
• This solution uses hardcoded joins and does not lend itself to changing requirements
• Although not recommended, you could modify this to use dynamic sql and build the query based upon the number of needed joins

**********************************************************************/

-------------------------------
-------------------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
GO
-------------------------------
-------------------------------
--Create #Numbers table and populate
SELECT  Number
INTO	#Numbers
FROM (VALUES (1), (2), (3), (4)) n(Number);
GO

-------------------------------
-------------------------------
--Two digits
SELECT  CONCAT(a.Number,',',b.Number) AS Permutation
FROM    #Numbers a INNER JOIN
        #Numbers b on a.Number <> b.Number;

--Two digits (Version 2)
SELECT  CONCAT(a.Number,',',b.Number) AS Permutation
FROM    #Numbers a CROSS JOIN
        #Numbers b
WHERE   a.Number NOT IN (b.Number)
ORDER BY 1;

-------------------------------
-------------------------------
--Three digits
SELECT  CONCAT(a.Number,',',b.Number,',',c.Number) AS Permutation
FROM    #Numbers a CROSS JOIN
        #Numbers b CROSS JOIN
        #Numbers c
WHERE   a.Number NOT IN (b.Number, c.Number) AND
        b.Number NOT IN (c.Number)
ORDER BY 1;

-------------------------------
-------------------------------
--Four digits
SELECT  CONCAT(a.Number,',',b.Number,',',c.Number,',',d.Number) AS Permutation
FROM    #Numbers a CROSS JOIN
        #Numbers b CROSS JOIN
        #Numbers c CROSS JOIN
        #Numbers d 
WHERE   a.Number NOT IN (b.Number, c.Number, d.Number) AND
        b.Number NOT IN (c.Number, d.Number) AND
        c.Number NOT IN (d.Number)
ORDER BY 1;


----And so on and so forth for 5,6,7.....