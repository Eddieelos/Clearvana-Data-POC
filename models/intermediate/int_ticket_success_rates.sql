{{ config(
    materialized='table',
    schema='intermediate'
) }}

WITH tickets AS (
    SELECT * FROM {{ ref('stg_removal_tickets') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
)

SELECT
    t.platform,
    t.removal_status,
    c.country_code,
    
    -- Date dimensions
    t.ticket_month,
    t.ticket_year,
    
    -- Aggregations
    COUNT(DISTINCT t.ticket_id) AS ticket_count,
    COUNT(DISTINCT t.customer_id) AS unique_customers,
    SUM(t.removal_price) AS total_removal_revenue,
    
    -- Success metrics
    COUNT(DISTINCT CASE WHEN t.is_successful THEN t.ticket_id END) AS successful_count,
    COUNT(DISTINCT CASE WHEN t.is_unsuccessful THEN t.ticket_id END) AS unsuccessful_count,
    COUNT(DISTINCT CASE WHEN t.is_completed THEN t.ticket_id END) AS completed_count,
    
    -- Success rate
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN t.is_completed THEN t.ticket_id END) > 0 
        THEN 
            CAST(COUNT(DISTINCT CASE WHEN t.is_successful THEN t.ticket_id END) AS FLOAT) / 
            COUNT(DISTINCT CASE WHEN t.is_completed THEN t.ticket_id END)
        ELSE NULL 
    END AS success_rate,
    
    -- Time to completion (avg days)
    AVG(
        CASE 
            WHEN t.successfully_removed_date IS NOT NULL 
            THEN DATEDIFF('day', t.ticket_created_at, t.successfully_removed_date)
            ELSE NULL 
        END
    ) AS avg_days_to_success,
    
    -- Billable metrics
    COUNT(DISTINCT CASE WHEN t.is_billable THEN t.ticket_id END) AS billable_ticket_count,
    SUM(CASE WHEN t.is_billable THEN t.removal_price ELSE 0 END) AS billable_revenue

FROM tickets t
LEFT JOIN customers c ON t.customer_id = c.customer_id
GROUP BY 
    t.platform,
    t.removal_status,
    c.country_code,
    t.ticket_month,
    t.ticket_year
