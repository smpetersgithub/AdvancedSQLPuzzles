/*********************************************************************
Answer to Puzzle #6
High Low Card Game
https://AdvancedSQLPuzzles.com

Developer Notes:

Here are the steps I use to solve the problem.

1) INSERT a deck of cards into table ##CardDeck
2) Shuffle the cards and INSERT the cards into ##CardDeckSchuffled
3) Draw a card and INSERT this card into ##CardDeckPlayed
4) Predict the outcome of the value of the next card and UPDATE the ##CardDeckPlayed with the prediction
5) Draw the next card in the deck from the table ##CardDeckSchuffled
6) UPDATE the ##CardDeckPlayed with the outcome of the prediction

**********************************************************************/

IF OBJECT_ID('tempdb.dbo.##CardDeck','U') IS NOT NULL
  DROP TABLE ##CardDeck;
GO

IF OBJECT_ID('tempdb.dbo.##CardDeckShuffled','U') IS NOT NULL
  DROP TABLE ##CardDeckShuffled;
GO

IF OBJECT_ID('tempdb.dbo.##CardDeckPlayed','U') IS NOT NULL
  DROP TABLE ##CardDeckPlayed;
GO

CREATE TABLE ##CardDeck
(
RandomNumber UNIQUEIDENTIFIER DEFAULT NEWID(),
CardValue INTEGER,
Suit VARCHAR(10),
CardDescription VARCHAR(10)
);
GO

INSERT INTO ##CardDeck (CardValue, Suit, CardDescription)
VALUES
(2,'Spades','Two'),
(3,'Spades','Three'),
(4,'Spades','Four'),
(5,'Spades','Five'),
(6,'Spades','Six'),
(7,'Spades','Seven'),
(8,'Spades','Eight'),
(9,'Spades','Nine'),
(10,'Spades','Ten'),
(11,'Spades','Jack'),
(12,'Spades','Queen'),
(13,'Spades','King'),
(14,'Spades','Ace'),
(2,'Clubs','Two'),
(3,'Clubs','Three'),
(4,'Clubs','Four'),
(5,'Clubs','Five'),
(6,'Clubs','Six'),
(7,'Clubs','Seven'),
(8,'Clubs','Eight'),
(9,'Clubs','Nine'),
(10,'Clubs','Ten'),
(11,'Clubs','Jack'),
(12,'Clubs','Queen'),
(13,'Clubs','King'),
(14,'Clubs','Ace'),
(2,'Hearts','Two'),
(3,'Hearts','Three'),
(4,'Hearts','Four'),
(5,'Hearts','Five'),
(6,'Hearts','Six'),
(7,'Hearts','Seven'),
(8,'Hearts','Eight'),
(9,'Hearts','Nine'),
(10,'Hearts','Ten'),
(11,'Hearts','Jack'),
(12,'Hearts','Queen'),
(13,'Hearts','King'),
(14,'Hearts','Ace'),
(2,'Diamonds','Two'),
(3,'Diamonds','Three'),
(4,'Diamonds','Four'),
(5,'Diamonds','Five'),
(6,'Diamonds','Six'),
(7,'Diamonds','Seven'),
(8,'Diamonds','Eight'),
(9,'Diamonds','Nine'),
(10,'Diamonds','Ten'),
(11,'Diamonds','Jack'),
(12,'Diamonds','Queen'),
(13,'Diamonds','King'),
(14,'Diamonds','Ace');
GO

CREATE TABLE ##CardDeckPlayed
(
RowNumber INTEGER,
CardValue INTEGER,
Suit VARCHAR(10),
CardDescription VARCHAR(10),
PercentNextCardIsHigher FLOAT,
PercentNextCardIsLower FLOAT,
PercentNextCardIsSame FLOAT,
NextCardValue INTEGER,
Prediction VARCHAR(1000),
Outcome BIT
);
GO

DECLARE @vCurrentCardValue INTEGER;
DECLARE @vRowNumber INTEGER = 1;

DECLARE @vTotalCardsPlayed FLOAT;
DECLARE @vTotalCardsHigher FLOAT;
DECLARE @vTotalCardsLower FLOAT;
DECLARE @vTotalCardsSame FLOAT = 4;
DECLARE @vTotalCardsPlayedHigher FLOAT;
DECLARE @vTotalCardsPlayedLower FLOAT;
DECLARE @vTotalCardsPlayedSame FLOAT;
DECLARE @vPercentHigher FLOAT;
DECLARE @vPercentLower FLOAT;
DECLARE @vPercentSame FLOAT;

DECLARE @vLastPlayedCard INTEGER /*Used in the print statement*/

