{{ config(
    materialized='table',
    schema='intermediate'
) }}

WITH invoices AS (
    SELECT * FROM {{ ref('stg_invoices') }}
),

invoice_items AS (
    SELECT * FROM {{ ref('stg_invoice_items') }}
),

products AS (
    SELECT * FROM {{ ref('stg_products') }}
)

SELECT
    ii.line_item_id,
    ii.invoice_id,
    i.subscription_id,
    i.invoice_created_at,
    i.invoice_status,
    i.invoice_date,
    i.invoice_month,
    i.invoice_year,
    i.is_paid,
    
    -- Line item details
    ii.line_amount,
    ii.currency_code,
    ii.description,
    ii.ticket_id,
    ii.is_ticket_charge,
    ii.is_missing_product_id,
    
    -- Product attribution
    ii.product_id,
    ii.product_family,
    p.product_plan_name,
    p.billing_frequency,
    
    -- Invoice total
    i.total_amount AS invoice_total_amount,
    
    -- Line item percentage of invoice
    CASE 
        WHEN i.total_amount > 0 
        THEN (ii.line_amount / i.total_amount) * 100 
        ELSE NULL 
    END AS pct_of_invoice

FROM invoice_items ii
INNER JOIN invoices i ON ii.invoice_id = i.invoice_id
LEFT JOIN products p ON ii.product_id = p.product_id
