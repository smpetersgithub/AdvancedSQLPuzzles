# Creating Truth Tables Using SQL

| p | q | p ∧ q | p ∨ q | ¬p | ¬¬p |
|---|---|-------|-------|----|-----|
| 1 | 1 | 1     | 1     | 0  | 1   |
| 1 | 0 | 0     | 1     | 0  | 1   |
| 0 | 1 | 0     | 1     | 1  | 0   |
| 0 | 0 | 0     | 0     | 1  | 0   |

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This exploration ventures into the intriguing crossroads of propositional logic and SQL, uncovering their interconnectedness. It focuses on demonstrating the capability of SQL in constructing comprehensive truth tables, a fundamental aspect of logical reasoning. This article not only reveals the practical application of SQL in logical operations but also deepens the understanding of how these two domains complement each other.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A truth table is a mathematical table utilized in logic, particularly relevant to Boolean algebra, Boolean functions, and propositional calculus. This table methodically displays the output values of logical expressions based on various combinations of input values (True or False) assigned to their logical variables. Moreover, truth tables serve as a tool to determine if a given propositional expression consistently yields a true outcome across all possible legitimate input values, thereby establishing its logical validity.

----------

🔌This article is not meant to be a lesson in propositional logic but simply an exploration of how to create truth tables using SQL.  If you are unfamiliar with propositional logic, I recommend taking a discrete mathematics course to understand the principles.

----------

Additionally, before we begin, a few tidbits of SQL should be mentioned.  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	SQL is based on relational algebra and relational calculus.  Although SQL is rooted in predicate logic, it is not based on propositional calculus.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	SQL includes the possibility of NULL markers when creating predicate logic statements.   Propositional logic does not incorporate the concept of NULL markers into its paradigm.  We will be ignoring the concept of NULL markers entirely for this article.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	The `BIT` data type in SQL is not an accurate Boolean representation, as it has three possible values: True, False, and NULL.  Many SQL experts recommend not to use the `BIT` data type because of this, and instead use the `SMALLINT` data type and set the permissible values to 0 and 1.  Also, SQL Server does not allow math operations on the `BIT` data type; using the `SMALLINT` datatype allows us to create mathematical expressions that we can use to resolve truths.   

❗To learn more about NULL markers and their effect on predicate logic, check out my article Behavior of NULLS.

-----------------------------------

### Truth Table

Now, let’s dive into truth tables and propositional statements.

A propositional statement is a statement that can be either true or false.  Often, we think of propositional statements in terms of English statements, such as: “When it is sunny, I wear my sunglasses”.  However, we often use a more generic form in discrete math and don’t assign statements to each proposition variable. The variables most used are P, Q, and R for English statements, and lowercase p, q, and r are used for generic statements.

In our example above, we would assign the uppercase P to “It is sunny” and the uppercase Q to “I wear my sunglasses".  We then would have a conditional statement of "If P, then Q", or "P → Q".

Like any branch of mathematics, a set of symbols and terms needs to be defined.  Here is a summary of the different symbols and terms and examples of how they are used in everyday English statements. 

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

Now that we have this out of the way, let’s build the following truth table.

