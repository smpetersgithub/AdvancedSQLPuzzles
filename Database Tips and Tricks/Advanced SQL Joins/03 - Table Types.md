# Table Types

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Within SQL, you can create a join to the following 10 table types, some of these objects are schema bound objects, meaning they are saved as a database object within a named schema, and others are unbound and only durable for the life of an SQL statement (CTE, Subquery, Values, Derived Tables) or your current session (Table Variable, Temporary Table).  Items that are not schema bound are created in the tempdb and do not have any data of their existince in the catalog views.

Here are the 10 different types of tables you can create.

| Id |              Name              |  Schema Bound |                                                                 Description                                                                |
|----|--------------------------------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------|
|  1 |  Table                         |  True         |  A regular table that is stored in the database.                                                                                           |
|  2 |  View                          |  True         |  A virtual table that is based on the result of a SELECT statement.                                                                        |
|  3 |  Values Constructor            |  True         |  The VALUES constructor can be used to create a derived table, which is a table that is created and used within a single SQL query.        |
|  4 |  Table Valued Function         |  True         |  A function that returns a table as its result.                                                                                            |
|  5 |  Subquery                      |  False        |  A query that is embedded within another query. The results of a subquery can be used in the outer query.                                  |
|  6 |  Derived Table                 |  False        |  A special type of subquery that is defined in the FROM statement, encloused in parenthses and a table name is provided.                   |
|  7 |  Common Table Expression (CTE) |  False        |  A named temporary result set that can be used in a SELECT, INSERT, UPDATE, or DELETE statement.                                           |
|  8 |  Temporary Table               |  False        |  A table that is created for a specific session or connection and is automatically dropped when the session or connection ends.            |
|  9 |  Table Variable                |  False        |  A variable that holds a table of data. It is similar to a temporary table but it has some differences in terms of its behavior and scope. |
| 10 |  External Tables               |  False        |  Used to access data stored externally, such as in a text file. They are created using the CREATE EXTERNAL TABLE statement.                |


The most interesting of these table types in the VALUES keyword.  We often think the only use of the VALUES operator is using it with an INSERT statement, but it can be used to create a relation.  First though, lets create examples of each of the table types.

--------------------------------------------------------------------------------------------------------
#### Table

The type of table referred to below is a base table. A base table is a permanent table stored in the database and contains the actual data in the form of rows and columns. The SELECT * statement retrieves all columns and all rows from the table. It is a permanent table that stores data in the database.

On base tables you can implement NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECKM and DEFAULT constraints.

```sql
CREATE TABLE Employees
(
ID INTEGER PRIMARY KEY,
Name VARCHAR(100)
);
```


--------------------------------------------------------------------------------------------------------
#### View

A SQL view is a virtual table that provides a specific, customized perspective of data from one or more tables in a database.  There are two main types of SQL views: materialized views and non-materialized (or simple) views. Materialized views store the result set of the view query, while non-materialized views do not store any data and dynamically retrieve data from the underlying tables each time the view is accessed.  You can INSERT and DELETE data through views.

```sql
CREATE VIEW vwEmployees as
(
SELECT * FROM Employees
);
```

--------------------------------------------------------------------------------------------------------
#### VALUES Operator

The VALUES constructor has a few considerations that are often overlooked and deserve its own recognition.  The VALUES constructor specifies a set of row value expressions to be constructed into a table and allows multiple sets of values to be specified in a single DML statement.  Normally we use the VALUES constructor to specify the data to insert into a table, as we initially did with our test data, but it can also be used as a derived table in an SQL statement.

Here is a basic example of using the VALUES constructor as a derived table.

```sql
SELECT  a,
        b 
FROM    (VALUES (1, 2), (3, 4), (5, 6), (7, 8), (9, 10)) AS MyTable(a, b);
```

| a | b  |
|---|----|
| 1 |  2 |
| 3 |  4 |
| 5 |  6 |
| 7 |  8 |
| 9 | 10 |


Here is a more elaborate example where the VALUES constructor specifies the values to return.  This statement uses an INNER JOIN, but you can use the usual OUTER JOIN, FULL OUTER JOIN, or CROSS JOIN.

```sql
SELECT  a.Fruit
FROM    ##TableA a INNER JOIN
        (VALUES ('Kiwi'), ('Apple')) AS b(Fruit) ON a.Fruit = b.Fruit;
```

| Fruit |
|-------|
| Apple |


You can also place functions into the VALUES constructor.  The NEWID() function creates a unique value of type UNIQUEIDENTIFIER.   Here you could easily just add the function to the SELECT statement, but this gives you an idea of the capbilities of the VALUES constructor.

```sql
SELECT  a.Fruit, 
        b.ID
FROM    ##TableA a CROSS JOIN
        (VALUES (NEWID())) AS b(ID);
```

| Fruit  |                ID                    |
|--------|--------------------------------------|
| Apple  | 72A95D25-1224-405E-8879-295C2DD0891A |
| Peach  | 3767AF47-17B1-4D92-9FBA-632E07A7D10D |
| Mango  | 60B37D3D-2FB4-4F24-B486-2CBCD2C09A6B |
| <NULL> | 6466B482-C607-497D-A355-0A9A97E61711 |

--------------------------------------------------------------------------------------------------------
#### Table Valued Function
        
        
--------------------------------------------------------------------------------------------------------
#### Subquery
        
--------------------------------------------------------------------------------------------------------
#### Derived Table
        
--------------------------------------------------------------------------------------------------------
#### Common Table Expression (CTE) 
        
--------------------------------------------------------------------------------------------------------
#### Temporary Table        

--------------------------------------------------------------------------------------------------------
#### Table Variable   
        
--------------------------------------------------------------------------------------------------------
#### External Tables           
