{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    ticket_id,
    customer_id,
    CAST(created_at AS TIMESTAMP) AS ticket_created_at,
    CAST(last_updated AS TIMESTAMP) AS ticket_last_updated,
    -- Standardize removal status
    CASE 
        WHEN LOWER(removal_status) = 'successful' THEN 'Successful'
        WHEN LOWER(removal_status) = 'unsuccessful' THEN 'Unsuccessful'
        WHEN LOWER(removal_status) IN ('not started', 'notstarted') THEN 'Not Started'
        WHEN LOWER(removal_status) IN ('in progress', 'inprogress') THEN 'In Progress'
        ELSE removal_status
    END AS removal_status,
    UPPER(TRIM(platform)) AS platform,
    CAST(successfully_removed_date AS TIMESTAMP) AS successfully_removed_date,
    CAST(price_for_successful_removal AS DECIMAL(12,2)) AS removal_price,
    UPPER(currency) AS currency_code,
    billing_type,
    -- Extract date parts
    CAST(created_at AS DATE) AS ticket_date,
    DATE_TRUNC('month', CAST(created_at AS DATE)) AS ticket_month,
    YEAR(CAST(created_at AS DATE)) AS ticket_year,
    -- Flags
    CASE WHEN LOWER(removal_status) = 'successful' THEN TRUE ELSE FALSE END AS is_successful,
    CASE WHEN LOWER(removal_status) = 'unsuccessful' THEN TRUE ELSE FALSE END AS is_unsuccessful,
    CASE WHEN LOWER(removal_status) IN ('successful', 'unsuccessful') THEN TRUE ELSE FALSE END AS is_completed,
    CASE WHEN price_for_successful_removal > 0 THEN TRUE ELSE FALSE END AS is_billable
FROM {{ ref('raw_removal_tickets_sample') }}
WHERE ticket_id IS NOT NULL
