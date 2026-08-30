# Self-Joins

A self-join relates rows from a table to other rows in the same table. It is not a separate SQL keyword or join type. The query references the same table more than once, assigns each reference a different alias, and joins those logical instances with an ordinary `INNER`, `LEFT`, `CROSS`, or other join.

Self-joins are useful for:

- parent-and-child relationships stored in one table;
- pairs of rows that share an attribute;
- comparisons between earlier and later rows;
- running aggregates when window functions are unavailable; and
- comparisons between sets associated with different entities.

The aliases are essential because they identify the role played by each table reference. Descriptive aliases such as `employee` and `manager` are often clearer than aliases such as `a` and `b`.

## Example 1: Hierarchical Relationships

Consider an employee hierarchy in which `ManagerID` refers to another row's `EmployeeID`.

```sql
DROP TABLE IF EXISTS #Employees;

CREATE TABLE #Employees
(
    EmployeeID int         NOT NULL PRIMARY KEY,
    Title      varchar(30) NOT NULL,
    ManagerID  int         NULL
);

INSERT INTO #Employees (EmployeeID, Title, ManagerID)
VALUES (1, 'President',      NULL),
       (2, 'Vice President', 1),
       (3, 'Vice President', 1),
       (4, 'Director',       2),
       (5, 'Director',       3);
```

| EmployeeID | Title          | ManagerID |
|-----------:|----------------|----------:|
| 1          | President      | *NULL*    |
| 2          | Vice President | 1         |
| 3          | Vice President | 1         |
| 4          | Director       | 2         |
| 5          | Director       | 3         |

### Finding Each Employee's Manager

The first reference represents the employee, and the second represents that employee's manager. A `LEFT JOIN` preserves the president, whose `ManagerID` is `NULL`.

```sql
SELECT employee.EmployeeID,
       employee.Title,
       employee.ManagerID,
       manager.Title AS ManagerTitle
FROM #Employees AS employee
LEFT OUTER JOIN #Employees AS manager
    ON manager.EmployeeID = employee.ManagerID
ORDER BY employee.EmployeeID;
```

| EmployeeID | Title          | ManagerID | ManagerTitle  |
|-----------:|----------------|-----------|---------------|
| 1          | President      | *NULL*    | *NULL*        |
| 2          | Vice President | 1         | President     |
| 3          | Vice President | 1         | President     |
| 4          | Director       | 2         | Vice President |
| 5          | Director       | 3         | Vice President |

An inner self-join would omit the president because no manager row can satisfy `manager.EmployeeID = NULL`.

### Traversing an Arbitrary-Depth Hierarchy

A single self-join moves across one relationship: employee to immediate manager. A recursive common table expression is more appropriate when the query must traverse an arbitrary number of hierarchy levels.

The anchor member begins with root employees. The recursive member joins each previously discovered parent to its direct reports.

```sql
WITH EmployeeHierarchy AS
(
    SELECT employee.EmployeeID,
           employee.Title,
           employee.ManagerID,
           0 AS Depth
    FROM #Employees AS employee
    WHERE employee.ManagerID IS NULL

    UNION ALL

    SELECT child.EmployeeID,
           child.Title,
           child.ManagerID,
           parent.Depth + 1
    FROM EmployeeHierarchy AS parent
    INNER JOIN #Employees AS child
        ON child.ManagerID = parent.EmployeeID
)
SELECT hierarchy.EmployeeID,
       hierarchy.Title,
       hierarchy.ManagerID,
       manager.Title AS ManagerTitle,
       hierarchy.Depth
FROM EmployeeHierarchy AS hierarchy
LEFT OUTER JOIN #Employees AS manager
    ON manager.EmployeeID = hierarchy.ManagerID
ORDER BY hierarchy.EmployeeID
OPTION (MAXRECURSION 100);
```

| EmployeeID | Title          | ManagerID | ManagerTitle   | Depth |
|-----------:|----------------|-----------|----------------|------:|
| 1          | President      | *NULL*    | *NULL*         | 0     |
| 2          | Vice President | 1         | President      | 1     |
| 3          | Vice President | 1         | President      | 1     |
| 4          | Director       | 2         | Vice President | 2     |
| 5          | Director       | 3         | Vice President | 2     |

