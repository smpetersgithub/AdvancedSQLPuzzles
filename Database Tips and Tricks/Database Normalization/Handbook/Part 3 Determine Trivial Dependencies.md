# Part 3: Determine Trivial Dependencies

This script determines trivial and semi-trivial dependencies.

To determine trivial and semi-trivial dependencies first generate a Cartesian product of all possible column combinations, and then compare the resulting list of combinations to identify any columns that appear in both the determinant and dependent sets.

**Table Used**    
1.  `Determinant_Dependent1_CrossJoin`
2.  `Determinant_Dependent2_StringSplit`
3.  `Determinant_Dependent3_SumPartOfDeterminant`
4.  `Determinant_Dependent4_TrivialDependency`



| Step |                          Table Created    |  Action  |                                                         Notes                                                                            |
|------|-------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------|
|1     | Determinant_Dependent1_CrossJoin          | CREATE   | Create the table `Determinant_Dependent1_CrossJoin` of all possibilities of determinants and dependents.                                  |
|2     | Determinant_Dependent2_StringSplit        | CREATE   | Uses `STRING_SPLIT` on the `Dependent` column to build a dataset to determine which columns are subsets.                                 |
|3     | Determinant_Dependent2_StringSplit        | CREATE   | Determine the count of `Dependent` columns that are part of the super key.                                                           |
|4     | Determinant_Dependent4_TrivialDependency  | CREATE   | Creates the `Determinant_Dependent4_TrivialDependency` table that determines if the dependent is a trivial or semi-trivial dependency.   |                    

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc. please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
