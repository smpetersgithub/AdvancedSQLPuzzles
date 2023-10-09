# Welcome

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Besides the standard `INNER`, `LEFT OUTER`, `RIGHT OUTER`, `FULL OUTER` and `CROSS` joins that are specified in the ANSI SQL standard, there are several joins that are not part of the standard SQL join syntax, but rather ways to classify different types of joins based on their behavior and the conditions used to join the tables.  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I classify joins into the following four categories; Logical, Physical, Descriptive, and Model.  The term "Model" comes from the Relational Model developed by Edgar F. Codd in the 1970s, which SQL is based on.  This name may warrant a rename if I can think of a better name.


| ID |    Type     |                                                          Description                                                    |
|----|-------------|-------------------------------------------------------------------------------------------------------------------------|
| 1  | Logical     | Joins that are part of the SQL ANSI syntax and used to combine data from two or more tables based on a filter criteria. | 
| 2  | Physical    | Implemented by the DBMS and describe how the system will physically join the tables to create the desired result.       |
| 3  | Descriptive | Used when discussing certain behaviors or complexity of a join.                                                         |
| 4  | Model       | Joins described in the Relational Model, which SQL is based on.                                                         |


Here is a brief description of each type of join:

|     Type    |       Join       |                                                                                                             Description                                                                                               |
|-------------|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Logical     | INNER JOIN       | An INNER JOIN returns only the rows with matching values in both tables.                                                                                                                                              |
| Logical     | OUTER JOIN       | An outer join (LEFT OUTER JOIN/RIGHT OUTER JOIN) returns all the rows from one table and any matching rows from the other table. If there is no match, the result will contain NULL markers.                          |
| Logical     | FULL OUTER JOIN  | A FULL OUTER JOIN returns all the rows from both tables.  If there are no matching rows, the result will contain NULL markers.                                                                                        |
| Logical     | CROSS JOIN       | A CROSS JOIN returns the Cartesian product of the two tables and returns every possible combination of rows from the two tables.                                                                                      |
| Physical    | NESTED LOOP JOIN | Nested loop join is a type of join algorithm that compares each row of one table with all rows of another table.                                                                                                      |
| Physical    | HASH JOIN        | Hash join is a join algorithm that uses a hash table to quickly match rows from one table with rows from another table.                                                                                               |
| Physical    | MERGE SORT JOIN  | Merge sort join is a join algorithm that sorts both tables on the join column and then merges the sorted rows together.                                                                                               |
| Descriptive | COMPLEX JOIN     | A complex join is a type of join operation that combines multiple tables using various comparison operators and often includes subqueries and aggregate functions to retrieve and combine data from different tables. |
| Descriptive | SELF-JOIN        | A self-join joins a table to itself, using the same table twice with different aliases.                                                                                                                               |
| Model       | SEMI-JOIN        | A semi-join returns only the rows from the first table with matching values in the second table.                                                                                                                      |
| Model       | ANTI-JOIN        | An anti-join returns only the rows from the first table that do not have matching values in the second table.                                                                                                         |
| Model       | EQUI-JOIN        | An equi-join returns only the rows where the values in the specified columns of both tables are equal.                                                                                                                |
| Model       | THETA-JOIN       | A theta-join is a flexible type of join that allows you to join tables based on any type of condition, not just an equality condition.                                                                                |
| Model       | NON-EQUI-JOIN    | Interchangeable with theta-join.  Some texts use the term theta-join, and others use non-equi-join.                                                                                                                    |
| Model       | NATURAL JOIN     | A NATURAL JOIN returns the rows where the values in the specified columns of both tables are equal and the column names are the same.                                                                                 |

---------------------------------------------------------

:electric_plug: I will cover all these types of joins and more in the following documents.  Continue reading with the links below.....

---------------------------------------------------------

1. [Introduction](01%20-%20Introduction.md)
2. [SQL Processing Order](02%20-%20SQL%20Query%20Processing%20Order.md)
3. [Table Types](03%20-%20Table%20Types.md)
4. [Equi, Theta, and Natural Joins](04%20-%20Equi%2C%20Theta%2C%20and%20Natural%20Joins.md)
5. [Inner Joins](05%20-%20Inner%20Join.md)
6. [Outer Joins](06%20-%20Outer%20Joins.md)
7. [Full Outer Joins](07%20-%20Full%20Outer%20Join.md)
8. [Cross Joins](08%20-%20Cross%20Join.md)
9. [Semi and Anti Joins](09%20-%20Semi%20and%20Anti%20Joins.md)
10. [Any, All, and Some](10%20-%20Any%2C%20All%2C%20and%20Some.md)
11. [Self Joins](11%20-%20Self%20Join.md)
12. [Relational Division](12%20-%20Relational%20Division.md)
13. [Set Operations](13%20-%20Set%20Operations.md)
14. [Join Algorithms](14%20-%20Join%20Algorithms.md)
15. [Exists](15%20-%20Exists.md)
16. [Complex Joins](16%20-%20Complex%20Joins.md)

https://advancedsqlpuzzles.com
