# Semi and Anti-Joins

Semi and anti-joins are logical join operations that decide whether to retain rows from one input based on the presence or absence of matching rows in another input.

- A **left semi-join** returns a row from the left input when at least one matching row exists in the right input.
- A **left anti-join** returns a row from the left input when no matching row exists in the right input.

Only columns from the left input are returned. The right input is used to test for matching rows, not to contribute columns to the result.

Transact-SQL does not provide `SEMI JOIN` or `ANTI JOIN` keywords. These operations are commonly expressed with:

- `EXISTS` or `IN` for semi-joins;
- `NOT EXISTS` or, with careful `NULL` handling, `NOT IN` for anti-joins; and
- `LEFT JOIN ... WHERE right_key IS NULL` for another anti-join form.

SQL Server execution plans can identify these operations as logical **Left Semi Join** or **Left Anti Semi Join** operations even though the query text uses different syntax.

## Defining Characteristics

A semi-join or anti-join has the following behavior:

1. It returns columns from only one input, usually called the left or outer input.
2. It retains or rejects each left-side row according to whether a qualifying right-side row exists.
3. Multiple matching rows on the right do not multiply a qualifying left-side row.

The third point does not mean that semi-joins remove duplicates already present in the left input. If the left input contains the same row twice and both occurrences qualify, both occurrences remain unless the query also uses `DISTINCT` or another deduplication operation.

The matching condition is often equality, but an `EXISTS` or `NOT EXISTS` subquery can use any valid search condition.

## Why Use Them Instead of an `INNER JOIN`?

When only existence matters, a semi-join communicates that intent directly:

- Right-side columns cannot accidentally become part of the result.
- Multiple right-side matches do not multiply left-side rows.
- The query does not need `DISTINCT` merely to undo duplication introduced by an inner join.

Do not assume that one syntax is always faster. SQL Server can transform logically equivalent `IN`, `EXISTS`, and join-based forms into the same or similar plans. Performance depends on the data, indexes, predicates, statistics, and chosen execution plan.

## `NULL`, `IN`, and `EXISTS`

The operators have different three-valued-logic implications:

- `IN` compares a scalar value with the values in a list or single-column subquery. A `NULL` item cannot match an outer `NULL` through ordinary equality.
- `NOT IN` is unsafe when its list or subquery can return `NULL`. A candidate that does not equal any known value still has an `UNKNOWN` comparison against `NULL`, so the `WHERE` clause does not retain it.
- `EXISTS` and `NOT EXISTS` test whether the subquery returns rows. Values in the subquery's `SELECT` list, including `NULL`, do not affect that test.
- With correlated `EXISTS` and `NOT EXISTS`, `NULL` behavior comes from the predicates inside the subquery. For example, `a.Fruit = b.Fruit` does not match two `NULL` values.

For nullable anti-join values, `NOT EXISTS` is usually the clearest and safest choice.

## Sample Data

The examples use the following local temporary tables. The word *NULL* is displayed explicitly so that it cannot be confused with an empty string.

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

## Semi-Joins

### Example 1: `IN` With a Value List

`IN` returns `TRUE` when the tested value equals at least one item in the list. Adding `NULL` to the list does not cause the `NULL` fruit from `TableA` to match; `NULL = NULL` evaluates to `UNKNOWN`.

The presence of `NULL` does not suppress the known Apple and Peach matches.

```sql
SELECT a.ID,
       a.Fruit
FROM #TableA AS a
WHERE a.Fruit IN ('Apple', 'Peach', NULL)
ORDER BY a.ID;
```

| ID | Fruit |
|---:|-------|
| 1  | Apple |
| 2  | Peach |

### Example 2: `IN` With a Subquery

This semi-join retains rows from `TableA` whose fruit value occurs in `TableB`. Although both tables contain a `NULL` fruit, ordinary equality does not match those rows.

```sql
SELECT a.ID,
       a.Fruit
FROM #TableA AS a
WHERE a.Fruit IN
      (
          SELECT b.Fruit
          FROM #TableB AS b
      )
ORDER BY a.ID;
```

| ID | Fruit |
|---:|-------|
| 1  | Apple |
| 2  | Peach |

### Example 3: A Correlated `IN` Subquery

An `IN` subquery can be correlated. For each row from `TableA`, the inner query first selects fruit values from `TableB` having the same quantity. The outer fruit must then occur in that per-row set.

Only Apple qualifies. Peach has the same quantity as Kiwi, but its fruit value is not Kiwi.

```sql
SELECT a.ID,
       a.Fruit
FROM #TableA AS a
WHERE a.Fruit IN
      (
          SELECT b.Fruit
          FROM #TableB AS b
          WHERE b.Quantity = a.Quantity
      )
ORDER BY a.ID;
```

| ID | Fruit |
|---:|-------|
| 1  | Apple |

### Example 4: A Correlated `EXISTS` Subquery

`EXISTS` returns `TRUE` when its subquery returns at least one row. The value projected by that subquery is irrelevant, so `SELECT 1`, `SELECT NULL`, and `SELECT *` have the same existence semantics. `SELECT 1` is a common convention because it makes the intent obvious.

