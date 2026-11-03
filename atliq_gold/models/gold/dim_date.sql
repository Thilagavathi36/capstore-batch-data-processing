
WITH dates AS (
    SELECT EXPLODE(
        SEQUENCE(
            DATE('2024-01-01'),
            MAKE_DATE(YEAR(CURRENT_DATE()) + 1, 12, 31),
            INTERVAL 1 DAY
        )
    ) AS date_day
)

SELECT
    date_day,
    CAST(DATE_FORMAT(date_day, 'yyyyMMdd') AS INT) AS date_key,
    date_day AS full_date,
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    DATE_FORMAT(date_day, 'MMM') AS month_name,
    DATE_FORMAT(date_day, 'yyyy-MM') AS year_month,
    DAY(date_day) AS day,
    DATE_FORMAT(date_day, 'EEEE') AS day_name,
    DAYOFWEEK(date_day) AS day_of_week,
    DATE_FORMAT(date_day, 'EEE') AS weekday_name,
    WEEKOFYEAR(date_day) AS week_of_year
FROM dates
