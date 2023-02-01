# Table Types

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Within SQL, you can create a join to the following 10 table types, some of these objects are schema bound objects, meaning they are saved as a database object within a named schema, and others are unbound and only durable for the life of an SQL statement (CTE, Subquery, Values, Derived Tables) or your current session (Table Variable, Temporary Table).  Items that are not schema bound are created in the tempdb and do not have any data of their existence in the catalog views.

Here are the 10 different types of tables you can create.

| Id |              Name              |  Schema Bound |                                                                 Description                                                                |
|----|--------------------------------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------|
|  1 |  Table                         |  True         |  A regular table that is stored in the database.                                                                                           |
|  2 |  View                          |  True         |  A virtual table that is based on the result of a SELECT statement.                                                                        |
|  3 |  Values Constructor            |  True         |  The VALUES constructor can be used to create a derived table, which is a table that is created and used within a single SQL query.        |
|  4 |  Table Valued Function         |  True         |  A function that returns a table as its result.                                                                                            |
|  5 |  Subquery                      |  False        |  A query that is embedded within another query. The results of a subquery can be used in the outer query.                                  |
|  6 |  Derived Table                 |  False        |  A special type of subquery that is defined in the FROM statement, enclosed in parentheses and a table name is provided.                   |
|  7 |  Common Table Expression (CTE) |  False        |  A named temporary result set that can be used in a SELECT, INSERT, UPDATE, or DELETE statement.                                           |
|  8 |  Temporary Table               |  False        |  A table that is created for a specific session or connection and is automatically dropped when the session or connection ends.            |
|  9 |  Table Variable                |  False        |  A variable that holds a table of data. It is similar to a temporary table but it has some differences in terms of its behavior and scope. |
| 10 |  External Tables               |  False        |  Used to access data stored externally, such as in a text file. They are created using the CREATE EXTERNAL TABLE statement.                |

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tempdb is used by SQL Server to store intermediate results when processing queries, such as those created by derived tables and subqueries. For example, when you create a derived table or use a subquery, SQL Server may create a temporary table in tempdb to store the intermediate results. This allows the database engine to reuse the results multiple times in the same query, instead of having to recompute them each time they're needed.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;It's important to note that the use of tempdb and the extent to which it's used can vary depending on the complexity of the query and other factors, such as the amount of memory available and the indexes present on the involved tables. However, it's a common practice for SQL Server to use tempdb when working with derived tables and subqueries.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The most interesting of these table types in the VALUES keyword.  We often think the only use of the VALUES operator is using it with an INSERT statement, but it can be used to create a relation.  First though, lets create examples of each of the table types.

--------------------------------------------------------------------------------------------------------
#### Table

The type of table referred to below is a base table. A base table is a permanent table stored in the database and contains the actual data in the form of rows and columns. The `SELECT *` statement retrieves all columns and all rows from the table. It is a permanent table that stores data in the database.  On base tables you can implement `NOT NULL`, `UNIQUE`, `PRIMARY KEY`, `FOREIGN KEY`, `CHECK` and `DEFAULT` constraints.

In this example we create a table named `Employees`, insert a record using the VALUES constructor, and then select from the table. 

```sql
CREATE TABLE Employees
(
EmployeeID INTEGER PRIMARY KEY,
FirstName  VARCHAR(100) NOT NULL,
LastName   VARCHAR(100) NOT NULL,
Department VARCHAR(100) NOT NULL,
Salary     MONEY NOT NULL
);

INSERT INTO Employees (EmployeeID, FirstName, LastName, Department,Salary) VALUES (1,'John','Wilson','Accounting',100000);
INSERT INTO Employees (EmployeeID, FirstName, LastName, Department,Salary) VALUES (2,'Sarah','Shultz','Accounting',90000);

SELECT * FROM Employees;
```


| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
|          1 | John      | Wilson   | Accounting | 100000.00 |
|          2 | Sarah     | Shultz   | Accounting |  90000.00 |

--------------------------------------------------------------------------------------------------------
#### View

