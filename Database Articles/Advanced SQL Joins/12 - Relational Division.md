# Relational Division

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Relational division is a Relational Algebra operation that represents the division of one relation into another relation based on certain conditions. In SQL, relational division can be achieved by using multiple join operations and conditional statements to divide the data in one table into multiple groups based on certain criteria. This can be useful for solving problems such as finding all employees who have had a shift in every department or employees with the same licenses or skillsets.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Relational division is not a built-in operator in SQL, so it must be simulated using a combination of other SQL operations, such as joins, subqueries, and conditional statements. The exact implementation of relational division may vary depending on the specific requirements of the problem and the database management system being used.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here are some examples of problems that require the use of relational division.
*  I want to find all pilots who can fly 100% of the airplanes in the hangar (the most common example of relational division).
*  I want to find all employees who match on their issued licenses.  
*  I want to find all managers who have worked in every department.

Let’s look at a few examples.

--------------------------------------------------------------
#### Planes In The Hangar

The most common example on the internet is the Airplanes in the Hangar example.  Here, you need to find all pilots that can fly all planes located in the hangar.

**Pilot Skills**

| Pilot Name |   Plane Name   |
|------------|----------------|
| Johnson    | Piper Cub      |
| Williams   | B-52 Bomber    |
| Williams   | F-14 Fighter   |
| Williams   | Piper Cub      |
| Roberts    | B-52 Bomber    |
| Roberts    | F-14 Fighter   |
| Jones      | B-1 Bomber     |
| Jones      | B-52 Bomber    |
| Jones      | F-14 Fighter   |
| Brown      | B-1 Bomber     |
| Brown      | B-52 Bomber    |
| Brown      | F-14 Fighter   |
| Brown      | F-17 Fighter   |

**Hangar**
|  Plane Name  |
|--------------|
| B-1 Bomber   |
| B-52 Bomber  |
| F-14 Fighter |

Once you understand how to use the `HAVING` clause, the query is relatively simple.

```sql
CREATE TABLE #PilotSkills 
(
PilotName VARCHAR(255),
PlaneName VARCHAR(255)
);

INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Johnson', 'Piper Cub');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Williams', 'B-52 Bomber');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Williams', 'F-14 Fighter');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Williams', 'Piper Cub');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Roberts', 'B-52 Bomber');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Roberts', 'F-14 Fighter');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Jones', 'B-1 Bomber');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Jones', 'B-52 Bomber');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Jones', 'F-14 Fighter');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Brown', 'B-1 Bomber');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Brown', 'B-52 Bomber');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Brown', 'F-14 Fighter');
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Brown', 'F-17 Fighter');

CREATE TABLE #Hangar
(
PlaneName VARCHAR(255)
);

INSERT INTO #Hangar (PlaneName) VALUES ('B-1 Bomber');
INSERT INTO #Hangar (PlaneName) VALUES ('B-52 Bomber');
INSERT INTO #Hangar (PlaneName) VALUES ('F-14 Fighter');

SELECT  ps.PilotName
FROM    #PilotSkills ps,
        #Hangar h
WHERE   ps.PlaneName = h.PlaneName
GROUP BY ps.PilotName 
HAVING  COUNT(ps.PlaneName) = (SELECT COUNT(PlaneName) FROM #Hangar);
```

| Pilot Name |
|------------|
| Brown      |
| Jones      |

-------------------------------------------------------------------------
#### Employees With Matching Licenses.

Another example is finding all employees who have the same licenses.

| EmployeeID | License |
|------------|---------|
| 1001       | Class A |
| 1001       | Class B |
| 1001       | Class C |
| 2002       | Class A |
| 2002       | Class B |
| 2002       | Class C |
| 3003       | Class A |
| 3003       | Class D |
| 4004       | Class A |
| 4004       | Class B |
| 4004       | Class D |
| 5005       | Class A |
| 5005       | Class B |
| 5005       | Class D |

