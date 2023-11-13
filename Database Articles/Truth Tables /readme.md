# Creating Truth Tables Using SQL

This exploration delves into the unique intersection of propositional logic and SQL, showcasing how truth tables can be effectively created using SQL.

| p | q | p ∧ q | p ∨ q | ¬p | ¬(¬p) |
|---|---|-------|-------|----|-------|
| 1 | 1 | 1     | 1     | 0  | 1     |
| 1 | 0 | 0     | 1     | 0  | 1     |
| 0 | 1 | 0     | 1     | 1  | 0     |
| 0 | 0 | 0     | 0     | 1  | 0     |

A truth table is a mathematical table utilized in logic, particularly relevant to Boolean algebra, Boolean functions, and propositional calculus. This table methodically displays the output values of logical expressions based on various combinations of input values (True or False) assigned to their logical variables. Moreover, truth tables serve as a tool to determine if a given propositional expression consistently yields a true outcome across all possible legitimate input values, thereby establishing its logical validity.

This article is not meant to be a lesson in propositional logic but simply an exploration of how to create truth tables using SQL.  If you are unfamiliar with propositional logic, I recommend taking a discrete mathematics course to understand the principles.

Additionally, before we begin, a few tidbits of SQL should be mentioned.  

•	SQL is based on relational algebra and relational calculus.  Although SQL is rooted in predicate logic, it is not based on propositional calculus.

•	SQL includes the possibility of NULL markers when creating predicate logic statements.   Propositional logic does not incorporate the concept of NULL markers into its paradigm.  We will be ignoring the concept of NULL markers entirely for this article.

•	We will be using the Boolean data type of BIT.  The BIT data type in SQL is not an accurate Boolean representation, as it has three possible values: True, False, and NULL.  Many SQL experts recommend not to use the BIT data type because of this.  Also, using the BIT data type, where True is 1 and False is 0, allows us to create mathematical expressions that we can use to resolve truths.   

! To learn more about NULL markers and their effect on predicate logic, check out my article Behavior of NULLS here.

Now, let’s dive into truth tables and propositional statements.

A propositional statement is a statement that can be either true or false.  Often, we think of propositional statements in terms of English statements, such as: “When it is sunny, I wear my sunglasses”.  However, we often use a more generic form in discrete math and don’t assign statements to each proposition variable. The variables most used are P, R, and Q for English statements, and lowercase p, q, and r are used for generic statements.

In our example above, we would assign the uppercase P to “It is sunny” and the uppercase Q to “I wear my sunglasses.  We then would have a conditional statement of “P when Q”, or P -> Q.

! As mentioned earlier, a discrete mathematics course is highly recommended if you are unfamiliar with propositional logic.

Like any branch of mathematics, a set of symbols and terms needs to be defined.  Here is a summary of the different symbols and terms and examples of how they are used in everyday English statements. 

| Logical Operation       | Symbol | ASCII  |   English Language Usage     |
|-------------------------|--------|--------|------------------------------|
| Negation (NOT)          | ¬      | ~ or ! | Not p                        |
| Conjunction (AND)       | ∧      | &      | p and q                      |
| Disjunction (OR)        | ∨      | |      | p or q                       |
| Implication (IF...THEN) | →      | ->     | If p, then q                 |
| Biconditional (IFF)     | ↔      | <->    | p if and only if q           |
| Tautology (True)        | ⊤      | T      | Always True                  |
| Contradiction (False)   | ⊥      | F      | Always False                 |
| Exclusive Or (XOR)      | ⊕     | ^      | Either p or q, but not both  |
| Logical Equivalant      | ⇔     | =      | 2+3 is the equivalant of 4+1 |

Now that we have this out of the way, let’s build the following truth table.


