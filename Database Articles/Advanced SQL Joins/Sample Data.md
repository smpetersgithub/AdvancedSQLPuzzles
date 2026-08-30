# Sample Data

The examples in this series use two small tables containing fruit names and quantities. The tables deliberately include `NULL` values so you can observe how different joins and predicates handle missing or unknown information.

In the result tables below, *NULL* represents the SQL `NULL` marker. It is not an empty string, a blank space, or zero.

## Table A

| ID | Fruit | Quantity |
| ---: | --- | ---: |
| 1 | Apple | 17 |
| 2 | Peach | 20 |
| 3 | Mango | 11 |
| 4 | *NULL* | 5 |

## Table B

| ID | Fruit | Quantity |
| ---: | --- | ---: |
| 1 | Apple | 17 |
| 2 | Peach | 25 |
| 3 | Kiwi | 20 |
| 4 | *NULL* | *NULL* |

## Create the Sample Tables

The following T-SQL script creates **local temporary tables** named `#TableA` and `#TableB`. Run the setup script and the examples that use these tables in the same SQL Server session.

```sql
DROP TABLE IF EXISTS #TableA;
DROP TABLE IF EXISTS #TableB;

CREATE TABLE #TableA
(
    ID       integer     NOT NULL PRIMARY KEY,
    Fruit    varchar(20) NULL,
    Quantity integer     NULL
);

CREATE TABLE #TableB
(
    ID       integer     NOT NULL PRIMARY KEY,
    Fruit    varchar(20) NULL,
    Quantity integer     NULL
);

INSERT INTO #TableA (ID, Fruit, Quantity)
VALUES
    (1, 'Apple', 17),
    (2, 'Peach', 20),
    (3, 'Mango', 11),
    (4, NULL,     5);

INSERT INTO #TableB (ID, Fruit, Quantity)
VALUES
    (1, 'Apple', 17),
    (2, 'Peach', 25),
    (3, 'Kiwi',  20),
    (4, NULL,    NULL);
```

Local temporary tables are preferable here because they are isolated to the current session. Global temporary tables, whose names begin with `##`, can be accessed by other sessions and may cause naming or data conflicts when several readers run the examples at the same time.

The `Fruit` columns are intentionally not constrained with `UNIQUE`. This makes it possible to add duplicate fruit names and explore one-to-many and many-to-many join results.

## Verify the Data

```sql
SELECT ID, Fruit, Quantity
FROM #TableA
ORDER BY ID;

SELECT ID, Fruit, Quantity
FROM #TableB
ORDER BY ID;
```

## Working with `NULL`

Keep these rules in mind while working through the examples:

- `NULL` represents missing or unknown information.
- Ordinary comparisons with `NULL`, including `NULL = NULL`, evaluate to `UNKNOWN` rather than `TRUE`.
- Use `IS NULL` and `IS NOT NULL` to test for `NULL`.
- An outer join also uses `NULL` to fill columns from a side that has no matching row.

These behaviors explain why rows containing `NULL` sometimes do not match and why a `NULL` in an outer-join result does not necessarily originate in the source data.

## Experimenting with the Data

You can add or modify rows to explore other outcomes. For example, adding duplicate fruit names demonstrates how a join can return multiple matches for a single row:

```sql
INSERT INTO #TableA (ID, Fruit, Quantity)
VALUES (5, 'Apple', 30);
```

Because `ID` is the primary key in each table, every added row must have a unique, non-`NULL` `ID`. Rerun the complete setup script whenever you want to restore the original data.

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

[https://advancedsqlpuzzles.com](https://advancedsqlpuzzles.com)
