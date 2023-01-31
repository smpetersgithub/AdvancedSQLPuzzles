# ANY, ALL and SOME

ANY, ALL and SOME compare a scalar value with a single-column set of values. 

**SOME and ANY are equivalent; for this document I will use ANY.**

Because ANY, ALL, and SOME can be used with the 9 different logical operators below, there can be a total of 27 combinations.  Plus they can be negated with the NOT operator leading to even more combinations.  Most of the usages have equivalents that are easy to understand, and I have found the best way to understand ANY, ALL and SOME is by using the IF keyword to review their usage and provide an equivalant statement.

ANY, ALL, and SOME are not join types, but rather methods for creating predicate logic between tables. They can be utilized in correlated subqueries, where the outer query is joined to the subquery involved in the ANY, ALL, or SOME statement. These methods are similar to semi and anti-joins, in that they cannot be used in the SELECT clause and do not introduce duplicates. However, they differ in that they allow for comparisons between a range of values, rather than only equality or inequality.

-----

Here are the 9 different comparison operators that can be used with ANY, ALL and SOME.

There are two usages, <> ANY and = ALL, that I will further elaborate on, as these have special use cases that I feel are best practice to use rather than their equivalants.

| Operator | Description                         |
|----------|-------------------------------------|
| =        | Equal To                            |
| >        | Greater Than                        |
| <        | Less Than                           |
| >=       | Greater Than Or Equal To            |
| <=       | Less Than Or Equal To               |
| <>       | Not Equal To                        |
| !=       | Not Equal To (not ISO standard)     |
| !<       | Not Less Than (not ISO standard)    |
| !>       | Not Greater Than (not ISO standard) |


I have found understanding these 9 operations will easily allow you to understand any combination you will see in your daily SQL activities.  I have included the SQL statements below to review these operations.  The operations <> ANY and = ALL have special use cases, which I futher elaborate and give a more business use case for them.

| Id |     Operation     |             Equivalent                                      |
|----|-------------------|-------------------------------------------------------------|
|  1 | = ALL             |  = MIN AND = MAX                                            |
|  2 | <> ALL            |  NOT IN                                                     |
|  3 | > ALL             |  > MAX                                                      |
|  4 | < ALL             |  < MIN                                                      |
|  5 | = ANY             |  IN                                                         |
|  6 | <> ANY            |  NOT(= ALL), <> MIN OR <> MAX, TOP 1 using a theta-join     | 
|  7 | > ANY             |  > MIN                                                      |
|  8 | < ANY             |  < MAX                                                      |
|  9 | >= ANY AND <= ANY |  BETWEEN and the MIN/MAX functions                          |

---------------------------------------------------------------

#### PART 1
**= ALL (Equal To ALL)**


```sql
--FALSE
IF 3 = ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```


```sql
--TRUE
IF 3 = ALL (SELECT ID FROM (VALUES(3),(3),(3),(3)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
IF 3 = (SELECT MAX(ID) FROM (VALUES(3),(3),(3),(3)) AS a(ID)) 
       AND
   3 = (SELECT MIN(ID) FROM (VALUES(3),(3),(3),(3)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

#### PART 2
**<> ALL (Not Equal To ALL)**

```sql
--FALSE
IF 3 <> ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

```sql
--TRUE
IF 5 <> ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--FALSE
IF 3 NOT IN (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

#### PART 3
**> ALL (Greater Than ALL)**

```sql
--FALSE
IF 3 > ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE' ;
```
Equivalant statement below.

```sql
--TRUE

