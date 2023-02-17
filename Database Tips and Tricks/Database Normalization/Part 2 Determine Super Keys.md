# Part 2: Determine Super Keys

This script determines all the **Super Keys**, **Minimal Super Keys** and **Candidate Keys**.

#### Tables Used


1.  `anf_SuperKeys1_SysColumns`    
2.  `anf_SuperKeys2_Permutations`    
3.  `anf_SuperKeys3_DynamicSQL`    
6.  `anf_SuperKeys5_CandidateKey`    
4.  `anf_SuperKeys4_StringSplit`    
5.  `anf_SuperKeys5_CandidateKey`



I have named the tables with a prefix of "anf".  
*  "a" for the first letter of the alphabet so they are sorted in the object viewer.
*  "nf" for normal form.
---------------------------------------------


| Step |        Table Created        |          |                                                         Notes                                                   |
|------|-----------------------------|----------|-----------------------------------------------------------------------------------------------------------------|
|    1 | anf_SuperKeys1_SysColumns   | `CREATE` | From the system tables, determines all the columns in the table NormalizationTest.                              |
|    2 | anf_SuperKeys2_Permutations | `CREATE` | Seed the `anf_SuperKeys2_Permutations` table by a simple insert from `anf_SuperKeys1_SysColumns`.               |
|    3 | anf_SuperKeys2_Permutations | `INSERT` | Loop through the table to determine the column list; column order is kept in alphabetical order.                |
|    4 | anf_SuperKeys3_DynamicSQL   | `CREATE` | Creates the SQL statements to determine record counts for Super Keys.                                           |
|    5 | anf_SuperKeys3_Final        | `CREATE` | Create `anf_SuperKeys3_Final` from `anf_SuperKeys3_DynamicSQL`.                                                 |
|    6 | anf_SuperKeys3_Final        | `UPDATE` | Using a cursor, loops through the SQL and updates the table `anf_SuperKeys3_Final`.                             |
|    7 | anf_SuperKeys3_Final        | `UPDATE` | Updates the `IsSuperKey` and `IsMinimalSuperKey` columns.                                                       |
|    8 | anf_SuperKeys4_StringSplit  | `CREATE` | This step uses the `STRING_SPLIT` function to help in determining the candidate keys.                           |
|    9 | anf_SuperKeys5_CandidateKey | `CREATE` | Determines the Candiate Keys.                                                                                   |
|   10 | anf_SuperKeys5_Final        | `UPDATE` | Updates the `anf_SuperKeys5_Final` table with the Candidate Keys.                                               |





In a relational database management system (RDBMS), the minimum superkeys are known as candidate keys.  A candidate key is a minimal set of attributes (or columns) that can uniquely identify each tuple (or row) in a relation (or table) without redundancy. In other words, a candidate key is a combination of one or more attributes that uniquely identifies each tuple in the relation.  A relation can have multiple candidate keys, but one of them is typically chosen to be the primary key of the relation, which is used to establish relationships with other tables and to enforce referential integrity constraints.



