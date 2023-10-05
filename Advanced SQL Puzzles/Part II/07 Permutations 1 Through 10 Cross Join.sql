/*---------------------------------------------------------------------------------------------
Scott Peters
Permutations 1 Through 10 (Cross Join)
https://advancedsqlpuzzles.com
Last Updated: 01/13/2023
Microsoft SQL Server T-SQL

This script generates permutations of digits from 1 to 10. It uses a table called #Numbers 
which is populated with the numbers 1 through 10. The script then uses CROSS JOINs to 
join the #Numbers table multiple times to generate permutations of various lengths 
(two digits, three digits, four digits, etc.) with the result set in the format of a concatenated 
string (e.g. "1,2,3"). The final query in each block filters out the permutations where 
the same number is repeated in the permutation. The script can be modified to generate 
permutations of any desired length by adding or removing CROSS JOINs and adjusting the 
number of columns in the SELECT statement's CONCAT function.

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

----And so on and so forth for 5,6,7.....
