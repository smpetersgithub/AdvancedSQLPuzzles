# SQL Query Processing Order

To better understand how an SQL statement is evaluated, it helps to separate **how a query is written** from **how it is logically processed**. Although SQL queries are typically written starting with the `SELECT` clause, the SQL engine does **not** execute them in that order. Instead, each clause is evaluated according to well-defined logical processing phases.

The diagram below illustrates this logical processing order.

![SQL Processing Order](/Database%20Articles/Advanced%20SQL%20Joins/images/SQLQueryProcessingOrderPage.png)

At a high level, SQL begins by identifying the data sources in the `FROM` clause, applies row-level filtering, performs grouping and aggregation, and only then determines which columns to return and how the final result set should be presented. This distinction between *logical processing* and *written syntax* is essential for understanding joins, aggregations, and query behavior.

---

## Logical Processing Order of a SQL Statement

The logical order in which a SQL query is processed is shown below.

| Order | Syntax   | Description |
|------:|----------|-------------|
| 1     | FROM     | Identifies the source tables, views, table variables, or derived tables |
| 2     | WHERE    | Filters rows based on a search condition |
| 3     | GROUP BY | Groups rows for aggregation |
| 4     | HAVING   | Filters groups created by `GROUP BY` |
| 5     | SELECT   | Determines which expressions and columns are returned |
| 6     | DISTINCT | Removes duplicate rows from the result set |
| 7     | ORDER BY | Sorts the final result set |
| 8     | LIMIT    | Restricts the number of rows returned |

> **Note:** SQL dialects vary slightly. For example, SQL Server uses `TOP` or `OFFSET / FETCH` instead of `LIMIT`, but the logical processing concept remains the same.

---

## Parsing and Optimization

The SQL Server Database Engine (and other relational database engines) parses the entire query as a single unit and validates its syntax and semantics. It then produces **one execution plan for the entire query**, not separate plans for each clause.

This execution plan represents the most efficient strategy the optimizer can determine for accessing and processing the data, based on factors such as:

- Available indexes  
- Table and column statistics  
- Estimated row counts  
- Available system resources  

---

## Table Operators in the FROM Clause

Once query processing begins in the `FROM` clause, SQL applies a set of **logical table operators** that transform or combine rowsets. In T-SQL, the primary table operators are:

- `JOIN`
- `APPLY`
- `PIVOT`
- `UNPIVOT`

Each operator follows a defined series of internal subphases.

### Operator Subphases

| Operator | Subphases |
|----------|-----------|
| JOIN     | 1) Cartesian Product  2) ON Predicate  3) Add Outer Rows |
| APPLY    | 1) Apply Table Expression  2) Add Outer Rows |
| PIVOT    | 1) Group  2) Spread  3) Aggregate |
| UNPIVOT  | 1) Generate Copies  2) Extract Element  3) Remove |

---

## Understanding Joins as Restricted Cartesian Products

All joins ultimately begin as a **Cartesian product**. The difference between join types lies in how that product is restricted or preserved.

- There is only one fundamental join operation: the Cartesian product.
- `INNER` and `OUTER` joins are **restricted Cartesian products**, where the `ON` predicate limits the rows returned.
- The `APPLY` operator is used to evaluate correlated table expressions, including table-valued functions.
- `PIVOT` and `UNPIVOT` reshape data by rotating rows into columns and columns into rows.

The following two queries produce the **same result set**, demonstrating how an `INNER JOIN` is logically equivalent to a filtered `CROSS JOIN`.

```sql
-- Statement 1: INNER JOIN
SELECT  *
FROM    Customers emp
INNER JOIN Orders ord
    ON emp.CustomerID = ord.CustomerID;

-- Statement 2: CROSS JOIN with filter
SELECT  *
FROM    Customers emp
CROSS JOIN Orders ord
WHERE   emp.CustomerID = ord.CustomerID;

### Key observations

- Removing the join condition from an `INNER JOIN` results in a syntax error.
- Removing the filter from a `CROSS JOIN` produces a full Cartesian product.
- Both queries use an equi-join condition (`=`) on `CustomerID`.
- A `CROSS JOIN` combined with a filtering predicate behaves the same as an `INNER JOIN`.

---

## Comparing INNER, OUTER, and CROSS Joins

The most important distinction between join types is how unmatched rows are handled:

- **INNER JOIN** acts as a filtering criterion
- **OUTER JOIN** acts as a matching criterion
- **CROSS JOIN** returns all possible combinations

More simply stated:

- `INNER JOIN` returns only matching rows
- `OUTER JOIN` returns matching rows plus unmatched rows from one or both tables
- `CROSS JOIN` returns the Cartesian product

---

## Join Conditions and Relational Algebra

Both `INNER` and `OUTER` joins rely on comparison operators to relate rows across tables. These comparisons are formally described as:

- **Equi-joins** – joins using equality (`=`)
- **Theta-joins** – joins using any binary comparison operator

These concepts originate from **Relational Algebra**, introduced by **Edgar F. Codd** in 1970. Relational Algebra provides the mathematical foundation for SQL by defining operations over relations using precise and well-defined semantics.

---

## Declarative vs. Physical Execution

SQL is a **declarative language**: you specify *what* result you want, not *how* to compute it. The logical processing order is defined by SQL semantics, but the **physical execution plan** chosen by the optimizer may differ.

When a table operation is executed, the database engine selects the most efficient join algorithm—such as nested loops, hash joins, or merge joins—based on:

- Table size
- Data distribution
- Index availability
- Statistics and cost estimates

Understanding the logical processing order helps explain *why* queries behave the way they do, even when the physical execution strategy varies.

---

## Continue Reading

1. Introduction  
2. SQL Processing Order  
3. Table Types  
4. Equi, Theta, and Natural Joins  
5. Inner Joins  
6. Outer Joins  
7. Full Outer Joins  
8. Cross Joins  
9. Semi and Anti Joins  
10. Any, All, and Some  
11. Self Joins  
12. Relational Division  
13. Set Operations  
14. Join Algorithms  
15. Exists  
16. Complex Joins  

https://advancedsqlpuzzles.com