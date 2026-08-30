# Outer Joins

An outer join returns the rows that satisfy its join condition and also preserves unmatched rows from one or both inputs. For a preserved row with no match, columns from the other input are returned as `NULL`.

SQL Server supports three logical outer-join forms:

- `LEFT OUTER JOIN` preserves every row from the left input. When a left-side row has no match, columns from the right input are `NULL`.
- `RIGHT OUTER JOIN` preserves every row from the right input. When a right-side row has no match, columns from the left input are `NULL`.
- `FULL OUTER JOIN` preserves unmatched rows from both inputs, in addition to returning the matched rows.

The keyword `OUTER` is optional: `LEFT JOIN` and `LEFT OUTER JOIN`, for example, mean the same thing.

A right outer join can always be rewritten as a left outer join by swapping the inputs. Many teams prefer left joins because a consistent direction can make a query easier to follow, but a right join is not inherently incorrect. This document focuses on left and right joins; full outer joins are covered separately.

Unless otherwise noted, the examples use Microsoft SQL Server and Transact-SQL.

## Sample Data

The examples use the following local temporary tables. The word *NULL* is displayed explicitly in the sample data and result tables so that it cannot be confused with an empty string.

```sql
DROP TABLE IF EXISTS #TableA;
DROP TABLE IF EXISTS #TableB;

CREATE TABLE #TableA
(
    ID       int         NOT NULL,
    Fruit    varchar(20) NULL,
    Quantity int         NULL
);

CREATE TABLE #TableB
(
    ID       int         NOT NULL,
    Fruit    varchar(20) NULL,
    Quantity int         NULL
);

INSERT INTO #TableA (ID, Fruit, Quantity)
VALUES (1, 'Apple', 17),
       (2, 'Peach', 20),
       (3, 'Mango', 11),
       (4, NULL,     5);

INSERT INTO #TableB (ID, Fruit, Quantity)
VALUES (1, 'Apple', 17),
       (2, 'Peach', 25),
       (3, 'Kiwi',  20),
       (4, NULL,    NULL);
```

**Table A**

| ID | Fruit  | Quantity |
|---:|--------|---------:|
| 1  | Apple  | 17       |
| 2  | Peach  | 20       |
| 3  | Mango  | 11       |
| 4  | *NULL* | 5        |

**Table B**

| ID | Fruit  | Quantity |
|---:|--------|---------:|
| 1  | Apple  | 17       |
| 2  | Peach  | 25       |
| 3  | Kiwi   | 20       |
| 4  | *NULL* | *NULL*   |

## `LEFT OUTER JOIN`

### Preserving Every Left-Side Row

The following query returns every row from `TableA`. Apple and Peach find matching rows in `TableB`. Mango does not match any right-side row, so the selected columns from `TableB` are null-extended.

The row in `TableA` whose fruit is `NULL` also remains unmatched. Ordinary equality does not match `NULL` to another `NULL`; the comparison evaluates to `UNKNOWN`, not `TRUE`.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
LEFT OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID   | B_Fruit |
|-----:|---------|--------|---------|
| 1    | Apple   | 1      | Apple   |
| 2    | Peach   | 2      | Peach   |
| 3    | Mango   | *NULL* | *NULL*  |
| 4    | *NULL*  | *NULL* | *NULL*  |

The `NULL` in `A_Fruit` on the last row comes from the stored data. The `NULL` values in `B_ID` and `B_Fruit` were introduced because no right-side row matched. A result table alone may not reveal that distinction, so understanding the source columns matters.

### Finding Left-Side Rows With No Match

A left outer join can be used as a left anti join by retaining only rows for which the right side was null-extended.

Test a right-side column that cannot be `NULL` in stored data, such as `b.ID`. Testing a nullable column can make a matched row containing a stored `NULL` indistinguishable from an unmatched row.

```sql
SELECT a.ID       AS A_ID,
       a.Fruit    AS A_Fruit,
       a.Quantity AS A_Quantity
FROM #TableA AS a
LEFT OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
WHERE b.ID IS NULL
ORDER BY a.ID;
```

| A_ID | A_Fruit | A_Quantity |
|-----:|---------|-----------:|
| 3    | Mango   | 11         |
| 4    | *NULL*  | 5          |

`NOT EXISTS` is another common way to express the same anti-join requirement and is covered in the chapter on semi and anti joins.

## Predicates in `ON` and `WHERE`

With an outer join, predicate placement can change the result:

- The `ON` condition determines which row pairs match. A left-side row that finds no match is still preserved by a left join.
- The `WHERE` condition filters the result after the join. A null-rejecting condition on the right-side columns removes null-extended rows and can make the result equivalent to an inner join.

### Restricting Matches in the `ON` Condition

The additional condition `b.Fruit = 'Apple'` allows only Apple to match. Every row from `TableA` is still preserved.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
LEFT OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
   AND b.Fruit = 'Apple'
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID   | B_Fruit |
|-----:|---------|--------|---------|
| 1    | Apple   | 1      | Apple   |
| 2    | Peach   | *NULL* | *NULL*  |
| 3    | Mango   | *NULL* | *NULL*  |
| 4    | *NULL*  | *NULL* | *NULL*  |

