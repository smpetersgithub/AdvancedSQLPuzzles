# Creating Truth Tables Using SQL

----------

❗This article is not meant to be a lesson in propositional logic but simply an exploration of how to create truth tables using SQL.  If you are unfamiliar with propositional logic, I recommend taking a discrete mathematics course to understand the principles.

----------

A truth table is a mathematical tool used in logic to represent the output of Boolean expressions based on all possible combinations of input values (True or False). Commonly applied in Boolean algebra, Boolean functions, and propositional calculus, truth tables are also used to determine the logical validity of an expression by confirming whether it evaluates to true for all possible inputs.

| p | q | p ∧ q | p ∨ q |
|---|---|-------|-------|
| 1 | 1 | 1     | 1     |
| 1 | 0 | 0     | 1     |
| 0 | 1 | 0     | 1     |
| 0 | 0 | 0     | 0     |

This exploration examines the intersection of propositional logic and SQL, demonstrating how SQL can be used to generate truth tables. By doing so, it highlights SQL's ability to model logical expressions.

----------

### Truth Tables and SQL

Additionally, before we begin, a few SQL tidbits are worth mentioning.  

*  SQL is based on relational algebra and relational calculus.  Although SQL is rooted in predicate logic, it is not based on propositional calculus.    
*  SQL includes the possibility of NULL markers when creating predicate logic statements.   Propositional logic does not incorporate the concept of NULL markers into its paradigm.  We will ignore the concept of NULL markers entirely in this article.    
*  The `BIT` data type in SQL is not an accurate Boolean representation, as it has three possible values: True, False, and NULL.  Many SQL experts recommend avoiding the `BIT` data type because of this and instead using `SMALLINT` with permissible values 0 and 1.  Also, SQL Server does not allow arithmetic operations on the `BIT` data type; using the `SMALLINT` data type allows us to create mathematical expressions that can be used to evaluate conditions.   

🔌To learn more about NULL markers and their effect on predicate logic, check out my article "Behavior of NULLS".

-----------------------------------

### Propositional Statements

Propositional statements form the foundation of logical reasoning in both natural language and mathematical logic. A propositional statement is any statement that has a definite truth value—it is either **true or false**, but not both.

In everyday language, we encounter simple propositions such as:

* “It is sunny.”
* “I wear my sunglasses.”

These can be represented using variables:

* `p`: It is sunny
* `q`: I wear my sunglasses

In discrete mathematics, propositions are typically denoted using lowercase letters like `p`, `q`, and `r`.

Propositions can be combined using **logical connectives** to form more complex statements. For example, the conditional statement:

> *“If it is sunny, then I wear my sunglasses”*

is written as `p → q`


This does **not** mean that wearing sunglasses only happens when it is sunny. Instead, it states that whenever `p` is true, `q` must also be true.

Using propositional variables and logical connectives allows us to analyze and reason about statements in a precise and systematic way.

-----------------------------------

### Logic Symbols

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Like any branch of mathematics, a set of symbols and terms needs to be defined.  Here is a summary of the different symbols and terms, and examples of how they are used in everyday English statements. 

| Logical Operation       | Symbol |     English Language Usage     |
|-------------------------|--------|--------------------------------|
| Negation (NOT)          | ¬      | Not p                          |
| Conjunction (AND)       | ∧      | p and q                        |
| Disjunction (OR)        | ∨      | p or q                         |
| Implication (IF...THEN) | →      | If p, then q                   |
| Biconditional (IFF)     | ↔      | p if and only if q             |
| Tautology (True)        | ⊤      | Always True                    |
| Contradiction (False)   | ⊥      | Always False                   |
| Exclusive Or (XOR)      | ⊕     | Either p or q, but not both    |
| Logical Equivalent      | ⇔     | p is logically equivalent to q |

-----------------------------------

### Truth Table

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here is the SQL to generate the truth table.  I find pivoting the data and sorting by the outcome to be the best method to view the table given the number of columns.

