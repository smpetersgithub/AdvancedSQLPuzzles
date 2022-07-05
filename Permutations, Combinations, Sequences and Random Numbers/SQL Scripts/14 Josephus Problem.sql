/*********************************************************************
Scott Peters
Josephus Problem
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• For this puzzle a SEQUENCE object is created, which is harcoded with the number of soldiers
• Once a sequence table is created, simply loop through the table to find the surviving soldier
• This solution uses a set based solution where I populate a #Numbers table in excess of the cycles needed
     1) An assumption is made to how many records are inserted into the #Numbers table
     2) The #Numbers table must be populated with more rows needed than the number of cycles through the count of soldiers

**********************************************************************/

-------------------------------
-------------------------------
--Tables used
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #Soldiers;
DROP SEQUENCE IF EXISTS JosephusSequence
GO

-------------------------------
-------------------------------
--Create sequence dbo.JosephusSequence
--Set the MAXVALUE to the number of soldiers
CREATE SEQUENCE dbo.JosephusSequence AS TINYINT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 4-----------------Set to number of soldiers
    CYCLE;
GO

-------------------------------
-------------------------------
--Create and populate a #Numbers table
DECLARE @vTotalNumbers INTEGER = 4;

WITH cte_Number (Number)
AS (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Number
    WHERE  Number <= @vTotalNumbers
    )
SELECT Number
INTO   #Numbers
FROM   cte_Number;
GO

-------------------------------
-------------------------------
--Create table #Soldiers
CREATE TABLE #Soldiers
(
RowNumber       INTEGER IDENTITY(1,1) PRIMARY KEY,
SoldierNumber   INTEGER NOT NULL,
Iterator        INTEGER NULL,
UpdateDate      DATETIME NULL
);
GO

-------------------------------
-------------------------------
--Insert into #Soldiers using #Numbers table
INSERT INTO #Soldiers (SoldierNumber)
SELECT  (NEXT VALUE FOR dbo.JosephusSequence)
FROM    #Numbers;
GO

-------------------------------
-------------------------------
--Declare and set variables
DECLARE @vCycle INTEGER = 2;
DECLARE @vIterator INTEGER = 1;

-------------------------------
-------------------------------
--Seed the #Soldiers table
UPDATE  #Soldiers
SET     Iterator = @vIterator,
        UpdateDate = GETDATE()
WHERE   SoldierNumber = @vCycle;

-------------------------------
-------------------------------
--Use a WHILE loop to determine which order soilders are killed
WHILE (SELECT COUNT(DISTINCT SoldierNumber) FROM #Soldiers WHERE Iterator IS NULL) > 1
        BEGIN

        SET @vIterator = @vIterator + 1;
        PRINT(@vIterator);

        DROP TABLE IF EXISTS #SoldiersTemp;

        WITH cte_RowNumberEstablish AS
        (
        SELECT  ROW_NUMBER() OVER (ORDER BY RowNumber) AS RowNumberNew,
                *
        FROM    #Soldiers
        WHERE   Iterator IS NULL AND
                RowNumber > (SELECT MIN(RowNumber) FROM #Soldiers WHERE Iterator = @vIterator - 1)
        )
        SELECT *
        INTO    #SoldiersTemp
        FROM cte_RowNumberEstablish;
        
        UPDATE #Soldiers
        SET    Iterator = @vIterator,
                UpdateDate = GETDATE()
        FROM    #Soldiers a
        WHERE   a.SoldierNumber IN (SELECT SoldierNumber FROM #SoldiersTemp WHERE RowNumberNew = @vIterator)

       IF @@ROWCOUNT = 0
        BEGIN
        PRINT '@@ROWCOUNT Returned 0.  Increase The Size Of The Numbers Table';
        RETURN
        END

        END;  --End Loop

-------------------------------
-------------------------------
--Display the results
SELECT  
        SoldierNumber,
        UpdateDate,
        Iterator,
        (CASE WHEN UpdateDate IS NULL THEN 'Winner' END) AS Status
FROM    #Soldiers
GROUP BY SoldierNumber,
        UpdateDate,
        Iterator
ORDER BY (CASE WHEN UpdateDate IS NULL THEN GETDATE() ELSE UpdateDate END);



