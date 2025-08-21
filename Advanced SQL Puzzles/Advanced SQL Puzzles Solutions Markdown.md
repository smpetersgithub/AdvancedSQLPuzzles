# Welcome  

I hope you enjoy these puzzles as much as I have enjoyed creating them!  

As my list of puzzles continues to grow, I have decided to combine the puzzles into one document broken down into two sections.  

In the first section, I have 77 of the most challenging puzzles I could create, randomly organized and in no specific order. These are primarily set-based puzzles, interspersed with a small number of puzzles that require knowledge of constraints, specific data types, cursors, loops, etc...  

Working through these puzzles will give you an understanding of the SQL language and what types of problems the SQL language solves best. Remember that SQL is a declarative and not an imperative language, and always think in sets when providing a solution.  

I collected all the puzzles related to permutations, combinations, and sequences in the second set of puzzles. Solving these puzzles will require a more profound knowledge of your SQL thinking, focusing on such constructs as using recursion or sequence objects to reach the desired output (and, of course, some will require using traditional set-based thinking).  

Ultimately, these puzzles resolve to creating number tables, which can be used to fill in gaps, create ranges and tallies, provide custom sorting, and allow you to create set-based solutions over iterative solutions. I also included a few puzzles from Part 1 into this set as they ultimately deal with creating a numbers table.  

I hope navigating through the GitHub repository to find the solutions is straightforward. The first set of puzzles is combined into one single SQL document, and the second set has a separate folder with individual solutions, as these solutions are a little more involved in solving.  

For my sanity, it is easiest not to embed the SQL solutions into this text document and instead provide them separately as SQL files in the GitHub repository. If you have any issues navigating the website or GitHub, please contact me and I would be happy to help.  

Answers to these puzzles are located in the following GitHub repository:  
**AdvancedSQLPuzzles/Advanced SQL Puzzles**  

I welcome any corrections, new tricks, new techniques, dead links, misspellings, bugs, and especially any new puzzles that would be an excellent fit for this document.  

Please contact me through the contact page on my website or use the discussion board in the GitHub repository.  

https://advancedsqlpuzzles.com/  

Happy coding!

--------

<br/>
<h1 align="center">PART I - Thinking in Sets</h1>
<br/>

--------

<h1 align="center">Puzzle #1</h1>
<h1 align="center">Shopping Carts</h1>

You are tasked with auditing two shopping carts.  

Write an SQL statement to transform the following tables into the expected output.  

**Cart 1**
| Item  |
|-------|
| Sugar |
| Bread |
| Juice |
| Soda  |
| Flour |

**Cart 2**
| Item   |
|--------|
| Sugar  |
| Bread  |
| Butter |
| Cheese |
| Fruit  |

Here is the expected output.

| Item Cart 1 | Item Cart 2 |
|-------------|-------------|
| Sugar       | Sugar       |
| Bread       | Bread       |
| Juice       |             |
| Soda        |             |
| Flour       |             |
|             | Butter      |
|             | Cheese      |
|             | Fruit       |

--------

<h1 align="center">Puzzle #2</h1>
<h1 align="center">Managers and Employees</h1>

Given the following hierarchical table, write an SQL statement that determines the level of depth each employee has from the president.

| Employee ID | Manager ID | Job Title       |
|-------------|------------|-----------------|
| 1001        |            | President       |
| 2002        | 1001       | Director        |
| 3003        | 1001       | Office Manager  |
| 4004        | 2002       | Engineer        |
| 5005        | 2002       | Engineer        |
| 6006        | 2002       | Engineer        |

Here is the expected output.

| Employee ID | Manager ID | Job Title       | Depth |
|-------------|------------|-----------------|-------|
| 1001        |            | President       | 0     |
| 2002        | 1001       | Director        | 1     |
| 3003        | 1001       | Office Manager  | 1     |
| 4004        | 2002       | Engineer        | 2     |
| 5005        | 2002       | Engineer        | 2     |
| 6006        | 2002       | Engineer        | 2     |

