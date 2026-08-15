# ANY, ALL, and SOME

❗ **`SOME` and `ANY` are equivalent; for this document I will use `ANY`.**

`ANY`, `ALL`, and `SOME` compare a scalar value with a single column set of values. 

---------------------------------------------------------

## Understanding ANY, SOME, and ALL

`ANY`, `SOME`, and `ALL` compare one value with a list of values returned by a subquery.

The basic difference is simple:

- `ANY` means **at least one value**.
- `SOME` means **at least one value** and is identical to `ANY`.
- `ALL` means **every value**.

For example:

```sql
3 = ANY (1, 2, 3, 4)
```

This is true because `3` equals at least one value in the list.

```sql
3 = ALL (3, 3, 3, 3)
```

This is true because `3` equals every value in the list.

```sql
3 = ALL (1, 2, 3, 4)
```

This is false because `3` does not equal every value in the list.

`ANY`, `SOME`, and `ALL` are comparison keywords. They are not join types. They are normally used with a subquery inside an `IF`, `WHERE`, `HAVING`, `ON`, or `CASE` expression.

---------------------------------------------------------

## ANY and SOME

`ANY` and `SOME` mean exactly the same thing.

Both require the comparison to be true for at least one value returned by the subquery.

For example:

```sql
3 = ANY (query)
```

means:

```text
Does 3 equal at least one value returned by the query?
```

The following expression has the same meaning:

```sql
3 = SOME (query)
```

Because `ANY` is more commonly used, the examples below use `ANY`.

---------------------------------------------------------

## ALL

`ALL` requires the comparison to be true for every value returned by the subquery.

For example:

```sql
5 > ALL (query)
```

means:

```text
Is 5 greater than every value returned by the query?
```

If the query returns `1, 2, 3, 4`, the result is true.

---------------------------------------------------------

## Comparison Operators

The following comparison operators can be used with `ANY`, `SOME`, and `ALL`:

| Operator | Meaning                      |
|----------|------------------------------|
| `=`      | Equal to                     |
| `<>`     | Not equal to                 |
| `!=`     | Not equal to                 |
| `>`      | Greater than                 |
| `<`      | Less than                    |
| `>=`     | Greater than or equal to     |
| `<=`     | Less than or equal to        |
| `!<`     | Not less than                |
| `!>`     | Not greater than             |

Some of these operators have the same meaning:

```text
!=  is the same as  <>
!<  is the same as  >=
!>  is the same as  <=
```

---------------------------------------------------------

## Common Equivalents

The following table shows familiar ways to express the most common `ANY` and `ALL` conditions:    
| Id | Operation                             | Common equivalent                           | Description                                       |
|----|---------------------------------------|---------------------------------------------|---------------------------------------------------|
| 1  | x = ALL (query)                       | NOT EXISTS (query WHERE value <> x)         | Does x equal every value in the set?              |
| 2  | x <> ALL (query)                      | NOT EXISTS (query WHERE value = x) / NOT IN | Does x differ from every value in the set?        |
| 3  | x > ALL (query)                       | x > MAX(value)                              | Is x greater than every value in the set?         |
| 4  | x < ALL (query)                       | x < MIN(value)                              | Is x less than every value in the set?            |
| 5  | x = ANY (query)                       | EXISTS (query WHERE value = x) / IN         | Does x equal at least one value in the set?       |
| 6  | x <> ANY (query)                      | EXISTS (query WHERE value <> x)             | Does x differ from at least one value in the set? |
| 7  | x > ANY (query)                       | x > MIN(value)                              | Is x greater than at least one value in the set?  |
| 8  | x < ANY (query)                       | x < MAX(value)                              | Is x less than at least one value in the set?     |
| 9  | x >= ANY (query) AND x <= ANY (query) | x BETWEEN MIN(value) AND MAX(value)         | Is x greater than or equal to at least one value and less than or equal to at least one value in the set? |

---------------------------------------------------------

## Easy Way to Remember Them

Use these two questions:

```text
ANY: Is the comparison true for at least one value?
ALL: Is the comparison true for every value?
```

For example:

```sql
3 <> ANY (1, 2, 3, 4)
```

asks:

```text
Is 3 different from at least one value?
```

The answer is true because `3` differs from `1`, `2`, and `4`.

However:

```sql
3 <> ALL (1, 2, 3, 4)
```

asks:

```text
Is 3 different from every value?
```

The answer is false because one of the values is `3`.

---------------------------------------------------------

## Important Note About NULL and Empty Results

The equivalents involving `MIN`, `MAX`, `EXISTS`, and `NOT EXISTS` are easiest to use when the subquery:

- Returns at least one row
- Does not contain `NULL`

`NULL` values and empty result sets can change the result because SQL uses three possible logical results:

```text
TRUE
FALSE
UNKNOWN
```

For introductory examples, using a nonempty list without `NULL` makes the behavior of `ANY`, `SOME`, and `ALL` much easier to understand.

---------------------------------------------------------------

# SQL Server: ALL and ANY Examples

> Unless otherwise stated, the `MIN`/`MAX` equivalents assume that the
> subquery returns at least one row and contains no `NULL` values.
>
> SQL Server treats `UNKNOWN` the same as `FALSE` when evaluating an `IF`
> condition, causing the `ELSE` branch to execute.

