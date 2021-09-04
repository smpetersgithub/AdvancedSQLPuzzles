/*********************************************************************
Answer to Puzzle #1
Double Or Add One
https://AdvancedSQLPuzzles.com

**********************************************************************/

DECLARE @vAmountToMatch MONEY = 1000000;
DECLARE @vCurrentAmount MONEY = .01;
DECLARE @vIntegerterator INTEGER = 0;
DECLARE @vDifference INTEGER;

WHILE @vCurrentAmount <= @vAmountToMatch
	BEGIN

	IF	(@vAmountToMatch - @vCurrentAmount) > @vCurrentAmount
		SET @vCurrentAmount = @vCurrentAmount * 2;
	ELSE BREAK;

	SET	@vIntegerterator = @vIntegerterator + 1;
	END

SET @vIntegerterator = @vIntegerterator + (@vAmountToMatch - @vCurrentAmount);

PRINT CONCAT('The least number of iterations to reach ',@vAmountToMatch,' is ',@vIntegerterator);