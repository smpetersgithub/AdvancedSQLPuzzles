# Welcome

Welcome to my collection of articles on advanced SQL joins. Although joins are the primary focus, the discussion extends into several related topics, including:    

*  The different ways the term “join” is used when discussing SQL.
*  The methods, operators, and clauses SQL provides for comparing two datasets.    
*  Other related concepts and observations that help explain how SQL queries work.    

## Overview 
Joins are one of the most fundamental and often most misunderstood concepts in SQL. At a basic level, joins allow you to combine rows from two or more tables based on a related condition. Most SQL users are familiar with the standard join keywords defined by the ANSI SQL specification, such as `INNER JOIN`, `LEFT OUTER JOIN`, `RIGHT OUTER JOIN`, `FULL OUTER JOIN`, and `CROSS JOIN`.

However, not all joins are defined purely by SQL syntax. Many commonly used “join types” are better understood as classifications based on *behavior*, *intent*, or *implementation*, rather than as explicit keywords you type into a query. Some describe how the database engine physically executes a join, others describe logical or relational concepts, and some are simply useful ways to talk about query complexity or structure.

To make these distinctions clearer, I group joins into four broad categories:

## Join Categories

| ID | Type | Description |
|----|------|-------------|
| 1 | Logical | Describes the relationship requested between two inputs. |
| 2 | Physical | Describes the algorithm the database engine uses to execute a join. |
| 3 | Descriptive | Uses informal terminology to describe query behavior, structure, or complexity. |
| 4 | Relational | Describes join operations and classifications derived from relational algebra. |

These categories are used to organize this material and are not mutually exclusive. A join may fit into more than one category depending on whether it is being discussed as SQL syntax, a logical operation, a relational concept, or a physical execution algorithm.

Below is a brief overview of the most common join types within each category.

## Join Types Overview

| #  | Type        | Join                  | Description |
|----|-------------|-----------------------|-------------|
| 1  | Logical     | INNER JOIN            | Returns row combinations that satisfy the join condition. |
| 2  | Logical     | LEFT/RIGHT OUTER JOIN | Returns every row from the preserved input and matching rows from the other input. Unmatched columns contain `NULL` markers. |
| 3  | Logical     | FULL OUTER JOIN       | Returns all matching and unmatched rows from both inputs. Unmatched columns contain `NULL` markers. |
| 4  | Logical     | CROSS JOIN            | Returns the Cartesian product of both inputs: every possible row combination. |
| 5  | Physical    | NESTED LOOPS JOIN     | Processes the outer input one row at a time and searches the inner input for matching rows. |
| 6  | Physical    | HASH JOIN             | Builds a hash table from one input and probes it with rows from the other input. |
| 7  | Physical    | MERGE JOIN            | Merges two inputs that are ordered on compatible equality join keys. |
| 8  | Physical    | ADAPTIVE JOIN         | Chooses between a Hash Join and Nested Loops Join at runtime using a row-count threshold. |
| 9  | Descriptive | COMPLEX JOIN          | An informal term for a query containing multiple joins, conditions, subqueries, or aggregates. |
| 10 | Descriptive | COMPOSITE JOIN        | Uses multiple columns in its join condition. |
| 11 | Descriptive | MULTI-JOIN            | An informal term for a query that joins more than two table sources. |
| 12 | Descriptive | SELF-JOIN             | Joins a table to another reference to itself, normally using aliases. |
| 13 | Relational  | SEMI-JOIN             | Returns rows from the first input that have at least one match in the second input. |
| 14 | Relational  | ANTI-JOIN             | Returns rows from the first input that have no match in the second input. |
| 15 | Relational  | THETA-JOIN            | Uses a comparison operator such as `=`, `<>`, `<`, `>`, `<=`, or `>=`. |
| 16 | Relational  | EQUI-JOIN             | A theta-join that uses equality comparisons. |
| 17 | Relational  | NON-EQUI-JOIN         | Uses a comparison other than equality. |
| 18 | Relational  | NATURAL JOIN | Uses equality to match all columns that have the same names in both inputs. SQL Server does not support this syntax directly. |

---

:electric_plug: **What’s Next**

Many of these join types, and several related concepts, will be explored in detail throughout the following documents. The goal is not only to show *how* joins work, but *why* they behave the way they do, how they relate to the relational model, and how the database engine processes them internally.

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
