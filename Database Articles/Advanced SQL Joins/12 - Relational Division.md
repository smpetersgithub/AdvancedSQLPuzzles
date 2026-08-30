# Relational Division

Relational division answers a universal-quantification question:

> Which entities are related to every member of a required set?

Given a relation `R(Entity, Item)` and a required set `S(Item)`, division returns each `Entity` for which every item in `S` has a corresponding row in `R`.

Typical questions include:

- Which pilots can fly every plane in the hangar?
- Which employees have worked in every required department?
- Which suppliers provide every required part?

Transact-SQL does not provide a division operator. Common formulations use:

- nested `NOT EXISTS` predicates;
- `EXCEPT` inside `NOT EXISTS`; or
- grouped counts with `HAVING`.

These formulations are not automatically interchangeable in every edge case. Duplicates, `NULL`, an empty required set, and whether extra related values are allowed all affect the correct query.

## Division With and Without a Remainder

Two related requirements are often called relational division:

- **Division with a remainder:** the entity must have every required item but may also have additional items.
- **Exact division:** the entity's item set must equal the required set, with no missing or additional items.

In the pilot example, a pilot who can fly all planes in the hangar may still know how to fly other planes. That is division with a remainder. Comparing two employees for identical license sets requires exact set equality.

## Example 1: Pilots Who Can Fly Every Plane in the Hangar

The `#PilotSkills` table is the dividend relation. The `#Hangar` table supplies the divisor, or required set.

```sql
DROP TABLE IF EXISTS #PilotSkills;
DROP TABLE IF EXISTS #Hangar;

CREATE TABLE #PilotSkills
(
    PilotName varchar(50) NOT NULL,
    PlaneName varchar(50) NOT NULL,
    PRIMARY KEY (PilotName, PlaneName)
);

CREATE TABLE #Hangar
(
    PlaneName varchar(50) NOT NULL PRIMARY KEY
);

INSERT INTO #PilotSkills (PilotName, PlaneName)
VALUES ('Johnson',  'Piper Cub'),
       ('Williams', 'B-52 Bomber'),
       ('Williams', 'F-14 Fighter'),
       ('Williams', 'Piper Cub'),
       ('Roberts',  'B-52 Bomber'),
       ('Roberts',  'F-14 Fighter'),
       ('Jones',    'B-1 Bomber'),
       ('Jones',    'B-52 Bomber'),
       ('Jones',    'F-14 Fighter'),
       ('Brown',    'B-1 Bomber'),
       ('Brown',    'B-52 Bomber'),
       ('Brown',    'F-14 Fighter'),
       ('Brown',    'F-17 Fighter');

INSERT INTO #Hangar (PlaneName)
VALUES ('B-1 Bomber'),
       ('B-52 Bomber'),
       ('F-14 Fighter');
```

**Pilot Skills**

| PilotName | PlaneName    |
|-----------|--------------|
| Johnson   | Piper Cub    |
| Williams  | B-52 Bomber  |
| Williams  | F-14 Fighter |
| Williams  | Piper Cub    |
| Roberts   | B-52 Bomber  |
| Roberts   | F-14 Fighter |
| Jones     | B-1 Bomber   |
| Jones     | B-52 Bomber  |
| Jones     | F-14 Fighter |
| Brown     | B-1 Bomber   |
| Brown     | B-52 Bomber  |
| Brown     | F-14 Fighter |
| Brown     | F-17 Fighter |

**Hangar**

| PlaneName    |
|--------------|
| B-1 Bomber   |
| B-52 Bomber  |
| F-14 Fighter |

### Nested `NOT EXISTS`

The most direct logical translation is:

> Return a pilot when there is no required plane for which that pilot has no matching skill.

The outer `NOT EXISTS` means “there is no required plane.” The inner `NOT EXISTS` means “for which no skill exists.”

