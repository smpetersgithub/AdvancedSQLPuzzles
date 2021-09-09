/*-------------------------------------------
Scott Peters
https://advancedsqlpuzzles.com
Mutual Friends Solution
*/-------------------------------------------

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------
This puzzle is best solved by thinking in sets and not code.  Before I divulge the answer, lets first breakdown the sets that are created to obtain the desired outcome.

Here is our original dataset.

Friend1, Friend2
Jason, Mary
Mike, Mary
Mike, Jason
Susan, Jason
John, Mary
Susan, Mary

---------------------
Step 1

First, create a list of reciprocals where each friendship exists twice.  

For example, the friendship between Jason and Mary will exist as Jason and Mary and it's reciprocal, Mary and Jason.  We now have 12 records from our original 6 records.

Friend1, Friend2
Jason, Mary
Jason, Mike
Jason, Susan
John, Mary
Mary, Jason
Mary, John
Mary, Mike
Mary, Susan
Mike, Jason
Mike, Mary
Susan, Jason
Susan, Mary

---------------------
Step 2

Here is where it gets a bit tricky.....

Second, we are going to build off our first dataset and build a set individuals that we need to check to determine if they are a friend.

This is best described by example.

Jason and Mary are friends.

Jason is also friends with Mike and Susan.
Mary is also friends with John, Mike and Susan.

