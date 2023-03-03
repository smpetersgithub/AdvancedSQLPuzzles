# Part 4: Determine Functional Dependencies

**Tables Used**    
1.  `Determinant_Dependent5_DynamicSQL1`
2.  `Determinant_Dependent6_DynamicSQL2`
3.  `Determinant_Dependent7_FunctionalDependency`


### Steps Involved

| Step |        Table Created                             |  Action  |                                                         Notes                                                              |
|------|--------------------------------------------------|----------|----------------------------------------------------------------------------------------------------------------------------|
|  1   |     Determinant_Dependent5_DynamicSQL1           |  CREATE  |  Builds part 1 of the dynamic SQL needed to determine Functional Dependencies.                                             |
|  2   |     Determinant_Dependent6_DynamicSQL2           |  CREATE  |  Builds part 2 of the dynamic SQL needed to determine Functional Dependencies.                                             |
|  3   |     Determinant_Dependent6_DynamicSQL2           |  UPDATE  |  Using a cursor, loop through `Determinant_Dependent6_DynamicSQL2` and determine if there is a Functional Dependency.      |
|  4   |     Determinant_Dependent7_FunctionalDependency  |  CREATE  |  Combine columns from `Determinant_Dependent6_DynamicSQL2` and `SuperKeys4_Final` for the Determinants and Dependents.     |

-------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc. please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
