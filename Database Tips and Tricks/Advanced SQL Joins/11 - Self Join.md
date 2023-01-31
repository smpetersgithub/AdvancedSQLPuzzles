# Self Joins

Self joins in SQL are a type of join operation where a table is joined with itself. In a self join, a table is aliased to give it a different name and then used twice in the same query, once as the left table and once as the right table. The join conditions in a self join specify how to relate the rows of a table to itself. Self joins can be used to compare rows within a table, to create subsets of data based on certain conditions, or to combine information from multiple rows within a single table. The result of a self join is a new table that contains the combined data from the two instances of the original table. Self joins can be useful when working with hierarchical data, or when you need to analyze data based on relationships within a table.

----------------------------------------------------

#### Example 1:  Hierarchial Relationships

Here is an example using a self join on a hierarchy table.

For the following table of Managers and Employees, determine each employee's manager.

| Employee ID |      Title     | Manager ID |
|-------------|----------------|------------|
|           1 | President      | <NULL>     |
|           2 | Vice President | 1          |
|           3 | Vice President | 1          |
|           4 | Director       | 2          |
|           5 | Director       | 3          |
  

Note the table Employees is referenced twice, but given two different aliases name, a and b.
 
```sql
SELECT  a.EmployeeID,
        a.Title ,
        a.ManagerID,
        b.Title
FROM    Employees a INNER JOIN
        Employees b ON a.ManagerID = b.EmployeeID;
```

| EmployeeID  |      Title     |  Manager ID |      Title     |
|-------------|----------------|-------------|----------------|
|           2 | Vice President |           1 | President      |
|           3 | Vice President |           1 | President      |
|           4 | Director       |           2 | Vice President |
|           5 | Director       |           3 | Vice President |

It is worth mentioning that because the Managers and Emnployees table is a heirarchial relationshipt, the problem lends itself to using a self-referencing common table expression (CTE) to determine the level of depth each employee has from the highest tier.

In the below example, the common table expression cte_Recursion references itself in the UNION ALL statement.

```sql
WITH cte_Recursion AS
(
SELECT  EmployeeID, 
        Title,
        ManagerID,
        0 AS Depth
FROM    #Employees
WHERE   ManagerID IS NULL
UNION ALL
SELECT  b.EmployeeID,
        b.Title,
        b.ManagerID,
        a.Depth + 1 AS Depth
FROM    cte_Recursion a INNER JOIN
        Employees b on a.EmployeeID = b.ManagerID
)
SELECT  a.EmployeeID,
        a.Title,
        a.ManagerID,
        b.Title AS ManagerTitle,
        a.Depth
FROM    cte_Recursion a LEFT JOIN
        Employees b ON a.ManagerID = b.EmployeeID
ORDER BY 1;
```
  

| Employee ID |     Title      | Manager ID | Manager Title  | Depth |
|-------------|----------------|------------|----------------|-------|
|           1 | President      |  <NULL>    | <NULL>         |     0 |
|           2 | Vice President | 1          | President      |     1 |
|           3 | Vice President | 1          | President      |     1 |
|           4 | Director       | 2          | Vice President |     2 |
|           5 | Director       | 3          | Vice President |     2 |

----------------------------------------------------

#### Example 2: Finding Pairs

Here is another example problem that can be solved with a self-join.  Unlike the above problem, this table does not have a foreign key that references its primary key.

List all cities that have more than one customer along with the customer details.

| ID |   City    |
|----|-----------|
| 1  | Milwaukee |
| 2  | Detroit   |
| 3  | Dallas    |
| 4  | Detroit   |

  
The syntax to solve this puzzle with a self-join is shown below.
  
```sql
SELECT  a.ID,
        a.City
FROM    Customer a INNER JOIN
        Customer b ON a.City = b.City AND a.ID <> b.ID;
```
  
The above query uses a self-join and returns the following result set.
  
| ID |  City   |
|----|---------|
|  2 | Detroit |
|  4 | Detroit |

Because the Customer table does not have a foreign key relationship, the above query could (and most probably should) be written using the following syntax.  This statement is slightly more verbose, but the intent of the statement becomes a bit more obvious.

```sql
WITH cte_CountCity AS
(
SELECT  ID,
        City
FROM    Customer
GROUP BY City
HAVING  COUNT(City) > 1
)
SELECT  a.*
FROM    cte_CountCity a INNER JOIN
        Customer b on a.ID = b.ID;  
```

 ----------------------------------------------------
  