A SQL view is a virtual table that provides a specific, customized perspective of data from one or more tables in a database.  There are two main types of SQL views: materialized views and non-materialized (or simple) views. Materialized views store the result set of the view query, while non-materialized views do not store any data and dynamically retrieve data from the underlying tables each time the view is accessed.  You issue `INSERT` and `DELETE` commands through views.

In this example we create a view from the `Employees` table, insert a record into the table, and then select from the view;

```sql
CREATE OR ALTER VIEW vwEmployees as
(
SELECT  EmployeeID,
        FirstName,
        LastName,
        Department,
        Salary
FROM    Employees
);

INSERT INTO vwEmployees (EmployeeID,FirstName,LastName, Department,Salary) VALUES(3,'Larry','Johnson','Accounting','85000');

SELECT * FROM vwEmployees;
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
|          1 | John      | Wilson   | Accounting | 100000.00 |
|          2 | Sarah     | Shultz   | Accounting |  90000.00 |
|          3 | Larry     | Johnson  | Accounting |  85000.00 |

--------------------------------------------------------------------------------------------------------
#### VALUES Operator

The `VALUES` constructor has a few considerations that are often overlooked and deserve its own recognition.  The `VALUES` constructor specifies a set of row value expressions to be constructed into a table and allows multiple sets of values to be specified in a single DML statement.  Normally we use the `VALUES` constructor to specify the data to insert into a table, as we initially did with our test data, but it can also be used as a derived table in an SQL statement.

Here is a basic example of using the `VALUES` constructor as a derived table.

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

Here is a more elaborate example where the VALUES constructor specifies the values to return.  This statement uses an `INNER JOIN`, but you can use a `LEFT OUTER JOIN`, `RIGHT OUTER JOIN`, `FULL OUTER JOIN`, or `CROSS JOIN`.

```sql
SELECT  a.Fruit
FROM    Employees a INNER JOIN
        (VALUES (1), (2)) AS b(EmployeeID) ON a.EmployeeID = b.EmployeeID;
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
|          1 | John      | Wilson   | Accounting | 100000.00 |
|          2 | Sarah     | Shultz   | Accounting |  90000.00 |


You can also place functions into the `VALUES` constructor.  The `NEWID()` function creates a unique value of type `UNIQUEIDENTIFIER`.   Here you could easily just add the function to the `SELECT` statement, but this gives you an idea of the capabilities of the `VALUES` constructor.

```sql
SELECT  CONCAT(FirstName,' ',LastName) AS Name,
        b.UniqueID
FROM    Employees a CROSS JOIN
        (VALUES (NEWID())) AS b(UniqueID);
```

|     Name      |               UniqueID               |
|---------------|--------------------------------------|
| John Wilson   | 50CA5F8E-9090-4DB8-A7C4-43F1D6C89D57 |
| Sarah Shultz  | 803DF712-0144-41AC-959A-A774F35DC600 |
| Larry Johnson | 5CCCCBE3-F600-4E79-B16B-1BC6504152A2 |


--------------------------------------------------------------------------------------------------------
#### Table Valued Function

A table valued function acts much like a view with the added benefit of being parameterized.  

For this example we create a table valued function using the `Employees` table.  To use the table values function we can simply select from the function, or use the `CROSS APPLY` to join to another table.
        
```sql
 CREATE OR ALTER FUNCTION FnGetEmployees (@EmployeeID INTEGER)
RETURNS TABLE
AS
RETURN
(
    SELECT EmployeeID, Name
    FROM   Employees
    WHERE EmployeeID = @EmployeeID
);

SELECT * FROM fnGetEmployees(1);

SELECT  a.*
FROM    Employees a CROSS APPLY
        fnGetEmployees(1);
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
|          1 | John      | Wilson   | Accounting | 100000.00 |

--------------------------------------------------------------------------------------------------------
#### Subquery

A subquery is a query nested within another query. Here are a few examples of subqueries using the `Employees` table:
   
```sql
SELECT  e.*
FROM    Employees e
WHERE   e.Salary >  (SELECT AVG(Salary)
                     FROM Employees
                     WHERE Department = e.Department););
