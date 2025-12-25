# Semi and Anti-Joins

Semi and anti-joins are two types of logical join operations used in SQL.

The term **semi** refers to the fact that a semi-join returns only a subset of the rows from one table based on the existence of matching rows in another table. Specifically, a semi-join returns only the rows from the first table (the left table) that have matching values in the second table (the right table). The columns of the right table are not included in the projection.

The opposite of a semi-join is an **anti-join**, which returns rows from the left table for which no matching rows exist in the right table.

> **Historical note:** The terms *semi-join* and *anti-join* were coined by **E. F. Codd**, the creator of the relational model, as part of relational algebra. These operators are fundamental to expressing existence- and non-existence-based relationships between relations.

In SQL, semi-joins and anti-joins are not expressed using explicit keywords. Instead, they are implemented using predicates in the `WHERE` clause:

- Semi-joins use the `IN` or `EXISTS` operators.
- Anti-joins use the `NOT IN` or `NOT EXISTS` operators.

## Characteristics of Semi and Anti-Joins

For a query to be considered a semi-join or anti-join, it must have the following qualities:

1. The join must not introduce duplicate rows from the outer (left) table.
2. Columns from the joined (right) table must not appear in the `SELECT` list.
3. The join condition determines row inclusion based on the *existence* or *non-existence* of matching rows, most commonly using equality (`=`).

## Benefits Over `INNER JOIN`

There are several advantages to using semi-joins and anti-joins instead of `INNER JOIN`:

- They eliminate the risk of returning duplicate rows caused by one-to-many relationships.
- They improve readability by returning only columns from the outer table.
- They more directly express intent when only existence (or non-existence) matters.

## Important Differences and Considerations

- **NULL handling:**  
  The `NOT IN` operator returns an empty result set if the subquery contains a `NULL`. In contrast, `NOT EXISTS` handles `NULL` values safely and does not suppress results.

- **Correlation:**  
  The `EXISTS` and `NOT EXISTS` operators are typically used as correlated subqueries, meaning the inner query references columns from the outer query.  
  The `IN` and `NOT IN` operators can be used with literal value lists or uncorrelated subqueries.

- **Evaluation semantics:**  
  The `IN` and `NOT IN` operators compare scalar values against a set of values.  
  The `EXISTS` and `NOT EXISTS` operators test only whether at least one matching row exists.

- **Best practice:**  
  When performing anti-joins against nullable columns, prefer `NOT EXISTS` over `NOT IN`.

- **Performance:**  
  Always examine execution plans. Because `IN`/`NOT IN` operate on value comparisons and `EXISTS`/`NOT EXISTS` operate on row existence, the optimizer may generate very different execution strategies.

Semi-joins and anti-joins are powerful tools for expressing relational intent clearly and efficiently, especially when the presence or absence of related data is more important than returning the related data itself.

----------------------------------------------------------------------------------------

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
| ID | Fruit   | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 25       |
| 3  | Kiwi    | 20       |
| 4  |         |          |
        
----------------------------------------------------------------------------------------
        
## Semi-Joins

### Example 1

The `IN` operator is typically used to filter a column for a specific list of values.  Even though we include a NULL marker in the inner query, the results do not include it.

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN ('Apple','Peach',NULL)
ORDER BY 1;
```

| ID | Fruit |
|----|-------|
| 1  | Apple |
| 2  | Peach |

----------------------------------------------------------------------------------------

### Example 2

Using the `IN` operator, this query will return results, but does not return a NULL marker even though there is both a NULL marker in `##TableA` and `##TableB`.  The `NOT IN` operator treats NULL markers as neither equal to nor unequal to each other; they are unknown. 

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit IN (SELECT Fruit FROM ##TableB)
ORDER BY 1;
```

| ID | Fruit |
|----|-------|
| 1  | Apple |
| 2  | Peach |

----------------------------------------------------------------------------------------

### Example 3

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

### Example 4

The `EXISTS` operator is used to test for the existence of any record in a subquery. The `EXISTS` operator returns TRUE if the subquery returns one or more records, and the `EXISTS` operator treats NULL markers as neither equal to nor unequal to each other; they are unknown. 

Because it checks for the existence of rows, you do not need to include any columns in the `SELECT` statement. It is considered best practice to place an arbitrary "1" here.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a 
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit)
ORDER BY 1;
```

| ID | Fruit |
|----|-------|
| 1  | Apple |
| 2  | Peach |

----------------------------------------------------------------------------------------

### Example 5

Be aware that when using correlated subqueries without a join condition, they will always evaluate to true. In the following SQL example, the subquery returns NULL but isn't joined to the main query. Despite the `NOT EXISTS (SELECT NULL)`, the query retrieves all rows from `##TableA` because the subquery will always be true without a join condition.

```sql
SELECT  *
FROM    ##TableA
WHERE   EXISTS (SELECT NULL)
ORDER BY 1;
```

| ID |  Fruit  | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 20       |
| 3  | Mango   | 11       |
| 4  |         | 5        |

----------------------------------------------------------------------------------------

### Example 6

Be cautious using the `IN` operator, as it can lead to unexpected behavior!

In this example, I use two table variables for demonstration.

In the SQL snippet below, you might anticipate that the inner `SELECT` statement would produce an error since `Column_AAA` doesn't exist in `@Table2`. However, this query runs without issue and updates `@Table1`, setting `Column_AAA` to 3. This is because Microsoft SQL Server treats it as a correlated subquery. To trigger a column reference error, you can use a table alias to refer to the column from `@Table2 explicitly`.

```sql
DECLARE @Table1 TABLE (Column_A INT);
DECLARE @Table2 TABLE (Column_B INT);

INSERT @Table1 VALUES(1);
INSERT @Table2 VALUES(2);

UPDATE  @Table1
SET     Column_A = 3
WHERE   Column_A IN (SELECT Column_A FROM @Table2);

SELECT  Column_A
FROM    @Table1;
```

| Column_AAA |
|------------|
| 3          |

----------------------------------------------------------------------------------------

## Anti-Joins

### Example 7

This statement returns an empty dataset because the `NOT IN` operator returns an empty set when the outer query contains a NULL marker.

```sql
SELECT  Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB)
        OR
        Fruit NOT IN (NULL);
```
\<Empty Data Set>

----------------------------------------------------------------------------------------

### Example 8

The `NOT EXISTS` operator handles NULL markers implicitly and will return a result set with a NULL marker.  The `NOT EXISTS` operator treats NULL markers as neither equal to nor unequal to each other. They are unknown. 

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit)
ORDER BY 1;
```

| ID |  Fruit  |
|----|---------|
| 3  | Mango   |
| 4  |         |

---------------------------------------------------------

### Continue Reading
 
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
