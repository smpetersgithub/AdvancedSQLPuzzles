### Self Joins

----

The most common example used to demonstrate a self-join is the Manager and Employee hierarchical relationship.  In this relationship, the table contains both a foreign key (Manager ID), which relates to its primary key (Employee ID).

Here is an example of such a hierarchy.

| Employee ID |      Title     | Manager ID |
|-------------|----------------|------------|
|           1 | President      | <NULL>     |
|           2 | Vice President | 1          |
|           3 | Vice President | 1          |
|           4 | Director       | 2          |
|           5 | Director       | 3          |
  
We can use the following self-join to determine each employee's manager.

```sql
SELECT  a.EmployeeID,
        a.Title ,
        a.ManagerID,
        b.Title
FROM    #Employees a INNER JOIN
        #Employees b ON a.ManagerID = b.EmployeeID;
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
        #Employees b on a.EmployeeID = b.ManagerID
)
SELECT  a.EmployeeID,
        a.Title,
        a.ManagerID,
        b.Title AS ManagerTitle,
        a.Depth
FROM    cte_Recursion a LEFT JOIN
        #Employees b ON a.ManagerID = b.EmployeeID
ORDER BY 1;
```
  

| Employee ID |     Title      | Manager ID | Manager Title  | Depth |
|-------------|----------------|------------|----------------|-------|
|           1 | President      |  <NULL>    | <NULL>         |     0 |
|           2 | Vice President | 1          | President      |     1 |
|           3 | Vice President | 1          | President      |     1 |
|           4 | Director       | 2          | Vice President |     2 |
|           5 | Director       | 3          | Vice President |     2 |

----
  
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
FROM    #Customer a INNER JOIN
        #Customer b ON a.City = b.City AND a.ID <> b.ID;
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
FROM    #Customer
GROUP BY City
HAVING  COUNT(City) > 1
)
SELECT  a.*
FROM    cte_CountCity a INNER JOIN
        #Customer b on a.ID = b.ID;  
```
  
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
FROM    #Animals a CROSS JOIN
        #Animals b
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

----
  
Up next....
  
  
  
  ---
  
  

  
  
  
  
----
  
  
