SET NOCOUNT ON;
GO

--------------------------------------------------
--Drop table for part 1
DROP TABLE IF EXISTS NormalizationTest;
GO

--Drop table for part 2
DROP TABLE IF EXISTS SuperKeys1_SysColumns;
DROP TABLE IF EXISTS SuperKeys2_Permutations;
DROP TABLE IF EXISTS SuperKeys3_DynamicSQL;
DROP TABLE IF EXISTS SuperKeys4_Final;
DROP TABLE IF EXISTS SuperKeys5_StringSplit;
DROP TABLE IF EXISTS SuperKeys6_CandidateKey;
DROP TABLE IF EXISTS SuperKeys7_NonPrime;
GO

--Drop table for part 3
DROP TABLE IF EXISTS Determinant_Dependent1_CrossJoin;
DROP TABLE IF EXISTS Determinant_Dependent2_StringSplit;
DROP TABLE IF EXISTS Determinant_Dependent3_SumPartOfDeterminant;
DROP TABLE IF EXISTS Determinant_Dependent4_TrivialDependency;
GO

--Drop table for part 4
DROP TABLE IF EXISTS Determinant_Dependent5_DynamicSQL1;
DROP TABLE IF EXISTS Determinant_Dependent6_DynamicSQL2;
DROP TABLE IF EXISTS Determinant_Dependent7_FunctionalDependency;
GO

--Drop table for part 5
DROP TABLE IF EXISTS PartialDependency;
DROP TABLE IF EXISTS FunctionalDependency;
GO

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--Set this variable!!
--Set this variable!!
--Set this variable!!
--Set this variable!!

DECLARE @vRun INTEGER = 5;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
IF @vRun = 1
BEGIN

CREATE TABLE NormalizationTest
(
Manufacturer VARCHAR(255) NOT NULL,
Model        VARCHAR(255) NOT NULL,
Country      VARCHAR(255) NOT NULL,
);

INSERT INTO NormalizationTest VALUES
('Forte','X-Prime','Italy'),
('Forte','Ultraclean','Italy'),
('Dent-o-Fresh','EZbrush','USA'),
('Brushmaster','SuperBrush','USA'),
('Kobayashi','ST-60','Japan'),
('Hoch','Toothmaster','Germany'),
('Hoch','X-Prime','Germany'),
('Test','X-Prime','Germany');
;
END;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
IF @vRun = 2
BEGIN

CREATE TABLE NormalizationTest
(
Tournament VARCHAR(255) NOT NULL,
Year       INTEGER NOT NULL,
Winner     INTEGER NOT NULL,
DOB        VARCHAR(255) NOT NULL,
);

INSERT INTO NormalizationTest VALUES
('Event A', 1998, 1001, '21 July 1975'),
('Event A', 1999, 2002, '14 March 1977'),
('Event A', 2000, 2002, '14 March 1977'),

('Event B', 1998, 3003, '28 September 1968'),
('Event B', 1999, 3003, '28 September 1968'),
('Event B', 2000, 1001, '21 July 1975'),

('Event C', 1998, 1001, '21 July 1975'),
('Event C', 1999, 2002, '14 March 1977'),
('Event C', 2000, 4004, '21 July 1975');
END;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
IF @vRun = 3

BEGIN
CREATE TABLE NormalizationTest
(
ID         INTEGER NOT NULL,
Tournament VARCHAR(255) NOT NULL,
Year       INTEGER NOT NULL,
Winner     INTEGER NOT NULL,
DOB        VARCHAR(255) NOT NULL,
);

INSERT INTO NormalizationTest VALUES
(1,'Event A', 1998, 1001, '21 July 1975'),
(2,'Event A', 1999, 2002, '14 March 1977'),
(3,'Event A', 2000, 2002, '14 March 1977'),
(4,'Event B', 1998, 3003, '28 September 1968'),
(5,'Event B', 1999, 3003, '28 September 1968'),
(6,'Event B', 2000, 1001, '21 July 1975'),
(7,'Event C', 1998, 1001, '21 July 1975'),
(8,'Event C', 1999, 2002, '14 March 1977'),
(9,'Event C', 2000, 4004, '21 July 1975');
END;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
IF @vRun = 4

BEGIN

CREATE TABLE NormalizationTest (
Court      INT NOT NULL,
StartTime TIME,
EndTime   TIME,
RateType  VARCHAR(20)
);

INSERT INTO NormalizationTest (Court, StartTime, EndTime, RateType) VALUES
(1, '09:30:00', '10:30:00', 'SAVER'),
(1, '11:00:00', '12:00:00', 'SAVER'),
(1, '14:00:00', '15:30:00', 'STANDARD'),
(2, '09:30:00', '10:30:00', 'PREMIUM-B'),
(2, '11:30:00', '13:30:00', 'PREMIUM-B'),
(2, '15:00:00', '16:30:00', 'PREMIUM-A');
END;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
IF @vRun = 5

BEGIN

CREATE TABLE NormalizationTest (
    Person VARCHAR(50),
    ShopType VARCHAR(50),
    NearestShop VARCHAR(50)
);

INSERT INTO NormalizationTest (Person, ShopType, NearestShop)
VALUES
    ('Davidson', 'Optician', 'Eagle Eye'),
    ('Davidson', 'Hairdresser', 'Snippets'),
    ('Wright', 'Bookshop', 'Merlin Books'),
    ('Fuller', 'Bakery', 'Doughys'),
    ('Fuller', 'Hairdresser', 'Sweeney Todds'),
    ('Fuller', 'Optician', 'Eagle Eye');

END;
GO
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
SELECT  *
FROM    NormalizationTest;
GO