--------

<h1 align="center">Puzzle #3</h1>
<h1 align="center">Fiscal Year Pay Rates</h1>

For each standard fiscal year, a record exists for each employee that states their current pay rate for the specified year.  

Can you determine all the constraints that can be applied to this table to ensure it contains only correct information? Assume that no pay raises are given mid-year. There are quite a few of them, so think carefully.  

```sql
CREATE TABLE #EmployeePayRecord
(
    EmployeeID  INTEGER,
    FiscalYear  INTEGER,
    StartDate   DATE,
    EndDate     DATE,
    PayRate     MONEY
);
```

--------

<h1 align="center">Puzzle #4</h1>
<h1 align="center">Two Predicates</h1>

Write an SQL statement given the following requirements.  

For every customer who had a delivery to California, provide a result set of the customer orders that were delivered to Texas.  

| Customer ID | Order ID | Delivery State | Amount |
|-------------|----------|----------------|--------|
| 1001        | 1        | CA             | $340   |
| 1001        | 2        | TX             | $950   |
| 1001        | 3        | TX             | $670   |
| 1001        | 4        | TX             | $860   |
| 2002        | 5        | WA             | $320   |
| 3003        | 6        | CA             | $650   |
| 3003        | 7        | CA             | $830   |
| 4004        | 8        | TX             | $120   |

Here is the expected output.

| Customer ID | Order ID | Delivery State | Amount |
|-------------|----------|----------------|--------|
| 1001        | 2        | TX             | $950   |
| 1001        | 3        | TX             | $670   |
| 1001        | 4        | TX             | $860   |

- **Customer ID 1001** appears in the result set because they had deliveries to both **California** and **Texas**.  
- **Customer ID 3003** does **not** appear because they never had a delivery to Texas.  
- **Customer ID 4004** does **not** appear because they never had a delivery to California.  

--------

<h1 align="center">Puzzle #5</h1>
<h1 align="center">Phone Directory</h1>

Your customer phone directory table allows individuals to set up a home, cellular, or work phone number.

Write an SQL statement to transform the following table into the expected output.

| Customer ID | Type     | Phone Number |
|-------------|----------|--------------|
| 1001        | Cellular | 555-897-5421 |
| 1001        | Work     | 555-897-6542 |
| 1001        | Home     | 555-698-9874 |
| 2002        | Cellular | 555-963-6544 |
| 2002        | Work     | 555-812-9856 |
| 3003        | Cellular | 555-987-6541 |

Here is the expected output.

| Customer ID | Cellular    | Work         | Home         |
|-------------|-------------|--------------|--------------|
| 1001        | 555-897-5421| 555-897-6542 | 555-698-9874 |
| 2002        | 555-963-6544| 555-812-9856 |              |
| 3003        | 555-987-6541|              |              |


--------

<h1 align="center">Puzzle #6</h1>
<h1 align="center">Workflow Steps</h1>

Write an SQL statement that determines all workflows that have started but have not been completed.  

| Workflow | Step Number | Completion Date |
|----------|-------------|-----------------|
| Alpha    | 1           | 7/2/2018        |
| Alpha    | 2           | 7/2/2018        |
| Alpha    | 3           | 7/1/2018        |
| Bravo    | 1           | 6/25/2018       |
| Bravo    | 2           |                 |
| Bravo    | 3           | 6/27/2018       |
| Charlie  | 1           |                 |
| Charlie  | 2           | 7/1/2018        |

Here is the expected output.

| Workflow |
|----------|
| Bravo    |
| Charlie  |
 
- The expected output would be **Bravo** and **Charlie**, as they have a workflow that has started but has not been completed.  
- **Bonus:** Write this query using only the `COUNT` function with no subqueries. Can you figure out the trick?  

--------

<h1 align="center">Puzzle #7</h1>
<h2 align="center">Mission to Mars</h2>

