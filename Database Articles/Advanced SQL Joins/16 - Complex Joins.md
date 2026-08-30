# Complex Joins

“Complex join” is an informal description, not a SQL command or logical join type. A query becomes complex when its relationships, cardinalities, or preservation rules require more reasoning than a straightforward key equality.

Complexity can arise from:

- joining several table sources;
- using compound predicates with `AND` or `OR`;
- combining inner and outer joins;
- using non-equality, range, or pattern predicates;
- joining a table to itself in different roles;
- joining to a derived table or common table expression;
- integrating aggregates or window functions; and
- handling optional relationships, duplicate matches, or tie conditions.

The number of tables alone does not make a query complex. A five-table chain of validated foreign keys can be easier to reason about than one two-table join containing ambiguous keys and many-to-many data.

## Sample Data

The examples use one small sales schema.

```sql
DROP TABLE IF EXISTS #Orders;
DROP TABLE IF EXISTS #SalaryBands;
DROP TABLE IF EXISTS #Employees;
DROP TABLE IF EXISTS #Customers;

CREATE TABLE #Customers
(
    CustomerID   int         NOT NULL PRIMARY KEY,
    CustomerName varchar(40) NOT NULL,
    Region       varchar(20) NOT NULL
);

CREATE TABLE #Employees
(
    EmployeeID   int           NOT NULL PRIMARY KEY,
    EmployeeName varchar(40)   NOT NULL,
    ManagerID    int           NULL,
    Salary       decimal(10,2) NOT NULL
);

CREATE TABLE #SalaryBands
(
    BandName           varchar(20)   NOT NULL PRIMARY KEY,
    MinSalary          decimal(10,2) NOT NULL,
    MaxSalaryExclusive decimal(10,2) NOT NULL
);

CREATE TABLE #Orders
(
    OrderID    int           NOT NULL PRIMARY KEY,
    CustomerID int           NOT NULL,
    EmployeeID int           NOT NULL,
    Region     varchar(20)   NOT NULL,
    OrderDate  date          NOT NULL,
    Amount     decimal(10,2) NOT NULL
);

INSERT INTO #Customers (CustomerID, CustomerName, Region)
VALUES (1, 'Acme',     'North'),
       (2, 'Bluebird', 'South'),
       (3, 'Cedar',    'North'),
       (4, 'Delta',    'West');

INSERT INTO #Employees (EmployeeID, EmployeeName, ManagerID, Salary)
VALUES (10, 'Alice', NULL, 120000.00),
       (11, 'Bob',   10,    80000.00),
       (12, 'Carol', 10,    70000.00),
       (13, 'Diego', 11,    60000.00);

INSERT INTO #SalaryBands (BandName, MinSalary, MaxSalaryExclusive)
VALUES ('Entry',     0.00,  75000.00),
       ('Senior', 75000.00, 100000.00),
       ('Executive', 100000.00, 1000000.00);

INSERT INTO #Orders
    (OrderID, CustomerID, EmployeeID, Region, OrderDate, Amount)
VALUES (1001, 1, 11, 'North', '2026-01-10', 500.00),
       (1002, 1, 12, 'North', '2026-02-15', 650.00),
       (1003, 2, 11, 'South', '2026-01-20', 400.00),
       (1004, 3, 12, 'South', '2026-02-05', 300.00),
       (1005, 3, 13, 'North', '2026-03-05', 450.00),
       (1006, 1, 11, 'North', '2026-02-15', 700.00);
```

Order 1004 deliberately contains a region that does not match its customer. Acme has two orders on the same latest date, and Delta has no orders. Those conditions expose behaviors that simplified sample data often hides.

## 1. Multiple Conditions in `ON`

A compound join predicate can require both a key match and an additional business rule. The following query accepts an order only when its customer and region both agree with the customer record.

```sql
SELECT orders.OrderID,
       customer.CustomerName,
       orders.Region,
       orders.Amount
FROM #Orders AS orders
INNER JOIN #Customers AS customer
    ON customer.CustomerID = orders.CustomerID
   AND customer.Region = orders.Region
ORDER BY orders.OrderID;
```

| OrderID | CustomerName | Region | Amount |
|--------:|--------------|--------|-------:|
| 1001    | Acme         | North  | 500.00 |
| 1002    | Acme         | North  | 650.00 |
| 1003    | Bluebird     | South  | 400.00 |
| 1005    | Cedar        | North  | 450.00 |
| 1006    | Acme         | North  | 700.00 |

Order 1004 is excluded because its customer matches but its region does not.

Every predicate in `ON` should represent an intended matching rule. If `Region` is merely an output filter rather than part of row correspondence, placing it in the join condition can conceal a data-quality issue instead of expressing the relationship accurately.

## 2. A Non-Equi Range Join

Range joins are useful for classifications such as tax brackets, effective-dated records, and salary bands.

