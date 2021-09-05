/***********************************************************************
Scott Peters
https://advancedsqlpuzzles.com

Baseball Balls and Strikes Answer
***********************************************************************/
IF OBJECT_ID('tempdb.dbo.#Pitches') IS NOT NULL
DROP TABLE #Pitches;

CREATE TABLE #Pitches
(
AtBatId INT,
PitchNumber INT,
Result VARCHAR(25)
PRIMARY KEY(AtBatId, PitchNumber)
)
INSERT INTO #Pitches SELECT 1, 1, 'Foul'
INSERT INTO #Pitches SELECT 1, 2, 'Foul'
INSERT INTO #Pitches SELECT 1, 3, 'Ball'
INSERT INTO #Pitches SELECT 1, 4, 'Ball'
INSERT INTO #Pitches SELECT 1, 5, 'Strike'
INSERT INTO #Pitches SELECT 2, 1, 'Ball'
INSERT INTO #Pitches SELECT 2, 2, 'Strike'
INSERT INTO #Pitches SELECT 2, 3, 'Foul'
INSERT INTO #Pitches SELECT 2, 4, 'Foul'
INSERT INTO #Pitches SELECT 2, 5, 'Foul'
INSERT INTO #Pitches SELECT 2, 6, 'In Play'
GO

--Additional Test Data
INSERT INTO #Pitches SELECT 3, 1, 'Ball'
INSERT INTO #Pitches SELECT 3, 2, 'Ball'
INSERT INTO #Pitches SELECT 3, 3, 'Ball'
INSERT INTO #Pitches SELECT 3, 4, 'Ball'
INSERT INTO #Pitches SELECT 4, 1, 'Foul'
INSERT INTO #Pitches SELECT 4, 2, 'Foul'
INSERT INTO #Pitches SELECT 4, 3, 'Foul'
INSERT INTO #Pitches SELECT 4, 4, 'Foul'
INSERT INTO #Pitches SELECT 4, 5, 'Foul'
INSERT INTO #Pitches SELECT 4, 6, 'Strike'
GO

WITH cte_BallsStrikes AS
(
SELECT	AtBatId,
		PitchNumber,
		Result,		
		(CASE WHEN	Result = 'Ball' THEN 1 ELSE 0 END) AS Ball,
		(CASE WHEN	Result IN ('Foul','Strike') THEN 1 ELSE 0 END) AS Strike
FROM	#Pitches
),
cte_BallsStrikesSumWidow AS
(
SELECT	*,
		SUM(Ball) OVER (PARTITION BY AtBatId ORDER BY PitchNumber) AS SumBall,
		SUM(Strike) OVER (PARTITION BY AtBatId ORDER BY PitchNumber) AS SumStrike
FROM cte_BallsStrikes
),
CTE_BallsStrikesLag AS
(
SELECT	a.*,
		LAG(SumBall,1,0) OVER (PARTITION BY AtBatId ORDER BY PitchNumber) AS SumBallLag,
		(CASE	WHEN	Result IN ('Foul','In Play') AND 
						LAG(SumStrike,1,0) OVER (PARTITION BY AtBatId ORDER BY PitchNumber) >= 3 THEN 2
				WHEN	Result = 'Strike' AND SumStrike >= 2 THEN 2 
				ELSE	LAG(SumStrike,1,0) OVER (PARTITION BY AtBatId ORDER BY PitchNumber)
		END) AS SumStrikeLag
FROM	cte_BallsStrikesSumWidow a
)
SELECT	AtBatId,
		PitchNumber,
		Result,
		--a.*,
		CONCAT(SumBallLag, ' - ', SumStrikeLag) AS StartOfPitchCount,
		(CASE WHEN Result = 'In Play' THEN Result 
				ELSE CONCAT(SumBall, ' - ', (CASE	WHEN Result = 'Foul' AND SumStrike >= 3 THEN 2 
													WHEN Result = 'Strike' AND SumStrike >= 2 THEN 3
													ELSE SumStrike END))
		END) AS EndOfPitchCount
FROM	cte_BallsStrikesLag	a
ORDER BY 1,2;