--Schuffle the cards
SELECT	Row_Number() OVER (ORDER BY RandomNumber) as RowNumber,
		*
INTO	##CardDeckShuffled
FROM	##CardDeck
ORDER BY 1;


--Begin Loop
WHILE @vRowNumber <= 52
	BEGIN
	
	--Draw a card and insert into table
	INSERT INTO ##CardDeckPlayed (RowNumber, CardValue, Suit, CardDescription)
	SELECT	RowNumber,
			CardValue,
			Suit,
			CardDescription
	FROM	##CardDeckShuffled
	WHERE	RowNumber = @vRowNumber;

	--If its the last card, exit the predictions
	IF @vRowNumber = 52 BREAK

	--Read the card
	SELECT	@vCurrentCardValue = CardValue,
			@vRowNumber = RowNumber
	FROM	##CardDeckPlayed
	WHERE	RowNumber = @vRowNumber;
	
	--Determine prediction
	SELECT	@vTotalCardsPlayed = COUNT(*)
	FROM	##CardDeckPlayed;
	
	SELECT	@vTotalCardsHigher = COUNT(*)
	FROM	##CardDeckShuffled
	WHERE	CardValue > @vCurrentCardValue;
	
	SELECT	@vTotalCardsLower = COUNT(*)
	FROM	##CardDeckShuffled
	WHERE	CardValue < @vCurrentCardValue;

	SELECT	@vTotalCardsPlayedHigher = COUNT(*)
	FROM	##CardDeckPlayed
	WHERE	CardValue > @vCurrentCardValue;
	
	SELECT	@vTotalCardsPlayedLower = COUNT(*)
	FROM	##CardDeckPlayed
	WHERE	CardValue < @vCurrentCardValue;
	
	SELECT	@vTotalCardsPlayedSame = COUNT(*)
	FROM	##CardDeckPlayed
	WHERE	CardValue = @vCurrentCardValue;


	--Percentage that the next card is higher
	SET @vPercentHigher = (@vTotalCardsHigher - @vTotalCardsPlayedHigher) / (52 - @vTotalCardsPlayed);

	--Percentage that the next card is lower
	SET @vPercentLower = (@vTotalCardsLower - @vTotalCardsPlayedLower) / (52 - @vTotalCardsPlayed);
	
	--Percentage that the next card is same
	SET @vPercentSame = (@vTotalCardsSame - @vTotalCardsPlayedSame) / (52 - @vTotalCardsPlayed);
	
	--Update table with percentages
	UPDATE	##CardDeckPlayed
	SET		PercentNextCardIsHigher = @vPercentHigher,
			PercentNextCardisLower = @vPercentLower,
			PercentNextCardisSame = @vPercentSame
	WHERE	RowNumber = @vRowNumber;
	
	--Increase the iterator
	SET @vRowNumber = @vRowNumber + 1;

	--Read the next card
	SELECT	@vCurrentCardValue = CardValue,
			@vRowNumber = RowNumber
	FROM	##CardDeckShuffled
	WHERE	RowNumber = @vRowNumber;

	--Determine the prediciton
	UPDATE	##CardDeckPlayed
	SET	NextCardValue = @vCurrentCardValue,
		Prediction = 
			CASE 
			WHEN	@vPercentHigher > @vPercentLower AND
					@vPercentHigher > @vPercentSame THEN 'Prediciton - Higher'
			WHEN	@vPercentLower > @vPercentHigher AND
					@vPercentLower > @vPercentSame THEN 'Prediciton - Lower'
			WHEN	--Scenario 1 - Two matching predicitons
					@vPercentHigher = @vPercentLower OR 
					--Scenario 2 - The prediction of same is the highest prediction
					@vPercentSame > @vPercentHigher AND
					@vPercentSame > @vPercentLower
			THEN 	(CASE	WHEN SUBSTRING(CAST(RAND() AS VARCHAR),3,1) IN ('0','1','2','3','4') 
							THEN 'Guessing - Higher' ELSE 'Guessing - Lower' END) 
			END
	WHERE	RowNumber = @vRowNumber - 1;--Remmeber i increased the incrementer above

	--Was the prediction correct?
	UPDATE	##CardDeckPlayed
	SET	Outcome = 
			CASE
			WHEN	Prediction LIKE '%Higher%' AND CardValue < NextCardValue 
			THEN 1
			WHEN	Prediction LIKE '%Lower%' AND CardValue > NextCardValue 
			THEN 1
			ELSE	0 END
	WHERE	RowNumber = @vRowNumber - 1;

	END;

SELECT * FROM ##CardDeckPlayed;


