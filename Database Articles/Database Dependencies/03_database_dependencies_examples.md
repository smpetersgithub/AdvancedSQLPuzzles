#### Table of Contents

1. [Introduction to SQL Server Object Dependencies](01_introduction_database_dependencies.md)
2. [Create Demo Databases and Schemas](02_create_demo_databases_and_schemas.md)
3. [Database Dependency Examples](03_database_dependencies_examples.md)
4. [Analyze Database Dependencies](04_analyze_database_dependencies.md)
5. [Determine Object Dependency Paths](05_determine_object_dependency_paths.md)
6. [Determine Foreign Key Paths](06_determine_foreign_key_paths.md)
   
<img src="https://raw.githubusercontent.com/smpetersgithub/AdvancedSQLPuzzles/main/images/AdvancedSQLPuzzles_image.png" alt="Advanced SQL Puzzles" width="200"/>

# Database Dependencies Examples


Next, we will review examples of database dependencies and how they are represented in the `sys.sql_expression_dependencies` table. These examples provide a comprehensive demonstration of the various types of dependencies that can occur in a database and illustrate how each is reflected (or not reflected) in the `sys.sql_expression_dependencies` table.

[📄 The corresponding scripts for this walkthrough are available here.](https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Database%20Articles/Database%20Dependencies/)

### Summary of Contents

