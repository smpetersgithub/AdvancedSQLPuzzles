# Sample Data

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For the following examples you will need to understand the behavior of NULL markers.  I’ve provided some rather simple tables with minimal records.  I've also included a few NULL markers so we can understand how the varoius joins treat this special case.

**Table A**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  |       17 |
|  2 | Peach  |       20 |
|  3 | Mango  |       11 |
|  4 | <NULL> |        5 |
  
**Table B**
| ID | Fruit  | Quantity |
|----|--------|----------|
|  1 | Apple  | 17       |
|  2 | Peach  | 25       |
|  3 | Kiwi   | 20       |
|  4 | <NULL> | <NULL>   |
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In some statements the example data may not be sufficient.  Feel free to add your own data and experiment with the outcomes.

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

https://advancedsqlpuzzles.com
