-- Create Diabetes table
CREATE TABLE DiabetesPrevalence (
    IndicatorID INT,
    IndicatorName NVARCHAR(500),
    ParentCode NVARCHAR(50),
    ParentName NVARCHAR(200),
    AreaCode NVARCHAR(50),
    AreaName NVARCHAR(200),
    AreaType NVARCHAR(100),
    Sex NVARCHAR(50),
    Age NVARCHAR(50),
    Category NVARCHAR(100),
    CategoryType NVARCHAR(100),
    TimePeriod NVARCHAR(50),
    Value FLOAT,
    LowerCI95 FLOAT,
    UpperCI95 FLOAT,
    LowerCI99 FLOAT,
    UpperCI99 FLOAT,
    Count FLOAT,
    Denominator FLOAT,
    ValueNote NVARCHAR(200),
    RecentTrend NVARCHAR(100),
    ComparedToEngland NVARCHAR(100),
    TimeperiodSortable INT,
    NewData NVARCHAR(10),
    ComparedToGoal NVARCHAR(100)
)
-- Create Deprivation table
CREATE TABLE DeprivationScores (
    AreaCode NVARCHAR(50),
    AreaName NVARCHAR(200),
    AreaType NVARCHAR(100),
    TimePeriod NVARCHAR(50),
    DeprivationScore FLOAT,
    DeprivationDecile INT
)
ALTER TABLE HbA1c_analyser_report
ALTER COLUMN Calendar_Year INT;
UPDATE HbA1c_analyser_report
SET Value_from_preceding_year = TRY_CAST(Value_from_preceding_year AS INT);
ALTER TABLE HbA1c_analyser_report
ALTER COLUMN Value_from_preceding_year INT;
UPDATE HbA1c_analyser_report
SET Value_from_preceding_year = TRY_CAST(Value_from_current_year AS INT);
ALTER TABLE HbA1c_analyser_report
ALTER COLUMN Value_from_current_year INT;
UPDATE HbA1c_analyser_report
SET Percentage_change_value = TRY_CAST(Percentage_change_value AS FLOAT)
ALTER TABLE HbA1c_analyser_report
ALTER COLUMN Percentage_change_value FLOAT;
SELECT TOP 10 *
FROM HbA1c_analyser_report;
SELECT COUNT (*) AS TotalRows
FROM HbA1c_analyser_report;



