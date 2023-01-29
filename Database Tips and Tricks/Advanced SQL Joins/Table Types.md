# Table Types

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Within SQL, you can create a join to the following 10 table types, some of these objects are schema bound objects, meaning they are saved as a database object within a named schema, and others are unbound and only durable for the life of an SQL statement (CTE, Subquery, Values, Derived Tables) or your current session (Table Variable, Temporary Table).  Items that are not schema bound are created in the tempdb and do not have any data of their existince in the catalog views.

| Id |              Name              |  Schema Bound |                                                                 Description                                                                |
|----|--------------------------------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------|
|  1 |  Static table                  |  True         |  A regular table that is stored in the database.                                                                                           |
|  2 |  View                          |  True         |  A virtual table that is based on the result of a SELECT statement.                                                                        |
|  3 |  Values Constructor            |  True         |  The VALUES constructor can be used to create a derived table, which is a table that is created and used within a single SQL query.        |
|  4 |  Table Valued Function         |  True         |  A function that returns a table as its result.                                                                                            |
|  5 |  Subquery                      |  False        |  A query that is embedded within another query. The results of a subquery can be used in the outer query.                                  |
|  6 |  Derived Table                 |  False        |  A special type of subquery that is defined in the FROM statement, encloused in parenthses and a table name is provided.                   |
|  7 |  Common Table Expression (CTE) |  False        |  A named temporary result set that can be used in a SELECT, INSERT, UPDATE, or DELETE statement.                                           |
|  8 |  Temporary Table               |  False        |  A table that is created for a specific session or connection and is automatically dropped when the session or connection ends.            |
|  9 |  Table Variable                |  False        |  A variable that holds a table of data. It is similar to a temporary table but it has some differences in terms of its behavior and scope. |
| 10 |  External Tables               |  False        |  Used to access data stored externally, such as in a text file. They are created using the CREATE EXTERNAL TABLE statement.                |




---
### VALUES Operator


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For this document we are going to concentrate on the VALUES constructor, as this constructor has a few considerations that are often overlooked and deserve its own recognition.  The VALUES constructor specifies a set of row value expressions to be constructed into a table and allows multiple sets of values to be specified in a single DML statement.  Normally we use the VALUES constructor to specify the data to insert into a table, as we initially did with our test data, but it can also be used as a derived table in an SQL statement.

----

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


---

Here is a more elaborate example where the VALUES constructor specifies the values to return.  This statement uses an INNER JOIN, but you can use the usual OUTER JOIN, FULL OUTER JOIN, or CROSS JOIN.

```sql
SELECT  a.Fruit
FROM    ##TableA a INNER JOIN
        (VALUES ('Kiwi'), ('Apple')) AS b(Fruit) ON a.Fruit = b.Fruit;
```

| Fruit |
|-------|
| Apple |

---

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

---
  
Up next is I don't know!
  
Happy coding!