1. [Cross-Databases and Cross-Schema Dependencies](03_database_dependencies_examples.md#01-cross-databases-and-cross-schema-dependencies)
2. [Cross Schema Dependencies](03_database_dependencies_examples.md#02-cross-schema-dependencies)
3. [Invalid Stored Procedures](03_database_dependencies_examples.md#03-invalid-stored-procedures)
4. [Numbered Stored Procedures](03_database_dependencies_examples.md#04-numbered-stored-procedures)
5. [Ambiguous References](03_database_dependencies_examples.md#05-ambiguous-references)
6. [Part Naming Conventions](03_database_dependencies_examples.md#06-part-naming-conventions)
7. [Part Naming Conventions - Caller Dependent](03_database_dependencies_examples.md#07-part-naming-conventions---caller-dependent)
8. [Dropping Objects](03_database_dependencies_examples.md#08-dropping-objects)
9. [Dropping Objects Then Recreating](03_database_dependencies_examples.md#09-dropping-objects-then-recreating)
10. [Self-Referencing Objects](03_database_dependencies_examples.md#10-self-referencing-objects)
11. [Object Aliases](03_database_dependencies_examples.md#11-object-aliases)
12. [Schemabindings](03_database_dependencies_examples.md#12-schemabindings)
13. [Synonyms](03_database_dependencies_examples.md#13-synonyms)
14. [Triggers - DML](03_database_dependencies_examples.md#14-triggers---dml)
15. [Triggers - DDL Database Level](03_database_dependencies_examples.md#15-triggers---ddl-database-level)
16. [Triggers - DDL Server Level - Table Insert](03_database_dependencies_examples.md#16-triggers---ddl-server-level---table-insert)
17. [Partition Functions](03_database_dependencies_examples.md#17-partition-functions)
18. [Defaults and Rules](03_database_dependencies_examples.md#18-defaults-and-rules)
19. [Contracts, Queues, and Message Types](03_database_dependencies_examples.md#19-contracts-queues-and-message-types)
20. [Sequences](03_database_dependencies_examples.md#20-sequences)
21. [User Defined Data Types](03_database_dependencies_examples.md#21-user-defined-data-types)
22. [User Defined Table Types](03_database_dependencies_examples.md#22-user-defined-table-types)
23. [Check Constraints](03_database_dependencies_examples.md#23-check-constraints)
24. [Foreign Key Constraints](03_database_dependencies_examples.md#24-foreign-key-constraints)
25. [Computed Columns](03_database_dependencies_examples.md#25-computed-columns)
26. [Masked Functions](03_database_dependencies_examples.md#26-masked-functions)
27. [Indexes - Table](03_database_dependencies_examples.md#27-indexes---table)
28. [Indexes - Filtered NonClustered](03_database_dependencies_examples.md#28-indexes---filtered-nonclustered)
29. [Indexes - Filtered XML](03_database_dependencies_examples.md#29-indexes---filtered-xml)
30. [Statistics - Filtered](03_database_dependencies_examples.md#30-statistics---filtered)
31. [XML Schema Collection](03_database_dependencies_examples.md#31-xml-schema-collection)
32. [XML Methods](03_database_dependencies_examples.md#32-xml-methods)
33. [Feature Installed Procedures](03_database_dependencies_examples.md#33-feature-installed-procedures)
34. [Security_Policies](03_database_dependencies_examples.md#34-security-policies)




***

### 01. Cross-Databases and Cross-Schema Dependencies

In this example, we create objects in two different databases and create a cross-database dependency. This will be the only example where we use different databases.

To obtain more information about the object, you must use the `referenced_database_name`, `referenced_schema_name`, and `referencing_object_name` columns to join with the `sys.objects` table in the corresponding database.

🔹For cross-database dependencies, the `referenced_id` column will contain a NULL marker. 

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_01
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

-------------------------------------------------------
USE bar
GO

CREATE VIEW dbo.vw_example_01 AS
SELECT  ProductID, 
        SUM(Quantity) AS QuantityOrdered
FROM    foo.dbo.tbl_example_01
GROUP BY ProductID;
GO
```

The results from the `foo` database will be an empty set.

The results from the `bar` database are as follows.

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 01             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | bar                       | dbo                     | vw\_example\_01         | 1205579333     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        | foo                      | dbo                    | tbl\_example\_01       |                        |               | 0                   | 0                   | 0            | 0                         |                          |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 02. Cross Schema Dependencies

Next, we will examine a dependency between two schemas within the same database.

The `referencing_schema_name` will populate the corresponding schema.

```sql
USE foo;
GO

CREATE TABLE schemaA.tbl_example_02_schemaA
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE TABLE dbo.tbl_example_02_dbo
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE VIEW dbo.vw_example_02 AS
SELECT  1 AS myValue
FROM    schemaA.tbl_example_02_schemaA CROSS JOIN
        dbo.tbl_example_02_dbo;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name    | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ------------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 02             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_example\_02         | 1301579675     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_02\_dbo     | U                      | 1285579618    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 02             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_example\_02         | 1301579675     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | schemaA                | tbl\_example\_02\_schemaA | U                      | 1269579561    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 03. Invalid Stored Procedures

Here, we will create a stored procedure that references a non-existent table. This procedure will be compiled as SQL Server uses deferred name resolution, but it will not execute. Once the invalid object is created, the `referenced_id` column will populate with the correct ID.

🔹For invalid stored procedures, the `referenced_id` column will contain a NULL marker. 

```sql
USE foo;
GO

CREATE PROCEDURE dbo.sp_example_03 AS
BEGIN
     SELECT  *
     FROM   dbo.tbl_does_not_exist_example_03;
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name             | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 03             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_03         | 1317579732     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_does\_not\_exist\_example\_03 |                        |               | 0                   | 0                   | 0            | 0                         |                          |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 04. Numbered Stored Procedures

Numbered Stored Procedures in SQL Server are a legacy feature that allows you to create a sequence of procedures with the same base name, distinguished by a number (e.g., `procName;1`, `procName;2`). They are deprecated and not recommended for new development.

Numbered Stored Procedures will only show dependencies of the base stored procedure.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_04_a
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE TABLE dbo.tbl_example_04_b
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE PROCEDURE dbo.sp_example_04;1 AS
BEGIN
     SELECT  *
     FROM    dbo.tbl_example_04_a;
END;
GO

CREATE PROCEDURE dbo.sp_example_04;2 AS
BEGIN
     SELECT  *
     FROM    dbo.tbl_example_04_b;
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 04             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_04         | 1365579903     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_04\_a    | U                      | 1333579789    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 05. Ambiguous References

The ambiguity in this example stems from the fact that the function `dbo.fn_example_05` will resolve the `OrderID` passed to it in the `SELECT` statement at runtime and does not evaluate this dependency during compilation.

Although this dependency is marked as ambiguous, the `referenced_id` column is populated.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_05
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE FUNCTION dbo.fn_example_05(@intToCheck INT) RETURNS VARCHAR(MAX) AS
BEGIN
    RETURN CASE WHEN @intToCheck IS NULL THEN -1 ELSE @intToCheck END;
END;
GO

CREATE PROCEDURE dbo.sp_example_05 (@inputInt INT) AS
BEGIN
    SELECT dbo.fn_example_05(tbl_example_05.OrderID)
    FROM   dbo.tbl_example_05;
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 05             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_05         | 1413580074     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | fn\_example\_05        | FN                     | 1397580017    | 0                   | 0                   | 1            | 0                         | 0                        |                           | 0                   |
| 05             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_05         | 1413580074     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_05       | U                      | 1381579960    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 06. Part Naming Conventions

Here, we create different objects using one-, two-, and three-part naming conventions. The `referenced_database_name`, `referenced_schema_name`, and `referencing_object_name` columns are populated accordingly.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_06
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE VIEW dbo.vw_one_part_name_example_06 AS
SELECT  *
FROM    tbl_example_06; --one-part
GO

CREATE VIEW dbo.vw_two_part_name_example_06 AS
SELECT  *
FROM    dbo.tbl_example_06; --two-part
GO

CREATE VIEW dbo.vw_three_part_name_example_06 AS
SELECT  *
FROM    foo.dbo.tbl_example_06; --three-part
GO

CREATE VIEW dbo.vw_four_part_name_example_06 AS
SELECT  *
FROM    [DESKTOP-D324ETP\SQLEXPRESS01].foo.dbo.tbl_example_06; --four-part
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name            | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name       | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ---------------------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 06             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_one\_part\_name\_example\_06   | 1445580188     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                              |                          |                        | tbl\_example\_06       | U                      | 1429580131    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 06             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_two\_part\_name\_example\_06   | 1461580245     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                              |                          | dbo                    | tbl\_example\_06       | U                      | 1429580131    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 06             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_three\_part\_name\_example\_06 | 1477580302     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                              | foo                      | dbo                    | tbl\_example\_06       | U                      | 1429580131    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 06             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_four\_part\_name\_example\_06  | 1493580359     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    | DESKTOP-D324ETP\SQLEXPRESS01 | foo                      | dbo                    | tbl\_example\_06       | U                      | 1429580131    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 07. Part Naming Conventions - Caller Dependent

This example creates two stored procedures. The stored procedure `dbo.sp_example_07_b` references `sp_example_07_a` using a one-part naming convention. This dependency will be resolved at runtime, as SQL Server first checks the user's default schema (typically the `dbo` schema) and then checks other schemas if necessary for the object. If you modify the stored procedure `dbo.sp_example_07_b` to reference `sp_example_07` using a two-part naming convention, the dependency will no longer be marked as `is_caller_dependent`.

🔹For part naming conventions, the `referenced_id` column will contain a NULL marker. 

Stored procedures are marked as caller-dependent only if they reference other stored procedures using a one-part naming convention. However, if a stored procedure references tables, functions, or views using a one-part naming convention, they are not marked as caller-dependent.

This behavior in SQL Server is tied to ownership chaining and how SQL Server resolves dependencies within objects, such as stored procedures.

* When a stored procedure references another stored procedure using a one-part name (e.g., ProcName without specifying the schema), SQL Server cannot resolve the schema of the referenced procedure until runtime.
* For tables, functions, or views referenced with a one-part name, SQL Server assumes the schema of the objects is the same as the schema of the stored procedure itself (i.e., it uses the schema of the caller to resolve dependencies).

```sql
USE foo;
GO

CREATE PROCEDURE dbo.sp_example_07_a AS
BEGIN
     PRINT 'Hello World';
END;
GO

CREATE PROCEDURE dbo.sp_example_07_b AS
BEGIN
     EXECUTE sp_example_07_a
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 07             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_07\_b      | 1525580473     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          |                        | sp\_example\_07\_a     |                        |               | 0                   | 1                   | 0            | 0                         |                          |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 08. Dropping Objects

In this example, we will create a valid object and then drop the referencing table, which will cause the view to become invalid.

🔹The `referenced_id` column will update with a NULL marker. 

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_08
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE VIEW dbo.vw_example_08 AS
SELECT  *
FROM    dbo.tbl_example_08
GO

DROP TABLE dbo.tbl_example_08;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 08             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_example\_08         | 434100587      | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_08       |                        |               | 0                   | 0                   | 0            | 0                         |                          |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 09. Dropping Objects Then Recreating

Here's an interesting example: we create a valid view, drop the corresponding table, and then recreate the dropped object as a stored procedure. In the `sys.sql_expression_dependencies` table, the entry will still appear as a valid reference, even though a view cannot reference a stored procedure.

```sql
USE foo;
GO

CREATE TABLE dbo.obj_example_09
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE VIEW dbo.vw_example_09 AS
SELECT  *
FROM    dbo.obj_example_09
GO

DROP TABLE dbo.obj_example_09;
GO

CREATE PROCEDURE dbo.obj_example_09 AS
BEGIN
     PRINT('Hello World');
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 09             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_example\_09         | 466100701      | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | obj\_example\_09       | P                      | 482100758     | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 10. Self-Referencing Objects

We often associate self-referencing objects with common table expressions, which are used for recursion. However, stored procedures and functions can also reference themselves.

🔹This example represents a self-referencing object, as the `referencing_id` and `referenced_id` are identical.

```sql
USE foo;
GO

CREATE FUNCTION dbo.fn_example_10 (@vInputString VARCHAR(100)) RETURNS VARCHAR(100) AS
BEGIN
     DECLARE @vResult VARCHAR(100);
     SET     @vResult = dbo.fn_example_10('Hello World');
     RETURN  @vResult;
END;
GO

CREATE PROCEDURE dbo.sp_example_10 AS
BEGIN
     EXEC dbo.sp_example_10;
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 10             | FN                      | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | fn\_example\_10         | 1621580815     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | fn\_example\_10        | FN                     | 1621580815    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 10             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_10         | 1637580872     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | sp\_example\_10        | P                      | 1637580872    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 11. Object Aliases

Here's another interesting example: when a temporary table is updated using an alias, the alias is recorded in the `referenced_entity_name` column.

🔹For object aliases, the `referenced_id` column will contain a NULL marker. 

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_11
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE PROCEDURE dbo.sp_example_11 AS
BEGIN
     UPDATE  alias_example_11
     SET     Quantity = 0
     FROM    dbo.tbl_example_11 AS alias_example_11;
     
     UPDATE  alias_example_11
     SET     Quantity = 0
     FROM    #temp_table AS alias_example_11;
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 11             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_11         | 1669580986     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          |                        | alias\_example\_11     |                        |               | 0                   | 0                   | 0            | 0                         |                          |                           | 0                   |
| 11             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_11         | 1669580986     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_11       | U                      | 1653580929    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 12. Schemabindings

In SQL Server, schema binding is an option that can be used when creating views or functions to bind the object to the schema of any underlying tables it references. When schema binding is applied, it prevents modifications to the underlying tables (such as changing the table structure or dropping columns) that would affect the object, ensuring data integrity and stability. This also allows for some performance optimizations, such as creating indexed views.

With schemabinding, two records will be created where `is_schema_bound_reference` will be set to 1, with one of the records having `referenced_minor_id` set to 1.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_12
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE FUNCTION dbo.fn_example_12() RETURNS INT
WITH SCHEMABINDING AS
BEGIN
    DECLARE @result INT;

    SELECT  TOP 1
            @result = OrderID
    FROM    dbo.tbl_example_12;

    RETURN @result;
END;
GO

CREATE VIEW dbo.vw_example_12
WITH SCHEMABINDING AS
SELECT  OrderID
FROM    dbo.tbl_example_12;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 12             | FN                      | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | fn\_example\_12         | 1701581100     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_12       | U                      | 1685581043    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 12             | FN                      | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | fn\_example\_12         | 1701581100     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_12       | U                      | 1685581043    | 1                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 12             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_example\_12         | 1717581157     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_12       | U                      | 1685581043    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 12             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_example\_12         | 1717581157     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_12       | U                      | 1685581043    | 1                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 13. Synonyms

In SQL Server, a synonym is an alias or alternative name for another database object, such as a table, view, or stored procedure. It makes it easier to reference that object without using its full name. Synonyms provide a layer of abstraction, allowing underlying objects to be changed or moved without affecting the code that references them.

The referencing object that points to the synonym is recorded in the `sys.sql_expression_dependencies` table, but the object that the synonym references is not captured. Refer to the `sys.synonyms` table to identify the underlying object for a synonym.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_13
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

--Invalid
CREATE SYNONYM dbo.syn_invalid_example_13 FOR tbl_does_not_exist_13;
GO

--Valid
CREATE SYNONYM dbo.syn_example_13 FOR tbl_example_13;
GO

CREATE VIEW dbo.vw_example_13 AS
SELECT *
FROM   dbo.syn_example_13;
GO

CREATE PROCEDURE dbo.sp_example_13 AS
BEGIN
     SELECT * FROM dbo.syn_example_13;
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 13             | V                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | vw\_example\_13         | 1781581385     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | syn\_example\_13       | SN                     | 1765581328    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 13             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_13         | 1797581442     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | syn\_example\_13       | SN                     | 1765581328    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 14. Triggers - DML

In SQL Server, a DML trigger is a particular type of stored procedure that automatically executes in response to data modification events (such as `INSERT`, `UPDATE`, or `DELETE`) on a table or view. This allows you to enforce business rules or perform additional actions when data changes occur.

Here, you can observe that the DML trigger references the internal SQL Server tables `deleted` and `inserted`, which store the deleted and inserted records, respectively, during the execution of a DML statement.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_14
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE TRIGGER dbo.trg_example_14 ON dbo.tbl_example_14
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
     SELECT * FROM inserted;
     SELECT * FROM deleted;
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 14             | TR                      | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | trg\_example\_14        | 1829581556     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          |                        | deleted                |                        |               | 0                   | 0                   | 0            | 0                         |                          |                           | 0                   |
| 14             | TR                      | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | trg\_example\_14        | 1829581556     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          |                        | inserted               |                        |               | 0                   | 0                   | 0            | 0                         |                          |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 15. Triggers - DDL Database Level

DDL triggers are a specific type of trigger that fires in response to Data Definition Language (DDL) events, such as `CREATE`, `ALTER`, or `DROP` statements. DDL triggers can be set at the database level to monitor or enforce rules on schema changes, helping to log, restrict, or audit modifications to the database structure.

The `referencing_id` for database-level triggers does not have a corresponding entry in the `sys.objects` table. To locate information, you must refer to the `sys.triggers` table instead.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_15
(
EventID INT IDENTITY(1,1) PRIMARY KEY,
EventType VARCHAR(100),
ObjectName VARCHAR(255),
ObjectType VARCHAR(100),
EventDate DATETIME,
LoginName VARCHAR(255),
UserName VARCHAR(255),
CommandText VARCHAR(MAX)
);
GO

CREATE TRIGGER trg_example_15 ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN   
    DECLARE @EventData XML;
    SET @EventData = EVENTDATA();

    INSERT INTO dbo.tbl_example_15 (EventType,ObjectName,ObjectType,EventDate,LoginName,UserName,CommandText)
    VALUES
    (
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'), -- Event type (e.g., CREATE, ALTER, DROP)
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)'), -- Object name (e.g., table name)
        @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'), -- Object type (e.g., TABLE)
        GETDATE(), -- The current date and time
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(255)'), -- The login name of the user
        @EventData.value('(/EVENT_INSTANCE/UserName)[1]', 'NVARCHAR(255)'), -- The user name that performed the action
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)') -- The executed SQL command
    );
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 15             | TR                      | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       |                         | trg\_example\_15        | 1877581727     | 0                    | 12                | DATABASE\_DDL\_TRIGGER | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_15       | U                      | 1845581613    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 16. Triggers - DDL Server Level - Table Insert

Server-level DDL triggers can capture and respond to server-wide DDL events such as `CREATE LOGIN` or `DROP DATABASE`.

The `referencing_id` for server-level triggers does not have a corresponding entry in the `sys.objects` table.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_16
(
EventID INT IDENTITY(1,1) PRIMARY KEY,
EventType VARCHAR(100),
ObjectName VARCHAR(255),
ObjectType VARCHAR(100),
EventDate DATETIME,
LoginName VARCHAR(255),
UserName VARCHAR(255),
CommandText VARCHAR(MAX)
);
GO

-- Create the trigger
CREATE TRIGGER trg_example_16 ON ALL SERVER 
FOR CREATE_DATABASE
AS
BEGIN
    DECLARE @EventData XML;
    SET @EventData = EVENTDATA();

    INSERT INTO foo.dbo.tbl_example_16 (EventType,ObjectName,ObjectType,EventDate,LoginName,UserName,CommandText)
    VALUES
    (
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        GETDATE(),
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(255)'),
        @EventData.value('(/EVENT_INSTANCE/UserName)[1]', 'NVARCHAR(255)'),
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
    );
END;
GO

-- Create a new database and trigger the event
CREATE DATABASE db_example_16;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 16             | TR                      | DESKTOP-D324ETP\SQLEXPRESS01 | master                    |                         | trg\_example\_16        | 2085634523     | 0                    | 13                | SERVER\_DDL\_TRIGGER   | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        | foo                      | dbo                    | tbl\_example\_16       |                        |               | 0                   | 0                   | 0            | 0                         |                          |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 17. Partition Functions

A partition function determines how data is divided across multiple partitions within a table or index based on the specified values of a specified column. It maps rows to partitions using a set of boundary values, allowing you to manage and query large datasets more efficiently by distributing them into smaller, more manageable chunks. Partition functions are paired with partition schemes to determine the physical storage of these partitions.

Contrary to the SQL Server documentation, partition functions are not represented in the `sys.sql_expression_dependencies` table.

```sql
USE foo;
GO

-- add filegroups to your database

-- fg1
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'fg1')
BEGIN
    ALTER DATABASE foo ADD FILEGROUP fg1;
END;
GO

-- fg2
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'fg2')
BEGIN
    ALTER DATABASE foo ADD FILEGROUP fg2;
END;
GO

-- fg3
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'fg3')
BEGIN
    ALTER DATABASE foo ADD FILEGROUP fg3;
END;
GO

-- fg4
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'fg4')
BEGIN
    ALTER DATABASE foo ADD FILEGROUP fg4;
END;
GO

-- add a file to the fg4 file group
ALTER DATABASE foo
ADD FILE 
(
    NAME = 'foo_fg4_data',
    FILENAME = 'C:\data\foo_fg4_data.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP fg4;
GO

```

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 18. Defaults and Rules

Defaults are constraints that provide a default value for a column when no specific value is inserted, ensuring that a column always has data. Rules are older SQL Server objects that enforce data validation by defining a condition that column values must meet. Still, they are primarily deprecated and have been replaced by check constraints for better functionality and management.

Defaults and rules are not represented in the `sys.sql_expression_dependencies` table.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_18
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY,
PhoneNumber VARCHAR(20)
);
GO

CREATE DEFAULT dbo.default_example_18 AS 'Unknown';
GO

CREATE RULE dbo.rule_example_18 AS
(@phone = 'Unknown') OR 
(
LEN(@phone) = 14 AND 
SUBSTRING(@phone, 1, 1) = '/' AND 
SUBSTRING(@phone, 4, 1) = '/'
);
GO

-- Bind the default to the column
EXEC sp_bindefault 'dbo.default_example_18', 'dbo.tbl_example_18.PhoneNumber';
GO

-- Bind the rule to the column
EXEC sp_bindrule 'dbo.rule_example_18', 'dbo.tbl_example_18.PhoneNumber';
GO
```

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 19. Contracts, Queues, and Message Types

In SQL Server, contracts, queues, and message types are core components of Service Broker, a feature used for building reliable messaging and asynchronous communication between database services.

Contrary to the SQL Server documentation, queues are not represented in the `sys.sql_expression_dependencies` table. Contracts and message types are also not included.

```sql
USE foo;
GO

--drop service
IF EXISTS (SELECT 1 FROM sys.services WHERE [name] = 'service_example_19')
BEGIN
     DROP SERVICE service_example_19;
END;
GO

--drop queue
IF EXISTS (SELECT 1 FROM sys.service_queues WHERE [name] = 'queue_example_19')
BEGIN
     DROP QUEUE queue_example_19;
END;
GO

--drop contract
IF EXISTS (SELECT 1 FROM sys.service_contracts WHERE [name] = 'contract_example_19')
BEGIN
     DROP CONTRACT contract_example_19;
END;
GO

--drop message type
IF EXISTS (SELECT 1 FROM sys.service_message_types WHERE name = 'msg_type_example_19')
BEGIN
     DROP MESSAGE TYPE msg_type_example_19;
END;
GO
```

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 20. Sequences

A Sequence is a user-defined object that generates a sequence of numeric values.

When creating a sequence, the `sys.sql_expression_dependencies` table will create a record where the referencing object is a system default constraint, and the referenced object is the sequence.

```sql
USE foo;
GO

CREATE SEQUENCE sequence_example_20
    START WITH 1
    INCREMENT BY 1;
GO

CREATE TABLE tbl_example_20
(
ID INT DEFAULT NEXT VALUE FOR sequence_example_20
);
GO

CREATE PROCEDURE dbo.sp_example_20
AS
BEGIN
    DECLARE @nextSeqValue BIGINT;

    SET @nextSeqValue = NEXT VALUE FOR sequence_example_20;
    
    INSERT INTO tbl_example_20 (ID)
    VALUES (@nextSeqValue) 
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name                | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | -------------------------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 20             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_20                        | 2053582354     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          |                        | sequence\_example\_20  | SO                     | 2005582183    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 20             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_20                        | 2053582354     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          |                        | tbl\_example\_20       | U                      | 2021582240    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 20             | D                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | DF\_\_tbl\_example\_\_\_ID\_\_797309D9 | 2037582297     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | sequence\_example\_20  | SO                     | 2005582183    | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 21. User Defined Data Types

User-defined data types are custom data types you create to encapsulate commonly used data formats based on the system's existing data types. You can enforce consistent data formats across multiple tables by defining a custom type with specific attributes, such as size, length, or rules. UDDTs are often used to standardize data entry across the database.

User-defined data types (and user-defined table types) are not stored in the `sys.objects` table. You must refer to the `sys.types` table for information about these objects.

```sql
USE foo;
GO

CREATE TYPE dbo.uddt_example_21 FROM VARCHAR(255) NOT NULL;
GO

CREATE TABLE dbo.tbl_example_21
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY,
UddtExample dbo.uddt_example_21
);
GO

CREATE PROCEDURE dbo.sp_example_21 AS
BEGIN
     DECLARE @vMyVarchar AS dbo.uddt_example_21
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 21             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_21         | 2085582468     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 6                | TYPE                  |                        |                          | dbo                    | uddt\_example\_21      | UDDT                   | 257           | 0                   | 0                   | 0            | 0                         |                          | 1                         | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 22. User Defined Table Types

A user-defined table type (UDTT) is a custom table structure you can define and use to pass datasets as parameters for stored procedures or functions.

User-defined table types (and user-defined data types) are not stored in the `sys.objects` table. You must refer to the `sys.types` table for information about these objects.

```sql
USE foo;
GO

CREATE TYPE dbo.udtt_example_22 AS TABLE
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE PROCEDURE dbo.sp_example_22 AS
BEGIN
     DECLARE @vMyVariable AS dbo.udtt_example_22;
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 22             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_22         | 2117582582     | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 0                         | 6                | TYPE                  |                        |                          | dbo                    | udtt\_example\_22      | UDTT                   | 257           | 0                   | 0                   | 0            | 0                         |                          | 1                         | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 23. Check Constraints

A check constraint is a rule that enforces a condition on the values entered into a column to ensure data integrity. It restricts the values stored in a column by evaluating a Boolean expression. The data modification (such as an `INSERT` or `UPDATE`) will only be accepted if the condition is met.

The `refereced_minor_id` column will populate with an integer corresponding to the column on which the constraint is dependent.

```sql
USE foo;
GO

CREATE FUNCTION dbo.fn_example_23 (@vQuantity INT) RETURNS VARCHAR(22) AS
BEGIN
    DECLARE @result VARCHAR(10);
    IF @vQuantity >= 1
        SET @result = 'TRUE';
    ELSE
        SET @result = 'FALSE';
    RETURN @result
END;
GO

CREATE TABLE dbo.tbl_example_23
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY,
CONSTRAINT example_23_chk_id CHECK (OrderID <> ProductID),
CONSTRAINT example_23_chk_quantity CHECK (dbo.fn_example_23(Quantity) = 'TRUE')
);
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name    | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | -------------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 23             | C                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | example\_23\_chk\_id       | 530100929      | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_23       | U                      | 514100872     | 1                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 23             | C                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | example\_23\_chk\_id       | 530100929      | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_23       | U                      | 514100872     | 2                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 23             | C                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | example\_23\_chk\_quantity | 546100986      | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | fn\_example\_23        | FN                     | 498100815     | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 23             | C                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | example\_23\_chk\_quantity | 546100986      | 0                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_23       | U                      | 514100872     | 3                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 24. Foreign Key Constraints

In SQL Server, a foreign key constraint enforces a relationship between columns in two tables, ensuring that the value in a column (or set of columns) in one table matches values in a referenced column of another table. This constraint maintains referential integrity by preventing actions that would leave orphaned rows or break the relationship, such as inserting a non-existent reference or deleting a referenced row.

The `sys.sql_expression_dependencies` table does not represent foreign key constraints. Refer to the `sys.foreign_keys` table for information about foreign keys.

```sql
USE foo;
GO

CREATE TABLE tbl_example_24_parent
(
ParentID   INT PRIMARY KEY, -- Primary Key in the parent table
ParentName VARCHAR(100) NOT NULL
);
GO

CREATE TABLE tbl_example_24_child
(
ChildID INT PRIMARY KEY, -- Primary Key in the child table
ChildName NVARCHAR(100) NOT NULL,
ParentID INT, -- Foreign Key column referencing ParentID in parent table
CONSTRAINT FK_Child_Parent FOREIGN KEY (ParentID) 
REFERENCES tbl_example_24_parent(ParentID) -- Foreign Key constraint
);
GO
```

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 25. Computed Columns

A computed column is a virtual column in a table whose value is calculated using an expression based on other columns in the same table. Computed columns can be either persisted, where the result is stored physically in the table, or non-persisted, where the value is calculated on the fly when the column is queried. If persisted, they can also be indexed, allowing for performance optimizations.

🔹In this example, the object appears as self-referencing because the `referencing_id` and `referenced_id` match.

```sql
USE foo;
GO

CREATE FUNCTION dbo.fn_example_25 (@vUnitPrice MONEY, @vQuantity INT) RETURNS MONEY AS
BEGIN
    RETURN @vUnitPrice * @vQuantity;
END;
GO

CREATE TABLE dbo.tbl_example_25
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY,
TotalValue AS (UnitPrice * Quantity),
TotalValue2 AS (dbo.fn_example_25(UnitPrice,Quantity))
);
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 25             | U                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | tbl\_example\_25        | 146099561      | 5                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_25       | U                      | 146099561     | 3                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 25             | U                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | tbl\_example\_25        | 146099561      | 5                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_25       | U                      | 146099561     | 4                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 25             | U                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | tbl\_example\_25        | 146099561      | 6                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | fn\_example\_25        | FN                     | 130099504     | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 25             | U                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | tbl\_example\_25        | 146099561      | 6                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_25       | U                      | 146099561     | 3                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 25             | U                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | tbl\_example\_25        | 146099561      | 6                    | 1                 | OBJECT\_OR\_COLUMN     | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_25       | U                      | 146099561     | 4                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 26. Masked Functions

In SQL Server, dynamic data masking is a feature that utilizes masked functions to conceal sensitive data by applying masks to columns, thereby limiting data visibility to unauthorized users. There are several masking functions available:

* Default: Fully masks the data according to the column's data type.
* Email: Masks email addresses by exposing only the first letter and domain (e.g., aXXX@domain.com).
* Partial: Masks part of the data, allowing you to define the visible prefix and suffix (e.g., for a phone number 123-XX-XXXX).
* Random: Masks numeric data by generating a random number within a specified range.

Masked functions are not represented in the `sys.sql_expression_dependencies` table.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_26 
(
EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
FirstName VARCHAR(50) MASKED WITH (FUNCTION = 'default()'),            -- Default mask: masks the entire value based on the data type
LastName VARCHAR(50) MASKED WITH (FUNCTION = 'partial(1,"XXXXXX",1)'), -- Partial mask: shows first and last character only
Email VARCHAR(255) MASKED WITH (FUNCTION = 'email()'),                 -- Email mask: hides part of the email
PhoneNumber VARCHAR(15) MASKED WITH (FUNCTION = 'partial(0, "XXX-XXX-", 4)'), -- Partial mask for phone number
Salary INT MASKED WITH (FUNCTION = 'random(1000, 5000)')               -- Random mask: generates a random number in the specified range
);
GO
```

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 27. Indexes - Table

Here, we will create the more common indexes typically seen on tables. Unlike filtered indexes, these are not represented in the `sys.sql_expression_dependencies` table.

Common indexes are not represented in the `sys.sql_expression_dependencies` table.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_27
(
OrderID INT PRIMARY KEY,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

CREATE NONCLUSTERED INDEX idx_nonclustered_example_27
ON dbo.tbl_example_27 (ProductID);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX idx_nonclustered_columnstore_example_27
ON dbo.tbl_example_27 (UnitPrice);
GO
---------------------------------------------

CREATE TABLE dbo.tbl_example_xml_27
(
OrderID INT PRIMARY KEY,
ProductID INT,
Quantity INT,
UnitPrice MONEY,
OrderCatalog XML
);
GO

CREATE PRIMARY XML INDEX idx_xml_example_27
ON dbo.tbl_example_xml_27 (OrderCatalog);
GO

CREATE XML INDEX idx_xml_example_27_a
ON dbo.tbl_example_xml_27 (OrderCatalog)
USING XML INDEX idx_xml_example_27
FOR PATH;
GO

CREATE XML INDEX idx_xml_example_27_b
ON dbo.tbl_example_xml_27 (OrderCatalog)
USING XML INDEX idx_xml_example_27
FOR VALUE;
GO

```

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 28. Indexes - Filtered NonClustered

In SQL Server, a filtered non-clustered index includes only a subset of rows from a table based on a specified `WHERE` clause. This makes the index smaller and more efficient because it only covers rows that meet the filtering criteria. This can significantly improve query performance and reduce storage requirements when dealing with large datasets with predictable patterns.

🔹In this example, the object appears as self-referencing because the `referencing_id` and `referenced_id` match.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_28
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY,
OrderCatalog XML
);
GO

CREATE NONCLUSTERED INDEX idx_example_28 ON dbo.tbl_example_28 (OrderID ASC) 
WHERE (ProductID=(1));
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 28             | U                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | tbl\_example\_28        | 274100017      | 2                    | 7                 | INDEX                  | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_28       | U                      | 274100017     | 2                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 29. Indexes - Filtered XML

A filtered XML index is a specialized index created on an XML column that focuses on a subset of the XML data based on a specified XML PATH. This allows you to target specific XML nodes or elements, making queries on those parts faster and more efficient without indexing the entire XML content. It's beneficial for optimizing performance when you frequently query specific sections of large XML data.

🔹In this example, the object appears as self-referencing because the `referencing_id` and `referenced_id` match.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_29
(
OrderID INT PRIMARY KEY,
ProductID INT,
Quantity INT,
UnitPrice MONEY,
OrderCatalog XML
);
GO

CREATE NONCLUSTERED INDEX idx_example_29
ON dbo.tbl_example_29 (ProductID)
WHERE ProductID = 1;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 29             | U                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | tbl\_example\_29        | 290100074      | 2                    | 7                 | INDEX                  | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_29       | U                      | 290100074     | 2                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 30. Statistics - Filtered

Filtered statistics are statistics objects that collect data only for a subset of rows in a table, defined by a `WHERE` clause filter. They provide more accurate cardinality estimates for queries that target specific subsets of data, which can lead to better execution plans and improved query performance. Filtered statistics are beneficial when dealing with skewed data distributions or when you frequently query specific portions of a dataset.

🔹In this example, the object appears as self-referencing because the `referencing_id` and `referenced_id` match.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_30
(
OrderID INT,
ProductID INT,
Quantity INT,
UnitPrice MONEY
);
GO

-- Create a filtered statistic for rows where Quantity is greater than 100
CREATE STATISTICS stat_example_30 ON dbo.tbl_example_30 (UnitPrice)
WHERE Quantity > 100;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc | Is Schema Bound Reference | Referenced Class | Referenced Class Desc | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ---------------------- | ------------------------- | ---------------- | --------------------- | ---------------------- | ------------------------ | ---------------------- | ---------------------- | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 30             | U                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | tbl\_example\_30        | 322100188      | 2                    | 9                 | STATISTICS             | 1                         | 1                | OBJECT\_OR\_COLUMN    |                        |                          | dbo                    | tbl\_example\_30       | U                      | 322100188     | 3                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 31. XML Schema Collection

In SQL Server, an XML Schema Collection is a database object that stores one or more XML schemas, which define and validate the structure of XML data in XML columns or variables. By associating an XML column with an XML schema collection, you ensure that any XML data inserted into the column adheres to the defined rules and structure, providing data integrity and validation. Additionally, it enables the use of typed XML, which can improve query performance by enforcing a consistent XML format.

Information about XML schema collections is not stored in the `sys.objects` table. For more information, refer to the `sys.xml_schema_collections` table.

```sql
USE foo;
GO

CREATE XML SCHEMA COLLECTION dbo.xml_schema_collection_example_31 AS
N'
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Order">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="OrderID" type="xs:int"/>
        <xs:element name="Product" type="xs:string"/>
        <xs:element name="Quantity" type="xs:int"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>';
GO

CREATE TABLE dbo.tbl_example_31
(
OrderID INT PRIMARY KEY,
OrderDetails XML(dbo.xml_schema_collection_example_31)
);
GO

CREATE PROCEDURE dbo.sp_example_31
    @OrderID INT,
    @OrderDetails XML(dbo.xml_schema_collection_example_31)
AS
BEGIN
    INSERT INTO dbo.tbl_example_31 (OrderID, OrderDetails)
    VALUES (@OrderID, @OrderDetails);
END;
GO
```

| Example Number | Referencing Object Type | Referencing Server Name      | Referencing Database Name | Referencing Schema Name | Referencing Entity Name | Referencing ID | Referencing Minor ID | Referencing Class | Referencing Class Desc  | Is Schema Bound Reference | Referenced Class | Referenced Class Desc   | Referenced Server Name | Referenced Database Name | Referenced Schema Name | Referenced Entity Name               | Referenced Object Type | Referenced ID | Referenced Minor ID | Is Caller Dependent | Is Ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| -------------- | ----------------------- | ---------------------------- | ------------------------- | ----------------------- | ----------------------- | -------------- | -------------------- | ----------------- | ----------------------- | ------------------------- | ---------------- | ----------------------- | ---------------------- | ------------------------ | ---------------------- | ------------------------------------ | ---------------------- | ------------- | ------------------- | ------------------- | ------------ | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 31             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_31         | 370100359      | 0                    | 1                 | OBJECT\_OR\_COLUMN      | 0                         | 1                | OBJECT\_OR\_COLUMN      |                        |                          | dbo                    | tbl\_example\_31                     | U                      | 338100245     | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |
| 31             | P                       | DESKTOP-D324ETP\SQLEXPRESS01 | foo                       | dbo                     | sp\_example\_31         | 370100359      | 0                    | 10                | XML\_SCHEMA\_COLLECTION | 0                         |                  | XML\_SCHEMA\_COLLECTION |                        |                          | dbo                    | xml\_schema\_collection\_example\_31 |                        | 65536         | 0                   | 0                   | 0            | 0                         | 0                        |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 32. XML Methods

This script illustrates XML handling in SQL Server using the following methods.

* The `value()` method extracts an XML attribute (id) as an integer from the XML column.
* The `exist()` method checks for the presence of specific XML content, validating if a node contains "Hello World."
* The `query()` method retrieves a section of the XML, targeting the node.
* The `nodes()` method shreds XML data into rows, allowing easier access to each node.
* The `modify()` method updates the XML content, changing the text from "Hello World" to "Goodbye World."

Interestingly, the columns `referenced_database_name`, `referenced_schema_name`, and the `referenced_entity_name` get repurposed with information about the XML method.

For XML methods, the `referenced_id` column will contain a NULL marker.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_32
(
ID INT,
column_xml_example_32 XML
);
GO

INSERT INTO dbo.tbl_example_32 (Id, column_xml_example_32) VALUES (1, '<Record id="1"><Message>Hello World</Message></Record>');
GO

CREATE PROCEDURE dbo.sp_example_32 AS
BEGIN

    -- value()
    SELECT t.column_xml_example_32.value('(./Record/@id)[1]', 'int')
    FROM dbo.tbl_example_32 t;

    -- exist()
    SELECT t.column_xml_example_32.exist('/Record[Message = "Hello World"]')
    FROM   dbo.tbl_example_32 t;

    -- query()
    SELECT t.column_xml_example_32.query('/Record/Message')
    FROM dbo.tbl_example_32 t;

    -- nodes()
    SELECT x.n.value('(text())[1]', 'NVARCHAR(100)')
    FROM   dbo.tbl_example_32 t CROSS APPLY 
           t.column_xml_example_32.nodes('/Record/Message') AS x(n);

    -- modify()
    UPDATE dbo.tbl_example_32
    SET column_xml_example_32.modify('replace value of (/Record/Message/text())[1] with "Goodbye World"')
    WHERE Id = 1;

END;
GO
```

| example\_number | referencing\_object\_type | referencing\_server\_name    | referencing\_database\_name | referencing\_schema\_name | referencing\_entity\_name | referencing\_id | referencing\_minor\_id | referencing\_class | referencing\_class\_desc | is\_schema\_bound\_reference | referenced\_class | referenced\_class\_desc | referenced\_server\_name | referenced\_database\_name | referenced\_schema\_name | referenced\_entity\_name | referenced\_object\_type | referenced\_id | referenced\_minor\_id | is\_caller\_dependent | is\_ambiguous | Referencing Is Ms Shipped | Referenced Is Ms Shipped | Is User Defined Data Type | Is Self Referencing |
| --------------- | ------------------------- | ---------------------------- | --------------------------- | ------------------------- | ------------------------- | --------------- | ---------------------- | ------------------ | ------------------------ | ---------------------------- | ----------------- | ----------------------- | ------------------------ | -------------------------- | ------------------------ | ------------------------ | ------------------------ | -------------- | --------------------- | --------------------- | ------------- | ------------------------- | ------------------------ | ------------------------- | ------------------- |
| 32              | P                         | DESKTOP-D324ETP\SQLEXPRESS01 | foo                         | dbo                       | sp\_example\_32           | 1122103038      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          | t                          | column\_xml\_example\_32 | exist                    |                          |                | 0                     | 0                     | 1             | 0                         |                          |                           | 0                   |
| 32              | P                         | DESKTOP-D324ETP\SQLEXPRESS01 | foo                         | dbo                       | sp\_example\_32           | 1122103038      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          | t                          | column\_xml\_example\_32 | query                    |                          |                | 0                     | 0                     | 1             | 0                         |                          |                           | 0                   |
| 32              | P                         | DESKTOP-D324ETP\SQLEXPRESS01 | foo                         | dbo                       | sp\_example\_32           | 1122103038      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            | dbo                      | tbl\_example\_32         | U                        | 1106102981     | 0                     | 0                     | 0             | 0                         | 0                        |                           | 0                   |
| 32              | P                         | DESKTOP-D324ETP\SQLEXPRESS01 | foo                         | dbo                       | sp\_example\_32           | 1122103038      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          | t                          | column\_xml\_example\_32 | value                    |                          |                | 0                     | 0                     | 1             | 0                         |                          |                           | 0                   |
| 32              | P                         | DESKTOP-D324ETP\SQLEXPRESS01 | foo                         | dbo                       | sp\_example\_32           | 1122103038      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          | x                          | n                        | value                    |                          |                | 0                     | 0                     | 1             | 0                         |                          |                           | 0                   |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 33. Feature Installed Procedures

In SQL Server Management Studio (SSMS), enabling certain features—such as Database Diagrams, Change Data Capture, or Replication—adds feature-specific system stored procedures and objects to your database to support that functionality.

For example, enabling Database Diagrams by right-clicking the Database Diagrams folder under the foo database and selecting New Database Diagram will trigger the creation of several dependencies.

These dependencies are recorded in the `sys.sql_expression_dependencies` table. Notably, the associated stored procedures will have `referencing_is_ms_shipped` and `referenced_is_ms_shipped` both set to 0, indicating they are not Microsoft-shipped system objects. Additionally, a table named `dtproperties` is created. This table is a system object used specifically to support database diagrams in SSMS.

| example\_number | referencing\_object\_type | referencing\_server\_name | referencing\_database\_name | referencing\_schema\_name | referencing\_entity\_name | referencing\_id | referencing\_minor\_id | referencing\_class | referencing\_class\_desc | is\_schema\_bound\_reference | referenced\_class | referenced\_class\_desc | referenced\_server\_name | referenced\_database\_name | referenced\_schema\_name | referenced\_entity\_name | referenced\_object\_type | referenced\_id | referenced\_minor\_id | is\_caller\_dependent | is\_ambiguous | referencing\_is\_ms\_shipped | referenced\_is\_ms\_shipped | is\_user\_defined\_data\_type | is\_self\_referencing |
| --------------- | ------------------------- | ------------------------- | --------------------------- | ------------------------- | ------------------------- | --------------- | ---------------------- | ------------------ | ------------------------ | ---------------------------- | ----------------- | ----------------------- | ------------------------ | -------------------------- | ------------------------ | ------------------------ | ------------------------ | -------------- | --------------------- | --------------------- | ------------- | ---------------------------- | --------------------------- | ----------------------------- | --------------------- |
| 33              | P                         | SQLEXPRESS01              | foo                         | dbo                       | sp\_upgraddiagrams        | 949578421       | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            | dbo                      | dtproperties             |                          |                | 0                     | 0                     | 0             | 0                            |                             |                               | 0                     |
| 33              | P                         | SQLEXPRESS01              | foo                         | dbo                       | sp\_upgraddiagrams        | 949578421       | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            | dbo                      | sysdiagrams              | U                        | 965578478      | 0                     | 0                     | 0             | 0                            | 0                           |                               | 0                     |
| 33              | P                         | SQLEXPRESS01              | foo                         | dbo                       | sp\_helpdiagrams          | 1013578649      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            |                          | sysdiagrams              | U                        | 965578478      | 0                     | 0                     | 0             | 0                            | 0                           |                               | 0                     |
| 33              | P                         | SQLEXPRESS01              | foo                         | dbo                       | sp\_helpdiagramdefinition | 1029578706      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            | dbo                      | sysdiagrams              | U                        | 965578478      | 0                     | 0                     | 0             | 0                            | 0                           |                               | 0                     |
| 33              | P                         | SQLEXPRESS01              | foo                         | dbo                       | sp\_creatediagram         | 1045578763      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            | dbo                      | sysdiagrams              | U                        | 965578478      | 0                     | 0                     | 0             | 0                            | 0                           |                               | 0                     |
| 33              | P                         | SQLEXPRESS01              | foo                         | dbo                       | sp\_renamediagram         | 1061578820      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            | dbo                      | sysdiagrams              | U                        | 965578478      | 0                     | 0                     | 0             | 0                            | 0                           |                               | 0                     |
| 33              | P                         | SQLEXPRESS01              | foo                         | dbo                       | sp\_alterdiagram          | 1077578877      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            | dbo                      | sysdiagrams              | U                        | 965578478      | 0                     | 0                     | 0             | 0                            | 0                           |                               | 0                     |
| 33              | P                         | SQLEXPRESS01              | foo                         | dbo                       | sp\_dropdiagram           | 1093578934      | 0                      | 1                  | OBJECT\_OR\_COLUMN       | 0                            | 1                 | OBJECT\_OR\_COLUMN      |                          |                            | dbo                      | sysdiagrams              | U                        | 965578478      | 0                     | 0                     | 0             | 0                            | 0                           |                               | 0                     |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***

### 34 Security Policies

Security policies in SQL Server enforce row-level security by filtering or blocking access to data based on user context. They use predicate functions to determine which rows a user can view or modify, and are applied directly to tables.

In this example, we see the security policy as a referencing object to both the table and the function.

```sql
USE foo;
GO

CREATE TABLE dbo.tbl_example_34 (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerName NVARCHAR(100),
    Salesperson SYSNAME
);
GO

CREATE FUNCTION dbo.fn_example_34 (@Salesperson SYSNAME)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_result
WHERE @Salesperson = USER_NAME();
GO

CREATE SECURITY POLICY dbo.security_policy_example_34
ADD FILTER PREDICATE dbo.fn_example_34(Salesperson)
ON dbo.tbl_example_34
WITH (STATE = ON);
GO
```

| example\_number | referencing\_object\_type | referencing\_server\_name | referencing\_database\_name | referencing\_schema\_name | referencing\_entity\_name  | referencing\_id | referencing\_minor\_id | referencing\_class | referencing\_class\_desc | is\_schema\_bound\_reference | referenced\_class | referenced\_class\_desc | referenced\_server\_name | referenced\_database\_name | referenced\_schema\_name | referenced\_entity\_name | referenced\_object\_type | referenced\_id | referenced\_minor\_id | is\_caller\_dependent | is\_ambiguous | referencing\_is\_ms\_shipped | referenced\_is\_ms\_shipped | is\_user\_defined\_data\_type | is\_self\_referencing |
| --------------- | ------------------------- | ------------------------- | --------------------------- | ------------------------- | -------------------------- | --------------- | ---------------------- | ------------------ | ------------------------ | ---------------------------- | ----------------- | ----------------------- | ------------------------ | -------------------------- | ------------------------ | ------------------------ | ------------------------ | -------------- | --------------------- | --------------------- | ------------- | ---------------------------- | --------------------------- | ----------------------------- | --------------------- |
| 34              | SP                        | SQLEXPRESS01              | foo                         | dbo                       | security_policy_example_34 | 242099903       | 1                      | 1                  | OBJECT_OR_COLUMN         | 1                            | 1                 | OBJECT_OR_COLUMN        |                          |                            | dbo                      | tbl_example_34           | U                        | 194099732      | 0                     | 0                     | 0             | 0                            |                             | 0                             | 0                     |
| 34              | SP                        | SQLEXPRESS01              | foo                         | dbo                       | security_policy_example_34 | 242099903       | 1                      | 1                  | OBJECT_OR_COLUMN         | 1                            | 1                 | OBJECT_OR_COLUMN        |                          |                            | dbo                      | tbl_example_34           | U                        | 194099732      | 4                     | 0                     | 0             | 0                            |                             | 0                             | 0                     |
| 34              | SP                        | SQLEXPRESS01              | foo                         | dbo                       | security_policy_example_34 | 242099903       | 1                      | 1                  | OBJECT_OR_COLUMN         | 1                            | 1                 | OBJECT_OR_COLUMN        |                          |                            | dbo                      | fn_example_34            | IF                       | 226099846      | 0                     | 0                     | 0             | 0                            |                             | 0                             | 0                     |

[Summary of Contents](03_database_dependencies_examples.md#summary-of-contents)

***





