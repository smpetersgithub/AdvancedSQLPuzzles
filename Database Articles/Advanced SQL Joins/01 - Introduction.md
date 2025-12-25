# Welcome

Joins are one of the most fundamental—and often most misunderstood—concepts in SQL. At a basic level, joins allow you to combine rows from two or more tables based on a related condition. Most SQL users are familiar with the standard join keywords defined by the ANSI SQL specification, such as `INNER`, `LEFT OUTER`, `RIGHT OUTER`, `FULL OUTER`, and `CROSS` joins.

However, not all joins are defined purely by SQL syntax. Many commonly used “join types” are better understood as classifications based on *behavior*, *intent*, or *implementation*, rather than as explicit keywords you type into a query. Some describe how the database engine physically executes a join, others describe logical or relational concepts, and some are simply useful ways to talk about query complexity or structure.

To make these distinctions clearer, I group joins into four broad categories:

- **Logical** – joins expressed directly in SQL syntax  
- **Physical** – joins describing how the database engine executes the operation  
- **Descriptive** – joins used to describe query structure or complexity  
- **Model** – joins derived from the Relational Model developed by Edgar F. Codd in the 1970s, on which SQL is based  

> The term **Model** is borrowed from the Relational Model itself. I may rename this category in the future if a better term emerges.

## Join Categories

| ID | Type        | Description |
|----|-------------|-------------|
| 1  | Logical     | Joins defined by ANSI SQL syntax and used to combine tables based on a condition. |
| 2  | Physical    | Joins implemented by the DBMS that describe *how* rows are physically matched. |
| 3  | Descriptive | Joins used to describe query behavior, structure, or complexity. |
| 4  | Model       | Joins defined in the Relational Model on which SQL is based. |

Below is a brief overview of the most common join types within each category.

## Join Types Overview

| Type        | Join            | Description |
|-------------|------------------|-------------|
| Logical     | INNER JOIN       | Returns only rows with matching values in both tables. |
| Logical     | OUTER JOIN       | (`LEFT OUTER JOIN` / `RIGHT OUTER JOIN`) Returns all rows from one table and matching rows from the other. Unmatched rows contain NULL markers. |
| Logical     | FULL OUTER JOIN  | Returns all rows from both tables. Unmatched rows contain NULL markers. |
| Logical     | CROSS JOIN       | Returns the Cartesian product of both tables—every possible row combination. |
| Physical    | NESTED LOOP JOIN | Compares each row of one table to all rows of another table. |
| Physical    | HASH JOIN        | Uses a hash table to efficiently match rows between tables. |
| Physical    | MERGE SORT JOIN  | Sorts both inputs on the join key and merges the results. |
| Descriptive | COMPLEX JOIN     | Combines multiple tables using various operators, often with subqueries and aggregates. |
| Descriptive | COMPOSITE JOIN   | Uses multiple columns from each table in the join condition. |
| Descriptive | MULTI-JOIN       | Refers to a query that joins more than two tables. |
| Descriptive | SELF-JOIN        | Joins a table to itself using aliases. |
| Model       | SEMI-JOIN        | Returns rows from the first table that have matching rows in the second table. |
| Model       | ANTI-JOIN        | Returns rows from the first table that have no matching rows in the second table. |
| Model       | THETA-JOIN       | A join based on any binary comparison operator (equality or inequality). |
| Model       | EQUI-JOIN        | A theta-join that uses only the equality operator. |
| Model       | NON-EQUI-JOIN    | A theta-join that uses operators other than equality. |
| Model       | NATURAL JOIN     | Automatically joins tables on columns with the same name and compatible data types. |

---

:electric_plug: **What’s Next**

Each of these join types—and several related concepts—will be explored in detail throughout the following documents. The goal is not only to show *how* joins work, but *why* they behave the way they do, how they relate to the relational model, and how the database engine processes them internally.

Continue reading using the links below.

---

### Continue Reading

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