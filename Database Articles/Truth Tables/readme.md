# Creating Truth Tables Using SQL

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A truth table is a mathematical table utilized in logic, particularly relevant to Boolean algebra, Boolean functions, and propositional calculus. This table methodically displays the output values of logical expressions based on various combinations of input values (True or False) assigned to their logical variables. Moreover, truth tables serve as a tool to determine if a given propositional expression consistently yields a true outcome across all possible legitimate input values, thereby establishing its logical validity.

| p | q | p ∧ q | p ∨ q |
|---|---|-------|-------|
| 1 | 1 | 1     | 1     |
| 1 | 0 | 0     | 1     |
| 0 | 1 | 0     | 1     |
| 0 | 0 | 0     | 0     |

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This exploration ventures into the intriguing crossroads of propositional logic and SQL, uncovering their interconnectedness. It focuses on demonstrating the capability of SQL in constructing comprehensive truth tables, a fundamental aspect of logical reasoning. This article not only reveals the practical application of SQL in logical operations but also deepens the understanding of how these two domains complement each other.

----------

❗This article is not meant to be a lesson in propositional logic but simply an exploration of how to create truth tables using SQL.  If you are unfamiliar with propositional logic, I recommend taking a discrete mathematics course to understand the principles.

----------

Additionally, before we begin, a few tidbits of SQL should be mentioned.  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	SQL is based on relational algebra and relational calculus.  Although SQL is rooted in predicate logic, it is not based on propositional calculus.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	SQL includes the possibility of NULL markers when creating predicate logic statements.   Propositional logic does not incorporate the concept of NULL markers into its paradigm.  We will be ignoring the concept of NULL markers entirely for this article.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	The `BIT` data type in SQL is not an accurate Boolean representation, as it has three possible values: True, False, and NULL.  Many SQL experts recommend not to use the `BIT` data type because of this, and instead use the `SMALLINT` data type and set the permissible values to 0 and 1.  Also, SQL Server does not allow math operations on the `BIT` data type; using the `SMALLINT` datatype allows us to create mathematical expressions that we can use to resolve truths.   

🔌To learn more about NULL markers and their effect on predicate logic, check out my article Behavior of NULLS.

-----------------------------------

### Propositional Statements

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Propositional statements form the core of logical reasoning in both natural language and mathematical logic. These statements, characterized by their ability to be distinctly true or false, are the building blocks of logical expressions. Commonly, in everyday language, we encounter propositions in statements like "If it is sunny, I wear my sunglasses." In this case, the proposition "It is sunny" is represented by the uppercase variable `P`, and "I wear my sunglasses" by `Q`. In the realm of discrete mathematics, these propositions are often denoted more abstractly with lowercase variables such as `p`, `q`, and `r`.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The relationship between these propositions can be articulated through logical connectives. In the provided example, the conditional "If P, then Q" (symbolized as `P → Q`) establishes a logical link between the two propositions. This implies that the occurrence of `Q` (wearing sunglasses) is contingent upon `P` (it being sunny). The use of such propositional variables and logical connectives allows for a formal and systematic approach to dissecting and understanding the structure of arguments and logical processes.

-----------------------------------

### Logic Symbols

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Like any branch of mathematics, a set of symbols and terms needs to be defined.  Here is a summary of the different symbols and terms and examples of how they are used in everyday English statements. 

| Logical Operation       | Symbol |   English Language Usage     |
|-------------------------|--------|------------------------------|
| Negation (NOT)          | ¬      | Not p                        |
| Conjunction (AND)       | ∧      | p and q                      |
| Disjunction (OR)        | ∨      | p or q                       |
| Implication (IF...THEN) | →      | If p, then q                 |
| Biconditional (IFF)     | ↔      | p if and only if q           |
| Tautology (True)        | ⊤      | Always True                  |
| Contradiction (False)   | ⊥      | Always False                 |
| Exclusive Or (XOR)      | ⊕     | Either p or q, but not both  |
| Logical Equivalant      | ⇔     | 2+3 is the equivalant of 4+1 |

-----------------------------------

### Truth Table

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here is the SQL to generate the truth table.  I find pivoting the data and sorting by the outcome the best method to view the table given the number of columns.

