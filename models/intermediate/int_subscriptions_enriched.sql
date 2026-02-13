{{ config(
    materialized='table',
    schema='intermediate'
) }}

WITH subscriptions AS (
    SELECT * FROM {{ ref('stg_subscriptions') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

invoices AS (
    SELECT 
        subscription_id,
        COUNT(DISTINCT invoice_id) AS invoice_count,
        COUNT(DISTINCT CASE WHEN is_paid THEN invoice_id END) AS paid_invoice_count,
        SUM(CASE WHEN is_paid THEN total_amount ELSE 0 END) AS total_revenue,
        MAX(invoice_date) AS last_invoice_date,
        MIN(invoice_date) AS first_invoice_date
    FROM {{ ref('stg_invoices') }}
    GROUP BY subscription_id
),

tickets AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT ticket_id) AS total_tickets,
        COUNT(DISTINCT CASE WHEN is_successful THEN ticket_id END) AS successful_tickets,
        COUNT(DISTINCT CASE WHEN is_unsuccessful THEN ticket_id END) AS unsuccessful_tickets,
        COUNT(DISTINCT CASE WHEN is_completed THEN ticket_id END) AS completed_tickets,
        SUM(removal_price) AS total_removal_revenue,
        MAX(ticket_created_at) AS last_ticket_date,
        MIN(ticket_created_at) AS first_ticket_date
    FROM {{ ref('stg_removal_tickets') }}
    GROUP BY customer_id
)

SELECT
    s.subscription_id,
    s.customer_id,
    s.product_id,
    
    -- Customer attributes
    c.customer_name,
    c.country_code,
    c.account_manager,
    c.default_currency,
    
    -- Product attributes
    p.product_family,
    p.product_plan_name,
    p.billing_frequency,
    p.monthly_fee,
    p.per_removal_price,
    
    -- Subscription status
    s.subscription_status,
    s.subscription_amount,
    s.currency_code AS subscription_currency,
    s.subscription_start_date,
    s.subscription_ended_date,
    s.tenure_days,
    s.is_active,
    s.is_churned,
    
    -- Invoice metrics
    COALESCE(i.invoice_count, 0) AS invoice_count,
    COALESCE(i.paid_invoice_count, 0) AS paid_invoice_count,
    COALESCE(i.total_revenue, 0) AS total_invoice_revenue,
    i.last_invoice_date,
    i.first_invoice_date,
    
    -- Ticket metrics
    COALESCE(t.total_tickets, 0) AS total_tickets,
    COALESCE(t.successful_tickets, 0) AS successful_tickets,
    COALESCE(t.unsuccessful_tickets, 0) AS unsuccessful_tickets,
    COALESCE(t.completed_tickets, 0) AS completed_tickets,
    COALESCE(t.total_removal_revenue, 0) AS total_removal_revenue,
    t.last_ticket_date,
    t.first_ticket_date,
    
    -- Calculated metrics
    CASE 
        WHEN COALESCE(t.completed_tickets, 0) > 0 
        THEN CAST(t.successful_tickets AS FLOAT) / t.completed_tickets 
        ELSE NULL 
    END AS ticket_success_rate,
    
    CASE 
        WHEN COALESCE(t.total_tickets, 0) > 0 AND i.total_revenue > 0
        THEN i.total_revenue / t.total_tickets
        ELSE NULL 
    END AS revenue_per_ticket,
    
    -- Tenure buckets
    CASE 
        WHEN s.tenure_days < 30 THEN '0-1 months'
        WHEN s.tenure_days < 90 THEN '1-3 months'
        WHEN s.tenure_days < 180 THEN '3-6 months'
        WHEN s.tenure_days < 365 THEN '6-12 months'
        ELSE '12+ months'
    END AS tenure_bucket

FROM subscriptions s
LEFT JOIN customers c ON s.customer_id = c.customer_id
LEFT JOIN products p ON s.product_id = p.product_id
LEFT JOIN invoices i ON s.subscription_id = i.subscription_id
LEFT JOIN tickets t ON s.customer_id = t.customer_id
