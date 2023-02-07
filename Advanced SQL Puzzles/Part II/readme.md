### Permutations, Combinations, Sequences and Random Numbers

This directory contains the SQL scripts to solve the puzzles for **Part II: Permutations, Combinations, Sequences and Random Numbers** which can be found in the [parent directory](/Advanced%20SQL%20Puzzles).

:keyboard:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The scripts provided are written in Microsoft SQL Server T-SQL, but you can easily modify them to fit your flavor of SQL.

----------------------

Overview
As the name of the title suggests, the solutions to the puzzles **Part II: Permutations, Combinations, Sequences and Random Numbers** require the use of permutations, combinations, sequences, and random numbers to solve. The following is a brief overview of some relevant talking points concerning these topics that I want to highlight.

:exclmation: Warning, you may consider some of the discussion below to be a spoiler alert on how to best solve these puzzles.

## Creating a Simple Numbers Table

At the heart of these puzzles a numbers table is ultimately involved in creating the solution. Numbers tables are much like calendar tables, and can be used to fill in gaps, create ranges and tallies, provide custom sorting, and allow you to create set based solutions over iterative solutions.

A numbers tables can be created using recursion, and you will find that many of these puzzles can be solved using recursion for certain (if not all) aspects of the puzzle.

Here is the code to create a numbers table using recursion.

```sql
DECLARE @vTotalNumbers INTEGER = 100;
WITH cte_Number (Number)
AS (
SELECT 1 AS Number
UNION ALL
SELECT Number + 1
FROM cte_Number
WHERE Number < @vTotalNumbers
)
SELECT Number
INTO #Numbers
FROM cte_Number
OPTION (MAXRECURSION 0)--A value of 0 means no limit to the recursion level
```

Here is another little trick to create a numbers table in SQL Server. This will only work in a SQL script, as the `GO` command is not a T-SQL statement.

