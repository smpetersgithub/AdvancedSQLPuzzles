# Permutations, Combinations, Sequences, and Random Numbers

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This directory contains the SQL scripts to solve the puzzles for **Part II: Permutations, Combinations, Sequences, and Random Numbers**, which can be found in the [parent directory](/Advanced%20SQL%20Puzzles).  I hope you enjoy solving these puzzles as much as I have enjoyed creating them (and solving them myself).


:keyboard:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The scripts provided are written in Microsoft SQL Server T-SQL, but you can easily modify them to fit your flavor of SQL.  

## Overview    

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;As the name of the title suggests, the solutions to the puzzles **Part II: Permutations, Combinations, Sequences and Random Numbers** require the use of permutations, combinations, sequences, and random numbers to solve. The following is a brief overview of relevant talking points concerning these topics that I want to highlight.

## Creating a Simple Numbers Table

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;At the heart of these puzzles, a numbers table is ultimately involved in creating the solution. Numbers tables are much like calendar tables and can be used to fill in gaps, create ranges and tallies, provide custom sorting, and allow you to create set-based solutions over iterative solutions.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A numbers tables can be created using recursion, and you will find that many of these puzzles can be solved using recursion for certain (if not all) aspects of the puzzle.

-----------------------------------------

Here is the code to create a numbers table using recursion.

```sql
DECLARE @vTotalNumbers INTEGER = 100;
WITH cte_Number (Number)
AS (
SELECT  1 AS Number
UNION ALL
SELECT  Number + 1
FROM    cte_Number
WHERE   Number < @vTotalNumbers
)
SELECT  Number
INTO    #Numbers
FROM    cte_Number
OPTION (MAXRECURSION 0)--A value of 0 means no limit to the recursion level
```

-----------------------------------------

Here is another little trick to create a numbers table in SQL Server. This will only work in an SQL script, as the `GO` command is not a `T-SQL` statement.

```sql
SET NOCOUNT ON;
DROP TABLE IF EXISTS #Numbers;
GO
CREATE TABLE #Numbers
(Number INT IDENTITY(1,1) PRIMARY KEY,
InsertDate DATETIME NOT NULL);
GO

INSERT INTO #Numbers (InsertDate) VALUES (GETDATE())
GO 100
```

From the [Microsoft documentation](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/sql-server-utilities-statements-go?view=sql-server-ver16):

>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SQL Server provides commands that are not Transact-SQL statements but are recognized by the `sqlcmd` and `osql` utilities and SQL Server Management Studio Code Editor. These commands can be used to facilitate the readability and execution of batches and scripts.

-----------------------------------------

:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;New in SQL Server 2022 is the `GENERATE_SERIES` function.

The `GENERATE_SERIES` function produces a set-based sequence of numeric values. It supplants cumbersome numbers tables, recursive CTEs, and other on-the-fly sequence generation techniques we've all used at one point or another.

The arguments are:  `GENERATE_SERIES(START = <start>, STOP = <stop> [, STEP = <step>])`

Here is an example of creating a numbers table.

```sql
SELECT value FROM GENERATE_SERIES(START = 1, STOP = 5);
```

## Permutations and Combinations

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A permutation is a way in which a set or number of things can be ordered or arranged.  With permutation, order matters. With combinations, the order does not matter.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We often use the word combination loosely without thinking order is important. A good example is the following:    
*  “My cheeseburger has a combination of the toppings lettuce, tomato, and onion”. Here, we do not care about the order. It is the same cheeseburger if the order was “onion, lettuce, and tomato” or “tomato, lettuce, and onion”. The same cheeseburger is described no matter the order of the ingredients.
*  “The combination to my locker is 23-56-12”. Here, the order is important, and a combination lock is more accurately described as a “permutation lock”. A different arrangement would yield an inaccurate result for opening the lock.

**Permutations can get very large!**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;When calculating permutations, the number of permutations grows substantially with each additional element added. The number of permutations to arrange the numbers 1 through 9 can be calculated by 9! (9 factorial) and returns 362,880 permutations. Adding another element to this set (10!) causes the number of permutations to grow to 3,628,800.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;When solving these puzzles, consider using a comma-separated list to store the data (often referred to as zero normal form), and when needed, you can pivot the data, which you have several options for. The solution to Puzzle #9, “Find the Spaces”, can give you a recipe for pivoting the data using recursion, or you can use the `STRING_SPLIT` function to perform this action. Please check out the documentation for the `STRING_SPLIT` function, as it does have several parameters.


## Sequences

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`Microsoft T-SQL` can create a `SEQUENCE` object, which creates a list of ordered numbers. The sequence of numeric values is generated in an ascending or descending order at a defined interval and can be configured to restart when exhausted. It acts much like an `IDENTITY` column, but a `SEQUENCE` object is schema-bound (i.e., You use the syntax `CREATE SEQUENCE` to define the object).

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The benefit of the `SEQUENCE` object is that generated values can be used across multiple tables or columns, and you can recycle the values and restart from the minimum value.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The downside of using the `SEQUENCE` object is that it is 1) schema bound and 2) does not accept parameterization. The parameters (such as min and max values) must be hardcoded to a number, as you cannot set these via a variable. You can use dynamic SQL to create the `SEQUENCE` object to circumvent this issue, but it may be best to create your own sequence table using a `WHILE` loop (while avoiding creating a schema-bound object, as you can use a temporary table).

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A real-world example of using a sequence object is where you need to display a quote on a website for each day where you must cycle through the quotes when exhausted. Here, you could create the following table that joins a calendar table, a sequence table, and a quotes table together.

