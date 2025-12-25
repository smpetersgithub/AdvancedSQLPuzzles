# EXISTS

The `EXISTS` operator in SQL is a Boolean operator that tests for the existence of any rows in a subquery. The `EXISTS` clause evaluates to a Boolean (TRUE or FALSE); it does not return data from the subquery - it checks for the existence of at least one matching row. The `EXISTS` can be used with the `IF`, `WHERE`, and `ON` clauses.  The `EXISTS` operator can also be used with the `NOT` operator for negation.

This document will concentrate on the `EXISTS` statement with the `ON` clause.  Strangely, I cannot find any documentation from Microsoft or PostgreSQL on the use of `ON EXISTS`.  Itzik Ben-Gan does mention it in passing in an article [here](https://sqlperformance.com/2019/12/t-sql-queries/null-complexities-part-1) about its usage, and he does mention it in the [T-SQL Fundamentals](https://www.amazon.com/T-SQL-Fundamentals-3rd-Itzik-Ben-Gan/dp/150930200X/ref=sr_1_1?adgrpid=1331509151302817&hvadid=83219393942729&hvbmt=be&hvdev=c&hvlocphy=66021&hvnetw=o&hvqmt=e&hvtargid=kwd-83219680138630%3Aloc-190&hydadcr=16377_10417921&keywords=t-sql+fundamentals&qid=1675204165&sr=8-1) book.

First, let's look at some examples of the `EXISTS`.  It is important to remember that the `EXISTS` clause returns TRUE or FALSE and not a result set.

--------------------------------------------------------------------------------

### Sample Data

We will be using the following tables, which contain types of fruits and their quantities.  

[The DDL to create these tables can be found here.](Sample%20Data.md)

**Table A**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  |       17 |
|  2 | Peach  |       20 |
|  3 | Mango  |       11 |
|  4 |        |        5 |
  
**Table B**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  | 17       |
|  2 | Peach  | 25       |
|  3 | Kiwi   | 20       |
|  4 |        |          |

----

### IF EXISTS

Here is an example of using `EXISTS` with `IF` to check whether records exist.  

This statement will return TRUE, as there are records in `TableA`.

```sql
IF EXISTS (SELECT 1 FROM ##TableA)
PRINT 'TRUE'
ELSE
PRINT 'FALSE'
```

This statement will return FALSE if we use the `NOT` operator.

```sql
IF NOT EXISTS (SELECT 1 FROM ##TableA)
PRINT 'TRUE'
ELSE
PRINT 'FALSE'
```

This statement will return TRUE when we supply a NULL marker.  Even though we provide a NULL marker, it still returns a record set with a NULL marker, which is different from an empty record set.

```sql
IF EXISTS (SELECT NULL)
PRINT 'TRUE'
ELSE
PRINT 'FALSE'
```


--------------------------------------------------------------
### EXISTS

Typically, we use the `EXISTS` operator with the `WHERE` clause to create a correlated subquery.

The query behaves like an `INNER JOIN` and returns only records from `TableA`.

```sql
SELECT  *
FROM    ##TableA a
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit)
ORDER BY 1;
```

| ID | Fruit | Quantity |
|----|-------|----------|
|  1 | Apple |       17 |
|  2 | Peach |       20 |

When we use negation (the `NOT` operator) with the `EXISTS` clause, we return the records in `TableA` but not in `TableB`.

```sql
SELECT  *
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit)
ORDER BY 1;
```

| ID | Fruit   | Quantity |
|----|---------|----------|
|  3 | Mango   |       11 |
|  4 |         |        5 |

  
--------------------------------------------------------------
### ON EXISTS
  
Probably one of the more difficult joins to understand is the `ON EXISTS` clause.  It is best to learn by example, and remember that `EXISTS` returns TRUE or FALSE, not a subset of records.  The `ON EXISTS` will work with the `INNER JOIN`, `LEFT OUTER JOIN`, `RIGHT OUTER JOIN`, and `FULL OUTER JOIN` clauses, but not the `CROSS JOIN`.

This query evaluates whether `a.Fruit` exists in the result set of `b.Fruit`, effectively acting like an equality join on Fruit, but also matching NULL markers (since `INTERSECT` treats NULL as not distinct from NULL). These statements will return TRUE and behave like a `CROSS JOIN`.
  
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
ORDER BY 1, 4;
```    

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 1  | Apple   | 17       |
| 1  | Apple   | 17       | 2  | Peach   | 25       |
| 1  | Apple   | 17       | 3  | Kiwi    | 20       |
| 1  | Apple   | 17       | 4  |         |          |
| 2  | Peach   | 20       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 2  | Peach   | 25       |
| 2  | Peach   | 20       | 3  | Kiwi    | 20       |
| 2  | Peach   | 20       | 4  |         |          |
| 3  | Mango   | 11       | 1  | Apple   | 17       |
| 3  | Mango   | 11       | 2  | Peach   | 25       |
| 3  | Mango   | 11       | 3  | Kiwi    | 20       |
| 3  | Mango   | 11       | 4  |         |          |
| 4  |         | 5        | 1  | Apple   | 17       |
| 4  |         | 5        | 2  | Peach   | 25       |
| 4  |         | 5        | 3  | Kiwi    | 20       |
| 4  |         | 5        | 4  |         |          |

----------------------------------------------------

### Example 1

From our previous SQL statement, we can see that the `INNER JOIN` acts like a `CROSS JOIN`.  Now, let’s add a more practical use of the `ON EXISTS`.

This query will return all the rows of `TableA` and `TableB` where the values of column `Fruit` are the same in both tables, and the columns of both tables will be included in the result set. The query will include rows from `TableA` where the `Fruit` value exists in `TableB`.  
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT a.Fruit INTERSECT SELECT b.Fruit)
ORDER BY 1;
```

| ID | Fruit   | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
|  1 | Apple   | 17       | 1  | Apple   | 17       |
|  2 | Peach   | 20       | 2  | Peach   | 25       |
|  4 |         | 5        | 4  |         |          |

  
A similar statement to the above would be the following, which explicitly handles NULL markers.

```sql
SELECT  *
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   ISNULL(a.Fruit,'') = ISNULL(b.Fruit,'')
ORDER BY 1;
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
|  1 | Apple   | 17       | 1  | Apple   | 17       |
|  2 | Peach   | 20       | 2  | Peach   | 25       |
|  4 |         | 5        | 4  |         |          |
  
  
We can also apply De Morgan's law and use the `NOT EXISTS` and the `EXCEPT` operators.
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON NOT EXISTS(SELECT a.Fruit EXCEPT SELECT b.Fruit)
ORDER BY 1;
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
|  1 | Apple   | 17       | 1  | Apple   | 17       |
|  2 | Peach   | 20       | 2  | Peach   | 25       |
|  4 |         | 5        | 4  |         |          |
  

-----------------------------------------------------------------------------------------
  
### Example 2

If we replace `INTERSECT` with `EXCEPT`, we get the following.
  
This query will return all the rows of `TableA` and `TableB` where the values of column `Fruit` are different in both tables, and the columns of both tables will be included in the result set. The query will exclude rows from `TableA` where the `Fruit` value exists in `TableB`.  
  
```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT a.Fruit EXCEPT SELECT b.Fruit)
ORDER BY 1, 4;
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 2  | Peach   | 25       |
| 1  | Apple   | 17       | 3  | Kiwi    | 20       |
| 1  | Apple   | 17       | 4  |         |          |
| 2  | Peach   | 20       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 3  | Kiwi    | 20       |
| 2  | Peach   | 20       | 4  |         |          |
| 3  | Mango   | 11       | 1  | Apple   | 17       |
| 3  | Mango   | 11       | 2  | Peach   | 25       |
| 3  | Mango   | 11       | 3  | Kiwi    | 20       |
| 3  | Mango   | 11       | 4  |         |          |
| 4  |         | 5        | 1  | Apple   | 17       |
| 4  |         | 5        | 2  | Peach   | 25       |
| 4  |         | 5        | 3  | Kiwi    | 20       |

