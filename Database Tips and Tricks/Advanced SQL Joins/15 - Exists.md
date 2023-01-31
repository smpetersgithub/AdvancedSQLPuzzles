# EXISTS

The EXISTS operator in SQL is a Boolean operator that tests for the existence of any rows in a subquery. It returns TRUE if the subquery returns at least one row, and FALSE if the subquery returns no rows. The EXISTS can be used with the IF, WHERE, and the ON clauses.  The EXIST operator can also be used with the NOT operator for negation.

This document will concentrate on the ON EXISTS statement with the ON clause.  Strangly, I cannot find any documentation with Microsoft or PostgreSQL for the usage of ON EXISTS.  Itzik Ben-Gan does mention it in passing in an article here about it's usage, and he does mention it in the TSQL Fundamentals book.

First let's look of some examples of the EXISTS.  It is important to remember that the EXISTS clause returns TRUE or FALSE, and not a result set.

--------------------------------------------------------------
#### IF EXISTS

Here we have an example of using EXISTS with the IF statement to check for the existence of records.  

This statement will return TRUE, as there are records in Table A.

```sql
IF EXISTS (SELECT 1 FROM ##TableA)
THEN
PRINT 'TRUE'
ELSE
PRINT 'FALSE'
```

This statement will return FALSE when we use use the NOT operator.

```sql
IF NOT EXISTS (SELECT 1 FROM ##TableA)
THEN
PRINT 'TRUE'
ELSE
PRINT 'FALSE'
```

This statement will return TRUE when we suplly a NULL value.

```sql
IF EXISTS (SELECT NULL)
PRINT 'True'
ELSE
PRINT 'False'
```


--------------------------------------------------------------
#### ON EXISTS

Normally we use the EXISTS operator with the WHERE clause to create a correlated subquery.

The query acts the same as the INNER JOIN and only returns records from TableA.

```sql
SELECT  *
FROM    ##TableA a
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);
```

| ID | Fruit | Quantity |
|----|-------|----------|
|  1 | Apple |       17 |
|  2 | Peach |       20 |


When we use negation (the NOT operator) with the EXISTS clause, we return the records that exist in TableA but not in TableB.

```sql
SELECT  *
FROM    ##TableA a
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);
```

| ID | Fruit   | Quantity |
|----|---------|----------|
|  3 | Mango   |       11 |
|  4 | <NULL>  |        5 |

  
--------------------------------------------------------------
#### ON EXISTS
  
Probably one of the more difficult joins to understand is the below usage of EXISTS.  It is best to learn by examples and remember that EXISTS returns TRUE or FALSE and not a subset of records.  The ON EXISTS will work with the INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN, and FULL OUTER JOIN clauses, but not the CROSS JOIN.
 
These statments will return TRUE and behave like a CROSS JOIN.
  
```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT 1)
ORDER BY 1,2;
```
  
```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT NULL)
ORDER BY 1,2;
```    

| ID | Fruit  | Quantity | ID | Fruit  | Quantity |
|----|--------|----------|----|--------|----------|
|  1 | Apple  |       17 |  1 | Apple  | 17       |
|  1 | Apple  |       17 |  2 | Peach  | 25       |
|  1 | Apple  |       17 |  3 | Kiwi   | 20       |
|  1 | Apple  |       17 |  4 | NULL   | <NULL>   |
|  2 | Peach  |       20 |  1 | Apple  | 17       |
|  2 | Peach  |       20 |  2 | Peach  | 25       |
|  2 | Peach  |       20 |  3 | Kiwi   | 20       |
|  2 | Peach  |       20 |  4 | <NULL> | <NULL>   |
|  3 | Mango  |       11 |  1 | Apple  | 17       |
|  3 | Mango  |       11 |  2 | Peach  | 25       |
|  3 | Mango  |       11 |  3 | Kiwi   | 20       |
|  3 | Mango  |       11 |  4 | <NULL> | <NULL>   |
|  4 | <NULL> |        5 |  1 | Apple  | 17       |
|  4 | <NULL> |        5 |  2 | Peach  | 25       |
|  4 | <NULL> |        5 |  3 | Kiwi   | 20       |
|  4 | <NULL> |        5 |  4 | <NULL> | <NULL>   |

----------------------------------------------------

From our previous SQL statement we can see that the INNER JOIN acts like a CROSS JOIN.  Now lets add a more practical use of the ON EXISTS.  Here we have a more practical use of the statement.

This query will return all the rows of table A and B where the values of column "Fruit" are the same in both tables, and the columns of both tables will be included in the result set. The query will include rows from TableA where the Fruit value exists in TableB.  
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT a.Fruit INTERSECT SELECT b.Fruit);
```


| ID | Fruit  | Quantity | ID | Fruit  | Quantity |
|----|--------|----------|----|--------|----------|
|  1 | Apple  |       17 |  1 | Apple  | 17       |
|  2 | Peach  |       20 |  2 | Peach  | 25       |
|  4 | <NULL> |        5 |  4 | <NULL> | <NULL>   |

  
A similiar statement to the above would be the following where we have to explicitly handle NULL markers.

```sql
SELECT  *
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   ISNULL(a.Fruit,'') = ISNULL(b.Fruit,'');
```

| ID | Fruit  | Quantity | ID | Fruit  | Quantity |
|----|--------|----------|----|--------|----------|
|  1 | Apple  |       17 |  1 | Apple  | 17       |
|  2 | Peach  |       20 |  2 | Peach  | 25       |
|  4 | <NULL> |        5 |  4 | <NULL> | <NULL>   |
  
  
We can also apply DeMorgan's law and use the NOT EXISTS and the EXCEPT operators.
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON NOT EXISTS(SELECT a.Fruit EXCEPT SELECT b.Fruit);
```

