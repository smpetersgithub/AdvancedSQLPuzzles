# Welcome

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Joining tables in SQL requires a good understanding of the data, the relationships between the tables, and the behavior of the different join types.  This GitHub repository covers some of the more advanced concepts of SQL joins and serves as a collection of interesting, odd, and uncommon ways you may see or think of joins in your everyday SQL encounters.  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I've tried to keep all my examples as concise as possible, and they should serve as a springboard for further exploration.  In this repository there are a number of markdown documents I have created that showcase different joins and concepts, and I try to show alternative ways in which you can write the SQL statement as a means of understanding their behavior.  I have tried to create the documents in such a way they can be read in any order without trying to sound repetitive.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Although I will talk about the logical processing order and physical join types, I have refrained from discussing query optimization and which SQL statments produce the most optimized execution plan.  Also, I use a very small sample dataset that contains types of fruit that can be found here.  The sample data has NULL markers in the sample data, but not duplicate data.  Feel free to add, subtract and modify the data and these queries to explore their behavior.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I welcome any corrections, additions, debates etc. I've tried to show different joins across all the major RDBMS platforms, and I am sure there are some new and interesting joins that I have not included here (such as graph joins).  Feel free to contact me through this GitHub repository or my Wordpress site at https://advancedsqlpuzzles.com.  

-----

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Besides the standard **INNER**, **LEFT OUTER**, **RIGHT OUTER**,**FULL OUTER** and **CROSS** joins that are specified in the ANSI SQL standard, there are a slew of joins are not part of the standard SQL join syntax, but rather ways to classify different types of joins based on their behavior and the condition used to join the tables.  

I classify joins into the following 4 categories:


| ID |     Type     |                                                           Description                                                          |
|----|--------------|--------------------------------------------------------------------------------------------------------------------------------|
|  1 |  Logical     |  Joins that are part of the SQL ANSI syntax and are used to combine data from two or more tables based upon a filter criteria. |
|  2 |  Physical    |  Implemented by the RDBMS and describe how the system will phyically join the tables to create the desired results.            |
|  3 |  Descriptive |  Used when discussing certain behavior or complexity of a join.                                                                |
|  4 |  Mathmatical |  Joins that are described in Relational Algebra which SQL is based on.                                                         |


Here is a breif description of each type of join:

|  Type         |       Join       |                                                                                                              Description                                                                                                              |
|---------------|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  Logical      | INNER JOIN       |  An INNER JOIN returns only the rows that have matching values in both tables.                                                                                                                                                        |
|  Logical      | OUTER JOIN       |  An outer join (LEFT OUTER JOIN/RIGHT OUTER JOIN) returns all the rows from one table, and any matching rows from the other table. If there is no match, the result will contain NULL values.                                         |
|  Logical      | FULL OUTER JOIN  |  A FULL OUTER JOIN returns all the rows from both tables, where if there are no matching rows, the result will contain NULL markers.                                                                                                  |
|  Logical      | CROSS JOIN       |  A CROSS JOIN returns the Cartesian product of the two tables, meaning it returns every possible combination of rows from the two tables.                                                                                             |
|  Physical     | NESTED LOOP JOIN |  Nested loop join is a type of join algorithm that compares each row of one table with all the rows of another table.                                                                                                                 |
|  Physical     | HASH JOIN        |  Hash join is a join algorithm that uses a hash table to quickly match rows from one table with rows from another table.                                                                                                              |
|  Physical     | MERGE SORT JOIN  |  Merge sort join is a join algorithm that sorts both tables on the join column, and then merges the sorted rows together.                                                                                                             |
|  Descriptive  | COMPLEX JOIN     |  A complex join is a type of join operation that combines multiple tables using various comparison operators, and often includes subqueries and aggregate functions, in order to retrieve and combine data from different tables.     |
|  Descriptive  | SELF-JOIN        |  A self-join is used to join a table to itself, using the same table twice with different aliases.                                                                                                                                    |
|  Mathmatical  | SEMI-JOIN        |  A semi-join returns only the rows from the first table that have matching values in the second table.                                                                                                                                |
|  Mathmatical  | ANTI-JOIN        |  An anti-join returns only the rows from the first table that do not have matching values in the second table.                                                                                                                        |
|  Mathmatical  | EQUI-JOIN        |  An equi-join returns only the rows where the values in the specified columns of both tables are equal.                                                                                                                               |
|  Mathmatical  | THETA-JOIN       |  A theta-join is a flexible type of join that allows you to join tables based on any type of condition, not just an equality condition.                                                                                               |
|  Mathmatical  | NON-EQUI-JOIN    |  Interchangable with theta-join  Some texts use the term theta-join, and others use non-equi-join.                                                                                                                                    |
|  Mathmatical  | NATURAL JOIN     |  A NATURAL JOIN returns the rows where the values in the specified columns of both tables are equal, and the column names are the same.                                              |
                                                           |
----

Before diving into specifics of each type of join, I recomend understanding table operators first.

Happy coding!

https://advancedsqlpuzzles.com
