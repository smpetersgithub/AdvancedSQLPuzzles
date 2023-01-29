# ANY, ALL and SOME

Coming Soon...

| Id |     Operation     |             Equivalent                                      |
-----|-------------------|-------------------------------------------------------------|
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
EQUAL TO ALL

FALSE
3 does not equate to ALL values in the comparison set

```sql
IF 3 = ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

TRUE
3 does equate to ALL values in the comparison set

```sql
IF 3 = ALL (SELECT ID FROM (VALUES(3),(3),(3),(3)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

TRUE
= ALL equivalent using MIN and MAX
3 is equal to the MIN and MAX values of the comparison set
```sql
IF 3 = (SELECT MAX(ID) FROM (VALUES(3),(3),(3),(3)) AS a(ID)) 
       AND
   3 = (SELECT MIN(ID) FROM (VALUES(3),(3),(3),(3)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

#### PART 2
NOT EQUAL TO ALL

FALSE
3 is IN the comparison set
```sql
IF 3 <> ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

TRUE
5 is NOT IN the comparison set
```sql
IF 5 <> ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

FALSE
<> ALL equivalent using the NOT IN operator
3 is IN the comparison set
```sql
IF 3 NOT IN (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

#### PART 3
GREATER THAN ALL

FALSE
3 is not greater than the MAX value in the comparison set
```sql
IF 3 > ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE' ;
```

TRUE
> ALL equivalent using MAX
5 is greater than the MAX value in the comparison set
```sql
IF 5 > (SELECT MAX(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

#### PART 4
LESS THAN ALL

FALSE
3 is not less than the MIN value in the comparison set
```sql
IF 3 < ALL (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

TRUE
< ALL equivalent using MIN
1 is less than the MIN value in the comparison set
```sql
IF 1 < (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

### PART 5
EQUAL TO ANY

TRUE
3 matches at least one value in the comparison set
```sql
IF 3 = ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

TRUE
= ANY equivalent using the IN operator
3 is IN the comparison set
```sql
IF 3 IN (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

### PART 6
NOT EQUAL TO ANY
Note this has several equivalent statements

TRUE
3 is not equal to 1, 2 and 4
```sql
IF 3 <> ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```
FALSE 
3 is equal to every value in the statement
```sql
IF 3 <> ANY (SELECT ID FROM (VALUES(3),(3),(3),(3)) AS a(ID))
PRINT 'TRUE'

ELSE
PRINT 'FALSE';
```

TRUE
<> ANY equivalent using NOT(= ALL)
```sql
IF NOT(3 = ALL(SELECT ID FROM (VALUES(1),(2),(3),(4))  AS a(ID)))
PRINT 'TRUE'
ELSE
PRINT 'FALSE';
```

TRUE
<> ANY equiv
alent using <> MIN OR <> MAX
3 is not equal to the MAX or the MIN values of the comparison set
```sql
IF 3 <> (SELECT MAX(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
        OR
   3 <> (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(4)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

TRUE
<> ANY equivalent using DISTINCT, CROSS JOIN, and a theta-join
```sql
SELECT  DISTINCT TableA.ID
FROM    (VALUES(3)) AS TableA(ID) CROSS JOIN
        (VALUES(1),(2),(3)) AS TableB(ID)
WHERE    TableA.ID <> TableB.ID;
```

### PART 7
GREATER THAN ANY

TRUE
3 is greater than the MIN value in the comparison set
```sql
IF 3 > ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

TRUE
> ANY equivalent using MIN function
3 is greater than the MIN value in the comparison set

```sql
IF 3 > (SELECT MIN(ID)a FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

### PART 8
LESS THAN ANY

TRUE
3 is less than the MAX value in the comparison set
```sql
IF 3 < ANY (SELECT ID FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```
TRUE
< ANY equivalent using MAX
3 is less than the MAX value in the comparison set
```sql
IF 3 < (SELECT MAX(ID)a FROM (VALUES(1),(2),(3),(4)) AS a(ID)) 
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

### PART 9
GREATER THAN OR EQUAL TO ANY AND LESS THAN OR EQUAL TO ANY

TRUE
9 is greater than the MIN value in the comparison set AND
9 is less than the MAX value in the comparison set
```sql
IF 9 >= ANY (SELECT ID FROM (VALUES(1),(2),(3),(10)) AS a(ID)) 
   AND
   9 <= ANY (SELECT ID FROM (VALUES(1),(2),(3),(10)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```

TRUE
>= ANY AND <= ANY equivalent using BETWEEN and the MIN/MAX functions
9 is BETWEEN the MIN and MAX values in the comparison set
```sql
IF 9 BETWEEN (SELECT MIN(ID) FROM (VALUES(1),(2),(3),(10)) AS a(ID)) 
             AND
             (SELECT MAX(ID) FROM (VALUES(1),(2),(3),(10)) AS a(ID))
PRINT 'TRUE'
ELSE  
PRINT 'FALSE';
```
------------------------------------------------------
THEN END-
