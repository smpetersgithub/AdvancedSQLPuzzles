# Table Types

SQL Server allows queries to read from and join to many kinds of tables, table-like objects, and rowset expressions. This article examines eleven commonly encountered examples.

❗For simplicity, we will be using the term "table" to describe the following. 

| Id | Name | Description |
|----|------|-------------|
| 1 | Table | A permanent, schema-scoped object that stores data as rows and columns. |
| 2 | View | A schema-scoped virtual table whose columns and rows are defined by a `SELECT` statement. |
| 3 | `VALUES` Constructor | An inline rowset that can supply values to a DML statement or be used as a derived table. |
| 4 | Table-Valued Function | A schema-scoped function that accepts parameters and returns a tabular result. |
| 5 | Subquery | A query nested inside another SQL statement that returns a scalar value, a single-column result, or a rowset. |
| 6 | Derived Table | A subquery defined in the `FROM` clause and assigned a table alias. |
| 7 | Common Table Expression (CTE) | A named query expression that exists for the duration of one statement. |
| 8 | Temporary Table | A table created in `tempdb` with local or global scope. |
| 9 | Table Variable | A variable that stores temporary tabular data within a batch, stored procedure, or function. |
| 10 | User-Defined Table Type | A schema-scoped type used to declare table variables and table-valued parameters. |
| 11 | External Table | A schema-scoped table that provides access to data stored outside SQL Server. |

Next, let's create examples of each type.

--------------------------------------------------------------------------------------------------------
## Table Type 1
### Table

The type of table referred to below is a base table. A base table is a permanent table stored in the database and contains the actual data in the form of rows and columns. Base tables can have `NOT NULL`, `UNIQUE`, `PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, and `DEFAULT` constraints.

In this example, we create a table named `Employees`, insert two rows using the `VALUES` constructor, and then select from the table. 

```sql
CREATE TABLE dbo.Employees
(
EmployeeID INTEGER PRIMARY KEY,
FirstName  VARCHAR(100) NOT NULL,
LastName   VARCHAR(100) NOT NULL,
Department VARCHAR(100) NOT NULL,
Salary     MONEY NOT NULL
);

INSERT INTO dbo.Employees (EmployeeID, FirstName, LastName, Department, Salary) VALUES (1,'John','Wilson','Accounting',100000);
INSERT INTO dbo.Employees (EmployeeID, FirstName, LastName, Department, Salary) VALUES (2,'Sarah','Shultz','Accounting',90000);

SELECT * FROM dbo.Employees ORDER BY 1;
```


| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |
| 2          | Sarah     | Shultz   | Accounting |  90000.00 |

--------------------------------------------------------------------------------------------------------
## Table Type 2
### View

An SQL view is a virtual table that provides a specific, customized data perspective from one or more tables in a database.  There are two main types of SQL views: materialized views (indexed views in SQL Server) and non-materialized views. Materialized views store the result set of the view query. In contrast, non-materialized views do not store data and dynamically retrieve data from the underlying tables each time the view is accessed.  Under certain conditions, you can issue DML commands  (`INSERT`, `UPDATE`, and `DELETE`) through views and can manipulate the underlying table(s) in the view.

In SQL Server, we can set the following options for views.

`[ WITH <view_attribute> [ ,...n ] ]`
*  `ENCRYPTION`: Hides the text of the view definition from being viewed by using the `sys.sql_modules` catalog view or the `OBJECT_DEFINITION` function. It provides a layer of security against viewing the view's SQL syntax.
*  `SCHEMABINDING`: Binds the view to the schema of the underlying tables. This prevents modifications to the underlying tables that would affect the view, ensuring the view's definition remains valid and unchanged.
*  `VIEW_METADATA`: Causes SQL Server to return metadata about the view, rather than its underlying tables, to DB-Library, ODBC, and OLE DB APIs when browse-mode metadata is requested. This can help client applications create updatable cursors against a view.

SQL Server also supports `WITH CHECK OPTION`, which is placed after the view's defining `SELECT` statement.

`WITH CHECK OPTION`: Ensures that all data modifications through the view comply with the view's `SELECT` statement. If a row is modified through the view that would not be selected by the view's `SELECT` statement, the modification is disallowed. This maintains data integrity by ensuring only valid data is entered through the view.

In this example, we create a view over the `Employees` table, insert a row through the view, and then select from the view.

```sql
CREATE OR ALTER VIEW dbo.vwEmployees AS
SELECT  EmployeeID,
        FirstName,
        LastName,
        Department,
        Salary
