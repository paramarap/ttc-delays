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