| RowId       | p | q | T | F | ¬p | ¬q | ¬¬p | ¬¬q | p∧q | p∧p | q∧q | p∧T | p∧F | q∧T | q∧F | ¬p∧¬q | ¬p∧¬p | ¬q∧¬q | ¬p∧p | ¬p∧q | ¬q∧q | ¬q∧p | p∨q | q∨p | p∨p | q∨q | p∨T | p∨F | q∨T | q∨F | ¬p∨¬q | ¬p∨¬p | ¬q∨¬q | ¬p∨p | ¬p∨q | ¬q∨q | ¬q∨p | p→q | q→p | p↔q | p⊕q |
|-------------|---|---|---|---|----|----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-------|-------|-------|------|------|------|------|-----|-----|-----|-----|-----|-----|-----|-----|-------|-------|-------|------|------|------|------|-----|-----|-----|------|
| p = 0, q = 0| 0 | 0 | 1 | 0 |  1 |  1 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |     1 |     1 |     1 |    0 |    0 |    0 |    0 |   0 |   0 |   0 |   0 |   1 |   0 |   1 |   0 |     1 |     1 |     1 |    1 |    1 |    1 |    1 |   1 |   1 |   1 |    0 |
| p = 0, q = 1| 0 | 1 | 1 | 0 |  1 |  0 |   0 |   1 |   0 |   0 |   1 |   0 |   0 |   1 |   0 |     1 |     1 |     0 |    0 |    1 |    1 |    1 |   1 |   1 |   0 |   1 |   1 |   0 |   1 |   1 |     0 |     1 |     1 |    1 |    1 |    1 |    1 |   1 |   0 |   0 |    1 |
| p = 1, q = 0| 1 | 0 | 1 | 0 |  0 |  1 |   1 |   0 |   0 |   1 |   0 |   1 |   0 |   0 |   0 |     1 |     0 |     1 |    0 |    0 |    0 |    0 |   1 |   1 |   1 |   0 |   1 |   1 |   1 |   0 |     0 |     0 |     1 |    1 |    1 |    0 |    0 |   0 |   0 |   1 |    0 |
| p = 1, q = 1| 1 | 1 | 1 | 0 |  0 |  0 |   1 |   1 |   1 |   1 |   1 |   1 |   0 |   1 |   0 |     0 |     0 |     0 |    0 |    0 |    0 |    0 |   1 |   1 |   1 |   1 |   1 |   1 |   1 |   1 |     0 |     0 |     0 |    0 |    1 |    1 |    1 |   1 |   1 |   1 |    0 |



