# Part 5: List Partial and Functional Dependencies

# Part 4: Determine Functional Dependencies

**Tables Used**    
1.  `PartialDependency`
2.  `FunctionalDependency`


### Steps Involved

| Step |        Table Created                             |  Action  |                                                         Notes                                                                                                       |
|------|--------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  1   |     FunctionalDependency                         |  CREATE  |  Creates the table `PartialDependency for which you can make deductions about 2NF.                                                                                  |
|  2   |     PartialDependency                            |  UPDATE  |  Updates the `PartialDependency.PartialDependency` column that gives a description of the dependency.                                                               |
|  3   |     PartialDependency                            |  INSERT  |  Inserts into the `FunctionalDependency` table any candidate keys that are currently not present.  These are keys that do not have any functional dependencies.     |
|  4   |     FunctionalDependency                         |  CREATE  |  Creates the table `FunctionalDependency` for which you can make deductions about 3NF, BCNF, 4NF, and 5NF.                                                          |
|  5   |     FunctionalDependency                         |  CREATE  |  Updates the `FunctionalDependency.FunctionalDependency` column that gives a description of the functional dependency.                                              |
|  6   |     FunctionalDependency                         |  INSERT  |  Creates the table `FunctionalDependency` for which you can make deductions about 3NF, BCNF, 4NF, and 5NF.                                                          |
|  7   |     FunctionalDependency                         |  CREATE  |  Inserts into the `FunctionalDependency` table any candidate keys that are currently not present.  These are keys that do not have any functional dependencies.     |

--------------------------------------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc. please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
