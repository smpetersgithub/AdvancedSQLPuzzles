# Recursion Examples

In this directory, you will find my collection of SQL scripts to solve various challenges using recursion.    

👓&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I am always on the lookout for puzzles that can be solved using recursion.  If you have any ideas or scripts you want to add to my collection, please contact me!

:keyboard:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The scripts provided are written in Microsoft SQL Server T-SQL, but you can easily modify them to fit your flavor of SQL.


## About

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Recursion in SQL is a technique used to process hierarchical data, where a query can reference itself to process data in a recursive manner. It is commonly used in cases where a single row of data has multiple relationships with other rows in the same table, creating a parent-child relationship. The process starts with an initial query that returns a base case, and subsequent queries use the results of the previous query to process the data until a stop condition is reached. Recursion in SQL is implemented using Common Table Expressions (CTEs), which are temporary result sets defined within a `SELECT` statement and can be referenced within the same `SELECT` statement to perform the recursion.

❕&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data can have an implicit or an explicit hierarchy.  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;An example of an **explicit hierarchy** is an organizational chart of a company. Each employee has a direct manager, and the top-level manager is at the root of the hierarchy.


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;An example of an **implicit hierarchy** can be found in numbers, dates, words, and sentences... where the hierarchy is inferred.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A numbers table can be considered to have an implicit hierarchy because each number depends on the previous number in the sequence. The hierarchy is implicit because it is not explicitly stored in the table but can be derived from the relationship between the numbers. This type of hierarchy can be helpful when you need to perform operations on sequences of numbers, such as generating a series of dates or calculating the cumulative sum of values.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dates, words, and sentences also have an implicit hierarchy.

*  Dates are a hierarchy as the date 1892-12-31 cannot exist without 1892-12-30.
*  The letters in the word "angel" must be printed in a specific order.  The letter "a" must come before the letter "n", and so on...  If they are not printed in the correct order, you may spell "glean, which is an entirely new word with a different meaning.
*  Also, sentences have an implicit hierarchy.  The sentence "The cat sat on the mat" must have a specific word order for it to be logical. 

Also, providing a solution using recursion rather than a loop-based solution isn't necessarily a best practice.  This is best highlighted in the book "T-SQL Querying" by Ben-Gan, Sarka, Machanic, and Farlee ...

> "The main benefits I see in recursive queries are the brevity of the code and the ability to traverse graph structures based only on the parent and child IDS.  The main drawback of recursive queries is performance.   They tend to perform less efficiently than alternative methods, even your own loop-based solutions.   With recursive queries, you don't have any control over the worktable; for example, you can't define your own indexes on it, you can't define how to filter the rows from the previous round, and so on.  If you know how to optimize T-SQL code, you can usually get better performance with your own solution." 

## Conclusion

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc., please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!

I hope you find this repository useful and informative, and I welcome any new puzzles or tips and tricks you may have. I also have a WordPress site where you can find my data analytics projects, Python puzzles, and blog.

https://advancedsqlpuzzles.com
