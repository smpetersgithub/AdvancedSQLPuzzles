# Table Validation

This script compares two identical tables using DYNAMIC SQL and FULL OUTER JOINS.  This can be used to audit the differences between two datasets and display all columns which do not match.

## Installation

Inside this GitHub repository you will find the following SQL scripts:

1)  **Table Validation Demo Tables.sql**    
A script that creates the test data for demo purposes. 

2)  **Table Validation Part 1.sql**  
A script that inserts the table information to be audited. 

3)  **Table Validation Part 2.sql**  
A script that creates a dynamic SQL statement and executes. 

To execute a quick demo, execute the above scripts in order. Note, the tables must have the exact same columns for this script to work.  

### Step 1

Run the script: **Full Outer Join Create Sample Data (Testing).sql** 

The following tables will be created for our demo; dbo.Sales_Old and dbo.Sales_New. 

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

Looking at this data we can see several differences between the tables; some values are different, the tables have different records, and the tables have duplicate rows. The Full Outer Join script will account for these scenarios. 

### Step 2

Next, run the script **Full Outer Join Insert Table Information (Part 1).sql**
This script will populate the table **##TableInformation** with the following values from our Test script.

| ColumnName  | Value                                     |
| ----------  | ----------------------------------------  |
| LookupID    | 1                                         |
| Schema1Name | dbo                                       | 
| Schema2Name | dbo                                       |
| Table1Name  | MyTable1                                  |
| Table2Name  | MyTable2                                  |
| Exists1     | CONCAT(t1.CustID, t1.Region, t1.City)     |
| Exists2     | CONCAT(t2.CustID, t2.Region, t2.City)     |

The table **##TableInformation** is used to store the schemas, table names, and the join conditions between the two tables. You will need to modify this table according to the tables you want to audit. 

The join between the two tables is created in the fields **Exists1** and **Exists2**, where a CONCAT function is used to group the values together.  If the join criteria is on multiple columns, use a CONCAT function to join the columns together.  You can remove the CONCAT if the join criteria is on one column.  Note the **t1** and **t2** difference between the fields **Exists1** and **Exists2**. This can be easily overlooked when inserting your join criteria.  

You can store multiple reconciliation scenarios in this table, simply input the values and increment the LookupID value. 

