# Table Validation

This script compares two identical tables using `DYNAMIC SQL` and `FULL OUTER JOIN`s.  This can be used to audit the differences between two datasets and display all columns that do not match.

⌨️&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This script is written in Microsoft SQL Server T-SQL.

## Overview

The scripts `Table Validation Part 1.sql` and `Table Validation Part 2.sql` will create the following thirteen temporary tables to arrive at the final temporary table `#SQLStatementFinal`.  The SQL statement in the table `#SQLStatementFinal` will then be executed via `DYNAMIC SQL`.  

1.  `##TableInformation`   
2.  `#Select`   
3.  `#Exists`    
4.  `#RowNumber`   
5.  `#Count`    
6.  `#Distinct_Count`    
7.  `#Compare`    
8.  `#Columns`    
9.  `#Into`    
10. `#From`    
11.  `#FullOuterJoin`    
12.  `#SQLStatementTemp`    
13.  `#SQLStatementFinal`


I recommend running the `Table Validation Demo Tables.sql` first on the provided sample set.  There are several items in the setup of the script that need to be modified.  Once the final dataset is created, export it to Microsoft Excel.

## Installation

Inside this GitHub repository, you will find the following SQL scripts:

1)  `Table Validation Demo Tables.sql`    
A script that creates the test data for demo purposes. 

2)  `Table Validation Part 1.sql`  
A script that inserts the table information to be audited. 

3)  `Table Validation Part 2.sql`  
A script that creates a dynamic SQL statement and executes. 

To execute the demo, execute the above scripts in order. 

:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For this installation, we will run the `Table Validation Part 1.sql` and `Table Validation Part 2.sql` on the sample data set created in `Table Validation Demo Tables.sql`      
:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The tables must have the exact same columns for this script to work.

---------------------------------------------------



### Step 1:  
Run the script: `Table Validation Demo Tables.sql` to create the demo tables.

The following tables will be created for our demo; `dbo.Sales_Old` and `dbo.Sales_New`. 

**Sales_Old**
| TableID  | CustID  | Region   | City       | Sales        | ManagerID  | AwardStatus  |
| -------  | ------  | ------   | ----       | -----        | ---------  | -----------  |
| 1        | 453     | Central  | Chicago    | $ 71,967.99  | 1324       | Gold         |
| 2        | 532     | Central  | Des Moines | $ 65,232.42  | 6453       | Gold         |
| 3        | 643     | West     | Spokane    | $ 44,981.23  | 7542       | Silver       |
| 4        | 643     | West     | Spokane    | $ 44,981.23  | 7542       | Silver       |
| 5        | 732     | West     | Helena     | $ 15,232.19  | 8123       | Bronze       |
| 6        | 732     | West     | Helena     | $ 15,232.19  | 8123       | Bronze       |

**Sales_New**
| TableID  | CustID  | Region   | City       | Sales        | ManagerID  | AwardStatus  |
| -------  | ------  | ------   | ----       | -----        | ---------  | -----------  |
| 1        | 453     | Central  | Chicago    | $ 71,967.99  | 1324       | Gold         |
| 2        | 532     | Central  | Des Moines | $ 65,232.00  | 6453       | Gold         | 
| 3        | 643     | West     | Spokane    | $ 44,981.23  | 7542       | Bronze       | 
| 4        | 643     | West     | Spokane    | $ 44,981.23  | 7542       | Bronze       | 
| 5        | 898     | East     | Toledo     | $ 53,432.78  | 9242       | Silver       | 

Looking at this data, we can see several differences between the tables; some values are different, the tables have different records, and the tables have duplicate rows. The Full Outer Join script will account for these scenarios. 

---------------------------------------------------
### Step 2:    
Next, run the script `Table Validation Part 1.sql`
This script will populate the table `##TableInformation` with the following values.

| ColumnName  | Value                                     |
| ----------  | ----------------------------------------  |
| LookupID    | 1                                         |
| Schema1Name | dbo                                       | 
| Schema2Name | dbo                                       |
| Table1Name  | Sales_New                                 |
| Table2Name  | Sales_Old                                 |
| Exists1     | CONCAT(t1.CustID, t1.Region, t1.City)     |
| Exists2     | CONCAT(t2.CustID, t2.Region, t2.City)     |

The table `##TableInformation` stores the schemas, table names, and the join conditions between the two tables. You will need to modify this table according to the tables you want to audit. 

The join between the two tables is created in the fields `Exists1` and `Exists2`, where a `CONCAT` function groups the values together.  If the join criteria is on multiple columns, use a `CONCAT` function to join the columns together.  You can remove the `CONCAT` if the join criteria is on one column.  

:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The `t1` and `t2` difference between the fields `Exists1` and `Exists2`. This can be easily overlooked when inserting your join criteria.

You can store multiple reconciliation scenarios in this table; simply input the values and increment the `LookupID` value.

---------------------------------------------------
### Step 3:  

Lastly, run the script `Table Validation Part 2.sql`

This script will generate an SQL statement that compares the tables using a `FULL OUTER JOIN` and then execute it dynamically. 

**Notes:**  

1)  Modify the `@vLookupID` variable appropriately. This variable is used to look up the table information in `##TableInformation`.  

2)  The dynamic SQL statement will be saved in the table `#SQLStatementFinal`. You can review this SQL statement and modify it as needed.   

3)  The results from the dynamic SQL statement will be saved in the temporary table `##@vTableName1_TemporaryTemp` (which will be `##Sales_New_TemporaryTable` in
    our example).  

