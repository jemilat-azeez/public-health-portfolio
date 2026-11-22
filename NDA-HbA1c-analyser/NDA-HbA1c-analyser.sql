-- QUERY 1: Overall trend by year
SELECT 
    Calendar_Year,
    AVG(TRY_CAST(Value_from_current_year AS DECIMAL(18,2))) AS Avg_Current_Value,
    AVG(TRY_CAST(Value_from_preceding_year AS DECIMAL(18,2))) AS Avg_Previous_Value,
    AVG(TRY_CAST(Percentage_change_value AS DECIMAL (18,2))) AS Avg_Percentage_Change,
    COUNT(*) AS Number_of_Areas
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
GROUP BY Calendar_Year
ORDER BY Calendar_Year

-- QUERY 2: Regional comparison latest year
SELECT 
    Region_Name,
    AVG(TRY_CAST(Value_from_current_year AS DECIMAL(18,2))) AS Avg_HbA1c_Value,
    AVG(TRY_CAST(Percentage_change_value AS DECIMAL (18,2))) AS Avg_Change,
    COUNT(*) AS Number_of_ICBs
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
AND Calendar_Year = (SELECT MAX(Calendar_Year) 
                     FROM HbA1c_analyser_report)
AND Region_Name != 'England'
GROUP BY Region_Name
ORDER BY Avg_HbA1c_Value DESC

-- QUERY 3: ICB level comparison
SELECT 
    ICB_Name,
    Region_Name,
    AVG(TRY_CAST(Value_from_current_year AS DECIMAL(18,2))) AS Avg_HbA1c_Value,
    AVG(TRY_CAST(Percentage_change_value AS DECIMAL(18,2))) AS Avg_Pct_Change
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
AND Calendar_Year = (SELECT MAX(Calendar_Year) 
                     FROM HbA1c_analyser_report)
AND ICB_Name != 'England'
GROUP BY ICB_Name, Region_Name
ORDER BY Avg_HbA1c_Value DESC

-- QUERY 4: Top 10 best performing ICBs
SELECT TOP 10
    ICB_Name,
    Region_Name,
    AVG(TRY_CAST(Value_from_current_year AS DECIMAL(18,2))) AS Avg_HbA1c_Value
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
AND Calendar_Year = (SELECT MAX(Calendar_Year) 
                     FROM HbA1c_analyser_report)
AND ICB_Name != 'England'
GROUP BY ICB_Name, Region_Name
ORDER BY Avg_HbA1c_Value DESC

-- QUERY 5: Top 10 worst performing ICBs
SELECT TOP 10
    ICB_Name,
    Region_Name,
    AVG(TRY_CAST(Value_from_current_year AS DECIMAL(18,2))) AS Avg_HbA1c_Value
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
AND Calendar_Year = (SELECT MAX(Calendar_Year) 
                     FROM HbA1c_analyser_report)
AND ICB_Name != 'England'
GROUP BY ICB_Name, Region_Name
ORDER BY Avg_HbA1c_Value ASC

-- QUERY 6: Monthly trend 2024
SELECT 
    Short_Date,
    Calendar_Year,
    AVG(TRY_CAST(Value_from_current_year AS DECIMAL(18,2))) AS Avg_HbA1c_Value,
    AVG(TRY_CAST(Percentage_change_value AS DECIMAL (18,2))) AS Avg_Change
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
AND Calendar_Year = 2024
AND Region_Name = 'England'
GROUP BY Short_Date, Calendar_Year
ORDER BY Short_Date

-- QUERY 7: Diagnosis type comparison
SELECT 
    Diagnosis_Type,
    Calendar_Year,
    AVG(TRY_CAST(Value_from_current_year AS DECIMAL (18,2))) AS Avg_HbA1c_Value,
    COUNT(*) AS Count
FROM HbA1c_analyser_report
WHERE Region_Name = 'England'
GROUP BY Diagnosis_Type, Calendar_Year
ORDER BY Calendar_Year, Diagnosis_Type

