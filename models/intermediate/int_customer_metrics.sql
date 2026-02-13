{{ config(
    materialized='table',
    schema='intermediate'
) }}

WITH subscriptions_enriched AS (
    SELECT * FROM {{ ref('int_subscriptions_enriched') }}
),

customer_aggregates AS (
    SELECT
        customer_id,
        
        -- Subscription metrics
        COUNT(DISTINCT subscription_id) AS lifetime_subscription_count,
        COUNT(DISTINCT CASE WHEN is_active THEN subscription_id END) AS active_subscription_count,
        COUNT(DISTINCT CASE WHEN is_churned THEN subscription_id END) AS churned_subscription_count,
        
        -- Revenue metrics
        SUM(CASE WHEN is_active THEN subscription_amount ELSE 0 END) AS current_mrr,
        SUM(total_invoice_revenue) AS lifetime_revenue,
        SUM(total_removal_revenue) AS lifetime_removal_revenue,
        
        -- Ticket metrics
        SUM(total_tickets) AS lifetime_tickets,
        SUM(successful_tickets) AS lifetime_successful_tickets,
        SUM(unsuccessful_tickets) AS lifetime_unsuccessful_tickets,
        
        -- Tenure metrics
        MIN(subscription_start_date) AS first_subscription_date,
        MAX(CASE WHEN is_active THEN subscription_start_date END) AS latest_active_subscription_date,
        MAX(CASE WHEN is_churned THEN subscription_ended_date END) AS latest_churn_date,
        MAX(last_invoice_date) AS last_invoice_date,
        MAX(last_ticket_date) AS last_ticket_date,
        
        -- Product mix
        COUNT(DISTINCT product_family) AS product_family_count,
        MAX(CASE WHEN product_family = 'WatchDog' THEN 1 ELSE 0 END) AS has_watchdog,
        MAX(CASE WHEN product_family = 'Retainer' THEN 1 ELSE 0 END) AS has_retainer

    FROM subscriptions_enriched
    GROUP BY customer_id
)

SELECT
    ca.*,
    
    -- Calculated metrics
    CASE 
        WHEN ca.lifetime_subscription_count > 0 
        THEN CAST(ca.churned_subscription_count AS FLOAT) / ca.lifetime_subscription_count 
        ELSE 0 
    END AS customer_churn_rate,
    
    CASE 
        WHEN ca.lifetime_tickets > 0 AND ca.lifetime_revenue > 0
        THEN ca.lifetime_revenue / ca.lifetime_tickets
        ELSE NULL 
    END AS revenue_per_ticket,
    
    CASE 
        WHEN ca.lifetime_tickets > 0 
        THEN CAST(ca.lifetime_successful_tickets AS FLOAT) / ca.lifetime_tickets 
        ELSE NULL 
    END AS lifetime_success_rate,
    
    -- Days since last activity
    DATEDIFF('day', COALESCE(ca.last_invoice_date, ca.last_ticket_date), CURRENT_DATE) AS days_since_last_activity,
    
    -- Customer health score (0-100)
    CASE 
        WHEN ca.active_subscription_count > 0 THEN
            LEAST(100, 
                (CASE WHEN ca.last_invoice_date >= CURRENT_DATE - INTERVAL 60 DAY THEN 40 ELSE 0 END) +
                (CASE WHEN ca.current_mrr > 100 THEN 30 ELSE ca.current_mrr / 100 * 30 END) +
                (CASE WHEN ca.lifetime_tickets > 0 THEN 20 ELSE 0 END) +
                (CASE WHEN ca.product_family_count > 1 THEN 10 ELSE 0 END)
            )
        ELSE 0 
    END AS health_score,
    
    -- Customer segment
    CASE 
        WHEN ca.active_subscription_count = 0 THEN 'Churned'
        WHEN ca.current_mrr >= 1000 THEN 'Enterprise'
        WHEN ca.current_mrr >= 500 THEN 'Mid-Market'
        WHEN ca.current_mrr >= 100 THEN 'SMB'
        ELSE 'Starter'
    END AS customer_segment

FROM customer_aggregates ca
