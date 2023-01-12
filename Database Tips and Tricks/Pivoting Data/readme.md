# Pivoting Data

The pivot operator is a powerful feature in SQL, but often goes unused due to its complicated syntax.  Here we simplify the syntax by encapsulating the pivot into a stored procedure. Under the hood the stored procedure uses XML and dynamic SQL to accomplish its goal.

## Installation

Inside this GitHub repository you will find the following SQL scripts:

1) SpPivotData.sql  
A script that creates the stored procedure SpPivotData

2) Pivot Data Examples.sql  
Example usages of the SpPivotData stored procedure.

## Usage

```sql
EXEC dbo.SpPivotData
     @vQuery = 'dbo.TestPivot',
     @vOnRows = 'TransactionType',
     @vOnColumns = 'TransactionDate',
     @vAggFunction = 'SUM',
     @vAggColumns = 'TotalTransactions';
```
