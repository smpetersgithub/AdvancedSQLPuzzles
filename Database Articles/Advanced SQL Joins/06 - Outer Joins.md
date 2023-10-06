# OUTER JOINS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Outer Joins consist of `LEFT`, `RIGHT`, and `FULL OUTER JOIN`.  `LEFT OUTER JOIN` and `RIGHT OUTER JOIN` function the same; the `LEFT OUTER JOIN` returns all records from the left table, and the `RIGHT OUTER JOIN` returns all records from the right table.


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;It is best practice to use the `LEFT OUTER JOIN` over the `RIGHT OUTER JOIN`, as we naturally read from left to right.  The `LEFT OUTER JOIN` is more intuitive in terms of its behavior, as the left table is preserved, and the right table is optional.  I will mainly demonstrate the `LEFT OUTER JOIN` for this reason.  Using `RIGHT OUTER JOIN` is considered a bad practice and should be avoided.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This document covers the `LEFT OUTER JOIN,` and the `RIGHT OUTER JOIN`.  The `FULL OUTER JOIN` has its own separate document.

-----------------------------------------------------------

We will use the following tables that contain types of fruits and their quantity.  

[The DDL to create these tables can be found here.](Sample%20Data.md)

**Table A**
| ID | Fruit   | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 20       |
| 3  | Mango   | 11       |
| 4  | \<NULL> | 5        |
  
**Table B**
| ID |  Fruit  | Quantity  |
|----|---------|-----------|
|  1 | Apple   | 17        |
|  2 | Peach   | 25        |
|  3 | Kiwi    | 20        |
|  4 | \<NULL> | \<NULL>   |
        
-----------------------------------------------------------
        
#### LEFT OUTER JOIN

The most widely used case for the `LEFT OUTER JOIN` is when we want all values in `TableA`, regardless of their presence in `TableB`.  A join condition in an `OUTER JOIN` acts as a matching criterion and not as a filtering mechanism.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a LEFT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit;
```

| ID |  Fruit  |    ID   |  Fruit  |
|----|---------|---------|---------|
| 1  | Apple   | 1       | Apple   |
| 2  | Peach   | 2       | Peach   |
| 3  | Mango   | \<NULL> | \<NULL> |
| 4  | \<NULL> | \<NULL> | \<NULL> |

---

A `LEFT OUTER JOIN` is one of several methods to determine records in `TableA` that do not exist in `TableB`.  The following statement returns all values in `TableA` that do not exist in `TableB`.  There are other (and possibly better) ways of writing this query, which we will cover later.

```sql
SELECT  a.*
FROM    ##TableA a LEFT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   b.Fruit IS NULL;
```

| ID | Fruit  | Quantity |
|----|--------|----------|
|  3 | Mango  |       11 |
|  4 | <NULL> |        5 |

---

Predicate logic in the `ON` clause behaves differently than predicate logic in the `WHERE` clause.  Notice the difference in output between these two queries.

Placing predicate login in the `ON` statement preserves the outer join.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a LEFT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit AND b.Fruit = 'Apple';
```

| ID |  Fruit  |   ID    |  Fruit  |
|----|---------|---------|---------|
| 1  | Apple   | 1       | Apple   |
| 2  | Peach   | \<NULL> | \<NULL> |
| 3  | Mango   | \<NULL> | \<NULL> |
| 4  | \<NULL> | \<NULL> | \<NULL> |

Placing a predicate on the outer joined table in the `WHERE` clause causes this to function to act as an `INNER JOIN`. 

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a LEFT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   b.Fruit = 'Apple';
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |

-----------------------------------------------------------
  
Joins can exist in the `SELECT`, `FROM`, and `WHERE` clauses of an SQL statement. 

You can also have nested `SELECT` statements which act as outer joins, as demonstrated below.
  
```sql 
SELECT  a.ID,
        a.Fruit,
        (SELECT B.ID FROM ##TableB b WHERE a.Fruit = b.Fruit) AS ID,
        (SELECT b.Fruit FROM ##TableB b WHERE a.Fruit = b.Fruit) AS Fruit
FROM    ##TableA a;
```
  
| ID |   Fruit |   ID    |  Fruit  |
|----|---------|---------|---------|
| 1  | Apple   | 1       | Apple   |
| 2  | Peach   | 2       | Peach   |
| 3  | Mango   | \<NULL> | \<NULL> |
| 4  | \<NULL> | \<NULL> | \<NULL> |

