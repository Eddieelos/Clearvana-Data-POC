{{ config(
    materialized='table',
    schema='marts_core'
) }}

WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
    product_id,
    product_plan_name,
    product_family,
    billing_frequency,
    fee_type,
    currency_code,
    monthly_fee,
    per_removal_price,
    
    -- Business logic flags
    CASE WHEN product_family = 'Retainer' THEN TRUE ELSE FALSE END AS is_retainer,
    CASE WHEN product_family = 'WatchDog' THEN TRUE ELSE FALSE END AS is_watchdog,
    CASE WHEN per_removal_price > 0 THEN TRUE ELSE FALSE END AS has_per_removal_fee,
    CASE WHEN billing_frequency = 'monthly' THEN TRUE ELSE FALSE END AS is_monthly_billing,
    CASE WHEN billing_frequency = 'yearly' THEN TRUE ELSE FALSE END AS is_yearly_billing,
    
    -- Metadata
    CURRENT_TIMESTAMP AS dbt_updated_at

FROM products
