# SQL Query Processing Order

To better understand how an SQL statement is evaluated, it helps to separate **how a query is written** from **how it is logically processed**. Although SQL queries are typically written starting with the `SELECT` clause, the SQL engine does **not** execute them in that order. Instead, each clause is evaluated according to well-defined logical processing phases.

The diagram below illustrates this logical processing order.

![SQL Processing Order](/Database%20Articles/Advanced%20SQL%20Joins/images/SQLQueryProcessingOrderPage.png)

At a high level, SQL begins by identifying the data sources in the `FROM` clause, applies row-level filtering, performs grouping and aggregation, and only then determines which columns to return and how the final result set should be presented. 

This distinction between *logical processing order* and *written syntax order* is essential for understanding joins, aggregations, and query behavior.

---

## Logical Processing Order of a SQL Statement

The logical order in which a SQL query is processed is shown below.

| Order | Clause     | Description |
|-------|------------|-------------|
| 1     | `FROM`     | Identifies the input table sources. |
| 2     | `ON`       | Evaluates join predicates. |
| 3     | `JOIN`     | Produces matching rows and adds preserved rows for outer joins. |
| 4     | `WHERE`    | Filters individual rows. |
| 5     | `GROUP BY` | Organizes rows into groups. |
| 6     | `WITH CUBE` or `WITH ROLLUP` | Produces additional aggregate groups when requested. |
| 7     | `HAVING`   | Filters groups. |
| 8     | `SELECT`   | Evaluates the expressions and columns to return. |
| 9     | `DISTINCT` | Removes duplicate result rows. |
| 10    | `ORDER BY` | Orders the result. |
| 11    | `TOP`      | Limits the rows returned. |

---

## Parsing and Optimization

The SQL Server Database Engine (and other relational database engines) parses the entire query as a single unit and validates its syntax and semantics. It then produces **one execution plan for the entire query**, not separate plans for each clause.

This execution plan represents a low-cost strategy selected by the optimizer from the alternatives it considered. The optimizer uses a cost-based search but does not guarantee that it finds the objectively best possible plan.

It includes such factors such as:

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

| Operator | Conceptual subphases |
|----------|----------------------|
| `JOIN` | Form row combinations, apply the `ON` predicate, and add preserved rows when required by an outer join. |
| `APPLY` | Evaluate the right table expression for each left row, combine the results, and preserve unmatched left rows for `OUTER APPLY`. |
| `PIVOT` | Group, spread values into columns, and aggregate. |
| `UNPIVOT` | Generate row copies, extract column names and values, and remove rows whose extracted values are NULL. |

---

## Understanding Joins as Restricted Cartesian Products

In relational terms, an inner join can be understood as a Cartesian product followed by a predicate that retains only matching row combinations.

An outer join adds another step by preserving unmatched rows from one or both inputs and supplying NULL markers for columns from the missing side.

A `CROSS JOIN` returns the Cartesian product directly, without an `ON` predicate.

- There is only one fundamental join operation: the Cartesian product.
- `INNER` and `OUTER` joins are **restricted Cartesian products**, where the `ON` predicate limits the rows returned.
- The `APPLY` operator is used to evaluate correlated table expressions, including table-valued functions.
- `PIVOT` and `UNPIVOT` reshape data by rotating rows into columns and columns into rows.


The following queries are logically equivalent. The optimizer may produce the same execution plan for both, although that is not guaranteed.

```sql
-- Statement 1: INNER JOIN
SELECT *
FROM dbo.Customers emp INNER JOIN
     dbo.Orders ord ON emp.CustomerID = ord.CustomerID;

-- Statement 2: CROSS JOIN with filter
SELECT  *
FROM dbo.Customers emp CROSS JOIN
     dbo.Orders ord
WHERE emp.CustomerID = ord.CustomerID;
```

---

## Comparing INNER, OUTER, and CROSS Joins

The primary difference is how each join handles matching and unmatched rows. Inner joins use the join condition as a filtering criterion, while outer joins use it as a matching criterion and preserve unmatched rows from one or both tables.

- An `INNER JOIN` returns only row combinations that satisfy its `ON` predicate.
- A `LEFT OUTER JOIN` or `RIGHT OUTER JOIN` returns matching rows and preserves unmatched rows from one input.
- A `FULL OUTER JOIN` preserves unmatched rows from both inputs.
- A `CROSS JOIN` returns every possible row combination and does not use an `ON` predicate.

---

## Join Conditions and Relational Algebra

Both `INNER` and `OUTER` joins rely on comparison operators to relate rows across tables. These comparisons are formally described as:

- **Theta-join** – uses comparison operators such as `=`, `<>`, `>`, `<`, `>=`, or `<=`.
- **Equi-join** – uses equality comparisons.
- **Non-equi-join** – uses comparisons or range predicates other than equality, such as `<`, `>`, `<>`, or `BETWEEN`.

Note the following distinctions.
  
- Every **equi-join** and **non-equi-join** is a **theta-join**.
- **Equi-joins**, **theta-joins** and **non-equi-join** are classifications, not SQL Server keywords.

These classifications originate from **Relational Algebra**, introduced by **Edgar F. Codd** in 1970. Relational Algebra provides the mathematical foundation for SQL by defining operations over relations using precise and well-defined semantics.

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

### Continue Reading

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

https://advancedsqlpuzzles.com
