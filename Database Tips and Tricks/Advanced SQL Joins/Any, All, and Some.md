### ANY, ALL and SOME

ANY, ALL and SOME compare a scalar value with a single-column set of values. 

> **SOME and ANY are equivalent; for this document I will use ANY.**

-----

Because ANY, ALL, and SOME can be used with the 9 different logical operators below, there can be a total of 27 combinations.  Plus they can be negated with the NOT operator leading to even more combinations.  Most of the usages have equivalents that are easy to understand, and I have found the best way to understand ANY, ALL and SOME is by using the IF keyword to review their usage and provide an equivalant statement.

There are two usages, <> ANY and = ALL, that I will further elaborate on, as these have special use cases that I feel are best practice to use rather than their equivalants.

First, here are the 9 different comparison operators that can be used with ANY, ALL and SOME.


|           Operator            |               Meaning               |
|-------------------------------|-------------------------------------|
| = (Equals)                    |  Equal to                           |
| > (Greater Than)              | Greater than                        |
| < (Less Than)                 | Less than                           |
| >= (Greater Than or Equal To) | Greater than or equal to            |
| <= (Less Than or Equal To)    | Less than or equal to               |
| <> (Not Equal To)             | Not equal to                        |
| != (Not Equal To)             | Not equal to (not ISO standard)     |
| !< (Not Less Than)            | Not less than (not ISO standard)    |
| !> (Not Greater Than)         | Not greater than (not ISO standard) |


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

I also want to point out the following negation, as DeMorgan's law does apply to <> ANY, which is equivalent to NOT(= ALL).  The <> ANY can also be determined by restricted cartesian product using a theta-join and the TOP 1 operation.


---------------------------------------------------------------

#### PART 1
**= ALL (Equal To ALL)**


```sql
--FALSE
--3 does not equate to ALL values in the comparison set
IF 3 = ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```


```sql
--TRUE
--3 does equate to ALL values in the comparison set
IF 3 = ALL (SELECT ID FROM (VALUES(3),(3),(3),(3)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
--3 is equal to the MIN and MAX values of the comparison set
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
--3 is IN the comparison set
IF 3 <> ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

```sql
--TRUE
--5 is NOT IN the comparison set
IF 5 <> ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--FALSE
--3 is IN the comparison set
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
--3 is not greater than the MAX value in the comparison set
IF 3 > ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE' ;
```
Equivalant statement below.

```sql
--TRUE
--5 is greater than the MAX value in the comparison set
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
--3 is not less than the MIN value in the comparison set
IF 3 < ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
--1 is less than the MIN value in the comparison set
IF 1 < (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 5
**= ANY (Equal To ANY)**

```sql
--TRUE
--3 matches at least one value in the comparison set
IF 3 = ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
--3 is IN the comparison set
IF 3 IN (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 6
**<> ANY (Not Equal To ANY)**    
Note this has several equivalent statements


```sql
--TRUE
--3 is not equal to 1, 2 and 4
IF 3 <> ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

```sql
--FALSE 
--3 is equal to every value in the statement
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
--3 is not equal to the MAX or the MIN values of the comparison set
IF 3 <> (SELECT MAX(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
        OR
   3 <> (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

```sql
--TRUE
SELECT  DISTINCT TableA.ID
FROM    (VALUES(3)) AS TableA(ID) CROSS JOIN
        (VALUES(1),(2),(3)) AS TableB(ID)
WHERE    TableA.ID <> TableB.ID;
```

---------------------------------------------------------------

### PART 7
**> ANY (Greater Than ANY)**

```sql
--TRUE
--3 is greater than the MIN value in the comparison set
IF 3 > ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
--3 is greater than the MIN value in the comparison set
IF 3 > (SELECT MIN(ID)a FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 8
**< ANY (Less Than ANY)**

```sql
--TRUE
--3 is less than the MAX value in the comparison set
IF 3 < ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

Equivalant statement below.

```sql
--TRUE
--3 is less than the MAX value in the comparison set
IF 3 < (SELECT MAX(ID)a FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 9
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
--9 is BETWEEN the MIN and MAX values in the comparison set
IF 9 BETWEEN (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(10)) AS a(ID)) 
             AND
             (SELECT MAX(ID) FROM (VALUES(1),(2),(3),(10)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

------------------------------------------------------

Happy coding!
