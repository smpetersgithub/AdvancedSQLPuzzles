# Complex Joins

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In this document we will define complex joins and highlight a few examples.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Complex joins is a descriptive term that refers to join operations that involve multiple tables and require more intricate join conditions than simple joins.  These joins can become quite complex when multiple conditions must be met to return the desired result set.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To create complex joins, it's essential to have a clear understanding of the relationships between the tables and the desired outcome. It is also essential to use clear and concise syntax, such as using explicit join clauses and knowing when to use windowing, ranking, lag/lead functions, etc... By breaking down complex joins into smaller, simpler join operations, it can be easier to understand and maintain the query.

Overall, here are some tips I use when working with complex joins.

1.  **Break down the query into smaller parts**: Divide the query into smaller, more manageable parts. Start by understanding the different clauses and how they fit together.
3.  **Know the database schema**: Understanding the database structure, including tables, columns, relationships, and constraints, is essential for understanding complex queries.
4.  **Identify the purpose of each clause**: Understand what each clause in the query is meant to do and how it contributes to the overall result.
5.  **Use diagrams or visual aids**: Draw a diagram of the relationships between tables or use other visual aids to help you understand the data flow in the query.
6.  **Test and validate the query**: Try running the query with a small subset of data to see the result and validate the output to ensure it matches your expectations.

-----------------------------------------------------

#### Driving Tables

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; One crucial concept of good query planning is understanding a driving table.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A driving table in SQL refers to the table that drives the execution of a query. In a query that involves multiple tables, the driving table determines the order in which the records are retrieved and processed and can have a significant impact on the performance of the query.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The driving table is typically the table with the smallest number of records or the table that has the most selective conditions applied to it. By starting with the driving table, the database can eliminate as many records as possible early in the processing, reducing the amount of data that needs to be further processed and improving the performance of the query.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;It is essential to carefully consider the driving table when writing complex SQL queries to ensure optimal performance. A well-chosen driving table can help to minimize the amount of data that needs to be processed and can lead to much faster query execution times. On the other hand, a poorly chosen driving table can result in slow query performance and inefficiencies in database processing.

-----------------------------------------------------
#### Multiple Branches

These types of SQL statements I like to refer to as branch joins.  First, let's look at the SQL statement.

```sql
SELECT  t.TransactionDate,
        ISNULL(tt.TransactionType,'Other') AS TransType,
        u.Name,
        SUM(t.Amount) AS DailyATMAmount
FROM    Users u INNER JOIN
        Transaction t ON u.AccountID - t.DebitAccountID LEFT OUTER JOIN
        TransactionType tt ON t.TranTypeID = tt.TranTypeID INNER JOIN
        SubUsers su ON u.SecondaryAccountID = su.SubAccountID INNER JOIN
        FeePlan fp ON u.FeePlanID = fp.FeePlanID OR su.FeePlanID = fp.FePlanID;
WHERE   fp.FeePlanType = 'Advantage' AND 
        t.TransactionDate BETWEEN '01-01-2023' AND '12-31-2023' AND
        su.AccountStatus = 'Enrolled';
```

Breaking down the joins, we have the following:
*  `Users` -> `Transaction` -> `TransactionType`
*  `Users` -> `SubUsers` -> `FeePlan`

From this join breakdown, we can see we have one root, two branches, and two leaf nodes.  The root table `Users` is our driving table.  Given this, here is a simpler way of writing the statement.

```sql
WITH cte_Users AS
(
SELECT  UserID
FROM    Users u INNER JOIN
        SubUsers su ON u.SecondaryAccountID = su.SubAccountID INNER JOIN
        FeePlan fp ON u.FeePlanID = fp.FeePlanID OR su.FeePlanID = fp.FePlanID;
WHERE   su.AccountStatus = 'Enrolled' AND 
        fp.FeePlanType = 'Advantage'
),
cte_Transaction AS
(
SELECT  t.TransactoinDate,
        t.DebitAccountID,
        t.Amount,
        tt.FeePlanType`
FROM    Users u INNER JOIN
        Transaction t ON u.AccountID - t.DebitAccountID LEFT OUTER JOIN
        TransactionType tt ON t.TranTypeID = tt.TranTypeID
WHERE   t.TransactionDate BETWEEN '01-01-2023' AND '12-31-2023';
)
SELECT  t.TransactionDate,
        ISNULL(t.TransactionType,'Other') AS TransType,
        u.Name,
        SUM(t.Amount) AS DailyATMAmount
