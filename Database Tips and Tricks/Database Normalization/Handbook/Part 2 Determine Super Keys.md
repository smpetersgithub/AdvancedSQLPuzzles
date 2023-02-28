# Part 2: Determine Super Keys

This script determines all the **Super Keys**, **Minimal Super Keys**, **Candidate Keys** and **Non-Prime Attributes** from the user created `NormalizationTest` table.

#### Tables Used

1.  `SuperKeys1_SysColumns`    
2.  `SuperKeys2_Permutations`    
3.  `SuperKeys3_DynamicSQL`    
4.  `SuperKeys4_Final`
5.  `SuperKeys5_StringSplit`    
6.  `SuperKeys6_CandidateKey`    
7.  `SuperKeys7_NonPrime`    


### Steps Involved

| Step |        Table Created    |  Action  |                                                         Notes                                           |
|------|-------------------------|----------|---------------------------------------------------------------------------------------------------------|
|    1 | SuperKeys1_SysColumns   | `CREATE` | From the system tables, determines all the columns in the table `NormalizationTest`.                    |
|    2 | SuperKeys2_Permutations | `CREATE` | Seed the `SuperKeys2_Permutations` table from `SuperKeys1_SysColumns`.                                  |
|    3 | SuperKeys2_Permutations | `INSERT` | Loop through `SuperKeys1_SysColumns` to determine the column list.                                      |
|    4 | SuperKeys3_DynamicSQL   | `CREATE` | Creates the dynamic SQL statements to determine record counts for use in determining the super keys.    |
|    5 | SuperKeys4_Final        | `CREATE` | Create `SuperKeys3_Final` from `SuperKeys3_DynamicSQL`.                                                 |
|    6 | SuperKeys4_Final        | `UPDATE` | Using a cursor, loops through the SQL and updates the `SuperKeys4_Final.RecordCount` column.            |
|    7 | SuperKeys4_Final        | `UPDATE` | Updates the `IsSuperKey` and `IsMinimalSuperKey` columns in the table `SuperKeys4_Final`.               |
|    8 | SuperKeys5_StringSplit  | `CREATE` | Uses the `STRING_SPLIT` function to determine candidate keys.                                           |
|    9 | SuperKeys6_CandidateKey | `CREATE` | Creates the table `SuperKeys6_CandidateKey` to determine the candiate keys.                             |
|   10 | SuperKeys4_Final        | `UPDATE` | Updates the `SuperKeys5_Final.IsCandidateKey` column.                                                   |
|   11 | SuperKeys7_NonPrime     | `CREATE` | Using the `STRING_AGG` function, determine non-prime attributes of the candidate keys.                  |
|   12 | SuperKeys4_Final        | `UPDATE` | For all super keys, update the `NonPrimeAttributes` column in the `SuperKeys4_Final`table.              |


A **candidate key** is a minimal set of attributes (or columns) that can uniquely identify each tuple (or row) in a relation (or table) without redundancy. In other words, a **candidate key** is a combination of one or more attributes that uniquely identifies each tuple in the relation.  A relation can have multiple **candidate keys**, but one of them (usually the minimal super key) is promoted to be the primary key of the relation.


### Example Output

Here is example output from the script:


|         ColumnList         | IsSuperKey | IsMinimalSuperKey | IsCandidateKey | NonPrimeAttributes   |
|----------------------------|------------|-------------------|----------------|----------------------|
| Tournament,Year            |          1 |                 1 |              1 | DOB,Winner           |
| Tournament,Winner,Year     |          1 |                 0 |              0 | DOB                  |
| DOB,Tournament,Year        |          1 |                 0 |              0 | Winner               |
| DOB,Tournament,Winner,Year |          1 |                 0 |              0 | <NULL>               |
| Tournament                 |          0 |                 0 |              0 | <NULL>               |
| DOB                        |          0 |                 0 |              0 | <NULL>               |
| Year                       |          0 |                 0 |              0 | <NULL>               |
| Winner                     |          0 |                 0 |              0 | <NULL>               |
| Winner,Year                |          0 |                 0 |              0 | <NULL>               |
| DOB,Tournament             |          0 |                 0 |              0 | <NULL>               |
| DOB,Winner                 |          0 |                 0 |              0 | <NULL>               |
| Tournament,Winner          |          0 |                 0 |              0 | <NULL>               |
| DOB,Year                   |          0 |                 0 |              0 | <NULL>               |
| DOB,Winner,Year            |          0 |                 0 |              0 | <NULL>               |
| DOB,Tournament,Winner      |          0 |                 0 |              0 | <NULL>               |