```sql
CREATE TABLE #Employees
(
EmployeeID  INTEGER,
License     VARCHAR(100),
PRIMARY KEY (EmployeeID, License)
);

INSERT INTO #Employees (EmployeeID, License) VALUES (1001,'Class A');
INSERT INTO #Employees (EmployeeID, License) VALUES (1001,'Class B');
INSERT INTO #Employees (EmployeeID, License) VALUES(1001,'Class C');
INSERT INTO #Employees (EmployeeID, License) VALUES (2002,'Class A');
INSERT INTO #Employees (EmployeeID, License) VALUES (2002,'Class B');
INSERT INTO #Employees (EmployeeID, License) VALUES(2002,'Class C');
INSERT INTO #Employees (EmployeeID, License) VALUES (3003,'Class A');
INSERT INTO #Employees (EmployeeID, License) VALUES(3003,'Class D');
INSERT INTO #Employees (EmployeeID, License) VALUES(4004,'Class A');
INSERT INTO #Employees (EmployeeID, License) VALUES(4004,'Class B');
INSERT INTO #Employees (EmployeeID, License) VALUES(4004,'Class D');
INSERT INTO #Employees (EmployeeID, License) VALUES(5005,'Class A');
INSERT INTO #Employees (EmployeeID, License) VALUES(5005,'Class B');
INSERT INTO #Employees (EmployeeID, License) VALUES(5005,'Class D');

WITH cte_Count AS
(
SELECT  EmployeeID,
        COUNT(*) AS LicenseCount
FROM    #Employees
GROUP BY EmployeeID
),
cte_CountWindow AS
(
SELECT  a.EmployeeID AS EmployeeID_A,
        b.EmployeeID AS EmployeeID_B,
        COUNT(*) OVER (PARTITION BY a.EmployeeID, b.EmployeeID) AS CountWindow
FROM    #Employees a CROSS JOIN
        #Employees b
WHERE   a.EmployeeID <> b.EmployeeID AND a.License = b.License
)
SELECT  DISTINCT
        a.EmployeeID_A,
        a.EmployeeID_B,
        a.CountWindow AS LicenseCount
FROM    cte_CountWindow a INNER JOIN
        cte_Count b ON a.CountWindow = b.LicenseCount AND a.EmployeeID_A = b.EmployeeID INNER JOIN
        cte_Count c ON a.CountWindow = c.LicenseCount AND a.EmployeeID_B = c.EmployeeID;
```


| EmployeeID_A | EmployeeID_B | LicenseCount |
|--------------|--------------|--------------|
| 1001         | 2002         | 3            |
| 2002         | 1001         | 3            |
| 4004         | 5005         | 3            |
| 5005         | 4004         | 3            |


-------------------------------------------------------------------------
#### All Departments

The last example shows all employees who have worked in all departments.

**Department History**
| Name  |  Department | IsActive |
|-------|-------------|----------|
| Chris | Wardrobe    | 0        |
| Chris | Lighting    | 1        |
| Chris | Music       | 0        |
| Nancy | Wardrobe    | 1        |
| Jim   | Music       | 1        |
| Jim   | Wardrobe    | 0        |

```sql
CREATE TABLE #DepartmentHistory
(
Name       VARCHAR(255),
Department VARCHAR(255),
IsActive   INTEGER
);

INSERT INTO #DepartmentHistory (Name, Department, IsActive) VALUES ('Chris', 'Wardrobe', 0);
INSERT INTO #DepartmentHistory (Name, Department, IsActive) VALUES ('Chris', 'Lighting', 1);
INSERT INTO #DepartmentHistory (Name, Department, IsActive) VALUES ('Chris', 'Music', 0);
INSERT INTO #DepartmentHistory (Name, Department, IsActive) VALUES ('Nancy', 'Wardrobe', 1);
INSERT INTO #DepartmentHistory (Name, Department, IsActive) VALUES ('Jim', 'Music', 1);
INSERT INTO #DepartmentHistory (Name, Department, IsActive) VALUES ('Jim', 'Wardrobe', 0);
GO

;WITH cte_DistinctEmployeeDepartment AS
(
SELECT  DISTINCT
        Name,
        Department
FROM    #DepartmentHistory
),
cte_EmployeeDepartmentCount AS
(
SELECT  Name,
        COUNT(Department) AS DepartmentCount
FROM    cte_DistinctEmployeeDepartment
GROUP BY Name
),
cte_DistinctDeparments AS
(
SELECT  COUNT(DISTINCT Department) AS DepartmentCount
FROM    #DepartmentHistory
)
SELECT  *
FROM    cte_EmployeeDepartmentCount
WHERE   DepartmentCount IN (SELECT DepartmentCount FROM cte_DistinctDepartments);
```

| Name  | DepartmentCount |
|-------|-----------------|
| Chris | 3               |

---------------------------------------------------------

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
