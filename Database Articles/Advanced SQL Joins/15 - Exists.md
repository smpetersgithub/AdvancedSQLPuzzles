# `EXISTS`

`EXISTS` is a predicate that tests whether a subquery returns at least one row. It evaluates to `TRUE` when a row exists and `FALSE` when the subquery is empty.

The values projected by the subquery do not become part of the outer result. For existence testing, these forms have the same meaning when the remainder of the subquery is unchanged:

```sql
EXISTS (SELECT 1    ...)
EXISTS (SELECT NULL ...)
EXISTS (SELECT 1/0  ...)
EXISTS (SELECT *    ...)
```

`SELECT 1` is a common convention because it communicates that the projected value is irrelevant.

`EXISTS` can be used anywhere Transact-SQL accepts an appropriate Boolean search condition, including `IF`, `WHERE`, `HAVING`, and a join's `ON` condition. Prefixing it with `NOT` reverses the existence test.

## Correlated and Uncorrelated Subqueries

An **uncorrelated** subquery does not reference the outer query. Its existence result is therefore constant for every outer row during that statement.

A **correlated** subquery references columns from an outer query scope. Conceptually, its matching rows can differ for each outer row. SQL Server's optimizer is free to transform the expression into an efficient plan; the conceptual model does not dictate a literal row-by-row execution strategy.

`EXISTS` does not provide special `NULL` equality. Its `TRUE` or `FALSE` result depends only on whether rows survive the predicates inside the subquery. If an inner predicate uses `a.Fruit = b.Fruit`, two `NULL` values do not match because ordinary equality evaluates to `UNKNOWN`.

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

## `IF EXISTS`

`IF EXISTS` is useful when procedural Transact-SQL needs to branch according to whether a query returns a row.

```sql
IF EXISTS (SELECT 1 FROM #TableA)
    PRINT 'TableA contains at least one row.';
ELSE
    PRINT 'TableA is empty.';
```

Because `#TableA` contains rows, the first message is printed.

Negation tests for an empty result:

```sql
IF NOT EXISTS (SELECT 1 FROM #TableA)
    PRINT 'TableA is empty.';
ELSE
    PRINT 'TableA contains at least one row.';
```

The following expression is also true:

```sql
IF EXISTS (SELECT NULL)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

`SELECT NULL` without a `FROM` clause returns one row containing a null value. `EXISTS` tests for that row, not for a non-null projected value. By contrast, `NOT EXISTS (SELECT NULL)` is false.

## `EXISTS` in a `WHERE` Clause

### Left Semi-Join

The correlated subquery retains a row from `TableA` when at least one row in `TableB` has the same non-null fruit value. Right-side columns are not returned, and multiple matching right-side rows would not multiply a qualifying left-side row.

```sql
SELECT a.ID,
       a.Fruit,
       a.Quantity
FROM #TableA AS a
WHERE EXISTS
      (
          SELECT 1
          FROM #TableB AS b
          WHERE b.Fruit = a.Fruit
      )
ORDER BY a.ID;
```

| ID | Fruit | Quantity |
|---:|-------|---------:|
| 1  | Apple | 17       |
| 2  | Peach | 20       |

### Left Anti-Join With `NOT EXISTS`

Negating the predicate retains a row from `TableA` when no matching row exists in `TableB`.

```sql
SELECT a.ID,
       a.Fruit,
       a.Quantity
FROM #TableA AS a
WHERE NOT EXISTS
      (
          SELECT 1
          FROM #TableB AS b
          WHERE b.Fruit = a.Fruit
      )
ORDER BY a.ID;
```

| ID | Fruit  | Quantity |
|---:|--------|---------:|
| 3  | Mango  | 11       |
| 4  | *NULL* | 5        |

The null fruit qualifies because `b.Fruit = a.Fruit` is never `TRUE` when `a.Fruit` is `NULL`, even though `TableB` also contains a null fruit.

## `EXISTS` in an `ON` Condition

There is no separate SQL construct formally called an `ON EXISTS` clause. `ON` accepts a search condition, and an `EXISTS` predicate can be part or all of that condition.

This applies to `INNER`, `LEFT`, `RIGHT`, and `FULL` joins. `CROSS JOIN` has no `ON` clause; filter a Cartesian product in `WHERE` when that behavior is required.

### An Uncorrelated Condition

The following `EXISTS` subquery always returns `TRUE` because `SELECT NULL` produces one row. Every row from `TableA` therefore matches every row from `TableB`, producing the same 16 pairs as a `CROSS JOIN`.

```sql
SELECT COUNT(*) AS PairCount
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON EXISTS (SELECT NULL);
```

| PairCount |
|----------:|
| 16        |

No columns from `a` or `b` appear inside the subquery, so the condition does not compare the two inputs.

### A Correlated Condition Equivalent to Equality

An `EXISTS` predicate can reference both join inputs:

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON EXISTS
       (
           SELECT 1
           WHERE a.Fruit = b.Fruit
       )
ORDER BY a.ID, b.ID;
```

This returns Apple and Peach, just like `ON a.Fruit = b.Fruit`. The extra subquery adds no value here, so the direct equality predicate is clearer.

