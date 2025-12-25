# CROSS JOINS

SQL Server provides two ways to perform cross joins: `CROSS JOIN` and `CROSS APPLY`. While both can produce Cartesian products, they differ in their use cases and behavior.

`CROSS JOIN` generates a Cartesian product between two tables—every row in the first table is combined with every row in the second. If Table A has 100 rows and Table B has 1,000 rows, the result will contain 100,000 rows.

`CROSS APPLY` can also be used to perform a cross join–like operation, but it is more powerful: it allows joining each row to a table-valued function or subquery that can vary per row.

⚠️ Be cautious: both join types can produce large result sets and may impact performance when used on large datasets.

### Permutations vs Combinations

Permutations and combinations are common patterns when using `CROSS JOIN`:

*  Permutations involve arranging items in order. For example, with {A, B, C}, permutations include: ABC, ACB, BAC, etc. A `CROSS JOIN` is often used to generate these.
*  Combinations involve selecting subsets without considering order. From {A, B, C}, the 2-item combinations are AB, AC, and BC.

---------------------------------------------------------------------------------

### Sample Data 
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
| ID |  Fruit  |  Quantity |
|----|---------|-----------|
| 1  | Apple   | 17        |
| 2  | Peach   | 25        |
| 3  | Kiwi    | 20        |
| 4  |         |           |
        

---------------------------------------------------------------------------------
### CROSS JOIN
  
Here is the simplest form of the `CROSS JOIN` that creates all permutations between two datasets.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b
ORDER BY 3, 1;
```

| ID |  Fruit  | ID |  Fruit  |
|----|---------|----|---------|
| 1  | Apple   | 1  | Apple   |
| 2  | Peach   | 1  | Apple   |
| 3  | Mango   | 1  | Apple   |
| 4  |         | 1  | Apple   |
| 1  | Apple   | 2  | Peach   |
| 2  | Peach   | 2  | Peach   |
| 3  | Mango   | 2  | Peach   |
| 4  |         | 2  | Peach   |
| 1  | Apple   | 3  | Kiwi    |
| 2  | Peach   | 3  | Kiwi    |
| 3  | Mango   | 3  | Kiwi    |
| 4  |         | 3  | Kiwi    |
| 1  | Apple   | 4  |         |
| 2  | Peach   | 4  |         |
| 3  | Mango   | 4  |         |
| 4  |         | 4  |         |


---------------------------------------------------------------------------------
### Simulating an INNER JOIN

You can simulate an `INNER JOIN` using a `CROSS JOIN` by placing the join logic in the `WHERE` clause using an equi-join
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   a.Fruit = b.Fruit
ORDER BY 1;
```
  
| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |  
 

---------------------------------------------------------------------------------
### Simulating a LEFT OUTER JOIN

To simulate a `LEFT OUTER JOIN` using a `CROSS JOIN`, you will need to incorporate set operators (`UNION`) and an anti-join (`NOT EXISTS`).  

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS JOIN 
        ##TableB b
WHERE   a.Fruit = b.Fruit
UNION
SELECT  a.ID,
        a.Fruit,
        NULL,
        NULL
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b where a.Fruit = b.Fruit)
ORDER BY 1;
```

| ID |  Fruit  |    ID   |  Fruit  |
|----|---------|---------|---------|
| 1  | Apple   | 1       |  Apple  |
| 2  | Peach   | 2       |  Peach  |
| 3  | Mango   |         |         |
| 4  |         |         |         |


---------------------------------------------------------------------------------

### Determining Combinations

The following produces all combinations (not permutations).
  
Given all fruits in both `TableA` and `TableB`, here is a result set of all fruit combinations.  Because of the theta-join in the `WHERE` clause, the fruits are listed in alphabetical order from left to right.  Note that NULL markers are not included in the result set, as NULL markers are neither equal to nor not equal to each other. They are unknown.
  
```sql
WITH cte_DistinctFruits as
(
SELECT Fruit FROM ##TableA
UNION
SELECT Fruit FROM ##TableB
)
SELECT
        a.Fruit,
        b.Fruit