```


| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
|          1 | John      | Wilson   | Accounting | 100000.00 |



--------------------------------------------------------------------------------------------------------
#### Derived Table

A derived table is a table that is derived from a `SELECT` statement and used within another `SELECT` statement. Here is an example of a derived table in SQL        
        
```sql
SELECT  e.*,
        e2.EmployeeID,
        e2.Salary
FROM  (
      SELECT  EmployeeID, FirstName, LastName, Salary
      FROM    Employees
      ) e INNER JOIN Employees e2 ON e.Salary > e2.Salary;      
```


| EmployeeID | FirstName | LastName |  Salary   | EmployeeID |  Salary  |
|------------|-----------|----------|-----------|------------|----------|
|          1 | John      | Wilson   | 100000.00 |          2 | 90000.00 |
|          1 | John      | Wilson   | 100000.00 |          3 | 85000.00 |
|          2 | Sarah     | Shultz   |  90000.00 |          3 | 85000.00 |


--------------------------------------------------------------------------------------------------------
#### Common Table Expression (CTE) 

A Common Table Expression (CTE) is a named, temporary result set that is defined within a `SELECT` statement

```sql        
WITH EmployeesByDepartment AS 
(
SELECT  Department, COUNT(*) AS EmployeeCount
FROM    Employees
GROUP BY Department
)
SELECT  Department, EmployeeCount
FROM    EmployeesByDepartment
WHERE   EmployeeCount > 2;
```

| Department | EmployeeCount |
|------------|---------------|
| Accounting |             3 |

--------------------------------------------------------------------------------------------------------
#### Temporary Table        

The syntax for creating temporary tables is different for each database system.  These examples work in `SQL Server`.

Session temporary tables and global temporary tables are two types of temporary tables in SQL. The main difference between them is their scope and visibility.  

*  In SQL Server you can use a single octothorpe (#) for a session temporary table, and two octothorpes (##) for a global session table.
*  Session temporary tables are only visible to the user who created them and are automatically dropped when the user's session ends.  
*  Global temporary tables are available to every user's session.  
*  You can place the same constraints, except for `FOREIGN KEY` constraints, on a temp table as you can on a permanent table.  
*  Indexing is also allowed on temporary tables.
*  Temporary tables reside in tempdb and you cannot see its meta data in the information schema.

This creates a session temporary table in `SQL Server`.

```sql
CREATE TABLE #Employees
(
EmployeeID INTEGER PRIMARY KEY,
FirstName  VARCHAR(100) NOT NULL,
LastName   VARCHAR(100) NOT NULL,
Department VARCHAR(100) NOT NULL,
Salary     MONEY NOT NULL
);

INSERT INTO #Employees SELECT * FROM Employees;

SELECT * FROM #Employees;
```sql

| EmployeeID | FirstName | LastName |  Salary   | EmployeeID |  Salary  |
|------------|-----------|----------|-----------|------------|----------|
|          1 | John      | Wilson   | 100000.00 |          2 | 90000.00 |
|          1 | John      | Wilson   | 100000.00 |          3 | 85000.00 |
|          2 | Sarah     | Shultz   |  90000.00 |          3 | 85000.00 |

You can also create temporary tables via the INTO statement in a query.  This works in `SQL Server` and each database system has slightly different syntax for temporary tables.

```sql
SELECT  *
INTO    #Employees2
FROM    Employees;

