{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    invoice_id,
    customer_id,
    subscription_id,
    repeating_invoice_id,
    CAST(created AS TIMESTAMP) AS invoice_created_at,
    CAST(due_date AS TIMESTAMP) AS due_date,
    CAST(fully_paid_on_date AS TIMESTAMP) AS fully_paid_on_date,
    UPPER(status) AS invoice_status,
    CAST(total_amount AS DECIMAL(12,2)) AS total_amount,
    CAST(amount_due AS DECIMAL(12,2)) AS amount_due,
    UPPER(currency_code) AS currency_code,
    CAST(currency_rate_to_aud AS DECIMAL(12,6)) AS currency_rate_to_aud,
    salesperson,
    -- Extract date parts
    CAST(created AS DATE) AS invoice_date,
    DATE_TRUNC('month', CAST(created AS DATE)) AS invoice_month,
    YEAR(CAST(created AS DATE)) AS invoice_year,
    -- Is paid flag
    CASE WHEN UPPER(status) = 'PAID' THEN TRUE ELSE FALSE END AS is_paid
FROM {{ ref('raw_xero_invoices') }}
WHERE invoice_id IS NOT NULL
