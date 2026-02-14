# Data Roadmap --- Clearvana

## Guiding Focus

-   Restore **trust in data**
-   Create **one source of truth**
-   Model the **business, not MySQL**
-   Optimize for **solo ownership and scalability**

------------------------------------------------------------------------

## Milestone 1 --- Take Control

**Goal:** Understand the chaos and stop metric drift.

**Actions** - Audit MySQL replica, dashboards, and SQL usage\
- Identify conflicting numbers (revenue, churn, customers)\
- Retire duplicate / low-value dashboards

✅ Deliverable: Data inventory + discrepancy report

------------------------------------------------------------------------

## Milestone 2 --- Define the Business Language

**Goal:** One metric = one definition.

**Define core entities**\
Customer, Subscription, Invoice, Payment, Product, Usage

**Lock core metrics**\
MRR / ARR, success rate, retention, churn, expansion, ARPU, LTV

✅ Deliverable: **Metrics Dictionary (company data constitution)**

------------------------------------------------------------------------

## ⭐ Major Milestone --- Build the Analytics Data Model in DBT

**This is the highest-impact investment.**

Move away from querying transactional tables.

**Lean architecture:**\
MySQL → Warehouse → DBT → Single BI tool

**DBT Layers** - **Staging:** clean, type, deduplicate\
- **Intermediate:** reusable logic (subscriptions, invoices)\
- **Marts:** business truth

**Priority models** - `fact_revenue`\
- `dim_customer`\
- `fact_subscription`\
- `fact_usage`

**Non-negotiables**\
Tests, documentation, freshness checks.

✅ Outcome: Trusted semantic layer for the company.

------------------------------------------------------------------------

## Milestone 4 --- Standardize BI

Three tools = guaranteed confusion.

Please pick one or two and sunset the others.

✅ Outcome: Consistent reporting.

------------------------------------------------------------------------

## Milestone 5 --- Executive Reporting

Build a tight leadership dashboard covering:

-   Company health\
-   Revenue movements\
-   Retention & churn\
-   Growth drivers\
-   Product adoption

**Rule:** Leadership should run the business from one dashboard.

------------------------------------------------------------------------

## Milestone 6 --- Create Lightweight Governance

Scale yourself without hiring:

-   Metric change process\
-   Data request workflow\
-   Office hours\
#   "If it's not in DBT --- it's not official."

------------------------------------------------------------------------

## Milestone 7 --- Shift to Strategic Insights

After trust is restored:

-   Pricing optimization\
-   Expansion signals\
-   Churn drivers\
-   Cohort behavior\
-   Sales efficiency

Move from **report builder → strategic partner.**

------------------------------------------------------------------------

## What Success Looks Like

From: *"Which number is correct?"*\
To: *"Check DBT --- that's the source of truth."*

------------------------------------------------------------------------

**Critical mindset:**\
Don't build the most advanced stack --- build the **last foundation the
company needs for the next 3--5 years.**