SELECT * FROM #Employees2
```

| EmployeeID | FirstName | LastName |  Salary   | EmployeeID |  Salary  |
|------------|-----------|----------|-----------|------------|----------|
|          1 | John      | Wilson   | 100000.00 |          2 | 90000.00 |
|          1 | John      | Wilson   | 100000.00 |          3 | 85000.00 |
|          2 | Sarah     | Shultz   |  90000.00 |          3 | 85000.00 |

--------------------------------------------------------------------------------------------------------
#### Table Variable   

Table variables are much like temporary tables.  They are often used when you need to pass a record set to a stored procedure.  Each database may implement table variables slightly different, but SQL Server has the following considerations.

*  You can place constraints on the table except for `FOREIGN KEY` constraints.
*  The constraints must be placed on the table on creation.
*  You cannot alter the table variable once it is created.
*  You cannot create an explicit index on a table variable.
*  When creating a primary key or a unique constraint an index is created.
*  The `TRUNCATE` statement does not work on table variables.
*  Table variables are stored in temdb.

```sql
DECLARE @TableVariable Table
(
EmployeeID INTEGER PRIMARY KEY,
FirstName  VARCHAR(100) NOT NULL,
LastName   VARCHAR(100) NOT NULL,
Department VARCHAR(100) NOT NULL,
Salary     MONEY NOT NULL
);

INSERT INTO @TableVariable
SELECT * FROM Employees;

SELECT * FROM @TableVariable;
```

| EmployeeID | FirstName | LastName |  Salary   | EmployeeID |  Salary  |
|------------|-----------|----------|-----------|------------|----------|
|          1 | John      | Wilson   | 100000.00 |          2 | 90000.00 |
|          1 | John      | Wilson   | 100000.00 |          3 | 85000.00 |
|          2 | Sarah     | Shultz   |  90000.00 |          3 | 85000.00 |

--------------------------------------------------------------------------------------------------------
#### External Tables           

External tables in `SQL Server` are tables that exist outside of the SQL Server database and are used to access data stored in external sources such as flat files, Hadoop, or Azure Blob storage. External tables provide a way to access external data as if it were a regular table within the `SQL Server` database, allowing you to use standard SQL queries to retrieve and manipulate data stored in external sources. This can be useful for tasks such as performing data integration, bulk data loading, and data archiving, as well as for querying and processing large datasets stored in external sources. However, external tables in `SQL Server` have some limitations and limitations such as limited indexing options and slower query performance compared to regular tables stored in the SQL Server database.

See your vendor's documentation on external tables, as this will vary for each vendor.

The `SQL Server` documentation has the following examples.

```sql
CREATE EXTERNAL DATA SOURCE mydatasource
WITH (
    TYPE = HADOOP,
    LOCATION = 'hdfs://xxx.xxx.xxx.xxx:8020'
);

CREATE EXTERNAL FILE FORMAT myfileformat
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS (FIELD_TERMINATOR ='|')
);

CREATE EXTERNAL TABLE ClickStream (
    url varchar(50),
    event_date date,
    user_IP varchar(50)
)
WITH (
        LOCATION='/webdata/employee.tbl',
        DATA_SOURCE = mydatasource,
        FILE_FORMAT = myfileformat
    );
```

---------------------------------------------------------

1. [Introduction](01%20-%20Introduction.md)
2. [SQL Processing Order](02%20-%20SQL%20Query%20Processing%20Order.md)
3. [Table Types](03%20-%20Table%20Types.md)
4. [Equi, Theta, and Natural Joins](04%20-%20Equi%2C%20Theta%2C%20and%20Natural%20Joins.md)
5. [Inner Joins](05%20-%20Inner%20Join.md)
6. [Outer Joins](06%20-%20Outer%20Joins.md)
7. [Full Outer Joins](07%20-%20Full%20Outer%20Join.md)
8. [Cross Joins](08%20-%20Cross%20Join.md)
9. [Semi and Anti Joins](09%20-%20Semi%20and%20Anti%20Joins.md)
10. [Any, All, and Some](10%20-%20Any%2C%20All%2C%20and%20Some.md)
11. [Self Joins](11%20-%20Self%20Join.md)
12. [Relational Divison](12%20-%20Relational%20Division.md)
13. [Set Operations](13%20-%20Set%20Operations.md)
14. [Join Algorithms](14%20-%20Join%20Algorithms.md)
15. [Exists](15%20-%20Exists.md)
16. [Complex Joins](16%20-%20Complex%20Joins.md)

https://advancedsqlpuzzles.com
