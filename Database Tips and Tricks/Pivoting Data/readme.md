# Pivoting Data

The `PIVOT` operator is a powerful feature in SQL, but often goes unused due to its complicated syntax.  

Here we simplify the syntax by encapsulating the pivot into a stored procedure allowing us to easy automate the creation of pivoted datasets. 

Under the hood the stored procedure uses `XML` and `DYNAMIC SQL` to accomplish its goal.

## Installation

**Step 1:**   
Create the stored procedure `SpPivotData` via the `SpPivotData.sql` script.

**Step 2:**   
Review example usages of the `SpPivotData` stored procedure in the `Pivot Data Examples.sql` script.

--------------------------------

Here is a basic execution of the `SpPivotData` stored procedure.

```sql
EXEC dbo.SpPivotData
     @vQuery = 'dbo.TestPivot',
     @vOnRows = 'TransactionType',
     @vOnColumns = 'TransactionDate',
     @vAggFunction = 'SUM',
     @vAggColumns = 'TotalTransactions';
```
