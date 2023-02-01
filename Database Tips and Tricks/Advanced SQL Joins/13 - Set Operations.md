# SET Operations

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SQL set operations refer to the methods used to combine the result sets of two or more SELECT statements into a single result set. The common set operations in SQL are UNION, UNION ALL, INTERSECT, and EXCEPT. The UNION operation returns distinct rows from both the sets, while UNION ALL returns all rows including duplicates. INTERSECT returns only the common rows present in both sets. EXCEPT returns the rows present in the first set but not in the second set. These operations help to retrieve and manipulate data in an organized manner and are an important aspect of SQL programming.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The difference between a join and set operation, is that although both concepts are used to combine data from multiple tables, a join combines columns from separate relations, whereas set operations combine rows.  The SQL standard for set operators does not use the term EQUAL TO or NOT EQUAL TO when describing their behavior but instead uses the terminology of IS [NOT] DISTINCT FROM and NULLS are treated as equalities in the context of SET operators.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SQL only supports the intersection, union, and relative complement in set theory (with the constructs INTERSECT, UNION, and MINUS/DIFFERENCE).  SQL does not have constructs for the symmetric difference or the absolute complement.  The ANSI standard set operation in SQL for returning the rows present in the first set but not in the second set is EXCEPT. The use of MINUS or DIFFERENCE is also prevalent but it is not part of the ANSI standard.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here are some examples of set operators in SQL and how they interact with the NULL markers in our example tables.

-----------------------------------------------------------------

#### Note on Venn Diagrams

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We often think of Venn Diagrams for both SET operations and JOIN operations,  Venn Diagrams are good for set theory , but often Venn diagrams are used for pedagogical reasons to quickly show the behavior of INNER, RIGHT OUTER, LEFT OUTER, FULL OUTER, and CROSS joins.  However, they are not well suited for representing complex relationships that can exist between tables in a relational database.  While Venn diagrams can be used to show the overlap between two sets of data, they cannot easily convey the specific conditions that are being used to filter the data and can become very complex and difficult to read as the number of tables and join conditions increases.  Venn diagrams are intended to show traditional SET operations and not JOIN operations.  A good example of the limitation in Venn diagrams is that it is not able to show the CROSS JOIN properly and how duplicate records can get introduced into the resulting dataset.

-----------------------------------------------------------------
#### UNION

UNION will return all rows without duplication.  Here the UNION interprets the NULLS as similar and combines the record into one. The UNION operator demonstrates that NULL is not distinct from NULL.

```sql
SELECT Fruit FROM ##TableA
UNION
SELECT Fruit FROM ##TableB;
```

| Fruit  |
|--------|
| <NULL> |
| Apple  |
| Kiwi   |
| Mango  |
| Peach  |

-----------------------------------------------------------------
  
#### UNION ALL

The UNION ALL operator returns all values including each NULL marker.

```sql
SELECT Fruit FROM ##TableA
UNION ALL
SELECT Fruit FROM ##TableB;
``` 

| Fruit  |
|--------|
| Apple  |
| Peach  |
| Mango  |
| <NULL> |
| Apple  |
| Peach  |
| Kiwi   |
| <NULL> |

---------------------------------------------------------------------

INTERSECT will return matching rows and the NULL marker is included in the output.  
  
```sql
SELECT Fruit FROM ##TableA
INTERSECT
SELECT Fruit FROM ##TableB;
```

| Fruit  |
|--------|
| <NULL> |
| Apple  |
| Peach  |

---------------------------------------------------------------------

EXCEPT will return the records in the table in the first statement that do not exist in the second statement below it.  Some SQL languages use MINUS or DIFFERENCE instead of EXCEPT.  

```sql
SELECT Fruit FROM ##TableA
EXCEPT
SELECT Fruit FROM ##TableB;
```

| Fruit |
|-------|
| Mango |

---------------------------------------------------------------------

#### Symmetric Difference

There is no SQL SET operation to find the symmetric difference of a dataset.  You can use a FULL OUTER JOIN to find the symmetric difference of two datasets using the ISNULL function.

This SQL statement returns the records that are in Table A but not in Table B along with the records in Table B that are not in Table A. The result set will include two NULL markers as NULLs.
  
```sql
SELECT  ISNULL(a.ID, b.ID) AS ID,
        ISNULL(a.Fruit, b.Fruit) AS Fruit
FROM    ##TableA a FULL OUTER JOIN
        ##TableB b ON a.Fruit = b.Fruit
WHERE   a.ID IS NULL OR B.ID IS NULL;
```


| ID | Fruit |
|----|-------|
|  3 | Mango |
|  4 |       |
|  3 | Kiwi  |
|  4 |       |

---------------------------------------------------------------------  
  
  
  
