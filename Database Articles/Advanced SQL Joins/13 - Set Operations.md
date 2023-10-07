# Set Operations

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SQL set operations refer to the methods used to combine the result sets of two or more `SELECT` statements into a single result set. The set operations in SQL are `UNION`, `UNION ALL`, `INTERSECT`, and `EXCEPT`. The `UNION` operation returns distinct rows from both sets, while `UNION ALL` returns all rows, including duplicates. `INTERSECT` returns only the common rows present in both sets. `EXCEPT` returns the rows present in the first set but not in the second set. These operations help to retrieve and manipulate data in an organized manner and are an essential aspect of SQL programming.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The difference between joins and set operations is that although both concepts are used to combine data from multiple tables, a join combines columns, whereas set operations combine rows.  The SQL standard for set operators does not use the terms "EQUAL TO" or "NOT EQUAL TO" when describing their behavior but instead uses the terminology of "IS [NOT] DISTINCT FROM" and NULLS are treated as equalities in the context of set operators.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SQL only supports the intersection, union, and relative complement in set theory (with the constructs `INTERSECT`, `UNION`, and `EXCEPT`).  SQL does not have constructs for the symmetric difference or the absolute complement.  The ANSI standard set operation in SQL for returning the rows present in the first set but not in the second set is `EXCEPT`. The use of `MINUS` or `DIFFERENCE` is also prevalent, but it is not part of the ANSI standard.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here are some examples of set operators in SQL and how they interact with the NULL markers in our example tables.

-----------------------------------------------------------------

#### Note on Venn Diagrams

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We often think of Venn Diagrams for both set operations and join operations,  Venn Diagrams are good for set theory but poor for join theory.  Often Venn diagrams are used for pedagogical reasons to quickly show the behavior of `INNER`, `RIGHT OUTER`, `LEFT OUTER`, and `FULL OUTER JOINs`.  However, they are not well suited for representing complex relationships that can exist between tables in a relational database.  While Venn diagrams can show the overlap between two sets of data, they cannot easily convey the specific conditions used to filter the data. They can become very complex and difficult to read as the number of tables and join conditions increases.  Simply put, Venn diagrams are intended to show traditional set operations and not join operations.  Some of the limitations of Venn Diagrams include their inability to accurately depict `CROSS JOIN`s, semi and anti-joins, as well as the introduction of duplicate records in the resulting dataset.

❗&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A good resource that I have found that provides a more accurate graphical representation of different SQL joins can be found in the book "R for Data Science" by Hadley Wicham and Garrett Grolemund. The chapter on relational data contains these improved graphics, which can be accessed through the following link. Due to potential copyright issues, I will not display the diagrams. Still, they are worth examining, and it is hoped that they will become the standard for representing SQL joins graphically.

Link to the chapter: https://r4ds.had.co.nz/relational-data.html (The improved join representations are located approximately halfway through the chapter.)

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
  
-----------------------------------------------------------------
#### UNION

`UNION` will return all rows without duplication.  Here, the `UNION` interprets the NULLS as similar and combines the record into one. The `UNION` operator demonstrates that NULL is not distinct from NULL.

```sql
SELECT ID, Fruit FROM ##TableA
UNION
SELECT ID, Fruit FROM ##TableB;
```


| ID | Fruit |
|----|-------|
| 1  | Apple |
| 2  | Peach |
| 3  | Kiwi  |
| 3  | Mango |
| 4  | \<NULL>  |

-----------------------------------------------------------------
  
#### UNION ALL

The `UNION ALL` operator returns all values, including each NULL marker.

```sql
SELECT ID, Fruit FROM ##TableA 
UNION ALL
SELECT ID, Fruit FROM ##TableB
``` 
  
| ID |  Fruit  |
|----|---------|
| 1  | Apple   |
| 1  | Apple   |
| 2  | Peach   |
| 2  | Peach   |
| 3  | Kiwi    |
| 3  | Mango   |
| 4  | \<NULL> |
| 4  | \<NULL> |

---------------------------------------------------------------------

`INTERSECT` will return matching rows, and the NULL marker is included in the output.  
  
```sql
SELECT ID, Fruit FROM ##TableA
INTERSECT
SELECT ID, Fruit FROM ##TableB
```

  
| ID |  Fruit  |
|----|---------|
| 1  | Apple   |
| 2  | Peach   |
| 4  | \<NULL> |

---------------------------------------------------------------------

`EXCEPT` will return the records in the table in the first statement that do not exist in the second statement below it.  Some SQL languages use `MINUS` or `DIFFERENCE` instead of `EXCEPT`.  

```sql
SELECT ID, Fruit FROM ##TableA
EXCEPT
SELECT ID, Fruit FROM ##TableB;
```
  
| ID | Fruit |
|----|-------|
| 3  | Mango |

---------------------------------------------------------------------

#### Symmetric Difference

There is no SQL set operation to find the symmetric difference of a dataset.  You can use a `FULL OUTER JOIN` to find the symmetric difference of two datasets using the `ISNULL` function.

This SQL statement returns the records that are in `TableA` but not in `TableB` along with the records in `TableB` that are not in `TableA`. The result set will include two NULL markers.  Note that the predicate logic is placed on the `ID` column which has a `NOT NULL` constraint.
  
```sql
SELECT  ISNULL(a.ID, b.ID) AS ID,
        ISNULL(a.Fruit, b.Fruit) AS Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.ID IS NULL OR B.ID IS NULL;
```
    
| ID |  Fruit  |
|----|---------|
| 3  | Mango   |
| 4  | \<NULL> |
| 3  | Kiwi    |
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
  
  
