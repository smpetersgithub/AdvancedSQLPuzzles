# Inner Joins

An `INNER JOIN` returns one row for every pair of input rows whose join condition evaluates to `TRUE`. Conditions that evaluate to `FALSE` or `UNKNOWN` are excluded.

The join condition commonly compares related columns using equality; this is called an equi-join. A non-equi join uses predicates such as `<`, `>`, `<>`, or `BETWEEN`. A join condition can combine equality and non-equality predicates, functions, and other valid search conditions.

Unless otherwise noted, the examples in this document use Microsoft SQL Server and Transact-SQL.

## Sample Data

The examples use the following local temporary tables. The word *NULL* is shown explicitly in the sample data and result tables so that it cannot be confused with an empty string.

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

## Basic Equi-Joins

### Example 1: Explicit `INNER JOIN`

This equi-join matches rows whose `Fruit` values are equal. Ordinary comparisons involving `NULL`, including `NULL = NULL`, evaluate to `UNKNOWN`. Because an inner join retains only conditions that evaluate to `TRUE`, the two rows with `NULL` fruit values do not match.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |

### Example 2: Legacy Implicit-Join Syntax

The following query places the matching condition in the `WHERE` clause and produces the same result as Example 1. This comma-separated form is valid, but explicit `JOIN ... ON` syntax is generally clearer and reduces the risk of an accidental Cartesian product.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a,
     #TableB AS b
WHERE a.Fruit = b.Fruit
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |

### Example 3: Filtering a `CROSS JOIN`

An inner join can be understood logically as a Cartesian product followed by a filter. The following query creates the Cartesian product explicitly and then retains only pairs whose `Fruit` values match.

This interpretation applies to inner joins. Outer, semi, and anti joins have additional semantics and should not all be described as restricted Cartesian products.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
CROSS JOIN #TableB AS b
WHERE a.Fruit = b.Fruit
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |

### Example 4: A Null-Rejecting Filter After a `LEFT JOIN`

The predicate `b.Fruit = 'Apple'` rejects the null-extended rows produced by the `LEFT JOIN`. For this query, that makes the result equivalent to an inner join.

If the intention were to preserve every row from `TableA` while restricting only the matches from `TableB`, the predicate would belong in the `ON` condition instead.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
LEFT JOIN #TableB AS b
    ON a.Fruit = b.Fruit
WHERE b.Fruit = 'Apple';
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |

## Non-Equi and Compound Join Conditions

### Example 5: Inequality Predicates

This non-equi join returns every pair containing different non-`NULL` fruits and different non-`NULL` quantities.

```sql
SELECT a.ID       AS A_ID,
       a.Fruit    AS A_Fruit,
       a.Quantity AS A_Quantity,
       b.ID       AS B_ID,
       b.Fruit    AS B_Fruit,
       b.Quantity AS B_Quantity
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Fruit <> b.Fruit
   AND a.Quantity <> b.Quantity
ORDER BY a.ID, b.ID;
```

| A_ID | A_Fruit | A_Quantity | B_ID | B_Fruit | B_Quantity |
|-----:|---------|-----------:|-----:|---------|-----------:|
| 1    | Apple   | 17         | 2    | Peach   | 25         |
| 1    | Apple   | 17         | 3    | Kiwi    | 20         |
| 2    | Peach   | 20         | 1    | Apple   | 17         |
| 3    | Mango   | 11         | 1    | Apple   | 17         |
| 3    | Mango   | 11         | 2    | Peach   | 25         |
| 3    | Mango   | 11         | 3    | Kiwi    | 20         |

### Example 6: Three-Valued Logic

For any two non-`NULL` values, either `a.Fruit <> b.Fruit` or `a.Fruit = b.Fruit` is true. If either value is `NULL`, both comparisons evaluate to `UNKNOWN`, so the combined condition is also `UNKNOWN`.

The query therefore returns the Cartesian product of the three non-`NULL` fruit rows from each table: nine rows. This condition is intentionally illustrative; `a.Fruit IS NOT NULL AND b.Fruit IS NOT NULL` would express the intended filter more directly.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Fruit <> b.Fruit
    OR a.Fruit = b.Fruit
ORDER BY b.ID, a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 1    | Apple   |
| 3    | Mango   | 1    | Apple   |
| 1    | Apple   | 2    | Peach   |
| 2    | Peach   | 2    | Peach   |
| 3    | Mango   | 2    | Peach   |
| 1    | Apple   | 3    | Kiwi    |
| 2    | Peach   | 3    | Kiwi    |
| 3    | Mango   | 3    | Kiwi    |

### Example 7: Range Comparison

This query returns every pair of rows for which the quantity in `TableA` is greater than or equal to the quantity in `TableB`. No key relationship is implied between the paired rows.

```sql
SELECT a.ID       AS A_ID,
       a.Fruit    AS A_Fruit,
       a.Quantity AS A_Quantity,
       b.ID       AS B_ID,
       b.Fruit    AS B_Fruit,
       b.Quantity AS B_Quantity
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Quantity >= b.Quantity
ORDER BY a.ID, b.ID;
```

| A_ID | A_Fruit | A_Quantity | B_ID | B_Fruit | B_Quantity |
|-----:|---------|-----------:|-----:|---------|-----------:|
| 1    | Apple   | 17         | 1    | Apple   | 17         |
| 2    | Peach   | 20         | 1    | Apple   | 17         |
| 2    | Peach   | 20         | 3    | Kiwi    | 20         |

### Example 8: Combining Equality and `BETWEEN`