```sql
SET NOCOUNT OFF;
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

>SQL Server provides commands that are not Transact-SQL statements, but are recognized by the sqlcmd and osql utilities and SQL Server Management Studio Code Editor. These commands can be used to facilitate the readability and execution of batches and scripts.

## Permutations and Combinations

A permutation is a way in which a set or number of things can be ordered or arranged.

With permutation, order matters. With combinations, order does not matter.

We often use the work combination loosely without thinking order is important. A good example is the following:    
*  “My cheeseburger has a combination of the toppings; lettuce, tomato, and onion”. Here we really do not care about order, it is the same cheeseburger if it was “onion, lettuce, and tomato” or “tomato, lettuce, and onion”. The same cheeseburger is described no matter the order of the ingredients.
*  “The combination to my locker is 23-56-12”. Here order is important, and a combination lock is more accurately described as a “permutation lock”. A different arrangement would yield an inaccurate result for opening the lock.

**Permutations can get very large!**

When calculating permutations, the number of permutations grows substantially with each additional element added. The number of permutations to arrange the numbers 1 through 9 can be calculated by 9! (9 factorial) and returns 362,880 permutations. Adding another element to this set (10!) causes the number of permutations to grow to 3,628,800.

When solving these puzzles, consider using a comma separated list to store the data (often referred to as zero normal form) and when needed you can pivot the data, which you have several options for. The solution to Puzzle #9 “Find the Spaces” can give you a recipe for pivoting the data using recursion or you can use the STRING_SPLIT function to perform this action. Please check out the documentation for the STRING_SPLIT function, as it does have several parameters. One particular note is the ENABLE_ORDINAL argument and ordinal output column are currently only supported in Azure SQL Database, Azure SQL Managed Instance, and Azure Synapse Analytics (serverless SQL pool only). It will not work in your Desktop SQL Server Express edition.

**Incorporating multi-digit numbers**

When solving the puzzles, your working data should include numbers of both single and multi-digit
numbers, such as the set 1 through 10. This will become more clearer as you work through the puzzles,
but certain solutions will require the use of the CHARINDEX function which searches for a substring in a
string and returns the position. When using this function, you need to account that the number 1 is not
the digit 1 in the number 10 or the number 11.
If you have problems solving for this scenario, consider using a mapping table where you assign single
ASCII characters to your numbers, and then use the REPLACE function to update the characters to the
desired number. An example of this is the numbers 1 through 10 can be replaced with the letters A
through J, and then simply use the REPLACE function at the end of your solution to update this value.
1
2
3
3
2
2
1
3
3
1
3
1
2
2
1
26 | P a g e
https://advancedsqlpuzzles.com/
Sequences
Microsoft’s T-SQL can create a SEQUENCE object, which creates a list of ordered numbers. The
sequence of numeric values is generated in an ascending or descending order at a defined interval and
can be configured to restart when exhausted. It acts much like an IDENTITY column, but a SEQUENCE
object is schema bound (i.e., You use the syntax CREATE SEQUENCE to define the object).
The benefit of the SEQUENCE object is that generated values can be used across multiple tables or
columns, and you can recycle the values and restart from the minimum value.
The downside of using the SEQUENCE object is that it is 1) schema bound and 2) does not accept
parameterization. The parameters (such as min and max values) must be hardcoded to a number, as
you cannot set these via a variable. You can use dynamic SQL to create the SEQUENCE object to
circumvent this issue, but it may be best to create your own sequence table using a WHILE loop (while
also avoiding creating a schema bound object as you can use a temporary table).
A real-world example of using a sequence object is where you need to display a quote on a website for
each day where you must cycle through the quotes when exhausted. Here you could create the
following table that joins a calendar table, a sequence table, and a quotes table together.
Calendar Date Sequence ID Quote
01/01/2023 1 Live long and prosper!
01/02/2023 2 I am a doctor, not a bricklayer.
01/03/2023 3 Beam me up, Scotty!
01/04/2023 1 Live long and prosper!
01/05/2023 2 I am a doctor, not a bricklayer.
01/06/2023 3 Beam me up, Scotty!
01/07/2023 1 Live long and prosper!
01/08/2023 2 I am a doctor, not a bricklayer.
01/09/2023 3 Beam me up, Scotty!
The SQL to generate the above table would be the following.
SELECT c.CalendarDate,
s.SequenceNumber,
q.Quote
FROM CalendarTable c INNER JOIN
Sequence s on c.RowNumber = b.RowNumber INNER JOIN
Quotes q on s.SequenceNumber = q.RowNumber;
27 | P a g e
https://advancedsqlpuzzles.com/
Random Numbers
Microsoft provides the RAND function to generate a pseudo-random float value from 0 through 1,
exclusive, and the NEWID function to create a unique value of type UNIQUEIDENTIFIER. Although not
explicitly stated in the Microsoft documentation, the value returned from the NEWID function can be
used as a random value.
The benefit of using NEWID over the RAND function is that NEWID will return a different but unique
value for each record in the table, giving you the ability to randomize the order of a table. When used in
an SQL statement, the RAND function will return the same value for each record in the table.
The benefit of the RAND function is that it provides a seed argument. If the seed argument is left blank,
the database engine assigns a seed value at random and for a specified seed value, the result returned
will always be the same.
If you need a random integer (for example you are simulating dice rolls), there are numerous ways in
SQL to return an integer value (remember the RAND function returns a float value, not an integer). A
quick internet search will return a multitude of statements that return an integer value, and some of
them are not truly random!
I recommend the following syntax to generate random integers between 1 and n.
ABS(CHECKSUM(NEWID()) % n) + 1
Before you implement any type of random integer solution, ensure the statement returns a random
number without any bias!
To determine if the random number generator truly is random, use the law of large numbers and
generate enough numbers where the distribution should be even across all the numbers. For example,
if you need to simulate dice rolls, run the random number generator 1,000 times, and ensure each value
appears 1/6 of the time. If you want to measure the randomness using statistical measures, the Chi-
Square test can be used to assess the goodness of fit between observed and expected values.
Also, I recommend saving your random number generator as a function and create a stored procedure
to validate the randomness of the function (which can then be reused when a new user needs to ensure
it is truly random).
Here is a quick script that creates a 1 million random numbers and checks the count of each number and
the percentage of its occurrence.
28 | P a g e
https://advancedsqlpuzzles.com/
When solving such puzzles as the Dice Roll Game, many developers will think of creating a fully iterative
based solutions rather than a set-based solution. The developer will write the code to roll the dice,
perform any update or insert based upon the result, roll the dice again… and continue this loop until an
exit condition is met.
Instead, consider creating an initial set of dice rolls that far exceeds the number needed and use set
based windowing techniques to create your answer. In this scenario you will need to provide a
validation to ensure you have a large enough set of dice rolls, but it will provide a more elegant solution
that executes faster.
Conclusion
I hope you have enjoyed solving these puzzles as much as I have enjoyed creating them (and solving
them myself).
For additional puzzles please visit my website at: https://advancedsqlpuzzles.com/
Happy Coding!
The End!