Production hierarchies should prevent or detect cycles. A cyclic manager relationship can cause recursive traversal to repeat until the recursion limit is reached.

## Example 2: Finding Pairs Within a Table

The following data contains two customers from Detroit.

```sql
DROP TABLE IF EXISTS #Customers;

CREATE TABLE #Customers
(
    ID   int         NOT NULL PRIMARY KEY,
    City varchar(30) NOT NULL
);

INSERT INTO #Customers (ID, City)
VALUES (1, 'Milwaukee'),
       (2, 'Detroit'),
       (3, 'Dallas'),
       (4, 'Detroit');
```

| ID | City      |
|---:|-----------|
| 1  | Milwaukee |
| 2  | Detroit   |
| 3  | Dallas    |
| 4  | Detroit   |

### Returning Each Pair Once

The self-join matches customers in the same city. The condition `customer_1.ID < customer_2.ID` prevents a customer from matching itself and keeps only one orientation of each pair.

```sql
SELECT customer_1.ID   AS Customer_1_ID,
       customer_1.City,
       customer_2.ID   AS Customer_2_ID
FROM #Customers AS customer_1
INNER JOIN #Customers AS customer_2
    ON customer_2.City = customer_1.City
   AND customer_1.ID < customer_2.ID
ORDER BY customer_1.ID, customer_2.ID;
```

| Customer_1_ID | City    | Customer_2_ID |
|--------------:|---------|--------------:|
| 2             | Detroit | 4             |

Using `customer_1.ID <> customer_2.ID` would return both `(2, 4)` and `(4, 2)`. If three or more customers shared a city, projecting only the first customer's columns could also return that customer multiple times.

### Returning Each Customer From a Repeated City

If the requirement is to return each qualifying customer once rather than return customer pairs, a self-referencing semi-join expresses that intent more directly:

```sql
SELECT customer.ID,
       customer.City
FROM #Customers AS customer
WHERE EXISTS
      (
          SELECT 1
          FROM #Customers AS other_customer
          WHERE other_customer.City = customer.City
            AND other_customer.ID <> customer.ID
      )
ORDER BY customer.ID;
```

| ID | City    |
|---:|---------|
| 2  | Detroit |
| 4  | Detroit |

This also fixes a problem in the original alternative query, which selected from a table named `Cities` even though the sample table was named `Customers`.

## Example 3: Running Totals

Before window functions were widely available, a non-equi self-join was a common way to calculate a running total.

```sql
DROP TABLE IF EXISTS #Animals;

CREATE TABLE #Animals
(
    ID     int         NOT NULL PRIMARY KEY,
    Animal varchar(30) NOT NULL,
    Weight int         NOT NULL
);

INSERT INTO #Animals (ID, Animal, Weight)
VALUES (1, 'Elephant',      13000),
       (2, 'Rhinoceros',     8000),
       (3, 'Hippopotamus',   3000),
       (4, 'Giraffe',        2000),
       (5, 'Water Buffalo',  2000);
```

The `current_row` instance joins to itself and every earlier row according to `ID`.

```sql
SELECT current_row.ID,
       current_row.Animal,
       SUM(prior_row.Weight) AS Cumulative_Weight
FROM #Animals AS current_row
INNER JOIN #Animals AS prior_row
    ON prior_row.ID <= current_row.ID
GROUP BY current_row.ID,
         current_row.Animal
ORDER BY current_row.ID;
```

| ID | Animal        | Cumulative_Weight |
|---:|---------------|------------------:|
| 1  | Elephant      | 13000             |
| 2  | Rhinoceros    | 21000             |
| 3  | Hippopotamus  | 24000             |
| 4  | Giraffe       | 26000             |
| 5  | Water Buffalo | 28000             |

The query assumes that `ID` defines the intended order. A window function is clearer and generally more efficient because it does not generate and aggregate all matching row pairs:

```sql
SELECT animal.ID,
       animal.Animal,
       SUM(animal.Weight) OVER
       (
           ORDER BY animal.ID
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS Cumulative_Weight
FROM #Animals AS animal
ORDER BY animal.ID;
```

The window query returns the same result.

## Example 4: Comparing Associated Sets

A self-join can help find entities associated with identical sets of values. The following table records employee licenses. Its composite primary key guarantees that an employee cannot have the same license more than once.