### Filtering the Joined Result in `WHERE`

Moving the Apple condition to the `WHERE` clause removes all rows for which `b.Fruit` is not Apple, including the null-extended rows. For this query, the left join is therefore equivalent to an inner join.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
LEFT OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
WHERE b.Fruit = 'Apple'
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |

Not every `WHERE` condition converts an outer join to an inner join. The effect depends on whether the condition accepts or rejects the null-extended rows. For example, `WHERE b.ID IS NULL` deliberately retains those rows in the anti-join example.

## `RIGHT OUTER JOIN`

A right outer join preserves every row from its right input. Here, Kiwi and the row whose `Fruit` is `NULL` have no match in `TableA`, so the selected columns from `TableA` are null-extended.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
RIGHT OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
ORDER BY b.ID;
```

| A_ID   | A_Fruit | B_ID | B_Fruit |
|--------|---------|-----:|---------|
| 1      | Apple   | 1    | Apple   |
| 2      | Peach   | 2    | Peach   |
| *NULL* | *NULL*  | 3    | Kiwi    |
| *NULL* | *NULL*  | 4    | *NULL*  |

The same operation can be written as a left join by swapping the inputs:

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableB AS b
LEFT OUTER JOIN #TableA AS a
    ON a.Fruit = b.Fruit
ORDER BY b.ID;
```

## Multiple Outer Joins

Mixing left and right joins is valid, but frequently changing the preserved direction can make a larger query difficult to reason about. The original mixed-direction example can be written with a consistent left-to-right flow by beginning with `TableB` and using two left joins.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit,
       c.ID    AS C_ID,
       c.Fruit AS C_Fruit
FROM #TableB AS b
LEFT OUTER JOIN #TableA AS a
    ON a.Fruit = b.Fruit
LEFT OUTER JOIN #TableA AS c
    ON b.Fruit = c.Fruit
ORDER BY b.ID;
```

| A_ID   | A_Fruit | B_ID | B_Fruit | C_ID   | C_Fruit |
|--------|---------|-----:|---------|--------|---------|
| 1      | Apple   | 1    | Apple   | 1      | Apple   |
| 2      | Peach   | 2    | Peach   | 2      | Peach   |
| *NULL* | *NULL*  | 3    | Kiwi    | *NULL* | *NULL*  |
| *NULL* | *NULL*  | 4    | *NULL*  | *NULL* | *NULL*  |

## Scalar Subqueries Are Not Outer Joins

A scalar correlated subquery in the `SELECT` list can sometimes produce a result shaped like a left join: it returns one value when it finds one row and `NULL` when it finds none. It is nevertheless a subquery, not an outer join.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       (SELECT b.ID FROM #TableB AS b WHERE b.Fruit = a.Fruit) AS B_ID,
       (SELECT b.Fruit FROM #TableB AS b WHERE b.Fruit = a.Fruit) AS B_Fruit
FROM #TableA AS a
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID   | B_Fruit |
|-----:|---------|--------|---------|
| 1    | Apple   | 1      | Apple   |
| 2    | Peach   | 2      | Peach   |
| 3    | Mango   | *NULL* | *NULL*  |
| 4    | *NULL*  | *NULL* | *NULL*  |

This is not generally equivalent to the earlier left join:

- Each scalar subquery must return at most one row. SQL Server raises an error if a subquery returns multiple rows, while a left join returns every matching pair.
- Repeating correlated subqueries can duplicate work and obscure the relationship between the selected values.
- A left join usually expresses this particular requirement more directly.

Subqueries can appear in `SELECT`, `FROM`, and `WHERE`, but the `JOIN` operator itself belongs to the `FROM` clause.

## Oracle's Legacy `(+)` Syntax

Oracle supports a legacy outer-join operator written as `(+)`. The marker is placed on the optional, or null-generated, side of the comparison. The following query preserves every row from `TableA` and is equivalent to a left outer join.

This example assumes that ordinary Oracle tables named `TableA` and `TableB` exist. SQL Server temporary-table names beginning with `#` or `##` are not valid substitutes in this query.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM TableA a,
     TableB b
WHERE a.Fruit = b.Fruit(+)
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID   | B_Fruit |
|-----:|---------|--------|---------|
| 1    | Apple   | 1      | Apple   |
| 2    | Peach   | 2      | Peach   |
| 3    | Mango   | *NULL* | *NULL*  |
| 4    | *NULL*  | *NULL* | *NULL*  |

Oracle recommends the ANSI `FROM ... OUTER JOIN` form instead. It is clearer, more portable, and does not have the legacy operator's additional restrictions:

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM TableA a
LEFT OUTER JOIN TableB b
    ON a.Fruit = b.Fruit
ORDER BY a.ID;
```

## Continue Reading

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

[Advanced SQL Puzzles](https://advancedsqlpuzzles.com)
