# INNER JOINS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The `INNER JOIN` selects records from two tables given a join condition.  This type of join requires a comparison operator to combine rows from the participating tables based on a common field(s) in both tables.  Because of this, `INNER JOIN` acts as a filter criteria.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We can use both equi-join and theta-join operators between the joining fields.  An equi-join is a type of join in which the join condition is based on equality between the values of the specified columns in the two joined tables.  Conversely, a theta-join is a type of join in which the join condition is based on a comparison operator other than equality.

---------------------------------------------------------------------------------

We will be using the following tables that contain types of fruits and their quantity.  

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
|  1 | Apple   | 17       |
|  2 | Peach   | 25       |
|  3 | Kiwi    | 20       |
|  4 | \<NULL> | \<NULL>  |

---------------------------------------------------------------------------------
  
To start, here is the most common join you will use, an `INNER JOIN` between two tables.  This join uses an equi-join to look for equality between the two fields.  Note the query does not return NULL markers, as NULL markers are neither equal to nor not equal to each other. They are unknown.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |

---
We can also specify the matching criteria in the `WHERE` clause without explicitly specifying the `INNER JOIN` clause.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a,
        ##TableB b
WHERE   a.Fruit = b.Fruit;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |

---------------------------------------------------------------------------------
  
Remembering that all types of joins are restricted Cartesian products, the following `CROSS JOIN` produces the same results as above as it establishes the join predicate in the `WHERE` clause.

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
  
In MySQL, the following SQL statement will work and mimic an `INNER JOIN`.   This SQL statement has an `ON` clause of `1=1` and a `WHERE` clause specifying the join criteria.  If you remove the `WHERE` clause, this statement will work in both MySQL and SQLite to return a full Cartesian product.

```sql
SELECT a.ID,
       a.Fruit,
       b.ID,
       b.Fruit
FROM   ##TableA a CROSS JOIN
       ##TableB b on 1=1
WHERE  a.Fruit = b.Fruit;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |
   
---------------------------------------------------------------------------------
  
This `LEFT OUTER JOIN` acts as an `INNER JOIN` because we specify a predicate in the `WHERE` clause on the outer joined table, `TableB`.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a LEFT JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   b.Fruit = 'Apple'
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |

---------------------------------------------------------------------------------
  
This following statement incorporates an `INNER JOIN` with a theta-join, which looks for inequality between two fields.

An excellent example of using a theta-join is when someone wants to pair two different fruits of different quantities.

```sql
SELECT  a.ID,
        a.Fruit,
        a.Quantity,
        b.ID,
        b.Fruit,
        b.Quantity,
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit <> b.Fruit AND a.Quantity <> b.Quantity;
```

---------------------------------------------------------------------------------
  
This query uses an equi-join and a theta-join and functions similar to a `CROSS JOIN`, but with one big difference, NULL markers are not returned.  NULL markers are neither equal to nor not equal to each other. They are unknown.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit <> b.Fruit OR a.Fruit = b.Fruit;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 1  | Apple |
| 3  | Mango | 1  | Apple |
| 1  | Apple | 2  | Peach |
| 2  | Peach | 2  | Peach |
| 3  | Mango | 2  | Peach |
| 1  | Apple | 3  | Kiwi  |
| 2  | Peach | 3  | Kiwi  |
| 3  | Mango | 3  | Kiwi  |

---------------------------------------------------------------------------------
  
Here are some other examples of `INNER JOINS` using theta-joins.

This query looks for all values where the quantity in `TableA` is greater than or equal to a quantity in the corresponding `TableB`.

```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Quantity >= b.Quantity;
```

| ID | Fruit | Quantity | ID | Fruit | Quantity |
|----|-------|----------|----|-------|----------|
| 1  | Apple | 17       | 1  | Apple | 17       |
| 2  | Peach | 20       | 1  | Apple | 17       |
| 2  | Peach | 20       | 3  | Kiwi  | 20       |

---------------------------------------------------------------------------------
  
This query uses an equi-join and a theta-join negated with a `NOT` operator.  Determining if the `ID` is between the `Quantity` columns may be a somewhat absurd SQL statement to write, but this shows the possibilities in creating join logic. We often forget we can use comparison operators such as `LIKE` or `BETWEEN` in an SQL statement's `ON` clause and then negate it with `NOT`.
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit AND NOT(a.ID BETWEEN a.Quantity AND b.Quantity);
```

