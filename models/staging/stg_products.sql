{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    product_id,
    -- Clean product_plan_name by removing currency suffix
    CASE 
        WHEN product_plan_name LIKE '% (AUD)' THEN TRIM(REPLACE(product_plan_name, '(AUD)', ''))
        WHEN product_plan_name LIKE '% (USD)' THEN TRIM(REPLACE(product_plan_name, '(USD)', ''))
        ELSE product_plan_name
    END AS product_plan_name,
    product_plan_name AS product_plan_name_raw,
    -- Standardize product family naming (WatchDog vs Watchdog issue)
    CASE 
        WHEN LOWER(product_family_name) IN ('watchdog', 'watch dog') THEN 'WatchDog'
        WHEN LOWER(product_family_name) = 'retainer' THEN 'Retainer'
        ELSE product_family_name
    END AS product_family,
    product_family_name AS product_family_raw,
    LOWER(subscription_frequency) AS billing_frequency,
    fee_type,
    UPPER(currency) AS currency_code,
    CAST(fee_per_frequency AS DECIMAL(12,2)) AS monthly_fee,
    CAST(price_for_successful_removal AS DECIMAL(12,2)) AS per_removal_price
FROM {{ ref('raw_recurring_products') }}
WHERE product_id IS NOT NULL
