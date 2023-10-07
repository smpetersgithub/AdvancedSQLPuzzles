# Semi and Anti-Joins

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Semi and anti-joins are two types of join operations used in SQL.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The term "semi", meaning half in quantity or value, refers to the fact that a semi-join only returns a subset (or a half) of the tables involved in the join.  Specifically, semi-joins only returns the rows from the first table (the left table) that have matching values in the second table (the right table). The columns of the right table are not included in the projection.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The opposite of semi-joins are anti-joins, which look for inequality between the two sets, i.e., the left and right tables.

*  Anti-joins use the `NOT IN` or `NOT EXISTS` operators in the WHERE clause of an SQL statement.    
*  Semi-joins use the `IN` or `EXISTS` operators in the `WHERE` clause of an SQL statement.

---

For a join to be considered a semi or anti-join it must have the following three qualities:

1)	The join cannot create duplicate rows from the outer table.
2)	The joining table cannot be used in the query projection (`SELECT` statement).
3)	The join predicate looks for equality (=) or in-equality (<>) and not a range (<, >, etc.).

---

There are several benefits of using anti-joins and semi-joins over `INNER JOINS`:

*  Semi-joins and anti-joins remove the risk of returning duplicate rows.
*  Semi-joins and anti-joins increase readability as the result set only contains the columns from the outer semi-joined table.

---

Semi-joins and anti-joins have some key differences and considerations.

*  One difference is how they handle NULL markers. The `NOT IN` operator returns an empty set if the anti-join contains a NULL marker, whereas the `NOT EXISTS` operator implicitly handles NULL markers and it will not affect the result set.
*  Another difference is that the `NOT EXISTS` and `EXIST` operators are best used as correlated subqueries, meaning they have a specified column to join between the outer and inner SQL statements, whereas the `IN` and `NOT IN` operators can contain a list of values and do not require a `SELECT` statement or for the statement to be correlated.
*  Additionally, the `IN` and `NOT IN` operators search for values in the result set of a subquery, whereas the `EXISTS` and `NOT EXISTS` operators check for the existence of rows.
*  If performing an anti-join to a NULLable column in the inner query, consider using the `NOT EXISTS` operator over the `NOT` operator.
*  When using semi or anti-joins, check execution plans for the most optimized usage method.  Because the `IN` and `NOT IN` operators check for values, and the `EXISTS` and `NOT EXISTS` check for rows, you will get two entirely different execution plans.

----------------------------------------------------------------------------------------

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
| ID | Fruit   | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 25       |
| 3  | Kiwi    | 20       |
| 4  | \<NULL> | \<NULL>  |
        
----------------------------------------------------------------------------------------
        
#### Semi-Joins

The `IN` operator is typically used to filter a column for a certain list of values.  Even though we include a NULL marker in the inner query, the results do not include a NULL marker.

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN ('Apple','Peach',NULL);
```

| ID | Fruit |
|----|-------|
| 1  | Apple |
| 2  | Peach |

----------------------------------------------------------------------------------------

Using the `IN` operator, this query will return results but does not return a NULL marker even though there is both a NULL marker in `##TableA` and `##TableB`.  The `NOT IN` operator treats NULL markers as neither equal to nor unequal to each other, they are unknown. 

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN (SELECT Fruit FROM ##TableB);
```

| ID | Fruit |
|----|-------|
| 1  | Apple |
| 2  | Peach |

----------------------------------------------------------------------------------------

Using the `IN` operator, you can join the outer and inner `SELECT` statements, creating a correlated subquery.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a
WHERE   Fruit IN (SELECT Fruit FROM ##TableB b WHERE a.Quantity = b.Quantity);
```

| ID | Fruit |
|----|-------|
| 1  | Apple |

----------------------------------------------------------------------------------------

The `EXISTS` operator is used to test for the existence of any record in a subquery. The `EXISTS` operator returns TRUE if the subquery returns one or more records, and the `EXISTS` operator treats NULL markers as neither equal to nor unequal to each other, they are unknown. 

Because it checks for the existence of rows, you do not need to include any columns in the `SELECT` statement. It is considered best practice to place an arbitrary "1" in this spot simply.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a 
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);
```

| ID | Fruit |
|----|-------|
| 1  | Apple |
| 2  | Peach |

----------------------------------------------------------------------------------------

Be aware that when using correlated subqueries without a join condition, they will always evaluate to true. In the following SQL example, the subquery returns NULL but isn't joined to the main query. Despite the `NOT EXISTS (SELECT NULL)`, the query retrieves all rows from `##TableA` because the subquery will always be true without a join condition.

```sql
SELECT  *
FROM    ##TableA
WHERE   EXISTS (SELECT NULL);
```

| ID |  Fruit  | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 20       |
| 3  | Mango   | 11       |  
| 4  | \<NULL> | 5        |

----------------------------------------------------------------------------------------

Be cautious using the `IN` operator, as it can lead to unexpected behavior!

In this example, I use two table variables for demonstration.

In the SQL snippet below, you might anticipate that the inner `SELECT` statement would produce an error since `Column_AAA` doesn't exist in `@Table2`. However, this query runs without issue and updates `@Table1`, setting `Column_AAA` to 3. This is because Microsoft SQL Server treats it as a correlated subquery. To trigger a column reference error, you can use a table alias to refer to the column from `@Table2 explicitly`.

```sql
DECLARE @Table1 TABLE (Column_AAA INT);
DECLARE @Table2 TABLE (Column_BBB INT);

INSERT @Table1 VALUES(1);
INSERT @Table2 VALUES(2);

UPDATE  @Table1
SET     Column_AAA = 3
WHERE   Column_AAA IN (SELECT Column_AAA FROM @Table2);

SELECT  Column_AAA
FROM    @Table1;
```

The result of the above statement is 3.

----------------------------------------------------------------------------------------

#### Anti-Joins

This statement returns an empty dataset as the `NOT IN` operator will return an empty set if the outer query contains a NULL marker.

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB)
        OR
        Fruit NOT IN (NULL);
```
\<Empty Data Set>

----------------------------------------------------------------------------------------

The `NOT EXISTS` operator handles NULL markers implicitly and will return a result set with a NULL marker.  The `NOT EXISTS` operator treats NULL markers as neither equal to nor unequal to each other. They are unknown. 

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit);
```

| ID |  Fruit  |
|----|---------|
| 3  | Mango   |
| 4  | \<NULL> |

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
