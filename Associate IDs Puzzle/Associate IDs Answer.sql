IF OBJECT_ID('tempdb.dbo.#Sequences','U') IS NOT NULL
DROP TABLE #Sequences;
GO
 
IF OBJECT_ID('tempdb.dbo.#Sequences2','U') IS NOT NULL
DROP TABLE #Sequences2;
GO
 
IF OBJECT_ID('tempdb.dbo.#Sequences3','U') IS NOT NULL
DROP TABLE #Sequences3;
GO
 
CREATE TABLE #Sequences
(
ID INT,
Associate_ID INT
);
GO

INSERT INTO #Sequences (ID, Associate_ID) VALUES (1,2),(1,3),(2,4),(3,5),(10,11),(11,12);
GO
 
WITH cte_Recursive AS
(
SELECT	ID,
		Associate_ID
FROM	#Sequences
UNION ALL
SELECT	a.ID,
		b.Associate_ID
FROM	#Sequences a INNER JOIN
		cte_Recursive b ON a.Associate_ID = b.ID
)
SELECT	*
INTO	#Sequences2
FROM	cte_Recursive
UNION ALL
SELECT	ID,
		ID
FROM	#Sequences;
SELECT	MIN(ID) AS ID,
		Associate_ID
INTO	#Sequences3
FROM	#Sequences2
GROUP BY Associate_ID;
 
SELECT	DENSE_RANK() OVER (ORDER BY ID) AS GroupingNumber,
		Associate_ID
FROM	#Sequences3;
GO