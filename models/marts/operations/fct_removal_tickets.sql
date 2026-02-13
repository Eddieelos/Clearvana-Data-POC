{{ config(
    materialized='table',
    schema='marts_operations'
) }}

WITH tickets AS (
    SELECT * FROM {{ ref('stg_removal_tickets') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['t.ticket_id']) }} AS ticket_key,
    t.ticket_id,
    t.customer_id,
    
    -- Customer attributes
    c.customer_name,
    c.country_code,
    c.account_manager,
    
    -- Date dimensions
    t.ticket_date,
    t.ticket_month,
    t.ticket_year,
    t.ticket_created_at,
    t.ticket_last_updated,
    t.successfully_removed_date,
    
    -- Ticket details
    t.platform,
    t.removal_status,
    t.billing_type,
    
    -- Financial
    t.removal_price,
    t.currency_code,
    
    -- Flags
    t.is_successful,
    t.is_unsuccessful,
    t.is_completed,
    t.is_billable,
    CASE WHEN t.billing_type = 'Included in Retainer' THEN TRUE ELSE FALSE END AS is_retainer_ticket,
    
    -- Days to completion
    CASE 
        WHEN t.successfully_removed_date IS NOT NULL 
        THEN DATEDIFF('day', t.ticket_created_at, t.successfully_removed_date)
        ELSE NULL 
    END AS days_to_completion,
    
    -- Metadata
    CURRENT_TIMESTAMP AS dbt_updated_at

FROM tickets t
LEFT JOIN customers c ON t.customer_id = c.customer_id
