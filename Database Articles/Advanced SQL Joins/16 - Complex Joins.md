# Complex Joins

In SQL, complex joins are not a specific, distinct command but a term used to describe queries that combine data from multiple tables using advanced techniques, multiple join conditions, or combinations of different join types. The "complexity" often stems from the logic required to accurately relate data across an intricate database schema. 

### Characteristics of Complex Joins    
*  Complex joins typically involve one or more of the following aspects:
*  Joining Multiple Tables: A query that joins three or more tables to gather all necessary information is generally considered complex.
*  Multiple `ON` Conditions: Using logical operators (`AND`, `OR`) within the `ON` clause to specify multiple criteria for matching rows.
*  Combining Join Types: Employing different join types (e.g., `INNER JOIN` and `LEFT JOIN`) within the same query to handle various data relationships.
*  Self Joins: Joining a table to itself to compare rows within the same table, often requiring the use of aliases.
*  Conditional Logic: Incorporating complex expressions like ranges, pattern matching, or `CASE` statements directly within the join conditions or the broader query.
*  Integration with Other Advanced Features: Complex joins frequently work in concert with other advanced SQL features like subqueries, Common Table Expressions (CTEs), window functions, or aggregate functions with `GROUP BY` to produce the desired results. 

---

### 1. **Multiple Conditions in the JOIN Clause**

Example:

```sql
SELECT *
FROM Orders o
JOIN Customers c
  ON o.CustomerID = c.CustomerID
 AND o.Region = c.Region;
```

---

### 2. **Joins Involving Inequality Operators**

These joins use conditions like `<`, `>`, `<=`, `>=`, or `<>`.
Example:

```sql
SELECT *
FROM   Employees e INNER JOIN
       Salaries s ON e.Salary > s.MinSalary;
```

---

### 3. **Joining More Than Two Tables**

Joining multiple tables together:

```sql
SELECT *
FROM   Orders o INNER JOIN
       Customers c ON o.CustomerID = c.CustomerID INNER JOIN
       Employees e ON o.EmployeeID = e.EmployeeID;
```

---

### 4. **Using Subqueries in JOINs**

Example:

```sql
SELECT *
FROM   Orders o
JOIN (
    SELECT CustomerID, MAX(OrderDate) AS LastOrder
    FROM   Orders
    GROUP BY CustomerID
) last_order
  ON o.CustomerID = last_order.CustomerID
 AND o.OrderDate = last_order.LastOrder;
```

---

### 5. **Self-Joins**

A table joined to itself:

```sql
SELECT e1.EmployeeID, e1.Name, e2.Name AS ManagerName
FROM   Employees e1 INNER JOIN
       Employees e2 ON e1.ManagerID = e2.EmployeeID;
```

These kinds of joins are often referred to as "complex" because they require deeper understanding of the data relationships and query logic.


---------------------------------------------------------

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


