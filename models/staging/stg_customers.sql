{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    customer_id,
    name AS customer_name,
    CAST(created_at AS TIMESTAMP) AS customer_created_at,
    CAST(last_updated AS TIMESTAMP) AS customer_last_updated,
    UPPER(TRIM(default_currency)) AS default_currency,
    TRIM(account_manager) AS account_manager,
    -- Standardize country codes
    CASE 
        WHEN UPPER(TRIM(country)) IN ('US', 'USA', 'UNITED STATES', 'AMERICA', 'U.S.A.') THEN 'US'
        WHEN UPPER(TRIM(country)) IN ('AU', 'AUS', 'AUSTRALIA', 'AUS') THEN 'AU'
        WHEN UPPER(TRIM(country)) IN ('UK', 'UNITED KINGDOM', 'GREAT BRITAIN') THEN 'UK'
        WHEN UPPER(TRIM(country)) IN ('CA', 'CANADA') THEN 'CA'
        WHEN UPPER(TRIM(country)) IN ('NZ', 'NEW ZEALAND') THEN 'NZ'
        ELSE UPPER(TRIM(country))
    END AS country_code,
    TRIM(country) AS country_raw
FROM {{ ref('raw_customers') }}
WHERE customer_id IS NOT NULL
