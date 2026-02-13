# Clearvana Analytics - Schema Description

## Overview
This document provides a comprehensive overview of all data models (tables) in the Clearvana Analytics Data Warehouse.

---

## Staging Layer
**Purpose:** Clean and standardize source data from MySQL transactional database

| Model | Description |
|-------|-------------|
| **stg_customers** | Cleaned and standardized customer dimension from MySQL db2.customers. Standardizes country codes and prepares customer attributes for downstream analytics. |
| **stg_products** | Product catalog from MySQL db2.recurring_products. Standardizes product family naming (WatchDog vs Watchdog inconsistencies) and formats pricing information. |
| **stg_subscriptions** | Subscription data from MySQL db2.stripe_subscriptions (2024+). Standardizes subscription status and calculates tenure metrics. |
| **stg_invoices** | Invoice transactions from MySQL db2.xero_invoices (2025+). Every customer charge has a Xero Invoice. Includes date dimensions for time-based analysis. |
| **stg_invoice_items** | Invoice line items from MySQL db2.xero_invoices_items. Only one product_family type per invoice (no PPR Charges mixed with subscription fees). One line item per subscription payment, but multiple PPR Charges can be on one invoice. |
| **stg_removal_tickets** | Removal ticket data from MySQL db2.removals_tickets (sampled). Each record represents an item of content being removed for a customer. Only WatchDog and Retainer customers included. |

---

## Intermediate Layer
**Purpose:** Business logic, joins, and aggregations

| Model | Description |
|-------|-------------|
| **int_subscriptions_enriched** | Enriched subscription data joining subscriptions with customers, products, invoices, and tickets. Provides a comprehensive view of subscription health with all related metrics. |
| **int_invoices_with_products** | Invoice line items enriched with full product information, invoice headers, and calculated percentage contributions. |
| **int_customer_metrics** | Aggregated customer-level metrics combining subscriptions, invoices, and tickets. Used for customer health scoring and segmentation. |
| **int_ticket_success_rates** | Aggregated ticket success rates by customer and product family, used for performance monitoring and account management. |

---

## Marts Layer - Dimensions
**Purpose:** Reusable dimension tables for analytics

| Model | Description |
|-------|-------------|
| **dim_customers** | Customer dimension with aggregated metrics and health scores from int_customer_metrics. |
| **dim_products** | Product dimension with business logic flags. |
| **dim_dates** | Date dimension table covering 2024-2026. |

---

## Marts Layer - Facts
**Purpose:** Transactional and event data for analysis

| Model | Description |
|-------|-------------|
| **fct_subscriptions_monthly** | Monthly subscription snapshots for trend analysis. Each row represents one subscription in one month, allowing you to see active subscriptions at any point in time. |
| **fct_invoices** | Invoice line items fact table with product attribution. |
| **fct_removal_tickets** | Removal tickets fact table. |

---

## Marts Layer - Aggregates
**Purpose:** Pre-aggregated metrics for dashboards and reporting

| Model | Description |
|-------|-------------|
| **mart_subscription_metrics** | Pre-aggregated subscription metrics by month and product family for dashboards. |
| **mart_customer_health** | Customer health dashboard with risk scoring and recent activity metrics. |

---

## Model Count Summary
- **Staging Models:** 6
- **Intermediate Models:** 4
- **Dimension Tables:** 3
- **Fact Tables:** 3
- **Mart Aggregates:** 2
- **Total Models:** 18

---

*Generated: February 14, 2026*