FROM    dbo.Employees;
GO

INSERT INTO dbo.vwEmployees (EmployeeID, FirstName, LastName, Department, Salary) VALUES(3,'Larry','Johnson','Finance','85000');
GO

SELECT * FROM dbo.vwEmployees ORDER BY 1;
GO

--Remove Larry
DELETE FROM dbo.vwEmployees WHERE FirstName = 'Larry';
GO
```

Here are the results before we removed Larry.

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |
| 2          | Sarah     | Shultz   | Accounting |  90000.00 |
| 3          | Larry     | Johnson  | Finance    |  85000.00 |

--------------------------------------------------------------------------------------------------------
## Table Type 3
### VALUES Constructor

The `VALUES` constructor has a few considerations that are often overlooked and deserves its own recognition.  The `VALUES` constructor specifies a set of row value expressions to be constructed into a table and allows multiple sets of values to be defined in a single DML statement.  Typically, we use the `VALUES` constructor to specify the data to insert into a table, as we initially did with our test data, and it can also be used as a derived table in an SQL statement.  The `VALUES` constructor is not a persistent object; it is an inline rowset.

Here is a basic example of using the `VALUES` constructor as a derived table.

```sql
SELECT  a,
        b 
FROM    (VALUES (1, 2), (3, 4), (5, 6), (7, 8), (9, 10)) AS MyTable(a, b)
ORDER BY 1;
```

| a | b  |
|---|----|
| 1 | 2  |
| 3 | 4  |
| 5 | 6  |
| 7 | 8  |
| 9 | 10 |

Here is a more elaborate example where the `VALUES` constructor specifies the values to return.

```sql
SELECT  a.*
FROM    dbo.Employees a INNER JOIN
        (VALUES (1), (2)) AS b(EmployeeID) ON a.EmployeeID = b.EmployeeID;
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |
| 2          | Sarah     | Shultz   | Accounting |  90000.00 |

You can also place functions into the `VALUES` constructor.  The `NEWID()` function creates a unique value of type `UNIQUEIDENTIFIER`.

```sql
SELECT  CONCAT(FirstName,' ',LastName) AS Name,
        b.UniqueID
FROM    dbo.Employees a CROSS JOIN
        (VALUES (NEWID())) AS b(UniqueID)
ORDER BY 1;
```

|     Name      |               UniqueID               |
|---------------|--------------------------------------|
| John Wilson   | 50CA5F8E-9090-4DB8-A7C4-43F1D6C89D57 |
| Sarah Shultz  | 803DF712-0144-41AC-959A-A774F35DC600 |

--------------------------------------------------------------------------------------------------------
## Table Type 4
### Table-Valued Function

A table-valued function acts like a view with the added benefit of being parameterized.  Table-valued functions can be inline or multi-statement functions, and you can join to other datasets using `CROSS APPLY` or `OUTER APPLY`.

For this example, we create a table-valued function using the `Employees` table.  To use the table-valued function, we can select from the function or use the `CROSS APPLY` join operation.

```sql
CREATE OR ALTER FUNCTION dbo.FnGetEmployees (@EmployeeID INTEGER)
RETURNS TABLE
AS
RETURN
(
SELECT EmployeeID, FirstName, LastName, Department, Salary
FROM   dbo.Employees
WHERE  EmployeeID = @EmployeeID
);
GO

SELECT * FROM dbo.fnGetEmployees(1);


SELECT  a.*,
        (CASE WHEN a.EmployeeID = f.EmployeeID THEN 1 ELSE 0 END) AS IsMatch
FROM    dbo.Employees a CROSS APPLY
        dbo.fnGetEmployees(1) f;
```

Here are the results from the first `SELECT` statement.

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |

Here are the results from the second `SELECT` statement using the `CROSS APPLY`.

| EmployeeID | FirstName | LastName | Department |  Salary   | IsMatch |
|------------|-----------|----------|------------|-----------|---------|     
| 1          | John      | Wilson   | Accounting | 100000.00 |    1    |
| 2          | Sarah     | Shultz   | Accounting |  90000.00 |    0    |

--------------------------------------------------------------------------------------------------------
## Table Type 5
### Subquery

A subquery is a query nested within another query. Subqueries can be used in various parts of a SQL query, such as the `SELECT`, `FROM`, `WHERE`, and `HAVING` clauses. They are handy for performing operations that require multiple scans of the same or different tables, complex calculations, or referencing results that are not part of the main query.  A subquery can be correlated (which depends on the outer query) or non-correlated.