FROM    cte_Users u INNER JOIN
        cte_Transactions on u.AccountID - t.DebitAccountID
GROUP BY t.TransactionDate,
        ISNULL(t.TransactionType,'Other'),
        u.Name;
```

-----------------------------------------------------
#### Overlapping Time Periods

This puzzle is called "Overlapping Time Periods", and I find this to be the most challenging puzzle to solve.
For this example, I used temporary tables to avoid making a common table expression dependent on another common table expression.  This allows future developers to quickly review the data sets in the step order and reverse engineer the statement.

Here is the overlapping time period data.

| StartDate  |  EndDate   |
|------------|------------|
| 2018-01-01 | 2018-01-05 |
| 2018-01-03 | 2018-01-09 |
| 2018-01-10 | 2018-01-11 |
| 2018-01-12 | 2018-01-16 |
| 2018-01-15 | 2018-01-19 |

Here is the expected output:

| StartDate  |  EndDate   |
|------------|------------|
| 2018-01-01 | 2018-01-09 |
| 2018-01-10 | 2018-01-11 |
| 2018-01-12 | 2018-01-19 |

The following solution uses a `LEFT OUTER JOIN` with a theta-join to create the table `#OuterJoin`.

```sql
CREATE TABLE #TimePeriods
(
StartDate  DATE,
EndDate    DATE,
PRIMARY KEY (StartDate, EndDate)
);

INSERT INTO #TimePeriods (StartDate, EndDate) VALUES ('1/1/2018','1/5/2018'),
INSERT INTO #TimePeriods (StartDate, EndDate) VALUES ('1/3/2018','1/9/2018'),
INSERT INTO #TimePeriods (StartDate, EndDate) VALUES ('1/10/2018','1/11/2018'),
INSERT INTO #TimePeriods (StartDate, EndDate) VALUES ('1/12/2018','1/16/2018') 
INSERT INTO #TimePeriods (StartDate, EndDate) VALUES ('1/15/2018','1/19/2018');

--Step 1
SELECT  DISTINCT
        StartDate
INTO    #Distinct_StartDates
FROM    #TimePeriods;

--Step 2
SELECT  a.StartDate AS StartDate_A,
        a.EndDate AS EndDate_A,
        b.StartDate AS StartDate_B,
        b.EndDate AS EndDate_B
INTO    #OuterJoin
FROM    #TimePeriods AS a LEFT OUTER JOIN
        #TimePeriods AS b ON a.EndDate >= b.StartDate AND
                                a.EndDate < b.EndDate;

--Step 3
SELECT  EndDate_A
INTO    #DetermineValidEndDates
FROM    #OuterJoin
WHERE   StartDate_B IS NULL
GROUP BY EndDate_A;

--Step 4
SELECT  a.StartDate, MIN(b.EndDate_A) AS MinEndDate_A
INTO    #DetermineValidEndDates2
FROM    #Distinct_StartDates a INNER JOIN
        #DetermineValidEndDates b ON a.StartDate <= b.EndDate_A
GROUP BY a.StartDate;

--Results
SELECT  MIN(StartDate) AS StartDate,
        MAX(MinEndDate_A) AS EndDate
FROM    #DetermineValidEndDates2
GROUP BY MinEndDate_A;
```


-------------------------------------------------

#### Programming Style

Lastly, when writing SQL, programming style goes a long way to readability.  

1.  Choose a more verbose solution over a concise solution where the intent of the SQL statement is more apparent when possible.  
2.  Understand the SQL language and its various functions, such as `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`, etc., and how to perform windowing.
3.  Understand the relation between the data, especially hierarchical data.  I often see bad implementations of hierarchical data structures.
4.  Just because you can doesn't mean you should.  For example, don't use a table variable if it is unneeded.
5.  Write well-formatted code.  I’m partial to keywords in upper case, column names in camel case, and my glyphs all spaces with nice white spacing.

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
12. [Relational Division](12%20-%20Relational%20Division.md)
13. [Set Operations](13%20-%20Set%20Operations.md)
14. [Join Algorithms](14%20-%20Join%20Algorithms.md)
15. [Exists](15%20-%20Exists.md)
16. [Complex Joins](16%20-%20Complex%20Joins.md)

https://advancedsqlpuzzles.com
