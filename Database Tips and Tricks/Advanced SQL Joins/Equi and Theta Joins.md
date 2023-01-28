
SQL has the following comparison operators, correct?

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


It is also important to note the following operators, although not considered equi-joins or theta-joins.

The NOT operator, as it negates a Boolean value, meaning that if a value is "true", the not operator will make it "false", and vice versa.

| NOT        |  Negates a Boolean value                                                 |
| NOT EXISTS |  Boolean operator that tests for the non-existence of rows in a subquery |
| EXISTS     |  Boolean operator that tests for the existence of rows in a subquery     |


The IN operator

