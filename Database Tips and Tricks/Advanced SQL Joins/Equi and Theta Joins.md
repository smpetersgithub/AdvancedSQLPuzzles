**Equi-joins** are a type of join operation that combines rows from two or more tables based on a matching value in one or more columns. This matching value is known as the "join condition" and is an equality condition. The term "equi" comes from the Latin word "aequus," meaning "equal."

On the other hand, a **theta-join**, also known as a **non-equi-join**, is a type of join that uses a comparison operator other than equality. These comparison operators include greater than, less than, and so on. The term "theta" is used to denote any non-equality comparison.  The terms **equi-join** and **theta-join** were coined by E.F. Codd in his seminal work on defining relational algebra, which serves as the foundation for SQL.

SQL has the following comparison operators that can be used to join tables.  These operators can be used in the ON clause of a table join and can be negated with the NOT operator.

| Type  |       Operator        |                                     Description                                    |
|-------|-----------------------|------------------------------------------------------------------------------------|
| Equi  |  =                    |  Equal To                                                                          |
| Theta |  <>                   |  Not Equal To                                                                      |
| Theta |  !=                   |  Not Equal To                                                                      |
| Theta |  >                    |  Greater Than                                                                      |
| Theta |  <                    |  Less Than                                                                         |
| Theta |  >=                   |  Greather Than or Equal To                                                         |
| Theta |  <=                   |  Less Than or Equal To                                                             |
| Theta |  IS DISTINCT FROM     |  Treats NULLs as known values for comparing equality                               |
| Theta |  IS NOT DISTINCT FROM |  Treats NULLs as known values for comparing equality                               |
| Theta |  BETWEEN              |  Defines a range and is inclusive                                                  |
| Theta |  LIKE                 |  Matches a string value to a specified pattern                                     |
