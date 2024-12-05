/*------------------------------------------------------------------------------------------------------------------

To run in sqlcmd select the following from the menu bar: Query -> sqlmode

The script 19_Contracts_and_Queues_and_Message_Types.sql must be executed separately because it requires an 
exclusive connection to the database.

Ensure that no other connections are active when running this script to avoid conflicts or execution errors.

------------------------------------------------------------------------------------------------------------------*/

SET NOCOUNT ON;
GO


PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(1)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\01_Cross_Database_Dependencies.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\01_Cross_Database_Dependencies.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(2)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\02_Cross_Schema_Dependencies.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\02_Cross_Schema_Dependencies.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(3)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\03_Invalid_Stored_Procedures.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\03_Invalid_Stored_Procedures.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(4)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\04_Numbered_Stored_Procedures.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\04_Numbered_Stored_Procedures.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(5)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\05_Ambiguous_References.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\05_Ambiguous_References.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(6)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\06_Part_Naming_Conventions.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\06_Part_Naming_Conventions.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(7)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\07_Part_Naming_Conventions_Caller_Dependent.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\07_Part_Naming_Conventions_Caller_Dependent.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(8)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\08_Dropping_Objects.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\08_Dropping_Objects.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(9)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\09_Dropping_Objects_Then_Recreating.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\09_Dropping_Objects_Then_Recreating.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(10)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\10_Self_Referencing_Objects.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\10_Self_Referencing_Objects.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(11)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\11_Object_Aliases.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\11_Object_Aliases.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(12)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\12_Schemabindings.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\12_Schemabindings.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(13)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\13_Synonyms.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\13_Synonyms.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(14)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\14_Triggers_DML.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\14_Triggers_DML.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(15)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\15_Triggers_DDL_Database_Level.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\15_Triggers_DDL_Database_Level.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(16)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\16_Triggers_DDL_Server_Level_Table_Insert.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\16_Triggers_DDL_Server_Level_Table_Insert.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(17)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\17_Partition_Functions.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\17_Partition_Functions.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(18)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\18_Defaults_and_Rules.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\18_Defaults_and_Rules.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
--PRINT(19)
--PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\19_Contracts_and_Queues_and_Message_Types.sql';
--GO
--:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\19_Contracts_and_Queues_and_Message_Types.sql"
--GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(20)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\20_Sequences.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\20_Sequences.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(21)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\21_User_Defined_Data_Types.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\21_User_Defined_Data_Types.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(22)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\22_User_Defined_Table_Types.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\22_User_Defined_Table_Types.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(23)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\23_Check_Constraints.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\23_Check_Constraints.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(24)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\24_Foreign_Key_Constraints.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\24_Foreign_Key_Constraints.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(25)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\25_Computed_Columns.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\25_Computed_Columns.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(26)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\26_Masked_Functions.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\26_Masked_Functions.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(27)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\27_Indexes_Table.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\27_Indexes_Table.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(28)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\28_Indexes_Filtered_NonClustered.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\28_Indexes_Filtered_NonClustered.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(29)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\29_Indexes_Filtered_XML.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\29_Indexes_Filtered_XML.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(30)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\30_Statistics_Filtered.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\30_Statistics_Filtered.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(31)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\31_XML_Schema_Collections.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\31_XML_Schema_Collections.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')
PRINT(32)
PRINT 'C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\32_XML_Methods.sql';
GO
:r "C:\AdvancedSQLPuzzles-main\Database Articles\Database Dependencies\SQL Scripts\32_XML_Methods.sql"
GO
PRINT('------------------------------------------------------------------------------------------------------------------')