| CalendarDate | SequenceID |                                          Quote                                           |
|--------------|------------|------------------------------------------------------------------------------------------|
| 01/01/2023   |         1  | "SQL is the language that lets you manage and manipulate data in a relational database." |
| 01/02/2023   |         2  | "SQL is the cornerstone of modern data management."                                      |
| 01/03/2023   |         3  | "SQL is the foundation of modern data analytics and reporting."                          |
| 01/04/2023   |         1  | "SQL is the language that lets you manage and manipulate data in a relational database." |
| 01/05/2023   |         2  | "SQL is the cornerstone of modern data management."                                      |
| 01/06/2023   |         3  | "SQL is the foundation of modern data analytics and reporting."                          |
| 01/07/2023   |         1  | "SQL is the language that lets you manage and manipulate data in a relational database." |
| 01/08/2023   |         2  | "SQL is the cornerstone of modern data management."                                      |
| 01/09/2023   |         3  | "SQL is the foundation of modern data analytics and reporting."                          |


The SQL to generate the above table would be the following.

```sql
SELECT  c.CalendarDate,
        s.SequenceNumber,
        q.Quote
FROM    CalendarTable c INNER JOIN
        Sequence s on c.RowNumber = b.RowNumber INNER JOIN
        Quotes q on s.SequenceNumber = q.RowNumber;
```

## Random Numbers
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Microsoft provides the `RAND` function to generate a pseudo-random float value from 0 through 1, exclusive, and the `NEWID` function to create a unique value of type `UNIQUEIDENTIFIER`. Although not explicitly stated in the Microsoft documentation, the value returned from the `NEWID` function can be used as a random value.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The benefit of using `NEWID` over the `RAND` function is that `NEWID` will return a different but unique value for each record in the table, giving you the ability to randomize the order of a table. When used in an SQL statement, the `RAND` function will return the same value for each record in the table.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The benefit of the `RAND` function is that it provides a seed argument. If the seed argument is left blank, the database engine assigns a seed value at random and for a specified seed value, the result returned will always be the same.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you need a random integer (for example, you are simulating dice rolls), there are numerous ways in SQL to return an integer value (remember the `RAND` function returns a float value, not an integer).  A quick internet search will return a multitude of statements that return an integer value, and some of them are not truly random!

I recommend the following syntax to generate random integers between 1 and n.    
`ABS(CHECKSUM(NEWID()) % n) + 1`

:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Before you implement any type of random integer solution, ensure the statement returns a random number without any bias!

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To determine if the random number generator truly is random, use the law of large numbers and generate enough numbers where the distribution should be even across all the numbers. For example, if you need to simulate dice rolls, run the random number generator 1,000 times and ensure each value appears 1/6 of the time. If you want to measure the randomness using statistical measures, the Chi-Square test can be used to assess the goodness of fit between observed and expected values.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Also, I recommend saving your random number generator as a function and creating a stored procedure to validate the randomness of the function (which can then be reused when a new user needs to ensure it is truly random). Here is a quick script that creates 1 million random numbers and checks the count of each number and the percentage of its occurrence.

```sql
SET NOCOUNT ON;
DROP TABLE IF EXISTS #Numbers;
GO

CREATE TABLE #Numbers
(Number    INT IDENTITY(1,1) PRIMARY KEY,
InsertDate DATETIME NOT NULL);
GO

INSERT INTO #Numbers (InsertDate) VALUES (GETDATE())
GO 100

;WITH cte_RandomNumber AS
(
SELECT  ABS(CHECKSUM(NEWID()) % 10) + 1 AS RandomNumber
FROM    #Numbers
)
SELECT  RandomNumber,
        COUNT(RandomNumber) AS RandomCount,
        COUNT(RandomNumber) / CAST((SELECT MAX(Number) FROM #Numbers) AS FLOAT) AS Perc
FROM    cte_RandomNumber
GROUP BY RandomNumber;
```

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;When solving such puzzles as the Dice Roll Game, many developers will think of creating a fully iterative based solutions rather than a set-based solution. The developer will write the code to roll the dice, perform any update or insert based on the result, roll the dice again… and continue this loop until an exit condition is met. Instead, consider creating an initial set of dice rolls far exceeding the number needed and use set-based windowing techniques to create your answer. In this scenario, you will need to provide a validation to ensure you have a large enough set of dice rolls, but it will provide a more elegant solution that executes faster.


## Conclusion

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc., please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!

I hope you find this repository useful and informative, and I welcome any new puzzles or tips and tricks you may have. I also have a WordPress site where you can find my data analytics projects, Python puzzles, and blog.

https://advancedsqlpuzzles.com

