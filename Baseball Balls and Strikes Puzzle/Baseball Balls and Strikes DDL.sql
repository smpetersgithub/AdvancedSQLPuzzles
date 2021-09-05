/***********************************************************************
Scott Peters
https://advancedsqlpuzzles.com
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