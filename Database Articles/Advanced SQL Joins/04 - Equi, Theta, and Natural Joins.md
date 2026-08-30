# Equi, Theta, and Natural Joins

The terms **equi join**, **theta join**, and **natural join** describe the condition used to match rows or, in the case of a natural join, how that condition is generated.

These terms come from relational theory, but SQL is not a literal implementation of classical relational algebra. SQL permits duplicate rows, uses `NULL` and three-valued logic, and supports join predicates that are more general than the comparison predicates traditionally associated with theta joins.

## Terminology

| Term | Meaning |
| --- | --- |
| **Theta join** | In relational algebra, a join whose condition uses a comparison operator such as `=`, `<>`, `<`, `>`, `<=`, or `>=`. |
| **Equi join** | A theta join whose comparisons use only equality. |
| **Non-equi join** | An informal SQL term for a join that uses a condition other than, or in addition to, equality. |
| **Natural join** | A join that automatically compares every pair of same-named columns for equality and returns one copy of each shared column. |

In relational-algebra notation, a theta join can be expressed as a Cartesian product followed by a selection:

```text
R ⋈θ S = σθ(R × S)
```

SQL's `ON` clause is broader: it accepts a search condition that evaluates to `TRUE`, `FALSE`, or `UNKNOWN`. Consequently, conditions involving `BETWEEN`, `LIKE`, functions, and compound expressions are often discussed with non-equi joins even though they are not classical theta comparisons.

## Common T-SQL Comparison Predicates

| Predicate | Meaning | Notes |
| --- | --- | --- |
| `=` | Equal to | The defining comparison for an equi join. |
| `<>` | Not equal to | ISO SQL form. |
| `!=` | Not equal to | T-SQL alternative to `<>`. |
| `<`, `>` | Less than; greater than | Common in range and temporal joins. |
| `<=`, `>=` | Less than or equal to; greater than or equal to | Include the boundary value. |
| `!<`, `!>` | Not less than; not greater than | T-SQL alternatives; `>=` and `<=` are clearer. |
| `BETWEEN` | Within an inclusive range | Equivalent to a lower-bound and an upper-bound comparison. |
| `LIKE` | Matches a character pattern | A search predicate rather than a classical theta operator. |
| `IS DISTINCT FROM` | Values are different, treating `NULL` as a comparable value | Available in SQL Server 2022 (16.x) and later. Always returns `TRUE` or `FALSE`. |
| `IS NOT DISTINCT FROM` | Values are the same, treating two `NULL` values as equal | Available in SQL Server 2022 (16.x) and later. Always returns `TRUE` or `FALSE`. |

## Sample Data

The SQL Server examples use these local temporary tables:

```sql
DROP TABLE IF EXISTS #TableA;
DROP TABLE IF EXISTS #TableB;

CREATE TABLE #TableA
(
    ID       integer     NOT NULL,
    Fruit    varchar(20) NULL,
    Quantity integer     NULL
);

CREATE TABLE #TableB
(
    ID       integer     NOT NULL,
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

**Table A**

| ID | Fruit | Quantity |
| ---: | --- | ---: |
| 1 | Apple | 17 |
| 2 | Peach | 20 |
| 3 | Mango | 11 |
| 4 | *NULL* | 5 |

**Table B**

| ID | Fruit | Quantity |
| ---: | --- | ---: |
| 1 | Apple | 17 |
| 2 | Peach | 25 |
| 3 | Kiwi | 20 |
| 4 | *NULL* | *NULL* |

## Equi Joins

An equi join uses equality to match rows. `INNER JOIN ... ON` is the clearest way to express one in SQL Server:

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Fruit = b.Fruit
ORDER BY a.ID, b.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
| ---: | --- | ---: | --- |
| 1 | Apple | 1 | Apple |
| 2 | Peach | 2 | Peach |

The comparison `NULL = NULL` evaluates to `UNKNOWN`, not `TRUE`, so the rows with a `NULL` fruit do not match.

### Equivalent Cartesian-product Form

An inner equi join can also be written as a Cartesian product followed by a filter:

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
CROSS JOIN #TableB AS b
WHERE a.Fruit = b.Fruit
ORDER BY a.ID, b.ID;
```

For this query, the two forms return the same rows. Prefer the explicit `INNER JOIN` form because it keeps the relationship between the tables in the `ON` clause and leaves the `WHERE` clause for filtering the joined result.

### Null-safe Equality

SQL Server 2022 and later support `IS NOT DISTINCT FROM`, which treats two `NULL` values as equal for the comparison:

```sql
SELECT a.ID    AS A_ID,
       a.Fruit AS A_Fruit,
       b.ID    AS B_ID,
       b.Fruit AS B_Fruit
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Fruit IS NOT DISTINCT FROM b.Fruit
ORDER BY a.ID, b.ID;
```

| A_ID | A_Fruit | B_ID | B_Fruit |
| ---: | --- | ---: | --- |
| 1 | Apple | 1 | Apple |
| 2 | Peach | 2 | Peach |
| 4 | *NULL* | 4 | *NULL* |

On earlier SQL Server versions, the same matching rule can be written explicitly:

