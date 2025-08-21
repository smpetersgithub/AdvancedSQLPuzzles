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

--------

--------

--------

--------

--------

--------

--------

--------

--------
