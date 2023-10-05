/*********************************************************************
Scott Peters
Four Vehicles Puzzle
https://advancedsqlpuzzles.com
Last Updated: 02/07/2023
Microsoft SQL Server T-SQL

This script solves the "Four Vehicles Puzzle", which is about assigning five children and five adults to four 
different vehicles (Motorcycle, Sidecar, Golf Cart, Car) with different seating capacities (1, 2, 3, 4).
The script starts by dropping and creating several tables, one of which is the #Passengers table, which 
stores information about the passengers (name and type). The script then populates the #Passengers table 
with five children and five adults.  The script then creates four additional tables (#Motorcycle, #Sidecar, #Golfcart, #Car) 
that are used to store the permutations of the passengers assigned to each vehicle. The script uses common 
table expressions (CTEs) and CROSS JOINs to generate all possible permutations of the passengers for each 
vehicle and stores them in the appropriate table. The script also uses CASE statements to treat reciprocals 
and sorts the passenger names alphabetically.  The final query uses a CROSS JOIN between the #Motorcycle, 
#Sidecar, #Golfcart, and #Car table to produce the final set of permutations. Each table is hardcoded 
to the number of seats in each vehicle, and the number of children and adults is also hardcoded in the script.

**********************************************************************/

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--Tables used
DROP TABLE IF EXISTS #Passengers
DROP TABLE IF EXISTS #Motorcycle
DROP TABLE IF EXISTS #Sidecar
DROP TABLE IF EXISTS #Golfcart
DROP TABLE IF EXISTS #Car
GO

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--Passengers
CREATE TABLE #Passengers
(
PassengerID INTEGER IDENTITY(1,1),
PassengerType VARCHAR(10),
PassengerName VARCHAR(10)
);

INSERT INTO #Passengers (PassengerType, PassengerName) VALUES
('Adult','Adult_1'),
('Adult','Adult_2'),
('Adult','Adult_3'),
('Adult','Adult_4'),
('Adult','Adult_5'),
('Child','Child_1'),
('Child','Child_2'),
('Child','Child_3'),
('Child','Child_4'),
('Child','Child_5');
GO

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--One seat Motorcycle
SELECT  'Motorcycle' AS VehicleType,
        PassengerName AS DriverName
INTO    #Motorcycle
FROM    #Passengers
WHERE   PassengerType = 'Adult';
GO

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--Two-seat sidecar
WITH
cte_drivers AS
(
SELECT  
        PassengerName AS DriverName
FROM    #Passengers
WHERE   PassengerType = 'Adult'
),
cte_permutations AS
(
SELECT  DriverName, PassengerName AS PassengerName_1
FROM    cte_drivers a CROSS JOIN
        #Passengers b
)
SELECT  'Sidecar' AS VehicleType,DriverName, PassengerName_1
INTO    #Sidecar
FROM    cte_permutations
WHERE   DriverName <> PassengerName_1;
GO

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--Three-seat golf cart
WITH
cte_drivers AS
(
SELECT  PassengerName AS DriverName
FROM    #Passengers
WHERE   PassengerType = 'Adult'
),
cte_permutations_1 AS
(
SELECT  DriverName, PassengerName AS PassengerName_1
FROM    cte_drivers a CROSS JOIN
        #Passengers b
),
cte_permutations_2 AS
(
SELECT  a.DriverName, 
        a.PassengerName_1, 
        b.PassengerName AS PassengerName_2
FROM    cte_permutations_1 a CROSS JOIN
        #Passengers b
),
cte_predicatelogic AS
(
SELECT  DriverName, PassengerName_1, PassengerName_2
FROM    cte_permutations_2
WHERE   DriverName <> PassengerName_1
        AND
        DriverName <> PassengerName_2
        AND
        PassengerName_1 <> PassengerName_2
)
SELECT  DISTINCT
        'Golf Cart' AS VehicleType,
        a.DriverName
        ,(CASE WHEN PassengerName_1 < PassengerName_2 THEN PassengerName_1 ELSE PassengerName_2 END) AS PassengerName_1
        ,(CASE WHEN a.PassengerName_1 < a.PassengerName_2 THEN a.PassengerName_2 ELSE a.PassengerName_1 END) AS PassengerName_2