```sql
ON a.Fruit = b.Fruit
OR (a.Fruit IS NULL AND b.Fruit IS NULL)
```

## Non-equi Joins

A non-equi join uses a range, inequality, pattern, or another condition that is not solely equality. It is not a separate SQL keyword; the condition is written in the `ON` clause of an ordinary join.

### Greater-than Join

This query returns pairs for which the quantity in `TableA` is greater than the quantity in `TableB`:

```sql
SELECT a.ID       AS A_ID,
       a.Fruit    AS A_Fruit,
       a.Quantity AS A_Quantity,
       b.ID       AS B_ID,
       b.Fruit    AS B_Fruit,
       b.Quantity AS B_Quantity
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Quantity > b.Quantity
ORDER BY a.ID, b.ID;
```

| A_ID | A_Fruit | A_Quantity | B_ID | B_Fruit | B_Quantity |
| ---: | --- | ---: | ---: | --- | ---: |
| 2 | Peach | 20 | 1 | Apple | 17 |

An inequality can match one row to many rows. Always consider the possible result cardinality before joining large tables this way.

### Range and Pattern Join

Join conditions can combine multiple predicates. The following query requires `TableA.Quantity` to fall within an inclusive range and `TableA.Fruit` to contain `TableB.Fruit`:

```sql
SELECT a.ID       AS A_ID,
       a.Fruit    AS A_Fruit,
       a.Quantity AS A_Quantity,
       b.ID       AS B_ID,
       b.Fruit    AS B_Fruit,
       b.Quantity AS B_Quantity
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.Quantity BETWEEN b.Quantity AND b.Quantity + 10
   AND a.Fruit LIKE '%' + b.Fruit + '%'
ORDER BY a.ID, b.ID;
```

| A_ID | A_Fruit | A_Quantity | B_ID | B_Fruit | B_Quantity |
| ---: | --- | ---: | ---: | --- | ---: |
| 1 | Apple | 17 | 1 | Apple | 17 |

`BETWEEN` includes both endpoints. The `+` operator is T-SQL string-concatenation syntax; other database systems may use `CONCAT()` or `||` instead.

If either side of an ordinary comparison is `NULL`, the comparison normally evaluates to `UNKNOWN`, and that pair is not returned by an inner join.

## Natural Joins

A natural join builds its equality condition from **every column name shared by both inputs**. Each shared column appears once in the result. The join therefore depends on the tables' column names as well as their data.

SQL Server does not implement `NATURAL JOIN` or `JOIN ... USING`. These forms are supported by database systems such as PostgreSQL, MySQL, and Oracle.

The following examples assume that ordinary tables named `TableA` and `TableB` have been created in one of those systems. They do not use SQL Server's `#` temporary-table prefix.

```sql
SELECT *
FROM TableA
NATURAL JOIN TableB;
```

Because `ID`, `Fruit`, and `Quantity` occur in both sample tables, the natural join is equivalent to matching all three columns:

```text
TableA.ID       = TableB.ID
AND TableA.Fruit    = TableB.Fruit
AND TableA.Quantity = TableB.Quantity
```

The result contains only the row that agrees on every shared column:

| ID | Fruit | Quantity |
| ---: | --- | ---: |
| 1 | Apple | 17 |

The peach rows do not match because their quantities differ. The rows containing `NULL` also do not match because ordinary equality with `NULL` does not evaluate to `TRUE`.

### `USING`

`USING` explicitly lists the same-named columns to compare. In database systems that support it, this query returns the same result as the preceding natural join:

```sql
SELECT *
FROM TableA
INNER JOIN TableB USING (ID, Fruit, Quantity);
```

Unlike `NATURAL JOIN`, `USING` does not silently add a new comparison when another same-named column is later added to both tables.

### T-SQL Equivalent

In SQL Server, write the conditions explicitly and project one copy of the joined columns:

```sql
SELECT a.ID,
       a.Fruit,
       a.Quantity
FROM #TableA AS a
INNER JOIN #TableB AS b
    ON a.ID = b.ID
   AND a.Fruit = b.Fruit
   AND a.Quantity = b.Quantity;
```

Explicit conditions make the intended relationship visible and protect the query from unrelated schema changes. For that reason, `JOIN ... ON` is generally preferable to `NATURAL JOIN` in production code, even in systems that support both.

## Key Points

- An equi join matches rows with equality comparisons.
- A classical theta join allows equality or inequality comparisons.
- SQL's `ON` clause supports predicates beyond the classical theta operators.
- “Non-equi join” is an informal description, not a SQL join keyword.
- Ordinary comparisons do not match `NULL` values to one another.
- A natural join uses every same-named column, which makes it sensitive to schema changes.
- SQL Server requires explicit `ON` conditions because it does not support `NATURAL JOIN` or `JOIN ... USING`.

## References

- [Joins (SQL Server)](https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins)
- [`IS [NOT] DISTINCT FROM` (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/queries/is-distinct-from-transact-sql)
- [PostgreSQL: Table Expressions](https://www.postgresql.org/docs/current/queries-table-expressions.html)
- [MySQL: `JOIN` Clause](https://dev.mysql.com/doc/refman/8.4/en/join.html)
- [Oracle Database: Joins](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/sqlrf/Joins.html)

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