The original one-sided condition `employee.Salary > band.MinSalary` can match an employee to several bands. A complete half-open interval defines one intended match:

```sql
SELECT employee.EmployeeID,
       employee.EmployeeName,
       employee.Salary,
       band.BandName
FROM #Employees AS employee
INNER JOIN #SalaryBands AS band
    ON employee.Salary >= band.MinSalary
   AND employee.Salary <  band.MaxSalaryExclusive
ORDER BY employee.EmployeeID;
```

| EmployeeID | EmployeeName | Salary    | BandName  |
|-----------:|--------------|----------:|-----------|
| 10         | Alice        | 120000.00 | Executive |
| 11         | Bob          | 80000.00  | Senior    |
| 12         | Carol        | 70000.00  | Entry     |
| 13         | Diego        | 60000.00  | Entry     |

The query assumes that salary bands do not overlap and cover every expected salary. Those are data-integrity requirements; the join itself does not enforce them.

Using an inclusive lower bound and exclusive upper bound prevents a boundary salary from matching two adjacent bands.

## 3. Joining Several Tables

This query joins orders to validated customer records and then to the employee responsible for each order. Explicit projection avoids the duplicate and ambiguous column names produced by `SELECT *`.

```sql
SELECT orders.OrderID,
       customer.CustomerName,
       employee.EmployeeName AS SalesRepresentative,
       orders.OrderDate,
       orders.Amount
FROM #Orders AS orders
INNER JOIN #Customers AS customer
    ON customer.CustomerID = orders.CustomerID
   AND customer.Region = orders.Region
INNER JOIN #Employees AS employee
    ON employee.EmployeeID = orders.EmployeeID
ORDER BY orders.OrderID;
```

| OrderID | CustomerName | SalesRepresentative | OrderDate  | Amount |
|--------:|--------------|---------------------|------------|-------:|
| 1001    | Acme         | Bob                 | 2026-01-10 | 500.00 |
| 1002    | Acme         | Carol               | 2026-02-15 | 650.00 |
| 1003    | Bluebird     | Bob                 | 2026-01-20 | 400.00 |
| 1005    | Cedar        | Diego               | 2026-03-05 | 450.00 |
| 1006    | Acme         | Bob                 | 2026-02-15 | 700.00 |

Before writing a multi-table join, identify the expected grain of the result. This query expects one row per valid order because both joined lookup keys are unique. Joining to a one-to-many source would change that grain and could multiply order rows.

## 4. Joining to an Aggregate Derived Table

A derived table can calculate the latest order date for each customer, after which the outer query joins back to `#Orders` to retrieve the corresponding order details.

```sql
SELECT customer.CustomerName,
       orders.OrderID,
       orders.OrderDate,
       orders.Amount
FROM #Customers AS customer
LEFT OUTER JOIN
     (
         SELECT CustomerID,
                MAX(OrderDate) AS LastOrderDate
         FROM #Orders
         GROUP BY CustomerID
     ) AS latest
    ON latest.CustomerID = customer.CustomerID
LEFT OUTER JOIN #Orders AS orders
    ON orders.CustomerID = latest.CustomerID
   AND orders.OrderDate = latest.LastOrderDate
ORDER BY customer.CustomerID, orders.OrderID;
```

| CustomerName | OrderID | OrderDate  | Amount |
|--------------|---------|------------|--------|
| Acme         | 1002    | 2026-02-15 | 650.00 |
| Acme         | 1006    | 2026-02-15 | 700.00 |
| Bluebird     | 1003    | 2026-01-20 | 400.00 |
| Cedar        | 1005    | 2026-03-05 | 450.00 |
| Delta        | *NULL*  | *NULL*     | *NULL* |

Acme appears twice because two orders share its latest date. The query is correct if all latest-date ties should be returned. It is incomplete if the requirement is exactly one row per customer.

### Selecting One Deterministic Latest Row

`ROW_NUMBER` can encode an explicit tie-breaker. This version chooses the highest `OrderID` when several orders share the latest date.

```sql
WITH RankedOrders AS
(
    SELECT orders.OrderID,
           orders.CustomerID,
           orders.OrderDate,
           orders.Amount,
           ROW_NUMBER() OVER
           (
               PARTITION BY orders.CustomerID
               ORDER BY orders.OrderDate DESC,
                        orders.OrderID DESC
           ) AS RowNumber
    FROM #Orders AS orders
)
SELECT customer.CustomerName,
       orders.OrderID,
       orders.OrderDate,
       orders.Amount
FROM #Customers AS customer
LEFT OUTER JOIN RankedOrders AS orders
    ON orders.CustomerID = customer.CustomerID
   AND orders.RowNumber = 1
ORDER BY customer.CustomerID;
```