INTO    #Golfcart
FROM    cte_predicatelogic a;
GO

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--Four-seat car
WITH
cte_drivers AS
(
SELECT  PassengerName AS DriverName
FROM    #passengers
WHERE   passengerType = 'Adult'
),
cte_permutations_1 AS
(
SELECT  DriverName, PassengerName AS PassengerName_1
FROM    cte_drivers a CROSS JOIN
        #Passengers b
),
cte_permutations_2 AS
(
SELECT  a.DriverName, 
        a.PassengerName_1, 
        b.PassengerName AS PassengerName_2
FROM    cte_permutations_1 a CROSS JOIN
        #Passengers b
),
cte_permutations_3 AS
(
SELECT  a.DriverName,
        a.PassengerName_1,
        a.PassengerName_2, 
        b.PassengerName AS PassengerName_3
FROM    cte_permutations_2 a CROSS JOIN
        #Passengers b
),
cte_pedicatelogic AS
(
SELECT  DriverName, PassengerName_1, PassengerName_2, PassengerName_3
FROM    cte_permutations_3
WHERE   DriverName <> PassengerName_1
        AND
        DriverName <> PassengerName_2
        AND
        DriverName <> PassengerName_3
        AND
        PassengerName_1 <> PassengerName_2
        AND
        PassengerName_1 <> PassengerName_3
        AND
        PassengerName_2 <> PassengerName_3
)
--Because seat order is not important we remove the reciprocals via the below case statement
SELECT  
        DISTINCT
        'Car' AS VehicleType,
        a.DriverName
        ----------------------------------------------------------
        ,(CASE  WHEN    PassengerName_1 < PassengerName_2 AND
                        PassengerName_1 < PassengerName_3
                THEN    PassengerName_1
                WHEN    PassengerName_2 < PassengerName_3
                THEN    PassengerName_2
                ELSE    PassengerName_3
            END) AS PassengerName_1
        ----------------------------------------------------------
        ,(CASE  WHEN    (PassengerName_1 < PassengerName_2 AND
                        PassengerName_1 > PassengerName_3)
                        OR
                        (PassengerName_1 < PassengerName_3 AND
                        PassengerName_1 > PassengerName_2)
                THEN    PassengerName_1             
                WHEN    (PassengerName_2 > PassengerName_1 AND
                        PassengerName_2 < PassengerName_3)
                        OR
                        (PassengerName_2 > PassengerName_3 AND
                        PassengerName_2 < PassengerName_1)
                THEN    PassengerName_2
                ELSE    PassengerName_3
            END) AS PassengerName_2
        ----------------------------------------------------------
        ,(CASE  WHEN    (PassengerName_1 > PassengerName_2 AND
                        PassengerName_1 > PassengerName_3)
                THEN    PassengerName_1
                WHEN    PassengerName_2 > PassengerName_3
                THEN    PassengerName_2
                ELSE    PassengerName_3
            END) AS PassengerName_3
