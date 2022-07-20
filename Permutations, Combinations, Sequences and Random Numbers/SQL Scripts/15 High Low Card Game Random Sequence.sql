/*********************************************************************
Scott Peters
High-Low Card Game
https://advancedsqlpuzzles.com
Last Updated: 07/05/2022

This script is written in SQL Server's T-SQL


• This solution uses the following concepts:
     1) A sequence generator to create a deck of cards, as we only care about the number value on the card and not its suite (Hearts, Diamonds, Clubs, Spades) 
     2) This solution also uses the UNIQUEIDENTIFIER data type to shuffle a deck of cards
     3) A random generator (0 or 1) to randomly choose a higher or lower prediction if both have the same probability 

• I use several temp tables for my solution rather than running UPDATE statements
     1) A #Numbers table is populated with 52 records, the size of a deck of cards
     2) The sequence CardDeckSequence is created that cycles every 13 numbers
     3) The #CardShuffle table is created using the UNIQUEIDENTIFIER data type to randomize the deck of cards and then populated using the CardDeckSequence
     4) I then use the following temp tables to create the solution, #CardShuffle2, #CardShuffle3, #CardShuffle4, and #CardShuffle5 
     5) The #CardShuffle2 table is created from #CardShuffle2 table, which adds a RowNumber column and is ordered by the RandomNumber field
     6) The #CardShuffle3 table is created from #CardShuffle2, where I determine the count of cards that are lower, higher or the same value that are ahead of it in the deck
     7) The #CardShuffle4 table is created from #CardShuffle3 where I use two CASE statements to determine the prediction and the outcome
     8) The #CardShuffle5 table is created from #CardShuffle4, where I determine if the prediction and the outcome are the same
     9) The #CardShuffleResults is created from #CardShuffle5 where I sum the results of correct predictions

**********************************************************************/

-------------------------------
-------------------------------
--Tables used
DROP SEQUENCE IF EXISTS dbo.CardDeckSequence; --Sequence
DROP TABLE IF EXISTS #Numbers;
DROP TABLE IF EXISTS #CardShuffle;
DROP TABLE IF EXISTS #CardShuffle2
DROP TABLE IF EXISTS #CardShuffle3
DROP TABLE IF EXISTS #CardShuffle4
DROP TABLE IF EXISTS #CardShuffle5
DROP TABLE IF EXISTS #CardShuffleResults
GO
-------------------------------
-------------------------------
--Create and populate a #Numbers table
WITH cte_Number (Number)
AS (
    SELECT 1 AS Number
    UNION ALL
    SELECT  Number + 1
    FROM   cte_Number
    WHERE  Number < 52 --52 cards in deck
    )
SELECT Number,
       (CASE Number WHEN 1 THEN 1 ELSE NULL END) AS Calculation
INTO   #Numbers
FROM   cte_Number;
GO
-------------------------------
-------------------------------
--Create sequence table
CREATE SEQUENCE dbo.CardDeckSequence AS TINYINT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 13
    CYCLE;
GO
-------------------------------
-------------------------------
--Create table #CardShuffle
CREATE TABLE #CardShuffle
(
RandomNumber UNIQUEIDENTIFIER DEFAULT NEWID(),
CardNumber   TINYINT
);
GO
-------------------------------
-------------------------------
--Create table #CardShuffleResults
CREATE TABLE #CardShuffleResults
(
Iteration INTEGER IDENTITY(1,1) PRIMARY KEY,
Result    INTEGER NOT NULL
);
GO
-------------------------------
-------------------------------
--Declare and set the variables
DECLARE @vIterations INTEGER = 1000;

-------------------------------
-------------------------------
--Begin WHILE loop
WHILE (SELECT COUNT(*) FROM #CardShuffleResults) <= @vIterations --Number of simulations to run
    BEGIN

    TRUNCATE TABLE #CardShuffle;
    DROP TABLE IF EXISTS #CardShuffle2
    DROP TABLE IF EXISTS #CardShuffle3
    DROP TABLE IF EXISTS #CardShuffle4
    DROP TABLE IF EXISTS #CardShuffle5

    INSERT INTO #CardShuffle (CardNumber)
    SELECT  (NEXT VALUE FOR dbo.CardDeckSequence)
    FROM    #Numbers;

    SELECT  ROW_NUMBER() OVER (ORDER BY RandomNumber) AS StepNumber,
            *
    INTO    #CardShuffle2
    FROM    #CardShuffle
    ORDER BY 1;

    SELECT  DISTINCT
            a.StepNumber,
            a.CardNumber,
            SUM(CASE WHEN a.CardNumber > b.CardNumber THEN 1 ELSE 0 END) AS LowerCardCount,
            SUM(CASE WHEN a.CardNumber < b.CardNumber THEN 1 ELSE 0 END) AS HigherCardCount,
            SUM(CASE WHEN a.CardNumber = b.CardNumber THEN 1 ELSE 0 END) AS SameCardCount
    INTO    #CardShuffle3
    FROM    #CardShuffle2 a LEFT OUTER JOIN
            #CardShuffle2 b on a.StepNumber < b.StepNumber
    GROUP BY a.StepNumber,
            a.CardNumber
    ORDER BY 1;

    SELECT  StepNumber,
            CardNumber,
            HigherCardCount,
            LowerCardCount,
            SameCardCount,
            LEAD(CardNumber,1) OVER (ORDER BY StepNumber) AS NextCardNumber,
            (CASE   WHEN HigherCardCount > LowerCardCount THEN 'Higher'
                    WHEN LowerCardCount > HigherCardCount THEN 'Lower'
                    WHEN LowerCardCount = HigherCardCount THEN IIF(ABS(CHECKSUM(NEWID()) % 2) + 1 = 1,'Higher','Lower') END) AS Prediction,
            (CASE   WHEN CardNumber < LEAD(CardNumber,1) OVER (ORDER BY StepNumber) THEN 'Higher'
                    WHEN CardNumber > LEAD(CardNumber,1) OVER (ORDER BY StepNumber) THEN 'Lower'
                    WHEN CardNumber = LEAD(CardNumber,1) OVER (ORDER BY StepNumber) THEN 'Same'
                    END) AS Outcome
    INTO    #CardShuffle4
    FROM    #CardShuffle3;

    SELECT  *,
            (CASE WHEN Prediction = Outcome THEN 1 ELSE 0 END) AS Result
    INTO    #CardShuffle5
    FROM    #CardShuffle4;

    INSERT INTO #CardShuffleResults (Result)
    SELECT  SUM(Result)
    FROM    #CardShuffle5;

    END--End Loop

-------------------------------
-------------------------------
--Display the results
SELECT * FROM #CardShuffleResults ORDER BY 2 DESC;