| RowId        | p | q | T | F | ¬p | ¬q | ¬¬p | ¬¬q | p∧q | q∧p | p∧p | q∧q | p∧T | p∧F | q∧T | q∧F | ¬(p∧q) | ¬(p∧p) | ¬(q∧q) | ¬p∧p | ¬p∧q | ¬q∧q | ¬q∧p | ¬p∧¬q | p∨q | q∨p | p∨p | q∨q | p∨T | p∨F | q∨T | q∨F | ¬(p∨q) | ¬(p∨p) | ¬(q∨q) | ¬p∨p | ¬p∨q | ¬q∨q | ¬q∨p | ¬p∨¬q | p→q | q→p | p→q∧q→p | p→q∨q→p | ¬(p→q∧q→p) | ¬(p→q∨q→p) | ¬p→¬q | ¬q→¬p | p↔q | ¬(p↔q) | p⊕q | ¬(p⊕q) |
|--------------|---|---|---|---|----|----|-----|-----|-----|------|-----|-----|-----|------|-----|-----|---------|--------|--------|------|------|-------|------|--------|-----|------|-----|-----|-----|------|-----|-----|--------|---------|--------|------|-------|------|------|-------|-----|-----|----------|----------|-----------|-------------|-------|-------|-----|--------|-----|---------|
| p = 0, q = 0 | 0 | 0 | 1 | 0 |  1 |  1 |   0 |   0 |   0 |   0  |   0 |   0 |   0 |    0 |   0 |   0 |       1 |      1 |      1 |    0 |    0 |     0 |    0 |      1 |   0 |    0 |   0 |   0 |   1 |    0 |   1 |   0 |      1 |       1 |      1 |    1 |     1 |    1 |    1 |     1 |   1 |   1 |        1 |        1 |         0 |           0 |     1 |     1 |   1 |      0 |   0 |       1 |
| p = 0, q = 1 | 0 | 1 | 1 | 0 |  1 |  0 |   0 |   1 |   0 |   0  |   0 |   1 |   0 |    0 |   1 |   0 |       1 |      1 |      0 |    0 |    1 |     0 |    0 |      0 |   1 |    1 |   0 |   1 |   1 |    0 |   1 |   1 |      0 |       1 |      0 |    1 |     1 |    0 |    1 |     1 |   0 |   1 |        0 |        1 |         1 |           0 |     1 |     0 |   0 |      1 |   1 |       0 |
| p = 1, q = 0 | 1 | 0 | 1 | 0 |  0 |  1 |   1 |   0 |   0 |   0  |   1 |   0 |   1 |    0 |   0 |   0 |       1 |      0 |      1 |    0 |    0 |     0 |    1 |      0 |   1 |    1 |   1 |   0 |   1 |    1 |   1 |   0 |      0 |       0 |      1 |    1 |     0 |    1 |    1 |     1 |   0 |   1 |        0 |        1 |         1 |           0 |     1 |     0 |   0 |      1 |   1 |       0 |
| p = 1, q = 1 | 1 | 1 | 1 | 0 |  0 |  0 |   1 |   1 |   1 |   1  |   1 |   1 |   1 |    0 |   1 |   0 |       0 |      0 |      0 |    0 |    0 |     0 |    0 |      0 |   1 |    1 |   1 |   1 |   1 |    1 |   1 |   1 |      0 |       0 |      0 |    1 |     1 |    1 |    1 |     0 |   1 |   1 |        1 |        1 |         0 |           0 |     1 |     1 |   1 |      0 |   0 |       1 |




