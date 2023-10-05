# Pivoting Data

The `PIVOT` operator is a powerful feature in SQL but often goes unused due to its complicated syntax.  

⌨️&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This script is written in Microsoft SQL Server T-SQL.

## Overview    

In the script `SpPivotData.sql`, we simplify the `PIVOT` table operator syntax by encapsulating the pivot into a stored procedure, allowing us to automate the creation of pivoted datasets easily. 

Under the hood, the stored procedure uses `XML` and `DYNAMIC SQL` to accomplish its goal.

## Installation

**Step 1:**   
Create the stored procedure `SpPivotData` via the `SpPivotData.sql` script.

**Step 2:**   
Review example usages of the `SpPivotData` stored procedure in the `Pivot Data Examples.sql` script.

## Example Usage

Here is a basic execution of the `SpPivotData` stored procedure.

```sql
EXEC dbo.SpPivotData
     @vQuery = 'dbo.TestPivot',
     @vOnRows = 'TransactionType',
     @vOnColumns = 'TransactionDate',
     @vAggFunction = 'SUM',
     @vAggColumns = 'TotalTransactions';
```


| TransactionType | 2019-01-01 | 2019-01-02 | 2019-01-03 | 2019-01-04 | 2019-01-05 |
|-----------------|------------|------------|------------|------------|------------|
| ATM             | 2          | 4          | 6          | 8          | \<NULL>    |
| Signature       | 10         | \<NULL>    | 12         | 14         | 16         |

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc., please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
