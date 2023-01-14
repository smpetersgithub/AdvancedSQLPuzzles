# Advanced SQL Joins   

## SQL JOINS  
In SQL, a join operation combines rows from two or more tables based on a related column between them. There are several types of joins, each with its own use case.  In this PDF I have collected all the different types of joins and provide examples of how they interact with NULL values and various SQL constructs.


For quick reference, here are all the types of joins.

**Inner Join**    
An inner join returns only the rows that have matching values in both tables.

**Outer Join**  
An outer join returns all the rows from one table, and any matching rows from the other table. If there is no match, the result will contain NULL values.

**Full Outer Join**   
A full outer join returns all the rows from both tables, where if there is no matching rows, the result will contain NULL values.

**Cross Join**  
A cross join returns the Cartesian product of the two tables, meaning it returns every possible combination of rows from the two tables.

**Natural Join**  
A natural join returns the rows where the values in the specified columns of both tables are equal and the column names are the same. It is important to note that in case of ambiguous columns, it may lead to unexpected results.

**Self Join**  
A self join is used to join a table to itself, using the same table twice with different aliases.

**Semi Join**  
A semi join returns only the rows from the first table that have matching values in the second table.

**Anti Join**  
An anti join returns only the rows from the first table that do not have matching values in the second table.

**Equi Join**  
An equi join returns only the rows where the values in the specified columns of both tables are equal.

**Theta Join**  
A theta join is a flexible type of join that allows you to join tables based on any type of condition, not just an equality condition.

**Nested Loop Join**  
Nested loop join is a type of join algorithm that compares each row of one table with all the rows of another table.

**Hash Join**  
Hash join is a join algorithm that uses a hash table to quickly match rows from one table with rows from another table.

**Merge Sort Join**  
Merge sort join is a join algorithm that sorts both tables on the join column, and then merges the sorted rows together.
