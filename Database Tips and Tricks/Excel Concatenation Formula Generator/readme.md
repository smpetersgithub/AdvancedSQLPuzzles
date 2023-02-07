# Creating an Excel Concatenation Formula

This script creates an Excel concatenation formula based on the number of user-inputted columns.  This becomes handy went I want to quickly insert into a temporary table and generate the `VALUES` statements within Excel.  Often, I will have privileges to 'CREATE' and `INSERT` into temporary tables, but not persistent tables, so this script provides a quick solution for loading data into a temporary table.

If you need a more robust solution, there are several available products that are very affordable that can transform CSV files to SQL `INSERT` statements.  A quick internet search of "convert CSV to SQL INSERT statements" should be sufficient.  Another option is to import the file into SQL Server Express (where you will have `CREATE TABLE` permissions) and then export as `INSERT` statements.  In SSMS, simply right click on the required Database (where the actual table is available) from the Object Explorer, select Tasks and click on Generate Scripts.  And finally, there are web-based converters available, but I do not recommend pasting any company data into a web browser for obvious security reasons.

⌨️&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This script is written in Microsoft SQL Server T-SQL.

## Overview 

The formula uses the `&` operator to join several strings of text and cell references.  The formula takes the values of cells `A2`, `B2`, `C2`, `D2`, `E2`, and so on, and combines them into one string, separating each cell value with a comma and single quotes, and ending with a comma.  This formula is a useful tool for generating a list of comma-separated values, which can then be used in SQL for inserting into a table.  

**This script treats each column as a string data type.**

## Installation

**Step 1:**  
Modify the variable `@vLastExcelColumn` to match the last column in your Excel file.
```sql
DECLARE @vLastExcelColumn VARCHAR(3) =  'E';
```

**Step 2:**  
Execute the script and copy the generated string to a new column at the end of your Excel file.
```excel
="('"&A2&"','"&B2&"','"&C2&"','"&D2&"','"&E2&"'),"
```

**Step 3:**  
The script assumes that your Excel file has a header row. In the second row of the new column, enter the generated string and then expand the formula down to each row.

**Step 4:**   
Copy the values into your SQL editor and then insert the values into a table.

------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc. please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
