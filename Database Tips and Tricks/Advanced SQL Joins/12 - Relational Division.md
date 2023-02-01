# Relational Division

Relational division is a relational algebra operation that represents the division of one relation into another relation based on certain conditions. In SQL, relational division can be achieved by using multiple join operations and conditional statements to divide the data in one table into multiple groups based on certain criteria. This can be useful for solving problems such as finding all employees who have had a shift in every department, or employees that have the same licenses or skillsets.

Relational division is not a built-in operator in SQL, so it must be simulated using a combination of other SQL operations, such as joins, subqueries, and conditional statements. The exact implementation of relational division may vary depending on the specific requirements of the problem and the database management system being used.

The simpliest way to define relational division is by stating you are looking for a percentage or fraction.  Relational division is used in SQL to select rows that conform to a number of different criteria.
*  I want to find all pilots who can fly 100% of the airplanes in the hanger (the most common exmaple of relational division).
*  I want to find all employees who match on at least two-thirds of their issued licenses.  
*  I want to find all managers who have worked in every department.

Lets look at a couple of examples.

--------------------------------------------------------------

The most common example you will find on the internet is the airplanes in the hanger example.

**Pilot Skills**

| Pilot Name |   Plane Name    |
|------------|-----------------|
| Johnson    |  Piper Cub      |
| Williams   |  B-52 Bomber    |
| Williams   |  F-14 Fighter   |
| Williams   |  Piper Cub      |
| Roberts    |  B-52 Bomber    |
| Roberts    |  F-14 Fighter   |
| Jones      |  B-1 Bomber     |
| Jones      |  B-52 Bomber    |
| Jones      |  F-14 Fighter   |
| Brown      |  B-1 Bomber     |
| Brown      |  B-52 Bomber    |
| Brown      |  F-14 Fighter   |
| Brown      |  F-17 Fighter   |


**Hanger**
|  Plane Name  |
|--------------|
| B-1 Bomber   |
| B-52 Bomber  |
| F-14 Fighter |


The query is rather simple once you understand how to use the HAVING clause.

```sql

CREATE TABLE #PilotSkills 
(
PilotName varchar(255),
PlaneName varchar(255)
);

INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Johnson', 'Piper Cub'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Williams', 'B-52 Bomber'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Williams', 'F-14 Fighter'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Williams', 'Piper Cub'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Roberts', 'B-52 Bomber'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Roberts', 'F-14 Fighter'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Jones', 'B-1 Bomber'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Jones', 'B-52 Bomber'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Jones', 'F-14 Fighter'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Brown', 'B-1 Bomber'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Brown', 'B-52 Bomber'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Brown', 'F-14 Fighter'),
INSERT INTO #PilotSkills (PilotName, PlaneName) VALUES ('Brown', 'F-17 Fighter');

CREATE TABLE #Hanger 
(
PlaneName varchar(255)
);

INSERT INTO #Hanger (PlaneName) VALUES ('B-1 Bomber');
INSERT INTO #Hanger (PlaneName) VALUES ('B-52 Bomber');
INSERT INTO #Hanger (PlaneName) VALUES ('F-14 Fighter');

SELECT  ps.PilotName
FROM    #PilotSkills AS ps, 
        #Hangar AS h
WHERE   ps.PlaneName = h.PlaneName
GROUP BY ps.PilotName 
HAVING  COUNT(ps.PlaneName) = (SELECT COUNT(PlaneName) FROM Hangar);
```

-------------------------------------------------------------------------

Another example is find all employees who have the same licenses.


```sql
CREATE TABLE #Employees
(
EmployeeID  INTEGER,
License     VARCHAR(100),
PRIMARY KEY (EmployeeID, License)
);

INSERT INTO #Employees (EmployeeID, License) VALUES (1001,'Class A');
INSERT INTO #Employees (EmployeeID, License) VALUES (1001,'Class B'),
INSERT INTO #Employees (EmployeeID, License) VALUES(1001,'Class C');
INSERT INTO #Employees (EmployeeID, License) VALUES (2002,'Class A');
INSERT INTO #Employees (EmployeeID, License) VALUES (2002,'Class B'),
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


-------------------------------------------------------------------------

The last example shows all employees who have worked in all departments.

**Department History**
| Name  |  Department |  IsActive |
|-------|-------------|-----------|
| Chris |  Wardrobe   |         0 |
| Chris |  Lighting   |         1 |
| Chris |  Music      |         0 |
| Nancy |  Wardrobe   |         1 |
| Jim   |  Music      |         1 |
| Jim   |  Wardrobe   |         0 |



