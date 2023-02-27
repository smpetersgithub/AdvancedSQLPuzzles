# Part 1: Create Normalization Tables

This script creates gives the user the option of several test datasets to experiment with.  These datasets are based upon the Wiki articles on normalization forms, where I include additional records to force the data to understand primary keys.

Simply set the variable `@vRun`.

*  [Second Normal Form](https://en.wikipedia.org/wiki/Second_normal_form)
*  [Third Normal Form](https://en.wikipedia.org/wiki/Third_normal_form)
*  [Boyce Codd Normal Form](https://en.wikipedia.org/wiki/Boyce%E2%80%93Codd_normal_form)
*  [Fourth Normal Form](https://en.wikipedia.org/wiki/Fourth_normal_form)
*  [Fifth Normal Form](https://en.wikipedia.org/wiki/Fifth_normal_form)

Note:
*  Second, third, and Boyce–Codd normal forms are concerned with functional dependencies, 4NF is concerned with a more general type of dependency known as a multivalued dependency.
*  Fifth normal form is designed to remove redundancy in relational databases recording multi-valued facts by isolating semantically related multiple relationships.

:exclamation:  In the following script, I do not state which exact normal forms the provided datasets exists in.  Rather, I state all the different keys, dependents and determinants, prime and non prime attributes, trivial dependencies, and functional dependencies.

-----------

### Option 1    

This example is from the Wikipedia article on second normal form.

https://en.wikipedia.org/wiki/Second_normal_form

`DECLARE @vRun INTEGER = 1;`    

| Manufacturer |    Model    | Country |
|--------------|-------------|---------|
| Forte        | X-Prime     | Italy   |
| Forte        | Ultraclean  | Italy   |
| Dent-o-Fresh | EZbrush     | USA     |
| Brushmaster  | SuperBrush  | USA     |
| Kobayashi    | ST-60       | Japan   |
| Hoch         | Toothmaster | Germany |
| Hoch         | X-Prime     | Germany |
| Test         | X-Prime     | Germany |

------------------------------

### Option 2

This example is from the Wikipedia article on third normal form.

`DECLARE @vRun INTEGER = 2;`   


| Tournament | Year | Winner |        DOB        |
|------------|------|--------|-------------------|
| Event A    | 1998 |   1001 | 21 July 1975      |
| Event A    | 1999 |   2002 | 14 March 1977     |
| Event A    | 2000 |   2002 | 14 March 1977     |
| Event B    | 1998 |   3003 | 28 September 1968 |
| Event B    | 1999 |   3003 | 28 September 1968 |
| Event B    | 2000 |   1001 | 21 July 1975      |
| Event C    | 1998 |   1001 | 21 July 1975      |
| Event C    | 1999 |   2002 | 14 March 1977     |
| Event C    | 2000 |   4004 | 21 July 1975      |

------------------------------

### Option 3

This example is the same as Option 2, but with an `ID` column added.

`DECLARE @vRun INTEGER = 3;`

:exclamation: I often characterize database normalization as an instructive demonstration of common mistakes because the examples include obviouse mistakes, such as not including an Identity column. This example shows how adding an `ID` column changes the different possibile keys.


| ID | Tournament | Year | Winner |        DOB        |
|----|------------|------|--------|-------------------|
|  1 | Event A    | 1998 |   1001 | 21 July 1975      |
|  2 | Event A    | 1999 |   2002 | 14 March 1977     |
|  3 | Event A    | 2000 |   2002 | 14 March 1977     |
|  4 | Event B    | 1998 |   3003 | 28 September 1968 |
|  5 | Event B    | 1999 |   3003 | 28 September 1968 |
|  6 | Event B    | 2000 |   1001 | 21 July 1975      |
|  7 | Event C    | 1998 |   1001 | 21 July 1975      |
|  8 | Event C    | 1999 |   2002 | 14 March 1977     |
|  9 | Event C    | 2000 |   4004 | 21 July 1975      |

------------------------------

### Option 4

This example is from the Wikipedia article on forth normal form.

`DECLARE @vRun INTEGER = 4;`


| Court |    StartTime     |     EndTime      | RateType  |
|-------|------------------|------------------|-----------|
|     1 | 09:30:00.0000000 | 10:30:00.0000000 | SAVER     |
|     1 | 11:00:00.0000000 | 12:00:00.0000000 | SAVER     |
|     1 | 14:00:00.0000000 | 15:30:00.0000000 | STANDARD  |
|     2 | 09:30:00.0000000 | 10:30:00.0000000 | PREMIUM-B |
|     2 | 11:30:00.0000000 | 13:30:00.0000000 | PREMIUM-B |
|     2 | 15:00:00.0000000 | 16:30:00.0000000 | PREMIUM-A |

------------------------------

### Option 5

This example is from the Wikipedia article on fifth normal form.

`DECLARE @vRun INTEGER = 5;`

|  Person  |  ShopType   |  NearestShop  |
|----------|-------------|---------------|
| Davidson | Optician    | Eagle Eye     |
| Davidson | Hairdresser | Snippets      |
| Wright   | Bookshop    | Merlin Books  |
| Fuller   | Bakery      | Doughys       |
| Fuller   | Hairdresser | Sweeney Todds |
| Fuller   | Optician    | Eagle Eye     |

