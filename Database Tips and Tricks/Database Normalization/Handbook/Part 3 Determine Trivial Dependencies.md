# Part 2: Determine Trivial Dependencies

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

---------------

Generating a permutations table of determinants and dependents can result in a large output. In the case of our sample dataset, the output is 225 rows.

|        Determinant         |         Dependent          | IsTrivialDependency | IsSemiTrivialDependency | IsDeterminantSuperKey | IsDependentSuperKey |
|----------------------------|----------------------------|---------------------|-------------------------|-----------------------|---------------------|
| DOB,Tournament,Winner,Year | DOB,Tournament,Winner,Year |                   1 |                       0 |                     1 |                   1 |
| DOB,Tournament,Winner,Year | DOB,Tournament,Year        |                   1 |                       0 |                     1 |                   1 |
| DOB,Tournament,Winner,Year | Tournament,Winner,Year     |                   1 |                       0 |                     1 |                   1 |
| DOB,Tournament,Winner,Year | Tournament,Year            |                   1 |                       0 |                     1 |                   1 |
| DOB,Tournament,Year        | DOB,Tournament,Winner,Year |                   0 |                       1 |                     1 |                   1 |
| DOB,Tournament,Year        | DOB,Tournament,Year        |                   1 |                       0 |                     1 |                   1 |
| DOB,Tournament,Year        | Tournament,Winner,Year     |                   0 |                       1 |                     1 |                   1 |
| DOB,Tournament,Year        | Tournament,Year            |                   1 |                       0 |                     1 |                   1 |
| Tournament,Winner,Year     | DOB,Tournament,Winner,Year |                   0 |                       1 |                     1 |                   1 |
| Tournament,Winner,Year     | DOB,Tournament,Year        |                   0 |                       1 |                     1 |                   1 |
| Tournament,Winner,Year     | Tournament,Winner,Year     |                   1 |                       0 |                     1 |                   1 |
| Tournament,Winner,Year     | Tournament,Year            |                   1 |                       0 |                     1 |                   1 |
| Tournament,Year            | DOB,Tournament,Winner,Year |                   0 |                       1 |                     1 |                   1 |
| Tournament,Year            | DOB,Tournament,Year        |                   0 |                       1 |                     1 |                   1 |
| Tournament,Year            | Tournament,Winner,Year     |                   0 |                       1 |                     1 |                   1 |
| Tournament,Year            | Tournament,Year            |                   1 |                       0 |                     1 |                   1 |
| DOB,Tournament,Winner,Year | DOB                        |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | DOB,Tournament             |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | DOB,Tournament,Winner      |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | DOB,Winner                 |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | DOB,Winner,Year            |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | DOB,Year                   |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | Tournament                 |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | Tournament,Winner          |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | Winner                     |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | Winner,Year                |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Winner,Year | Year                       |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Year        | DOB                        |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Year        | DOB,Tournament             |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Year        | DOB,Tournament,Winner      |                   0 |                       1 |                     1 |                   0 |
| DOB,Tournament,Year        | DOB,Winner                 |                   0 |                       1 |                     1 |                   0 |
| DOB,Tournament,Year        | DOB,Winner,Year            |                   0 |                       1 |                     1 |                   0 |
| DOB,Tournament,Year        | DOB,Year                   |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Year        | Tournament                 |                   1 |                       0 |                     1 |                   0 |
| DOB,Tournament,Year        | Tournament,Winner          |                   0 |                       1 |                     1 |                   0 |
| DOB,Tournament,Year        | Winner                     |                   0 |                       0 |                     1 |                   0 |
| DOB,Tournament,Year        | Winner,Year                |                   0 |                       1 |                     1 |                   0 |
| DOB,Tournament,Year        | Year                       |                   1 |                       0 |                     1 |                   0 |
| Tournament,Winner,Year     | DOB                        |                   0 |                       0 |                     1 |                   0 |
| Tournament,Winner,Year     | DOB,Tournament             |                   0 |                       1 |                     1 |                   0 |
| Tournament,Winner,Year     | DOB,Tournament,Winner      |                   0 |                       1 |                     1 |                   0 |
| Tournament,Winner,Year     | DOB,Winner                 |                   0 |                       1 |                     1 |                   0 |
| Tournament,Winner,Year     | DOB,Winner,Year            |                   0 |                       1 |                     1 |                   0 |
| Tournament,Winner,Year     | DOB,Year                   |                   0 |                       1 |                     1 |                   0 |
| Tournament,Winner,Year     | Tournament                 |                   1 |                       0 |                     1 |                   0 |
| Tournament,Winner,Year     | Tournament,Winner          |                   1 |                       0 |                     1 |                   0 |
| Tournament,Winner,Year     | Winner                     |                   1 |                       0 |                     1 |                   0 |
| Tournament,Winner,Year     | Winner,Year                |                   1 |                       0 |                     1 |                   0 |
| Tournament,Winner,Year     | Year                       |                   1 |                       0 |                     1 |                   0 |
| Tournament,Year            | DOB                        |                   0 |                       0 |                     1 |                   0 |
| Tournament,Year            | DOB,Tournament             |                   0 |                       1 |                     1 |                   0 |
| Tournament,Year            | DOB,Tournament,Winner      |                   0 |                       1 |                     1 |                   0 |
| Tournament,Year            | DOB,Winner                 |                   0 |                       0 |                     1 |                   0 |
| Tournament,Year            | DOB,Winner,Year            |                   0 |                       1 |                     1 |                   0 |
| Tournament,Year            | DOB,Year                   |                   0 |                       1 |                     1 |                   0 |
| Tournament,Year            | Tournament                 |                   1 |                       0 |                     1 |                   0 |
| Tournament,Year            | Tournament,Winner          |                   0 |                       1 |                     1 |                   0 |
| Tournament,Year            | Winner                     |                   0 |                       0 |                     1 |                   0 |
| Tournament,Year            | Winner,Year                |                   0 |                       1 |                     1 |                   0 |
| Tournament,Year            | Year                       |                   1 |                       0 |                     1 |                   0 |
| DOB                        | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| DOB                        | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| DOB                        | Tournament,Winner,Year     |                   0 |                       0 |                     0 |                   1 |
| DOB                        | Tournament,Year            |                   0 |                       0 |                     0 |                   1 |
| DOB,Tournament             | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| DOB,Tournament             | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| DOB,Tournament             | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| DOB,Tournament             | Tournament,Year            |                   0 |                       1 |                     0 |                   1 |
| DOB,Tournament,Winner      | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| DOB,Tournament,Winner      | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| DOB,Tournament,Winner      | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| DOB,Tournament,Winner      | Tournament,Year            |                   0 |                       1 |                     0 |                   1 |
| DOB,Winner                 | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| DOB,Winner                 | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| DOB,Winner                 | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| DOB,Winner                 | Tournament,Year            |                   0 |                       0 |                     0 |                   1 |
| DOB,Winner,Year            | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| DOB,Winner,Year            | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| DOB,Winner,Year            | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| DOB,Winner,Year            | Tournament,Year            |                   0 |                       1 |                     0 |                   1 |
| DOB,Year                   | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| DOB,Year                   | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| DOB,Year                   | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| DOB,Year                   | Tournament,Year            |                   0 |                       1 |                     0 |                   1 |
| Tournament                 | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| Tournament                 | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| Tournament                 | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| Tournament                 | Tournament,Year            |                   0 |                       1 |                     0 |                   1 |
| Tournament,Winner          | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| Tournament,Winner          | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| Tournament,Winner          | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| Tournament,Winner          | Tournament,Year            |                   0 |                       1 |                     0 |                   1 |
| Winner                     | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| Winner                     | DOB,Tournament,Year        |                   0 |                       0 |                     0 |                   1 |
| Winner                     | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| Winner                     | Tournament,Year            |                   0 |                       0 |                     0 |                   1 |
| Winner,Year                | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| Winner,Year                | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| Winner,Year                | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| Winner,Year                | Tournament,Year            |                   0 |                       1 |                     0 |                   1 |
| Year                       | DOB,Tournament,Winner,Year |                   0 |                       1 |                     0 |                   1 |
| Year                       | DOB,Tournament,Year        |                   0 |                       1 |                     0 |                   1 |
| Year                       | Tournament,Winner,Year     |                   0 |                       1 |                     0 |                   1 |
| Year                       | Tournament,Year            |                   0 |                       1 |                     0 |                   1 |
| DOB                        | DOB                        |                   1 |                       0 |                     0 |                   0 |
| DOB                        | DOB,Tournament             |                   0 |                       1 |                     0 |                   0 |
| DOB                        | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| DOB                        | DOB,Winner                 |                   0 |                       1 |                     0 |                   0 |
| DOB                        | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| DOB                        | DOB,Year                   |                   0 |                       1 |                     0 |                   0 |
| DOB                        | Tournament                 |                   0 |                       0 |                     0 |                   0 |
| DOB                        | Tournament,Winner          |                   0 |                       0 |                     0 |                   0 |
| DOB                        | Winner                     |                   0 |                       0 |                     0 |                   0 |
| DOB                        | Winner,Year                |                   0 |                       0 |                     0 |                   0 |
| DOB                        | Year                       |                   0 |                       0 |                     0 |                   0 |
| DOB,Tournament             | DOB                        |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament             | DOB,Tournament             |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament             | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| DOB,Tournament             | DOB,Winner                 |                   0 |                       1 |                     0 |                   0 |
| DOB,Tournament             | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| DOB,Tournament             | DOB,Year                   |                   0 |                       1 |                     0 |                   0 |
| DOB,Tournament             | Tournament                 |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament             | Tournament,Winner          |                   0 |                       1 |                     0 |                   0 |
| DOB,Tournament             | Winner                     |                   0 |                       0 |                     0 |                   0 |
| DOB,Tournament             | Winner,Year                |                   0 |                       0 |                     0 |                   0 |
| DOB,Tournament             | Year                       |                   0 |                       0 |                     0 |                   0 |
| DOB,Tournament,Winner      | DOB                        |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament,Winner      | DOB,Tournament             |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament,Winner      | DOB,Tournament,Winner      |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament,Winner      | DOB,Winner                 |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament,Winner      | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| DOB,Tournament,Winner      | DOB,Year                   |                   0 |                       1 |                     0 |                   0 |
| DOB,Tournament,Winner      | Tournament                 |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament,Winner      | Tournament,Winner          |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament,Winner      | Winner                     |                   1 |                       0 |                     0 |                   0 |
| DOB,Tournament,Winner      | Winner,Year                |                   0 |                       1 |                     0 |                   0 |
| DOB,Tournament,Winner      | Year                       |                   0 |                       0 |                     0 |                   0 |
| DOB,Winner                 | DOB                        |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner                 | DOB,Tournament             |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner                 | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner                 | DOB,Winner                 |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner                 | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner                 | DOB,Year                   |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner                 | Tournament                 |                   0 |                       0 |                     0 |                   0 |
| DOB,Winner                 | Tournament,Winner          |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner                 | Winner                     |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner                 | Winner,Year                |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner                 | Year                       |                   0 |                       0 |                     0 |                   0 |
| DOB,Winner,Year            | DOB                        |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner,Year            | DOB,Tournament             |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner,Year            | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner,Year            | DOB,Winner                 |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner,Year            | DOB,Winner,Year            |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner,Year            | DOB,Year                   |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner,Year            | Tournament                 |                   0 |                       0 |                     0 |                   0 |
| DOB,Winner,Year            | Tournament,Winner          |                   0 |                       1 |                     0 |                   0 |
| DOB,Winner,Year            | Winner                     |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner,Year            | Winner,Year                |                   1 |                       0 |                     0 |                   0 |
| DOB,Winner,Year            | Year                       |                   1 |                       0 |                     0 |                   0 |
| DOB,Year                   | DOB                        |                   1 |                       0 |                     0 |                   0 |
| DOB,Year                   | DOB,Tournament             |                   0 |                       1 |                     0 |                   0 |
| DOB,Year                   | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| DOB,Year                   | DOB,Winner                 |                   0 |                       1 |                     0 |                   0 |
| DOB,Year                   | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| DOB,Year                   | DOB,Year                   |                   1 |                       0 |                     0 |                   0 |
| DOB,Year                   | Tournament                 |                   0 |                       0 |                     0 |                   0 |
| DOB,Year                   | Tournament,Winner          |                   0 |                       0 |                     0 |                   0 |
| DOB,Year                   | Winner                     |                   0 |                       0 |                     0 |                   0 |
| DOB,Year                   | Winner,Year                |                   0 |                       1 |                     0 |                   0 |
| DOB,Year                   | Year                       |                   1 |                       0 |                     0 |                   0 |
| Tournament                 | DOB                        |                   0 |                       0 |                     0 |                   0 |
| Tournament                 | DOB,Tournament             |                   0 |                       1 |                     0 |                   0 |
| Tournament                 | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| Tournament                 | DOB,Winner                 |                   0 |                       0 |                     0 |                   0 |
| Tournament                 | DOB,Winner,Year            |                   0 |                       0 |                     0 |                   0 |
| Tournament                 | DOB,Year                   |                   0 |                       0 |                     0 |                   0 |
| Tournament                 | Tournament                 |                   1 |                       0 |                     0 |                   0 |
| Tournament                 | Tournament,Winner          |                   0 |                       1 |                     0 |                   0 |
| Tournament                 | Winner                     |                   0 |                       0 |                     0 |                   0 |
| Tournament                 | Winner,Year                |                   0 |                       0 |                     0 |                   0 |
| Tournament                 | Year                       |                   0 |                       0 |                     0 |                   0 |
| Tournament,Winner          | DOB                        |                   0 |                       0 |                     0 |                   0 |
| Tournament,Winner          | DOB,Tournament             |                   0 |                       1 |                     0 |                   0 |
| Tournament,Winner          | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| Tournament,Winner          | DOB,Winner                 |                   0 |                       1 |                     0 |                   0 |
| Tournament,Winner          | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| Tournament,Winner          | DOB,Year                   |                   0 |                       0 |                     0 |                   0 |
| Tournament,Winner          | Tournament                 |                   1 |                       0 |                     0 |                   0 |
| Tournament,Winner          | Tournament,Winner          |                   1 |                       0 |                     0 |                   0 |
| Tournament,Winner          | Winner                     |                   1 |                       0 |                     0 |                   0 |
| Tournament,Winner          | Winner,Year                |                   0 |                       1 |                     0 |                   0 |
| Tournament,Winner          | Year                       |                   0 |                       0 |                     0 |                   0 |
| Winner                     | DOB                        |                   0 |                       0 |                     0 |                   0 |
| Winner                     | DOB,Tournament             |                   0 |                       0 |                     0 |                   0 |
| Winner                     | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| Winner                     | DOB,Winner                 |                   0 |                       1 |                     0 |                   0 |
| Winner                     | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| Winner                     | DOB,Year                   |                   0 |                       0 |                     0 |                   0 |
| Winner                     | Tournament                 |                   0 |                       0 |                     0 |                   0 |
| Winner                     | Tournament,Winner          |                   0 |                       1 |                     0 |                   0 |
| Winner                     | Winner                     |                   1 |                       0 |                     0 |                   0 |
| Winner                     | Winner,Year                |                   0 |                       1 |                     0 |                   0 |
| Winner                     | Year                       |                   0 |                       0 |                     0 |                   0 |
| Winner,Year                | DOB                        |                   0 |                       0 |                     0 |                   0 |
| Winner,Year                | DOB,Tournament             |                   0 |                       0 |                     0 |                   0 |
| Winner,Year                | DOB,Tournament,Winner      |                   0 |                       1 |                     0 |                   0 |
| Winner,Year                | DOB,Winner                 |                   0 |                       1 |                     0 |                   0 |
| Winner,Year                | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| Winner,Year                | DOB,Year                   |                   0 |                       1 |                     0 |                   0 |
| Winner,Year                | Tournament                 |                   0 |                       0 |                     0 |                   0 |
| Winner,Year                | Tournament,Winner          |                   0 |                       1 |                     0 |                   0 |
| Winner,Year                | Winner                     |                   1 |                       0 |                     0 |                   0 |
| Winner,Year                | Winner,Year                |                   1 |                       0 |                     0 |                   0 |
| Winner,Year                | Year                       |                   1 |                       0 |                     0 |                   0 |
| Year                       | DOB                        |                   0 |                       0 |                     0 |                   0 |
| Year                       | DOB,Tournament             |                   0 |                       0 |                     0 |                   0 |
| Year                       | DOB,Tournament,Winner      |                   0 |                       0 |                     0 |                   0 |
| Year                       | DOB,Winner                 |                   0 |                       0 |                     0 |                   0 |
| Year                       | DOB,Winner,Year            |                   0 |                       1 |                     0 |                   0 |
| Year                       | DOB,Year                   |                   0 |                       1 |                     0 |                   0 |
| Year                       | Tournament                 |                   0 |                       0 |                     0 |                   0 |
| Year                       | Tournament,Winner          |                   0 |                       0 |                     0 |                   0 |
| Year                       | Winner                     |                   0 |                       0 |                     0 |                   0 |
| Year                       | Winner,Year                |                   0 |                       1 |                     0 |                   0 |
| Year                       | Year                       |                   1 |                       0 |                     0 |                   0 |


