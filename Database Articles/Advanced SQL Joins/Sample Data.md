# Sample Data

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For the following examples you will need to understand the behavior of NULL markers.  I’ve provided some rather simple tables with minimal records.  I've also included a few NULL markers to understand how the various joins treat this particular case.

**Table A**
| ID |  Fruit  | Quantity |
|----|---------|----------|
|  1 | Apple   |       17 |
|  2 | Peach   |       20 |
|  3 | Mango   |       11 |
|  4 | \<NULL> |        5 |
  
**Table B**
| ID |  Fruit  | Quantity |
|----|---------|----------|
|  1 | Apple   | 17       |
|  2 | Peach   | 25       |
|  3 | Kiwi    | 20       |
|  4 | \<NULL> | \<NULL>  |
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In some statements, the example data may not be sufficient.  Feel free to add your own data and experiment with the outcomes.

```sql
------------------------
--Create Sample Tables--
------------------------

DROP TABLE IF EXISTS ##TableA;
DROP TABLE IF EXISTS ##TableB;

CREATE TABLE ##TableA
(
ID          INTEGER NOT NULL PRIMARY KEY,
Fruit       VARCHAR(10) NULL UNIQUE,
Quantity    INTEGER
);

CREATE TABLE ##TableB
(
ID          INTEGER NOT NULL PRIMARY KEY,
Fruit       VARCHAR(10) NULL UNIQUE,
Quantity    INTEGER
);

INSERT INTO ##TableA VALUES (1,'Apple',17);
INSERT INTO ##TableA VALUES (2,'Peach',20);
INSERT INTO ##TableA VALUES (3,'Mango',11);
INSERT INTO ##TableA VALUES (4,NULL,5);

INSERT INTO ##TableB VALUES (1,'Apple',17);
INSERT INTO ##TableB VALUES (2,'Peach',25);
INSERT INTO ##TableB VALUES (3,'Kiwi',20);
INSERT INTO ##TableB VALUES (4,NULL,NULL);
```
  
----------------------------  

1. [Introduction](01%20-%20Introduction.md)
2. [SQL Processing Order](02%20-%20SQL%20Query%20Processing%20Order.md)
3. [Table Types](03%20-%20Table%20Types.md)
4. [Equi, Theta, and Natural Joins](04%20-%20Equi%2C%20Theta%2C%20and%20Natural%20Joins.md)
5. [Inner Joins](05%20-%20Inner%20Join.md)
6. [Outer Joins](06%20-%20Outer%20Joins.md)
7. [Full Outer Joins](07%20-%20Full%20Outer%20Join.md)
8. [Cross Joins](08%20-%20Cross%20Join.md)
9. [Semi and Anti Joins](09%20-%20Semi%20and%20Anti%20Joins.md)
10. [Any, All, and Some](10%20-%20Any%2C%20All%2C%20and%20Some.md)
11. [Self Joins](11%20-%20Self%20Join.md)
12. [Relational Division](12%20-%20Relational%20Division.md)
13. [Set Operations](13%20-%20Set%20Operations.md)
14. [Join Algorithms](14%20-%20Join%20Algorithms.md)
15. [Exists](15%20-%20Exists.md)
16. [Complex Joins](16%20-%20Complex%20Joins.md)
  
https://advancedsqlpuzzles.com
