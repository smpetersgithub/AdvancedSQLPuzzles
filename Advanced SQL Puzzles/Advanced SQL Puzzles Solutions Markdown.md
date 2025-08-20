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
