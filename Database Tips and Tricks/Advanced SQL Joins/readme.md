
## Welcome

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Joining tables in SQL requires a good understanding of the data, the relationships between the tables, and the behavior of the different join types.  This GitHub repository covers some of the more advanced concepts of SQL joins.
     
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Besides the standard INNER, OUTER, FULL, and NATURAL joins that are specified in the ANSI SQL standard, there are equi-joins, theta-joins, semi-joins, anti-joins, self-joins, nested-loop joins, merge sort joins, and hash joins.  These joins are not part of the standard SQL join syntax but rather ways to classify different types of joins based on their behavior and the condition used to join the tables.  

We can classify joins into the following 5 categories:
1.	**Inner**, **outer**, **cross**, and **natural joins** are part of the SQL syntax and are used to combine data from two or more tables based upon a filtering or matching criterion.
2.	A **self-join** is used when a table is joined to itself. It is useful when a table has a hierarchical structure or when the table has a one-to-many relationship with itself.
3.	**Semi-joins** and **anti-joins** look for equality or inequality between two datasets, but have an added benefit of not returning duplicates.
4.	**Equi-joins** and **theta-joins** are used to describe if the join is looking for equality, inequality, or a range of values. 
5.	**Nested loop**, **Hash**, and **Merge sort joins** are types of join algorithms. They are used to optimize the performance of a query when joining large tables, based on the table size and the type of data they contain.

Here is an overall summary of each of the joins:
|       Join       |                                                                                                              Description                                                                                                              |
|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| INNER JOIN       |  An inner join returns only the rows that have matching values in both tables.                                                                                                                                                        |
| OUTER JOIN       |  An outer join returns all the rows from one table, and any matching rows from the other table. If there is no match, the result will contain NULL values.                                                                            |
| FULL OUTER JOIN  |  A full outer join returns all the rows from both tables, where if there are no matching rows, the result will contain NULL values.                                                                                                   |
| CROSS JOIN       |  A cross join returns the Cartesian product of the two tables, meaning it returns every possible combination of rows from the two tables.                                                                                          |
| NATURAL JOIN     |  A natural join returns the rows where the values in the specified columns of both tables are equal, and the column names are the same. It is important to note that in case of ambiguous columns, it may lead to unexpected results. |
| SELF JOIN        |  A self-join is used to join a table to itself, using the same table twice with different aliases.                                                                                                                                    |
| SEMI JOIN        |  A semi-join returns only the rows from the first table that have matching values in the second table.                                                                                                                                |
| ANTI JOIN        |  An anti-join returns only the rows from the first table that do not have matching values in the second table.                                                                                                                        |
| EQUI JOIN        |  An equi join returns only the rows where the values in the specified columns of both tables are equal.                                                                                                                               |
| THETA JOIN       |     A theta join is a flexible type of join that allows you to join tables based on any type of condition, not just an equality condition.                                                                                            |
| NESTED LOOP JOIN |  Nested loop join is a type of join algorithm that compares each row of one table with all the rows of another table.                                                                                                                 |
| HASH JOIN        |  Hash join is a join algorithm that uses a hash table to quickly match rows from one table with rows from another table.                                                                                                              |
| MERGE SORT JOIN  |  Merge sort join is a join algorithm that sorts both tables on the join column, and then merges the sorted rows together.                                                                                                             |

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Besides the above mentioned joins, I will also cover table operators and SET operators in this GitHub repository.  I have each of these written in individual markup notebooks that you can indiviually explore.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Before diving into specifics of each type of join, I recomend understanding table operators first.
