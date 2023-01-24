/*********************************************************************
Scott Peters
Josephus Problem
https://advancedsqlpuzzles.com
Last Updated: 01/24/2023
Microsoft SQL Server T-SQL

This script runs an iteration of the Josephus Problem.
https://en.wikipedia.org/wiki/Josephus_problem

This script creates and populates a table of soldiers using a sequence. 
It then uses a while loop to determine which soldier is eliminated in each iteration, 
based on a specified cycle value. The script keeps track of the soldiers who have 
been eliminated and the order they were eliminated in and returns the soldier 
who is the last one remaining as the winner. The number of soldiers and the cycle 
value can be adjusted by changing the MAXVALUE of the sequence and the @vCycle 
variable respectively. The script also displays the result in order of 
elimination and indicates the winner.

**********************************************************************/
SET NOCOUNT ON;
GO

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
    MAXVALUE 14-----------------Set to number of soldiers
    CYCLE;
GO

-------------------------------
-------------------------------
--Create and populate a #Numbers table
DECLARE @vTotalNumbers INTEGER = 100;

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
DECLARE @vCycle INTEGER = 2;--------------------------------------------------
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

        DROP TABLE IF EXISTS #SoldiersTemp;

        WITH cte_RowNumberEstablish AS
        (
        SELECT  ROW_NUMBER() OVER (ORDER BY RowNumber) AS RowNumberNew,
                *
        FROM    #Soldiers
        WHERE   Iterator IS NULL AND
                RowNumber > (SELECT MIN(RowNumber) FROM #Soldiers WHERE Iterator = @vIterator)
        )
        SELECT  *
        INTO    #SoldiersTemp
        FROM    cte_RowNumberEstablish;
  

		SET @vIterator = @vIterator + 1;
        PRINT(@vIterator);


        UPDATE  #Soldiers
        SET     Iterator = @vIterator,
                UpdateDate = GETDATE()
        FROM    #Soldiers a
        WHERE   a.SoldierNumber IN (SELECT SoldierNumber FROM #SoldiersTemp WHERE RowNumberNew = @vCycle);

        END;  --End Loop
GO

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
GO
