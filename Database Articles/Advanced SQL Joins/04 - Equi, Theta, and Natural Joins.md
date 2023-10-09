# Equi, Theta, and Natural Joins

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Equi, theta, and natural joins were introduced by E.F. Codd in his seminal work on defining relational algebra, which serves as the foundation for SQL.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SQL is considered a lenient interpretation of relational algebra because it deviates from the strict mathematical principles of relational algebra in some ways. While relational algebra provides a rigorous mathematical foundation for relational database management, SQL is a more practical, user-friendly language for querying and manipulating data in relational databases.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SQL has added various features and capabilities beyond those found in relational algebra, such as aggregate functions, subqueries, and the ability to manipulate data directly. It also provides a way to work with NULL markers, which are not part of the mathematical model of relational algebra. Additionally, SQL uses a syntax that is more accessible and easier to read than the mathematical notation used in relational algebra.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;However, the basic principles of relational algebra still form the basis of SQL, and many SQL operations can be directly mapped to relational algebra operations. This means that understanding relational algebra can help to understand SQL more deeply and improve the ability to write effective and efficient SQL queries. Nevertheless, SQL remains a lenient interpretation of relational algebra, as it deviates from the mathematical principles to provide a practical and user-friendly way to work with relational databases.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We will first look at equi and theta-joins, and then move on to the natural join.

----------------------------------

#### Equi and Theta-joins Overview

*  Equi-joins look for equality in the join condition.  It is a join operation that combines rows from two or more tables based on a matching value in one or more columns. This matching value is known as the join condition and is an equality condition. The term equi comes from the Latin word aequus, meaning equal.

*  A theta-join, also known as a non-equi-join, is a join that uses an operator other than equality. These operators include both comparison and logical operators. The term "theta" is used to denote any non-equality comparison.  The terms equi-join and theta-join was coined by E.F. Codd in his seminal work on defining relational algebra, which serves as the foundation for SQL.

--------------------------------------------------------------------------------
SQL has the following operators that can be used to join tables.

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
|            | IS DISTINCT FROM     | Treats NULLs as known values for comparing equality |
|            | IS NOT DISTINCT FROM | Treats NULLs as known values for comparing equality |

*  Logical operators test for the truth of some condition. Logical operators, like comparison operators, return a Boolean data type with a value of **TRUE**, **FALSE**, or **UNKNOWN**.

*  Comparison operators test whether two expressions are the same. Comparison operators can be used on all expressions except expressions of the `text`, `ntext`, or `image` data types.

*  The `IS [NOT] DISTINCT FROM` operator is a relatively new feature being added to the various database systems.  I have set it to NULL as I have not found any vendor documentation categorizing this operator as logical or a comparison.
 
--------------------------------------------------------------------------------
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
| ID |  Fruit  | Quantity |
|----|---------|----------|
| 1  | Apple   | 17       |
| 2  | Peach   | 25       |
| 3  | Kiwi    | 20       |
| 4  | \<NULL> | \<NULL>  |
 
--------------------------------------------------------------------------------
#### Equi-joins

Equi-joins look for equality in a relationship.  They can be used with `INNER`, `OUTER`, `FULL OUTER`, and `CROSS JOINS`. The example below uses the `CROSS JOIN` syntax but functions like an `INNER JOIN` because the join logic is in the `WHERE` clause.

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

--------------------------------------------------------------------------------
#### Theta-joins
Theta-joins looks for any non-equality comparison.  Sometimes this join is called a non-equi-join.  They can be used with `INNER`, `OUTER`, `FULL OUTER`, and `CROSS JOINS`.

Here are some examples that you may not have realized are possible.

You can use the `LIKE` and `BETWEEN` operators with the `ON` statement, as well as mathematical operations.  We often place these operators in the `WHERE` clause, but they can exist with the `ON` statement.

```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Quantity BETWEEN b.Quantity AND b.Quantity + 10
                      AND a.Fruit LIKE '%' + b.Fruit + '%';
```

| ID | Fruit | Quantity | ID | Fruit | Quantity |
|----|-------|----------|----|-------|----------|
| 1  | Apple | 17       | 1  | Apple | 17       |
 
Here is an example where you would use the greater than operator.  Suppose you want to purchase two fruits, one fruit from `TableA` and one fruit from `TableB`, however, the quantity of the fruit in `TableA` needs to be larger than the quantity in `TableB`.  A typical example on the internet is when you need to purchase two items (such as a car and a boat), and one item (the car) must be of greater value than the other.

```sql
SELECT  *
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Quantity > b.Quantity;
```

| ID | Fruit | Quantity | ID | Fruit | Quantity |
|----|-------|----------|----|-------|----------|
|  2 | Peach | 20       | 1  | Apple | 17       |

--------------------------------------------------------------------------------
#### Natural Joins Overview

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A natural join in relational algebra is a join operation that combines two relational tables via an equi-join based on their common attributes. In a natural join, only the rows with matching values in the common columns are included in the result. The common columns of the two tables are used as the join criteria, and the result set includes only one copy of these columns. The columns in the result set correspond to the combination of columns from both tables.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ORACLE is currently the only vendor that supports the `NATURAL JOIN` syntax.  It is considered a bad practice for the following reasons:
*  Ambiguity: Natural joins can cause ambiguity if two or more columns in the participating tables have the same name. This can lead to unexpected results and make the SQL statement difficult to understand and maintain.
*  Maintenance: Natural joins can make the database schema more difficult to maintain because changes to the common columns in one of the participating tables will affect the join result.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For these reasons, it is generally recommended to use explicit join syntax and specify the join conditions explicitly rather than relying on natural joins. This allows for more control over the join conditions and the resulting data and makes the query easier to understand and maintain.

------------------------------------------------

#### Natural Joins

Using an asterisk in the `SELECT` statement is mandatory, and the output does not show duplicate column names. This query is the same as an equi-join on the `ID`, `Fruit`, and `Quantity` columns between `TableA` and `TableB`.

```sql
SELECT  *
FROM    ##TableA a NATURAL JOIN
        ##TableB b;  
```


| ID | Fruit | Quantity |
|----|-------|----------|
| 1  | Apple | 17       |


Note, to counteract some of the bad practices for using the `NATURAL JOIN`, ORACLE and MySQL have the `USING` clause.  Below is the ORACLE implementation of the `USING` clause.

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
