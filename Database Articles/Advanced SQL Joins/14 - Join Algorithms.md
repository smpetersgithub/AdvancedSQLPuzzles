# Join Algorithms

SQL expresses **logical joins** such as `INNER JOIN`, `LEFT OUTER JOIN`, and left semi-joins. SQL Server must then choose one or more **physical algorithms** to execute those logical operations.

The principal physical join algorithms are:

- Nested Loops;
- Merge Join;
- Hash Match; and
- batch mode Adaptive Join.

The query text normally specifies the logical result, not the physical algorithm. During compilation, the SQL Server Query Optimizer considers alternative plans and selects a plan with a low estimated cost from the alternatives it explores. That decision depends on factors such as:

- estimated input and output row counts;
- indexes and available ordering;
- join predicates and data types;
- statistics, selectivity, and data distribution;
- memory and parallelism choices; and
- the cost of scans, seeks, sorts, exchanges, and other supporting operators.

The chosen plan is not guaranteed to be the fastest possible plan. Optimization is cost-based, relies on estimates, and operates within practical search limits. Stale statistics, skewed data, parameter-sensitive workloads, or inaccurate cardinality estimates can lead to a poor algorithm choice.

## Algorithm Comparison

| Algorithm | Commonly effective when | Important costs or risks |
|-----------|-------------------------|--------------------------|
| Nested Loops | The outer input is small and the inner input has an efficient access path, often an index seek | The inner operation is repeated for each outer row; unexpectedly large outer inputs can make it expensive |
| Merge Join | Both inputs are already ordered on compatible equality keys and substantial portions of both inputs are needed | Missing order may require expensive sorts; duplicate keys can require additional many-to-many processing |
| Hash Match | Inputs are relatively large, useful ordering or indexes are absent, and an equality key is available | Requires a memory grant; insufficient memory can cause partitioning and spills to `tempdb` |
| Adaptive Join | Runtime row counts may vary enough that either Nested Loops or Hash Match could be preferable | Requires an eligible batch mode plan and carries some runtime decision overhead |

These are useful tendencies, not rules. The complete plan and workload determine which algorithm is best.

## Nested Loops

A Nested Loops operator has an outer input and an inner input:

1. SQL Server reads a row from the outer input.
2. It executes or searches the inner input for matching rows.
3. It repeats that inner operation for every outer row.

Nested Loops is particularly effective when the outer input is small and the inner input can use a selective index seek. It is common in transactional queries that retrieve a small number of rows.

The plan's **Actual Number of Rows** and **Actual Number of Executions** properties are especially important. An inner seek that is inexpensive once can become costly when inaccurate estimates cause it to execute thousands or millions of times.

SQL Server can use several Nested Loops variants:

- a naive form that repeatedly scans the inner source;
- an index form that seeks into a preexisting index;
- a temporary-index form that builds an index for the query; and
- an optimized form that can reorder outer rows to improve inner-side I/O locality.

## Merge Join

A Merge Join reads two inputs that are ordered on compatible join keys. It advances through those ordered streams, comparing the current keys and returning rows according to the logical join operation.

Merge Join can be efficient for large inputs when suitable indexes already provide the required order. It can also support useful plan ordering for later operations.

If an input is not already ordered, SQL Server may add a `Sort`. The cost, memory grant, and possible spill associated with that sort can outweigh the benefit of the merge algorithm.

Duplicate join keys require special handling. A many-to-many Merge Join can use a worktable to retain duplicate rows from one input while it finds all matching combinations from the other input.

## Hash Match

For a hash join, SQL Server generally performs two phases:

1. **Build:** read one input and create a hash table using the equality join key.
2. **Probe:** hash each row from the other input and search the corresponding hash bucket for matches.

Hash joins are often effective for large, unsorted inputs when useful indexes are unavailable. They can implement inner, outer, semi, and anti joins, provided an appropriate equality key is available; additional predicates can be evaluated as residual conditions.

The in-memory hash table requires a memory grant. If it does not fit in the available memory, SQL Server can partition data and spill work to `tempdb`. In an actual execution plan, inspect warnings, spill details, granted versus used memory, and discrepancies between estimated and actual build-input rows.

