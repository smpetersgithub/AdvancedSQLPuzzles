# FULL OUTER JOIN

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A `FULL OUTER JOIN` is a method of combining tables so that the result includes unmatched rows of both tables. It is an often-underutilized join with a more specific use case than the other joins.  This join best compares two similar tables, as shown below.

---------------------------------------------------------------------------------

We will use the following tables that contain types of fruits and their quantity.  

[The DDL to create these tables can be found here.](Sample%20Data.md)

**Table A**
| ID |  Fruit  | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 20       |
| 3  | Mango   | 11       |
| 4  | \<NULL> | 5        |
  
**Table B**
| ID |  Fruit  | Quantity  |
|----|---------|-----------|
| 1  | Apple   | 17        |
| 2  | Peach   | 25        |
| 3  | Kiwi    | 20        |
| 4  | \<NULL> | \<NULL>   |
        

---------------------------------------------------------------------------------

The following shows the contents of fruits in both `TableA` and `TableB`.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit;
```

|    ID   |  Fruit  |    ID   |  Fruit  |
|---------|---------|---------|---------|
| 1       | Apple   | 1       | Apple   |
| 2       | Peach   | 2       | Peach   |
| 3       | Mango   | \<NULL> | \<NULL> |
| 4       | \<NULL> | \<NULL> | \<NULL> |
| \<NULL> | \<NULL> | 3       | Kiwi    |
| \<NULL> | \<NULL> | 4       | \<NULL> |

---------------------------------------------------------------------------------
  
You can use a `FULL OUTER JOIN` to find the symmetric difference of two datasets using the `ISNULL` function.

This SQL statement returns the records that are in `TableA` but not in `TableB` along with the records in `TableB` that are not in `TableA`.  This is known in set theory as the symmetric difference.  The result set will include two NULL markers, as NULLs are neither equal to nor not equal to each other. They are unknown.
 
```sql 
SELECT  ISNULL(a.ID, b.ID) AS ID,
        ISNULL(a.Fruit, b.Fruit) AS Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.ID IS NULL OR B.ID IS NULL;
```
  
|   ID   |  Fruit  |
|--------|---------|
| 3      | Mango   |
| 4      | \<NULL> |
| 3      | Kiwi    |
| 4      | \<NULL> |
  
---------------------------------------------------------------------------------
  
You can simulate an `INNER JOIN` by placing the following predicate logic in the `WHERE` clause
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.ID IS NOT NULL AND b.ID IS NOT NULL;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |

---------------------------------------------------------------------------------
        
You can simulate a `FULL OUTER JOIN` by using set operators (`UNION`) and anti-joins (`NOT EXISTS`).
        
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit
UNION
SELECT  a.ID,
        a.Fruit,
        NULL,
        NULL
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit)
UNION
SELECT  NULL,
        NULL,
        a.ID,
        a.Fruit
FROM    ##TableB a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableA b WHERE a.Fruit = b.Fruit); 
```        
 
|   ID    |  Fruit  |    ID   |  Fruit  |
|---------|---------|---------|---------|
| 1       | Apple   | 1       | Apple   |
| 2       | Peach   | 2       | Peach   |
| 3       | Mango   | \<NULL> | \<NULL> |
| 4       | \<NULL> | \<NULL> | \<NULL> |
| \<NULL> | \<NULL> | 3       | Kiwi    |
| \<NULL> | \<NULL> | 4       | \<NULL> |

---------------------------------------------------------------------------------

You can also use the `LEFT OUTER JOIN` and a `RIGHT OUTER JOIN` to simulate the `FULL OUTER JOIN`.
        
This may be the only case where a `LEFT OUTER JOIN` and a `RIGHT OUTER JOIN` can be used in the same SQL statement as it preserves the column and table orders between the two statements.
     
```sql
SELECT  a.ID, b.Fruit, b.ID, b.Fruit
FROM    ##TableA a LEFT JOIN 
        ##TableB b ON a.Fruit = b.Fruit
UNION
SELECT  a.ID, b.Fruit, b.ID, b.Fruit
FROM    ##TableA a RIGHT JOIN 
        ##TableB b ON a.Fruit = b.Fruit;
```

|    ID   |  Fruit  |    ID   |  Fruit  |
|---------|---------|---------|---------|
| 1       | Apple   | 1       | Apple   |
| 2       | Peach   | 2       | Peach   |
| 3       | Mango   | \<NULL> | \<NULL> |
| 4       | \<NULL> | \<NULL> | \<NULL> |
| \<NULL> | \<NULL> | 3       | Kiwi    |
| \<NULL> | \<NULL> | 4       | \<NULL> |
        
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