Here is an example of a correlated subquery using the `Employees` table.  We will discuss correlated subqueries more in the semi-join and anti-join portions of this repository.

```sql
SELECT  e.*
FROM    dbo.Employees e
WHERE   e.Salary >  (SELECT AVG(Salary)
                     FROM dbo.Employees
                     WHERE Department = e.Department);
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |

--------------------------------------------------------------------------------------------------------
## Table Type 6
### Derived Table

A derived table is a special type of subquery. It is an expression that generates a table within the scope of the `FROM` clause.  

A derived table has three characteristics:

1. It is defined in the `FROM` clause.
2. It is enclosed in parentheses.
3. It has a table alias.

Here is an example of a derived table in SQL.

```sql
SELECT  e.*,
        e2.EmployeeID,
        e2.Salary
FROM    (SELECT EmployeeID, FirstName, LastName, Salary FROM dbo.Employees) e INNER JOIN 
        dbo.Employees e2 ON e.Salary > e2.Salary
ORDER BY 1, 2, 3, 4, 5;
```

| EmployeeID | FirstName | LastName |  Salary   | EmployeeID |  Salary  |
|------------|-----------|----------|-----------|------------|----------|
| 1          | John      | Wilson   | 100000.00 | 2          | 90000.00 |

--------------------------------------------------------------------------------------------------------
## Table Type 7
### Common Table Expression (CTE) 

A common table expression (CTE) is a named query expression that exists for one statement and can be used with `SELECT`, `INSERT`, `UPDATE`, `DELETE`, or `MERGE`, or in a view definition.   

```sql        
WITH EmployeesByDepartment AS 
(
SELECT  Department,
        COUNT(*) AS EmployeeCount
FROM    dbo.Employees
GROUP BY Department
)
SELECT  Department,
        EmployeeCount
FROM    EmployeesByDepartment
WHERE   EmployeeCount > 1;
```

| Department | EmployeeCount |
|------------|---------------|
| Accounting | 2             |

Besides improving the readability of an SQL statement, CTEs can be used for recursion.  This example creates a Fibonacci sequence using a self-referencing CTE.

```sql
WITH cte_Recursion (PrevNumber, Number) AS
(
SELECT  0, 1
UNION ALL
SELECT  Number, PrevNumber + Number
FROM    cte_Recursion
WHERE   Number < 1000000000
)
SELECT PrevNumber AS Fibonacci
FROM   cte_Recursion
OPTION (MAXRECURSION 0);
```

--------------------------------------------------------------------------------------------------------
## Table Type 8
### Temporary Table        

The syntax for creating temporary tables varies across database systems.  These examples work in Microsoft SQL Server.

Local temporary tables and global temporary tables are two types of temporary tables in SQL. The main difference between them is their scope and visibility. 

*  You can use a single octothorpe (#) for a local temporary table and two octothorpes (##) for a global temporary table.
*  Local temporary tables are visible only within the session that created them, including nested stored procedures executed by that session. They are automatically dropped when their scope ends. 
*  Global temporary tables are available to every user's session.  
*  You can place the same constraints, except for `FOREIGN KEY` constraints, on a temp table as you can on a permanent table.  
*  Indexing is allowed on temporary tables.
*  Temporary tables reside in `tempdb`, and their metadata can be seen in the information schema.

This creates a local temporary table in SQL Server.

```sql
CREATE TABLE #Employees
(
EmployeeID INTEGER PRIMARY KEY,
FirstName  VARCHAR(100) NOT NULL,
LastName   VARCHAR(100) NOT NULL,
Department VARCHAR(100) NOT NULL,
Salary     MONEY NOT NULL
);

INSERT INTO #Employees SELECT * FROM dbo.Employees;

SELECT * FROM #Employees ORDER BY 1;
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |
| 2          | Sarah     | Shultz   | Accounting |  90000.00 |

You can also create temporary tables via the `INTO` statement in a SQL statement.  This works in Microsoft SQL Server, and each database system has slightly different syntax for temporary tables.

