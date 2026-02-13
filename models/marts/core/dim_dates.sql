{{ config(
    materialized='table',
    schema='marts_core'
) }}

-- Generate date spine for the reporting period
WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2024-01-01' as date)",
        end_date="cast('2026-12-31' as date)"
    ) }}
),

dates AS (
    SELECT
        CAST(date_day AS DATE) AS date_key,
        date_day,
        YEAR(date_day) AS year,
        QUARTER(date_day) AS quarter,
        MONTH(date_day) AS month,
        DAY(date_day) AS day_of_month,
        DAYOFWEEK(date_day) AS day_of_week,
        DAYOFYEAR(date_day) AS day_of_year,
        WEEKOFYEAR(date_day) AS week_of_year,
        DATE_TRUNC('month', date_day) AS month_start_date,
        LAST_DAY(date_day) AS month_end_date,
        DATE_TRUNC('quarter', date_day) AS quarter_start_date,
        DATE_TRUNC('year', date_day) AS year_start_date,
        
        -- Day name
        CASE DAYOFWEEK(date_day)
            WHEN 1 THEN 'Sunday'
            WHEN 2 THEN 'Monday'
            WHEN 3 THEN 'Tuesday'
            WHEN 4 THEN 'Wednesday'
            WHEN 5 THEN 'Thursday'
            WHEN 6 THEN 'Friday'
            WHEN 7 THEN 'Saturday'
        END AS day_name,
        
        -- Month name
        CASE MONTH(date_day)
            WHEN 1 THEN 'January'
            WHEN 2 THEN 'February'
            WHEN 3 THEN 'March'
            WHEN 4 THEN 'April'
            WHEN 5 THEN 'May'
            WHEN 6 THEN 'June'
            WHEN 7 THEN 'July'
            WHEN 8 THEN 'August'
            WHEN 9 THEN 'September'
            WHEN 10 THEN 'October'
            WHEN 11 THEN 'November'
            WHEN 12 THEN 'December'
        END AS month_name,
        
        -- Flags
        CASE WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        CASE WHEN DAYOFWEEK(date_day) BETWEEN 2 AND 6 THEN TRUE ELSE FALSE END AS is_weekday,
        CASE WHEN DAY(date_day) = 1 THEN TRUE ELSE FALSE END AS is_month_start,
        CASE WHEN DAY(LAST_DAY(date_day)) = DAY(date_day) THEN TRUE ELSE FALSE END AS is_month_end,
        CASE WHEN date_day = DATE_TRUNC('quarter', date_day) THEN TRUE ELSE FALSE END AS is_quarter_start,
        CASE WHEN date_day = LAST_DAY(DATE_TRUNC('quarter', date_day) + INTERVAL 2 MONTH) THEN TRUE ELSE FALSE END AS is_quarter_end
        
    FROM date_spine
)

SELECT
    *,
    CURRENT_TIMESTAMP AS dbt_updated_at
FROM dates