```sql
DROP TABLE IF EXISTS #TruthTable;
GO

WITH cte_LogicValues AS
(
SELECT  CAST(p AS SMALLINT) AS p,
        CAST(q AS SMALLINT) AS q,
        CAST(1 AS SMALLINT) AS T,
        CAST(0 AS SMALLINT) AS F
FROM    (SELECT p FROM (VALUES (0),(1)) AS MyTable(p)) a CROSS JOIN
        (SELECT q FROM (VALUES (0),(1)) AS MyTable2(q)) b
)
SELECT  CONCAT('p = ',p,',',' q = ',q) AS RowId
        --------------------------------------------
       ,p
       ,q
       ,T
       ,F
       --------------------------------------------
       --Negation
       ,(CASE p WHEN 0 THEN T ELSE F END) AS [¬p]
       ,(CASE q WHEN 0 THEN T ELSE F END) AS [¬q]
       --------------------------------------------
       --Double Negation
       ,(CASE WHEN NOT(NOT(p = 1)) THEN T ELSE F END) AS [¬¬p]
       ,(CASE WHEN NOT(NOT(q = 1)) THEN T ELSE F END) AS [¬¬q]
       --------------------------------------------
       --And
       ,(CASE WHEN p + q = 2 THEN T ELSE F END) AS [p∧q]
       ,(CASE WHEN q + p = 2 THEN T ELSE F END) AS [q∧p]
       ,(CASE WHEN p + p = 2 THEN T ELSE F END) AS [p∧p]
       ,(CASE WHEN q + q = 2 THEN T ELSE F END) AS [q∧q]
       ,(CASE WHEN p + T = 2 THEN T ELSE F END) AS [p∧T]
       ,(CASE WHEN p + F = 2 THEN T ELSE F END) AS [p∧F]
       ,(CASE WHEN q + T = 2 THEN T ELSE F END) AS [q∧T]
       ,(CASE WHEN q + F = 2 THEN T ELSE F END) AS [q∧F]
       ,(CASE WHEN NOT(p = T  AND q = T) THEN T ELSE F END) AS [¬(p∧q)]
       ,(CASE WHEN NOT(p = T  AND p = T) THEN T ELSE F END) AS [¬(p∧p)]
       ,(CASE WHEN NOT(q = T  AND q = T) THEN T ELSE F END) AS [¬(q∧q)]
       ,(CASE WHEN NOT(p = T) AND p = T  THEN T ELSE F END) AS [¬p∧p]
       ,(CASE WHEN NOT(p = T) AND q = T  THEN T ELSE F END) AS [¬p∧q]
       ,(CASE WHEN NOT(q = T) AND q = T  THEN T ELSE F END) AS [¬q∧q]
       ,(CASE WHEN NOT(q = T) AND p = T  THEN T ELSE F END) AS [¬q∧p]
       ,(CASE WHEN NOT(p = T) AND NOT(q = T) THEN T ELSE F END) AS [¬p∧¬q]
        --------------------------------------------
       --Or
       ,(CASE WHEN p + q >= 1 THEN T ELSE F END) AS [p∨q]
       ,(CASE WHEN q + p >= 1 THEN T ELSE F END) AS [q∨p]
       ,(CASE WHEN p + p >= 1 THEN T ELSE F END) AS [p∨p]
       ,(CASE WHEN q + q >= 1 THEN T ELSE F END) AS [q∨q]
       ,(CASE WHEN p + T >= 1 THEN T ELSE F END) AS [p∨T]
       ,(CASE WHEN p + F >= 1 THEN T ELSE F END) AS [p∨F]
       ,(CASE WHEN q + T >= 1 THEN T ELSE F END) AS [q∨T]
       ,(CASE WHEN q + F >= 1 THEN T ELSE F END) AS [q∨F]
       ,(CASE WHEN NOT(p = T  OR q = T) THEN T ELSE F END) AS [¬(p∨q)]
       ,(CASE WHEN NOT(p = T  OR p = T) THEN T ELSE F END) AS [¬(p∨p)]
       ,(CASE WHEN NOT(q = T  OR q = T) THEN T ELSE F END) AS [¬(q∨q)]
       ,(CASE WHEN NOT(p = T) OR p = T  THEN T ELSE F END) AS [¬p∨p]
       ,(CASE WHEN NOT(p = T) OR q = T  THEN T ELSE F END) AS [¬p∨q]
       ,(CASE WHEN NOT(q = T) OR q = T  THEN T ELSE F END) AS [¬q∨q]
       ,(CASE WHEN NOT(q = T) OR p = T  THEN T ELSE F END) AS [¬q∨p]
       ,(CASE WHEN NOT(p = T) OR NOT(q = T) THEN T ELSE F END) AS [¬p∨¬q]
       --------------------------------------------
       --Implies (If..Then)
       ,(CASE WHEN p <= q THEN T ELSE F END) AS [p→q]
       ,(CASE WHEN q <= p THEN T ELSE F END) AS [q→p]
       ,(CASE WHEN p <= q AND q <= p THEN T ELSE F END) AS [p→q∧q→p]
       ,(CASE WHEN p <= q OR  q <= p THEN T ELSE F END) AS [p→q∨q→p]
       ,(CASE WHEN NOT(p <= q AND q <= p) THEN T ELSE F END) AS [¬(p→q∧q→p)]
       ,(CASE WHEN NOT(p <= q OR  q <= p) THEN T ELSE F END) AS [¬(p→q∨q→p)]
       ,(CASE WHEN (CASE WHEN p = T THEN 0 ELSE 1 END) <= (CASE WHEN q = T THEN 0 ELSE 1 END) THEN T ELSE F END) AS [¬p→¬q]
       ,(CASE WHEN (CASE WHEN q = T THEN 0 ELSE 1 END) <= (CASE WHEN p = T THEN 0 ELSE 1 END) THEN T ELSE F END) AS [¬q→¬p]	   
       --------------------------------------------
       --Biconditional (If And Only If)
       ,(CASE WHEN p = q THEN T ELSE F END) AS [p↔q]
       ,(CASE WHEN NOT(p = q) THEN T ELSE F END) AS [¬(p↔q)]
        --------------------------------------------
       --XOR (Exclusive OR)
       ,(CASE WHEN p + q = 1 THEN T ELSE F END) AS [p⊕q]
       ,(CASE WHEN NOT(p + q = 1) THEN T ELSE F END) AS [¬(p⊕q)]
INTO   #TruthTable
FROM   cte_LogicValues
ORDER BY p DESC, q DESC;
GO

SELECT * FROM #TruthTable;
```