| RowId       | p | q | T | F | ¬p | ¬q | ¬¬p | ¬¬q | p∧q | q∧p | p∧p | q∧q | p∧T | p∧F | q∧T | q∧F | ¬(p∧q) | ¬(p∧p) | ¬(q∧q) | ¬p∧p | ¬p∧q | ¬q∧q | ¬q∧p | ¬p∧¬q | p∨q | q∨p | p∨p | q∨q | p∨T | p∨F | q∨T | q∨F | ¬(p∨q) | ¬(p∨p) | ¬(q∨q) | ¬p∨p | ¬p∨q | ¬q∨q | ¬q∨p | ¬p∨¬q | p→q | q→p | p→q∧q→p | p→q∨q→p | ¬(p→q∧q→p) | ¬(p→q∨q→p) | ¬p→¬q | ¬q→¬p | p↔q | ¬(p↔q) | p⊕q | ¬(p⊕q) |
|-------------|---|---|---|---|----|----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|--------|--------|--------|------|------|------|------|-------|-----|-----|-----|-----|-----|-----|-----|-----|-------|-------|-------|------|------|------|------|-------|-----|-----|----------|----------|--------------|--------------|--------|--------|-----|---------|-----|---------|
| p = 0, q = 0| 0 | 0 | 1 | 0 |  1 |  1 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   1    |   1    |   1    |   0  |   0  |   0  |   0  |   1   |   0 |   0 |   0 |   0 |   1 |   0 |   1 |   0 |    1    |    1    |    1    |   1   |   1   |   1   |   1   |    1   |   1  |   1  |     1     |     1     |       0       |       0       |    1   |    1   |   1  |    0    |   0  |    1    |
| p = 0, q = 1| 0 | 1 | 1 | 0 |  1 |  0 |   0 |   1 |   0 |   0 |   0 |   1 |   0 |   0 |   1 |   0 |   1    |   1    |   0    |   0  |   1  |   0  |   1  |   0   |   1 |   1 |   0 |   1 |   1 |   0 |   1 |   1 |    0    |    1    |    0    |   1   |   1   |   0   |   1   |    1   |   0  |   1  |     0     |     1     |       1       |       0       |    1   |    0   |   0  |    1    |   1  |    0    |
| p = 1, q = 0 | 1 | 0 | 1 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | 1 | 1 | 1 | 0 | 1 | 0 | 1 | 1 | 0 | 1 | 0 | 0 | 1 | 1 | 0 |
| p = 1, q = 1 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 1 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | 1 |




```
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
       ,(CASE WHEN NOT(p = T) AND q = T  THEN T ELSE F END) AS [¬q∧p]
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

```
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

