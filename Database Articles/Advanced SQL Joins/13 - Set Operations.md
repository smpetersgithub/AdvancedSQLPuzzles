# Set Operations

Set operators combine the rows returned by two or more query expressions into one result. In SQL Server, the available forms are:

- `UNION`: returns the distinct rows found in either input;
- `UNION ALL`: concatenates both inputs and preserves duplicate rows;
- `INTERSECT`: returns the distinct rows found in both inputs; and
- `EXCEPT`: returns the distinct rows found in the left input but not in the right input.

A join normally combines columns from related row sources horizontally. A set operation combines compatible query results vertically. The inputs can be queries against different tables, the same table, views, derived tables, or other query expressions.

SQL Server does not provide `INTERSECT ALL` or `EXCEPT ALL`. Both `INTERSECT` and `EXCEPT` return distinct rows. It also has no single symmetric-difference operator, but symmetric difference can be composed from two `EXCEPT` operations.

## Compatibility Rules

Each input query must satisfy the following rules:

1. It must return the same number of columns.
2. Corresponding columns must appear in the same logical order.
3. Corresponding data types must be compatible. When types differ, SQL Server applies its data-type precedence and conversion rules.

The column names in the final result come from the first query. The source column names do not need to match.

Set operators compare complete projected rows. If a query projects `(ID, Fruit)`, differences in an unselected `Quantity` column have no effect. Adding `Quantity` changes the definition of row equality for that operation.

## Duplicates and `NULL`

`UNION`, `INTERSECT`, and `EXCEPT` determine distinctness across every projected column. For that distinctness comparison, SQL Server considers two `NULL` values equal.

This does not mean that the ordinary predicate `NULL = NULL` evaluates to `TRUE`. Predicate comparisons use three-valued logic and return `UNKNOWN`; set operators use distinct-row semantics.

`UNION ALL` does not perform duplicate elimination, so it preserves every input row, including every occurrence containing `NULL`.

## Ordering and Precedence

Set-operation results have no guaranteed order unless the complete expression ends with an `ORDER BY` clause. That final clause uses the output column names established by the first query.

When different set operators appear in one expression, SQL Server evaluates them in this order:

1. parenthesized expressions;
2. `INTERSECT`; and
3. `UNION` and `EXCEPT` from left to right.

Use parentheses, common table expressions, or derived tables when the intended grouping is not immediately obvious.

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

## `UNION`

`UNION` combines both inputs and removes duplicate projected rows. The `(4, NULL)` row occurs in both inputs but appears only once in the result.

```sql
SELECT ID,
       Fruit
FROM #TableA

UNION

SELECT ID,
       Fruit
FROM #TableB
ORDER BY ID, Fruit;
```

| ID | Fruit  |
|---:|--------|
| 1  | Apple  |
| 2  | Peach  |
| 3  | Kiwi   |
| 3  | Mango  |
| 4  | *NULL* |

Only `ID` and `Fruit` participate in duplicate elimination. The different Peach quantities are not visible to this operation.

## `UNION ALL`

`UNION ALL` concatenates the two inputs without removing duplicates. Both copies of Apple, Peach, and `(4, NULL)` remain.

```sql
SELECT ID,
       Fruit
FROM #TableA

UNION ALL

SELECT ID,
       Fruit
FROM #TableB
ORDER BY ID, Fruit;
```

| ID | Fruit  |
|---:|--------|
| 1  | Apple  |
| 1  | Apple  |
| 2  | Peach  |
| 2  | Peach  |
| 3  | Kiwi   |
| 3  | Mango  |
| 4  | *NULL* |
| 4  | *NULL* |

When duplicate elimination is not required, `UNION ALL` usually communicates the intent more accurately and avoids the work needed to identify distinct rows.

## `INTERSECT`

`INTERSECT` returns the distinct projected rows found in both inputs.

```sql
SELECT ID,
       Fruit
FROM #TableA

INTERSECT

SELECT ID,
       Fruit
FROM #TableB
ORDER BY ID, Fruit;
```

