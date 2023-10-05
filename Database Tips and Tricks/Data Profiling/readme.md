 # Data Profiling  

When working with datasets, it's important to have a quick and easy way to understand the structure and quality of the data. One important aspect of this is identifying missing or NULL values in the dataset.

To address these issues, I created a data profiling script that allows me to identify the number of NULL or empty string values quickly and easily in each column (among other things). This script is designed to be simple and easy to use, allowing me to quickly get a sense of the quality of the data and identify any areas that may require further cleaning or processing.

## Overview  

The script updates a temporary table called `#DataProfiling` with a user-supplied metric (such as `COUNT`, `AVG`, `MAX`, `MIN`, etc.) for a user-specified schema and table name. The script uses a cursor to iterate through each column in the specified table and executes an update statement for each column with a different metric specified.   This script creates a temporary table called `#DataProfilingSQL`, which contains the SQL statements that are used to update the `#DataProfiling` table.

Example SQL statements are provided to find NULL markers, empty strings, keyword searches, etc...

## Installation

**Step 1:**  
Modify the script variables `@vSchemaName` and `@vTableName` to the schema and table name you wish to profile.  
```sql
DECLARE @vSchemaName NVARCHAR(100) = '';
DECLARE @vTableName NVARCHAR(100) = '';
```

**Step 2:**  
Locate the following SQL statement in the script and modify as needed.  You may want to limit the columns to certain data types or names.
```sql
WHERE   1=1 AND 
        s.[Name] = @vSchemaName AND 
        t.[Name] = @vTableName
        AND ty.Name NOT IN ('XML','uniqueidentifier')--Modify as needed
```
**Step 3:**  
I have provided several SQL statements for NULL markers, empty strings, keyword searches, etc... You may need to create your own profiling query based on your needs.
Here is an example of profiling where I count the non-NULL values in the columns.

```sql
INSERT INTO #DataProfilingSQL (DataProfilingType, OrderID, SQLLine) VALUES
(1,1,'UPDATE #DataProfiling SET RecordCount ='),
(1,2,'('),
(1,3,'SELECT  COUNT([ColumnName])'),
(1,4,'FROM    SchemaName.TableName'),
(1,5,')'),
(1,6,'WHERE RowNumber = vRowNumber');
```
Modify `@vSQLStatement` variable to point to the desired profile in the `#DataProfilingSQL` table.
```sql
DECLARE @vSQLStatement NVARCHAR(1000) = (SELECT STRING_AGG(SQLLine,' ') FROM #DataProfilingSQL WHERE DataProfilingType = 1);
```

**Step 4:**  
Execute the script.

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc., please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
