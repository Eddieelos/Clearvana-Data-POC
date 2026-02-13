{% docs __overview__ %}
# Clearvana Analytics Data Warehouse

This dbt project transforms Clearvana's MySQL transactional database (db2) into a clean analytics layer using dbt + DuckDB.

## Project Structure
- **Staging**: Clean & standardize source data
- **Intermediate**: Business logic & joins
- **Marts**: Analytics-ready tables for BI tools

{% enddocs %}

{# ============================================ #}
{# PRIMARY KEYS & IDENTIFIERS #}
{# ============================================ #}

{% docs customer_id %}
Unique customer identifier (Primary Key)
{% enddocs %}

{% docs subscription_id %}
Unique Stripe subscription identifier (Primary Key)
{% enddocs %}

{% docs product_id %}
Unique recurring product identifier (Primary Key)
{% enddocs %}

{% docs invoice_id %}
Unique invoice identifier (Primary Key)
{% enddocs %}

{% docs line_item_id %}
Unique line item identifier (Primary Key)
{% enddocs %}

{% docs ticket_id %}
Unique ticket identifier (Primary Key)
{% enddocs %}

{% docs repeating_invoice_id %}
Xero Repeating Invoice identifier (closest thing to a subscription in Xero)
{% enddocs %}

{# ============================================ #}
{# CUSTOMER ATTRIBUTES #}
{# ============================================ #}

{% docs customer_name %}
Customer display name
{% enddocs %}

{% docs customer_created_at %}
Timestamp when customer record was created
{% enddocs %}

{% docs customer_last_updated %}
Timestamp when customer record was last updated
{% enddocs %}

{% docs default_currency %}
Customer's default billing currency (AUD, USD, etc.)
{% enddocs %}

{% docs account_manager %}
Clearvana Account Manager (AM) assigned to this customer
{% enddocs %}

{% docs country_code %}
Standardized customer country code (US, AU, UK, CA, NZ). Normalized from free-text country field.
{% enddocs %}

{# ============================================ #}
{# PRODUCT ATTRIBUTES #}
{# ============================================ #}

{% docs product_plan_name %}
Clean plan name without currency suffix (Basic, Premium, Retainer Paid Monthly, Retainer Paid Yearly)
{% enddocs %}

{% docs product_plan_name_raw %}
Original plan name from source including currency suffix (e.g., Premium (AUD), Basic (USD))
{% enddocs %}

{% docs product_family %}
Standardized product family name (WatchDog or Retainer). Resolves case inconsistencies from source data.
{% enddocs %}

{% docs product_family_raw %}
Original product family name from source before standardization
{% enddocs %}

{% docs billing_frequency %}
Billing frequency (monthly or yearly)
{% enddocs %}

{% docs fee_type %}
Type of fee structure (Fixed, Variable, etc.)
{% enddocs %}

{% docs currency_code %}
Currency code (AUD or USD)
{% enddocs %}

{% docs monthly_fee %}
Subscription fee per billing frequency (fee_per_frequency)
{% enddocs %}

{% docs per_removal_price %}
The amount invoiced ad-hoc each time a successful removal is achieved (Pay Per Removal)
{% enddocs %}

{# ============================================ #}
{# SUBSCRIPTION ATTRIBUTES #}
{# ============================================ #}

{% docs subscription_status %}
Subscription status (active, cancelled, paused, trialing). Standardizes 'canceled' vs 'cancelled' spelling.
{% enddocs %}

{% docs subscription_amount %}
Subscription fee per frequency in dollars
{% enddocs %}

{% docs subscription_currency %}
Subscription currency (AUD or USD)
{% enddocs %}

{% docs subscription_start_date %}
Subscription start date
{% enddocs %}

{% docs subscription_ended_date %}
Subscription end date (NULL if still active)
{% enddocs %}

{% docs tenure_days %}
Subscription tenure in days. Calculated as: days from start_date to ended_date (if ended) or to CURRENT_DATE (if active).
{% enddocs %}

{% docs tenure_months %}
Subscription tenure in months. Calculated as: months from start_date to ended_date (if ended) or to CURRENT_DATE (if active).
{% enddocs %}

{% docs is_active %}
Flag indicating if subscription is currently active (status = 'active')
{% enddocs %}

{% docs is_churned %}
Flag indicating if subscription has been cancelled (status = 'cancelled')
{% enddocs %}

{# ============================================ #}
{# INVOICE ATTRIBUTES #}
{# ============================================ #}

{% docs invoice_created_at %}
Timestamp when invoice was created
{% enddocs %}

{% docs due_date %}
Invoice payment due date
{% enddocs %}

{% docs fully_paid_on_date %}
Date invoice was fully paid (NULL if unpaid)
{% enddocs %}

{% docs invoice_status %}
Invoice status (PAID, AUTHORISED, VOIDED, DRAFT)
{% enddocs %}

{% docs total_amount %}
Total invoice amount
{% enddocs %}

{% docs amount_due %}
Amount still unpaid
{% enddocs %}

{% docs currency_rate_to_aud %}
Foreign exchange rate to AUD
{% enddocs %}

{% docs salesperson %}
Salesperson associated with the invoice
{% enddocs %}

{% docs invoice_date %}
Invoice date (created date cast as DATE)
{% enddocs %}

{% docs invoice_month %}
Invoice month start date (DATE_TRUNC to month)
{% enddocs %}

{% docs invoice_year %}
Invoice year
{% enddocs %}

{% docs is_paid %}
Flag indicating if invoice is fully paid (status = 'PAID')
{% enddocs %}

{# ============================================ #}
{# INVOICE LINE ITEM ATTRIBUTES #}
{# ============================================ #}

{% docs line_amount %}
Line item amount
{% enddocs %}

{% docs line_currency_code %}
Line currency - always matches parent invoice currency
{% enddocs %}

{% docs description %}
Line item description (free text)
{% enddocs %}

{% docs is_ticket_charge %}
Flag indicating if this line item is a Pay Per Removal charge (ticket_id IS NOT NULL)
{% enddocs %}

{% docs is_missing_product_id %}
Flag indicating if product_id is missing (data quality check)
{% enddocs %}

{# ============================================ #}
{# REMOVAL TICKET ATTRIBUTES #}
{# ============================================ #}

{% docs ticket_created_at %}
Timestamp when ticket was created
{% enddocs %}

{% docs ticket_last_updated %}
Timestamp when ticket was last updated
{% enddocs %}

{% docs removal_status %}
Ticket status (Successful, Unsuccessful, In Progress, Not Started). Standardizes case and spacing from source.
{% enddocs %}

{% docs platform %}
Platform where content is being removed (Google, Glassdoor, Other)
{% enddocs %}

{% docs successfully_removed_date %}
Date content was successfully removed (NULL if not successful)
{% enddocs %}

{% docs removal_price %}
Charge amount if removal is successful (for Pay Per Removal billing)
{% enddocs %}

{% docs billing_type %}
How the ticket is billed (Pay Per Removal or Included in Retainer)
{% enddocs %}

{% docs ticket_date %}
Ticket created date (created_at cast as DATE)
{% enddocs %}

{% docs ticket_month %}
Ticket month start date (DATE_TRUNC to month)
{% enddocs %}

{% docs ticket_year %}
Ticket year
{% enddocs %}

{% docs is_successful %}
Flag indicating if removal was successful (removal_status = 'Successful')
{% enddocs %}

{% docs is_unsuccessful %}
Flag indicating if removal was unsuccessful (removal_status = 'Unsuccessful')
{% enddocs %}

{% docs is_completed %}
Flag indicating if ticket is completed (status is Successful or Unsuccessful)
{% enddocs %}

{# ============================================ #}
{# AGGREGATED METRICS - INVOICE #}
{# ============================================ #}

{% docs invoice_count %}
Total number of invoices
{% enddocs %}

{% docs paid_invoice_count %}
Number of paid invoices
{% enddocs %}

{% docs total_invoice_revenue %}
Total revenue from paid invoices
{% enddocs %}

{% docs last_invoice_date %}
Date of most recent invoice
{% enddocs %}

{% docs first_invoice_date %}
Date of first invoice
{% enddocs %}

{# ============================================ #}
{# AGGREGATED METRICS - TICKETS #}
{# ============================================ #}

{% docs total_tickets %}
Total number of removal tickets
{% enddocs %}

{% docs successful_tickets %}
Number of successful removal tickets
{% enddocs %}

{% docs unsuccessful_tickets %}
Number of unsuccessful removal tickets
{% enddocs %}

{% docs in_progress_tickets %}
Number of in-progress tickets
{% enddocs %}

{% docs not_started_tickets %}
Number of not-started tickets
{% enddocs %}

{% docs completed_tickets %}
Number of completed tickets (successful + unsuccessful)
{% enddocs %}

{% docs total_removal_revenue %}
Total revenue from Pay Per Removal charges
{% enddocs %}

{% docs last_ticket_date %}
Date of most recent ticket
{% enddocs %}

{% docs first_ticket_date %}
Date of first ticket
{% enddocs %}

{% docs lifetime_tickets %}
Total number of removal tickets (lifetime)
{% enddocs %}

{# ============================================ #}
{# AGGREGATED METRICS - SUBSCRIPTIONS #}
{# ============================================ #}

{% docs total_subscriptions %}
Total number of subscriptions (lifetime)
{% enddocs %}

{% docs active_subscription_count %}
Number of currently active subscriptions
{% enddocs %}

{% docs cancelled_subscription_count %}
Number of cancelled subscriptions
{% enddocs %}

{% docs product_family_count %}
Number of distinct product families customer subscribes to
{% enddocs %}

{# ============================================ #}
{# CALCULATED METRICS #}
{# ============================================ #}

{% docs ticket_success_rate %}
Ticket success rate calculated as: successful_tickets / completed_tickets. Returns NULL if no completed tickets.
{% enddocs %}

{% docs revenue_per_ticket %}
Average revenue per ticket calculated as: total_invoice_revenue / total_tickets. Returns NULL if no tickets.
{% enddocs %}

{% docs average_invoice_amount %}
Average invoice amount calculated as: total_invoice_revenue / invoice_count. Returns NULL if no invoices.
{% enddocs %}

{% docs ltv_estimate %}
Lifetime value estimate calculated as: subscription_amount * tenure_days / 30. Approximates total subscription value.
{% enddocs %}

{% docs line_item_percentage %}
Line item percentage of total invoice calculated as: (line_amount / total_amount) * 100
{% enddocs %}

{% docs current_mrr %}
Current Monthly Recurring Revenue calculated as: SUM(subscription_amount) for active subscriptions
{% enddocs %}

{% docs lifetime_revenue %}
Total revenue from paid invoices (lifetime)
{% enddocs %}

{% docs lifetime_subscription_revenue %}
Total revenue from subscription fees only
{% enddocs %}

{% docs lifetime_removal_revenue %}
Total revenue from Pay Per Removal charges only
{% enddocs %}

{% docs total_invoices %}
Total number of invoices (lifetime)
{% enddocs %}

{% docs paid_invoices %}
Number of paid invoices (lifetime)
{% enddocs %}

{% docs average_ticket_price %}
Average removal price calculated as: lifetime_removal_revenue / successful_tickets. Returns NULL if no successful tickets.
{% enddocs %}

{% docs customer_lifetime_value %}
Customer Lifetime Value calculated as: lifetime_revenue + (current_mrr * 12). Combines historical revenue with projected annual value.
{% enddocs %}

{% docs health_score %}
Customer health score (0-100) calculated as: recent_invoice_activity (40pts) + mrr_level (30pts) + ticket_activity (20pts) + product_diversification (10pts). Returns 0 for churned customers.
{% enddocs %}

{% docs customer_segment %}
Customer segment based on MRR and status: 'Churned' (no active subs), 'Enterprise' (MRR >= 1000), 'Growth' (MRR >= 500), 'Standard' (MRR >= 100), 'Starter' (MRR < 100)
{% enddocs %}

{% docs success_rate %}
Success rate calculated as: successful_tickets / completed_tickets. Returns NULL if no completed tickets.
{% enddocs %}

{% docs average_ticket_value %}
Average removal price for successful tickets
{% enddocs %}

{# ============================================ #}
{# SURROGATE KEYS #}
{# ============================================ #}

{% docs customer_key %}
Surrogate key for customer dimension (generated hash)
{% enddocs %}

{% docs product_key %}
Surrogate key for product dimension (generated hash)
{% enddocs %}

{% docs date_key %}
Date in YYYY-MM-DD format (Primary Key for date dimension)
{% enddocs %}

{% docs subscription_month_key %}
Surrogate key for subscription-month combination (generated hash)
{% enddocs %}

{% docs invoice_line_key %}
Surrogate key for invoice line item (generated hash)
{% enddocs %}

{% docs ticket_key %}
Surrogate key for removal ticket (generated hash)
{% enddocs %}

{# ============================================ #}
{# DATE DIMENSION ATTRIBUTES #}
{# ============================================ #}

{% docs full_date %}
Full date timestamp
{% enddocs %}

{% docs year %}
Year (YYYY)
{% enddocs %}

{% docs quarter %}
Quarter (1-4)
{% enddocs %}

{% docs month %}
Month number (1-12)
{% enddocs %}

{% docs month_name %}
Month name (January, February, etc.)
{% enddocs %}

{% docs week %}
Week of year (1-53)
{% enddocs %}

{% docs day %}
Day of month (1-31)
{% enddocs %}

{% docs day_of_week %}
Day of week number (1=Monday, 7=Sunday)
{% enddocs %}

{% docs day_name %}
Day name (Monday, Tuesday, etc.)
{% enddocs %}

{% docs month_start_date %}
First day of the month
{% enddocs %}

{% docs quarter_start_date %}
First day of the quarter
{% enddocs %}

{% docs year_start_date %}
First day of the year
{% enddocs %}

{% docs is_weekend %}
Flag indicating if date is Saturday or Sunday
{% enddocs %}

{% docs is_month_start %}
Flag indicating if date is the first day of a month
{% enddocs %}

{% docs is_month_end %}
Flag indicating if date is the last day of a month
{% enddocs %}

{% docs is_quarter_start %}
Flag indicating if date is the first day of a quarter
{% enddocs %}

{% docs is_year_start %}
Flag indicating if date is the first day of a year
{% enddocs %}

{# ============================================ #}
{# FACT TABLE SPECIFIC METRICS #}
{# ============================================ #}

{% docs mrr %}
Monthly Recurring Revenue
{% enddocs %}

{% docs is_first_month %}
Flag indicating if this is the subscription's first month
{% enddocs %}

{% docs is_last_month %}
Flag indicating if this is the subscription's last month (before churn)
{% enddocs %}

{% docs months_since_start %}
Number of months since subscription started
{% enddocs %}

{% docs invoice_currency_code %}
Invoice currency (AUD or USD)
{% enddocs %}

{% docs tickets_last_30_days %}
Number of tickets in the last 30 days
{% enddocs %}

{% docs tickets_last_90_days %}
Number of tickets in the last 90 days
{% enddocs %}

{% docs recent_success_rate %}
Recent ticket success rate (last 90 days)
{% enddocs %}

{% docs risk_category %}
Customer risk category: 'Healthy', 'Monitor', 'Medium Risk', 'High Risk', or 'Churned'
{% enddocs %}

{# ============================================ #}
{# MART SPECIFIC METRICS #}
{# ============================================ #}

{% docs new_subscriptions %}
Number of new subscriptions started this month
{% enddocs %}

{% docs churned_subscriptions %}
Number of subscriptions cancelled this month
{% enddocs %}

{% docs net_change %}
Net change in subscriptions (new - churned)
{% enddocs %}

{% docs total_mrr %}
Total Monthly Recurring Revenue for this period
{% enddocs %}

{% docs churn_rate %}
Churn rate calculated as: churned_subscriptions / (beginning_subscriptions + new_subscriptions). Returns NULL if denominator is 0.
{% enddocs %}

{% docs mrr_growth_rate %}
MRR growth rate calculated as: (current_period_mrr - prior_period_mrr) / prior_period_mrr. Returns NULL if prior period is 0.
{% enddocs %}

{% docs average_subscription_value %}
Average subscription value calculated as: total_mrr / ending_subscriptions
{% enddocs %}

{% docs dbt_updated_at %}
Timestamp when the record was last updated by dbt
{% enddocs %}

{# ============================================ #}
{# ADDITIONAL CUSTOMER METRICS #}
{# ============================================ #}

{% docs lifetime_subscription_count %}
Total number of subscriptions (lifetime) - all subscriptions customer has ever had
{% enddocs %}

{% docs lifetime_successful_tickets %}
Number of successful removal tickets (lifetime)
{% enddocs %}

{% docs lifetime_unsuccessful_tickets %}
Number of unsuccessful removal tickets (lifetime)
{% enddocs %}

{% docs customer_churn_rate %}
Customer churn rate calculated as: churned_subscriptions / lifetime_subscriptions
{% enddocs %}

{% docs lifetime_success_rate %}
Lifetime ticket success rate calculated as: lifetime_successful_tickets / lifetime_tickets
{% enddocs %}

{% docs first_subscription_date %}
Date of customer's first subscription
{% enddocs %}

{% docs latest_active_subscription_date %}
Date of most recent active subscription start
{% enddocs %}

{% docs latest_churn_date %}
Date of most recent subscription cancellation
{% enddocs %}

{% docs days_since_last_activity %}
Days since last invoice or ticket activity
{% enddocs %}

{% docs has_watchdog %}
Flag indicating if customer has WatchDog product (1=yes, 0=no)
{% enddocs %}

{% docs has_retainer %}
Flag indicating if customer has Retainer product (1=yes, 0=no)
{% enddocs %}

{% docs is_currently_active %}
Flag indicating if customer has at least one active subscription
{% enddocs %}

{% docs has_watchdog_product %}
Flag indicating if customer has WatchDog product
{% enddocs %}

{% docs has_retainer_product %}
Flag indicating if customer has Retainer product
{% enddocs %}

{% docs is_at_risk %}
Flag indicating if customer has no activity in 90+ days
{% enddocs %}

{# ============================================ #}
{# SUBSCRIPTION MONTHLY SNAPSHOT FIELDS #}
{# ============================================ #}

{% docs subscription_month %}
Month of the subscription snapshot
{% enddocs %}

{% docs snapshot_month %}
First day of the month for this subscription snapshot
{% enddocs %}

{% docs snapshot_year %}
Year of the snapshot
{% enddocs %}

{% docs snapshot_month_number %}
Month number (1-12) of the snapshot
{% enddocs %}

{% docs snapshot_quarter %}
Quarter (1-4) of the snapshot
{% enddocs %}

{% docs status_in_month %}
Subscription status during this specific month (not_started, active, cancelled, churned)
{% enddocs %}

{% docs was_active_in_month %}
Flag indicating if subscription was active during this specific month
{% enddocs %}

{% docs days_since_start %}
Number of days since subscription started (at snapshot month)
{% enddocs %}

{% docs ending_subscriptions %}
Number of subscriptions at end of month
{% enddocs %}

{% docs beginning_subscriptions %}
Number of subscriptions at beginning of month
{% enddocs %}

