## FULL OUTER JOIN

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A FULL OUTER JOIN is a method of combining tables so that the result includes unmatched rows of both tables. It is an often underutilized join that has a more specific use case than the other joins.  This join is best used to compare two similar tables as shown below.  Remember to use this type of join when you want to compare two shopping baskets.

----

The following shows the contents of fruits in both Table A and Table B.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit;
```

| ID     | Fruit  | ID     | Fruit  |
|--------|--------|--------|--------|
| 1      | Apple  | 1      | Apple  |
| 2      | Peach  | 2      | Peach  |
| 3      | Mango  | <NULL> | <NULL> |
| 4      | <NULL> | <NULL> | <NULL> |
| <NULL> | <NULL> | 3      | Kiwi   |
| <NULL> | <NULL> | 4      | <NULL> |

---
  
You can use a FULL OUTER JOIN to find the symetric difference of two datasets using the ISNULL function.

This SQL statement returns the records that are in Table A but not in Table B along with the records in Table B that are not in Table A.  This is known in set theory as the symetric difference.  The result set will include two NULL markers as NULLs are neither equal to nor not equal to each other, they are unkown.
 
```sql 
SELECT  ISNULL(a.ID, b.ID) AS ID,
        ISNULL(a.Fruit, b.Fruit) AS Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.ID IS NULL OR B.ID IS NULL;
```
  
|   ID   | Fruit  |
|--------|--------|
| 3      | Mango  |
| 4      | <NULL> |
| 3      | Kiwi   |
| 4      | <NULL> |
  
---
  
You can simulate an INNER JOIN by placing the following predicate logic in the WHERE clause
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.ID IS NOT NULL AND B.ID IS NOT NULL;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
|  1 | Apple |  1 | Apple |
|  2 | Peach |  2 | Peach |

---

You can simulate FULL OUTER JOINs using set operators (UNION) and anti-joins (NOT EXISTS).
        
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
 
| ID     | Fruit  | ID     | Fruit  |
|--------|--------|--------|--------|
| 1      | Apple  | 1      | Apple  |
| 2      | Peach  | 2      | Peach  |
| 3      | Mango  | <NULL> | <NULL> |
| 4      | <NULL> | <NULL> | <NULL> |
| <NULL> | <NULL> | 3      | Kiwi   |
| <NULL> | <NULL> | 4      | <NULL> |

---

You can also use the LEFT OUTER JOIN and a RIGHT OUTER JOIN to simulate the FULL OUTER JOIN.
        
This may be the only case where a LEFT OUTER JOIN and a RIGHT OUTER JOIN can be used in the same SQL statement as it preservers the column and table orders between the two unioned statements.
     
```sql
SELECT  a.ID, b.Fruit, b.ID, b.Fruit
FROM    ##TableA a LEFT JOIN 
        ##TableB b ON a.Fruit = b.Fruit
UNION
SELECT  a.ID, b.Fruit, b.ID, b.Fruit
FROM    ##TableA a RIGHT JOIN 
        ##TableB b ON a.Fruit = b.Fruit;
```

| ID     | Fruit  | ID     | Fruit  |
|--------|--------|--------|--------|
| 1      | Apple  | 1      | Apple  |
| 2      | Peach  | 2      | Peach  |
| 3      | Mango  | <NULL> | <NULL> |
| 4      | <NULL> | <NULL> | <NULL> |
| <NULL> | <NULL> | 3      | Kiwi   |
| <NULL> | <NULL> | 4      | <NULL> |
        
---        
Up next is CROSS JOIN.
  
Happy coding!
