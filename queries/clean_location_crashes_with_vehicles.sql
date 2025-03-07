WITH cleaned_vehicles AS (
    SELECT 
        COLLISION_ID,
        DRIVER_LICENSE_STATUS,
        UPPER(TRIM(VEHICLE_TYPE)) AS VEHICLE_TYPE,
        DRIVER_SEX,
        
        #This case query will sort the type of vehicles (ex: motorcycles, trucks, sedans, SUVs) together
        CASE 
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%SEDAN%' THEN 'Sedan'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%SPORT UTILITY%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%SUV%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%STATION WAGON%' THEN 'SUV'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%TAXI%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%CAB%' THEN 'Taxi'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%PICK%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%TRUCK%' THEN 'Pickup Truck'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%VAN%' THEN 'Van'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%AMBULANCE%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%FIRE TRUCK%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%FDNY%' 
                OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%POLICE%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%EMERGENCY%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%EMS%' THEN 'Emergency Vehicle'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%LIVERY%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%LIMO%' THEN 'Livery'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%BUS%' THEN 'Bus'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%MOTORCYCLE%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%SCOOTER%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%MOPED%' 
                OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%E-SCOOTER%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%MOTORBIKE%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%E-BIKE%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%EBIKE%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%DIRT BIKE%' THEN 'Motorcycle'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%BICYCLE%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%E-BIKE%' THEN 'Bicycle'
            WHEN UPPER(TRIM(VEHICLE_TYPE)) LIKE '%TRUCK%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%DUMP TRUCK%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%FLATBED%' 
                OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%TRACTOR TRAILER%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%MAIL TRUCK%' OR UPPER(TRIM(VEHICLE_TYPE)) LIKE '%GARBAGE%' THEN 'Truck'
            ELSE 'Other'

    END AS TYPE_OF_VEHICLE


    FROM 
        `ferrous-thought-409502.insurance.vehicles`
    WHERE 
        `CRASH_DATE` BETWEEN '2015-01-01' AND '2024-12-01'
        AND VEHICLE_TYPE IS NOT NULL
        AND DRIVER_SEX IS NOT NULL
        AND DRIVER_LICENSE_STATUS IS NOT NULL
        AND COLLISION_ID IS NOT NULL

)

SELECT 
  c.COLLISION_ID,
  c.`CRASH DATE`,
  c.LATITUDE,
  c.LONGITUDE,
  c.`ZIP CODE`,
  c.BOROUGH,
  LEAST(TRIM(UPPER(c.`ON STREET NAME`)), TRIM(UPPER(c.`CROSS STREET NAME`))) AS primary_street_name,
  GREATEST(TRIM(UPPER(c.`ON STREET NAME`)), TRIM(UPPER(c.`CROSS STREET NAME`))) AS secondary_street_name,
  v.TYPE_OF_VEHICLE
FROM `ferrous-thought-409502.insurance.crashes` AS c
  INNER JOIN cleaned_vehicles v
    ON c.COLLISION_ID = v.COLLISION_ID
WHERE
  c.BOROUGH IS NOT NULL
  AND c.`ZIP CODE` IS NOT NULL
  AND c.`ZIP CODE` > 10000
  AND c.LATITUDE IS NOT NULL
  AND c.LONGITUDE IS NOT NULL
  AND c.`ON STREET NAME` IS NOT NULL
  AND c.`CROSS STREET NAME` IS NOT NULL
  AND TRIM(UPPER(c.`ON STREET NAME`)) <> ''
  AND TRIM(UPPER(c.`CROSS STREET NAME`)) <> ''
  AND TRIM(UPPER(c.`CROSS STREET NAME`)) <> TRIM(UPPER(c.`ON STREET NAME`))
  AND c.`CRASH DATE` BETWEEN "2015-01-01" AND "2024-12-01"
ORDER BY c.`CRASH DATE` DESC;
