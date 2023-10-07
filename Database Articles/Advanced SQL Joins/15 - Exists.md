# EXISTS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The `EXISTS` operator in SQL is a Boolean operator that tests for the existence of any rows in a subquery. It returns TRUE if the subquery returns at least one row and FALSE if the subquery returns no rows. The `EXISTS` can be used with the `IF`, `WHERE`, and the `ON` clauses.  The `EXIST` operator can also be used with the `NOT` operator for negation.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This document will concentrate on the `EXISTS` statement with the `ON` clause.  Strangely, I cannot find any documentation with Microsoft or PostgreSQL for the usage of `ON EXISTS`.  Itzik Ben-Gan does mention it in passing in an article [here](https://sqlperformance.com/2019/12/t-sql-queries/null-complexities-part-1) about its usage, and he does mention it in the [T-SQL Fundamentals](https://www.amazon.com/T-SQL-Fundamentals-3rd-Itzik-Ben-Gan/dp/150930200X/ref=sr_1_1?adgrpid=1331509151302817&hvadid=83219393942729&hvbmt=be&hvdev=c&hvlocphy=66021&hvnetw=o&hvqmt=e&hvtargid=kwd-83219680138630%3Aloc-190&hydadcr=16377_10417921&keywords=t-sql+fundamentals&qid=1675204165&sr=8-1) book.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;First, let's look at some examples of the `EXISTS`.  It is important to remember that the `EXISTS` clause returns TRUE or FALSE and not a result set.

--------------------------------------------------------------------------------
We will be using the following tables that contain types of fruits and their quantity.  

[The DDL to create these tables can be found here.](Sample%20Data.md)

**Table A**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  |       17 |
|  2 | Peach  |       20 |
|  3 | Mango  |       11 |
|  4 | \<NULL> |        5 |
  
**Table B**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  | 17       |
|  2 | Peach  | 25       |
|  3 | Kiwi   | 20       |
|  4 | \<NULL> | \<NULL>   |
  
#### IF EXISTS

Here, we have an example of using `EXISTS` with the `IF` statement to check for the existence of records.  

This statement will return TRUE, as there are records in `TableA`.

```sql
IF EXISTS (SELECT 1 FROM ##TableA)
THEN
PRINT 'TRUE'
ELSE
PRINT 'FALSE'
```

This statement will return FALSE if we use the `NOT` operator.

```sql
IF NOT EXISTS (SELECT 1 FROM ##TableA)
THEN
PRINT 'TRUE'
ELSE
PRINT 'FALSE'
```

This statement will return TRUE when we supply a NULL value.  Even though we supply a NULL value, it does return a record set with a NULL value, which is different than an empty record set.

```sql
IF EXISTS (SELECT NULL)
PRINT 'TRUE'
ELSE
PRINT 'FALSE'
```


--------------------------------------------------------------
#### EXISTS

Normally, we use the `EXISTS` operator with the `WHERE` clause to create a correlated subquery.

The query acts the same as the `INNER JOIN`, and only returns records from `TableA`.

```sql
SELECT  *
FROM    ##TableA a
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);
```

| ID | Fruit | Quantity |
|----|-------|----------|
|  1 | Apple |       17 |
|  2 | Peach |       20 |

When we use negation (the `NOT` operator) with the `EXISTS` clause, we return the records in `TableA` but not in `TableB`.

```sql
SELECT  *
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);
```

| ID | Fruit   | Quantity |
|----|---------|----------|
|  3 | Mango   |       11 |
|  4 | \<NULL>  |        5 |

  
--------------------------------------------------------------
#### ON EXISTS
  
Probably one of the more difficult joins to understand is the below usage of `EXISTS`.  It is best to learn by examples and remember that `EXISTS` returns TRUE or FALSE and not a subset of records.  The `ON EXISTS` will work with the `INNER JOIN`, `LEFT OUTER JOIN`, `RIGHT OUTER JOIN`, and `FULL OUTER JOIN` clauses, but not the `CROSS JOIN`.
 
These statements will return TRUE and behave like a `CROSS JOIN`.
  
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

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 1  | Apple   | 17       |
| 1  | Apple   | 17       | 2  | Peach   | 25       |
| 1  | Apple   | 17       | 3  | Kiwi    | 20       |
| 1  | Apple   | 17       | 4  | \<NULL> | \<NULL>  |
| 2  | Peach   | 20       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 2  | Peach   | 25       |
| 2  | Peach   | 20       | 3  | Kiwi    | 20       |
| 2  | Peach   | 20       | 4  | \<NULL> | \<NULL>  |
| 3  | Mango   | 11       | 1  | Apple   | 17       |
| 3  | Mango   | 11       | 2  | Peach   | 25       |
| 3  | Mango   | 11       | 3  | Kiwi    | 20       |
| 3  | Mango   | 11       | 4  | \<NULL> | \<NULL>  |
| 4  | \<NULL> | 5        | 1  | Apple   | 17       |
| 4  | \<NULL> | 5        | 2  | Peach   | 25       |
| 4  | \<NULL> | 5        | 3  | Kiwi    | 20       |
| 4  | \<NULL> | 5        | 4  | \<NULL> | \<NULL>  |

----------------------------------------------------