FROM    cte_DistinctFruits a CROSS JOIN
        cte_DistinctFruits b
WHERE   a.Fruit < b.Fruit
ORDER BY 1, 2;
```                          

| Fruit | Fruit |
|-------|-------|
| Apple | Kiwi  |
| Apple | Mango |
| Apple | Peach |
| Kiwi  | Mango |
| Kiwi  | Peach |
| Mango | Peach |
                        
---------------------------------------------------------------------------------

### Reciprocals
                         
If you need to find reciprocals on a result set and preserve NULL markers, you can use the following `CASE` statement.
                         
```sql
SELECT  DISTINCT
        (CASE WHEN a.Fruit < b.Fruit THEN a.Fruit ELSE b.Fruit END) AS Fruit,
        (CASE WHEN a.Fruit < b.Fruit THEN b.Fruit ELSE a.Fruit END) AS Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   a.Fruit <> b.Fruit OR a.Fruit IS NULL OR b.Fruit IS NULL
ORDER BY 1, 2;
```

|  Fruit  |  Fruit  |
|---------|---------|
|         |         |
|         | Apple   |
|         | Mango   |
|         | Peach   |
| Apple   |         |
| Apple   | Kiwi    |
| Apple   | Mango   |
| Apple   | Peach   |
| Kiwi    |         |
| Kiwi    | Mango   |
| Kiwi    | Peach   |
| Mango   | Peach   |
| Peach   |         |

---------------------------------------------------------
  
### CROSS APPLY
  
In Microsoft SQL Server, the `CROSS APPLY` functions the same as `CROSS JOIN`.
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS APPLY
        ##TableB b
ORDER BY 3, 1;
```
  
| ID |  Fruit  | ID |  Fruit  |
|----|---------|----|---------|
| 1  | Apple   | 1  | Apple   |
| 2  | Peach   | 1  | Apple   |
| 3  | Mango   | 1  | Apple   |
| 4  |         | 1  | Apple   |
| 1  | Apple   | 2  | Peach   |
| 2  | Peach   | 2  | Peach   |
| 3  | Mango   | 2  | Peach   |
| 4  |         | 2  | Peach   |
| 1  | Apple   | 3  | Kiwi    |
| 2  | Peach   | 3  | Kiwi    |
| 3  | Mango   | 3  | Kiwi    |
| 4  |         | 3  | Kiwi    |
| 1  | Apple   | 4  |         |
| 2  | Peach   | 4  |         |
| 3  | Mango   | 4  |         |
| 4  |         | 4  |         |


---------------------------------------------------------

### CROSS APPLY with TVFs

The `CROSS APPLY` is used when joining to a table-valued function.

This performs an `INNER JOIN` as the join logic is placed in the `WHERE` clause of the SQL statement.

```sql
  --Create a view
CREATE OR ALTER VIEW dbo.VwCalendarTable AS
SELECT  ct.*
FROM    CalendarDaysTemp cd CROSS APPLY
        dbo.FnReturnCalendarTable(cd.CalendarDate) ct
WHERE   cd.DateKey = ct.DateKey;
```  
---------------------------------------------------------

#### CROSS APPLY with a sub-query

If you need to do a `CROSS JOIN` on a sub-query, the `CROSS APPLY` operator must be used.  Some databases like `PostgreSQL` have the `LATERAL` join instead of `CROSS APPLY`.
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS APPLY
        (SELECT * FROM ##TableB) b
WHERE   a.Fruit = b.Fruit
ORDER BY 1;
```
  
| ID |  Fruit  | ID |  Fruit  |
|----|---------|----|---------|
| 1  | Apple   | 1  | Apple   |
| 2  | Peach   | 2  | Peach   |
  
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
