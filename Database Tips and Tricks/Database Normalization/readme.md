
# Database Normalization Scripts 

In this repository, you'll find several scripts for determining various attributes of a relation, including:

1) Super Keys
2) Minimal Super Keys
3) Candidate Keys
4) Prime and Non-Prime Attributes 
5) Dependents and Determinants
6) Trivial, Non-Trivial and Semi-Trivial Dependencies
7) Partial and Functional Dependencies

From these attributes, you can make deductions about 2NF, 3NF, BCNF, 4NF, 5NF.

## Overview

There are five scripts in this repository, and I break each one down into its own markup file for easy explanation.   

1) `Part 1 Create Normalization Base Table`
2) `Part 2 Determine Super Keys`
3) `Part 3 Determine Trivial Dependencies`
4) `Part 4 Determine Functional Dependencies`
5) `Part 5 List Partial and Functional Dependencies` 

:book:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For documentation for each of these scripts, please review the relevant markdowns in the directory named Handbook.

## Installation

The first script gives the user the ability to choose from several datasets that I have copied from the Wikipedia articles on normalization.  You can create your own dataset with the table name `NormalizationTest`.

:exclamation:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;These scripts use brute force to determine the various keys!  The test data must include proper test data for the scripts to deduce these keys!

To get started, set the `@vRun` variable in `Part 1 Create Normalization Base Table`, and then simply run each script in succession.  

To ensure accuracy, I drop the tables for the current and future scripts to help prevent not running the scripts in the correct order.  You will see these `DROP TABLE` statements at the beginning of each script.

--------------------------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc. please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!