In Microsoft SQL Server, up to 32 levels of nesting is possible, although the limit varies based on available memory and the complexity of other expressions in the query. Individual queries may not support nesting up to 32 levels. A subquery can appear anywhere an expression can be used if it returns a single value

Here is a `SELECT`, within a `SELECT`, within a `SELECT` statement.  Nesting SQL statements can make them difficult to read and should be avoided if possible.

```sql
SELECT  a.ID,
        a.Fruit,
        (SELECT B.ID FROM ##TableB b WHERE a.Fruit = b.Fruit) AS ID,
        (SELECT (SELECT Fruit FROM ##TableB b WHERE b.Fruit = c.Fruit) FROM ##TableB c WHERE c.Fruit = a.Fruit) AS Fruit
FROM    ##TableA a;
```
  
| ID |  Fruit  |    ID   |  Fruit  |
|----|---------|---------|---------|
| 1 | Apple    | 1       | Apple   |
| 2 | Peach    | 2       | Peach   |
| 3 | Mango    | \<NULL> | \<NULL> |
| 4 | \0<NULL> | \<NULL> | \<NULL> |

-----------------------------------------------------------
   
Windowing functions were added to the `ANSI/ISO Standard SQL:2003` and then extended in `ANSI/ISO Standard SQL:2008`.  Microsoft SQL Server did not implement window functions until SQL Server 2012.

Because of Microsoft SQL Server's delay in implementation, you may see statements such as below that were used to mimic window functions.  This statement is often called a "Flash Fill" or "Data Smudge".

This SQL statement will populate the NULL markers in the `Fruit` column with the nearest prior value.

```sql
SELECT  a.ID,
        (SELECT b.Fruit
        FROM    ##TableA b
        WHERE   b.ID =
                    (SELECT MAX(c.ID)
                    FROM ##TableA c
                    WHERE c.ID <= a.ID AND c.Fruit != '')) Fruit,
        a.Quantity
FROM    ##TableA a;
```

| ID | Fruit | Quantity |
|----|-------|----------|
| 1  | Apple | 17       |
| 2  | Peach | 20       |
| 3  | Mango | 11       |
| 4  | Mango | 5        |

Here the query can be written much cleaner using a window function.

```sql
WITH cte_Count AS
(
SELECT  ID,
        Fruit,
        Quantity,
        COUNT(Fruit) OVER (ORDER BY ID) AS DistinctCount
FROM    ##TableA
)
SELECT  ID,
        MAX(Fruit) OVER (PARTITION BY DistinctCount) AS Fruit,
        Quantity
FROM    cte_Count
ORDER BY ID;
```

| ID | Fruit | Quantity |
|----|-------|----------|
| 1  | Apple | 17       |
| 2  | Peach | 20       |
| 3  | Mango | 11       |
| 4  | Mango | 5        |
                                     
-----------------------------------------------------------

Using both `LEFT OUTER JOINS` and `RIGHT OUTER JOINS` in a single query is probably the worst SQL practice for an SQL developer, but it is possible.  Avoid this like the plague, as these queries become very hard to read and can be very easy to get wrong.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit,
        c.ID,
        c.Fruit
FROM    ##TableA a RIGHT OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit LEFT OUTER JOIN
        ##TableA c ON b.Fruit = c.Fruit;
```

|   ID    |  Fruit  | ID |  Fruit  |   ID    |  Fruit  |
|---------|---------|----|---------|---------|---------|
| 1       | Apple   | 1  | Apple   | 1       | Apple   |
| 2       | Peach   | 2  | Peach   | 2       | Peach   |
| \<NULL> | \<NULL> | 3  | Kiwi    | \<NULL> | \<NULL> |
| \<NULL> | \<NULL> | 4  | \<NULL> | \<NULL> | \<NULL> |

-----------------------------------------------------------

The plus sign is Oracle syntax for an outer join and is not ANSI standard.  The `+` sign determines which table is outer joined.
  
  ```sql
  SELECT  a.ID,
        a.Fruit
        b.ID,
        b.Fruit
FROM    ##TableA a,
        ##TableB b
WHERE   a.Fruit = b.Fruit(+)
```
  
| ID |  Fruit  |   ID    |  Fruit  |
|----|---------|---------|---------|
| 1  | Apple   | 1       | Apple   |
| 2  | Peach   | 2       | Peach   |
| 3  | Mango   | \<NULL> | \<NULL> |
| 4  | \<NULL> | \<NULL> | \<NULL> |
  
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