-- QUERY 8: Final export dataset for Power BI
SELECT 
    Calendar_Year,
    Short_Date,
    ICB_Code,
    ICB_Name,
    Region_Code,
    Region_Name,
    Diagnosis_Type,
    Value_from_preceding_year,
    Value_from_current_year,
    Percentage_change_value,
    CASE 
        WHEN Region_Name = 'North East and Yorkshire' THEN 'North'
        WHEN Region_Name = 'North West' THEN 'North'
        WHEN Region_Name = 'Midlands' THEN 'Midlands'
        WHEN Region_Name = 'East of England' THEN 'East'
        WHEN Region_Name = 'London' THEN 'London'
        WHEN Region_Name = 'South East' THEN 'South'
        WHEN Region_Name = 'South West' THEN 'South'
        ELSE Region_Name
    END AS Broad_Region
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
AND ICB_Name != 'England'
ORDER BY Calendar_Year, Region_Name, ICB_Name
--Top 10 ICBs
SELECT TOP 10
ICB_Name,
Region_Name,
AVG(TRY_CAST(Value_from_current_year AS DECIMAL(18,2))) AS Avg_HbA1c_Value
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
AND ICB_NAME != 'England'
AND Calendar_Year = 2024
GROUP BY ICB_Name, Region_Name
ORDER BY Avg_HbA1c_Value DESC;

-- Bottom 10 ICBs
SELECT TOP 10
ICB_Name,
Region_Name,
AVG(TRY_CAST(Value_from_current_year AS DECIMAL(18,2))) AS Avg_HbA1c_Value
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
AND ICB_Name != 'England'
AND Calendar_Year = 2024
GROUP BY ICB_Name, Region_Name
ORDER BY Avg_HbA1c_Value ASC;

SELECT TOP 10 * FROM Lower_tier_DeprivationScores
SELECT COUNT (*) FROM Lower_tier_DeprivationScores;

SELECT
h.ICB_Name,
h.Region_Name,
h.Calendar_Year,
AVG(TRY_CAST(h.Value_from_current_year AS DECIMAL (18,2)))
     AS Avg_HbA1c,
AVG(TRY_CAST(d.column3 AS INT)) AS Avg_Deprivation_Rank
 FROM HbA1c_analyser_report h
 LEFT JOIN Lower_tier_DeprivationScores d
         ON h.ICB_Name LIKE '%' + d.column2 + '%'
   WHERE h.Diagnosis_Type = 'Type 2 and Other'
   AND h.Calendar_Year = 2024
   AND h.ICB_Name != 'England'
   GROUP BY h.ICB_Name, h.Region_Name, h.Calendar_Year;
WITH MappedDeprivation AS (
SELECT
column3 AS Deprivation_Rank,
-- Complete mapping matrix for all remaining NHS Integrated Care Boards
CASE
WHEN column2 IN ('Hartlepool', 'Middlesbrough', 'Redcar and Cleveland', 'Stockton-on-Tees') THEN 'HUMBER AND NORTH YORKSHIRE'
WHEN column2 IN ('Watford', 'Stevenage', 'St Albans', 'Harlow', 'Epping Forest') THEN 'HERTFORDSHIRE AND WEST ESSEX'
WHEN column2 IN ('Southend-on-Sea', 'Thurrock', 'Basildon', 'Chelmsford') THEN 'MID AND SOUTH ESSEX'
WHEN column2 IN ('Norwich', 'Great Yarmouth', 'King''s Lynn') THEN 'NORFOLK AND WAVENEY'
WHEN column2 IN ('Ipswich', 'Colchester', 'Tendring') THEN 'SUFFOLK AND NORTH EAST ESSEX'
WHEN column2 IN ('Camden', 'Islington', 'Hackney', 'Tower Hamlets') THEN 'NORTH EAST LONDON'
WHEN column2 IN ('Brent', 'Harrow', 'Ealing', 'Hounslow') THEN 'NORTH WEST LONDON'
WHEN column2 IN ('Manchester', 'Salford', 'Bolton', 'Wigan', 'Trafford') THEN 'GREATER MANCHESTER'
WHEN column2 IN ('Barnet', 'Enfield', 'Haringey', 'Westminster') THEN 'NORTH CENTRAL LONDON'
WHEN column2 IN ('Blackpool', 'Blackburn with Darwen', 'Preston', 'Lancaster') THEN 'LANCASHIRE AND SOUTH CUMBRIA'
WHEN column2 IN ('Brighton and Hove', 'Crawley', 'Hastings', 'Chichester') THEN 'SUSSEX'
WHEN column2 IN ('Newcastle upon Tyne', 'Sunderland', 'Gateshead', 'Carlisle') THEN 'NORTH EAST AND NORTH CUMBRIA'
WHEN column2 IN ('Liverpool', 'Wirral', 'Sefton', 'Knowsley', 'St Helens') THEN 'CHESHIRE AND MERSEYSIDE'
ELSE UPPER(column2) -- Fallback for direct string matches
END AS Target_ICB_Match
FROM Lower_tier_DeprivationScores
)
SELECT
h.ICB_Name,
h.Region_Name,
h.Calendar_Year,
AVG(TRY_CAST(h.Value_from_current_year AS DECIMAL(18,2))) AS Avg_HbA1c,
AVG(TRY_CAST(m.Deprivation_Rank AS INT)) AS Avg_Deprivation_Rank
FROM HbA1c_analyser_report h
LEFT JOIN MappedDeprivation m
ON h.ICB_Name LIKE '%' + m.Target_ICB_Match + '%'
WHERE h.Diagnosis_Type = 'Type 2 and Other'
AND h.Calendar_Year = 2024
AND h.ICB_Name != 'England'
GROUP BY
h.ICB_Name,
h.Region_Name,
h.Calendar_Year
ORDER BY Avg_Deprivation_Rank DESC;