Hash Match is a general physical operator and can also perform aggregation or distinct set processing. Seeing `Hash Match` in a plan does not by itself prove that the operator is a join; inspect its logical operation and properties.

## Batch Mode Adaptive Join

Batch mode Adaptive Join was introduced in SQL Server 2017. It allows one cached plan to defer the runtime choice between Nested Loops and Hash Match until the first, or build, input has been scanned.

During compilation, SQL Server calculates an **Adaptive Threshold Rows** value:

- below the threshold, the operator switches to the Nested Loops path;
- at or above the threshold, it continues with the Hash Match path.

If the operator chooses Nested Loops, it can reuse the build rows it already read rather than reading that input again.

Adaptive Join is most useful when the build-side row count can vary substantially between executions or when estimates near the decision boundary are uncertain.

### Eligibility

An Adaptive Join does not appear merely because SQL Server 2017 or later is installed. Current documented eligibility conditions include:

- database compatibility level 140 or higher;
- a `SELECT` statement;
- a logical join that is eligible for both an indexed Nested Loops plan and a Hash Match plan;
- a Hash Match alternative that can execute in batch mode, through a columnstore path or batch mode on rowstore; and
- compatible first-child plan shapes for the two alternatives.

The optimizer may still select a nonadaptive plan when an Adaptive Join is eligible but not estimated to be beneficial.

### Execution-Plan Properties

An Adaptive Join operator exposes properties including:

- **Adaptive Threshold Rows**: the build-row boundary used for the runtime decision;
- **Estimated Join Type**: the algorithm expected during compilation; and
- **Actual Join Type**: the algorithm selected during execution.

An estimated plan can show the adaptive shape and threshold, but only an actual execution plan can report the algorithm chosen for that execution.

## Inspecting an Execution Plan

The graphical operator names commonly appear as:

- `Nested Loops`;
- `Merge Join`;
- `Hash Match`; and
- `Adaptive Join`.

Do not evaluate the join operator in isolation. Inspect its inputs and supporting operators as well. Useful properties include:

- estimated versus actual row counts;
- number of executions;
- seek and scan predicates;
- residual predicates;
- input ordering and explicit sorts;
- memory grants and spill warnings;
- parallel exchanges;
- actual elapsed time and CPU time, where available; and
- the Adaptive Join threshold and actual join type.

The **actual execution plan** is usually more useful for diagnosing a completed execution because it includes runtime row counts and warnings. The estimated plan is still useful when executing the statement would be unsafe or expensive.

## Influencing the Choice With Hints

SQL Server provides query-level join hints:

```sql
OPTION (LOOP JOIN);
OPTION (MERGE JOIN);
OPTION (HASH JOIN);
```

A query-level hint constrains all join operations in that statement to the specified algorithm, or to the allowed algorithms when more than one is supplied.

A join hint can instead target a particular table pair:

```sql
SELECT order_header.OrderID,
       customer.CustomerName
FROM dbo.OrderHeader AS order_header
INNER HASH JOIN dbo.Customer AS customer
    ON customer.CustomerID = order_header.CustomerID;
```

The table and column names above are illustrative. A pair-level join hint can also constrain join ordering in a multi-table query, so its effect may be broader than the individual operator appears to suggest.

Hints should be a last resort after investigating the cause of the plan choice. Before forcing an algorithm, check:

- cardinality estimates and statistics;
- missing or unsuitable indexes;
- implicit conversions and non-sargable predicates;
- parameter sensitivity;
- memory-grant and spill behavior; and
- whether a query or schema rewrite fixes the underlying problem.

A forced algorithm can help one parameter value and harm another, prevent Adaptive Join behavior, or make compilation fail when SQL Server cannot produce a valid plan under the imposed restrictions. If a hint is necessary, document the evidence, test representative workloads, and monitor it after data or version changes.

## Official References

- [Joins in SQL Server](https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins)
- [Query hints in Transact-SQL](https://learn.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-query)
- [Join hints in Transact-SQL](https://learn.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-join)

## Continue Reading

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

[Advanced SQL Puzzles](https://advancedsqlpuzzles.com)