| ID | Fruit  | Quantity | ID | Fruit  | Quantity |
|----|--------|----------|----|--------|----------|
|  1 | Apple  |       17 |  1 | Apple  | 17       |
|  2 | Peach  |       20 |  2 | Peach  | 25       |
|  4 | <NULL> |        5 |  4 | <NULL> | <NULL>   |
  

-----------------------------------------------------------------------------------------
  
If we change the INTERSECT with an EXCEPT we get the following.
  
This query will return all the rows of table A and B where the values of column "Fruit" are different in both tables, and the columns of both tables will be included in the result set. The query will exclude rows from TableA where the Fruit value exists in TableB.  
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT a.Fruit EXCEPT SELECT b.Fruit);
```

| ID | Fruit  | Quantity | ID | Fruit  | Quantity |
|----|--------|----------|----|--------|----------|
| 1  | Apple  | 17       | 2  | Peach  | 25       |
| 1  | Apple  | 17       | 3  | Kiwi   | 20       |
| 1  | Apple  | 17       | 4  | <NULL> | <NULL>   |
| 2  | Peach  | 20       | 1  | Apple  | 17       |
| 2  | Peach  | 20       | 3  | Kiwi   | 20       |
| 2  | Peach  | 20       | 4  | <NULL> | <NULL>   |
| 3  | Mango  | 11       | 1  | Apple  | 17       |
| 3  | Mango  | 11       | 2  | Peach  | 25       |
| 3  | Mango  | 11       | 3  | Kiwi   | 20       |
| 3  | Mango  | 11       | 4  | <NULL> | <NULL>   |
| 4  | <NULL> | 5        | 1  | Apple  | 17       |
| 4  | <NULL> | 5        | 2  | Peach  | 25       |
| 4  | <NULL> | 5        | 3  | Kiwi   | 20       |

Note, missing from this above set is the following.

| ID | Fruit  | Quantity | ID | Fruit  | Quantity |
|----|--------|----------|----|--------|----------|
|  1 | Apple  |       17 |  1 | Apple  | 17       |
|  2 | Peach  |       20 |  2 | Peach  | 25       |
|  4 | <NULL> |        5 |  4 | <NULL> | <NULL>   |
 
The equivalant statement for this below.
  
``sql
SELECT  *
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   NOT(ISNULL(a.Fruit,'') = ISNULL(b.Fruit,''));
```
  
| ID | Fruit  | Quantity | ID | Fruit  | Quantity |  
|----|--------|----------|----|--------|----------|
| 1  | Apple  | 17       | 2  | Peach  | 25       |
| 1  | Apple  | 17       | 3  | Kiwi   | 20       |
| 1  | Apple  | 17       | 4  | <NULL> | <NULL>   |
| 2  | Peach  | 20       | 1  | Apple  | 17       |
| 2  | Peach  | 20       | 3  | Kiwi   | 20       |
| 2  | Peach  | 20       | 4  | <NULL> | <NULL>   |
| 3  | Mango  | 11       | 1  | Apple  | 17       |
| 3  | Mango  | 11       | 2  | Peach  | 25       |
| 3  | Mango  | 11       | 3  | Kiwi   | 20       |
| 3  | Mango  | 11       | 4  | <NULL> | <NULL>   |
| 4  | <NULL> | 5        | 1  | Apple  | 17       |
| 4  | <NULL> | 5        | 2  | Peach  | 25       |
| 4  | <NULL> | 5        | 3  | Kiwi   | 20       |

  
DeMorgan's Law is in effect, and you can accomplish the above with the NOT EXISTS and the INTERSECT statement.

```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON NOT EXISTS(SELECT a.Fruit INTERSECT SELECT b.Fruit);
```

| ID | Fruit  | Quantity | ID | Fruit  | Quantity |  
|----|--------|----------|----|--------|----------|
| 1  | Apple  | 17       | 2  | Peach  | 25       |
| 1  | Apple  | 17       | 3  | Kiwi   | 20       |
| 1  | Apple  | 17       | 4  | <NULL> | <NULL>   |
| 2  | Peach  | 20       | 1  | Apple  | 17       |
| 2  | Peach  | 20       | 3  | Kiwi   | 20       |
| 2  | Peach  | 20       | 4  | <NULL> | <NULL>   |
| 3  | Mango  | 11       | 1  | Apple  | 17       |
| 3  | Mango  | 11       | 2  | Peach  | 25       |
| 3  | Mango  | 11       | 3  | Kiwi   | 20       |
| 3  | Mango  | 11       | 4  | <NULL> | <NULL>   |
| 4  | <NULL> | 5        | 1  | Apple  | 17       |
| 4  | <NULL> | 5        | 2  | Peach  | 25       |
| 4  | <NULL> | 5        | 3  | Kiwi   | 20       |
  
-----------------------------------------------------------------------------------------
  
  
