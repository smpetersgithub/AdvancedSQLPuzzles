/*********************************************************************
Scott Peters
Non-Overlapping Sets
https://advancedsqlpuzzles.com
Last Updated: 03/29/2023

Microsoft SQL Server T-SQL

This script consists of an SQL function definition and a series of SQL queries to perform various data manipulations.
The function defined in the script is named dbo.fnCompareStrings. This function takes two input strings, @string1 and @string2, and returns a BIT value indicating whether at least one letter (case-sensitive) from @string1 is found in @string2. The function ignores non-letter characters, such as commas and hyphens. Several examples are provided to illustrate how to use the function.
The script then creates several temporary tables that store intermediate results for the subsequent queries.
The first table, #Orders, contains a list of orders, their line items, and the cost associated with each line item. This table is used as the starting point for most of the subsequent queries.
The second table, #MyAlphabet, contains a list of letters in the alphabet and their corresponding ASCII values. This table is used to generate all possible combinations of two letters.
The third table, #AlphabetTranslation, contains a translation of the two-letter combinations generated from #MyAlphabet into a format that can be used in subsequent queries.
The fourth table, #OrdersSetsOverEvaluation, is used to identify pairs of line items within each order whose total cost is greater than or equal to a given threshold value.
The fifth table, #OrdersSetsOverEvaluationFinal, generates all possible combinations of line item pairs from #OrdersSetsOverEvaluation.
The sixth table, #OrdersDetermineCombinations, is used to split the combinations of line item pairs into individual elements and translate those elements into the format used in #AlphabetTranslation.
The seventh table, #OrdersCombinationsFinal, is the final output table. It lists the maximum number of non-overlapping sets of line items for each order and the sets themselves.

**********************************************************************/

CREATE OR ALTER FUNCTION fnCompareStrings
(
/*----------------------------------------------------
 This user-defined function dbo.fnCompareStrings takes two input strings, @string1 and @string2.
 The function returns a BIT value, where 1 (True) indicates that at least one letter (case-sensitive)
 from @string1 is found in @string2, and 0 (False) indicates no letters from @string1 are found in @string2.
 The function ignores non-letter characters, such as commas and hyphens.

 Example usage:
   SELECT dbo.fnCompareStrings('a', 'a'); ---- Returns True (1)
   SELECT dbo.fnCompareStrings('A', 'A'); ---- Returns True (1)
   SELECT dbo.fnCompareStrings('AB', 'AC'); -- Returns True (1)
   SELECT dbo.fnCompareStrings('a', 'b'); ---- Returns False (0)
   SELECT dbo.fnCompareStrings('A', 'a'); ---- Returns False (0)
   SELECT dbo.fnCompareStrings(',', ','); ---- Returns False (0)
   SELECT dbo.fnCompareStrings('-', '-'); ---- Returns False (0)
*/----------------------------------------------------

@string1 NVARCHAR(MAX),
@string2 NVARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
    DECLARE @i INT;
    DECLARE @char NVARCHAR(1);
    DECLARE @result BIT;
    DECLARE @pattern NVARCHAR(50) = '%[a-zA-Z]%';

    SET @result = 0;
    SET @i = 1;

    WHILE @i <= LEN(@string1) AND @result = 0
    BEGIN
        SET @char = SUBSTRING(@string1, @i, 1);

        IF CHARINDEX(@char, @string2 COLLATE Latin1_General_BIN) > 0 AND PATINDEX(@pattern, @char) > 0
        BEGIN
            SET @result = 1;
        END

        SET @i = @i + 1;
    END

    RETURN @result;
END;
GO
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS #Orders;
DROP TABLE IF EXISTS #OrdersSetsOverEvaluation;
DROP TABLE IF EXISTS #OrdersSetsOverEvaluationFinal;
DROP TABLE IF EXISTS #OrdersDetermineCombinations;
DROP TABLE IF EXISTS #OrdersCombinationsFinal;
DROP TABLE IF EXISTS #Alphabet;
DROP TABLE IF EXISTS #AlphabetTranslation;
GO

CREATE TABLE #OrdersCombinationsFinal
(
RowNumber  INTEGER NOT NULL,
OrderID    INTEGER NOT NULL,
MySet      VARCHAR(255) NOT NULL
);
GO

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

CREATE TABLE #Orders (
OrderID   INTEGER,
LineItem  INTEGER,
Cost      INTEGER
);
GO

INSERT INTO #Orders (OrderID, LineItem, Cost)
VALUES
(1,1,9),
(1,2,15),
(1,3,7),
(1,4,3),
(1,5,1),
(1,6,1),
(2,1,10),
(2,2,10),
(2,3,11),
(3,1,3),
(3,2,4);
GO

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

CREATE TABLE #MyAlphabet
(
ID      INTEGER NOT NULL,
Letter  CHAR(1) NOT NULL
);
GO

INSERT INTO #MyAlphabet (ID, Letter)
VALUES (1, CHAR(65)), (2, CHAR(66)), (3, CHAR(67)), (4, CHAR(68)), (5, CHAR(69)),
       (6, CHAR(70)), (7, CHAR(71)), (8, CHAR(72)), (9, CHAR(73)), (10, CHAR(74)),
       (11, CHAR(75)), (12, CHAR(76)), (13, CHAR(77)), (14, CHAR(78)), (15, CHAR(79)),
       (16, CHAR(80)), (17, CHAR(81)), (18, CHAR(82)), (19, CHAR(83)), (20, CHAR(84)),
       (21, CHAR(85)), (22, CHAR(86)), (23, CHAR(87)), (24, CHAR(88)), (25, CHAR(89)), (26, CHAR(90));
GO

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

