# Join Algorithms

There are several types of join algorithms that the SQL Server optimizer can choose from, including **Nested Loops Join**, **Hash Join**, **Merge Join**, and **Adaptive Join**. The choice of join algorithm depends on various factors, such as dataset size, index availability, data distribution, and estimated row counts. The optimizer makes a cost-based decision to choose the most efficient algorithm for the given query, returning results in the quickest possible time. These physical join algorithms are chosen by the SQL Server query optimizer, not the developer. However, you can influence the decision using query hints such as `OPTION (HASH JOIN)`, `LOOP JOIN`, or `MERGE JOIN`.

An **Adaptive Join**, introduced in SQL Server 2017, differs from the other join algorithms because it allows SQL Server to defer the choice between a Nested Loops Join and a Hash Join until query execution time. During execution, SQL Server evaluates the actual number of rows returned from one side of the join and selects the most efficient join strategy based on a predefined threshold. This can improve performance when row count estimates are uncertain or vary significantly between executions.

A detailed discussion of join algorithms, along with practical examples of how each one operates, is beyond the scope of this article. For now, it is sufficient to understand that SQL Server's query optimizer selects the most appropriate join algorithm based on its cost estimates and available metadata. In some cases, SQL Server may choose an Adaptive Join to allow the final join strategy to be determined at runtime.

To identify which join algorithm was chosen, examine the query's execution plan. Within the execution plan, the join operator will indicate whether SQL Server used a **Nested Loops**, **Hash Match**, **Merge Join**, or **Adaptive Join** operation. For Adaptive Joins, the execution plan also contains information about the runtime threshold and which join strategy was ultimately selected during execution.

---------------------------------------------------------------------
### Types Of Join Algorithms

Here is a brief overview of each join algorithm.

* A **Nested Loops Join** iterates over each row in the outer input and, for each row, searches for matching rows in the inner input. This method is most efficient when the outer input is small and the inner input can be accessed efficiently through an index.

* A **Merge Join** requires both inputs to be sorted on the join key. If the inputs are not already sorted, SQL Server may introduce an explicit sort operation. The join then efficiently traverses both inputs in order, comparing rows and returning matching results.

* A **Hash Join** is commonly used when joining large datasets, particularly when suitable indexes are not available. SQL Server builds an in-memory hash table from one input and then probes it using rows from the other input to find matching values. Although Hash Joins typically require more memory and CPU resources than Nested Loops or Merge Joins, they are often the most efficient choice for large, unsorted datasets.

* An **Adaptive Join**, introduced in SQL Server 2017, allows SQL Server to defer the choice between a Nested Loops Join and a Hash Join until execution time. During query execution, SQL Server evaluates the actual number of rows returned from the build input and selects the most efficient join strategy based on a predefined threshold. This can improve performance when row count estimates are uncertain or vary significantly between executions.

---------------------------------------------------------------------

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
