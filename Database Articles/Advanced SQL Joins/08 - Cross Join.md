# Cross Joins

A `CROSS JOIN` returns the Cartesian product of two inputs: every row from the first input is paired with every row from the second. If the first input contains 100 rows and the second contains 1,000 rows, the result contains 100,000 rows.

In SQL Server, an uncorrelated `CROSS APPLY` can produce the same Cartesian product. In that specific case, the right-side source does not reference columns from the left side, so the same right-side rows are paired with every left-side row.

`CROSS APPLY` is nevertheless a separate and more general operator. Its right-side table expression can depend on the current left-side row. Correlated subqueries, table-valued functions, empty right-side results, and `OUTER APPLY` will be covered in a separate document.

Because Cartesian products grow multiplicatively, verify the expected row count before applying them to large inputs.

## Ordered Pairs, Permutations, and Combinations

A cross join directly produces ordered pairs. Those pairs can be used as building blocks for permutations and combinations, but the cross join does not enforce either concept by itself.

- In a permutation, order matters. The ordered pairs `(Apple, Peach)` and `(Peach, Apple)` are different.
- In a combination, order does not matter. Those two pairs represent the same two-item combination, so one orientation must be removed.
- Depending on the requirement, additional predicates may also be needed to exclude pairs that repeat the same item.

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

## `CROSS JOIN` and Uncorrelated `CROSS APPLY`

The following `CROSS JOIN` pairs all four rows from `TableA` with all four rows from `TableB`, producing 16 rows.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
CROSS JOIN #TableB AS b
ORDER BY b.ID, a.ID;
```

The same unfiltered Cartesian product can be written with `CROSS APPLY`:

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
CROSS APPLY #TableB AS b
ORDER BY b.ID, a.ID;
```

Both queries return the same result:

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 1    | Apple   |
| 3    | Mango   | 1    | Apple   |
| 4    | *NULL*  | 1    | Apple   |
| 1    | Apple   | 2    | Peach   |
| 2    | Peach   | 2    | Peach   |
| 3    | Mango   | 2    | Peach   |
| 4    | *NULL*  | 2    | Peach   |
| 1    | Apple   | 3    | Kiwi    |
| 2    | Peach   | 3    | Kiwi    |
| 3    | Mango   | 3    | Kiwi    |
| 4    | *NULL*  | 3    | Kiwi    |
| 1    | Apple   | 4    | *NULL*  |
| 2    | Peach   | 4    | *NULL*  |
| 3    | Mango   | 4    | *NULL*  |
| 4    | *NULL*  | 4    | *NULL*  |

The equivalence here depends on the right side being uncorrelated. `#TableB` does not reference the current row from `#TableA`, so SQL Server combines the same four right-side rows with each left-side row.

Only this cross-product case is demonstrated in this chapter. The separate `APPLY` chapter will cover the per-row evaluation behavior that distinguishes `CROSS APPLY` and `OUTER APPLY` from ordinary joins.

## Filtering a Cartesian Product

A `CROSS JOIN` followed by a matching predicate in the `WHERE` clause is logically equivalent to an inner join using the same predicate.

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

For production code, an explicit `INNER JOIN ... ON` usually communicates the intended relationship more clearly.

## Reconstructing a Left Outer Join

A Cartesian product can be filtered to obtain the matched rows and then combined with the unmatched left-side rows. This demonstrates the logical components of a left outer join, although a direct `LEFT OUTER JOIN` is clearer and should normally be preferred.

```sql
WITH LeftJoinSimulation AS
(
    SELECT a.ID    AS A_ID,
           a.Fruit AS A_Fruit,
           b.ID    AS B_ID,
           b.Fruit AS B_Fruit
    FROM #TableA AS a
    CROSS JOIN #TableB AS b
    WHERE a.Fruit = b.Fruit

    UNION ALL

    SELECT a.ID,
           a.Fruit,
           NULL,
           NULL
    FROM #TableA AS a
    WHERE NOT EXISTS
          (
              SELECT 1
              FROM #TableB AS b
              WHERE b.Fruit = a.Fruit
          )
)
SELECT A_ID,
       A_Fruit,
       B_ID,
       B_Fruit
FROM LeftJoinSimulation
ORDER BY A_ID;
```

| A_ID | A_Fruit | B_ID   | B_Fruit |
|-----:|---------|--------|---------|
| 1    | Apple   | 1      | Apple   |
| 2    | Peach   | 2      | Peach   |
| 3    | Mango   | *NULL* | *NULL*  |
| 4    | *NULL*  | *NULL* | *NULL*  |

`UNION ALL` is intentional. Using `UNION` would remove duplicate projected rows and could change the left join's multiset semantics.

## Determining Two-Item Combinations

The following query first creates one distinct set of fruit values from both tables. It then cross joins that set to itself.

The predicate `a.Fruit < b.Fruit` performs three jobs:

- it removes pairs containing the same non-`NULL` value;
- it keeps only one orientation of each pair; and
- it excludes `NULL`, because an ordinary comparison involving `NULL` evaluates to `UNKNOWN`.

The exact ordering of text values is determined by the applicable collation.

```sql
WITH DistinctFruits AS
(
    SELECT Fruit FROM #TableA
    UNION
    SELECT Fruit FROM #TableB
)
SELECT a.Fruit AS Fruit_1,
       b.Fruit AS Fruit_2
FROM DistinctFruits AS a
CROSS JOIN DistinctFruits AS b
WHERE a.Fruit < b.Fruit
ORDER BY a.Fruit, b.Fruit;
```

| Fruit_1 | Fruit_2 |
|---------|---------|
| Apple   | Kiwi    |
| Apple   | Mango   |
| Apple   | Peach   |
| Kiwi    | Mango   |
| Kiwi    | Peach   |
| Mango   | Peach   |

## Canonicalizing Reciprocal Pairs

When `(A, B)` and `(B, A)` should represent the same pair, a `CASE` expression can place the values in a consistent order before `DISTINCT` removes repeats. The following version also preserves `NULL` and always places it in `Fruit_1`.

```sql
SELECT DISTINCT
       CASE
           WHEN a.Fruit IS NULL OR b.Fruit IS NULL THEN NULL
           WHEN a.Fruit < b.Fruit THEN a.Fruit
           ELSE b.Fruit
       END AS Fruit_1,
       CASE
           WHEN a.Fruit IS NULL THEN b.Fruit
           WHEN b.Fruit IS NULL THEN a.Fruit
           WHEN a.Fruit < b.Fruit THEN b.Fruit
           ELSE a.Fruit
       END AS Fruit_2
FROM #TableA AS a
CROSS JOIN #TableB AS b
WHERE a.Fruit <> b.Fruit
   OR a.Fruit IS NULL
   OR b.Fruit IS NULL
ORDER BY Fruit_1, Fruit_2;
```

| Fruit_1 | Fruit_2 |
|---------|---------|
| *NULL*  | *NULL*  |
| *NULL*  | Apple   |
| *NULL*  | Kiwi    |
| *NULL*  | Mango   |
| *NULL*  | Peach   |
| Apple   | Kiwi    |
| Apple   | Mango   |
| Apple   | Peach   |
| Kiwi    | Mango   |
| Kiwi    | Peach   |
| Mango   | Peach   |

This canonicalization is application logic, not an inherent behavior of `CROSS JOIN`.

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