INTO    #Car
FROM    cte_pedicatelogic a
GO

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--The following creates the predicate logic that I copy and paste into the next query
/*
;WITH cte_predicate_permutations AS
(
------------
SELECT  'MotorCycleDriverName' AS FieldName
------------
UNION
SELECT  'SideCarDriverName'
UNION
SELECT  'SideCarPassengerName_1'
------------
UNION
SELECT  'GolfcartDriverName'
UNION
SELECT  'GolfcartPassengerName_1'
UNION
SELECT  'GolfcartPassengerName_2'
------------
UNION
SELECT  'CarDriverName'
UNION
SELECT  'CarPassengerName_1'
UNION
SELECT  'CarPassengerName_2'
UNION
SELECT  'CarPassengerName_3'
)
SELECT  CONCAT(a.FieldName, ' <> ', b.FieldName, ' AND') 
FROM    cte_predicate_permutations a CROSS JOIN
        cte_predicate_permutations b
WHERE   a.FieldName <> b.FieldName
ORDER BY a.FieldName, b.FieldName
GO
*/

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--Display the results
WITH cte_dataset AS
(
SELECT  --'Motorcycle ---->' AS x1,
        a.VehicleType AS MotorCycle,
        a.DriverName AS MotorcycleDriverName,
        --'Sidecar ---->' AS x2,
        b.VehicleType AS Sidecar,
        b.DriverName AS SidecarDriverName,
        b.PassengerName_1 AS SidecarPassengerName_1,
        --'Golf Cart ---->' AS x3,
        c.VehicleType AS Golfcart,
        c.DriverName AS GolfcartDriverName,
        c.PassengerName_1 AS GolfCartPassengerName_1,
        c.PassengerName_2 AS GolfCartPassengerName_2,
        --'Car ---->' AS x4,
        d.VehicleType AS Car,
        d.DriverName AS CarDriverName,
        d.PassengerName_1 AS CarPassengerName_1,
        d.PassengerName_2 AS CarPassengerName_2,
        d.PassengerName_3 AS CarPassengerName_3
FROM    #Motorcycle a CROSS JOIN
        #Sidecar b CROSS JOIN
        #Golfcart c CROSS JOIN
        #Car d
)
SELECT  DISTINCT *
FROM    cte_dataset
WHERE
--Below is copied and pasted from the above commented-out query
CarDriverName <> CarPassengerName_1 AND
CarDriverName <> CarPassengerName_2 AND
CarDriverName <> CarPassengerName_3 AND
CarDriverName <> GolfcartDriverName AND
CarDriverName <> GolfcartPassengerName_1 AND
CarDriverName <> GolfcartPassengerName_2 AND
CarDriverName <> MotorCycleDriverName AND
CarDriverName <> SideCarDriverName AND
CarDriverName <> SideCarPassengerName_1 AND
CarPassengerName_1 <> CarDriverName AND
CarPassengerName_1 <> CarPassengerName_2 AND
CarPassengerName_1 <> CarPassengerName_3 AND
CarPassengerName_1 <> GolfcartDriverName AND
CarPassengerName_1 <> GolfcartPassengerName_1 AND
CarPassengerName_1 <> GolfcartPassengerName_2 AND
CarPassengerName_1 <> MotorCycleDriverName AND
CarPassengerName_1 <> SideCarDriverName AND
CarPassengerName_1 <> SideCarPassengerName_1 AND
CarPassengerName_2 <> CarDriverName AND
CarPassengerName_2 <> CarPassengerName_1 AND
CarPassengerName_2 <> CarPassengerName_3 AND
CarPassengerName_2 <> GolfcartDriverName AND
CarPassengerName_2 <> GolfcartPassengerName_1 AND
CarPassengerName_2 <> GolfcartPassengerName_2 AND
CarPassengerName_2 <> MotorCycleDriverName AND
CarPassengerName_2 <> SideCarDriverName AND
CarPassengerName_2 <> SideCarPassengerName_1 AND
CarPassengerName_3 <> CarDriverName AND
CarPassengerName_3 <> CarPassengerName_1 AND
CarPassengerName_3 <> CarPassengerName_2 AND
CarPassengerName_3 <> GolfcartDriverName AND
CarPassengerName_3 <> GolfcartPassengerName_1 AND
CarPassengerName_3 <> GolfcartPassengerName_2 AND
CarPassengerName_3 <> MotorCycleDriverName AND
CarPassengerName_3 <> SideCarDriverName AND
CarPassengerName_3 <> SideCarPassengerName_1 AND
GolfcartDriverName <> CarDriverName AND
GolfcartDriverName <> CarPassengerName_1 AND
GolfcartDriverName <> CarPassengerName_2 AND
GolfcartDriverName <> CarPassengerName_3 AND
GolfcartDriverName <> GolfcartPassengerName_1 AND
GolfcartDriverName <> GolfcartPassengerName_2 AND
GolfcartDriverName <> MotorCycleDriverName AND
GolfcartDriverName <> SideCarDriverName AND
GolfcartDriverName <> SideCarPassengerName_1 AND
GolfcartPassengerName_1 <> CarDriverName AND
GolfcartPassengerName_1 <> CarPassengerName_1 AND
GolfcartPassengerName_1 <> CarPassengerName_2 AND
GolfcartPassengerName_1 <> CarPassengerName_3 AND
GolfcartPassengerName_1 <> GolfcartDriverName AND
GolfcartPassengerName_1 <> GolfcartPassengerName_2 AND
GolfcartPassengerName_1 <> MotorCycleDriverName AND
GolfcartPassengerName_1 <> SideCarDriverName AND
GolfcartPassengerName_1 <> SideCarPassengerName_1 AND
GolfcartPassengerName_2 <> CarDriverName AND
GolfcartPassengerName_2 <> CarPassengerName_1 AND
GolfcartPassengerName_2 <> CarPassengerName_2 AND
GolfcartPassengerName_2 <> CarPassengerName_3 AND
GolfcartPassengerName_2 <> GolfcartDriverName AND
GolfcartPassengerName_2 <> GolfcartPassengerName_1 AND
GolfcartPassengerName_2 <> MotorCycleDriverName AND
GolfcartPassengerName_2 <> SideCarDriverName AND
GolfcartPassengerName_2 <> SideCarPassengerName_1 AND
MotorCycleDriverName <> CarDriverName AND
MotorCycleDriverName <> CarPassengerName_1 AND
MotorCycleDriverName <> CarPassengerName_2 AND
MotorCycleDriverName <> CarPassengerName_3 AND
MotorCycleDriverName <> GolfcartDriverName AND
MotorCycleDriverName <> GolfcartPassengerName_1 AND
MotorCycleDriverName <> GolfcartPassengerName_2 AND
MotorCycleDriverName <> SideCarDriverName AND
MotorCycleDriverName <> SideCarPassengerName_1 AND
SideCarDriverName <> CarDriverName AND
SideCarDriverName <> CarPassengerName_1 AND
SideCarDriverName <> CarPassengerName_2 AND
SideCarDriverName <> CarPassengerName_3 AND
SideCarDriverName <> GolfcartDriverName AND
SideCarDriverName <> GolfcartPassengerName_1 AND
SideCarDriverName <> GolfcartPassengerName_2 AND
SideCarDriverName <> MotorCycleDriverName AND
SideCarDriverName <> SideCarPassengerName_1 AND
SideCarPassengerName_1 <> CarDriverName AND
SideCarPassengerName_1 <> CarPassengerName_1 AND
SideCarPassengerName_1 <> CarPassengerName_2 AND
SideCarPassengerName_1 <> CarPassengerName_3 AND
SideCarPassengerName_1 <> GolfcartDriverName AND
SideCarPassengerName_1 <> GolfcartPassengerName_1 AND
SideCarPassengerName_1 <> GolfcartPassengerName_2 AND
SideCarPassengerName_1 <> MotorCycleDriverName AND
SideCarPassengerName_1 <> SideCarDriverName;
GO
