# Equi, Theta, and Natural Joins

*  Equi-joins are a type of join operation that combines rows from two or more tables based on a matching value in one or more columns. This matching value is known as the join condition and is an equality condition. The term equi comes from the Latin word aequus, meaning equal.

*  A theta-join, also known as a non-equi-join, is a type of join that uses an operator other than equality. These operators include both comparison and logical operators. The term "theta" is used to denote any non-equality comparison.  The terms equi-join and theta-join were coined by E.F. Codd in his seminal work on defining relational algebra, which serves as the foundation for SQL.

--------------------------------------------------------------------------------
SQL has the following operators that can be used to join tables.

| Type       |       Operator        |                                     Description       |
|------------|-----------------------|-------------------------------------------------------|
| Comparison |  =                    |  Equal To                                             |
| Comparison |  <>                   |  Not Equal To                                         |
| Comparison |  !=                   |  Not Equal To (not ISO standard)                      |
| Comparison |  >                    |  Greater Than                                         |
| Comparison |  !<                	 |  Not less than (not ISO standard)                     |
| Comparison |  <                    |  Less Than                                            |
| Comparison |  !>                   |Not greater than (not ISO standard)                    |
| Comparison |  >=                   |  Greater Than or Equal To                            |
| Comparison |  <=                   |  Less Than or Equal To                                |
| Logical    |  BETWEEN              |  Defines a range and is inclusive                     |
| Logical    |  LIKE                 |  Matches a string value to a specified pattern        |
|            |  IS DISTINCT FROM     |  Treats NULLs as known values for comparing equality  |
|            |  IS NOT DISTINCT FROM |  Treats NULLs as known values for comparing equality  |

*  Logical operators test for the truth of some condition. Logical operators, like comparison operators, return a Boolean data type with a value of TRUE, FALSE, or UNKNOWN.

*  Comparison operators test whether two expressions are the same. Comparison operators can be used on all expressions except expressions of the text, ntext, or image data types.

*  The IS \[NOT] DISTINCT FROM operator is relatively new feature being added to the various database systems.  I have set it to NULL as I have not been able to find any vendor documentation that categorizes this operator as logical or a comparison.

--------------------------------------------------------------------------------
#### Equi-joins

--------------------------------------------------------------------------------
#### Theta-joins

--------------------------------------------------------------------------------
#### Natural joins





