# Creating an Excel Concatenation Formula

This script creates an Excel concatenation formula based on the number of user-inputted columns.

The formula uses the "&" operator to join together several strings of text and cell references. 

The formula takes the values of cells A2, B2, C2, D2, E2, and so on, and combines them into one string, separating each cell value with a comma and single quotes, and ending with a comma.

This formula is a useful tool for generating a list of comma-separated values, which can then be used in SQL for inserting into a table

This script treats each column as a string data type.

## Installation

Step 1:  
Modify the variable @vLastExcelColumn to match the last column in your Excel file.

Step 2:  
Execute the script and copy the generated string to a new column at the end of your Excel file.

Step 3:  
The script assumes that your Excel file has a header row. In the second row of the new column, enter the generated string and then expand the formula down to each row.

Step 4:   
Copy the values into your SQL editor and create a new table with string data types.  Then, use an INSERT INTO statement to insert the values into the table.