| ID | Fruit  |
|---:|--------|
| 1  | Apple  |
| 2  | Peach  |
| 4  | *NULL* |

Peach appears because `(2, 'Peach')` exists in both projected results. The quantities 20 and 25 are irrelevant because `Quantity` is not selected. The two `(4, NULL)` rows are considered the same for set distinctness.

## `EXCEPT`

`EXCEPT` is directional. It returns distinct rows from the left input that are absent from the right input.

```sql
SELECT ID,
       Fruit
FROM #TableA

EXCEPT

SELECT ID,
       Fruit
FROM #TableB
ORDER BY ID, Fruit;
```

| ID | Fruit |
|---:|-------|
| 3  | Mango |

Reversing the inputs asks the opposite question:

```sql
SELECT ID,
       Fruit
FROM #TableB

EXCEPT

SELECT ID,
       Fruit
FROM #TableA
ORDER BY ID, Fruit;
```

| ID | Fruit |
|---:|-------|
| 3  | Kiwi  |

`MINUS` is not Transact-SQL syntax. Other database products may use different names for a similar operation, so check the target platform's documentation.

## Symmetric Difference

The symmetric difference contains rows found in exactly one of the two inputs. SQL Server has no single symmetric-difference operator, but the result can be built as:

```text
(A EXCEPT B) UNION ALL (B EXCEPT A)
```

The two `EXCEPT` results are disjoint and already distinct, so `UNION ALL` can concatenate them without another duplicate-elimination step.

```sql
WITH A_Only AS
(
    SELECT ID, Fruit
    FROM #TableA

    EXCEPT

    SELECT ID, Fruit
    FROM #TableB
),
B_Only AS
(
    SELECT ID, Fruit
    FROM #TableB

    EXCEPT

    SELECT ID, Fruit
    FROM #TableA
)
SELECT ID,
       Fruit,
       'Only in TableA' AS Row_Source
FROM A_Only

UNION ALL

SELECT ID,
       Fruit,
       'Only in TableB' AS Row_Source
FROM B_Only
ORDER BY ID, Fruit, Row_Source;
```

| ID | Fruit | Row_Source     |
|---:|-------|----------------|
| 3  | Kiwi  | Only in TableB |
| 3  | Mango | Only in TableA |

The `(4, NULL)` row does not appear because it exists in both projected sets. This differs from a full outer join on `a.Fruit = b.Fruit`, where the two null fruit values would not match under ordinary predicate semantics.

## Projection Determines Row Equality

When `Quantity` is added to the projection, more rows differ. Apple remains common, but Peach has different quantities, and the two rows with `ID = 4` have different quantities.

```sql
WITH A_Only AS
(
    SELECT ID, Fruit, Quantity
    FROM #TableA

    EXCEPT

    SELECT ID, Fruit, Quantity
    FROM #TableB
),
B_Only AS
(
    SELECT ID, Fruit, Quantity
    FROM #TableB

    EXCEPT

    SELECT ID, Fruit, Quantity
    FROM #TableA
)
SELECT ID,
       Fruit,
       Quantity,
       'Only in TableA' AS Row_Source
FROM A_Only

UNION ALL

SELECT ID,
       Fruit,
       Quantity,
       'Only in TableB' AS Row_Source
FROM B_Only
ORDER BY ID, Fruit, Quantity, Row_Source;
```

| ID | Fruit  | Quantity | Row_Source     |
|---:|--------|----------|----------------|
| 2  | Peach  | 20       | Only in TableA |
| 2  | Peach  | 25       | Only in TableB |
| 3  | Kiwi   | 20       | Only in TableB |
| 3  | Mango  | 11       | Only in TableA |
| 4  | *NULL* | *NULL*   | Only in TableB |
| 4  | *NULL* | 5        | Only in TableA |

An absolute complement cannot be defined without specifying a universal set. SQL queries can express a relative complement with `EXCEPT`, but the relevant universe must come from an identified table or query when an absolute-style business requirement is intended.

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