```sql
--Pivot the data
;WITH cte_Pivot AS
(
SELECT  operation, [p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1]
FROM
    (SELECT RowId,
            Operation,
            value
     FROM #TruthTable
     UNPIVOT
     (
         value
         FOR operation IN 
        ([¬p], [¬q], [¬¬p], [¬¬q], [p∧q], [q∧p], [p∧p], [q∧q], [p∧T], [p∧F], [q∧T], [q∧F], [¬(p∧q)], [¬(p∧p)], [¬(q∧q)], [¬p∧p], [¬p∧q], [¬q∧q], [¬q∧p], [¬p∧¬q], [p∨q], [q∨p], [p∨p], [q∨q], [p∨T], [p∨F], [q∨T], [q∨F], [¬(p∨q)], [¬(p∨p)], [¬(q∨q)], [¬p∨p], [¬p∨q], [¬q∨q], [¬q∨p], [¬p∨¬q], [p→q], [q→p], 
         [p↔q], [p⊕q],[p→q∧q→p], [p→q∨q→p],[¬(p→q∧q→p)], [¬(p→q∨q→p)], [¬(p↔q)],[¬(p⊕q)],[¬p→¬q],[¬q→¬p]
        )
     ) AS unpvt) AS src
PIVOT
(
    MAX(value)
    FOR RowId IN ([p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1])
) AS pvt
),
cte_RowNumber AS
(
SELECT  ROW_NUMBER() OVER (ORDER BY [p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1], Operation) AS RowNumber,
        CONCAT([p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1]) AS LogicIdentity,
        *
FROM cte_Pivot
)
SELECT  DENSE_RANK() OVER (PARTITION BY LogicIdentity ORDER BY RowNumber) AS DenseRank
        ,*
INTO    #TruthTable_Pivot
FROM    cte_RowNumber;
GO

SELECT * FROM #TruthTable_Pivot;
```

Here is the truth table pivoted, with a dense rank and row number added.