| ID | Fruit   | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
|  1 | Apple   | 17       | 1  | Apple   | 17       |
|  2 | Peach   | 20       | 2  | Peach   | 25       |
|  4 | \<NULL> | 5        | 4  | \<NULL> | \<NULL>  |

---  
Functions can be used in the join condition as well.  Assigning the empty string to a NULL value via the `ISNULL` function causes the NULLs to now equate to each other.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON ISNULL(a.Fruit,'') = ISNULL(b.Fruit,'');
```

| ID |  Fruit  | ID | Fruit   |
|----|---------|----|---------|
|  1 | Apple   | 1  | Apple   |
|  2 | Peach   | 2  | Peach   |
|  4 | \<NULL> | 4  | \<NULL> |

---------------------------------------------------------------------------------
In Microsoft SQL Server and PostgreSQL, you can also write the above query using the `ON EXISTS` clause. This is a little-known trick you can use that may (or may not) yield a bit better execution plan than the above statement, but it is worth checking.  I will cover the `ON EXISTS` syntax in another document, as it takes some thinking to understand its behavior. 

```sql
SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT a.Fruit INTERSECT SELECT b.Fruit);
```

| ID |  Fruit  | Quantity | ID |  Fruit  | Quantity |
|----|---------|----------|----|---------|----------|
|  1 | Apple   | 17       | 1  | Apple   | 17       |
|  2 | Peach   | 20       | 2  | Peach   | 25       |
|  4 | \<NULL> | 5        | 4  | \<NULL> | \<NULL>  |

---------------------------------------------------------------------------------
You can use a `CASE` statement to specify the join condition in the `WHERE` clause.  This is considered a bad practice, and you should find a better way of writing this query.
        
```sql
 SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a,
        ##TableB b
WHERE   (CASE WHEN a.Fruit = 'Apple' THEN a.Fruit ELSE 'Peach' END) = b.Fruit;
```
        
| ID |  Fruit  | ID | Fruit |
|----|---------|----|-------|
| 1  | Apple   | 1  | Apple |
| 2  | Peach   | 2  | Peach |
| 3  | Mango   | 2  | Peach |
| 4  | \<NULL> | 2  | Peach |
     
--------------------------------------------------------------------------------- 
When joining three or more statements, this SQL statement works in `SQL Server`.  The table referenced in the `ON` clause must be in reverse order for this to work.

For this SQL statement, I am self-joining to `TableA` three times.
        
```sql
SELECT  a.ID,
        a.Fruit
FROM    ##TableA a INNER JOIN
        ##TableA b INNER JOIN
        ##TableA c INNER JOIN
        ##TableA d ON c.Fruit = d.Fruit ON b.Fruit = c.Fruit ON a.Fruit = b.Fruit;
```

| ID | Fruit |
|----|-------|
| 1  | Apple |
| 2  | Peach |
| 3  | Mango |

---------------------------------------------------------------------------------
In MySQL and Oracle, there is a `USING` clause that you can use to specify the joining columns.  Each vendor's implementation is slightly different; see your vendor's documentation for specifics.
  
The below SQL statement works in MySQL.
  
```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b USING(Fruit);  
```
  
| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |
  
---------------------------------------------------------------------------------
ORACLE supports the `NATURAL JOIN` syntax.  I classify the natural join as a model join as E.F. Codd first conceived it in his work on the Relational Model.
  
The use of an asterisk in the `SELECT` statement is mandatory, and the output does not show duplicate column names.  This query is the same as an equi-join on the `ID`, `Fruit`, and `Quantity` columns between `TableA` and `TableB`.

```sql
SELECT  *
FROM    ##TableA a NATURAL JOIN
        ##TableB b;  
```

| ID | Fruit | Quantity |
|----|-------|----------|
| 1  | Apple | 17       |
  
The below ORACLE SQL statement uses the `USING` clause and mimics the `NATURAL JOIN`.
  
```sql
SELECT  *
FROM    ##TableA a JOIN
        ##TableB b USING(ID, Fruit, Quantity);  
```

| ID | Fruit | Quantity |
|----|-------|----------|
| 1  | Apple | 17       |

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