IF 5 > (SELECT MAX(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

#### PART 4
**< ALL (Less Than ALL)**

```sql
--FALSE
IF 3 < ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
IF 1 < (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

#### PART 5
**= ANY (Equal To ANY)**

```sql
--TRUE
IF 3 = ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
IF 3 IN (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

#### PART 6
**<> ANY (Not Equal To ANY)**    
Note this has several equivalent statements


```sql
--TRUE
IF 3 <> ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

```sql
--FALSE 
IF 3 <> ANY (SELECT ID FROM (VALUES(3),(3),(3),(3)) AS a(ID))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

Equivalant statements below.

```sql
--TRUE
IF NOT(3 = ALL(SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID)))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

```sql
--TRUE
IF 3 <> (SELECT MAX(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
        OR
   3 <> (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

```sql
--TRUE
IF EXISTS 
(
SELECT  DISTINCT TableA.ID
FROM    (VALUES(3)) AS TableA(ID) CROSS JOIN
        (VALUES(1),(2),(3)) AS TableB(ID)
WHERE    TableA.ID <> TableB.ID
)
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

---------------------------------------------------------------

#### PART 7
**> ANY (Greater Than ANY)**

```sql
--TRUE
IF 3 > ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
IF 3 > (SELECT MIN(ID)a FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

#### PART 8
**< ANY (Less Than ANY)**

```sql
--TRUE
IF 3 < ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
IF 3 < (SELECT MAX(ID)a FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

#### PART 9
**>= ANY AND <= ANY (Greater Than Or Equal To ANY AND Less Than Or Equal To ANY)**

```sql
--TRUE
--9 is greater than the MIN value in the comparison set AND
--9 is less than the MAX value in the comparison set
IF 9 >= ANY (SELECT ID FROM (VALUES(1),(2),(3),(10)) AS a(ID)) 
   AND
   9 <= ANY (SELECT ID FROM (VALUES(1),(2),(3),(10)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
IF 9 BETWEEN (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(10)) AS a(ID)) 
             AND
             (SELECT MAX(ID) FROM (VALUES(1),(2),(3),(10)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

------------------------------------------------------

### Example 1: Use Cases for = ALL and <> ANY

The following are examples of the = ALL and <> ANY operators.

You are given the following example table of runtime statuses, provide an SQL statement that generates the required output.

*  If all the statuses are completed, print "True", else print "False"
*  If all the statuses are not completed, print "True", else print "False".

This example table has statuses that are all completed.

| ID |  Status   |
|----|-----------|
|  1 | Completed |
|  2 | Completed |
|  3 | Completed |
|  4 | Completed |

This example table has statuses that are not all completed.

| ID |  Status   |
|----|-----------|
|  1 | Completed |
|  2 | Completed |
|  3 | Running   |
|  4 | Completed |

Here is the SQL statements (along with the DDL) that produce the required output.

```sql
CREATE TABLE #Status
(
ID  INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
Status VARCHAR(10)
);

INSERT INTO #Status (Status) VALUES ('Completed'),('Completed'),('Completed'),('Completed');
GO

IF 'Completed' = ALL (SELECT Status FROM #Status)
PRINT 'TRUE'
ELSE
PRINT 'FALSE';

TRUNCATE TABLE #Status
INSERT INTO #Status (Status) VALUES ('Completed'),('Error'),('Running'),('Completed');
GO

IF 'Completed' <> ANY (SELECT Status FROM #Status)
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

-----

### Example 2: Use Cases for = ALL and <> ANY

Here is another (more elaborate) example using the = ALL operator with a correlated subquery.  Feel free to modify the data and the requirements to experiment with different ways to produce the expected output.
        
Given the following tables: Sales Representatives and Top Selling Products by Quarter; calculate the following commissions for the year.

*  If ALL the top selling products for the quarter are from one region only, all sales representatives from that region receive a $1000 bonus.
*  If the top selling products for the quarter are from different regions, all sales representatives from those regions receive a $250 bonus.
*  If a sales representative is assigned to a region that did not have a top selling product for the year, they receive a goat.

| SalesRepID | Region |
|------------|--------|
|       1001 | North  |
|       2002 | North  |
|       3003 | South  |
|       4004 | South  |
|       5005 | East   |
|       6006 | West   |


| SalesQuarter | Region | Product |
|--------------|--------|---------|
| Q1           | North  | A       |
| Q1           | North  | B       |
| Q1           | North  | C       |
| Q2           | North  | A       |
| Q2           | North  | B       |
| Q2           | South  | C       |
| Q3           | East   | D       |
| Q3           | North  | C       |
| Q3           | South  | E       |
| Q4           | North  | A       |
| Q4           | North  | C       |
| Q4           | South  | E       |

*  For Q1, the North region had all of the top selling products, therefore reps 1001 and 2002 each get a $1000 commission for that quarter. The North region also had sales in Q2, Q3, and Q4, getting $250 for each of these quarters.
*  The South region had top selling products in Q2, Q3, and Q4, so they receive $750.
*  The East region had a top selling product in Q3 only, so they receive $250.
*  The West region did not have any top selling products for any of the quarters, therefore the sales reps get a goat as a commission.

Here is the SQL to produce the expected results.

```sql
DROP TABLE IF EXISTS #TopSellingProducts;
DROP TABLE IF EXISTS #SalesReps;
DROP TABLE IF EXISTS #CommissionsQuarter;
GO

CREATE TABLE #TopSellingProducts
(
SalesQuarter CHAR(2) NOT NULL,
Region  VARCHAR(10) NOT NULL,
Product CHAR(1) NOT NULL,
PRIMARY KEY (SalesQuarter, Region, Product)
);
GO

INSERT INTO #TopSellingProducts (SalesQuarter, Region, Product) VALUES
('Q1','North','A'),
('Q1','North','B'),
('Q1','North','C'),
-------------------
('Q2','North','A'),
('Q2','North','B'),
('Q2','South','C'),
-------------------
('Q3','North','C'),
('Q3','East','D'),
('Q3','South','E'),
-------------------
('Q4','North','A'),
('Q4','North','C'),
('Q4','South','E');
GO

CREATE TABLE #SalesReps 
(
SalesRepID INTEGER NOT NULL PRIMARY KEY,
Region VARCHAR(10) NOT NULL
);
GO

INSERT INTO #SalesReps (SalesRepID, Region) VALUES
(1001,'North'),
(2002,'North'),
(3003,'South'),
(4004,'South'),
(5005,'East'),
(6006,'West');
GO

WITH cte_SalesRepsQuarter AS
(
SELECT DISTINCT
       a.SalesRepID,
       a.Region,
       b.SalesQuarter
FROM   #SalesReps a CROSS JOIN
       #TopSellingProducts b
),
cte_CommissionALL AS
(
SELECT  CAST(1000.00 AS VARCHAR(10)) AS Commission,
        *
FROM    cte_SalesRepsQuarter a
WHERE   Region = ALL(SELECT Region FROM #TopSellingProducts b WHERE a.SalesQuarter = b.SalesQuarter)
)
----------------------------
SELECT  *
INTO    #CommissionsQuarter
FROM    cte_CommissionALL
UNION
----------------------------
SELECT  CAST(250.00 AS MONEY),
        *
FROM    cte_SalesRepsQuarter a
WHERE   Region IN (SELECT Region FROM #TopSellingProducts b WHERE a.SalesQuarter = b.SalesQuarter)
        AND
        NOT EXISTS (SELECT 1 FROM cte_CommissionALL b WHERE a.SalesRepID = b.SalesRepID AND a.SalesQuarter = b.SalesQuarter)
UNION
----------------------------
SELECT  NULL,
        SalesRepID,
        Region,
        NULL
FROM    cte_SalesRepsQuarter a
WHERE   Region NOT IN (SELECT Region FROM #TopSellingProducts)
----------------------------
ORDER BY SalesQuarter, SalesRepID, Region, Commission;
GO

SELECT  COALESCE(CAST(SUM(Commission) AS VARCHAR(100)),'Goat') AS Commission,
        SalesRepID,
        Region
FROM    #CommissionsQuarter
GROUP BY SalesRepID, Region
ORDER BY SalesRepID;
GO
```

---------------

Happy coding!