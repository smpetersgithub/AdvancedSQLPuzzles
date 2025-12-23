# FULL OUTER JOIN

A `FULL OUTER JOIN` returns all rows from both tables, including unmatched rows from each side. Where a match does not exist, the result will contain NULL markers for the columns from the non-matching table.

Although less commonly used than `INNER JOIN` or `LEFT JOIN`, `FULL OUTER JOIN` is especially useful when you want a complete comparison between two related datasets—such as identifying what rows are missing or different between them.

---------------------------------------------------------------------------------

We will use the following tables, which contain types of fruits and their quantities.  

[The DDL to create these tables can be found here.](Sample%20Data.md)

**Table A**
| ID |  Fruit  | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 20       |
| 3  | Mango   | 11       |
| 4  |         | 5        |

**Table B**
| ID |  Fruit  | Quantity  |
|----|---------|-----------|
| 1  | Apple   | 17        |
| 2  | Peach   | 25        |
| 3  | Kiwi    | 20        |
| 4  |         |           |
        

---------------------------------------------------------------------------------

The following shows the contents of fruits in both `TableA` and `TableB`.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
ORDER BY 1;
```

|    ID   |  Fruit  |    ID   |  Fruit  |
|---------|---------|---------|---------|
|         |         | 3       | Kiwi    |
|         |         | 4       |         |
| 1       | Apple   | 1       | Apple   |
| 2       | Peach   | 2       | Peach   |
| 3       | Mango   |         |         |
| 4       |         |         |         |

---------------------------------------------------------------------------------
  
You can use a `FULL OUTER JOIN` to find the symmetric difference of two datasets using the `ISNULL` function.

This query returns the symmetric difference between `TableA` and `TableB` — rows that exist in one table but not the other. Using `ISNULL()` ensures values from either side appear in a unified result, even when one side is NULL.
 
```sql 
SELECT  ISNULL(a.ID, b.ID) AS ID,
        ISNULL(a.Fruit, b.Fruit) AS Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.ID IS NULL OR B.ID IS NULL
ORDER BY 1, 2;
```
  
|   ID   |  Fruit  |
|--------|---------|
| 3      | Mango   |
| 3      | Kiwi    |
| 4      |         |
| 4      |         |
  
---------------------------------------------------------------------------------
  
You can simulate an `INNER JOIN` by placing the following predicate logic in the `WHERE` clause
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.ID IS NOT NULL AND b.ID IS NOT NULL
ORDER BY 1, 2;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |

---------------------------------------------------------------------------------
        
If `FULL OUTER JOIN` is unavailable or unsupported, you can simulate it using a combination of `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, and `NOT EXISTS` with `UNION`. This approach ensures all matching and unmatched rows from both tables are included.

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
WHERE   NOT EXISTS (SELECT 1 FROM ##TableA b WHERE a.Fruit = b.Fruit)
ORDER BY 1, 2;
```        
 
|   ID    |  Fruit  |    ID   |  Fruit  |
|---------|---------|---------|---------|
|         |         | 3       | Kiwi    |
|         |         | 4       |         |
| 1       | Apple   | 1       | Apple   |
| 2       | Peach   | 2       | Peach   |
| 3       | Mango   |         |         |
| 4       |         |         |         |

---------------------------------------------------------------------------------

You can also use the `LEFT OUTER JOIN` and a `RIGHT OUTER JOIN` to simulate the `FULL OUTER JOIN`.
        
This may be the only case where a `LEFT OUTER JOIN` and a `RIGHT OUTER JOIN` can be used in the same SQL statement, as it preserves the column and table orders between the two statements.
     
```sql
SELECT  a.ID, a.Fruit, b.ID, b.Fruit
FROM    ##TableA a LEFT JOIN 
        ##TableB b ON a.Fruit = b.Fruit
UNION
SELECT  a.ID, a.Fruit, b.ID, b.Fruit
FROM    ##TableA a RIGHT JOIN 
        ##TableB b ON a.Fruit = b.Fruit
ORDER BY 1, 2;
```

|    ID   |  Fruit  |    ID   |  Fruit  |
|---------|---------|---------|---------|
|         |         | 3       | Kiwi    |
|         |         | 4       |         |
| 1       | Apple   | 1       | Apple   |
| 2       | Peach   | 2       | Peach   |
| 3       | Mango   |         |         |
| 4       |         |         |         |

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