WITH cte_Alphabet AS
(
SELECT  CONCAT(a.Letter, b.Letter) AS MySetIndividual, CONCAT('(', a.ID, ',', b.ID, ')') AS Translation
FROM    #MyAlphabet a CROSS JOIN
        #MyAlphabet b
WHERE   a.ID <> b.ID
UNION
SELECT  Letter, CONCAT('(',ID,')') AS Translation
FROM    #MyAlphabet
)
SELECT ROW_NUMBER() OVER (ORDER BY MySetIndividual) AS RowNumber,
       *
INTO   #AlphabetTranslation
FROM   cte_Alphabet
GO

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

DECLARE @vTotalCostEvaluate INTEGER = 10;

WITH cte_rank AS
(
SELECT a.OrderID, a.LineItem AS LineItem1, b.LineItem AS LineItem2, a.Cost + b.Cost AS TotalCost
FROM   #Orders a INNER JOIN
       #Orders b ON a.OrderID = b.OrderID AND a.LineItem < b.LineItem
WHERE  a.Cost + b.Cost >= @vTotalCostEvaluate
       AND a.Cost < @vTotalCostEvaluate AND a.Cost < @vTotalCostEvaluate -----Variable used here
UNION
SELECT a.OrderID, a.LineItem, NULL, a.Cost AS TotalCost
FROM   #Orders a
WHERE  a.Cost >= @vTotalCostEvaluate------------------------------------------Variable used here
)
SELECT *,
       CHAR(LineItem1+64) AS CharAsciiValue1,
       CHAR(LineItem2+64) AS CharAsciiValue2,
       CONCAT(CHAR(LineItem1+64),CHAR(LineItem2+64)) AS MySet
INTO   #OrdersSetsOverEvaluation
FROM   cte_rank
GO

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--Seed the table
DECLARE @InsertSequenceNumber INTEGER = 1;

SELECT @InsertSequenceNumber AS InsertSequenceNumber,
       OrderID, CAST(MySet AS VARCHAR(8000)) AS MySet
INTO   #OrdersSetsOverEvaluationFinal
FROM   #OrdersSetsOverEvaluation;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

WHILE @@RowCount > 0
BEGIN

    SET @InsertSequenceNumber = @InsertSequenceNumber + 1;

    INSERT INTO #OrdersSetsOverEvaluationFinal
    SELECT  @InsertSequenceNumber,
            a.OrderID,
            CONCAT(a.MySet,',',b.MySet)
    FROM    #OrdersSetsOverEvaluationFinal a INNER JOIN
            #OrdersSetsOverEvaluation b ON a.OrderID = b.OrderID
    WHERE   InsertSequenceNumber = (SELECT MAX(InsertSequenceNumber) FROM #OrdersSetsOverEvaluationFinal) AND
            dbo.fnCompareStrings(a.MySet,b.MySet) = 0;
END;
GO

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

WITH cte_MaxInsertDate AS
(
SELECT  MAX(InsertSequenceNumber) AS MaxSequenceNumber,
        OrderID
FROM    #OrdersSetsOverEvaluationFinal
GROUP BY OrderID
),
cte_Permutations AS
(
SELECT  a.*
FROM    #OrdersSetsOverEvaluationFinal a INNER JOIN
        cte_MaxInsertDate b ON a.OrderID = b.OrderID AND a.InsertSequenceNumber = b.MaxSequenceNumber
),
cte_PermutationLength AS
(
SELECT  OrderID, MySet, MAX(LEN(MySet) - LEN(REPLACE(MySet,',','')) + 1) AS MaxNumberSets
FROM    cte_permutations
GROUP BY OrderID, MySet
)
SELECT  ROW_NUMBER() OVER(ORDER BY OrderID, MySet) AS RowNumber,
        *, CAST(NULL AS VARCHAR(8000)) AS MySetOrdered
INTO    #OrdersDetermineCombinations
FROM    cte_PermutationLength;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

WHILE @@ROWCOUNT > 0
BEGIN
    WITH cte_StringSplit AS
    (
    SELECT  a.*, b.Value
    FROM    #OrdersDetermineCombinations a CROSS APPLY
            STRING_SPLIT(a.MySet,',') b
    WHERE   RowNumber = (SELECT MIN(RowNumber) FROM #OrdersDetermineCombinations WHERE MySetOrdered IS NULL)
    ),
    cte_StringSplitTranslation AS
    (
    SELECT  a.*, b.Translation AS ValueTranslation
    FROM    cte_StringSplit a INNER JOIN
            #AlphabetTranslation b ON a.Value = b.MySetIndividual
    ),
    cte_StringAgg AS
    (
    SELECT  RowNumber, STRING_AGG(ValueTranslation, ',') WITHIN GROUP (ORDER BY ValueTranslation ASC) AS MySetOrdered
    FROM    cte_StringSplitTranslation
    GROUP BY RowNumber
    )
    UPDATE #OrdersDetermineCombinations
    SET    MySetOrdered = a.MySetOrdered
    FROM   cte_StringAgg a INNER JOIN
           #OrdersDetermineCombinations b ON a.RowNumber = b.RowNumber;
END;
GO

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

WITH cte_OrdersDetermineCombinations AS
(
SELECT  DISTINCT
        OrderID,
        MaxNumberSets AS SetCount,
        MySetOrdered AS SetCombinations
FROM    #OrdersDetermineCombinations
)
SELECT  *
FROM    cte_OrdersDetermineCombinations
UNION
SELECT  DISTINCT OrderID, 0, NULL
FROM    #Orders
WHERE   OrderID NOT IN (SELECT OrderID FROM cte_OrdersDetermineCombinations)
ORDER BY 1,2,3;
GO
