# Semi and Anti-Joins

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Semi and anti-joins are two types of join operations used in SQL.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The term "semi", meaning half in quantity or value, refers to the fact that a semi-join only returns a subset (or a half) of the tables involved in the join.  Specifically, semi-joins only returns the rows from the first table (the left table) that have matching values in the second table (the right table). The columns of the right table are not included in the projection.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The opposite of semi-joins are anti-joins, which look for inequality between the two sets, i.e., the left and right tables.

*  Anti-joins use the **NOT IN** or **NOT EXISTS** operators in the WHERE clause of an SQL statement.    
*  Semi-joins use the **IN** or **EXISTS** operators in the WHERE clause of an SQL statement.

---

**For a join to be considered a semi or anti-join it must have the following three qualities:**

1)	The join cannot create duplicate rows from the outer table.
2)	The joining table cannot be used in the queries projection (SELECT statement).
3)	The join predicate looks for equality (=) or in-equality (<>) and not a range (<, >, etc.).

---

**There are several benefits of using anti-joins and semi-joins over INNER joins:**

*  Semi-joins and anti-joins remove the risk of returning duplicate rows.
*  Semi-joins and anti-joins increase readability as the result set can only contain the columns from the outer semi-joined table.

---

**Semi-joins and anti-joins have some key differences and considerations.**

*  One difference is how they handle NULL markers. The **NOT IN** operator returns an empty set if the anti-join contains a NULL marker, whereas the **NOT EXISTS** operator implicitly handles NULL markers and it will not affect the result set.
*  Another difference is that the **NOT EXISTS** and **EXIST** operators are correlated subqueries, meaning they must have a specified column to join between the outer and inner SQL statements, whereas the **IN** and **NOT IN** operators can contain a list of values and do not require a SELECT statement.
*  Additionally, the **IN** and **NOT IN** operators search for values in the result set of a subquery, whereas the **EXISTS** and **NOT EXISTS** operators check for the existence of rows.
*  If you are performing an anti-join to a NULLable column in the inner query, consider using the **NOT EXISTS** operator over the **NOT** operator.
*  When using semi or anti-joins, check execution plans for the most optimized usage method.  Becaue the **IN** and **NOT IN** operators check for values, and the **EXISTS** and **NOT EXISTS** check for rows, you will get two entirely different execution plans.

----------------------------------------------------------------------------------------

#### Semi-Joins

The **IN** operator is typically used to filter a column for a certain list of values.  Even though we include a NULL marker in the inner query, the results do not include a NULL marker.

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN ('Apple','Peach',NULL);
```

| ID | Fruit |
|----|-------|
|  1 | Apple |
|  2 | Peach |

----------------------------------------------------------------------------------------

Using the **IN** operator, this query will return results but does not return a NULL marker even though there is both a NULL marker in Table A and Table B.  The **NOT IN** operator treats NULL markers as neither equal to nor unequal to each other, they are unknown. 

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN (SELECT Fruit FROM ##TableB);
```

| ID | Fruit |
|----|-------|
|  1 | Apple |
|  2 | Peach |

----------------------------------------------------------------------------------------

Using the **IN** operator, you can also join the outer and inner SELECT statements creating a correlated subquery.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a
WHERE   Fruit IN (SELECT Fruit FROM ##TableB b WHERE a.Quantity = b.Quantity);
```

| ID | Fruit |
|----|-------|
|  1 | Apple |

----------------------------------------------------------------------------------------

The **EXISTS** operator is used to test for the existence of any record in a subquery. The **EXISTS** operator returns TRUE if the subquery returns one or more records and the **EXISTS** operator treats NULL markers as neither equal to nor unequal to each other, they are unknown. 

Because it checks for the existence of rows, you do not need to include any columns in the SELECT statment.  It is considered best practice to simply place an arbitarary "1" in this spot.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a 
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);
```

| ID | Fruit |
|----|-------|
|  1 | Apple |
|  2 | Peach |

----------------------------------------------------------------------------------------

#### Anti-Joins

This statement returns an empty dataset as the **NOT IN** operator will return an empty set if the outer query contains a NULL marker.

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB)
        OR
        Fruit NOT IN (NULL);
```
Empty Data Set

----------------------------------------------------------------------------------------

The **NOT EXISTS** operator handles NULL markers implicitly and will return a result set with a NULL marker.  The **NOT EXISTS** operator treats NULL markers as neither equal to nor unequal to each other, they are unknown. 

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);
```

| ID | Fruit  |
|----|--------|
|  3 | Mango  |
|  4 | <NULL> |

----------------------------------------------------------------------------------------
  
Up next is....

Happy coding!
