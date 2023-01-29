# ANY, ALL and SOME

Coming Soon...

| Id |     Operation     |             Equivalent                                      |
|----|-------------------|-------------------------------------------------------------|
|  1 | = ALL             |  = MIN AND = MAX                                            |
|  2 | <> ALL            |  NOT IN                                                     |
|  3 | > ALL             |  > MAX                                                      |
|  4 | < ALL             |  < MIN                                                      |
|  5 | = ANY             |  IN                                                         |
|  6 | <> ANY            |  NOT(= ALL), <> MIN OR <> MAX, Restricted Cartesian Product | 
|  7 | > ANY             |  > MIN                                                      |
|  8 | < ANY             |  < MAX                                                      |
|  9 | >= ANY AND <= ANY |  BETWEEN and the MIN/MAX functions                          |

---------------------------------------------------------------

#### PART 1
**= ALL (Equal to ALL)**


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
**<> ALL (Not Equal to ALL)**

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
**> ALL (GREATER THAN ALL)**

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
**< ALL (LESS THAN ALL)**

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
**= ANY (EQUAL TO ANY)**

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
**<> ANY (NOT EQUAL TO ANY)**    
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
**> ANY (GREATER THAN ANY)**

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
**< ANY (LESS THAN ANY)**

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
**>= ANY AND <= ANY (GREATER THAN OR EQUAL TO ANY AND LESS THAN OR EQUAL TO ANY)**

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