Note that the above set is missing the following.

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 2  | Peach   | 25       |
| 4  |         | 5        | 4  |         |          |
 
The equivalent statement for this is below.
  
```sql
SELECT  *
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   NOT(ISNULL(a.Fruit,'') = ISNULL(b.Fruit,''))
ORDER BY 1, 4;
```
  
| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 2  | Peach   | 25       |
| 1  | Apple   | 17       | 3  | Kiwi    | 20       |
| 1  | Apple   | 17       | 4  |         |          |
| 2  | Peach   | 20       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 3  | Kiwi    | 20       |
| 2  | Peach   | 20       | 4  |         |          |
| 3  | Mango   | 11       | 1  | Apple   | 17       |
| 3  | Mango   | 11       | 2  | Peach   | 25       |
| 3  | Mango   | 11       | 3  | Kiwi    | 20       |
| 3  | Mango   | 11       | 4  |         |          |
| 4  |         | 5        | 1  | Apple   | 17       |
| 4  |         | 5        | 2  | Peach   | 25       |
| 4  |         | 5        | 3  | Kiwi    | 20       |

  
De Morgan's Law is in effect, and you can accomplish the above with the `NOT EXISTS` and the `INTERSECT` statements.

```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON NOT EXISTS(SELECT a.Fruit INTERSECT SELECT b.Fruit)
ORDER BY 1, 4;
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
| 1  | Apple   | 17       | 2  | Peach   | 25       |
| 1  | Apple   | 17       | 3  | Kiwi    | 20       |
| 1  | Apple   | 17       | 4  |         |          |
| 2  | Peach   | 20       | 1  | Apple   | 17       |
| 2  | Peach   | 20       | 3  | Kiwi    | 20       |
| 2  | Peach   | 20       | 4  |         |          |
| 3  | Mango   | 11       | 1  | Apple   | 17       |
| 3  | Mango   | 11       | 2  | Peach   | 25       |
| 3  | Mango   | 11       | 3  | Kiwi    | 20       |
| 3  | Mango   | 11       | 4  |         |          |
| 4  |         | 5        | 1  | Apple   | 17       |
| 4  |         | 5        | 2  | Peach   | 25       |
| 4  |         | 5        | 3  | Kiwi    | 20       |
  
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
