SELECT
    code_description,
    COUNT(*)                 AS incidents,
    SUM(min_delay)           AS total_delay_min,
    ROUND(AVG(min_delay), 2) AS avg_delay_min,
    MEDIAN(min_delay)        AS median_delay_min
FROM delays
WHERE year <= 2025
GROUP BY code_description
ORDER BY total_delay_min DESC
LIMIT 10;

SELECT
    code_description,
    COUNT(*)                 AS incidents,
    ROUND(AVG(min_delay), 2) AS avg_delay_min,
    SUM(min_delay)           AS total_delay_min,
FROM delays
WHERE year <= 2025
GROUP BY code_description
HAVING COUNT(*) >= 30
ORDER BY avg_delay_min DESC
LIMIT 5;

WITH by_cause AS (
    SELECT
        code_description,
        COUNT(*)                 AS incidents,
        SUM(min_delay)           AS total_delay_min,
        MEDIAN(min_delay)        AS median_delay_min
    FROM delays
    WHERE year <= 2025
    GROUP BY code_description
)
SELECT
    code_description,
    incidents,
    total_delay_min,
    -- Window functions used for the cumulative percentage of total delay
    ROUND(100.0 * total_delay_min / SUM(total_delay_min) OVER (), 1)                                           AS pct_total_delay,
    ROUND(100.0 * SUM(total_delay_min) OVER (ORDER BY total_delay_min DESC) / SUM(total_delay_min) OVER (), 1) AS cumulative_pct
FROM by_cause
ORDER BY total_delay_min DESC
LIMIT 30;