Join conditions can use predicates such as `LIKE` and `BETWEEN` and can negate them with `NOT`. The following deliberately artificial example demonstrates an equality predicate combined with a negated, inclusive `BETWEEN` predicate.

```sql
SELECT a.ID       AS A_ID,
       a.Fruit    AS A_Fruit,
       a.Quantity AS A_Quantity,
       b.ID       AS B_ID,
       b.Fruit    AS B_Fruit,
       b.Quantity AS B_Quantity
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
   AND NOT (a.ID BETWEEN a.Quantity AND b.Quantity)
ORDER BY a.ID;
```

| A_ID | A_Fruit | A_Quantity | B_ID | B_Fruit | B_Quantity |
|-----:|---------|-----------:|-----:|---------|-----------:|
| 1    | Apple   | 17         | 1    | Apple   | 17         |
| 2    | Peach   | 20         | 2    | Peach   | 25         |

## Null-Safe Equality

Ordinary equality does not match two `NULL` values. The following examples show several ways to request null-safe equality in SQL Server.

### Example 9: Replacing `NULL` With a Sentinel Value

`ISNULL(column, '')` maps `NULL` to an empty string before comparing the values. This allows two `NULL` values to match, but it also makes a real empty string match a `NULL`. Choose a replacement value only when that collision is acceptable or impossible under the data model.

Applying a function to an indexed join column can also make the predicate non-sargable and prevent an index seek. Verify performance with an actual execution plan when this technique is used on production data.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON ISNULL(a.Fruit, '') = ISNULL(b.Fruit, '')
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |
| 4    | *NULL*  | 4    | *NULL*  |

### Example 10: Explicit `NULL` Handling

This query expresses the same null-safe comparison as Example 9 without replacing `NULL` with a sentinel value. The `IS NULL` predicates explicitly allow two `NULL` values to match.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
    OR (a.Fruit IS NULL AND b.Fruit IS NULL)
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |
| 4    | *NULL*  | 4    | *NULL*  |

### Example 11: `IS NOT DISTINCT FROM`

SQL Server 2022 (16.x) and supported Azure and Microsoft Fabric SQL products provide the `IS NOT DISTINCT FROM` predicate. It compares two expressions and always returns `TRUE` or `FALSE`, even when one or both expressions are `NULL`.

This is the clearest null-safe form when the target platform supports it.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Fruit IS NOT DISTINCT FROM b.Fruit
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |
| 4    | *NULL*  | 4    | *NULL*  |

### Example 12: An `EXISTS` Predicate With `INTERSECT`

SQL Server can also express null-safe equality with an `EXISTS` predicate in the `ON` condition. This is not a separate `ON EXISTS` clause.

`INTERSECT` considers two `NULL` values equal when determining distinct rows. The subquery therefore returns a row when the two fruit values are equal or when both are `NULL`, and `EXISTS` converts that result into a true-or-false condition.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON EXISTS
       (
           SELECT a.Fruit
           INTERSECT
           SELECT b.Fruit
       )
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |
| 4    | *NULL*  | 4    | *NULL*  |

## Advanced and Unusual Forms

### Example 13: A `CASE` Expression in the Join Logic

A `CASE` expression can participate in a join condition, but this form is often harder to understand than a direct predicate. It may also make the predicate non-sargable, complicate cardinality estimation, and produce a less efficient execution plan. The exact result depends on the data, indexes, SQL Server version, and optimizer choices.

The explicit `CROSS JOIN` makes it clear that the `WHERE` clause supplies the filtering condition.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
CROSS JOIN #TableB AS b
WHERE CASE
          WHEN a.Fruit = 'Apple' THEN a.Fruit
          ELSE 'Peach'
      END = b.Fruit
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |
| 3    | Mango   | 2    | Peach   |
| 4    | *NULL*  | 2    | Peach   |

### Example 14: Multiple Self-Joins

This query reads `TableA` through four aliases: the original reference plus three self-joins. Each `ON` condition appears immediately after its corresponding `JOIN`, which makes the relationships easier to read and maintain.

There is no general requirement to place `ON` clauses in reverse order. Reverse-looking `ON` clauses arise only from an unusually nested join expression and are best avoided when a conventional form is available.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit
FROM #TableA AS a
INNER JOIN #TableA AS b
    ON a.Fruit = b.Fruit
INNER JOIN #TableA AS c
    ON b.Fruit = c.Fruit
INNER JOIN #TableA AS d
    ON c.Fruit = d.Fruit
ORDER BY a.ID;
```

| A_ID | A_Fruit |
|-----:|---------|
| 1    | Apple   |
| 2    | Peach   |
| 3    | Mango   |

## Other Database Systems

The examples in this section assume that ordinary tables named `TableA` and `TableB` have been created in the target database. SQL Server temporary-table names beginning with `#` or `##` are not portable to MySQL or Oracle.

### MySQL: `USING`

MySQL supports a `USING` clause when the named join columns exist in both inputs.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM TableA AS a
INNER JOIN TableB AS b
    USING (Fruit)
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |

Oracle also supports `USING`, although vendor-specific details should be checked against the documentation for the deployed version.

### Oracle: `NATURAL JOIN`

Oracle supports `NATURAL JOIN`. It automatically compares every pair of columns that have the same name in both inputs. In this sample, those columns are `ID`, `Fruit`, and `Quantity`.

Because adding or renaming a common column can silently change a natural join's behavior, an explicit `JOIN ... ON` or `JOIN ... USING` condition is usually safer in production code.

```sql
SELECT *
FROM TableA a
NATURAL JOIN TableB b;
```

| ID | Fruit | Quantity |
|---:|-------|---------:|
| 1  | Apple | 17       |

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