```
DROP TABLE IF EXISTS #LogicValues;
DROP TABLE IF EXISTS #TruthTable;
GO

SELECT  *,
        1 AS T,
        0 AS F
INTO    #LogicValues
FROM    (SELECT p FROM (VALUES (0),(1)) AS MyTable(p)) a CROSS JOIN
        (SELECT q FROM (VALUES (0),(1)) AS MyTable2(q)) b;


SELECT  CONCAT('p = ',p,',',' q = ',q) AS RowId
        --------------------------------------------
       ,p
       ,q
       ,T
       ,F
       --------------------------------------------
       --Negation
       ,(CASE p WHEN 0 THEN T ELSE F END) AS "¬p"
       ,(CASE q WHEN 0 THEN T ELSE F END) AS "¬q"
       --------------------------------------------
       --Double Negation
       ,(CASE WHEN NOT(NOT(p = 1)) THEN T ELSE F END) AS "¬¬p"
       ,(CASE WHEN NOT(NOT(q = 1)) THEN T ELSE F END) AS "¬¬q"
       --------------------------------------------
       --And
       ,(CASE WHEN p + q = 2 THEN T ELSE F END) AS "p∧q"
       ,(CASE WHEN q + p = 2 THEN T ELSE F END) AS "q∧p"
       ,(CASE WHEN p + p = 2 THEN T ELSE F END) AS "p∧p"
       ,(CASE WHEN q + q = 2 THEN T ELSE F END) AS "q∧q"
       ,(CASE WHEN p + T = 2 THEN T ELSE F END) AS "p∧T"
       ,(CASE WHEN p + F = 2 THEN T ELSE F END) AS "p∧F"
       ,(CASE WHEN q + T = 2 THEN T ELSE F END) AS "q∧T"
       ,(CASE WHEN q + F = 2 THEN T ELSE F END) AS "q∧F"
       ,(CASE WHEN NOT(p = T  AND q = T) THEN T ELSE F END) AS "¬p∧¬q"
       ,(CASE WHEN NOT(p = T  AND p = T) THEN T ELSE F END) AS "¬p∧¬p"
       ,(CASE WHEN NOT(q = T  AND q = T) THEN T ELSE F END) AS "¬q∧¬q"
       ,(CASE WHEN NOT(p = T) AND p = T  THEN T ELSE F END) AS "¬p∧p"
       ,(CASE WHEN NOT(p = T) AND q = T  THEN T ELSE F END) AS "¬p∧q"
       ,(CASE WHEN NOT(p = T) AND q = T  THEN T ELSE F END) AS "¬q∧q"
       ,(CASE WHEN NOT(p = T) AND q = T  THEN T ELSE F END) AS "¬q∧p"
       --------------------------------------------
       --Or
       ,(CASE WHEN p + q >= 1 THEN T ELSE F END) AS "p∨q"
       ,(CASE WHEN q + p >= 1 THEN T ELSE F END) AS "q∨p"
       ,(CASE WHEN p + p >= 1 THEN T ELSE F END) AS "p∨p"
       ,(CASE WHEN q + q >= 1 THEN T ELSE F END) AS "q∨q"
       ,(CASE WHEN p + T >= 1 THEN T ELSE F END) AS "p∨T"
       ,(CASE WHEN p + F >= 1 THEN T ELSE F END) AS "p∨F"
       ,(CASE WHEN q + T >= 1 THEN T ELSE F END) AS "q∨T"
       ,(CASE WHEN q + F >= 1 THEN T ELSE F END) AS "q∨F"
       ,(CASE WHEN NOT(p = T  OR q = T) THEN T ELSE F END) AS "¬p∨¬q"
       ,(CASE WHEN NOT(p = T  OR p = T) THEN T ELSE F END) AS "¬p∨¬p"
       ,(CASE WHEN NOT(q = T  OR q = T) THEN T ELSE F END) AS "¬q∨¬q"
       ,(CASE WHEN NOT(p = T) OR p = T  THEN T ELSE F END) AS "¬p∨p"
       ,(CASE WHEN NOT(p = T) OR q = T  THEN T ELSE F END) AS "¬p∨q"
       ,(CASE WHEN NOT(p = T) OR q = T  THEN T ELSE F END) AS "¬q∨q"
       ,(CASE WHEN NOT(p = T) OR q = T  THEN T ELSE F END) AS "¬q∨p"
       --------------------------------------------
       --Implies (If..Then)
       ,(CASE WHEN p <= q THEN T ELSE F END) AS "p→q"
       ,(CASE WHEN q <= p THEN T ELSE F END) AS "q→p"
       --------------------------------------------
       --Biconditional (If And Only If)
       ,(CASE WHEN p = q THEN T ELSE F END) AS "p↔q"
       --------------------------------------------
       --XOR (Exclusive OR)
       ,(CASE WHEN p + q = 1 THEN T ELSE F END) AS "p⊕q"	
INTO   #TruthTable
FROM   #LogicValues
ORDER BY p DESC, q DESC;
GO
```

## Logic Laws

Propositional logic consists of several fundamental laws that are crucial for logical reasoning and manipulation of logical expressions. These laws are important because they provide a framework for constructing valid arguments, proving theorems, and simplifying logical statements. The following are the most popular laws, but there are several more.

|      Law Name        |             Formula              |
|----------------------|----------------------------------|
| Identity Law         | p ∧ T ⇔ p<br>p ∨ F ⇔ p         |
| Domination Law       | p ∨ T ⇔ T<br>p ∧ F ⇔ F         |
| Idempotent Law       | p ∨ p ⇔ p<br>p ∧ p ⇔ p         |
| Complement Law       | p ∨ ¬p ⇔ T<br>p ∧ ¬p ⇔ F       |
| Double Negation Law  | ¬(¬p) ⇔ p                       |
| Commutative Law      | p ∨ q ⇔ q ∨ p<br>p ∧ q ⇔ q ∧ p |
| Associative Law      | (p ∨ q) ∨ r ⇔ p ∨ (q ∨ r)<br>(p ∧ q) ∧ r ⇔ p ∧ (q ∧ r)             |
| Distributive Law     | p ∧ (q ∨ r) ⇔ (p ∧ q) ∨ (p ∧ r)<br>p ∨ (q ∧ r) ⇔ (p ∨ q) ∧ (p ∨ r) |
| De Morgan's Law      | ¬(p ∧ q) ⇔ ¬p ∨ ¬q<br>¬(p ∨ q) ⇔ ¬p ∧ ¬q                            |

