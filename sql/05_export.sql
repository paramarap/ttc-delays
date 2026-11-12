COPY (
    SELECT theme, year, COUNT(*) AS incidents, SUM(min_delay) AS total_delay_min
    FROM delays_themed
    WHERE year <= 2025
    GROUP BY theme, year
    ORDER BY year, total_delay_min DESC
) TO 'clean/summary_theme_year.csv' (HEADER, DELIMITER ',');

COPY (
    SELECT code_description, theme, COUNT(*) AS incidents,
           SUM(min_delay) AS total_delay_min, MEDIAN(min_delay) AS median_delay_min
    FROM delays_themed
    WHERE year <= 2025
    GROUP BY code_description, theme
    ORDER BY total_delay_min DESC
) TO 'clean/summary_cause.csv' (HEADER, DELIMITER ',');

COPY (
    SELECT year, line, COUNT(*) AS incidents, SUM(min_delay) AS total_delay_min
    FROM delays_themed
    WHERE year <= 2025 AND line IN ('YU', 'BD', 'SHP')
    GROUP BY year, line
    ORDER BY year, line
) TO 'clean/summary_line_year.csv' (HEADER, DELIMITER ',');

COPY (
    SELECT line, station, COUNT(*) AS incidents, SUM(min_delay) AS total_delay_min
    FROM delays_themed
    WHERE year <= 2025
      AND line IN ('YU', 'BD', 'SHP')
      AND station <> 'OTHER / NOT A STATION'
    GROUP BY line, station
    ORDER BY total_delay_min DESC
) TO 'clean/summary_station.csv' (HEADER, DELIMITER ',');

COPY (
    SELECT hour, is_weekend, COUNT(*) AS incidents, SUM(min_delay) AS total_delay_min
    FROM delays_themed
    WHERE year <= 2025
    GROUP BY hour, is_weekend
    ORDER BY hour, is_weekend
) TO 'clean/summary_hour.csv' (HEADER, DELIMITER ',');

COPY (
    SELECT year, month, COUNT(*) AS incidents, SUM(min_delay) AS total_delay_min
    FROM delays_themed
    WHERE year <= 2025
    GROUP BY year, month
    ORDER BY year, month
) TO 'clean/summary_month.csv' (HEADER, DELIMITER ',');