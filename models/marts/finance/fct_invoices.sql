{{ config(
    materialized='table',
    schema='marts_finance'
) }}

WITH invoices_with_products AS (
    SELECT * FROM {{ ref('int_invoices_with_products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['line_item_id']) }} AS invoice_line_key,
    line_item_id,
    invoice_id,
    subscription_id,
    product_id,
    ticket_id,
    
    -- Date dimensions
    invoice_date,
    invoice_month,
    invoice_year,
    
    -- Amounts
    line_amount,
    invoice_total_amount,
    pct_of_invoice,
    currency_code,
    
    -- Status
    invoice_status,
    is_paid,
    
    -- Product attributes
    product_family,
    product_plan_name,
    billing_frequency,
    
    -- Flags
    is_ticket_charge,
    is_missing_product_id,
    CASE WHEN product_family = 'Retainer' THEN TRUE ELSE FALSE END AS is_retainer_invoice,
    CASE WHEN product_family = 'WatchDog' THEN TRUE ELSE FALSE END AS is_watchdog_invoice,
    
    -- Description
    description,
    
    -- Metadata
    invoice_created_at,
    CURRENT_TIMESTAMP AS dbt_updated_at

FROM invoices_with_products