From our previous SQL statement, we can see that the `INNER JOIN` acts like a `CROSS JOIN`.  Now let’s add a more practical use of the `ON EXISTS`.  Here, we have a more practical use of the statement.

This query will return all the rows of `TableA` and `TableB` where the values of column `Fruit` are the same in both tables, and the columns of both tables will be included in the result set. The query will include rows from `TableA` where the `Fruit` value exists in `TableB`.  
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT a.Fruit INTERSECT SELECT b.Fruit);
```

| ID | Fruit   | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
|  1 | Apple   | 17       | 1  | Apple   | 17       |
|  2 | Peach   | 20       | 2  | Peach   | 25       |
|  4 | \<NULL> | 5        | 4  | \<NULL> | \<NULL>  |

  
A similar statement to the above would be the following, where we must explicitly handle NULL markers.

```sql
SELECT  *
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   ISNULL(a.Fruit,'') = ISNULL(b.Fruit,'');
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
|  1 | Apple   | 17       | 1  | Apple   | 17       |
|  2 | Peach   | 20       | 2  | Peach   | 25       |
|  4 | \<NULL> | 5        | 4  | \<NULL> | \<NULL>  |
  
  
We can also apply De Morgan's law and use the `NOT EXISTS` and the `EXCEPT` operators.
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON NOT EXISTS(SELECT a.Fruit EXCEPT SELECT b.Fruit);
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
|  1 | Apple   | 17       | 1  | Apple   | 17       |
|  2 | Peach   | 20       | 2  | Peach   | 25       |
|  4 | \<NULL> | 5        | 4  | \<NULL> | \<NULL>  |
  

-----------------------------------------------------------------------------------------
  
If we change the `INTERSECT` with an `EXCEPT`, we get the following.
  
This query will return all the rows of `TableA` and `TableB` where the values of column `Fruit` are different in both tables, and the columns of both tables will be included in the result set. The query will exclude rows from `TableA` where the `Fruit` value exists in `TableB`.  
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT a.Fruit EXCEPT SELECT b.Fruit);
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 2  | Peach   | 25       |
| 1  | Apple   | 17       | 3  | Kiwi    | 20       |
| 1  | Apple   | 17       | 4  | \<NULL> | \<NULL>  |
| 2  | Peach   | 20       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 3  | Kiwi    | 20       |
| 2  | Peach   | 20       | 4  | <NULL>  | \<NULL>  |
| 3  | Mango   | 11       | 1  | Apple   | 17       |
| 3  | Mango   | 11       | 2  | Peach   | 25       |
| 3  | Mango   | 11       | 3  | Kiwi    | 20       |
| 3  | Mango   | 11       | 4  | \<NULL> | \<NULL>  |
| 4  | \<NULL> | 5        | 1  | Apple   | 17       |
| 4  | \<NULL> | 5        | 2  | Peach   | 25       |
| 4  | \<NULL> | 5        | 3  | Kiwi    | 20       |

Note, missing from this above set is the following.

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 2  | Peach   | 25       |
| 4  | \<NULL> | 5        | 4  | \<NULL> | \<NULL>  |
 
The equivalent statement for this is below.
  
```sql
SELECT  *
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   NOT(ISNULL(a.Fruit,'') = ISNULL(b.Fruit,''));
```
  
| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |  
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 2  | Peach   | 25       |
| 1  | Apple   | 17       | 3  | Kiwi    | 20       |
| 1  | Apple   | 17       | 4  | \<NULL> | \<NULL>  |
| 2  | Peach   | 20       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 3  | Kiwi    | 20       |
| 2  | Peach   | 20       | 4  | \<NULL> | \<NULL>  |
| 3  | Mango   | 11       | 1  | Apple   | 17       |
| 3  | Mango   | 11       | 2  | Peach   | 25       |
| 3  | Mango   | 11       | 3  | Kiwi    | 20       |
| 3  | Mango   | 11       | 4  | \<NULL> | \<NULL>  |
| 4  | \<NULL> | 5        | 1  | Apple   | 17       |
| 4  | \<NULL> | 5        | 2  | Peach   | 25       |
| 4  | \<NULL> | 5        | 3  | Kiwi    | 20       |

  
De Morgan's Law is in effect, and you can accomplish the above with the `NOT EXISTS` and the `INTERSECT` statements.

```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON NOT EXISTS(SELECT a.Fruit INTERSECT SELECT b.Fruit);
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |  
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 2  | Peach   | 25       |
| 1  | Apple   | 17       | 3  | Kiwi    | 20       |
| 1  | Apple   | 17       | 4  | \<NULL> | \<NULL>  |
| 2  | Peach   | 20       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 3  | Kiwi    | 20       |
| 2  | Peach   | 20       | 4  | \<NULL> | \<NULL>  |
| 3  | Mango   | 11       | 1  | Apple   | 17       |
| 3  | Mango   | 11       | 2  | Peach   | 25       |
| 3  | Mango   | 11       | 3  | Kiwi    | 20       |
| 3  | Mango   | 11       | 4  | \<NULL> | \<NULL>  |
| 4  | \<NULL> | 5        | 1  | Apple   | 17       |
| 4  | \<NULL> | 5        | 2  | Peach   | 25       |
| 4  | \<NULL> | 5        | 3  | Kiwi    | 20       |
  
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
