### SQL Query Processing Order

-----

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To best understand the processing order of an SQL statement, consider the diagram.     


![SQL Processing Order](/Database%20Tips%20and%20Tricks/Advanced%20SQL%20Joins/images/SQLQueryProcessingOrderPage.png)


  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SQL does not process the query in the order in which it is written, as the SELECT statement is processed almost last.  The correct processing order is FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY and LIMIT.  Once a query first enters the FROM statement, there are four types of table operators, JOIN, APPLY, PIVOT, and UNPIVOT that can be performed, and each of these operators has a series of subphases.

Processing order of a SQL statement:

| Order |   Syntax  |                                         Description                                         |
|-------|-----------|---------------------------------------------------------------------------------------------|
|     1 |  FROM     |  Specifies a table, view, table variable, or derived table source, with or without an alias |
|     2 |  WHERE    |  Specifies the search condition for the rows returned by the query                          |
|     3 |  GROUP BY |  Specifies the records in which to group on                                                 |
|     4 |  HAVING   |  Restricts the results of a GROUP BY                                                        |
|     5 |  SELECT   |  Specifies which values are to be returned                                                  |
|     6 |  ORDER BY |  Specifies which values to order the result set by                                          |
|     7 |  LIMIT    |  Constrains the number of rows returned by a SELECT statement                               |

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A join can take place within the SELECT, FROM, and WHERE clauses of an SQL statement and the join logic can be specified in the FROM and WHERE clauses.  I will cover the various methods of joining tables in the individual markdown notebooks.

The four table operators and their suboperations are:

| Operator |                      SubPHases                          |
|----------|---------------------------------------------------------|
| JOIN     |  1) Cartesian Product 2) ON Predicate 3) Add Outer Rows |
| APPLY    |  1) Apply Table Expression 2) Add Outer Rows            |
| PIVOT    |  1) Group 2) Spread 3) Aggregate                        |
| UNPIVOT  |  1) Generate Copies 2) Extract Element 3) Remove NULLs  |

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The PIVOT and UNPIVOT are two operators in SQL Server that are used to generate multi-dimensional reports. The APPLY operator is used when you want to return values from a table-valued function.
From the diagram we can determine there is only one true type of table join, the cartesian product.  INNER and OUTER JOINS are restricted cartesian products where the ON predicate specifies the restriction.  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To best understand that joins are simply restricted cartesian products, the following two statements below produce the exact same result set.  The first statement uses an INNER JOIN, and the second statement uses the CROSS JOIN syntax.  If we were to remove the join logic from the ON clause on the INNER JOIN, an error would occur.  If the join logic is removed from the CROSS join, a full cartesian product is created.  Both statements use an equi-join to filter the result set to all records that have a Customer ID equal in both the Customers and Orders table.  Because the CROSS JOIN has an ON statement specifying how to join the tables, this join acts as an INNER JOIN.     

```sql
--Statement 1
SELECT  *
FROM    Customers emp INNER JOIN
        Orders ord ON emp.CustomerID = ord.CustomerID;

--Statement 2
SELECT  *
FROM    Customers emp CROSS JOIN
        Orders ord ON emp.CustomerID = ord.CustomerID;
```

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The biggest difference between INNER, OUTER, and CROSS JOINS is that the INNER JOIN acts as a filtering criterion, OUTER JOIN acts as a matching criterion, and a CROSS JOIN gives all possible combinations.
  
* For INNER joins, the join logic acts as a filter where both columns need to equate to each other, thus restricting the output to only the records that have these matching column values. 
* For OUTER JOINS, the join logic acts as a matching criterion, where the record count output is not affected by this join logic as it will display the results from the preserved table.
* A CROSS JOIN creates a cartesian product.  It combines each row from the first table with each row from the second table.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For INNER and OUTER JOINS, these types of joins require a comparison operator to equate rows from the participating tables based on a common field in both the tables.  These comparison operators are described as equi-joins and theta-joins.  Many of these types of joins are rooted in relational algebra.  Introduced by Edgar F. Codd in 1970, relational algebra uses algebraic structures with a well-founded semantics for modeling data and defining queries on it.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lastly, SQL is a declarative language, meaning you tell the SQL engine WHAT to do, and not HOW to do it.  When a table operation is being performed, the SQL engine decides the best method for physically joining the tables (called a join algorithm).  These join algorithms are used to optimize the performance of a query when performing a join operation and are based on the table size, type of data they contain, available index, table statistics.