SELECT Region_Name,
  CASE WHEN Trust_Flag LIKE '%Affected%' THEN 'Affected' ELSE 'Control' END AS Practice_Group,
  COUNT(*) AS Rows_Used,
  100.0 * (SUM(TRY_CAST(REPLACE(Value_from_current_year, ',', '') AS INT))
         - SUM(TRY_CAST(REPLACE(Value_from_preceding_year, ',', '') AS INT)))
    / NULLIF(SUM(TRY_CAST(REPLACE(Value_from_preceding_year, ',', '') AS INT)), 0) AS Pct_Change
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
  AND Trust_Flag LIKE 'ICB%'
  AND Calendar_Year = 2024
GROUP BY Region_Name,
  CASE WHEN Trust_Flag LIKE '%Affected%' THEN 'Affected' ELSE 'Control' END
ORDER BY Region_Name, Practice_Group;

SELECT ICB_Name,
  CASE WHEN Trust_Flag LIKE '%Affected%' THEN 'Affected' ELSE 'Control' END AS Practice_Group,
  COUNT(*) AS Rows_Used,
  100.0 * (SUM(TRY_CAST(REPLACE(Value_from_current_year, ',', '') AS INT))
         - SUM(TRY_CAST(REPLACE(Value_from_preceding_year, ',', '') AS INT)))
    / NULLIF(SUM(TRY_CAST(REPLACE(Value_from_preceding_year, ',', '') AS INT)), 0) AS Pct_Change
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other'
  AND Trust_Flag LIKE 'ICB%'
  AND Calendar_Year = 2024
GROUP BY ICB_Name,
  CASE WHEN Trust_Flag LIKE '%Affected%' THEN 'Affected' ELSE 'Control' END
ORDER BY ICB_Name, Practice_Group;
SELECT Calendar_Year, Short_Date,
  CASE WHEN Trust_Flag LIKE '%Affected%' THEN 'Affected' ELSE 'Control' END AS Practice_Group,
  SUM(TRY_CAST(REPLACE(Value_from_preceding_year, ',', '') AS INT)) AS Previous_Year_Count,
  SUM(TRY_CAST(REPLACE(Value_from_current_year, ',', '') AS INT)) AS Current_Year_Count
FROM HbA1c_analyser_report
WHERE Diagnosis_Type = 'Type 2 and Other' AND Trust_Flag LIKE 'Total%'
GROUP BY Calendar_Year, Short_Date,
  CASE WHEN Trust_Flag LIKE '%Affected%' THEN 'Affected' ELSE 'Control' END
ORDER BY Calendar_Year, Short_Date;