---------------------------------------------------------------

### PART 1
**= ALL (Equal To Every Value)**

`= ALL` is true when the value equals every value returned by the subquery.

```sql
-- TRUE
IF 3 = ALL (
    SELECT ID
    FROM (VALUES (3), (3), (3), (3)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

```sql
-- FALSE
IF 3 = ALL (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent `NOT EXISTS` statement:

```sql
-- TRUE
IF NOT EXISTS (
    SELECT 1
    FROM (VALUES (3), (3), (3), (3)) AS a(ID)
    WHERE ID <> 3
       OR ID IS NULL
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

The `ID IS NULL` condition is needed because a `NULL` prevents
`3 = ALL (...)` from being true.

---------------------------------------------------------------

### PART 2
**<> ALL (Not Equal To Every Value)**

`<> ALL` is true when the value differs from every value returned by the
subquery.

```sql
-- TRUE
IF 5 <> ALL (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

```sql
-- FALSE
IF 3 <> ALL (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent `NOT IN` statement:

```sql
-- TRUE
IF 5 NOT IN (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent `NOT EXISTS` statement for a non-NULL comparison value:

```sql
-- TRUE
IF NOT EXISTS (
    SELECT 1
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
    WHERE ID = 5
       OR ID IS NULL
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 3
**> ALL (Greater Than Every Value)**

`> ALL` is true when the value is greater than every value returned by
the subquery.

```sql
-- TRUE
IF 5 > ALL (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent statement for a nonempty, non-NULL set:

```sql
-- TRUE
IF 5 > (
    SELECT MAX(ID)
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 4
**< ALL (Less Than Every Value)**

`< ALL` is true when the value is less than every value returned by the
subquery.

```sql
-- TRUE
IF 1 < ALL (
    SELECT ID
    FROM (VALUES (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

```sql
-- FALSE
IF 3 < ALL (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent statement for a nonempty, non-NULL set:

```sql
-- TRUE
IF 1 < (
    SELECT MIN(ID)
    FROM (VALUES (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 5
**= ANY (Equal To At Least One Value)**

`= ANY` is true when the value equals at least one value returned by the
subquery.

```sql
-- TRUE
IF 3 = ANY (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent `IN` statement:

```sql
-- TRUE
IF 3 IN (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent `EXISTS` statement:

```sql
-- TRUE
IF EXISTS (
    SELECT 1
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
    WHERE ID = 3
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 6
**<> ANY (Not Equal To At Least One Value)**

`<> ANY` is true when the value differs from at least one value returned
by the subquery.

```sql
-- TRUE
IF 3 <> ANY (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

It is true because `3` differs from at least one value in the set.

```sql
-- FALSE
IF 3 <> ANY (
    SELECT ID
    FROM (VALUES (3), (3), (3), (3)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent statement using `NOT` and `ALL`:

```sql
-- TRUE
IF NOT (
    3 = ALL (
        SELECT ID
        FROM (VALUES (1), (2), (3), (4)) AS a(ID)
    )
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent `EXISTS` statement for the shown non-NULL data:

```sql
-- TRUE
IF EXISTS (
    SELECT 1
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
    WHERE ID <> 3
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

When `NULL` is present, the `EXISTS` version can return `FALSE` where
`<> ANY` returns `UNKNOWN`. Both results execute the `ELSE` branch inside
an `IF`, but they are not identical under SQL's three-valued logic.

---------------------------------------------------------------

### PART 7
**> ANY (Greater Than At Least One Value)**

`> ANY` is true when the value is greater than at least one value
returned by the subquery.

```sql
-- TRUE
IF 3 > ANY (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent statement for a nonempty, non-NULL set:

```sql
-- TRUE
IF 3 > (
    SELECT MIN(ID)
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 8
**< ANY (Less Than At Least One Value)**

`< ANY` is true when the value is less than at least one value returned
by the subquery.

```sql
-- TRUE
IF 3 < ANY (
    SELECT ID
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent statement for a nonempty, non-NULL set:

```sql
-- TRUE
IF 3 < (
    SELECT MAX(ID)
    FROM (VALUES (1), (2), (3), (4)) AS a(ID)
)
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

---------------------------------------------------------------

### PART 9
**>= ANY AND <= ANY**

This asks whether the value is:

1. Greater than or equal to at least one value; and
2. Less than or equal to at least one value.

The two conditions do not have to be satisfied by the same row.

```sql
-- TRUE
IF 9 >= ANY (
       SELECT ID
       FROM (VALUES (1), (2), (3), (10)) AS a(ID)
   )
   AND
   9 <= ANY (
       SELECT ID
       FROM (VALUES (1), (2), (3), (10)) AS a(ID)
   )
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

Equivalent statement for a nonempty, non-NULL set:

```sql
-- TRUE
IF 9 BETWEEN
    (
        SELECT MIN(ID)
        FROM (VALUES (1), (2), (3), (10)) AS a(ID)
    )
    AND
    (
        SELECT MAX(ID)
        FROM (VALUES (1), (2), (3), (10)) AS a(ID)
    )
    PRINT 'TRUE';
ELSE
    PRINT 'FALSE';
```

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
