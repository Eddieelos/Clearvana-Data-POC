{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    subscription_id,
    customer_id,
    product_id,
    -- Standardize status spelling (cancelled vs canceled)
    CASE 
        WHEN LOWER(status) IN ('canceled', 'cancelled') THEN 'cancelled'
        WHEN LOWER(status) = 'active' THEN 'active'
        WHEN LOWER(status) = 'paused' THEN 'paused'
        WHEN LOWER(status) = 'trialing' THEN 'trialing'
        ELSE LOWER(status)
    END AS subscription_status,
    CAST(amount_in_dollars AS DECIMAL(12,2)) AS subscription_amount,
    UPPER(currency) AS currency_code,
    CAST(start_date AS TIMESTAMP) AS subscription_start_date,
    CAST(ended_date AS TIMESTAMP) AS subscription_ended_date,
    -- Calculate subscription tenure in days
    CASE 
        WHEN ended_date IS NULL THEN 
            DATEDIFF('day', CAST(start_date AS DATE), CURRENT_DATE)
        ELSE 
            DATEDIFF('day', CAST(start_date AS DATE), CAST(ended_date AS DATE))
    END AS tenure_days,
    -- Is currently active
    CASE 
        WHEN LOWER(status) = 'active' THEN TRUE 
        ELSE FALSE 
    END AS is_active,
    -- Is churned
    CASE 
        WHEN LOWER(status) IN ('canceled', 'cancelled') THEN TRUE 
        ELSE FALSE 
    END AS is_churned
FROM {{ ref('raw_stripe_subscriptions') }}
WHERE subscription_id IS NOT NULL