| DenseRank | RowNumber | LogicIdentity | Operation     | p = 0, q = 0 | p = 0, q = 1 | p = 1, q = 0 | p = 1, q = 1 |
| ----------|-----------|---------------|---------------|--------------|--------------|--------------|--------------|
| 1         | 1         | 0000          | ¬(p→q∨q→p)    | 0            | 0            | 0            | 0            |
| 2         | 2         | 0000          | ¬p∧p          | 0            | 0            | 0            | 0            |
| 3         | 3         | 0000          | ¬q∧q          | 0            | 0            | 0            | 0            |
| 4         | 4         | 0000          | p∧F           | 0            | 0            | 0            | 0            |
| 5         | 5         | 0000          | q∧F           | 0            | 0            | 0            | 0            |
| 1         | 6         | 0001          | p∧q           | 0            | 0            | 0            | 1            |
| 2         | 7         | 0001          | q∧p           | 0            | 0            | 0            | 1            |
| 1         | 8         | 0010          | ¬q∧p          | 0            | 0            | 1            | 0            |
| 1         | 9         | 0011          | ¬¬p           | 0            | 0            | 1            | 1            |
| 2         | 10        | 0011          | p∧p           | 0            | 0            | 1            | 1            |
| 3         | 11        | 0011          | p∧T           | 0            | 0            | 1            | 1            |
| 4         | 12        | 0011          | p∨F           | 0            | 0            | 1            | 1            |
| 5         | 13        | 0011          | p∨p           | 0            | 0            | 1            | 1            |
| 1         | 14        | 0100          | ¬p∧q          | 0            | 1            | 0            | 0            |
| 1         | 15        | 0101          | ¬¬q           | 0            | 1            | 0            | 1            |
| 2         | 16        | 0101          | q∧q           | 0            | 1            | 0            | 1            |
| 3         | 17        | 0101          | q∧T           | 0            | 1            | 0            | 1            |
| 4         | 18        | 0101          | q∨F           | 0            | 1            | 0            | 1            |
| 5         | 19        | 0101          | q∨q           | 0            | 1            | 0            | 1            |
| 1         | 20        | 0110          | ¬(p→q∧q→p)    | 0            | 1            | 1            | 0            |
| 2         | 21        | 0110          | ¬(p↔q)        | 0            | 1            | 1            | 0            |
| 3         | 22        | 0110          | p⊕q           | 0            | 1            | 1            | 0            |
| 1         | 23        | 0111          | p∨q           | 0            | 1            | 1            | 1            |
| 2         | 24        | 0111          | q∨p           | 0            | 1            | 1            | 1            |
| 1         | 25        | 1000          | ¬(p∨q)        | 1            | 0            | 0            | 0            |
| 2         | 26        | 1000          | ¬p∧¬q         | 1            | 0            | 0            | 0            |
| 1         | 27        | 1001          | ¬(p⊕q)        | 1            | 0            | 0            | 1            |
| 2         | 28        | 1001          | p→q∧q→p       | 1            | 0            | 0            | 1            |
| 3         | 29        | 1001          | p↔q           | 1            | 0            | 0            | 1            |
| 1         | 30        | 1010          | ¬(q∧q)        | 1            | 0            | 1            | 0            |
| 2         | 31        | 1010          | ¬(q∨q)        | 1            | 0            | 1            | 0            |
| 3         | 32        | 1010          | ¬q            | 1            | 0            | 1            | 0            |
| 1         | 33        | 1011          | ¬p→¬q         | 1            | 0            | 1            | 1            |
| 2         | 34        | 1011          | ¬q∨p          | 1            | 0            | 1            | 1            |
| 3         | 35        | 1011          | q→p           | 1            | 0            | 1            | 1            |
| 1         | 36        | 1100          | ¬(p∧p)        | 1            | 1            | 0            | 0            |
| 2         | 37        | 1100          | ¬(p∨p)        | 1            | 1            | 0            | 0            |
| 3         | 38        | 1100          | ¬p            | 1            | 1            | 0            | 0            |
| 1         | 39        | 1101          | ¬p∨q          | 1            | 1            | 0            | 1            |
| 2         | 40        | 1101          | ¬q→¬p         | 1            | 1            | 0            | 1            |
| 3         | 41        | 1101          | p→q           | 1            | 1            | 0            | 1            |
| 1         | 42        | 1110          | ¬(p∧q)        | 1            | 1            | 1            | 0            |
| 2         | 43        | 1110          | ¬p∨¬q         | 1            | 1            | 1            | 0            |
| 1         | 44        | 1111          | ¬p∨p          | 1            | 1            | 1            | 1            |
| 2         | 45        | 1111          | ¬q∨q          | 1            | 1            | 1            | 1            |
| 3         | 46        | 1111          | p∨T           | 1            | 1            | 1            | 1            |
| 4         | 47        | 1111          | p→q∨q→p       | 1            | 1            | 1            | 1            |
| 5         | 48        | 1111          | q∨T           | 1            | 1            | 1            | 1            |

---------------

### Logic Laws

Propositional logic consists of several fundamental laws that are crucial for logical reasoning and manipulation of logical expressions. These laws are important because they provide a framework for constructing valid arguments, proving theorems, and simplifying logical statements. The following are the most popular laws, but there are several more.