You are given the following tables that list the requirements for a space mission and a list of potential candidates.  

Write an SQL statement to determine which candidates meet the mission's requirements.  

#### Candidates
| Candidate ID | Description |
|--------------|-------------|
| 1001         | Geologist   |
| 1001         | Astrogator  |
| 1001         | Biochemist  |
| 1001         | Technician  |
| 2002         | Surgeon     |
| 2002         | Machinist   |
| 2002         | Geologist   |
| 3003         | Geologist   |
| 3003         | Astrogator  |
| 4004         | Selenologist|

#### Requirements

| Description  |
|--------------|
| Geologist    |
| Astrogator   |
| Technician   |

Here is the expected output.

| Candidate ID |
|--------------|
| 1001         |

- The expected output would be **Candidate ID 1001**, as this candidate has all the necessary skills for the space mission.  
- Candidate ID **2002** and **3003** would not be in the output as they have some but not all the required skills.  
- Candidate ID **4004** has none of the needed requirements.

--------

<h1 align="center">Puzzle #8</h1>
<h1 align="center">Workflow Cases</h1>

You have a report of all workflows and their case results.  

A value of **0** signifies the workflow failed, and a value of **1** signifies the workflow passed.  

Write an SQL statement that transforms the following table into the expected output.  

| Workflow | Case 1 | Case 2 | Case 3 |
|----------|--------|--------|--------|
| Alpha    | 0      | 0      | 0      |
| Bravo    | 0      | 1      | 1      |
| Charlie  | 1      | 0      | 0      |
| Delta    | 0      | 0      | 0      |

Here is the expected output.

| Workflow | Passed |
|----------|--------|
| Alpha    | 0      |
| Bravo    | 2      |
| Charlie  | 1      |
| Delta    | 0      |

--------

<h1 align="center">Puzzle #9</h1>
<h1 align="center">Matching Sets</h1>

Write an SQL statement that matches an employee to all other employees who carry the same licenses.  

| Employee ID | License |
|-------------|---------|
| 1001        | Class A |
| 1001        | Class B |
| 1001        | Class C |
| 2002        | Class A |
| 2002        | Class B |
| 2002        | Class C |
| 3003        | Class A |
| 3003        | Class D |
| 4004        | Class A |
| 4004        | Class B |
| 4004        | Class D |
| 5005        | Class A |
| 5005        | Class B |
| 5005        | Class D |

Here is the expected output.

| Employee ID | Employee ID | Count |
|-------------|-------------|-------|
| 1001        | 2002        | 3     |
| 2002        | 1001        | 3     |
| 4004        | 5005        | 3     |
| 5005        | 4004        | 3     |

- Employee IDs **1001** and **2002** would be in the expected output as they both carry a Class A, Class B, and a Class C license.  
- Employee IDs **4004** and **5005** would be in the expected output as they both carry a Class A, Class B, and a Class D license.  
- Although Employee ID **3003** has the same licenses as Employee ID 4004 and 5005, these Employee IDs do not have the same licenses as Employee ID 3003.  

--------

<h1 align="center">Puzzle #10</h1>
<h1 align="center">Mean, Median, Mode, and Range</h1>

- The **mean** is the average of all numbers.  
- The **median** is the middle number in a sequence of numbers.  
- The **mode** is the number that occurs most often within a set of numbers.  
- The **range** is the difference between the largest and smallest values in a set of numbers.  

Write an SQL statement to determine the mean, median, mode, and range of the set of integers provided in the following DDL statement.  

```sql
CREATE TABLE #SampleData
(
    IntegerValue INTEGER
);

INSERT INTO #SampleData
VALUES (5),(6),(10),(10),(13),
       (14),(17),(20),(81),(90),(76);
```

--------

<h1 align="center">Puzzle #11</h1>
<h1 align="center">Permutations</h1>

You are given the following list of test cases and must determine all possible permutations.  

