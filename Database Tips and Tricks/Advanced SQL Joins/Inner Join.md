## INNER JOINS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The INNER JOIN selects records from two tables given a join condition.  This type of join requires a comparison operator to combine rows from the participating tables based on a common field(s) in both tables.  Because of this, INNER JOINS act as a filter criteria.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We can use both equi-join and theta-join operators between the joining fields.  An equi-join is a type of join in which the join condition is based on equality between the values of the specified columns in the two tables being joined.  A theta-join, on the other hand, is a type of join in which the join condition is based on a comparison operator other than equality. This comparison operator can be any of the standard comparison operators such as <, >, <=, >=, <>, etc.

---

We will be using the following tables that contain fruits.  The DDL to create these tables can be found here.
  
**Table A**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  |       17 |
|  2 | Peach  |       20 |
|  3 | Mango  |       11 |
|  4 | <NULL> |        5 |
  
**Table B**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  | 17       |
|  2 | Peach  | 25       |
|  3 | Kiwi   | 20       |
|  4 | <NULL> | <NULL>   |

----
To start, here is the most common join you will use, an INNER JOIN between two tables.  This join uses an equi-join as it looks for equality between the two fields.  Note the query does not return the NULL markers, as NULL markers are neither equal to or not equal to each other, they are unknown.

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
|  1 | Apple |  1 | Apple |
|  2 | Peach |  2 | Peach |

---
We can also specify the matching criteria in the WHERE clause without specifiy the INNER JOIN clause.

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
|  1 | Apple |  1 | Apple |
|  2 | Peach |  2 | Peach |

---
Remembering that all types of joins are restricted cartesian products, the following CROSS JOIN produces the same results as above as it has a matching predicate in the WHERE clause.

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
|  1 | Apple |  1 | Apple |
|  2 | Peach |  2 | Peach |

---
This LEFT OUTER JOIN acts as an INNER JOIN because we specify a predicate in the WHERE clause on the outer joined table (TableB).

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a LEFT JOIN
        ##TableB b ON a.Fruit = b.Fruit;
WHERE   b.Fruit = 'Apple'
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
|  1 | Apple |  1 | Apple |
|  2 | Peach |  2 | Peach |

---
This next statement incorporates an INNER JOIN with a theta-join, which looks for inequality between two fields.  Normally you will combine a theta-join with an equi-join when creating predicate logic (although not always the case).  This statement uses both an equi-join and a theta-join join to find fruits which exist in both tables but have different quantities.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit AND a.Quantity <> b.Quantity;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
|  2 | Peach |  2 | Peach |

---
This query uses both an equi-join and a theta-join, and functions similiar to a CROSS JOIN but with one big difference, no NULL markers are returned.  Because we have NULL markers in the table, they are eradicated as NULL markers are neither equal nor not equal to each other, they are unknown.

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
|  1 | Apple |  1 | Apple |
|  2 | Peach |  1 | Apple |
|  3 | Mango |  1 | Apple |
|  1 | Apple |  2 | Peach |
|  2 | Peach |  2 | Peach |
|  3 | Mango |  2 | Peach |
|  1 | Apple |  3 | Kiwi  |
|  2 | Peach |  3 | Kiwi  |
|  3 | Mango |  3 | Kiwi  |

---
Here are some other examples of INNER JOINS using theta-joins.  

This query looks for all values where the quantity in Table A is greater than or equal to a quantity in the corresponding Table B.

```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Quantity >= b.Quantity;
```

| ID | Fruit | Quantity | ID | Fruit | Quantity |
|----|-------|----------|----|-------|----------|
|  1 | Apple |       17 |  1 | Apple |       17 |
|  2 | Peach |       20 |  1 | Apple |       17 |
|  2 | Peach |       20 |  3 | Kiwi  |       20 |

---
This query uses a theta-join to find all fruits in Table A that have a quantity between 10 and 20.  The columns from Table A are shown first in the result set as this table is listed first in the FROM statement.
  
```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit AND a.Quantity BETWEEN 10 AND 20;
```

| ID | Fruit | Quantity | ID | Fruit | Quantity |
|----|-------|----------|----|-------|----------|
|  1 | Apple |       17 |  1 | Apple |       17 |
|  2 | Peach |       20 |  2 | Peach |       25 |
 
---  
Functions can be used in the join condition as well.  Assigning the empty string to a NULL value via the ISNULL function causes the NULLs to now equate to each other.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON ISNULL(a.Fruit,'') = ISNULL(b.Fruit,'');
```

| ID | Fruit  | ID | Fruit  |
|----|--------|----|--------|
|  1 | Apple  |  1 | Apple  |
|  2 | Peach  |  2 | Peach  |
|  4 | <NULL> |  4 | <NULL> |

---

You can also write the above query by using the ON EXISTS clause.  This is a little known trick you can use that may (or may not) yeild a bit better execution plan then the above, but it is worth checking.

```sql
  SELECT  a.*,
        b.*
FROM    ##TableA a INNER JOIN
        ##TableB b ON EXISTS(SELECT a.Fruit INTERSECT SELECT b.Fruit);
```

| ID | Fruit  | Quantity | ID | Fruit  | Quantity |
|----|--------|----------|----|--------|----------|
|  1 | Apple  |       17 |  1 | Apple  | 17       |
|  2 | Peach  |       20 |  2 | Peach  | 25       |
|  4 | <NULL> |        5 |  4 | <NULL> | <NULL>   |

---

You can use a CASE statement to specify the join condition in the WHERE clause by and using a CROSS join.  This is considered a bad practice and you should find a better way of writing this query.
        
```sql
 SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a,
        ##TableB b
WHERE   (CASE WHEN a.Fruit = 'Apple' THEN a.Fruit ELSE 'Peach' END) = b.Fruit;
```
        
| ID | Fruit  | ID | Fruit |
|----|--------|----|-------|
|  1 | Apple  |  1 | Apple |
|  2 | Peach  |  2 | Peach |
|  3 | Mango  |  2 | Peach |
|  4 | <NULL> |  2 | Peach |
     
---        
        
This example works in T-SQL when joining three or more tables.  The ON clause must be in reverse order for this to work.

For this statement, I am self-joining to TableA three times.
        
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
|  1 | Apple |
|  2 | Peach |
|  3 | Mango |

---

Up next is OUTER JOINS.

Happy coding!        