```sql
WITH CandidatePilots AS
(
    SELECT DISTINCT PilotName
    FROM #PilotSkills
)
SELECT pilot.PilotName
FROM CandidatePilots AS pilot
WHERE NOT EXISTS
      (
          SELECT 1
          FROM #Hangar AS required_plane
          WHERE NOT EXISTS
                (
                    SELECT 1
                    FROM #PilotSkills AS skill
                    WHERE skill.PilotName = pilot.PilotName
                      AND skill.PlaneName = required_plane.PlaneName
                )
      )
ORDER BY pilot.PilotName;
```

| PilotName |
|-----------|
| Brown     |
| Jones     |

Brown qualifies even though Brown can also fly an F-17. Extra skills are allowed because this is division with a remainder.

### Grouping and `HAVING`

The same nonempty-divisor requirement can be expressed by counting each pilot's matched required planes and comparing that count with the number of planes in the hangar.

The primary keys in the setup guarantee that neither relation contains duplicate pilot/plane or hangar-plane rows. Without those guarantees, a plain `COUNT(*)` could overcount matches; use appropriate uniqueness constraints or count distinct required values.

```sql
SELECT skill.PilotName
FROM #PilotSkills AS skill
INNER JOIN #Hangar AS required_plane
    ON required_plane.PlaneName = skill.PlaneName
GROUP BY skill.PilotName
HAVING COUNT(*) =
       (
           SELECT COUNT(*)
           FROM #Hangar
       )
ORDER BY skill.PilotName;
```

| PilotName |
|-----------|
| Brown     |
| Jones     |

This grouped formulation has a different empty-divisor edge case. If `#Hangar` is empty, the inner join forms no pilot groups, so the query returns no rows. The nested `NOT EXISTS` version returns every candidate pilot because no required plane is missing. Decide which behavior matches the business rule.

### Exact Division

If the requirement changes to “which pilots can fly exactly the planes in the hangar and no others,” both set differences must be empty:

```sql
WITH CandidatePilots AS
(
    SELECT DISTINCT PilotName
    FROM #PilotSkills
)
SELECT pilot.PilotName
FROM CandidatePilots AS pilot
WHERE NOT EXISTS
      (
          SELECT PlaneName
          FROM #Hangar

          EXCEPT

          SELECT skill.PlaneName
          FROM #PilotSkills AS skill
          WHERE skill.PilotName = pilot.PilotName
      )
  AND NOT EXISTS
      (
          SELECT skill.PlaneName
          FROM #PilotSkills AS skill
          WHERE skill.PilotName = pilot.PilotName

          EXCEPT

          SELECT PlaneName
          FROM #Hangar
      )
ORDER BY pilot.PilotName;
```

| PilotName |
|-----------|
| Jones     |

Brown is excluded from exact division because the F-17 skill is not present in the hangar set.

## Example 2: Employees With Identical License Sets

Finding employees with identical licenses is an exact set-equality problem. Each employee's license set must be a subset of the other employee's set in both directions.

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

The two `EXCEPT` expressions calculate `A minus B` and `B minus A`. If neither difference contains a row, the sets are equal.

```sql
WITH Employees AS
(
    SELECT DISTINCT EmployeeID
    FROM #EmployeeLicenses
)
SELECT employee_a.EmployeeID AS EmployeeID_A,
       employee_b.EmployeeID AS EmployeeID_B,
       (
           SELECT COUNT(*)
           FROM #EmployeeLicenses AS license_count
           WHERE license_count.EmployeeID = employee_a.EmployeeID
       ) AS LicenseCount
FROM Employees AS employee_a
CROSS JOIN Employees AS employee_b
WHERE employee_a.EmployeeID < employee_b.EmployeeID
  AND NOT EXISTS
      (
          SELECT license_a.License
          FROM #EmployeeLicenses AS license_a
          WHERE license_a.EmployeeID = employee_a.EmployeeID

          EXCEPT

          SELECT license_b.License
          FROM #EmployeeLicenses AS license_b
          WHERE license_b.EmployeeID = employee_b.EmployeeID
      )
  AND NOT EXISTS
      (
          SELECT license_b.License
          FROM #EmployeeLicenses AS license_b
          WHERE license_b.EmployeeID = employee_b.EmployeeID

          EXCEPT

          SELECT license_a.License
          FROM #EmployeeLicenses AS license_a
          WHERE license_a.EmployeeID = employee_a.EmployeeID
      )
ORDER BY employee_a.EmployeeID,
         employee_b.EmployeeID;
```

