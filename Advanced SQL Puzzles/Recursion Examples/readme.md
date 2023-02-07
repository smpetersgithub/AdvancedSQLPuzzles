# Recursion Examples

In this directory you will find my collection of SQL scripts to solve various challenges using resursion.    

:star: I am always on the look out for puzzles that can be solved using recursion.  If you have any ideas or scripts you want to add to my collection, please contact me!

Recursion in SQL is a technique used to process hierarchical data, where a query can reference itself in order to process data in a recursive manner. It is commonly used in cases where a single row of data has multiple relationships with other rows in the same table, creating a parent-child relationship. The process starts with an initial query that returns a base case, and subsequent queries use the results of the previous query to process the data until a stop condition is reached. Recursion in SQL is implemented using Common Table Expressions (CTEs), which are temporary result sets defined within a SELECT statement, and can be referenced within the same SELECT statement to perform the recursion.

An example of an implicit hierarchy where the table containing the data doesn't always show a hierarchy is a file system in a computer. A file system organizes files and directories into a tree-like structure, where each directory can contain multiple subdirectories and files. However, the table that stores the information about the files and directories in a file system typically only contains information about each individual file or directory, without explicitly showing the parent-child relationships between them. Nevertheless, the hierarchy can be inferred based on the file path, where each directory is a parent of its subdirectories and files. In this scenario, the implicit hierarchy can be used to traverse the file system, starting from the root directory and moving down to each subdirectory and file.

a numbers table can be considered to have an implicit hierarchy, where each number depends on the previous number in the sequence. The hierarchy is implicit because it is not explicitly stored in the table, but can be derived from the relationship between the numbers. This type of hierarchy can be useful in situations where you need to perform operations on sequences of numbers, such as generating a series of dates or calculating the cumulative sum of values.



:keyboard:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The scripts provided are written in Microsoft SQL Server T-SQL, but you can easily modify them to fit your flavor of SQL.