Many of these laws may seem trivial in nature, but the most important one for SQL developers to understand is De Morgan's law.

### De Morgan's Law

De Morgan's Laws are two transformation rules that are used in propositional logic and Boolean algebra. They state that:

1. The negation of a conjunction is the disjunction of the negations: ¬(p ∧ q) ⇔ ¬p ∨ ¬q
2. The negation of a disjunction is the conjunction of the negations: ¬(p ∨ q) ⇔ ¬p ∧ ¬q

These laws are important because they allow for the expression of logical statements in different forms, which can be very useful in various logical and computational applications, such as simplifying logical expressions and digital circuit design.

The following SQL statement can be used to prove De Morgan's Law from the truth table we created.

```
SELECT  'Negation of Conjunction' AS [Description],
        RowId,
        "¬(p∧q)",
        "¬p∨¬q"
FROM    #TruthTable
WHERE  "¬(p∧q)" = "¬p∨¬q";

SELECT  'Negation of Disjunction' AS [Description],
        RowId,
        "¬(p∨q)",
        "¬p∧¬q"
FROM    #TruthTable
WHERE  "¬(p∨q)" = "¬p∧¬q";
```

---------------

| Description            | RowId       | ¬(p∧q) | ¬p∨¬q |
|------------------------|-------------|--------|-------|
| Negation of Conjunction| p = 0, q = 0|   1    |   1   |
| Negation of Conjunction| p = 0, q = 1|   1    |   1   |
| Negation of Conjunction| p = 1, q = 0|   1    |   1   |
| Negation of Conjunction| p = 1, q = 1|   0    |   0   |


| Description            | RowId       | ¬(p∨q) | ¬p∧¬q |
|------------------------|-------------|--------|-------|
| Negation of Disjunction| p = 0, q = 0|   1    |   1   |
| Negation of Disjunction| p = 0, q = 1|   0    |   0   |
| Negation of Disjunction| p = 1, q = 0|   0    |   0   |
| Negation of Disjunction| p = 1, q = 1|   0    |   0   |

---------------

### Analysing the Truth Table

To analyse the truth table to find easily find such things as all statements that are always true or false (tautology/contradiction) or which statements have matching/unmatching outcomes, it is easiest if we pivot the table using the following SQL statement.

```

--Pivot the data
SELECT operation, [p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1]
FROM
    (SELECT RowId,
            operation,
            value
     FROM #TruthTable
     UNPIVOT
     (
         value
         FOR operation IN ("p", "q", "T", "F", "¬p", "¬q", "¬¬p", "¬¬q", "p∧q", "q∧p", "p∧p", "q∧q", "p∧T", "p∧F", "q∧T", "q∧F", "¬(p∧q)", "¬(p∧p)", "¬(q∧q)", "¬p∧p", "¬p∧q", "¬q∧q", "¬q∧p", "¬p∧¬q", "p∨q", "q∨p", "p∨p", "q∨q", "p∨T", "p∨F", "q∨T", "q∨F", "¬(p∨q)", "¬(p∨p)", "¬(q∨q)", "¬p∨p", "¬p∨q", "¬q∨q", "¬q∨p", "p→q", "q→p", "p↔q", "p⊕q"
)
     ) AS unpvt) AS src
PIVOT
(
    MAX(value)
    FOR RowId IN ([p = 0, q = 0],[p = 0, q = 1],[p = 1, q = 0],[p = 1, q = 1])
) AS pvt
ORDER BY 2,3,4,5,1;
```