```sql
SELECT  *
INTO    #Employees2
FROM    dbo.Employees;

SELECT * FROM #Employees2 ORDER BY 1;
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |
| 2          | Sarah     | Shultz   | Accounting |  90000.00 |

--------------------------------------------------------------------------------------------------------
## Table Type 9
### Table Variable   

Table variables store temporary tabular data within a batch, stored procedure, or function. A table variable declared from a user-defined table type can also be passed to a stored procedure as a table-valued parameter.  Each database may implement table variables slightly differently, but Microsoft SQL Server has the following considerations.

*  You can place constraints on the table except for `FOREIGN KEY` constraints.
*  The constraints must be placed on the table on creation.
*  You cannot alter the table variable once it is created.
*  You cannot execute `CREATE INDEX` against a table variable after declaring it. However, `PRIMARY KEY` and `UNIQUE` constraints create indexes.
*  You cannot truncate a table variable.
*  Table variables are stored in `tempdb`. 
*  Table variables are not affected by rollbacks.
*  SQL Server does not maintain distribution statistics on table variables. SQL Server 2019 and later can use table-variable deferred compilation to improve cardinality estimates when the appropriate database compatibility level is enabled.

```sql
DECLARE @TableVariable TABLE
(
EmployeeID INTEGER PRIMARY KEY,
FirstName  VARCHAR(100) NOT NULL,
LastName   VARCHAR(100) NOT NULL,
Department VARCHAR(100) NOT NULL CHECK (Department IN ('Engineering', 'Accounting', 'Finance')),
Salary     MONEY NOT NULL DEFAULT 0
);

INSERT INTO @TableVariable
SELECT * FROM dbo.Employees;

SELECT * FROM @TableVariable ORDER BY 1;
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |
| 2          | Sarah     | Shultz   | Accounting |  90000.00 |

--------------------------------------------------------------------------------------------------------
## Table Type 10
### User-Defined Table Types

User-defined table types are a special type in SQL Server that allows for the definition of table structures. These structures are used as parameters in stored procedures or functions, allowing for the passage of multiple rows of data in a single parameter. 

A table type cannot have a FOREIGN KEY constraint. Also, a user-defined table type cannot be altered after creation; to change it, you generally must drop and recreate it after removing objects that depend on it.

User-defined table types are used in conjunction with table variables such as the following.

```sql
CREATE TYPE dbo.MyTableType AS TABLE
(
EmployeeID INTEGER PRIMARY KEY,
FirstName  VARCHAR(100) NOT NULL,
LastName   VARCHAR(100) NOT NULL,
Department VARCHAR(100) NOT NULL,
Salary     MONEY NOT NULL
);
GO

CREATE OR ALTER PROCEDURE dbo.MyProcedure
    @Data dbo.MyTableType READONLY
AS
BEGIN
    SELECT *
    FROM @Data;
END;
GO

DECLARE @Input dbo.MyTableType;

INSERT INTO @Input (EmployeeID, FirstName, LastName, Department, Salary) VALUES (1,'John','Wilson','Accounting',100000);
INSERT INTO @Input (EmployeeID, FirstName, LastName, Department, Salary) VALUES (2,'Sarah','Shultz','Accounting',90000);

EXEC dbo.MyProcedure @Data = @Input;
GO
```

| EmployeeID | FirstName | LastName | Department |  Salary   |
|------------|-----------|----------|------------|-----------|
| 1          | John      | Wilson   | Accounting | 100000.00 |
| 2          | Sarah     | Shultz   | Accounting |  90000.00 |

--------------------------------------------------------------------------------------------------------
## Table Type 11
### External Tables           

External tables in Microsoft SQL Server are database objects that allow access to data stored outside the SQL Server instance, typically through PolyBase and an external data source. They reference external data sources and external file formats, enabling SQL Server to query data stored in locations such as Hadoop, Azure Blob Storage, Azure Data Lake Storage, or another SQL Server via PolyBase.

These tables appear like regular tables but are read-only and do not physically store data within the SQL Server database. Instead, they act as a metadata layer that enables querying external data using T-SQL. This is particularly useful for data integration, bulk data loading, archiving, and working with large datasets without importing them into SQL Server.

However, external tables have some limitations:

*  Indexing is not supported on external tables.
*  Query performance may be slower due to reliance on external storage and network latency.
*  DML operations (`INSERT`, `UPDATE`, `DELETE`) are not supported directly on external tables.

The Microsoft SQL Server documentation has the following examples.

> **Version note:** The following Hadoop example applies to SQL Server
> 2016 through SQL Server 2019. SQL Server 2022 and later do not support
> Hadoop external data sources through PolyBase.


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

### Continue Reading

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
12. [Relational Division](12%20-%20Relational%20Division.md)
13. [Set Operations](13%20-%20Set%20Operations.md)
14. [Join Algorithms](14%20-%20Join%20Algorithms.md)
15. [Exists](15%20-%20Exists.md)
16. [Complex Joins](16%20-%20Complex%20Joins.md)

https://advancedsqlpuzzles.com