| CustomerName | OrderID | OrderDate  | Amount |
|--------------|---------|------------|--------|
| Acme         | 1006    | 2026-02-15 | 700.00 |
| Bluebird     | 1003    | 2026-01-20 | 400.00 |
| Cedar        | 1005    | 2026-03-05 | 450.00 |
| Delta        | *NULL*  | *NULL*     | *NULL* |

The tie-breaker is a business rule, not merely a technical detail. Choose a column whose meaning supports the selection.

## 5. A Self-Join

The employee and manager are different roles played by rows from the same table. A left self-join preserves Alice, the top-level employee with no manager.

```sql
SELECT employee.EmployeeID,
       employee.EmployeeName,
       employee.ManagerID,
       manager.EmployeeName AS ManagerName
FROM #Employees AS employee
LEFT OUTER JOIN #Employees AS manager
    ON manager.EmployeeID = employee.ManagerID
ORDER BY employee.EmployeeID;
```

| EmployeeID | EmployeeName | ManagerID | ManagerName |
|-----------:|--------------|-----------|-------------|
| 10         | Alice        | *NULL*    | *NULL*      |
| 11         | Bob          | 10        | Alice       |
| 12         | Carol        | 10        | Alice       |
| 13         | Diego        | 11        | Bob         |

An inner self-join would omit Alice because no manager row can match a null `ManagerID`.

## 6. Combining Techniques

The following query combines:

- a compound inner join that validates the customer and region;
- an inner join to the responsible employee;
- a left self-join to the employee's optional manager; and
- a range join to classify the employee's salary.

```sql
SELECT orders.OrderID,
       customer.CustomerName,
       employee.EmployeeName AS SalesRepresentative,
       manager.EmployeeName  AS ManagerName,
       band.BandName,
       orders.Amount
FROM #Orders AS orders
INNER JOIN #Customers AS customer
    ON customer.CustomerID = orders.CustomerID
   AND customer.Region = orders.Region
INNER JOIN #Employees AS employee
    ON employee.EmployeeID = orders.EmployeeID
LEFT OUTER JOIN #Employees AS manager
    ON manager.EmployeeID = employee.ManagerID
INNER JOIN #SalaryBands AS band
    ON employee.Salary >= band.MinSalary
   AND employee.Salary <  band.MaxSalaryExclusive
ORDER BY orders.OrderID;
```

| OrderID | CustomerName | SalesRepresentative | ManagerName | BandName | Amount |
|--------:|--------------|---------------------|-------------|----------|-------:|
| 1001    | Acme         | Bob                 | Alice       | Senior   | 500.00 |
| 1002    | Acme         | Carol               | Alice       | Entry    | 650.00 |
| 1003    | Bluebird     | Bob                 | Alice       | Senior   | 400.00 |
| 1005    | Cedar        | Diego               | Bob         | Entry    | 450.00 |
| 1006    | Acme         | Bob                 | Alice       | Senior   | 700.00 |

Although the syntax is longer, each table has one defined role and each predicate has one explainable purpose.

## Common Failure Modes

### Unexpected Row Multiplication

Know the cardinality of every relationship. If one left row matches three right rows, the join produces three result rows before later grouping or filtering. Do not add `DISTINCT` until the reason for duplication is understood.

### Incorrect Outer-Join Filtering

A null-rejecting predicate on the optional side in `WHERE` can remove null-extended rows and make an outer join behave like an inner join. Place a condition in `ON` when it should restrict matches while preserving the outer row.

### Ambiguous or Incomplete Range Rules

Range tables can contain gaps or overlaps. Prefer clearly defined half-open intervals and enforce the business rules that keep those intervals valid.

### Implicit Conversions

Join columns with incompatible data types can force conversions, harm cardinality estimates, or prevent efficient index access. Related keys should normally use compatible types, lengths, and collations.

### Hidden Tie Behavior

Aggregating to `MAX`, `MIN`, or another value and joining back can return multiple rows when ties exist. Decide whether all ties or one deterministic row is required.

### Unclear Predicate Placement

Separate matching rules from result filters conceptually. For inner joins, moving a single-table condition between `ON` and `WHERE` may preserve the result, but outer joins can change meaning.

## A Review Method for Complex Joins

Before finalizing a complex query:

1. State the intended result grain, such as one row per order or one row per customer.
2. Assign every table reference a clear role.
3. Identify each relationship's cardinality and uniqueness guarantees.
4. Decide which side of every outer join must be preserved.
5. Classify every predicate as a matching rule or a result filter.
6. Define behavior for `NULL`, duplicate keys, missing relationships, and ties.
7. Add joins incrementally and compare row counts at each step.
8. Replace `SELECT *` with an explicit projection.
9. Inspect the actual execution plan for estimation errors, repeated work, sorts, and spills.
10. Test data that exercises exceptional cases, not only clean one-to-one matches.

Common table expressions and derived tables can make stages easier to name and review, but they do not automatically materialize results or improve performance. Use them to clarify logic, then evaluate the execution plan produced for the complete statement.

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