|      Law Name        |    Formula                                                              |
|----------------------|-------------------------------------------------------------------------|
| Identity Law         | p ∧ T ⇔ p<br>p ∨ F ⇔ p                                                |
| Domination Law       | p ∨ T ⇔ T<br>p ∧ F ⇔ F                                                |
| Idempotent Law       | p ∨ p ⇔ p<br>p ∧ p ⇔ p                                                |
| Complement Law       | p ∨ ¬p ⇔ T<br>p ∧ ¬p ⇔ F                                              |
| Double Negation Law  | ¬(¬p) ⇔ p                                                              |
| Commutative Law      | p ∨ q ⇔ q ∨ p<br>p ∧ q ⇔ q ∧ p                                       |
| Associative Law      | (p ∨ q) ∨ r ⇔ p ∨ (q ∨ r)<br>(p ∧ q) ∧ r ⇔ p ∧ (q ∧ r)              |
| Distributive Law     | p ∧ (q ∨ r) ⇔ (p ∧ q) ∨ (p ∧ r)<br>p ∨ (q ∧ r) ⇔ (p ∨ q) ∧ (p ∨ r)  |
| De Morgan's Law      | ¬(p ∧ q) ⇔ ¬p ∨ ¬q<br>¬(p ∨ q) ⇔ ¬p ∧ ¬q                              |
| Implication Law      | p → q ⇔ ¬p ∨ q                                                         |
| Absorption Law       | p ∨ (p ∧ q) ⇔ p<br>p ∧ (p ∨ q) ⇔ p                                   |
| Contraposition Law   | p → q ⇔ ¬q → ¬p                                                        |
| Biconditional Law    | p ↔ q ⇔ (p → q) ∧ (q → p)<br>p ↔ q ⇔ ¬p ↔ ¬q                          |
| Exclusive Or Law     | p ⊕ q ⇔ (p ∨ q) ∧ ¬(p ∧ q)                                            |


Many of these laws may seem trivial in nature, but the most important one for SQL developers to understand is De Morgan's law.  We will look at this law along with a few others.

---------------

### De Morgan's Law

De Morgan's Laws are two transformation rules that are used in propositional logic and Boolean algebra. They state that:

1. The negation of a conjunction is the disjunction of the negations: `¬(p ∧ q) ⇔ ¬p ∨ ¬q`
2. The negation of a disjunction is the conjunction of the negations: `¬(p ∨ q) ⇔ ¬p ∧ ¬q`

These laws are important because they allow for the expression of logical statements in different forms, which can be very useful in various logical and computational applications, such as simplifying logical expressions and digital circuit design.

### Negation of Conjunction

| p | q | ¬(p∧q) | ¬p∨¬q |
|---|---|--------|-------|
| 0 | 0 |   1    |   1   |
| 0 | 1 |   1    |   1   |
| 1 | 0 |   1    |   1   |
| 1 | 1 |   0    |   0   |

###  Negation of Disjunction

| p | q | ¬(p∨q) | ¬p∧¬q |
|---|---|--------|-------|
| 0 | 0 |   1    |   1   |
| 0 | 1 |   0    |   0   |
| 1 | 0 |   0    |   0   |
| 1 | 1 |   0    |   0   |

### Exclusive Or Law (XOR)

A closer examination of logical laws reveals that various logical truths can be expressed in multiple ways. Notably, the XOR operation, represented as `p⊕q`, is logically equivalent to the negation of the biconditional: `p⊕q≡¬[(¬p→¬q)∧(¬q→¬p)]`.

| p | q | p⊕q | ¬p→¬q ∧ ¬q→¬p |
|---|---|-----|----------------|
| 1 | 1 | 0   |       1        |
| 1 | 0 | 1   |       0        | 
| 0 | 1 | 1   |       0        |
| 0 | 0 | 0   |       1        |

-----

### Conditional Statements

| p | q | p→q<br>Conditional | ¬q→¬p<br>Contrapositive | q→p<br>Converse | ¬p→¬q<br>Inverse |
|---|---|--------------------|-------------------------|-----------------|------------------|
| 1 | 1 | 1                  | 1                       | 1               | 1                |
| 1 | 0 | 0                  | 0                       | 1               | 1                |
| 0 | 1 | 1                  | 1                       | 0               | 0                |
| 0 | 0 | 1                  | 1                       | 1               | 1                |

