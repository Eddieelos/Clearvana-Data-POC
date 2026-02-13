{{ config(
    materialized='table',
    schema='marts_core'
) }}

WITH customer_metrics AS (
    SELECT * FROM {{ ref('int_customer_metrics') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} AS customer_key,
    c.customer_id,
    c.customer_name,
    c.country_code,
    c.account_manager,
    c.default_currency,
    c.customer_created_at,
    
    -- Aggregated metrics
    cm.lifetime_subscription_count,
    cm.active_subscription_count,
    cm.churned_subscription_count,
    cm.current_mrr,
    cm.lifetime_revenue,
    cm.lifetime_tickets,
    cm.lifetime_successful_tickets,
    cm.customer_churn_rate,
    cm.lifetime_success_rate,
    cm.health_score,
    cm.customer_segment,
    cm.first_subscription_date,
    cm.last_invoice_date,
    cm.days_since_last_activity,
    
    -- Flags
    CASE WHEN cm.active_subscription_count > 0 THEN TRUE ELSE FALSE END AS is_currently_active,
    CASE WHEN cm.has_watchdog = 1 THEN TRUE ELSE FALSE END AS has_watchdog_product,
    CASE WHEN cm.has_retainer = 1 THEN TRUE ELSE FALSE END AS has_retainer_product,
    CASE WHEN cm.days_since_last_activity > 90 THEN TRUE ELSE FALSE END AS is_at_risk,
    
    -- Metadata
    CURRENT_TIMESTAMP AS dbt_updated_at

FROM customers c
LEFT JOIN customer_metrics cm ON c.customer_id = cm.customer_id