4)  For each column, there is a `Compare` field created that will be populated with a `1` if the fields are unequal and a `0` if they are equal.   

5)  The field `Compare_Summary` in the first column of the result set gives an overall summary if the record matches between the two tables.   

6)  The result set also has information on which fields do not exist in its partner table, distinct counts, etc.….   

7)  To best understand the SQL generated from the script, review the SQL statement in the table `#SQLStatementFinal`.   

## Example Usage

To best understand the SQL generated from the script, review the example SQL statement in the table `#SQLStatementFinal`.   

```sql
WITH CTE_SQLStatement AS ( 
SELECT   'Start Compare-->' AS CompareStart 
        ,'dbo,MyTable1' AS TableName1 
        ,'dbo,MyTable2' AS TableName2 
        ,'Your Servername' AS ServerName 
        ,'CONCAT(t1.CustID, t1.Region, t1.City)' AS JoinSyntax_Table1 
        ,'CONCAT(t2.CustID, t2.Region, t2.City)' AS JoinSyntax_Table2 
        ,CASE WHEN CONCAT(t1.CustID, t1.Region, t1.City) = '' THEN 1 ELSE 0 END AS NotExists_Table1 
        ,CASE WHEN CONCAT(t2.CustID, t2.Region, t2.City) = '' THEN 1 ELSE 0 END AS NotExists_Table2 
        ,(SELECT COUNT(*) FROM dbo.MyTable1) AS Count_Table1 
        ,(SELECT COUNT(*) FROM dbo.MyTable2) AS Count_Table2 
        ,(SELECT COUNT(DISTINCT CONCAT(t1.CustID, t1.Region, t1.City)) FROM dbo.MyTable1 AS t1) AS DistinctCount_Table1 
        ,(SELECT COUNT(DISTINCT CONCAT(t2.CustID, t2.Region, t2.City)) FROM dbo.MyTable2 AS t2) AS DistinctCount_Table2 
        ,(SELECT COUNT(*) FROM dbo.MyTable1 AS t1 INNER JOIN dbo.MyTable2 AS t2 ON CONCAT(t1.CustID, t1.Region, t1.City) 
        = CONCAT(t2.CustID, t2.Region, t2.City)) AS DistinctIntersect 
        ,CASE WHEN t1.[AwardStatus] IS NULL AND t2.[AwardStatus] IS NULL THEN 0 WHEN t1.[AwardStatus] = t2.[AwardStatus] 
        THEN 0 ELSE 1 END AS [AwardStatus_Compare] 
        ,t1.[AwardStatus] AS [AwardStatus_Table1] 
        ,t2.[AwardStatus] AS [AwardStatus_Table2] 
        ,CASE WHEN t1.[City] IS NULL AND t2.[City] IS NULL THEN 0 WHEN t1.[City] = t2.[City] THEN 0 ELSE 1 END AS 
        [City_Compare] 
        ,t1.[City] AS [City_Table1] 
        ,t2.[City] AS [City_Table2] 
        ,CASE WHEN t1.[CustID] IS NULL AND t2.[CustID] IS NULL THEN 0 WHEN t1.[CustID] = t2.[CustID] THEN 0 ELSE 1 END AS 
        [CustID_Compare] 
        ,t1.[CustID] AS [CustID_Table1] 
        ,t2.[CustID] AS [CustID_Table2] 
        ,CASE WHEN t1.[ManagerID] IS NULL AND t2.[ManagerID] IS NULL THEN 0 WHEN t1.[ManagerID] = t2.[ManagerID] THEN 0 
        ELSE 1 END AS [ManagerID_Compare] 
        ,t1.[ManagerID] AS [ManagerID_Table1] 
        ,t2.[ManagerID] AS [ManagerID_Table2] 
        ,CASE WHEN t1.[Region] IS NULL AND t2.[Region] IS NULL THEN 0 WHEN t1.[Region] = t2.[Region] THEN 0 ELSE 1 END AS 
        [Region_Compare] 
        ,t1.[Region] AS [Region_Table1] 
        ,t2.[Region] AS [Region_Table2] 
        ,CASE WHEN t1.[Sales] IS NULL AND t2.[Sales] IS NULL THEN 0 WHEN t1.[Sales] = t2.[Sales] THEN 0 ELSE 1 END AS 
        [Sales_Compare] 
        ,t1.[Sales] AS [Sales_Table1] 
        ,t2.[Sales] AS [Sales_Table2] 
        ,CASE WHEN t1.[TableID] IS NULL AND t2.[TableID] IS NULL THEN 0 WHEN t1.[TableID] = t2.[TableID] THEN 0 ELSE 1 
        END AS [TableID_Compare] 
        ,t1.[TableID] AS [TableID_Table1] 
        ,t2.[TableID] AS [TableID_Table2] 
        FROM 
        dbo.Sales_New t1 FULL OUTER JOIN 
        dbo.Sales_Old t2 ON CONCAT(t1.CustID, t1.Region, t1.City) = CONCAT(t2.CustID, t2.Region, t2.City) 
        ) SELECT 
        CASE WHEN 
        AwardStatus_Compare = 1 OR City_Compare = 1 OR CustID_Compare = 1 OR ManagerID_Compare = 1 OR Region_Compare = 1 
        OR Sales_Compare = 1 OR TableID_Compare = 1 
         THEN 1 ELSE 0 END AS [Compare_Summary] 
        ,* 
INTO    ##Sales_New_TemporaryTable 
FROM    CTE_SQLStatement; 
```

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc., please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!

