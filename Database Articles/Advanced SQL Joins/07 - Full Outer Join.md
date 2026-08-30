# Full Outer Join

A `FULL OUTER JOIN` returns every matched pair of rows and also preserves unmatched rows from both inputs. For an unmatched row, columns from the other input are returned as `NULL`.

Full outer joins are useful when reconciling two related datasets. They can show:

- rows found in both datasets;
- rows found only in the first dataset;
- rows found only in the second dataset; and
- differences between the matched rows.

The keyword `OUTER` is optional: `FULL JOIN` and `FULL OUTER JOIN` mean the same thing in SQL Server.

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

## What Counts as a Match?

The `ON` condition defines which rows correspond to one another. In these examples, rows match when their `Fruit` values are equal:

```sql
ON a.Fruit = b.Fruit
```

This has several important consequences:

- Apple and Peach match even when another column, such as `Quantity`, differs.
- Mango and Kiwi do not match because their fruit values differ.
- The two `NULL` fruit values do not match. Ordinary equality involving `NULL` evaluates to `UNKNOWN`, not `TRUE`.
- If either input contains duplicate fruit values, the join can return multiple matching combinations. A reconciliation query should use a key, or set of columns, that represents the intended row identity.

## Example 1: Returning Matched and Unmatched Rows

The following query returns all matched and unmatched fruit rows from both tables.

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
FULL OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
ORDER BY COALESCE(a.ID, b.ID),
         CASE WHEN a.ID IS NULL THEN 1 ELSE 0 END;
```

| A_ID   | A_Fruit | B_ID   | B_Fruit |
|--------|---------|--------|---------|
| 1      | Apple   | 1      | Apple   |
| 2      | Peach   | 2      | Peach   |
| 3      | Mango   | *NULL* | *NULL*  |
| *NULL* | *NULL*  | 3      | Kiwi    |
| 4      | *NULL*  | *NULL* | *NULL*  |
| *NULL* | *NULL*  | 4      | *NULL*  |

The last two rows come from different inputs. The fifth row preserves the row with `ID = 4` from `TableA`; the sixth preserves the row with `ID = 4` from `TableB`. They do not match because `NULL = NULL` is not `TRUE`.

## Example 2: Finding Rows Present on Only One Side

Filtering for a missing non-nullable `ID` returns the unmatched rows from both inputs. Relative to the `Fruit` join condition, this is the symmetric difference of the two datasets.

`COALESCE` selects the available value from either side for display. It does not change the join condition or cause two `NULL` fruit values to match. The `Row_Location` column preserves the row's origin, which is important when the two tables contain the same `ID` or a `NULL` fruit value.

```sql
SELECT COALESCE(a.ID, b.ID)       AS Source_ID,
       COALESCE(a.Fruit, b.Fruit) AS Fruit,
       CASE
           WHEN a.ID IS NULL THEN 'Only in TableB'
           WHEN b.ID IS NULL THEN 'Only in TableA'
       END AS Row_Location
FROM #TableA AS a
FULL OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
WHERE a.ID IS NULL
   OR b.ID IS NULL
ORDER BY COALESCE(a.ID, b.ID),
         CASE WHEN a.ID IS NULL THEN 1 ELSE 0 END;
```

| Source_ID | Fruit  | Row_Location   |
|----------:|--------|----------------|
| 3         | Mango  | Only in TableA |
| 3         | Kiwi   | Only in TableB |
| 4         | *NULL* | Only in TableA |
| 4         | *NULL* | Only in TableB |

The `ID` columns are defined as `NOT NULL`, so `a.ID IS NULL` or `b.ID IS NULL` reliably identifies a null-extended side. If the tested column were nullable in stored data, it could not safely distinguish an unmatched row from a matched row containing a stored `NULL`.

## Example 3: Classifying Missing and Changed Rows

A complete comparison often needs to distinguish missing rows from matched rows whose non-key values differ. Because `Fruit` defines the match in this example, the quantities can be compared after the join.

```sql
SELECT a.ID       AS A_ID,
       a.Fruit    AS A_Fruit,
       a.Quantity AS A_Quantity,
       b.ID       AS B_ID,
       b.Fruit    AS B_Fruit,
       b.Quantity AS B_Quantity,
       CASE
           WHEN a.ID IS NULL THEN 'Only in TableB'
           WHEN b.ID IS NULL THEN 'Only in TableA'
           WHEN a.Quantity = b.Quantity
             OR (a.Quantity IS NULL AND b.Quantity IS NULL)
               THEN 'Same quantity'
           ELSE 'Different quantity'
       END AS Comparison_Result