For the friendship reciprocal of Jason and Mary, we need to check Jason for friendships with John, Mike and Susan (Mary's friends).

For the friendship reciprocal of Mary and Jason, we need to check Mary for friendships with Mike and Susan (Jason's friends).

Friend1, Friend2, Mutual_Friend_Check
Jason, Mary, John
Jason, Mary, Mike
Jason, Mary, Susan
Jason, Mike, Mary
Jason, Susan, Mary
John, Mary, Jason
John, Mary, Mike
John, Mary, Susan
Mary, Jason, Mike
Mary, Jason, Susan
Mary, Mike, Jason
Mary, Susan, Jason
Mike, Jason, Mary
Mike, Jason, Susan
Mike, Mary, Jason
Mike, Mary, John
Mike, Mary, Susan
Susan, Jason, Mary
Susan, Jason, Mike
Susan, Mary, Jason
Susan, Mary, John
Susan, Mary, Mike

---------------------
Step 3

Next, given the above dataset, we create reciprocals of the Friend1 and Friend2 columns and place the values in alphabetical order.  

For example, Jason and Mary will remain as Jason and Mary, but the reciprocal of Mary and Jason becomes Jason and Mary.  This will give us duplicate rows for us to determine who the mutual friends are.

Friend1, Friend2, Mutual_Friend_Check
Jason, Mary, John
Jason, Mary, Mike
Jason, Mary, Mike
Jason, Mary, Susan
Jason, Mary, Susan
Jason, Mike, Mary
Jason, Mike, Mary
Jason, Mike, Susan
Jason, Susan, Mary
Jason, Susan, Mary
Jason, Susan, Mike
John, Mary, Jason
John, Mary, Mike
John, Mary, Susan
Mary, Mike, Jason
Mary, Mike, Jason
Mary, Mike, John
Mary, Mike, Susan
Mary, Susan, Jason
Mary, Susan, Jason
Mary, Susan, John
Mary, Susan, Mike

---------------------
Step 4

Next we are going to group and count the above dataset.

Friend1, Friend2, Mutual_Friend_Check, Grouping_Count
Jason, Mary, John, 1
Jason, Mary, Mike, 2
Jason, Mary, Susan, 2
Jason, Mike, Mary, 2
Jason, Mike, Susan, 1
Jason, Susan, Mary, 2
Jason, Susan, Mike, 1
John, Mary, Jason, 1
John, Mary, Mike, 1
John, Mary, Susan, 1
Mary, Mike, Jason, 2
Mary, Mike, John, 1
Mary, Mike, Susan, 1
Mary, Susan, Jason, 2
Mary, Susan, John, 1
Mary, Susan, Mike, 1

---------------------
Step 5

Next we review the Grouping Count column in the previous dataset, if the Grouping Count is 2, than the Mutual Friend Check column is indeed a mutual friend.

Friend1, Friend2, Mutual_Friend_Check, Friend_Count
Jason, Mary, John, 0
Jason, Mary, Mike, 1
Jason, Mary, Susan, 1
Jason, Mike, Mary, 1
Jason, Mike, Susan, 0
Jason, Susan, Mary, 1
Jason, Susan, Mike, 0
John, Mary, Jason, 0
John, Mary, Mike, 0
John, Mary, Susan, 0
Mary, Mike, Jason, 1
Mary, Mike, John, 0
Mary, Mike, Susan, 0
Mary, Susan, Jason, 1
Mary, Susan, John, 0
Mary, Susan, Mike, 0

---------------------
Step 6

And then finally sum the results.

Friend1, Friend2, Total_Mutual_Friends
Jason, Mary, 2
Jason, Mike, 1
Jason, Susan, 1
John, Mary, 0
Mary, Mike, 1
Mary, Susan, 1
*/----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Here is the SQL code that I used to generate the result set.

IF OBJECT_ID(N'tempdb..#Friends') IS NOT NULL
	DROP TABLE #Friends;
IF OBJECT_ID(N'tempdb..#Distinct_Friends_Full_1') IS NOT NULL
	DROP TABLE #Distinct_Friends_Full_1;
IF OBJECT_ID(N'tempdb..#Mutual_Friend_Check_2') IS NOT NULL
	DROP TABLE #Mutual_Friend_Check_2;
IF OBJECT_ID(N'tempdb..#Reciprocal_Mutual_Friend_Check_3') IS NOT NULL
	DROP TABLE #Reciprocal_Mutual_Friend_Check_3;
IF OBJECT_ID(N'tempdb..#Reciprocal_Mutual_Friend_Check_Count_4') IS NOT NULL
	DROP TABLE #Reciprocal_Mutual_Friend_Check_Count_4;
IF OBJECT_ID(N'tempdb..#Reciprocal_Mutual_Friend_Check_Count_Modified_5') IS NOT NULL
	DROP TABLE #Reciprocal_Mutual_Friend_Check_Count_Modified_5;

--Create the intial table and populate
CREATE TABLE #Friends
(
Id INTEGER IDENTITY(1,1),
Friend1 VARCHAR(10),
Friend2 VARCHAR(10)
);
INSERT INTO #Friends (Friend1, Friend2) VALUES ('Jason','Mary')
INSERT INTO #Friends (Friend1, Friend2) VALUES ('Mike','Mary')
INSERT INTO #Friends (Friend1, Friend2) VALUES ('Mike','Jason')
INSERT INTO #Friends (Friend1, Friend2) VALUES ('Susan','Jason')
INSERT INTO #Friends (Friend1, Friend2) VALUES ('John','Mary')
INSERT INTO #Friends (Friend1, Friend2) VALUES ('Susan','Mary')
GO

--Step 1
;WITH cte_Reciprocal_Friends AS
(
SELECT	Friend1,
		Friend2
FROM	#Friends
UNION
SELECT	Friend2,
		Friend1
FROM	#Friends
)
SELECT	*
INTO	#Distinct_Friends_Full_1
FROM	cte_Reciprocal_Friends
ORDER BY 1,2;

--Step 2
SELECT	a.*, 
		b.Friend2 AS Mutual_Friend_Check
INTO	#Mutual_Friend_Check_2
FROM	#Distinct_Friends_Full_1 a INNER JOIN
		#Distinct_Friends_Full_1 b ON a.Friend2 = b.Friend1
WHERE	a.Friend1 <> b.Friend2
ORDER BY 1,2;

--Step 3
SELECT	(CASE WHEN Friend1 < Friend2 THEN Friend1 ELSE Friend2 END) AS Friend1,
		(CASE WHEN Friend1 < Friend2 THEN Friend2 ELSE Friend1 END) AS Friend2,
		a.Mutual_Friend_Check
INTO	#Reciprocal_Mutual_Friend_Check_3
FROM	#Mutual_Friend_Check_2 a;

--Step 4
SELECT	Friend1, 
		Friend2, 
		Mutual_Friend_Check, 
		COUNT(*) AS Grouping_Count
INTO	#Reciprocal_Mutual_Friend_Check_Count_4
FROM	#Reciprocal_Mutual_Friend_Check_3
GROUP BY Friend1, Friend2, Mutual_Friend_Check;

--Step 5
SELECT	Friend1,
		Friend2,
		Mutual_Friend_Check,
		(CASE Grouping_Count WHEN 1 THEN 0 WHEN 2 THEN 1 END) AS Friend_Count
INTO	#Reciprocal_Mutual_Friend_Check_Count_Modified_5
FROM	#Reciprocal_Mutual_Friend_Check_Count_4

--Results
SELECT	Friend1,
		Friend2,
		SUM(Friend_Count) AS Total_Mutual_Friends
FROM	#Reciprocal_Mutual_Friend_Check_Count_Modified_5
GROUP BY Friend1, Friend2
ORDER BY 1,2;

--Thanks for checking out my puzzle!
