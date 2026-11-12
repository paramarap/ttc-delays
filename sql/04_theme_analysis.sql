SELECT
    theme,
    COUNT(*)                                                    AS incidents,
    SUM(min_delay)                                              AS total_delay_min,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS pct_of_incidents,
    ROUND(100.0 * SUM(min_delay) / SUM(SUM(min_delay)) OVER (), 1) AS pct_of_minutes,
    ROUND(SUM(min_delay) * 1.0 / COUNT(*), 2)                   AS min_per_incident,
    ROUND(100.0 * AVG(CASE WHEN min_delay = 0 THEN 1 ELSE 0 END), 1) AS pct_zero_min
FROM delays_themed
WHERE year <= 2025
GROUP BY theme
ORDER BY pct_of_incidents DESC;

SELECT
    theme,
    SUM(CASE WHEN year = 2023 THEN min_delay ELSE 0 END) AS min_2023,
    SUM(CASE WHEN year = 2024 THEN min_delay ELSE 0 END) AS min_2024,
    SUM(CASE WHEN year = 2025 THEN min_delay ELSE 0 END) AS min_2025,
    ROUND(100.0 * (SUM(CASE WHEN year = 2025 THEN min_delay ELSE 0 END)
                 - SUM(CASE WHEN year = 2023 THEN min_delay ELSE 0 END))
          / NULLIF(SUM(CASE WHEN year = 2023 THEN min_delay ELSE 0 END), 0), 1) AS pct_change_23_to_25
FROM delays_themed
WHERE year <= 2025
GROUP BY theme
ORDER BY min_2025 DESC;

SELECT
    theme,
    SUM(CASE WHEN line = 'YU'  THEN min_delay ELSE 0 END) AS yu_min,
    SUM(CASE WHEN line = 'BD'  THEN min_delay ELSE 0 END) AS bd_min,
    SUM(CASE WHEN line = 'SHP' THEN min_delay ELSE 0 END) AS shp_min
FROM delays_themed
WHERE year <= 2025
GROUP BY theme
ORDER BY yu_min DESC;

SELECT
    CASE WHEN hour BETWEEN 0  AND 4  THEN '1 Overnight (0-4)'
         WHEN hour BETWEEN 5  AND 8  THEN '2 Early AM (5-8)'
         WHEN hour BETWEEN 9  AND 14 THEN '3 Midday (9-14)'
         WHEN hour BETWEEN 15 AND 18 THEN '4 PM peak (15-18)'
         ELSE                             '5 Evening (19-23)'
    END AS time_band,
    theme,
    COUNT(*)       AS incidents,
    SUM(min_delay) AS total_delay_min
FROM delays_themed
WHERE year <= 2025
GROUP BY time_band, theme
ORDER BY time_band, total_delay_min DESC;

SELECT
    theme,
    COUNT(*)       AS long_incidents,
    SUM(min_delay) AS long_delay_min
FROM delays_themed
WHERE year <= 2025
  AND min_delay >= 30
GROUP BY theme
ORDER BY long_delay_min DESC;

SELECT
    station,
    line,
    COUNT(*)       AS incidents,
    SUM(min_delay) AS total_delay_min
FROM delays_themed
WHERE year <= 2025
  AND theme = 'Customers and security'
  AND station <> 'OTHER / NOT A STATION'
GROUP BY station, line
ORDER BY total_delay_min DESC
LIMIT 5;