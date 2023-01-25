## FULL OUTER JOIN

A FULL OUTER JOIN is a method of combining tables so that the result includes unmatched rows of both tables. It is an often underutilized join that has a more specific use case than the other joins.  This join is best used to compare two similar tables as shown below.  Remember to use this type of join when you want to compare two shopping baskets.

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

This SQL statement returns the records that are in Table A but not in Table B, and the records in TAble B that are not in Table A.  This query returns two NULL markers as NULLs are neither equal to or not equal to each other, they are unkown.
 
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
  
Up next is CROSS JOIN.
  
Happy coding!
  
  

  