| Operation     | p = 0, q = 0 | p = 0, q = 1 | p = 1, q = 0 | p = 1, q = 1 | DenseRank | RowNumber | LogicIdentity |
|---------------|--------------|--------------|--------------|--------------|-----------|-----------|---------------|
| ¬(p→q∨q→p)    | 0            | 0            | 0            | 0            | 1         | 1         | 0000          |
| ¬p∧p          | 0            | 0            | 0            | 0            | 2         | 2         | 0000          |
| ¬q∧q          | 0            | 0            | 0            | 0            | 3         | 3         | 0000          |
| p∧F           | 0            | 0            | 0            | 0            | 4         | 4         | 0000          |
| q∧F           | 0            | 0            | 0            | 0            | 5         | 5         | 0000          |
| p∧q           | 0            | 0            | 0            | 1            | 1         | 6         | 0001          |
| q∧p           | 0            | 0            | 0            | 1            | 2         | 7         | 0001          |
| ¬¬p           | 0            | 0            | 1            | 1            | 1         | 8         | 0011          |
| p∧p           | 0            | 0            | 1            | 1            | 2         | 9         | 0011          |
| p∧T           | 0            | 0            | 1            | 1            | 3         | 10        | 0011          |
| p∨F           | 0            | 0            | 1            | 1            | 4         | 11        | 0011          |
| p∨p           | 0            | 0            | 1            | 1            | 5         | 12        | 0011          |
| ¬p∧q          | 0            | 1            | 0            | 0            | 1         | 13        | 0100          |
| ¬q∧p          | 0            | 1            | 0            | 0            | 2         | 14        | 0100          |
| ¬¬q           | 0            | 1            | 0            | 1            | 1         | 15        | 0101          |
| q∧q           | 0            | 1            | 0            | 1            | 2         | 16        | 0101          |
| q∧T           | 0            | 1            | 0            | 1            | 3         | 17        | 0101          |
| q∨F           | 0            | 1            | 0            | 1            | 4         | 18        | 0101          |
| q∨q           | 0            | 1            | 0            | 1            | 5         | 19        | 0101          |
| ¬(p→q∧q→p)    | 0            | 1            | 1            | 0            | 1         | 20        | 0110          |
| ¬(p↔q)        | 0            | 1            | 1            | 0            | 2         | 21        | 0110          |
| p⊕q           | 0            | 1            | 1            | 0            | 3         | 22        | 0110          |
| p∨q           | 0            | 1            | 1            | 1            | 1         | 23        | 0111          |
| q∨p           | 0            | 1            | 1            | 1            | 2         | 24        | 0111          |
| ¬(p∨q)        | 1            | 0            | 0            | 0            | 1         | 25        | 1000          |
| ¬p∧¬q         | 1            | 0            | 0            | 0            | 2         | 26        | 1000          |
| ¬(p⊕q)        | 1            | 0            | 0            | 1            | 1         | 27        | 1001          |
| p→q∧q→p       | 1            | 0            | 0            | 1            | 2         | 28        | 1001          |
| p↔q           | 1            | 0            | 0            | 1            | 3         | 29        | 1001          |
| ¬(q∧q)        | 1            | 0            | 1            | 0            | 1         | 30        | 1010          |
| ¬(q∨q)        | 1            | 0            | 1            | 0            | 2         | 31        | 1010          |
| ¬q            | 1            | 0            | 1            | 0            | 3         | 32        | 1010          |
| ¬p→¬q         | 1            | 0            | 1            | 1            | 1         | 33        | 1011          |
| ¬q∨p          | 1            | 0            | 1            | 1            | 2         | 34        | 1011          |
| q→p           | 1            | 0            | 1            | 1            | 3         | 35        | 1011          |
| ¬(p∧p)        | 1            | 1            | 0            | 0            | 1         | 36        | 1100          |
| ¬(p∨p)        | 1            | 1            | 0            | 0            | 2         | 37        | 1100          |
| ¬p            | 1            | 1            | 0            | 0            | 3         | 38        | 1100          |
| ¬p∨q          | 1            | 1            | 0            | 1            | 1         | 39        | 1101          |
| ¬q→¬p         | 1            | 1            | 0            | 1            | 2         | 40        | 1101          |
| p→q           | 1            | 1            | 0            | 1            | 3         | 41        | 1101          |
| ¬(p∧q)        | 1            | 1            | 1            | 0            | 1         | 42        | 1110          |
| ¬p∨¬q         | 1            | 1            | 1            | 0            | 2         | 43        | 1110          |
| ¬p∨p          | 1            | 1            | 1            | 1            | 1         | 44        | 1111          |
| ¬q∨q          | 1            | 1            | 1            | 1            | 2         | 45        | 1111          |
| p∨T           | 1            | 1            | 1            | 1            | 3         | 46        | 1111          |
| p→q∨q→p       | 1            | 1            | 1            | 1            | 4         | 47        | 1111          |
| q∨T           | 1            | 1            | 1            | 1            | 5         | 48        | 1111          |

---------------

### Logic Laws

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Propositional logic consists of several fundamental laws that are crucial for logical reasoning and manipulation of logical expressions. These laws are important because they provide a framework for constructing valid arguments, proving theorems, and simplifying logical statements. The following are the most popular laws, but there are several more.

|      Law Name        |    Formula                        |
|----------------------|-----------------------------------|
| Identity Law         | p ∧ T ⇔ p<br>p ∨ F ⇔ p          |
| Domination Law       | p ∨ T ⇔ T<br>p ∧ F ⇔ F          |
| Idempotent Law       | p ∨ p ⇔ p<br>p ∧ p ⇔ p          |
| Complement Law       | p ∨ ¬p ⇔ T<br>p ∧ ¬p ⇔ F        |
| Double Negation Law  | ¬(¬p) ⇔ p                        |
| Commutative Law      | p ∨ q ⇔ q ∨ p<br>p ∧ q ⇔ q ∧ p  |
| Associative Law      | (p ∨ q) ∨ r ⇔ p ∨ (q ∨ r)<br>(p ∧ q) ∧ r ⇔ p ∧ (q ∧ r) |
| Distributive Law     | p ∧ (q ∨ r) ⇔ (p ∧ q) ∨ (p ∧ r)<br>p ∨ (q ∧ r) ⇔ (p ∨ q) ∧ (p ∨ r) |
| De Morgan's Law      | ¬(p ∧ q) ⇔ ¬p ∨ ¬q<br>¬(p ∨ q) ⇔ ¬p ∧ ¬q |
| Implication Law      | p → q ⇔ ¬p ∨ q                   |
| Absorption Law       | p ∨ (p ∧ q) ⇔ p<br>p ∧ (p ∨ q) ⇔ p |
| Contraposition Law   | p → q ⇔ ¬q → ¬p                   |
| Biconditional Law    | p ↔ q ⇔ (p → q) ∧ (q → p)<br>p ↔ q ⇔ ¬p ↔ ¬q |
| Exclusive Or Law     | p ⊕ q ⇔ (p ∨ q) ∧ ¬(p ∧ q)       |


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Many of these laws may seem trivial in nature, but the most important one for SQL developers to understand is De Morgan's law.  We will look at this law along with a few others.

