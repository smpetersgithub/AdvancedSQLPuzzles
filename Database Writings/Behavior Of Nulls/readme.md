### Behavior of Nulls

Because NULL markers represent the absence of a value, NULL markers can be a source of much confusion and trouble for developers.  Becaue of this, I decided to create a document on how all the different SQL constructs treat the NULL marker.

----

To best understand NULL markers, one must understand the three-valued logic of true, false, or unknown, and recognize how NULL markers are treated within the different constructs of the SQL language. The join syntax will treat NULL markers differently than set operators, and a unique constraint will treat a NULL marker differently than a primary key constraint. 

Because NULL markers do not represent a value, SQL has two conditions specific to the SQL language: 
* IS NULL 
* IS NOT NULL 

SQL also provides three functions to evaluate NULL markers: 
* NULLIF 
* ISNULL 
* COALESCE 

When working with predicate logic, it is important to understand SQL truth tables and how the NULL markers are treated different with AND, OR and NOT operators.  

**And**
   A   |   B   | A AND B 
 ------|-------|--------- 
  TRUE  | TRUE  | TRUE    
  TRUE  | FALSE | FALSE   
  FALSE | TRUE  | FALSE   
  FALSE | FALSE | FALSE   
  TRUE  | NULL  | NULL    
  FALSE | NULL  | FALSE   

**OR**  
|    A   |   B   | A OR B 
| -------|-------|-------- 
|  TRUE  | TRUE  | TRUE   
|  TRUE  | FALSE | TRUE   
|  FALSE | TRUE  | TRUE   
|  FALSE | FALSE | FALSE  
|  TRUE  | NULL  | TRUE   
|  FALSE | NULL  | NULL   
|  NULL  | NULL  | NULL   

**NOT**
  A     | NOT A 
 -------|------- 
  TRUE  | FALSE 
  FALSE | TRUE  
  NULL  | NULL  

Check out the PDF file for this and more....
