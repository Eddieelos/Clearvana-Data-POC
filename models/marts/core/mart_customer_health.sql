{{ config(
    materialized='table',
    schema='marts_core'
) }}

-- Customer health dashboard with all key metrics
WITH customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
),

recent_activity AS (
    SELECT
        customer_id,
        COUNT(DISTINCT CASE WHEN ticket_date >= CURRENT_DATE - INTERVAL 30 DAY THEN ticket_id END) AS tickets_last_30_days,
        COUNT(DISTINCT CASE WHEN ticket_date >= CURRENT_DATE - INTERVAL 90 DAY THEN ticket_id END) AS tickets_last_90_days,
        AVG(CASE WHEN is_successful THEN 1.0 ELSE 0.0 END) AS recent_success_rate
    FROM {{ ref('fct_removal_tickets') }}
    WHERE ticket_date >= CURRENT_DATE - INTERVAL 90 DAY
    GROUP BY customer_id
)

SELECT
    c.customer_key,
    c.customer_id,
    c.customer_name,
    c.country_code,
    c.account_manager,
    c.customer_segment,
    
    -- Financial health
    c.current_mrr,
    c.lifetime_revenue,
    c.active_subscription_count,
    c.churned_subscription_count,
    
    -- Usage health
    c.lifetime_tickets,
    c.lifetime_successful_tickets,
    c.lifetime_success_rate,
    ra.tickets_last_30_days,
    ra.tickets_last_90_days,
    ra.recent_success_rate,
    
    -- Engagement health
    c.days_since_last_activity,
    c.health_score,
    c.customer_churn_rate,
    
    -- Risk flags
    c.is_at_risk,
    CASE 
        WHEN c.active_subscription_count = 0 THEN 'Churned'
        WHEN c.days_since_last_activity > 90 THEN 'High Risk'
        WHEN c.health_score < 40 THEN 'Medium Risk'
        WHEN c.health_score >= 70 THEN 'Healthy'
        ELSE 'Monitor'
    END AS risk_category,
    
    -- Product mix
    c.has_watchdog_product,
    c.has_retainer_product,
    
    -- Dates
    c.first_subscription_date,
    c.last_invoice_date,
    DATEDIFF('month', c.first_subscription_date, CURRENT_DATE) AS months_as_customer,
    
    -- Metadata
    CURRENT_TIMESTAMP AS dbt_updated_at

FROM customers c
LEFT JOIN recent_activity ra ON c.customer_id = ra.customer_id
WHERE c.is_currently_active = TRUE
    OR c.days_since_last_activity <= 180
