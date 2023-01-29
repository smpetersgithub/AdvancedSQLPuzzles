# Overview

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Joining tables in SQL requires a good understanding of the data, the relationships between the tables, and the behavior of the different join types.  This GitHub repository covers some of the more advanced concepts of SQL joins.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Besides the standard INNER, OUTER, FULL, and NATURAL joins that are specified in the ANSI SQL standard, there are equi-joins, theta-joins, semi-joins, anti-joins, self-joins, nested-loop joins, merge sort joins, and hash joins.  These joins are not part of the standard SQL join syntax but rather ways to classify different types of joins based on their behavior and the condition used to join the tables.  

We can classify joins into the following 5 categories:
1.  **INNER**, **OUTER**, **CROSS**, and **NATURAL** joins are part of the SQL syntax (hence their capitalization) and are used to combine data from two or more tables based upon a filtering or matching criterion.  These joins are called **logical joins**.
2.  A **self-join** is used when a table is joined to itself. It is useful when a table has a hierarchical structure or when the table has a one-to-many relationship with itself.
3.  **Semi-joins** and **anti-joins** look for equality or inequality between two datasets, but have an added benefit of not returning duplicates.
4.  **Equi-joins** and **theta-joins** (sometimes called **non-equi-joins**) are used to describe if the join is looking for equality, inequality, or a range of values. 
5.  **Nested Loop**, **Hash**, and **Merge Sort joins** are types of join algorithms. They are used to optimize the performance of a query when joining large tables, based on the table size and the type of data they contain.  These joins are called **physical joins** and are the common types of physical joins implemented by the DBMS, and each DBMS may have different physical join algorithms, such as **Index** or **Mege-Sort joins**.

Here is a summary of each of the joins.
|       Join       |                                                                                                              Description                                                                                                              |
|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| INNER JOIN       |  An INNER JOIN returns only the rows that have matching values in both tables.                                                                                                                                                        |
| OUTER JOIN       |  An outer join (LEFT OUTER JOIN/RIGHT OUTER JOIN) returns all the rows from one table, and any matching rows from the other table. If there is no match, the result will contain NULL values.                                         |
| FULL OUTER JOIN  |  A FULL OUTER JOIN returns all the rows from both tables, where if there are no matching rows, the result will contain NULL markers.                                                                                                  |
| CROSS JOIN       |  A CROSS JOIN returns the Cartesian product of the two tables, meaning it returns every possible combination of rows from the two tables.                                                                                             |
| NATURAL JOIN     |  A NATURAL JOIN returns the rows where the values in the specified columns of both tables are equal, and the column names are the same. It is important to note that in case of ambiguous columns, it may lead to unexpected results. |
| COMPLEX JOIN     |  A complex join is a type of join operation that combines multiple tables using various comparison operators, and often includes subqueries and aggregate functions, in order to retrieve and combine data from different tables.     |
| SELF-JOIN        |  A self-join is used to join a table to itself, using the same table twice with different aliases.                                                                                                                                    |
| SEMI-JOIN        |  A semi-join returns only the rows from the first table that have matching values in the second table.                                                                                                                                |
| ANTI-JOIN        |  An anti-join returns only the rows from the first table that do not have matching values in the second table.                                                                                                                        |
| EQUI-JOIN        |  An equi-join returns only the rows where the values in the specified columns of both tables are equal.                                                                                                                               |
| THETA-JOIN       |  A theta-join is a flexible type of join that allows you to join tables based on any type of condition, not just an equality condition.                                                                                               |
| NON-EQUI-JOIN    |  Interchangable with theta-join  Some texts use the term theta-join, and others use non-equi-join.                                                                                                                                    |
| NESTED LOOP JOIN |  Nested loop join is a type of join algorithm that compares each row of one table with all the rows of another table.                                                                                                                 |
| HASH JOIN        |  Hash join is a join algorithm that uses a hash table to quickly match rows from one table with rows from another table.                                                                                                              |
| MERGE SORT JOIN  |  Merge sort join is a join algorithm that sorts both tables on the join column, and then merges the sorted rows together.                                                                                                             |
| PHYSICAL JOIN    |  Physical joins implemented inside the database engine to implement the Logical Joins.  The basic physical joins are Nested Loop, Hash, and Merge Sort.                                                                               |
| LOGICAL JOIN     |  Joins that we apply in our SQL queries, like INNER JOIN, RIGHT/LEFT OUTER JOIN, CROSS JOIN, etc.

----

Before diving into specifics of each type of join, I recomend understanding table operators first.

Happy coding!