Write an SQL statement that produces the expected output. Ensure your code can account for a changing number of elements without rewriting.  

| Test Case |
|-----------|
| A         |
| B         |
| C         |

Here is the expected output.

| Test Cases |
|------------|
| A,B,C      |
| A,C,B      |
| B,A,C      |
| B,C,A      |
| C,A,B      |
| C,B,A      |

--------

<h1 align="center">Puzzle #12</h1>
<h1 align="center">Average Days</h1>

Write an SQL statement to determine the average number of days between executions for each workflow.  

| Workflow | Execution Date |
|----------|----------------|
| Alpha    | 6/1/2018       |
| Alpha    | 6/14/2018      |
| Alpha    | 6/15/2018      |
| Bravo    | 6/1/2018       |
| Bravo    | 6/2/2018       |
| Bravo    | 6/19/2018      |
| Charlie  | 6/1/2018       |
| Charlie  | 6/15/2018      |
| Charlie  | 6/30/2018      |

Here is the expected output.

| Workflow | Average Days |
|----------|--------------|
| Alpha    | 7            |
| Bravo    | 9            |
| Charlie  | 14           |

--------

<h1 align="center">Puzzle #13</h1>
<h1 align="center">Inventory Tracking</h1>

You work for a manufacturing company and need to track inventory adjustments from the warehouse.  

Some days the inventory increases, on other days the inventory decreases.  

Write an SQL statement that will provide a running balance of the inventory.  

| Date      | Quantity Adjustment |
|-----------|----------------------|
| 7/1/2018  | 100                  |
| 7/2/2018  | 75                   |
| 7/3/2018  | -150                 |
| 7/4/2018  | 50                   |
| 7/5/2018  | -100                 |

Here is the expected output.

| Date      | Quantity Adjustment | Inventory |
|-----------|----------------------|-----------|
| 7/1/2018  | 100                  | 100       |
| 7/2/2018  | 75                   | 175       |
| 7/3/2018  | -150                 | 25        |
| 7/4/2018  | 50                   | 75        |
| 7/5/2018  | -100                 | -25       |

--------

<h1 align="center">Puzzle #14</h1>
<h1 align="center">Indeterminate Process Log</h1>

Your process log has several workflows broken down by step numbers with the possible status values of Complete, Running, or Error.  

Your task is to write an SQL statement that creates an overall status based on the following requirements:  

- If all steps of a workflow are of the same status (Error, Complete, or Running), then return the distinct status.  
- If any steps of a workflow have an Error status along with a status of Complete or Running, set the overall status to Indeterminate.  
- If the workflow steps have a combination of Complete and Running (without any Errors), set the overall status to Running.  

| Workflow | Step Number | Status   |
|----------|-------------|----------|
| Alpha    | 1           | Error    |
| Alpha    | 2           | Complete |
| Alpha    | 3           | Running  |
| Bravo    | 1           | Complete |
| Bravo    | 2           | Complete |
| Charlie  | 1           | Running  |
| Charlie  | 2           | Running  |
| Delta    | 1           | Error    |
| Delta    | 2           | Error    |
| Echo     | 1           | Running  |
| Echo     | 2           | Complete |

Here is the expected output.

| Workflow | Status       |
|----------|--------------|
| Alpha    | Indeterminate|
| Bravo    | Complete     |
| Charlie  | Running      |
| Delta    | Error        |
| Echo     | Running      |

--------

<h1 align="center">Puzzle #15</h1>
<h1 align="center">Group Concatenation</h1>

Write an SQL statement that can group-concatenate the following values.  

| Sequence | Syntax       |
|----------|--------------|
| 1        | SELECT       |
| 2        | Product,     |
| 3        | UnitPrice,   |
| 4        | EffectiveDate|
| 5        | FROM         |
| 6        | Products     |
| 7        | WHERE        |
| 8        | UnitPrice    |
| 9        | > 100        |

Here is the expected output.

