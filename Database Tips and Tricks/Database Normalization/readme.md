# Welcome 

In this part of my GitHub I have several scripts to determine the following attributes of a dataset:

1) Super Keys
2) Minimal Super Keys
3) Candidate Keys
4) Prime and Non-Prime Attributes 
5) Dependents and Determinants
6) Trivial, Non-Trivial and Semi-Trivial Dependencies 
7) Partial and Functional Dependencies


## Overview    

There are five sripts in this repository, and I break each one down into its own markup file for easy explanation.   

The five scripts are:    
1) Part 1 Create Normalization Base Table
2) Part 2 Determine Super Keys
3) Part 3 Determine Trivial Dependencies
4) Part 4 Determine Functional Dependencies
5) Part 5 List Partial and Functional Dependencies 


## Installation

The first script gives the user the ability to choose from several datasets that I have copied from the Wikipedia articles on normalization.  These scripts use brute force to determine the various keys, so the test data must include enough information for the scripts to deduce these keys.

To get started, set the `DECLARE @vRun INTEGER = 1;` in Part 1 Create Normalization Base Table, and then simply run each script in succession.  To ensure accuracy, I `DROP` the tables for the current and future scripts in order to help prevent not running the scripts in full or jumping over a script
