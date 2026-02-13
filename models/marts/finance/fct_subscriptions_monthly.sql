{{ config(
    materialized='table',
    schema='marts_finance'
) }}

-- Monthly subscription snapshot for historical trending
-- Each row = one subscription in one month
-- Use this to analyze active subscriptions, MRR, and churn over time

WITH subscriptions AS (
    SELECT * FROM {{ ref('int_subscriptions_enriched') }}
),

-- Generate monthly spine for each subscription
subscription_months AS (
    SELECT 
        s.subscription_id,
        s.customer_id,
        s.product_id,
        s.subscription_status,
        s.subscription_start_date,
        s.subscription_ended_date,
        d.date_key,
        d.month_start_date,
        d.year,
        d.month,
        d.quarter
    FROM subscriptions s
    CROSS JOIN {{ ref('dim_dates') }} d
    WHERE d.is_month_start = TRUE
        AND d.date_key >= DATE_TRUNC('month', s.subscription_start_date)
        AND (
            s.subscription_ended_date IS NULL 
            OR d.date_key <= DATE_TRUNC('month', s.subscription_ended_date)
        )
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['sm.subscription_id', 'sm.month_start_date']) }} AS subscription_month_key,
    sm.subscription_id,
    sm.customer_id,
    sm.product_id,
    sm.month_start_date AS snapshot_month,
    sm.year AS snapshot_year,
    sm.month AS snapshot_month_number,
    sm.quarter AS snapshot_quarter,
    
    -- Subscription attributes
    s.customer_name,
    s.country_code,
    s.account_manager,
    s.product_family,
    s.product_plan_name,  -- Now cleaned without currency suffix
    s.billing_frequency,
    s.subscription_currency,
    s.subscription_start_date,
    s.subscription_ended_date,
    
    -- Financial metrics for this month
    s.subscription_amount AS mrr,
    
    -- Status at snapshot month
    CASE 
        WHEN sm.month_start_date < DATE_TRUNC('month', s.subscription_start_date) THEN 'not_started'
        WHEN s.subscription_ended_date IS NOT NULL 
            AND sm.month_start_date > DATE_TRUNC('month', s.subscription_ended_date) THEN 'churned'
        ELSE s.subscription_status
    END AS status_in_month,
    
    -- Activity flags
    CASE 
        WHEN sm.month_start_date = DATE_TRUNC('month', s.subscription_start_date) 
        THEN TRUE 
        ELSE FALSE 
    END AS is_first_month,
    
    CASE 
        WHEN s.subscription_ended_date IS NOT NULL 
            AND sm.month_start_date = DATE_TRUNC('month', s.subscription_ended_date) 
        THEN TRUE 
        ELSE FALSE 
    END AS is_last_month,
    
    CASE 
        WHEN s.subscription_status = 'active' THEN TRUE 
        ELSE FALSE 
    END AS is_active,
    
    -- Tenure tracking
    DATEDIFF('month', s.subscription_start_date, sm.month_start_date) AS months_since_start,
    
    -- Metadata
    CURRENT_TIMESTAMP AS dbt_updated_at

FROM subscription_months sm
INNER JOIN subscriptions s ON sm.subscription_id = s.subscription_id
