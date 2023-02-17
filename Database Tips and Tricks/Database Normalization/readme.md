

## Part 1
Creates the table `NormalizationTest`

----------------------------------

### 1 is in Second Normal Form but not in Third Normal Form

https://en.wikipedia.org/wiki/Second_normal_form

I have added the last three lines to force the table into 2NF.


|                   Tournament                    | Year |     Winner     |        DOB        |
|-------------------------------------------------|------|----------------|-------------------|
| Indiana Invitational                            | 1998 | Al Fredrickson | 21 July 1975      |
| Cleveland Open                                  | 1999 | Bob Albertson  | 28 September 1968 |
| Des Moines Masters                              | 1999 | Al Fredrickson | 21 July 1975      |
| Indiana Invitational                            | 1999 | Chip Masterson | 14 March 1977     |
| Indiana Invitational                            | 2000 | Chip Masterson | 14 March 1977     |
| Putt Pirate Classic                             | 2000 | Chip Masterson | 14 March 1977     |
| Springfield Dirty Birdie Mini Gulf Invitational | 2000 | Buzz Lightyear | 24 January 1943   |
| Springfield Dirty Birdie Mini Gulf Invitational | 2001 | Chip Masterson | 14 March 1977     |



### 2 is in First Normal Form but not in 3rd Normal Form.

| Manufacturer |    Model    | Country |
|--------------|-------------|---------|
| Forte        | X-Prime     | Italy   |
| Forte        | Ultraclean  | Italy   |
| Dent-o-Fresh | EZbrush     | USA     |
| Brushmaster  | SuperBrush  | USA     |
| Kobayashi    | ST-60       | Japan   |
| Hoch         | Toothmaster | Germany |
| Hoch         | X-Prime     | Germany |



### 3 is the same as 1 but has an ID column added

| ID |                   Tournament                    | Year |     Winner     |        DOB        |
|----|-------------------------------------------------|------|----------------|-------------------|
|  1 | Indiana Invitational                            | 1998 | Al Fredrickson | 21 July 1975      |
|  2 | Cleveland Open                                  | 1999 | Bob Albertson  | 28 September 1968 |
|  3 | Des Moines Masters                              | 1999 | Al Fredrickson | 21 July 1975      |
|  4 | Indiana Invitational                            | 1999 | Chip Masterson | 14 March 1977     |
|  5 | Indiana Invitational                            | 2000 | Chip Masterson | 14 March 1977     |
|  6 | Putt Pirate Classic                             | 2000 | Chip Masterson | 14 March 1977     |
|  7 | Springfield Dirty Birdie Mini Gulf Invitational | 2000 | Buzz Lightyear | 24 January 1943   |
|  8 | Springfield Dirty Birdie Mini Gulf Invitational | 2001 | Chip Masterson | 14 March 1977     |



