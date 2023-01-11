# Data Profiling

This script is intended to update a temporary table called #DataProfiling with a user supplied metric (such as COUNT, AVG, MAX, MIN) for a user-specified schema and table name.
 
The script uses a cursor to iterate through each column in the specified table and executes an update statement for each column with a different metric specified. 

This script creates a temporary table called #DataProfilingSQL, which contain the SQL statements that used to update the #DataProfiling table.

It also provides examples for SQL statements such as determining the count of NULL markers, empty strings, keywords, etc. in the columns. 

Example SQL statements are provided to find NULL markers, empty strings, keywords, etc....

## Installation

Modify the script to the table and data types of your choosing.  Modify the SQL statement that is ran dynamically to pull the desired metric.
