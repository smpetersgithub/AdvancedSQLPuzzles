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
