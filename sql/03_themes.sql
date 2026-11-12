CREATE OR REPLACE TABLE code_themes_auto AS
SELECT
    code,
    code_description,
    CASE
        WHEN code_description = 'UNMAPPED' THEN 'Unmapped code'
        WHEN code_description LIKE '%INJURED%'
          OR code_description LIKE '%ESCL%'
          OR code_description LIKE '%STAIRWAY%' THEN 'Medical and injuries'
        WHEN code_norm LIKE 'SU%'
          OR code_norm IN ('MUPAA', 'MUPR1', 'MUSAN', 'MUD', 'MUDD') THEN 'Customers and security'
        WHEN code_norm LIKE 'TU%'
          OR code_norm IN ('MUNOA', 'MUNCA', 'MUESA', 'MUTO', 'MUWR', 'MUCL', 'MUTD', 'MULD', 'OPTO') THEN 'Operators and crew'
        WHEN code_norm LIKE 'EU%' THEN 'Vehicles'
        WHEN code_norm LIKE 'PU%'
          OR code_norm IN ('MUATC', 'MUEC', 'MUSTM') THEN 'Track, signals and infrastructure'
        WHEN code_norm LIKE 'MUPL%'
          OR code_norm IN ('MUFS', 'MUWEA', 'MUPF') THEN 'Fire, weather and external'
        ELSE 'Other'
    END AS auto_theme
FROM (
    SELECT DISTINCT code, code_description,
           regexp_replace(code, '^([EMPST])R', '\1U') AS code_norm
    FROM delays
);

CREATE OR REPLACE TABLE code_themes AS
SELECT
    a.code,
    a.code_description,
    COALESCE(o.theme, a.auto_theme) AS theme,
    a.auto_theme,
    (o.theme IS NOT NULL) AS overridden
FROM code_themes_auto a
LEFT JOIN (
    SELECT upper(trim(code)) AS code, trim(theme) AS theme
    FROM read_csv('raw/theme_overrides.csv', header = true,
                  columns = {'code': 'VARCHAR', 'theme': 'VARCHAR'})
) o ON a.code = o.code;

CREATE OR REPLACE VIEW delays_themed AS
SELECT d.*, t.theme
FROM delays d
LEFT JOIN code_themes t ON d.code = t.code;

COPY (
    SELECT t.code, t.code_description, t.theme, t.overridden,
           COUNT(d.code)    AS incidents,
           SUM(d.min_delay) AS total_min
    FROM code_themes t
    LEFT JOIN delays d ON d.code = t.code AND d.year <= 2025
    GROUP BY t.code, t.code_description, t.theme, t.overridden
    ORDER BY total_min DESC NULLS LAST
) TO 'clean/code_theme_review.csv' (HEADER, DELIMITER ',');

