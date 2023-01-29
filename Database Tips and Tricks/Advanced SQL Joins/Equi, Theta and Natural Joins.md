# Equi, Theta, and Natural Joins

*  **Equi-joins** are a type of join operation that combines rows from two or more tables based on a matching value in one or more columns. This matching value is known as the "join condition" and is an equality condition. The term "equi" comes from the Latin word "aequus," meaning "equal."

*  A **theta-join**, also known as a **non-equi-join**, is a type of join that uses a comparison operator other than equality. These comparison operators include greater than, less than, and so on. The term "theta" is used to denote any non-equality comparison.  The terms **equi-join** and **theta-join** were coined by E.F. Codd in his seminal work on defining relational algebra, which serves as the foundation for SQL.

----

SQL has the following comparison operators that can be used to join tables.  These operators can be used in the ON clause of a table join and can be negated with the NOT operator.

|       Operator        |                                     Description                                    |
|-----------------------|------------------------------------------------------------------------------------|
|  =                    |  Equal To                                                                          |
|  <>                   |  Not Equal To                                                                      |
|  !=                   |  Not Equal To                                                                      |
|  >                    |  Greater Than                                                                      |
|  <                    |  Less Than                                                                         |
|  >=                   |  Greather Than or Equal To                                                         |
|  <=                   |  Less Than or Equal To                                                             |
|  BETWEEN              |  Defines a range and is inclusive                                                  |
|  LIKE                 |  Matches a string value to a specified pattern                                     |
|  IS DISTINCT FROM     |  Treats NULLs as known values for comparing equality                               |
|  IS NOT DISTINCT FROM |  Treats NULLs as known values for comparing equality                               |

