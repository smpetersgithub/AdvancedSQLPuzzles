# CROSS JOINS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In `Microsoft SQL Server`, there are two join functions for performing a cross join, `CROSS JOIN` and `CROSS APPLY`.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A `CROSS JOIN` creates all permutations (i.e., a cartesian product) of the two joining tables.  It will produce a result set which is the number of rows in the first table multiplied by the number of rows in the second table.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;It is important to be mindful of the number of rows in each table because a `CROSS JOIN` will return the product of the number of rows of both tables. If one table has 100 rows and the other has 1000 rows, a `CROSS JOIN` will return 100,000 rows. Therefore, `CROSS JOIN` can cause performance issues if used on large tables.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Note, you can also use recursion to generate permutation sets.  The benefit of using recursion is when you have an unknown number of elements you need to create permutations on, which you may not know at runtime.  With `CROSS JOIN`, you need to create each join manually.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Also of note is that in Microsoft SQL Server, there are two join functions for performing a cross join, `CROSS JOIN` and `CROSS APPLY`.  `CROSS JOIN` and `CROSS APPLY` will work when only dealing with tables, but `CROSS APPLY` will only work with table-valued functions and sub-queries, which I will demonstrate below.

#### Permutations vs Combinations

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Permutations and combinations are both ways of arranging a set of items, but they differ in how the items are arranged.  Permutations are arrangements of items in a specific order, while combinations are selections of items without regard to the order.

*  Permutations are a way of arranging a set of items in a specific order. For example, if you have the set of items {A, B, C}, there are 3! (3 factorial) or 6 possible permutations: ABC, ACB, BAC, BCA, CAB, CBA.

*  Combinations, conversely, are a way of selecting a subset of items from a set without regard to the order. For example, if you have the set of items {A, B, C}, there are 3 C 2 (read as "3 choose 2") or 3 possible combinations: AB, AC, BC.

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
| ID |  Fruit  |  Quantity |
|----|---------|-----------|
| 1  | Apple   | 17        |
| 2  | Peach   | 25        |
| 3  | Kiwi    | 20        |
| 4  | \<NULL> | \<NULL>   |
        

---------------------------------------------------------------------------------
### CROSS JOIN
  
Here is the simplest form of the `CROSS JOIN` that creates all permutations between two datasets.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b;
```

| ID |  Fruit  | ID |  Fruit  |
|----|---------|----|---------|
| 1  | Apple   | 1  | Apple   |
| 2  | Peach   | 1  | Apple   |
| 3  | Mango   | 1  | Apple   |
| 4  | \<NULL> | 1  | Apple   |
| 1  | Apple   | 2  | Peach   |
| 2  | Peach   | 2  | Peach   |
| 3  | Mango   | 2  | Peach   |
| 4  | \<NULL> | 2  | Peach   |
| 1  | Apple   | 3  | Kiwi    |
| 2  | Peach   | 3  | Kiwi    |
| 3  | Mango   | 3  | Kiwi    |
| 4  | \<NULL> | 3  | Kiwi    |
| 1  | Apple   | 4  | \<NULL> |
| 2  | Peach   | 4  | \<NULL> |
| 3  | Mango   | 4  | \<NULL> |
| 4  | \<NULL> | 4  | \<NULL> |


---------------------------------------------------------------------------------

You can simulate an `INNER JOIN` using a `CROSS JOIN` by placing the join logic in the `WHERE` clause using an equi-join
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   a.Fruit = b.Fruit;
```
  
| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |  
 

---------------------------------------------------------------------------------
  
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
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b where a.Fruit = b.Fruit);
```

| ID |  Fruit  |    ID   |  Fruit  |
|----|---------|---------|---------|
| 1  | Apple   | 1       |  Apple  |
| 2  | Peach   | 2       |  Peach  |
| 3  | Mango   | \<NULL> | \<NULL> |
| 4  | \<NULL> | \<NULL> | \<NULL> |


---------------------------------------------------------------------------------
  
The following produces all combinations (not permutations).
  
Given all fruits in both `TableA` and `TableB`, here is a result set of all fruit combinations.  Because of the theta-join in the `WHERE` clause, the fruits are listed in alphabetical order from left to right.  Note that NULL markers are not included in the result set, as NULL markers are not equal to each other, nor are they equal to each other. They are unknown.
  
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
                         
If you need to find reciprocals on a result set and preserve NULL markers, you can use the following `CASE` statement.
                         
```sql
SELECT  DISTINCT
        (CASE WHEN a.Fruit < b.Fruit THEN a.Fruit ELSE b.Fruit END) AS Fruit,
        (CASE WHEN a.Fruit < b.Fruit THEN b.Fruit ELSE a.Fruit END) AS Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   a.Fruit <> b.Fruit OR a.Fruit IS NULL OR b.Fruit IS NULL;
