# Creating Truth Tables Using SQL

| p | q | p ∧ q | p ∨ q | ¬p | ¬¬p |
|---|---|-------|-------|----|-----|
| 1 | 1 | 1     | 1     | 0  | 1   |
| 1 | 0 | 0     | 1     | 0  | 1   |
| 0 | 1 | 0     | 1     | 1  | 0   |
| 0 | 0 | 0     | 0     | 1  | 0   |

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This exploration ventures into the intriguing crossroads of propositional logic and SQL, uncovering their interconnectedness. It focuses on demonstrating the capability of SQL in constructing comprehensive truth tables, a fundamental aspect of logical reasoning. This journey not only reveals the practical application of SQL in logical operations but also deepens the understanding of how these two domains complement each other.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A truth table is a mathematical table utilized in logic, particularly relevant to Boolean algebra, Boolean functions, and propositional calculus. This table methodically displays the output values of logical expressions based on various combinations of input values (True or False) assigned to their logical variables. Moreover, truth tables serve as a tool to determine if a given propositional expression consistently yields a true outcome across all possible legitimate input values, thereby establishing its logical validity.

----------

🔌This article is not meant to be a lesson in propositional logic but simply an exploration of how to create truth tables using SQL.  If you are unfamiliar with propositional logic, I recommend taking a discrete mathematics course to understand the principles.

----------

Additionally, before we begin, a few tidbits of SQL should be mentioned.  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	SQL is based on relational algebra and relational calculus.  Although SQL is rooted in predicate logic, it is not based on propositional calculus.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	SQL includes the possibility of NULL markers when creating predicate logic statements.   Propositional logic does not incorporate the concept of NULL markers into its paradigm.  We will be ignoring the concept of NULL markers entirely for this article.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•	The BIT data type in SQL is not an accurate Boolean representation, as it has three possible values: True, False, and NULL.  Many SQL experts recommend not to use the BIT data type because of this.  Also, using the BIT data type, where True is 1 and False is 0, allows us to create mathematical expressions that we can use to resolve truths.   

❗To learn more about NULL markers and their effect on predicate logic, check out my article Behavior of NULLS.

-----------------------------------

Now, let’s dive into truth tables and propositional statements.

A propositional statement is a statement that can be either true or false.  Often, we think of propositional statements in terms of English statements, such as: “When it is sunny, I wear my sunglasses”.  However, we often use a more generic form in discrete math and don’t assign statements to each proposition variable. The variables most used are P, R, and Q for English statements, and lowercase p, q, and r are used for generic statements.

In our example above, we would assign the uppercase P to “It is sunny” and the uppercase Q to “I wear my sunglasses".  We then would have a conditional statement of "If P, then Q", or "P → Q".

:electric_plug: As mentioned earlier, a discrete mathematics course is highly recommended if you are unfamiliar with propositional logic.

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

| RowId         | p | q | T | F | ¬p | ¬q | ¬¬p | ¬¬q | p∧q | q∧p | p∧p | p∧T | ¬(p∧q) | ¬p∧p | p∨q | q∨p | p∨F | ¬p∨q | ¬q∨p | ¬p∨¬q | ¬p∨p | p→q | q→p | p↔q | p⊕q |
|---------------|---|---|---|---|----|----|---  |-----|-----|-----|-----|-----|---------|------|-----|-----|------|------|------|-------|------|-----|-----|-----|-------|
| p = 0, q = 0  | 0 | 0 | 1 | 0 | 1 |  1  | 0   | 0   | 0   | 0   | 0   | 0   | 1       | 0    |  0  |  0  |  0   |  1   |  1   |  1    |  1   |  1  |  1  |  1  |  0    |
| p = 0, q = 1  | 0 | 1 | 1 | 0 | 1 |  0  | 0   | 1   | 0   | 0   | 0   | 0   | 1       | 0    |  1  |  1  |  0   |  1   |  0   |  1    |  1   |  1  |  0  |  0  |  1    |
| p = 1, q = 0  | 1 | 0 | 1 | 0 | 0 |  1  | 1   | 0   | 0   | 0   | 1   | 1   | 1       | 0    |  1  |  1  |  1   |  0   |  1   |  1    |  1   |  0  |  1  |  0  |  1    |
| p = 1, q = 1  | 1 | 1 | 1 | 0 | 0 |  0  | 1   | 1   | 1   | 1   | 1   | 1   | 0       | 0    |  1  |  1  |  1   |  1   |  1   |  0    |  1   |  1  |  1  |  1  |  0    |


Before we look at the SQL statement to generate the truth table. Propositional logic consists of several fundamental laws that are crucial for logical reasoning and manipulation of logical expressions. These laws are important because they provide a framework for constructing valid arguments, proving theorems, and simplifying logical statements. 

Here are some key laws.

|      Law Name        |             Formula              |
|----------------------|----------------------------------|
| Identity Law         | p ∧ T ⇔ p<br>p ∨ F ⇔ p         |
| Domination Law       | p ∨ T ⇔ T<br>p ∧ F ⇔ F         |
| Idempotent Law       | p ∨ p ⇔ p<br>p ∧ p ⇔ p         |
| Complement Law       | p ∨ ¬p ⇔ T<br>p ∧ ¬p ⇔ F       |
| Double Negation Law  | ¬(¬p) ⇔ p                       |
| Commutative Law      | p ∨ q ⇔ q ∨ p<br>p ∧ q ⇔ q ∧ p |
| Associative Law      | (p ∨ q) ∨ r ⇔ p ∨ (q ∨ r)<br>(p ∧ q) ∧ r ⇔ p ∧ (q ∧ r)             |
| Distributive Law     | p ∧ (q ∨ C) ⇔ (p ∧ q) ∨ (p ∧ r)<br>p ∨ (q ∧ C) ⇔ (p ∨ q) ∧ (p ∨ r) |
| De Morgan's Law      | ¬(p ∧ q) ⇔ ¬p ∨ ¬q<br>¬(p ∨ q) ⇔ ¬p ∧ ¬q                            |

Here is the SQL to build the truth table.  Once we establish the truth table, we can then use SQL proofs to prove these laws are correct, or maybe a better statement is that we can prove that our SQL statement has implemented these laws correctly.

INSERT SQL TABLE HERE





