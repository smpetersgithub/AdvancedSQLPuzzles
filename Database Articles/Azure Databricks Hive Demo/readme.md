# Databricks Spark Hive Demo

**https://advancedsqlpuzzles.com**

This directory contains a demo to understand how to connect Databricks to an Azure Data Lake and SQL Server.

:exclamation: This presentation was created in late 2021, and Microsoft Azure may have updated certain features and options. If any information in this presentation becomes outdated or needs to be updated, kindly notify me. Thank you!

## About

**In this demo, we will perform the following:**
1.  Connect Databricks to an Azure Key Vault
2.  Connect Databricks to an Azure Data Lake
3.  Create an ETL process to import CSV files from an Azure Data Lake
4.  Merge the data into Hive tables
5.  Insert the data into a SQL Server database
6.  Automate the ETL via an Azure Data Factory pipeline

## Getting Started

To get started, download the `Databricks Spark Hive Demo.pdf` and follow along with each slide.

In this directory, you will find the following files:

*  Sample text files (`Parts.txt`,`Shipments.txt`,`Suppliers.txt`) that we will import using Databricks.
*  The Databricks notebooks (`SuppliersAndParts.dbc`) that connect the Key Vault, Data Lake, SQL Server, etc., and perform the ETL.
*  The DDL statements (`SuppliersAndPartsDDL.sql`) to create the tables in SQL Server.

I've also included the PowerPoint presentation (`Databricks Spark Hive Demo PowerPoint.pptx`) that you can download and add notes or modify as needed.

---------------------------------------------

:mailbox:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you find any inaccuracies, misspellings, bugs, dead links, etc., please report an issue!  No detail is too small, and I appreciate all the help.

:smile:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Happy coding!