```

|  Fruit  |  Fruit  |
|---------|---------|
| \<NULL> | <NULL>  |
| \<NULL> | Apple   |
| \<NULL> | Mango   |
| \<NULL> | Peach   |
| Apple   | \<NULL> |
| Apple   | Kiwi    |
| Apple   | Mango   |
| Apple   | Peach   |
| Kiwi    | \<NULL> |
| Kiwi    | Mango   |
| Kiwi    | Peach   |
| Mango   | Peach   |
| Peach   | \<NULL> |

---------------------------------------------------------
  
### CROSS APPLY
  
In Microsoft SQL Server, the `CROSS APPLY` functions the same as `CROSS JOIN`.
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS APPLY
        ##TableB b;
```
  
| ID |  Fruit  | ID |  Fruit  |
|----|---------|----|---------|
| 1  | Apple   | 1  | Apple   |
| 2  | Peach   | 1  | Apple   |
| 3  | Mango   | 1  | Apple   |
| 4  | \<NULL> | 1  | Apple   |
| 1  | Apple   | 2  | Peach   |
| 2  | Peach   | 2  | Peach   |
| 3  | Mango   | 2  | Peach   |
| 4  | \<NULL> | 2  | Peach   |
| 1  | Apple   | 3  | Kiwi    |
| 2  | Peach   | 3  | Kiwi    |
| 3  | Mango   | 3  | Kiwi    |
| 4  | \<NULL> | 3  | Kiwi    |
| 1  | Apple   | 4  | \<NULL> |
| 2  | Peach   | 4  | \<NULL> |
| 3  | Mango   | 4  | \<NULL> |
| 4  | \<NULL> | 4  | \<NULL> |


---------------------------------------------------------
  
The `CROSS APPLY` is used when joining to a table-valued function.  Here is an example from my Calendar Table example located [here.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/blob/main/Database%20Tips%20and%20Tricks/Calendar%20Table/FnReturnCalendarTable%20Example%20Use.sql)
  
This performs an `INNER JOIN` as the join logic is placed in the `WHERE` clause of the SQL statement.
  
```
  --Create a view
CREATE OR ALTER VIEW dbo.VwCalendarTable AS
SELECT  ct.*
FROM    CalendarDaysTemp cd CROSS APPLY
        dbo.FnReturnCalendarTable(cd.CalendarDate) ct
WHERE   cd.DateKey = ct.DateKey;
```  
---------------------------------------------------------  
 
If you need to do a `CROSS JOIN` on a sub-query, the `CROSS APPLY` operator must be used.  Some databases like `PostgreSQL` have the `LATERAL` join instead of `CROSS APPLY`.
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS APPLY
        (SELECT * FROM ##TableB) b
WHERE   a.Fruit = b.Fruit;
```
  
| ID |  Fruit  | ID |  Fruit  |
|----|---------|----|---------|
| 1  | Apple   | 1  | Apple   |
| 2  | Peach   | 1  | Apple   |
| 3  | Mango   | 1  | Apple   |
| 4  | \<NULL> | 1  | Apple   |
| 1  | Apple   | 2  | Peach   |
| 2  | Peach   | 2  | Peach   |
| 3  | Mango   | 2  | Peach   |
| 4  | <NULL>  | 2  | Peach   |
| 1  | Apple   | 3  | Kiwi    |
| 2  | Peach   | 3  | Kiwi    |
| 3  | Mango   | 3  | Kiwi    |
| 4  | \<NULL> | 3  | Kiwi    |
| 1  | Apple   | 4  | \<NULL> |
| 2  | Peach   | 4  | \<NULL> |
| 3  | Mango   | 4  | \<NULL> |
| 4  | \<NULL> | 4  | \<NULL> |
  
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