#### Example 3: Windowing

  
Often, if you need to use a self-join there are options you can use (such as window functions) to avoid the use of a self-join.  Let’s look at an example.

Given the below dataset consisting of the weight of various animals, create a cumulative total column summing the current row plus all previous rows.

| ID  |    Animal     | Weight |
|-----|---------------|--------|
| 1   | Elephant      |  13000 |
| 2   | Rhinoceros    |   8000 |
| 3   | Hippopotamus  |   3000 |
| 4   | Giraffe       |   2000 |
| 5   | Water Buffalo |   2000 |

```sql
SELECT  a.ID
        a.Animal,
        SUM(b.Weight) AS Cummulative_Weight
FROM    Animals a CROSS JOIN
        Animals b
WHERE   a.ID >= b.ID
GROUP BY a.ID, a.Animal; 
```  
  

| ID |    Animal     | Cummulative Weight |
|----|---------------|--------------------|
|  1 | Elephant      |              13000 |
|  4 | Giraffe       |              26000 |
|  3 | Hippopotamus  |              24000 |
|  2 | Rhinoceros    |              21000 |
|  5 | Water Buffalo |              28000 |

However, a better way to write this statement is by using a windowing function.
  
```sql
SELECT  ID,
        Animal,
        SUM(Weight) OVER (ORDER BY ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cummulative_Weight
FROM    #Animals;  
```

----------------------------------------------------

#### Example 4: Relational Division
  
Self joins are also used in relational division.

Given the following table of Employees and their licenses, determine all employees who have matching licenses.

| EmployeeID | License |
|------------|---------|
|       1001 | Class A |
|       1001 | Class B |
|       1001 | Class C |
|       2002 | Class A |
|       2002 | Class B |
|       2002 | Class C |
|       3003 | Class A |
|       3003 | Class D |
|       4004 | Class A |
|       4004 | Class B |
|       4004 | Class D |
|       5005 | Class A |
|       5005 | Class B |
|       5005 | Class D |

Here is the expected output; employees 1001 and 2002 have matching licenses, and employees 4004 and 5005 have matching licenses.
  
| EmployeeID_A | EmployeeID_B | LicenseCount |
|--------------|--------------|--------------|
|         1001 |         2002 |            3 |
|         2002 |         1001 |            3 |
|         4004 |         5005 |            3 |
|         5005 |         4004 |            3 |

The SQL to generate the expected output uses a self join.
  
```sql
WITH cte_Count AS
(
SELECT  EmployeeID,
        COUNT(*) AS LicenseCount
FROM    Employees
GROUP BY EmployeeID
),
cte_CountWindow AS
(
SELECT  a.EmployeeID AS EmployeeID_A,
        b.EmployeeID AS EmployeeID_B,
        COUNT(*) OVER (PARTITION BY a.EmployeeID, b.EmployeeID) AS CountWindow
FROM    Employees a CROSS JOIN
        Employees b
WHERE   a.EmployeeID <> b.EmployeeID and a.License = b.License
)
SELECT  DISTINCT
        a.EmployeeID_A,
        a.EmployeeID_B,
        a.CountWindow AS LicenseCount
FROM    cte_CountWindow a INNER JOIN
        cte_Count b ON a.CountWindow = b.LicenseCount AND a.EmployeeID_A = b.EmployeeID INNER JOIN
        cte_Count c ON a.CountWindow = c.LicenseCount AND a.EmployeeID_B = c.EmployeeID;
```
----------------------------------------------------
  
#### Example of what is not a self join.
  
The following are **not** considered self-joins.

Given a table of employees and their salary, write an SQL statment to return all employees who have a higher salary than the average salary of the company.
  
Although this SQL statement uses the Employees table twice, it does not join to itself.  In this example, the aggregation on the Employees table is used in the predicate logic and not joined to the Employees table.
  
```sql
SELECT  Name,
        Salary
FROM    Employees
GROUP BY Name, Salary
HAVING Salary > (SELECT AVG(Salary) FROM Employees);
```
  
The following is also not a self=join.  The cte_Average does reference the Employees table, but it creates an entirely new relation consisting of {Name, Average}, which does not equal the original Employees table of {Name, Salary}.
  
```sql
WITH cte_Average AS
(
SELECT AVG(Salary) AS Average FROM Employees
)
SELECT  *
FROM    Employees a CROSS JOIN
        cte_Average b
WHERE   Salary > Average;
```
  
---------------------------------------
  
Happy coding!

  