FROM #TableA AS a
FULL OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
ORDER BY COALESCE(a.ID, b.ID),
         CASE WHEN a.ID IS NULL THEN 1 ELSE 0 END;
```

| A_ID   | A_Fruit | A_Quantity | B_ID   | B_Fruit | B_Quantity | Comparison_Result  |
|--------|---------|------------|--------|---------|------------|--------------------|
| 1      | Apple   | 17         | 1      | Apple   | 17         | Same quantity      |
| 2      | Peach   | 20         | 2      | Peach   | 25         | Different quantity |
| 3      | Mango   | 11         | *NULL* | *NULL*  | *NULL*     | Only in TableA     |
| *NULL* | *NULL*  | *NULL*     | 3      | Kiwi    | 20         | Only in TableB     |
| 4      | *NULL*  | 5          | *NULL* | *NULL*  | *NULL*     | Only in TableA     |
| *NULL* | *NULL*  | *NULL*     | 4      | *NULL*  | *NULL*     | Only in TableB     |

The explicit `NULL` comparison in the `CASE` expression makes two null quantities count as the same. On SQL Server 2022 or later, that test can also be written with `a.Quantity IS NOT DISTINCT FROM b.Quantity`.

## Example 4: Retaining Only Matched Rows

A full outer join followed by null-rejecting predicates can retain only matched rows. Because both `ID` columns are non-nullable in the base tables, the following conditions remove every null-extended row:

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
FULL OUTER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
WHERE a.ID IS NOT NULL
  AND b.ID IS NOT NULL
ORDER BY a.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 1    | Apple   |
| 2    | Peach   | 2    | Peach   |

For this result, a direct `INNER JOIN` is clearer and should normally be preferred. This example demonstrates how filtering affects a full outer join; it is not a recommended substitute for an inner join.

## Example 5: Simulating a Full Outer Join

A full outer join can be reproduced with two left joins and `UNION ALL`. The first branch returns every row from `TableA`, including its matches. The second branch returns only the rows from `TableB` that found no match in `TableA`.

```sql
WITH FullJoinSimulation AS
(
    SELECT a.ID    AS A_ID,
           a.Fruit AS A_Fruit,
           b.ID    AS B_ID,
           b.Fruit AS B_Fruit
    FROM #TableA AS a
    LEFT OUTER JOIN #TableB AS b
        ON a.Fruit = b.Fruit

    UNION ALL

    SELECT a.ID    AS A_ID,
           a.Fruit AS A_Fruit,
           b.ID    AS B_ID,
           b.Fruit AS B_Fruit
    FROM #TableB AS b
    LEFT OUTER JOIN #TableA AS a
        ON a.Fruit = b.Fruit
    WHERE a.ID IS NULL
)
SELECT A_ID,
       A_Fruit,
       B_ID,
       B_Fruit
FROM FullJoinSimulation
ORDER BY COALESCE(A_ID, B_ID),
         CASE WHEN A_ID IS NULL THEN 1 ELSE 0 END;
```

| A_ID   | A_Fruit | B_ID   | B_Fruit |
|--------|---------|--------|---------|
| 1      | Apple   | 1      | Apple   |
| 2      | Peach   | 2      | Peach   |
| 3      | Mango   | *NULL* | *NULL*  |
| *NULL* | *NULL*  | 3      | Kiwi    |
| 4      | *NULL*  | *NULL* | *NULL*  |
| *NULL* | *NULL*  | 4      | *NULL*  |

`UNION ALL` is intentional. Replacing it with `UNION` would remove duplicate projected rows and could change the full join's multiset semantics.

The second branch tests `a.ID`, a non-nullable column, to identify unmatched rows. Testing a nullable column would make this pattern unreliable.

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
