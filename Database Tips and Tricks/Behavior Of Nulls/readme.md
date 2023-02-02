# Behavior of Nulls
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;https://advancedsqlpuzzles.com

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To record missing or unknown values, users of relational databases can assign NULL markers to columns.  NULL is not a data value, but a marker representing the absence of a value.

NULL markers can mean one of two things:
1)  The column does not apply to the other columns in the record.
2)  The column applies, but the information is unknown.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Because NULL markers represent the absence of a value, NULL markers can be a source of much confusion and trouble for developers.  To best understand NULL markers, one must understand the three-valued logic of **TRUE**, **FALSE**, or **UNKNOWN**, and recognize how NULL markers are treated within the different constructs of the SQL language.

Because NULL markers do not represent a value, SQL has two conditions specific to the SQL language:
1)  `IS NULL`
2)  `IS NOT NULL`

SQL also provides three functions to evaluate NULL markers: 
1)  `NULLIF`
2)  `ISNULL`
3)  `COALESCE`

We will cover these aspects and many more in the following document.

----------------------------------------------------------

👍 I recomend navigating using the **Table Of Contents**.

#### Table Of Contents    
[1. PREDICATE LOGIC](#predicate-logic)    
[2. ANSI_NULLS](#ansi_nulls)    
[3. IS NULL and IS NOT NULL](#is-null-and-is-not-null)    
[4. SAMPLE DATA](#sample-data)    
[5. JOIN SYNTAX](#join-syntax)    
[6. SEMI AND ANTI JOINS](#semi-and-anti-joins)    
[7. SET OPERATORS](#set-operators)    
[8. COUNT AND AVERAGE FUNCTION](#count-and-average-function)    
[9. CONSTRAINTS](#constraints)    
[10. REFERENTIAL INTEGRITY](#referential-integrity)    
[11. COMPUTED COLUMNS](#computed-columns)    
[12. SQL FUNCTIONS](#sql-functions)    
[13. EMPTY STRINGS, NULL, AND ASCII VALUES](#empty-strings-null-and-ascii-values)    
[14. CONCAT](#concat)    
[15. VIEWS](#views)    
[16. BOOLEAN VALUES](#boolean-values)    

--------------------------------------------------------
### Brief History of NULLS 
:large_blue_circle: [Table Of Contents](#table-of-contents)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NULL values in relational databases are a source of debate, with some proponents rejecting them entirely, while others, including E.F. Codd, advocate for their use. Codd, a computer scientist who revolutionized database management with his work on relational database theory, introduced the concept of NULL values in the late 1960s and early 1970s to represent the absence of a value.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Codd's work ensured data consistency and accuracy in relational databases, as they could better handle real-world scenarios where information may not always be complete. However, some critics argue that NULL values can lead to ambiguity and confusion, lack of default values, performance issues, and affect data quality.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Despite these criticisms, NULL values are widely used and accepted, but must be used appropriately to understand their limitations and impact on data quality and performance. For further information, refer to C.J. Date's book, [Database in Depth: Relational Theory for Practitioners](https://www.amazon.com/Database-Depth-Relational-Theory-Practitioners/dp/0596100124).

---------------------------------------------------------

:white_check_mark:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The examples provided are written in `Microsoft’s SQL Server T-SQL`.  The provided SQL statements can be easily modified to fit your dialect of SQL.  

:mailbox: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**I welcome any corrections, new tricks, new techniques, dead links, misspellings, or bugs!**

---------------------------------------------------------
### PREDICATE LOGIC
:large_blue_circle: [Table Of Contents](#table-of-contents)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To best understand NULL markers in SQL, we need to understand the three-valued logic outcomes of **TRUE**, **FALSE**, and **UNKNOWN**.  Unique to SQL, the logic result will always be **UNKNOWN** when comparing a NULL marker to any other value.   SQL’s use of the three-valued logic system presents a surprising amount of complexity into a seemingly straightforward query!

---------------------------------------------------------

The following truth tables display how the three-valued logic is applied.

![Truth Tables Three Valued Logic](/Database%20Tips%20and%20Tricks/Behavior%20Of%20Nulls/images/Truth_Tables_Three_Valued_Logic.png)

A good example of the complexity is shown below in the following examples.

```sql
--TRUE OR UNKNOWN = TRUE
SELECT 1 WHERE ((1=1) OR (NULL=1));

--FALSE OR UNKNOWN = UNKNOWN
SELECT 1 WHERE NOT((1=2) OR (NULL=1));
```

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Because **TRUE OR UNKNOWN** equates to **TRUE**, one may expect `NOT(FALSE OR UNKNOWN)` to equate to **TRUE**, but this is not the case.  **UNKNOWN** could potentially have the value of **TRUE** or **FALSE**, leading to the second statement to either be **TRUE** or **FALSE** if the value of **UNKNOWN** becomes available.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The statement **TRUE OR UNKNOWN** will always resolve to **TRUE** if the value of **UNKNOWN** is either **TRUE** or **FALSE**, as **TRUE OR FALSE** is always **TRUE**.

---------------------------------------------------------
### ANSI_NULLS
:large_blue_circle: [Table Of Contents](#table-of-contents)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In SQL Server, the `SET ANSI_NULLS` setting specifies the ISO compliant behavior of the equality (=) and inequality (<>) comparison operators.  The following table shows how the `ANSI_NULLS` session setting affects the results of Boolean expressions using NULL markers.  

:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The standard setting for `ANSI_NULLS` is `ON`.  In a future version of `Microsoft SQL Server` `ANSI_NULLS` will always be `ON` and any applications that explicitly set the option to `OFF` will produce an error. Avoid using this feature in new development work, and plan to modify applications that currently use this feature.


| Boolean Expression | SET ANSI_NULLS ON | SET ANSI_NULLS OFF |
|--------------------|-------------------|--------------------|
| NULL = NULL        | UNKNOWN           | TRUE               |
| 1 = NULL           | UNKNOWN           | FALSE              |
| NULL <> NULL       | UNKNOWN           | FALSE              |
| 1 <> NULL          | UNKNOWN           | TRUE               |
| NULL > NULL        | UNKNOWN           | UNKNOWN            |
| 1 > NULL           | UNKNOWN           | UNKNOWN            |
| NULL | TRUE              | TRUE               |
| 1 IS NULL          | FALSE             | FALSE              |
| NULL IS NOT NULL   | FALSE             | FALSE              |
| 1 IS NOT NULL      | TRUE              | TRUE               |


---------------------------------------------------------
### IS NULL and IS NOT NULL
:large_blue_circle: [Table Of Contents](#table-of-contents)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We can experiment with setting the `ANSI_NULLS` to `ON` and `OFF` to review how the behavior of NULL markers change.  In the following examples we will set the default `ANSI_NULLS` setting to `ON`.

SQL provides two functions for handling NULL markers, `IS NULL` and `IS NOT NULL` which we will also demonstrate below.

```sql
--2.1
SET ANSI_NULLS ON;

--UNKNOWN
SELECT 1 WHERE NULL = NULL;
SELECT 1 WHERE 1 = NULL;
SELECT 1 WHERE NULL <> NULL;
SELECT 1 WHERE NULL = NULL;
SELECT 1 WHERE 1 = NULL;
SELECT 1 WHERE NULL <> NULL;
SELECT 1 WHERE 1 <> NULL;
SELECT 1 WHERE NULL > NULL;
SELECT 1 WHERE 1 > NULL;

--TRUE
SELECT 1 WHERE NULL IS NULL;
SELECT 1 WHERE 1 IS NOT NULL;

--FALSE
SELECT 1 WHERE 1 IS NULL;
SELECT 1 WHERE NULL IS NOT NULL;
```

Now that we have covered the basics of NULL markers, lets create two sample data tables and start working through examples.

---------------------------------------------------------
### SAMPLE DATA
:large_blue_circle: [Table Of Contents](#table-of-contents)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We will use the following tables of fruits and their quantities in our quest to understand the behavior of NULL markers.  Using two tables of the same type gives us the best example for understanding NULL markers.  We will work with this data throughout these exercises.

**##TableA**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  |       17 |
|  2 | Peach  |       20 |
|  3 | Mango  |       11 |
|  4 | Mango  |       15 |
|  5 | <NULL> |        5 |
|  6 | <NULL> |        3 |

**##TableB**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  | 17       |
|  2 | Peach  | 25       |
|  3 | Kiwi   | 20       |
|  4 | <NULL> | <NULL>   |


```sql
DROP TABLE IF EXISTS ##TableA;
DROP TABLE IF EXISTS ##TableB;
GO

CREATE TABLE ##TableA
(
ID          INTEGER,
Fruit       VARCHAR(255),
Quantity    INTEGER
);
GO

CREATE TABLE ##TableB
(
ID          INTEGER,
Fruit       VARCHAR(255),
Quantity    INTEGER
);
GO

INSERT INTO ##TableA VALUES
(1,'Apple',17),
(2,'Peach',20),
(3,'Mango',11),
(4,'Mango',15),
(5,NULL,5),
(6,NULL,3);
GO

INSERT INTO ##TableB VALUES
(1,'Apple',17),
(2,'Peach',25),
(3,'Kiwi',20),
(4,NULL,NULL)
GO
```

---------------------------------------------------------
### JOIN SYNTAX
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NULL markers are neither equal to nor not equal to each other.  They are treated as unknowns.  This is best demonstrated by the below `INNER JOIN` statement, where NULL markers are not present in the result set.  Note here we are looking for both equality and inequality on the Fruit column (and a `DISTINCT` is applied as well).

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a INNER JOIN
        ##TableB b ON a.Fruit = b.Fruit OR a.Fruit <> b.Fruit;
```

| ID | Fruit | ID | Fruit |
|----|-------|----|-------|
|  1 | Apple |  1 | Apple |
|  1 | Apple |  2 | Peach |
|  1 | Apple |  3 | Kiwi  |
|  2 | Peach |  1 | Apple |
|  2 | Peach |  2 | Peach |
|  2 | Peach |  3 | Kiwi  |
|  3 | Mango |  1 | Apple |
|  3 | Mango |  2 | Peach |
|  3 | Mango |  3 | Kiwi  |
|  4 | Mango |  1 | Apple |
|  4 | Mango |  2 | Peach |
|  4 | Mango |  3 | Kiwi  |

---------------------------------------------------
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The `OUTER JOIN` will give an illusion that is matches on the NULL markers but looking closely at the number of NULL markers returned vs the number of NULL markers in our sample data, we can determine this is indeed not true.  Also, the below query demonstrates the `ORDER BY` sorts NULLS in ascending order.

```sql
SELECT  a.ID,
        a.Fruit,
        b.ID,
        b.Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
ORDER BY 1,2;
```

|   ID   | Fruit  |   ID   | Fruit  |
|--------|--------|--------|--------|
| <NULL> | <NULL> | 3      | Kiwi   |
| <NULL> | <NULL> | 4      | <NULL> |
| 1      | Apple  | 1      | Apple  |
| 2      | Peach  | 2      | Peach  |
| 3      | Mango  | <NULL> | <NULL> |
| 4      | Mango  | <NULL> | <NULL> |
| 5      | <NULL> | <NULL> | <NULL> |
| 6      | <NULL> | <NULL> | <NULL> |

---------------------------------------------------------
### SEMI AND ANTI JOINS
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Semi-joins and anti-joins are two closely related join methods.  The semi-join and anti-join are types of joins between two tables where rows from the outer query are returned based upon the presence or absence of a matching row in the joined table.

Anti-joins use the `NOT IN` or `NOT EXISTS` operators.  Semi-joins use the `IN` or `EXISTS` operators.

There are several benefits of using anti-joins and semi-joins over `INNER JOINS`:
1.  Semi-joins and anti-joins remove the risk of returning duplicate rows.
2.  Semi-joins and anti-joins increase readability as the result set can only contain the columns from the outer semi-joined table.

There are two key differences differences between semi-joins and anti-joins:
1.  The `NOT IN` operator will return an empty set if the anti-join contains a NULL marker.  The `NOT EXISTS` will return a dataset that contains a NULL marker if the anti-join contains a NULL marker.
2.  The `IN` and `EXIST` operators will return a dataset if the semi-join contains a NULL marker.

:small_red_triangle:      If you are performing an anti-join to a NULLable column, consider using the `NOT EXISTS` operator over the `NOT` operator.

--------------------------------------------------------
This statement returns an empty dataset as the anti-join contains a NULL marker.

```sql
SELECT  1 AS RowNumber,
        ID,
        Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB);
```

| RowNumber | ID | Fruit |
|-----------|----|-------|    
  
\<Empty Data Set>

--------------------------------------------------------  
Adding an `ISNULL` function to the inner query is one way to alleviate the issue of NULL markers.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT ISNULL(Fruit,'') FROM ##TableB);
```

| ID | Fruit |
|----|-------|
|  3 | Mango |
|  4 | Mango |

--------------------------------------------------------  
A better practice is to place predicate logic in the `WHERE` clause to eradicate the NULL markers.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA
WHERE   Fruit NOT IN (SELECT Fruit FROM ##TableB WHERE Fruit IS NOT NULL);
```

| ID | Fruit |
|----|-------|
|  3 | Mango |
|  4 | Mango |

--------------------------------------------------------        
The opposite of anti-joins are semi-joins.  Using the `IN` operator, this query will return a result set.  A `NOT IN` operator would return an empty dataset.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA
WHERE   Fruit IN (SELECT Fruit FROM ##TableB);
```

| ID | Fruit |
|----|-------|
|  1 | Apple |
|  2 | Peach |

--------------------------------------------------------  
The `IN` and `NOT IN` operators can also take a hard coded list of values as its input.  For this example, we use the `IN` operator.  Even though we include a NULL marker in the inner query, the results do not include a NULL marker.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA
WHERE   Fruit IN ('Apple','Kiwi',NULL);
```

| ID | Fruit |
|----|-------|
|  1 | Apple |

--------------------------------------------------------
`EXISTS` is much the same as `IN`.  But with `EXISTS` you must specify a query and you can specify multiple join conditions.

```sql
SELECT  ID,
        Fruit
FROM    ##TableA a
WHERE   EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit AND a.Quantity = b.Quantity);
```

| ID | Fruit |
|----|-------|
|  1 | Apple |

--------------------------------------------------------
Here is the usage of the `NOT EXISTS`.  A NULL marker is returned in the dataset (unlike the `IN` operator).

```sql
SELECT  a.ID,
        Fruit
FROM    ##TableA a
WHERE   NOT EXISTS (SELECT 1 FROM ##TableB b WHERE a.Fruit = b.Fruit AND a.Quantity = b.Quantity);
```

| ID | Fruit  |
|----|--------|
|  2 | Peach  |
|  3 | Mango  |
|  4 | Mango  |
|  5 | <NULL> |
|  6 | <NULL> |

---------------------------------------------------------
### SET OPERATORS
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The SQL standard for set operators does not use the term **EQUAL TO or NOT EQUAL TO** when describing their behavior.  Instead, it uses the terminology of **IS [NOT] DISTINCT FROM** and the following expressions are TRUE when using set operators.
*  NULL is not distinct from NULL
*  NULL is distinct from "Apple".

In the following examples, we see the set operators treat the NULL markers differently than the join syntax.

--------------------------------------------------------        
The `UNION` operator demonstrates that NULL is not distinct from NULL, as the following returns only one NULL marker.

```sql
SELECT DISTINCT Fruit FROM ##TableA
UNION
SELECT DISTINCT Fruit FROM ##TableB;
```

| Fruit  |
|--------|
| <NULL> |
| Apple  |
| Kiwi   |
| Mango  |
| Peach  |

--------------------------------------------------------
The `UNION ALL` operator returns all values including each NULL marker.

```sql
SELECT DISTINCT Fruit FROM ##TableA
UNION ALL
SELECT DISTINCT Fruit FROM ##TableB;
```

| Fruit  |
|--------|
| <NULL> |
| Apple  |
| Mango  |
| Peach  |
| <NULL> |
| Apple  |
| Kiwi   |
| Peach  |

--------------------------------------------------------
The `EXCEPT` operator treats the NULL markers as being not distinct from each other.

```sql
SELECT DISTINCT Fruit FROM ##TableB
EXCEPT
SELECT DISTINCT Fruit FROM ##TableA;
```

| Fruit |
|-------|
| Kiwi  |

--------------------------------------------------------
The `INTERSECT` returns the following records.

```sql
SELECT DISTINCT Fruit FROM ##TableA
INTERSECT
SELECT DISTINCT Fruit FROM ##TableB;
```

| Fruit  |
|--------|
| <NULL> |
| Apple  |
| Peach  |

---------------------------------------------------------
### GROUP BY
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
The `GROUP BY` clause aggregates the NULL markers together.

```sql
SELECT  Fruit,
        COUNT(*) AS Count_Star,
        COUNT(Fruit) AS Count_Fruit
FROM    ##TableA
GROUP BY Fruit;
```

| Fruit  | Count_Star | Count_Fruit |
|--------|------------|-------------|
| <NULL> |          2 |           0 |
| Apple  |          1 |           1 |
| Mango  |          2 |           2 |
| Peach  |          1 |           1 |

---------------------------------------------------------
### COUNT AND AVERAGE FUNCTION
:large_blue_circle: [Table Of Contents](#table-of-contents)

**ADD SOME TEXT HERE**
---------------------------------------------------------  
The `COUNT` function removes the NULL markers when a specified field is included in the function but counts the NULL markers when using the asterisk.

```sql
SELECT  Fruit,
        COUNT(*) AS Count_Star,
        COUNT(Fruit) AS Count_Fruit
FROM    ##TableA
GROUP BY Fruit;
```

| Fruit  | Count_Star | Count_Fruit |
|--------|------------|-------------|
| <NULL> |          2 |           0 |
| Apple  |          1 |           1 |
| Mango  |          2 |           2 |
| Peach  |          1 |           1 |

---------------------------------------------------------
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The `AVG` function will remove records with NULL markers in its calculation, as shown below.  For this example, we created the test data in the common table expression `cte_Average`, as this more easily demonstrates the functions behavior.

In `SQL Server`, when performing division between integers, you will need to use the `CAST` or `CONVERT` function on the values as shown below.

```sql
WITH cte_Average AS
(
SELECT 1 AS ID, 100 AS MyValue
UNION 
SELECT 2 AS ID, 100 AS MyValue
UNION 
SELECT 3 AS ID, NULL AS MyValue
UNION 
SELECT NULL AS ID, 100 AS MyValue
)
SELECT  SUM(MyValue) / CAST(COUNT(*) AS NUMERIC(10,2)) AS Average_CountStar,
        SUM(MyValue) / CAST(COUNT(ID) AS NUMERIC(5,2)) AS Average_CountId,
        AVG(CAST(MyValue AS NUMERIC(10,2))) AS Average_AvgFunction
FROM    cte_Average;
```

| Average_CountStar | Average_CountId | Average_AvgFunction |
|-------------------|-----------------|---------------------|
|   112.50000000000 |      150.000000 |          150.000000 |

--------------------------------------------------------- 
### CONSTRAINTS
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
SQL provides the following contraints; `NOT NULL`, `PRIMARY KEY`, `FOREIGN KEY`. `UNIQUE`, and `CHECK CONSTRAINTS`.
        
--------------------------------------------------------- 
**PRIMARY KEYS**

The `PRIMARY KEY` syntax will create a `CLUSTERED INDEX` unless specified otherwise.  The following statements will error as a `PRIMARY KEY` does not allow for NULL markers.

```sql
ALTER TABLE ##TableA
ADD CONSTRAINT PK_NULLConstraints PRIMARY KEY NONCLUSTERED (Fruit);

ALTER TABLE ##TableA
ADD CONSTRAINT PK_NULLConstraints PRIMARY KEY CLUSTERED (Fruit);
```
❗
>Msg 8111, Level 16, State 1, Line 1
>Cannot define PRIMARY KEY constraint on nullable column in table '##TableA'.
>Msg 1750, Level 16, State 0, Line 1
>Could not create constraint or index. See previous errors.

--------------------------------------------------------- 
**UNIQUE**

To demonstrate that a `UNIQUE CONSTRAINT` allows only one NULL marker we can run the following statement.  We add a `UNIQUE CONSTRAINT` to `##TableB`, which already includes a NULL marker in the column Fruit. 

```sql
ALTER TABLE ##TableB
ADD CONSTRAINT UNIQUE_NULLConstraints UNIQUE (Fruit);
GO

INSERT INTO ##TableB(Fruit) VALUES (NULL);
GO
```

The second statement produces the following error.     
>:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Msg 2627, Level 14, State 1, Line 5
Violation of UNIQUE KEY constraint 'UNIQUE_NULLConstraints'. Cannot insert duplicate key in object 'dbo.##TableB'. The duplicate key value is (<NULL>).

--------------------------------------------------------
**CHECK CONSTRAINTS**

To demonstrate `CHECK CONSTRAINTS`, let's start by creating a new table with the constraints.  The below insert does not error and allows for the operation to take place.

```sql
DROP TABLE IF EXISTS ##CheckConstraints;
GO

CREATE TABLE ##CheckConstraints
(
ID            INTEGER,
MyField       INTEGER,
CONSTRAINT Check_NULLConstraints CHECK (MyField > 0)
);
GO

INSERT INTO ##CheckConstraints (ID, MyField) VALUES (1,NULL);
GO

SELECT * FROM ##CheckConstraints;
```

| ID | MyField |
|----|---------|
|  1 | <NULL>  |

---------------------------------------------------------
### REFERENTIAL INTEGRITY
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Multiple NULL markers can be inserted into the child column or a `FOREIGN KEY` constraint.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In `SQL Server`, a `FOREIGN KEY` constraint must be linked to a column with either a `PRIMARY KEY` constraint or a `UNIQUE` constraint defined on the column.  A `PRIMARY KEY` constraint does not allow NULL markers, but a `UNIQUE` constraint allows one NULL marker.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In the below example, we demonstrate that multiple NULL markers can be inserted into a child column that references another column only if the referenced column has a `UNIQUE CONSTRAINT` on the table.  

Referential integrity cannot be created on temporary tables, so for this example we create two tables in the dbo schema named `Parent` and `Child`.

```sql
DROP TABLE IF EXISTS dbo.Child;
DROP TABLE IF EXISTS dbo.Parent;
GO

CREATE TABLE dbo.Parent
(
ParentID INTEGER PRIMARY KEY
);
GO

CREATE TABLE dbo.Child
(
ChildID INTEGER FOREIGN KEY REFERENCES dbo.Parent (ParentID)
);
GO

INSERT INTO dbo.Parent VALUES (1),(2),(3),(4),(5);
GO

INSERT INTO dbo.Child VALUES (1),(2),(NULL),(NULL);
GO

SELECT * FROM dbo.Parent;
SELECT * FROM dbo.Child;
```

**Parent**
| ParentID |
|----------|
|        1 |
|        2 |
|        3 |
|        4 |
|        5 |

  
**Child**
| ChildID |
|---------|
| 1       |
| 2       |
| <NULL>  |
| <NULL>  |

  
---------------------------------------------------------
### COMPUTED COLUMNS
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A computed column is a virtual column that is not physically stored in a table.  A computed column expression can use data from other columns to calculate a value.  When an expression is applied to a column with a NULL marker, a NULL marker will be the return value.   Here we add the value `2` to a the `Quantity` field in `TableB` (which includes a NULL marker in the `Quantity` field.

```sql
SELECT Fruit,
       Quantity + 2 AS QuantityPlus2
FROM   ##TableB;
```


| ID | Fruit  | QuantityPlus2 |
|----|--------|---------------|
|  1 | Apple  | 19            |
|  2 | Peach  | 27            |
|  3 | Kiwi   | 22            |
|  4 | <NULL> | <NULL>        |

-------------------------------------------------------------
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;When creating a table with a non-NULLable computed column, you must create the column as `PERSISTED`, else you will receive the error message:

> :exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Only `UNIQUE` or `PRIMARY KEY` constraints can be created on computed columns, while `CHECK`, `FOREIGN KEY`, and `NOT NULL` constraints require that computed columns be persisted.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;From this error message we can see there are several rules we need to follow on computed columns if we want to add `UNIQUE`, `PRIMARY KEY`, `FOREIGN KEY`, `CHECK` and `NOT NULL` constraints.

Here we add a `NOT NULL` constraint to a `PERSISTED` computed column and add a `PRIMARY KEY` to the column.

```sql
DROP TABLE IF EXISTS MyComputed;
GO

CREATE TABLE MyComputed
(
Int1 INTEGER NOT NULL,
Int2 INTEGER NOT NULL,
Int3 AS MyInt1 + MyInt2 PERSISTED NOT NULL
);

ALTER TABLE MyComputed ADD PRIMARY KEY CLUSTERED (Int3);

DROP TABLE IF EXISTS MyComputed;
GO
```
  
Commands completed successfully.
  
---------------------------------------------------------
### SQL FUNCTIONS 
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
Besides the `IS NULL` and `IS NOT NULL` predicate logic constructs, SQL also provides three functions to help evaluate NULL markers.

1.  `ISNULL`
2.  `COALESCE`
3.  `NULLIF`
  
`COALESCE` and `ISNULL` have several key differences that should be noted.  A full comparison can be found [here](https://www.mssqltips.com/sqlservertip/2689/deciding-between-coalesce-and-isnull-in-sql-server/).

The major differences between `COALESCE` and `ISNULL` from the documentation are:

1.  `COALESCE` behaves the same as a `CASE` statement, and therefore can accept multiple parameters and return a NULL marker.  `ISNULL` cannot return a NULL marker and accepts only two parameters.
2.  `COALESCE` determines the type of output based upon data type precedence.  ISNULL uses the data type of the first parameter.

---------------------------------------------------------
**COALESCE**
*  The `COALESCE` function returns the first non-NULL value among its arguments.  If all values are NULL, `COALESCE` returns a NULL marker.        
*  The basic usage of the function is `COALESCE(expression [ ,…n ])`       

---------------------------------------------------------
**ISNULL**     
 *  The `ISNULL` function replaces NULL with the specified replacement value.        
*  The basic usage of the function is `ISNULL(check_expression , replacement_value)`

---------------------------------------------------------        
**NULLIF**    
*  The `NULLIF` returns a NULL marker if the two specified expressions are equal.    
*  The basic usage of the function is `NULLIF(expression , expression)`

--------------------------------------------------------- 

Below I provide a few quick examples to note their behavior.

```sql
SELECT  1 AS ID,
        ISNULL(NULL, 'foo') AS fnISNULL,
        COALESCE(NULL, NULL, 'foo') AS fnCOALESCE,
        NULLIF('foo', 'foo') AS fnNULLIF
```

| Id | fnISNULL | fnCOALESCE | fnNULLIF |
|----|----------|------------|----------|
|  1 | foo      | foo        | <NULL>   |


---------------------------------------------------------
### EMPTY STRINGS, NULL, AND ASCII VALUES
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A useful feature to combat NULL markers in character fields is by using the empty string.  The empty string character is not an ASCII value, and the following function returns a NULL marker.  Also, you would assume the ASCII value for a NULL marker is 0 when reviewing an ASCII code chart, however this is not the case, and the `ASCII` function returns NULL for the NULL marker as shown below.  SQL does not use the standard ANSI NULL marker.

```sql
SELECT  1 AS ID,
        ASCII('') AS ASCII_EmptyString,
        ASCII(NULL) AS ASCII_NULL;
```

| ID | ASCII_EmptyString | ASCII_NULL |
|----|-------------------|------------|
|  1 | <NULL>            | <NULL>     |


---------------------------------------------------------
Any queries that join on a field with an empty string will equate to true.  Commonly the empty string is used with the ISNULL function, such as the following query.

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
|  5 | <NULL> |  4 | <NULL> |
|  6 | <NULL> |  4 | <NULL> |
  

---------------------------------------------------------
### CONCAT
:large_blue_circle: [Table Of Contents](#table-of-contents)

        
> :exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In `SQL Server`, the `SET CONCAT_NULL_YIELDS_NULL` database setting controls whether concatenation results are treated as NULL or empty string values.  In a future version of `SQL Server` `CONCAT_NULL_YIELDS_NULL` will always be `ON` and any applications that explicitly set the option to OFF will generate an error. Avoid using this feature in new development work, and plan to modify applications that currently use this feature.
       
The `CONCAT` function will return an empty string if all the values are NULL.
  
 
```sql
SELECT 1 AS ID, CONCAT(NULL,NULL,NULL) AS fnConcat;
```
 

| ID |    fnConcat     |
|----|-----------------|
|  1 | \<empty string> |

---------------------------------------------------------
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This feature of `CONCAT` is especially helpful when you want to join to a table on multiple fields (with multiple data types) where NULL markers and empty strings are not used consistently in the tables, as shown below.  You can include fields with different data types into the `CONCAT` function as this function performs an implicit data type conversion.
 
```sql
WITH
cte_NULL AS 
(
SELECT 'NULL' AS MyType,
       NULL AS A,
       NULL AS B,
       NULL AS C
),
cte_EmptyString AS 
(
SELECT 'EmptyString' AS MyType,
       '' AS A,
       '' AS B,
       '' AS C)
SELECT *
FROM   cte_NULL a INNER JOIN 
       cte_EmptyString b ON CONCAT(a.A, a.B, a.C) = CONCAT(b.A, b.B, b.C);
```

---------------------------------------------------------
### VIEWS
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;When creating a view, if you perform a `CAST` function or create a computed column on a column which has a NOT NULL constraint, the result will yield a NULLable column.

Here we create a table with `NOT NULL` constraints and then create a view where we perform a `CAST` and create a computed column.  From the resulting screen shot, we can see the columns are NULLable.

```sql
DROP TABLE IF EXISTS MyTable;
GO

CREATE TABLE MyTable
(
MyInteger INT NOT NULL,
MyVarchar VARCHAR(100) NOT NULL,
MyDate DATE NOT NULL
);
GO

CREATE OR ALTER VIEW vwMyTable AS
SELECT  MyInteger,
        MyVarchar,
        MyDate,
        CAST(MyInteger AS INT) AS MyInteger_Cast,
        CAST(MyVarchar AS VARCHAR(100)) AS MyVarchar_Cast,
        CAST(MyDate AS DATETIME) AS MyDate_Cast,
        MyInteger * 10 AS MyInteger_Computed
FROM    MyTable;
GO

SELECT  c.name AS ColumnName,
        ty.name as DataType,
        c.is_nullable
FROM    sys.views t INNER JOIN
        sys.columns c ON t.object_id = c.object_id INNER JOIN
        sys.types ty ON ty.user_type_id = c.user_type_id
WHERE   t.name = 'vwMyTable' and c.is_nullable = 1
ORDER BY 1,2,3;
```

|     ColumnName     | DataType | is_nullable |
|--------------------|----------|-------------|
| MyDate_Cast        | datetime |           1 |
| MyInteger_Cast     | int      |           1 |
| MyInteger_Computed | int      |           1 |
| MyVarchar_Cast     | varchar  |           1 |

---------------------------------------------------------
### BOOLEAN VALUES
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
Here we will discuss two SQL constructs, the `BIT` data type and the `NOT` operator.

------------------------------------------------------------------
**BIT**    
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Often, we think of the `BIT` data type as being a Boolean value (true or false, yes or no, on or off, one or zero…), however NULL markers are allowed for the `BIT` data type making the possible values 1, 0 and NULL.  **The `BIT` data type in SQL is not a true Boolean value.**
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Because the only acceptable values for the `BIT` data type is 1, 0 or NULL.  The `BIT` data type converts any nonzero value to 1.  As discussed earlier, the NULL marker is neither a nonzero value nor a zero value, so it is not promoted to the value of 1.  Here we can demonstrate that behavior.

```sql   
SELECT 1 AS ID, CAST(NULL AS BIT) AS Bit
UNION
SELECT 2 AS ID, CAST(3 AS BIT) AS Bit;
```

| ID |  Bit   |
|----|--------|
|  1 | <NULL> |
|  2 | 1      |

------------------------------------------------------------------
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Much like NULL markers and duplicate tuples, there is much debate in the SQL community if the BIT data type should be a permissible data type, as its allowance for the NULL marker does not mimic the real world.  Joe Celko and C.J. Date advocate against using the BIT data type and give further details of this in many of their writings.
------------------------------------------------------------------   
**NOT**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The `NOT` operator negates a Boolean input.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here we can see how the `NOT` operator acts on our test data.  The distinct fruits in the table are Apple, Peach, Mango and NULL.  Placing the `NOT` operator on the predicate logic will return Apple and Peach, but the NULL marker is not returned.

```sql
--15.2
SELECT  *
FROM    ##TableA
WHERE   NOT(FRUIT = 'Mango');
```

| ID | Fruit | Quantity |
|----|-------|----------|
|  1 | Apple |       17 |
|  2 | Peach |       20 |

--------------------------------------------------------- 
### RETURN
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The `RETURN` statement exists unconditionally from a query or procedure.  All stored procedures return a value of 0 for a successful execution, and a nonzero value for a failure.  When the `RETURN` statement is used with a stored procedure, it cannot return a NULL marker.  If a procedure tries to return a NULL marker in the `RETURN` statement, a warning message is generated and a value of 0 is returned.

Here we will create a stored procedure that overrides the default `RETURN` value and attempt to return a NULL value.

```sql
CREATE OR ALTER PROCEDURE SpReturnStatement
AS
IF 1=2
    RETURN 1
ELSE
    RETURN NULL;
GO

DECLARE @return_status INT;

EXEC @return_status = SpReturnStatement;
SELECT 'Return Status' = @return_status;
```

The `SpReturnStatement` procedure attempted to return a status of NULL, which is not allowed. A status of 0 will be returned instead.

| Return Status |
|---------------|
|             0 |

--------------------------------------------------------- 
### CONCLUSION
:large_blue_circle: [Table Of Contents](#table-of-contents)
        
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Over the course of this document, we have touched on many of the SQL constructs and how they treat NULL markers.  I hope this document serves as a guiding document for future development, and most importantly, always remember to include NULL markers in your test data.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The most important concept to understand with NULL markers is the three-valued logic, where statements can equate to **TRUE**, **FALSE**, or **UNKNOWN**.  Understanding the three-valued logic is instrumental in understanding the behavior of NULL markers.  **TRUE OR UNKNOWN** equates to TRUE, and **TRUE AND UNKNOWN** equates to **UNKNOWN**.
 
https://advancedsqlpuzzles.com
