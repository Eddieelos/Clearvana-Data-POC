{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    line_item_id,
    invoice_id,
    product_id,
    -- Standardize product family
    CASE 
        WHEN LOWER(product_family_name) IN ('watchdog', 'watch dog') THEN 'WatchDog'
        WHEN LOWER(product_family_name) = 'retainer' THEN 'Retainer'
        ELSE product_family_name
    END AS product_family,
    product_family_name AS product_family_raw,
    UPPER(currency_code) AS currency_code,
    CAST(line_amount AS DECIMAL(12,2)) AS line_amount,
    description,
    ticket_id,
    -- Flags
    CASE WHEN ticket_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_ticket_charge,
    CASE WHEN product_id IS NULL THEN TRUE ELSE FALSE END AS is_missing_product_id
FROM {{ ref('raw_xero_invoices_items') }}
WHERE line_item_id IS NOT NULL