---------------

### De Morgan's Law

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;De Morgan's Laws are two transformation rules that are used in propositional logic and Boolean algebra. They state that:

1. The negation of a conjunction is the disjunction of the negations: `¬(p ∧ q) ⇔ ¬p ∨ ¬q`
2. The negation of a disjunction is the conjunction of the negations: `¬(p ∨ q) ⇔ ¬p ∧ ¬q`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;These laws are important because they allow for the expression of logical statements in different forms, which can be very useful in various logical and computational applications, such as simplifying logical expressions and digital circuit design.

#### Negation of Conjunction

| p | q | ¬(p∧q) | ¬p∨¬q |
|---|---|--------|-------|
| 0 | 0 |   1    |   1   |
| 0 | 1 |   1    |   1   |
| 1 | 0 |   1    |   1   |
| 1 | 1 |   0    |   0   |

####  Negation of Disjunction

| p | q | ¬(p∨q) | ¬p∧¬q |
|---|---|--------|-------|
| 0 | 0 |   1    |   1   |
| 0 | 1 |   0    |   0   |
| 1 | 0 |   0    |   0   |
| 1 | 1 |   0    |   0   |

#### Exclusive Or Law (XOR)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A closer examination of logical laws reveals that various logical truths can be expressed in multiple ways. Notably, the XOR (Exclusive Or) operation, represented as `p ⊕ q`, is equivalent to the conjunction of the implications `¬p → ¬q ∧ ¬q → ¬p`.

| p | q | p⊕q | ¬p→¬q ∧ ¬q→¬p |
|---|---|-----|----------------|
| 1 | 1 | 0   |       0        |
| 1 | 0 | 1   |       1        | 
| 0 | 1 | 1   |       1        |
| 0 | 0 | 0   |       0        |

-----

#### Conditional Statements

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The conditional statement `p → q` possesses several related forms: its contrapositive `¬q → ¬p`, its converse `q → p`, and its inverse `¬p → ¬q`. Each of these forms offers a different perspective on the same underlying logical relationship.

| p | q | p→q<br>Conditional | ¬q→¬p<br>Converse | q→p<br>Contrapositive | ¬p→¬q<br>Inverse |
|---|---|--------------------|-------------------|-----------------------|------------------|
| 1 | 1 | 1                  | 1                 | 1                     | 1                |
| 1 | 0 | 0                  | 1                 | 1                     | 0                |
| 0 | 1 | 1                  | 0                 | 0                     | 1                |
| 0 | 0 | 1                  | 1                 | 1                     | 1                |

-----

#### Tautology (⊤) and Contradiction (⊥)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tautology (⊤) and contradiction (⊥) are fundamental concepts in propositional logic. A tautology is a statement that is always true, regardless of the truth values of its components. It represents a universal truth and is used to express logical certainties. On the other hand, a contradiction is a statement that is always false, no matter what the truth values of its components are. It symbolizes an inherent inconsistency and is used to denote logical impossibilities. Both concepts are crucial in logical reasoning, helping to understand and define the limits of logical arguments and 

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

### Conclusion

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The exploration of logical operations and their corresponding truth tables offers insightful perspectives into the foundations of propositional logic. By systematically breaking down complex logical expressions into simpler components, we can discern the underlying principles governing logical reasoning. This analysis not only reinforces the fundamental concepts of logic, such as negation, conjunction, and disjunction, but also elucidates the more intricate aspects like implications and biconditional relationships. The ability to translate these logical operations into a structured format like truth tables is a valuable skill, enhancing our understanding of logical processes and their applications in various fields.