```sql
DROP TABLE IF EXISTS #EmployeeLicenses;

CREATE TABLE #EmployeeLicenses
(
    EmployeeID int         NOT NULL,
    License    varchar(20) NOT NULL,
    PRIMARY KEY (EmployeeID, License)
);

INSERT INTO #EmployeeLicenses (EmployeeID, License)
VALUES (1001, 'Class A'),
       (1001, 'Class B'),
       (1001, 'Class C'),
       (2002, 'Class A'),
       (2002, 'Class B'),
       (2002, 'Class C'),
       (3003, 'Class A'),
       (3003, 'Class D'),
       (4004, 'Class A'),
       (4004, 'Class B'),
       (4004, 'Class D'),
       (5005, 'Class A'),
       (5005, 'Class B'),
       (5005, 'Class D');
```

The self-join counts licenses shared by each pair of employees. The `HAVING` conditions require that the shared count equal each employee's total license count. Together, those tests establish set equality.

The condition `employee_1.EmployeeID < employee_2.EmployeeID` returns each matching pair once.

```sql
SELECT employee_1.EmployeeID AS EmployeeID_A,
       employee_2.EmployeeID AS EmployeeID_B,
       COUNT(*)               AS LicenseCount
FROM #EmployeeLicenses AS employee_1
INNER JOIN #EmployeeLicenses AS employee_2
    ON employee_2.License = employee_1.License
   AND employee_1.EmployeeID < employee_2.EmployeeID
GROUP BY employee_1.EmployeeID,
         employee_2.EmployeeID
HAVING COUNT(*) =
       (
           SELECT COUNT(*)
           FROM #EmployeeLicenses AS license_a
           WHERE license_a.EmployeeID = employee_1.EmployeeID
       )
   AND COUNT(*) =
       (
           SELECT COUNT(*)
           FROM #EmployeeLicenses AS license_b
           WHERE license_b.EmployeeID = employee_2.EmployeeID
       )
ORDER BY employee_1.EmployeeID,
         employee_2.EmployeeID;
```

| EmployeeID_A | EmployeeID_B | LicenseCount |
|-------------:|-------------:|-------------:|
| 1001         | 2002         | 3            |
| 4004         | 5005         | 3            |

This is a form of relational set comparison. A dedicated chapter covers relational division and alternative formulations in greater depth.

## Repeated References That Are Not Direct Self-Joins

Not every query that reads the same base table more than once uses a direct self-join.

Consider the following salary data:

```sql
DROP TABLE IF EXISTS #EmployeeSalaries;

CREATE TABLE #EmployeeSalaries
(
    EmployeeID int           NOT NULL PRIMARY KEY,
    Name       varchar(30)   NOT NULL,
    Salary     decimal(10,2) NOT NULL
);

INSERT INTO #EmployeeSalaries (EmployeeID, Name, Salary)
VALUES (1, 'Alice', 50000.00),
       (2, 'Bob',   70000.00),
       (3, 'Carol', 90000.00);
```

### Scalar Aggregate Subquery

The following query reads `#EmployeeSalaries` in both the outer query and a scalar subquery, but it does not join two row-producing aliases of the table. The subquery calculates one scalar value: the company average salary.

```sql
SELECT employee.Name,
       employee.Salary
FROM #EmployeeSalaries AS employee
WHERE employee.Salary >
      (
          SELECT AVG(all_employees.Salary)
          FROM #EmployeeSalaries AS all_employees
      );
```

| Name  | Salary   |
|-------|---------:|
| Carol | 90000.00 |

No `GROUP BY` or `HAVING` clause is required in the outer query because the comparison is a row-level filter.

### Joining to an Aggregate Relation

This version materializes the average as a one-row relation and cross joins that derived relation to the employees. It is a join, but it is not conventionally called a direct self-join: one input contains employee rows, while the other contains a different one-row aggregate relation.

```sql
WITH CompanyAverage AS
(
    SELECT AVG(employee.Salary) AS AverageSalary
    FROM #EmployeeSalaries AS employee
)
SELECT employee.Name,
       employee.Salary
FROM #EmployeeSalaries AS employee
CROSS JOIN CompanyAverage AS company
WHERE employee.Salary > company.AverageSalary;
```

| Name  | Salary   |
|-------|---------:|
| Carol | 90000.00 |

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
