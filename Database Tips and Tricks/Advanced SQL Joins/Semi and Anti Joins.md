## Semi and Anti-Joins

Semi and Anti joins are two closely related joins.

The term "semi", meaning half in quantity or value, refers to the fact that it only returns a subset or a half of the data from the joined tables. Specifically, semi-joins only returns the rows from the first table (the left table) that have matching values in the second table (the right table). The columns of the right table are not included in the projection.

The opposite are anti-joins act the very same as semi-joins but only return the rows from the firsts table that do not have matching values in the second table.

---

For a join to be considered a semi or anti-join it must have the following three qualities:

1)	The join cannot create duplicate rows from the outer table.
2)	The joining table cannot be used in the queries projection (SELECT statement).
3)	The join predicate looks for equality (=) or in-equality (<>) and not a range (<, >, etc.).

---

Anti-joins use the NOT IN or NOT EXISTS operators.  Semi-joins use the IN or EXISTS operators.

There are several benefits of using anti-joins and semi-joins over INNER joins:

1.	Semi-joins and anti-joins remove the risk of returning duplicate rows.
2.	Semi-joins and anti-joins increase readability as the result set can only contain the columns from the outer semi-joined table.

---
There are several key differences between semi-joins and anti-joins:
1.	The NOT IN operator will return an empty set if the anti-join contains a NULL marker.  The NOT EXISTS will return a dataset that contains a NULL marker if the anti-join contains a NULL marker.
2.	The IN and EXIST operators will return a dataset if the semi-join contains a NULL marker.
3.	The NOT EXISTS and EXIST operators can join on multiple columns between the outer and inner SQL statements.  The NOT IN or IN operators join on only one single field.

If you are performing an anti-join to a NULLable column, consider using the NOT EXISTS operator over the NOT operator.

---

### Anti-Joins

This statement returns an empty dataset as the NOT IN operator will return an empty set if the anti-join contains a NULL marker.

```sql
SELECT	Fruit
FROM	##TableA
WHERE	Fruit NOT IN (SELECT Fruit FROM ##TableB);
```
<<Empty Data Set>>