| Syntax                                                                 |
|------------------------------------------------------------------------|
| SELECT Product, UnitPrice, EffectiveDate FROM Products WHERE UnitPrice > 100 |

--------

<h1 align="center">Puzzle #16</h1>
<h1 align="center">Reciprocals</h1>

You work for a software company that released a 2-player game and you need to tally the scores.  

Given the following table, write an SQL statement to determine the reciprocals and calculate their aggregate score.  

In the data below, players 3003 and 4004 have two valid entries, but their scores need to be aggregated together.  

| Player A | Player B | Score |
|----------|----------|-------|
| 1001     | 2002     | 150   |
| 3003     | 4004     | 15    |
| 4004     | 3003     | 125   |

Here is the expected output.

| Player A | Player B | Score |
|----------|----------|-------|
| 1001     | 2002     | 150   |
| 3003     | 4004     | 140   |

--------

<h1 align="center">Puzzle #17</h1>
<h1 align="center">De-Grouping</h1>

Write an SQL Statement to de-group the following data.  

| Product  | Quantity |
|----------|----------|
| Pencil   | 3        |
| Eraser   | 4        |
| Notebook | 2        |

Here is the expected output.

| Product  | Quantity |
|----------|----------|
| Pencil   | 1        |
| Pencil   | 1        |
| Pencil   | 1        |
| Eraser   | 1        |
| Eraser   | 1        |
| Eraser   | 1        |
| Eraser   | 1        |
| Notebook | 1        |
| Notebook | 1        |

--------

<h1 align="center">Puzzle #18</h1>
<h1 align="center">Seating Chart</h1>

Given the set of integers provided in the following DDL statement, write the SQL statements to determine the following:
- Gap start and gap ends
- Total missing numbers
- Count of odd and even numbers

```sql
CREATE TABLE #SeatingChart (SeatNumber INTEGER);

INSERT INTO #SeatingChart VALUES
(7),(13),(14),(15),(27),(28),(29),(30),
(31),(32),(33),(34),(35),(52),(53),(54);
```

Here is the expected output.

| Gap Start | Gap End |
|-----------|---------|
| 1         | 6       |
| 8         | 12      |
| 16        | 26      |
| 36        | 51      |

| Total Missing Numbers |
|----------------------|
| 38                   |

| Type         | Count |
|--------------|-------|
| Even Numbers | 7     |
| Odd Numbers  | 9     |

--------

<h1 align="center">Puzzle #19</h1>
<h1 align="center">Back to the Future</h1>

Here is one of the more difficult puzzles to solve with a declarative SQL statement.

Write an SQL statement to merge the overlapping time periods.

| Start Date | End Date  |
|------------|-----------|
| 1/1/2018   | 1/5/2018  |
| 1/3/2018   | 1/9/2018  |
| 1/10/2018  | 1/11/2018 |
| 1/12/2018  | 1/16/2018 |
| 1/15/2018  | 1/19/2018 |

Here is the expected output.

| Start Date | End Date  |
|------------|-----------|
| 1/1/2018   | 1/9/2018  |
| 1/10/2018  | 1/11/2018 |
| 1/12/2018  | 1/19/2018 |

--------

<h1 align="center">Puzzle #20</h1>
<h1 align="center">Price Points</h1>

Write an SQL statement to determine the current price point for each product.

| Product ID | Effective Date | Unit Price |
|------------|----------------|-----------|
| 1001       | 1/1/2018       | $1.99     |
| 1001       | 4/15/2018      | $2.99     |
| 1001       | 6/8/2018       | $3.99     |
| 2002       | 4/17/2018      | $1.99     |
| 2002       | 5/19/2018      | $2.99     |

Here is the expected output.

| Product ID | Effective Date | Unit Price |
|------------|----------------|-----------|
| 1001       | 6/8/2018       | $3.99     |
| 2002       | 5/19/2018      | $2.99     |

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------

--------