| EmployeeID_A | EmployeeID_B | LicenseCount |
|-------------:|-------------:|-------------:|
| 1001         | 2002         | 3            |
| 4004         | 5005         | 3            |

The `<` predicate returns each employee pair once. Replacing it with `<>` would also return the reciprocal pairs `(2002, 1001)` and `(5005, 4004)`.

## Example 3: Employees Who Have Worked in Every Department

This example uses a separate table to define the required department set. That distinction is important: deriving the required set from the history table would make every newly observed department part of the requirement automatically.

`IsActive` records the employee's current status in that department, but the question asks whether the employee has ever worked there. The existence test therefore does not filter on `IsActive`.

```sql
DROP TABLE IF EXISTS #DepartmentHistory;
DROP TABLE IF EXISTS #Departments;

CREATE TABLE #Departments
(
    Department varchar(30) NOT NULL PRIMARY KEY
);

CREATE TABLE #DepartmentHistory
(
    Name       varchar(50) NOT NULL,
    Department varchar(30) NOT NULL,
    IsActive   bit         NOT NULL
);

INSERT INTO #Departments (Department)
VALUES ('Wardrobe'),
       ('Lighting'),
       ('Music');

INSERT INTO #DepartmentHistory (Name, Department, IsActive)
VALUES ('Chris', 'Wardrobe', 0),
       ('Chris', 'Lighting', 1),
       ('Chris', 'Music',    0),
       ('Nancy', 'Wardrobe', 1),
       ('Jim',   'Music',    1),
       ('Jim',   'Wardrobe', 0);
```

```sql
WITH Employees AS
(
    SELECT DISTINCT Name
    FROM #DepartmentHistory
)
SELECT employee.Name,
       (
           SELECT COUNT(*)
           FROM #Departments
       ) AS RequiredDepartmentCount
FROM Employees AS employee
WHERE NOT EXISTS
      (
          SELECT 1
          FROM #Departments AS required_department
          WHERE NOT EXISTS
                (
                    SELECT 1
                    FROM #DepartmentHistory AS history
                    WHERE history.Name = employee.Name
                      AND history.Department = required_department.Department
                )
      )
ORDER BY employee.Name;
```

| Name  | RequiredDepartmentCount |
|-------|------------------------:|
| Chris | 3                       |

If the requirement were “currently active in every department,” add `AND history.IsActive = 1` to the innermost subquery. No employee in the sample would then qualify.

## Important Edge Cases

### Duplicates

Relational algebra uses sets, while SQL tables and query results can contain duplicate rows. Counting formulations require uniqueness constraints, prior deduplication, or `COUNT(DISTINCT ...)` where supported. Existence- and `EXCEPT`-based formulations naturally ignore duplicate evidence, but duplicates can still affect the candidate relation and projected output.

### `NULL`

Classical relational division assumes known comparable values. SQL's `NULL` introduces `UNKNOWN` into equality predicates. Prefer `NOT NULL` constraints on divisor values and relationship keys. If `NULL` has a defined business meaning and should match another `NULL`, use an explicit null-safe comparison.

### Empty Required Sets

Under the usual logical interpretation, every candidate satisfies an empty required set because there is no missing requirement. Nested `NOT EXISTS` and empty-set-difference formulations naturally produce that result.

The candidate population still matters. If candidates exist only in the relationship table, entities with no relationship rows cannot be returned. Use a separate master table when those entities must participate.

Grouped inner-join formulations often return no candidates for an empty divisor because no groups are formed. Handle that case explicitly if the required set can be empty.

### Extra Related Values

Determine whether extra values are allowed. One subset test implements division with a remainder; subset tests in both directions implement exact set equality.

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