## Null-Safe Scalar Comparison With Set Operators

An advanced Transact-SQL idiom combines `EXISTS` with single-row `INTERSECT` or `EXCEPT` expressions. Each `SELECT` below has no `FROM` clause and produces exactly one scalar row. Set operators consider two `NULL` values equal when determining distinct rows.

For scalar expressions `A` and `B`, the following identities hold:

| Expression | Meaning |
|------------|---------|
| `EXISTS (SELECT A INTERSECT SELECT B)` | `A` is not distinct from `B` |
| `NOT EXISTS (SELECT A EXCEPT SELECT B)` | `A` is not distinct from `B` |
| `EXISTS (SELECT A EXCEPT SELECT B)` | `A` is distinct from `B` |
| `NOT EXISTS (SELECT A INTERSECT SELECT B)` | `A` is distinct from `B` |

These identities rely on each side producing one scalar row. They should not be generalized carelessly to arbitrary multirow set expressions.

### Null-Safe Equality

The `INTERSECT` subquery returns a row when the two fruit values are equal or when both are `NULL`. `EXISTS` converts that row-or-empty result into the join condition.

```sql
SELECT a.ID       AS A_ID,
       a.Fruit    AS A_Fruit,
       a.Quantity AS A_Quantity,
       b.ID       AS B_ID,
       b.Fruit    AS B_Fruit,
       b.Quantity AS B_Quantity
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON EXISTS
       (
           SELECT a.Fruit
           INTERSECT
           SELECT b.Fruit
       )
ORDER BY a.ID, b.ID;
```

| A_ID | A_Fruit | A_Quantity | B_ID | B_Fruit | B_Quantity |
|-----:|---------|-----------:|-----:|---------|------------|
| 1    | Apple   | 17         | 1    | Apple   | 17         |
| 2    | Peach   | 20         | 2    | Peach   | 25         |
| 4    | *NULL*  | 5          | 4    | *NULL*  | *NULL*     |

On SQL Server 2022 or later, the clearest equivalent is:

```sql
ON a.Fruit IS NOT DISTINCT FROM b.Fruit
```

On earlier versions, use explicit logic:

```sql
ON a.Fruit = b.Fruit
OR (a.Fruit IS NULL AND b.Fruit IS NULL)
```

Replacing `NULL` with `ISNULL(a.Fruit, '')` is not generally equivalent: a stored empty string would also match a `NULL`, and applying functions to indexed join columns can make index access less efficient.

### Null-Safe Inequality

`EXISTS (SELECT a.Fruit EXCEPT SELECT b.Fruit)` returns `TRUE` when the two scalar rows are distinct, including when exactly one fruit value is `NULL`.

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
           EXCEPT
           SELECT b.Fruit
       )
ORDER BY a.ID, b.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
|-----:|---------|-----:|---------|
| 1    | Apple   | 2    | Peach   |
| 1    | Apple   | 3    | Kiwi    |
| 1    | Apple   | 4    | *NULL*  |
| 2    | Peach   | 1    | Apple   |
| 2    | Peach   | 3    | Kiwi    |
| 2    | Peach   | 4    | *NULL*  |
| 3    | Mango   | 1    | Apple   |
| 3    | Mango   | 2    | Peach   |
| 3    | Mango   | 3    | Kiwi    |
| 3    | Mango   | 4    | *NULL*  |
| 4    | *NULL*  | 1    | Apple   |
| 4    | *NULL*  | 2    | Peach   |
| 4    | *NULL*  | 3    | Kiwi    |

On SQL Server 2022 or later, write the condition directly:

```sql
ON a.Fruit IS DISTINCT FROM b.Fruit
```

On earlier versions, an explicit equivalent is:

```sql
ON a.Fruit <> b.Fruit
OR (a.Fruit IS NULL AND b.Fruit IS NOT NULL)
OR (a.Fruit IS NOT NULL AND b.Fruit IS NULL)
```

## Choosing a Form

Use the simplest predicate that communicates the requirement:

- Use correlated `EXISTS` when only the existence of a qualifying row matters.
- Use `NOT EXISTS` for non-existence, particularly when nullable values make `NOT IN` unsafe.
- Use `IS [NOT] DISTINCT FROM` for null-safe scalar comparison on SQL Server 2022 or later.
- Use explicit equality-and-`NULL` logic on earlier versions when portability and clarity matter.
- Reserve the `INTERSECT` and `EXCEPT` scalar idioms for cases where their behavior is understood and justified.

Do not assume that `EXISTS` is always faster than `IN` or a join. SQL Server can transform logically equivalent forms into similar plans. Compare actual execution plans and runtime measurements for the real data and indexes.

## Official References

- [`EXISTS` in Transact-SQL](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/exists-transact-sql)
- [`EXCEPT` and `INTERSECT` in Transact-SQL](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-except-and-intersect-transact-sql)
- [`IS [NOT] DISTINCT FROM` in Transact-SQL](https://learn.microsoft.com/en-us/sql/t-sql/queries/is-distinct-from-transact-sql)

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
