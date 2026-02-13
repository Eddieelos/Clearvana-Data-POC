{{ config(
    materialized='table',
    schema='marts_finance'
) }}

-- Dashboard-ready subscription metrics by month, product, country
WITH monthly_subscriptions AS (
    SELECT * FROM {{ ref('fct_subscriptions_monthly') }}
)

SELECT
    snapshot_month,
    snapshot_year,
    snapshot_month_number,
    snapshot_quarter,
    product_family,
    product_plan_name,
    billing_frequency,
    country_code,
    account_manager,
    
    -- Subscription counts
    COUNT(DISTINCT subscription_id) AS total_subscriptions,
    COUNT(DISTINCT CASE WHEN is_active THEN subscription_id END) AS active_subscriptions,
    COUNT(DISTINCT CASE WHEN is_first_month THEN subscription_id END) AS new_subscriptions,
    COUNT(DISTINCT CASE WHEN is_last_month THEN subscription_id END) AS cancelled_subscriptions,
    
    -- Revenue metrics
    SUM(CASE WHEN is_active THEN mrr ELSE 0 END) AS total_mrr,
    AVG(CASE WHEN is_active THEN mrr ELSE NULL END) AS avg_mrr_per_subscription,
    
    -- Churn rate
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN is_active OR is_last_month THEN subscription_id END) > 0
        THEN 
            CAST(COUNT(DISTINCT CASE WHEN is_last_month THEN subscription_id END) AS FLOAT) / 
            COUNT(DISTINCT CASE WHEN is_active OR is_last_month THEN subscription_id END)
        ELSE NULL 
    END AS churn_rate,
    
    -- Customer counts
    COUNT(DISTINCT customer_id) AS unique_customers,
    
    -- Metadata
    CURRENT_TIMESTAMP AS dbt_updated_at

FROM monthly_subscriptions
GROUP BY 
    snapshot_month,
    snapshot_year,
    snapshot_month_number,
    snapshot_quarter,
    product_family,
    product_plan_name,
    billing_frequency,
    country_code,
    account_manager
