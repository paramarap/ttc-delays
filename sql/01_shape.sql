-- Number of incidents, number of incidents with zero delay, percentage of incidents with zero delay, median delay, mean delay, and maximum delay.
SELECT
    COUNT (*) AS incidents,
    SUM(CASE WHEN min_delay = 0 THEN 1 ELSE 0 END) AS zero_delay_incidents,
    ROUND(100.0 * AVG(CASE WHEN min_delay = 0 THEN 1 ELSE 0 END), 1) AS pct_zero,
    MEDIAN(min_delay) AS median_delay,
    ROUND(AVG(min_delay), 2) AS mean_delay,
    MAX(min_delay) AS max_delay,
FROM delays;

-- Yearly summary of incidents and total delay minutes
SELECT year, COUNT (*) AS incidents, SUM(min_delay) AS total_delay_min
FROM delays
WHERE year < 2026
GROUP BY year
ORDER BY year;

-- Curious about the 900 minutes delay
SELECT *
FROM delays
WHERE min_delay = 900