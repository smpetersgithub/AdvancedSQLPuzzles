# Equi, Theta, and Natural Joins

SQL is considered a lenient interpretation of relational algebra because it deviates from the strict mathematical principles of relational algebra in some ways. While relational algebra provides a rigorous mathematical foundation for relational database management, SQL is a more practical, user-friendly language for querying and manipulating data in relational databases.

SQL has added various features and capabilities beyond those found in relational algebra, such as aggregate functions, subqueries, and the ability to manipulate data directly. It also provides a way to work with NULL markers, which are not part of the mathematical model of relational algebra. Additionally, SQL uses a syntax that is more accessible and easier to read than the mathematical notation used in relational algebra.

However, the basic principles of relational algebra still form the basis of SQL, and many SQL operations can be directly mapped to relational algebra operations. Understanding relational algebra can deepen your understanding of SQL and improve your ability to write effective, efficient SQL queries. Nevertheless, SQL remains a lenient interpretation of relational algebra, as it deviates from the mathematical principles to provide a practical and user-friendly way to work with relational databases.

----------------------------------

#### Equi and Theta-joins Overview

*  A theta-join is a join that uses a condition based on any binary comparison operator (such as `=`, `<`, `>`, `<=`, `>=`, or `<>`). These joins allow flexible matching logic beyond just equality. Theta-joins include both equi-joins, which test for equality, and non-equi-joins, which use other comparison operators.

*  An equi-join is a specific type of theta-join that matches rows based on equality conditions between columns in the joined tables. In other words, it returns rows where the values in the specified columns are equal. The term "equi" comes from the Latin word aequus, meaning "equal."

*  A non-equi-join is a type of theta-join that uses a condition other than equality (such as `<`, `>`, or `BETWEEN`) to compare columns. It returns rows where the join condition evaluates to true based on those non-equality comparisons.

--------------------------------------------------------------------------------

The following T-SQL comparison operators and predicates can be used in join conditions.

| Type       |       Operator       |                     Description                     |
|------------|----------------------|-----------------------------------------------------|
| Comparison | =                    | Equal To                                            |
| Comparison | <>                   | Not Equal To                                        |
| Comparison | !=                   | Not Equal To (not ISO standard)                     |
| Comparison | >                    | Greater Than                                        |
| Comparison | !<                   | Not less than (not ISO standard)                    |
| Comparison | <                    | Less Than                                           |
| Comparison | !>                   | Not greater than (not ISO standard)                 |
| Comparison | >=                   | Greater Than or Equal To                            |
| Comparison | <=                   | Less Than or Equal To                               |
| Logical    | BETWEEN              | Defines a range and is inclusive                    |
| Logical    | LIKE                 | Matches a string value to a specified pattern       |
| Comparison | IS DISTINCT FROM     | Treats NULLs as known values for comparing equality |
| Comparison | IS NOT DISTINCT FROM | Treats NULLs as known values for comparing equality |

*  Logical operators test for the truth of some condition. Like comparison operators, logical operators return a Boolean data type with a value of **TRUE**, **FALSE**, or **UNKNOWN**.

*  Comparison operators test whether two expressions are the same. Comparison operators can be used on all expressions except expressions of the `text`, `ntext`, or `image` data types.

*  `IS DISTINCT FROM` and `IS NOT DISTINCT FROM` compare values while treating NULL as a known value. They were added to SQL Server in SQL Server 2022, although other database systems supported them earlier.
 
--------------------------------------------------------------------------------
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
| ID |  Fruit  | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 25       |
| 3  | Kiwi    | 20       |
| 4  |         |          |
 
--------------------------------------------------------------------------------
#### Equi-joins

Equi-joins look for equality in a relationship.  

Equality predicates can be used with inner and outer joins. A `CROSS JOIN` does not have an `ON` clause, but applying an equality predicate in the WHERE clause produces a result logically equivalent to an inner equi-join. 

Here are several examples of an equi-join.


```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a CROSS JOIN
        ##TableB b
WHERE   a.Fruit = b.Fruit
ORDER BY 1;

SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit
ORDER BY 1;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
| 1  | Apple | 1  | Apple |
| 2  | Peach | 2  | Peach |

--------------------------------------------------------------------------------
#### Non-equi-joins
Non-equi-joins look for any non-equality comparison.  They can be used with `INNER`, `OUTER`, `FULL OUTER`, and `CROSS JOINS`.

Here are some examples that you may not have realized are possible.

You can use the `LIKE` and `BETWEEN` operators with the `ON` statement, as well as mathematical operations.  We often place these operators in the `WHERE` clause, but they can also appear in the `ON` clause.

```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Quantity BETWEEN b.Quantity AND b.Quantity + 10
                      AND a.Fruit LIKE '%' + b.Fruit + '%';
```

| ID | Fruit | Quantity | ID | Fruit | Quantity |
|----|-------|----------|----|-------|----------|
| 1  | Apple | 17       | 1  | Apple | 17       |
 
Here is an example of when you would use the greater-than operator.  Suppose you want to purchase two fruits, one fruit from `TableA` and one fruit from `TableB`; however, the quantity of the fruit in `TableA` needs to be larger than the quantity in `TableB`.  A typical example on the internet is when you need to purchase two items (such as a car and a boat), and one item must be worth more than the other.

```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Quantity > b.Quantity;
```

| ID | Fruit | Quantity | ID | Fruit | Quantity |
|----|-------|----------|----|-------|----------|
|  2 | Peach | 20       | 1  | Apple | 17       |

--------------------------------------------------------------------------------
#### Natural Joins

A natural join automatically creates an equality condition for every column name shared by the two inputs. A plain `NATURAL JOIN` is normally an inner join, although database systems may also support natural outer joins.

When `SELECT *` is used, each common join column appears only once in the result. Columns that are not common to both inputs are returned separately.

Several database systems, including Oracle, MySQL, and PostgreSQL, support NATURAL JOIN. SQL Server does not support the syntax directly.  

Natural joins are often discouraged for the following reasons:

- **Implicit behavior:** The join condition is not visible in the SQL
  statement, making the query harder to understand.
- **Unintended matches:** Columns may share a name even though they are
  not logically related.
- **Schema sensitivity:** Adding, removing, or renaming a column can
  silently change the join condition and the query result.
- **Portability:** Some database systems, including SQL Server, do not
  support `NATURAL JOIN`.
  
It is recommended to use explicit join syntax and specify the join conditions explicitly rather than relying on natural joins. This allows more control over the join conditions and the resulting data, making the query easier to understand and maintain.

Here is an example of a `NATURAL JOIN`.

```sql
SELECT  *
FROM    TableA a NATURAL JOIN
        TableB b;  
```

| ID | Fruit | Quantity |
|----|-------|----------|
| 1  | Apple | 17       |


The `USING` clause provides a more explicit alternative when the join columns have the same names. Unlike `NATURAL JOIN`, it identifies exactly which common columns participate in the join. Oracle, MySQL, PostgreSQL, and several other database systems support `USING`; SQL Server does not.

```sql
SELECT  *
FROM    ##TableA a JOIN
        ##TableB b USING(ID, Fruit, Quantity);  
```

| ID | Fruit | Quantity |
|----|-------|----------|
| 1  | Apple | 17       |

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