The conditional statement `p → q` has several related forms: the **contrapositive** (`¬q → ¬p`), the **converse** (`q → p`), and the **inverse** (`¬p → ¬q`). While these are all connected, only the original statement and its contrapositive are logically equivalent.

A common example is:

> *“When it is sunny, I wear my sunglasses.”*

Let:

* `p` = It is sunny
* `q` = I wear my sunglasses

We evaluate this statement by considering all possible combinations of `p` and `q`:

* It is sunny, and I am wearing sunglasses
* It is sunny, and I am not wearing sunglasses
* It is not sunny, and I am wearing sunglasses
* It is not sunny, and I am not wearing sunglasses

Only one of these violates the original statement:

> **It is sunny, and I am not wearing sunglasses**

This is false because it contradicts the rule that sunny weather implies wearing sunglasses. All other cases are valid since the statement makes no claim about what happens when it is not sunny.

#### Converse and Inverse

Now consider the **converse**:

> *“If I am wearing my sunglasses, then it is sunny.”*

Here:

* `q` = I am wearing my sunglasses
* `p` = It is sunny

This is a different statement and not logically equivalent to the original. It assumes that wearing sunglasses only happens when it is sunny, which is not necessarily true.

Looking again at all possibilities:

* It is sunny, and I am wearing sunglasses
* It is sunny, and I am not wearing sunglasses
* It is not sunny, and I am wearing sunglasses
* It is not sunny, and I am not wearing sunglasses

The incorrect case is now:

> **It is not sunny, and I am wearing sunglasses**

This makes the converse false because it provides a counterexample—wearing sunglasses does not guarantee that it is sunny.

The **inverse** fails for the same reason, since it also assumes a stronger relationship than the original statement provides.

Here is the truth table again, so you can review the converse and inverse and how it relates to the conditional and contrapositive without scrolling to the top of this section.

| p | q | p→q<br>Conditional | ¬q→¬p<br>Contrapositive | q→p<br>Converse | ¬p→¬q<br>Inverse |
|---|---|--------------------|-------------------------|-----------------|------------------|
| 1 | 1 | 1                  | 1                       | 1               | 1                |
| 1 | 0 | 0                  | 0                       | 1               | 1                |
| 0 | 1 | 1                  | 1                       | 0               | 0                |
| 0 | 0 | 1                  | 1                       | 1               | 1                |

-----

### Tautology (⊤) and Contradiction (⊥)

Tautology (⊤) and contradiction (⊥) are fundamental concepts in propositional logic. A tautology is a statement that is always true, regardless of the truth values of its components. It represents a universal truth and is used to express logical certainties. On the other hand, a contradiction is a statement that is always false, no matter what the truth values of its components are. It symbolizes an inherent inconsistency and is used to denote logical impossibilities. Both concepts are crucial in logical reasoning, helping to understand and define the limits of logical arguments and establish the validity of logical proofs.

#### Tautology
| p | q | ¬p∨p | ¬q∨q | p∨T | p→q∨q→p | q∨T |
|---|---|------|------|-----|---------|-----|
| 0 | 0 |  1   |  1   |  1  |    1    |  1  |
| 0 | 1 |  1   |  1   |  1  |    1    |  1  |
| 1 | 0 |  1   |  1   |  1  |    1    |  1  |
| 1 | 1 |  1   |  1   |  1  |    1    |  1  |

#### Contradiction (⊥)

| p | q | ¬(p→q∨q→p) | ¬p∧p | ¬q∧q | p∧F | q∧F |
|---|---|------------|------|------|-----|-----|
| 0 | 0 |     0      |   0  |   0  |  0  |  0  |
| 0 | 1 |     0      |   0  |   0  |  0  |  0  |
| 1 | 0 |     0      |   0  |   0  |  0  |  0  |
| 1 | 1 |     0      |   0  |   0  |  0  |  0  |

----

### Conclusion

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The exploration of logical operations and their corresponding truth tables offers insightful perspectives into the foundations of propositional logic. By systematically breaking down complex logical expressions into simpler components, we can discern the underlying principles governing logical reasoning. This analysis not only reinforces the fundamental concepts of logic, such as negation, conjunction, and disjunction, but also elucidates more intricate aspects, such as implications and biconditional relationships. The ability to translate these logical operations into a structured format, such as a truth table, is a valuable skill that enhances our understanding of logical processes and their applications across various fields.
