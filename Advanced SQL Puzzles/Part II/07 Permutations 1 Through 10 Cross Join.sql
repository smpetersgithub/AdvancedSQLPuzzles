/*---------------------------------------------------------------------------------------------
Scott Peters
Permutations 1 Through 10 (Cross Join)
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL
*/---------------------------------------------------------------------------------------------

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
GO

--Two digits (Version 2)
SELECT  CONCAT(a.Number,',',b.Number) AS Permutation
FROM    #Numbers a CROSS JOIN
        #Numbers b
WHERE   a.Number NOT IN (b.Number)
ORDER BY 1;
GO

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
GO

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
GO

----And so on for 5,6,7.....
