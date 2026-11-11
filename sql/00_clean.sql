-- 1. Combine the three delay sources (identical columns; _id dropped from the CSV)
INSTALL excel;
LOAD excel;

CREATE OR REPLACE TABLE raw_all AS
SELECT CAST("Date" AS DATE) AS d, CAST("Time" AS VARCHAR) AS t, "Day" AS wd,
       "Station" AS st, "Code" AS cd, "Min Delay" AS md, "Min Gap" AS mg,
       "Bound" AS bd, "Line" AS ln, "Vehicle" AS v
FROM read_xlsx('raw/ttc-subway-delay-data-2023.xlsx')
UNION ALL
SELECT CAST("Date" AS DATE), CAST("Time" AS VARCHAR), "Day", "Station", "Code",
       "Min Delay", "Min Gap", "Bound", "Line", "Vehicle"
FROM read_xlsx('raw/ttc-subway-delay-data-2024.xlsx')
UNION ALL
SELECT CAST("Date" AS DATE), CAST("Time" AS VARCHAR), "Day", "Station", "Code",
       "Min Delay", "Min Gap", "Bound", "Line", "Vehicle"
FROM read_csv_auto('raw/TTC_Subway_Delay_Data_since_2025.csv');

-- 2. Delay code lookup
CREATE OR REPLACE TABLE codes AS
SELECT upper(trim(CODE)) AS code, trim(DESCRIPTION) AS description
FROM read_csv_auto('raw/Code_Descriptions.csv');

-- 3. Clean: dedupe, fix Line and Station, join codes, add helper columns
CREATE OR REPLACE TABLE delays AS
WITH dedup AS (
    SELECT DISTINCT * FROM raw_all
),
cleaned AS (
    SELECT
        d AS delay_date,
        substr(t, 1, 5) AS delay_time,
        trim(wd) AS weekday,
        -- cut everything after "STATION", then strip trailing line tags (BD, YU...)
        trim(regexp_replace(
               regexp_replace(upper(trim(coalesce(st, ''))),
                              '\s+STATI?O?N?\b.*$|\s+STAT?I?O?$', ''),
               '\s+(YUS|YU|BD|SHP|SRT)$', '')) AS station_raw,
        upper(trim(cd)) AS code,
        md AS min_delay,
        mg AS min_gap,
        coalesce(nullif(upper(trim(bd)), ''), 'UNSPECIFIED') AS bound,
        CASE replace(replace(upper(trim(coalesce(ln, ''))), ' ', ''), '&', '/')
            WHEN 'YU' THEN 'YU' WHEN 'YUS' THEN 'YU'
            WHEN 'BD' THEN 'BD' WHEN 'BDLINE2' THEN 'BD' WHEN 'BLOORDANFORTH' THEN 'BD'
            WHEN 'SHP' THEN 'SHP' WHEN 'SHEP' THEN 'SHP'
            WHEN 'SRT' THEN 'SRT'
            WHEN 'YU/BD' THEN 'MULTIPLE' WHEN 'YUS/BD' THEN 'MULTIPLE'
            WHEN 'BD/YU' THEN 'MULTIPLE' WHEN 'BD/YUS' THEN 'MULTIPLE'
            WHEN 'YU/BD/SHP' THEN 'MULTIPLE'
            ELSE 'UNKNOWN'
        END AS line,
        v AS vehicle
    FROM dedup
)
SELECT
    c.delay_date,
    c.delay_time,
    c.weekday,
    CASE WHEN n.cnt >= 20 THEN c.station_raw ELSE 'OTHER / NOT A STATION' END AS station,
    c.station_raw,
    c.code,
    coalesce(k.description, 'UNMAPPED') AS code_description,
    c.min_delay,
    c.min_gap,
    c.bound,
    c.line,
    c.vehicle,
    year(c.delay_date)  AS year,
    month(c.delay_date) AS month,
    CAST(substr(c.delay_time, 1, 2) AS INTEGER) AS hour,
    CASE WHEN c.weekday IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS is_weekend
FROM cleaned c
LEFT JOIN codes k ON c.code = k.code
LEFT JOIN (SELECT station_raw, COUNT(*) AS cnt FROM cleaned GROUP BY station_raw) n
       ON c.station_raw = n.station_raw;

-- 4. Export the clean table for the dashboard
COPY delays TO 'clean/ttc_subway_clean.csv' (HEADER, DELIMITER ',');