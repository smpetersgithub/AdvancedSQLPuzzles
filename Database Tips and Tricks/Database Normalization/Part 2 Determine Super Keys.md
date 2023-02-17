This process determines all the Super Keys, Minimal Super Keys and Candidate Keys.

I have named the table with a prefix of "anf".  "a" for the first letter of the alphabet so they are sorted in the object viewer, and "nf" for normal form.

`anf_SuperKeys1_SysColumns`
`anf_SuperKeys2_Permutations`
`anf_SuperKeys3_DynamicSQL`
`anf_SuperKeys4_StringSplit`
`anf_SuperKeys5_CandidateKey`

Step 1
--anf_SuperKeys1_SysColumns
--From the system tables, determines all the columns in the table NormalizationTest

Step 2
--anf_SuperKeys2_Permutations
--Seed the anf_SuperKeys2_Permutations table by a simple insert from anf_SuperKeys1_SysColumns

Step 3
--anf_SuperKeys2_Permutations
--Loop through the table to determine all permuations of columns, but where column order is kept in alphabetical order.

Step 4
--anf_SuperKeys3_DynamicSQL
--Creates the SQL statements that need to be dynamically run
```sql
UPDATE anf_SuperKeys3_Final 
SET    RecordCount = (SELECT COUNT(DISTINCT <ColumnListConcat>)
                      FROM dbo.NormalizationTest) WHERE RowNumber = <vRowNumber>
```

Step 5
--anf_SuperKeys3_Final
--Create anf_SuperKeys3_Final from anf_SuperKeys3_DynamicSQL

Step 6
--anf_SuperKeys3_Final
--Using a cursor, loops through the SQL and updates the table anf_SuperKeys3_Final

Step 7
anf_SuperKeys3_Final
--Updates the IsSuperKey and IsMinimalSuperKey columns

Step 8
anf_SuperKeys4_StringSplit
This step uses the String Split function to determine the candidate keys.

Step 9
anf_SuperKeys5_CandidateKey
Determines the Candi
--------------
----Step 9----
--------------date Keys

Step 10
anf_SuperKeys5_Final

Updates the anf_SuperKeys5_Final table with the Candidate Keys.

In a relational database management system (RDBMS), the minimum superkeys are known as candidate keys.

A candidate key is a minimal set of attributes (or columns) that can uniquely identify each tuple (or row) in a relation (or table) without redundancy. In other words, a candidate key is a combination of one or more attributes that uniquely identifies each tuple in the relation.

A relation can have multiple candidate keys, but one of them is typically chosen to be the primary key of the relation, which is used to establish relationships with other tables and to enforce referential integrity constraints.