The comparison inside this subquery determines the `NULL` behavior. Because `a.Fruit = b.Fruit` is not `TRUE` for two `NULL` values, the null fruit does not qualify.

```sql
SELECT a.ID,
       a.Fruit
FROM #TableA AS a
WHERE EXISTS
      (
          SELECT 1
          FROM #TableB AS b
          WHERE b.Fruit = a.Fruit
      )
ORDER BY a.ID;
```

| ID | Fruit |
|---:|-------|
| 1  | Apple |
| 2  | Peach |

### Example 5: `EXISTS` Tests for Rows, Not Values

The following subquery is uncorrelated: it does not reference `TableA`. In SQL Server, `SELECT NULL` without a `FROM` clause returns one row containing a null value. Because a row exists, `EXISTS` is `TRUE` for every row from `TableA`.

```sql
SELECT a.ID,
       a.Fruit,
       a.Quantity
FROM #TableA AS a
WHERE EXISTS (SELECT NULL)
ORDER BY a.ID;
```

| ID | Fruit  | Quantity |
|---:|--------|---------:|
| 1  | Apple  | 17       |
| 2  | Peach  | 20       |
| 3  | Mango  | 11       |
| 4  | *NULL* | 5        |

Conversely, `NOT EXISTS (SELECT NULL)` is `FALSE` for every row and returns an empty result.

### Example 6: Accidental Outer References

SQL Server resolves an unqualified column name inside a subquery at the current scope first. If the name does not exist there, SQL Server can resolve it from an outer query scope.

In the following example, `@Table2` has no `Column_A`. The unqualified `Column_A` inside the subquery therefore refers to `@Table1.Column_A`. Because `@Table2` contains a row, the subquery returns the current outer value, the `IN` condition is true, and the update changes the value to 3.

```sql
DECLARE @Table1 table (Column_A int);
DECLARE @Table2 table (Column_B int);

INSERT INTO @Table1 (Column_A) VALUES (1);
INSERT INTO @Table2 (Column_B) VALUES (2);

UPDATE @Table1
SET Column_A = 3
WHERE Column_A IN
      (
          SELECT Column_A
          FROM @Table2
      );

SELECT Column_A
FROM @Table1;
```

| Column_A |
|---------:|
| 3        |

Qualify column references in subqueries. Writing `SELECT t2.Column_A FROM @Table2 AS t2` would correctly raise an invalid-column error instead of silently binding to the outer query.

## Anti-Joins

### Example 7: The `NOT IN` and `NULL` Trap

This query returns no rows because the subquery returns a `NULL` fruit. For Mango, for example, each comparison with Apple, Peach, and Kiwi is true after applying `<>`, but `Mango <> NULL` is `UNKNOWN`. The combined `NOT IN` condition is therefore `UNKNOWN`, and a `WHERE` clause retains only `TRUE`.

The cause is the nullable value returned by the inner query, not merely the presence of a `NULL` in the outer table.

```sql
SELECT a.ID,
       a.Fruit
FROM #TableA AS a
WHERE a.Fruit NOT IN
      (
          SELECT b.Fruit
          FROM #TableB AS b
      )
ORDER BY a.ID;
```

*Empty result set.*

Filtering `NULL` from the subquery makes `NOT IN` usable for known outer values:

```sql
SELECT a.ID,
       a.Fruit
FROM #TableA AS a
WHERE a.Fruit NOT IN
      (
          SELECT b.Fruit
          FROM #TableB AS b
          WHERE b.Fruit IS NOT NULL
      )
ORDER BY a.ID;
```

| ID | Fruit |
|---:|-------|
| 3  | Mango |

The outer `NULL` fruit is still excluded because `NULL NOT IN (...)` evaluates to `UNKNOWN`.

### Example 8: `NOT EXISTS`

`NOT EXISTS` retains a row from `TableA` when the correlated subquery finds no matching row in `TableB`. Mango qualifies because no Mango row exists in `TableB`. The null fruit also qualifies because ordinary equality does not match the two `NULL` fruit values.

```sql
SELECT a.ID,
       a.Fruit
FROM #TableA AS a
WHERE NOT EXISTS
      (
          SELECT 1
          FROM #TableB AS b
          WHERE b.Fruit = a.Fruit
      )
ORDER BY a.ID;
```

| ID | Fruit  |
|---:|--------|
| 3  | Mango  |
| 4  | *NULL* |

If two `NULL` fruit values should count as a match, the correlation predicate must request null-safe equality explicitly.

### Example 9: `LEFT JOIN ... IS NULL`

A left outer join can express the same anti-join by retaining only null-extended rows. Test a right-side column that is declared `NOT NULL`, such as `b.ID`. Testing a nullable right-side column could confuse a matched row containing a stored `NULL` with an unmatched row.

```sql
SELECT a.ID,
       a.Fruit
FROM #TableA AS a
LEFT OUTER JOIN #TableB AS b
    ON b.Fruit = a.Fruit
WHERE b.ID IS NULL
ORDER BY a.ID;
```

| ID | Fruit  |
|---:|--------|
| 3  | Mango  |
| 4  | *NULL* |

`NOT EXISTS` often states the non-existence requirement more directly, while the left-join form can be useful when extending an existing outer-join query. Inspect the execution plan rather than assuming that one form always performs better.

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
