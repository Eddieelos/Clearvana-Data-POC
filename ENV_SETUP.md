# DB2POC Environment Setup Instructions

Complete guide to set up the Clearvana Analytics Data Warehouse using dbt and DuckDB.

---

## Prerequisites

### Required Software
- **Python 3.8+** - [Download Python](https://www.python.org/downloads/)
- **pip** (comes with Python)
- **MySQL Client** (for data export) - Already installed on macOS or use `brew install mysql-client`
- **Git** (optional, for version control)

### Access Requirements
- MySQL database access credentials for db2 (Clearvana production database)
- Read permissions on the following MySQL tables:
  - `customers`
  - `recurring_products`
  - `stripe_subscriptions`
  - `xero_invoices`
  - `xero_invoices_items`
  - `xero_repeating_invoices`
  - `removal_tickets` (or sample)

---

## Step-by-Step Setup

### 1. Navigate to Project Directory
```bash
cd /Users/eddieazuelos/db2POC
```

### 2. Create Python Virtual Environment
Creating a virtual environment isolates project dependencies from your system Python.

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment (macOS/Linux)
source .venv/bin/activate

# You should see (.venv) in your terminal prompt
```

**Windows users:**
```bash
.venv\Scripts\activate
```

### 3. Install dbt-duckdb
Install dbt with DuckDB adapter:

```bash
pip install --upgrade pip
pip install dbt-duckdb
```

**Verify installation:**
```bash
dbt --version
```

Expected output:
```
Core:
  - installed: 1.x.x
  - latest:    1.x.x

Plugins:
  - duckdb: 1.x.x
```

### 4. Install dbt Packages
Install required dbt packages (dbt-utils, dbt-expectations):

```bash
dbt deps
```

This will install packages defined in [packages.yml](packages.yml) into the `dbt_packages/` directory.

### 5. Configure MySQL Connection (For Data Export)
The export script needs MySQL credentials. Update the script if needed:

```bash
nano scripts/export_all_tables.sh
```

Update these variables at the top of the script:
```bash
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="your_mysql_user"
DB_PASS="your_mysql_password"
DB_NAME="db2"
```

**Security Note:** For production, use environment variables or `.env` file instead of hardcoding credentials.

### 6. Export Data from MySQL
Run the export script to extract data from MySQL into CSV files:

```bash
# Make script executable (first time only)
chmod +x scripts/export_all_tables.sh

# Run export from project root
./scripts/export_all_tables.sh
```

This will create CSV files in the `seeds/` directory:
- `raw_customers.csv` (~1,430 rows)
- `raw_recurring_products.csv` (~50 rows)
- `raw_stripe_subscriptions.csv` (~1,400 subscriptions since 2024)
- `raw_xero_invoices.csv` (~5K invoices, last 12 months)
- `raw_xero_invoices_items.csv` (~5K line items)
- `raw_xero_repeating_invoices.csv` (small dataset)
- `raw_removal_tickets_sample.csv` (~50K sampled tickets)

**Verify exports:**
```bash
ls -lh seeds/*.csv
```

### 7. Load Seed Data into DuckDB
Load the CSV files into DuckDB tables:

```bash
dbt seed
```

This creates the base raw tables in DuckDB from your CSV files.

### 8. Test dbt Configuration
Verify your dbt setup is working:

```bash
dbt debug
```

All checks should pass with ✅ (green checkmarks).

---

## Running the Project

### Build All Models
```bash
dbt run
```

This will:
1. Create **staging models** (views) - Clean & standardize source data
2. Build **intermediate models** (tables) - Business logic & joins
3. Build **marts models** (tables) - Final analytics tables organized by domain

### Run Specific Models
```bash
# Run only staging models
dbt run --select staging.*

# Run only marts
dbt run --select marts.*

# Run a specific model and its dependencies
dbt run --select +mart_customer_health
```

### Run Data Quality Tests
```bash
dbt test
```

This validates:
- Data freshness
- Uniqueness constraints
- Not-null constraints
- Referential integrity
- Custom business logic tests

### Generate Documentation
```bash
dbt docs generate
dbt docs serve
```

Opens a browser with interactive documentation including:
- Model lineage (DAG)
- Column descriptions
- Test results
- SQL code for each model

---

## Project Structure

```
/Users/eddieazuelos/db2POC/
├── dbt_project.yml          # dbt project configuration
├── profiles.yml             # DuckDB connection settings
├── packages.yml             # dbt package dependencies
│
├── models/
│   ├── staging/             # Cleaned source data (views)
│   ├── intermediate/        # Business logic & joins (tables)
│   └── marts/              # Analytics-ready tables
│       ├── core/           # Dimension tables (customers, products, dates)
│       ├── finance/        # Revenue & subscription metrics
│       └── operations/     # Ticket analytics & operations
│
├── seeds/                   # CSV source files from MySQL
├── macros/                  # Reusable SQL functions
├── tests/                   # Custom data quality tests
├── docs/                    # Additional documentation
└── scripts/                 # Data export utilities
```

---

## Database Location

DuckDB database file: `db2_analytics.duckdb`

This file is created automatically in the project root when you run `dbt seed` or `dbt run` for the first time.

To query directly:
```bash
duckdb db2_analytics.duckdb
```

---

## Helpful Commands

### Development Workflow
```bash
# Build specific model
dbt run --select model_name

# Build model and all downstream dependencies
dbt run --select model_name+

# Build model and all upstream dependencies
dbt run --select +model_name

# Test specific model
dbt test --select model_name

# Compile SQL without running
dbt compile
```

### Cleaning Up
```bash
# Remove compiled files
dbt clean

# Drop all schemas (WARNING: deletes all transformed data)
dbt run-operation drop_all_schemas
```

### Refresh Seed Data
```bash
# Full refresh (truncate and reload)
dbt seed --full-refresh
```

---

## Troubleshooting

### Issue: `dbt: command not found`
**Solution:** Activate your virtual environment:
```bash
source .venv/bin/activate
```

### Issue: `dbt deps` fails
**Solution:** Ensure you have internet connectivity. The packages are downloaded from GitHub.

### Issue: MySQL export fails
**Solution:** 
- Verify MySQL credentials in `scripts/export_all_tables.sh`
- Ensure MySQL server is running
- Check network connectivity to MySQL server
- Verify you have SELECT permissions on required tables

### Issue: `dbt run` fails with compilation errors
**Solution:** 
- Run `dbt deps` first to install packages
- Check model SQL syntax
- Review error messages for specific model failures

### Issue: DuckDB file locked
**Solution:** 
- Close any open DuckDB connections
- Close dbt docs serve (`Ctrl+C`)
- Remove lock file: `rm db2_analytics.duckdb.wal`

---

## Environment Variables (Optional)

For better security, use environment variables for sensitive data:

Create a `.env` file:
```bash
# .env (add this to .gitignore!)
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=your_user
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=db2
```

Load in terminal session:
```bash
export $(cat .env | xargs)
```

Update `scripts/export_all_tables.sh` to use:
```bash
DB_HOST="${MYSQL_HOST:-localhost}"
DB_USER="${MYSQL_USER:-root}"
# etc.
```

---

## Next Steps After Setup

1. **Explore the data:**
   ```bash
   duckdb db2_analytics.duckdb
   SELECT * FROM main.dim_customers LIMIT 10;
   ```

2. **Review documentation:**
   ```bash
   dbt docs serve
   ```

3. **Add custom models:**
   - Create new `.sql` files in `models/`
   - Run `dbt run --select your_new_model`

4. **Schedule refreshes:**
   - Set up cron job to run data export + dbt daily
   - Consider using Airflow/Dagster for orchestration

5. **Connect BI tools:**
   - Connect Tableau/PowerBI/Metabase to `db2_analytics.duckdb`
   - Use marts tables for dashboard queries

---

## Support & Resources

- **dbt Documentation:** https://docs.getdbt.com/
- **DuckDB Documentation:** https://duckdb.org/docs/
- **Project Documentation:** See [MODELS_CREATED.md](MODELS_CREATED.md) and [docs/metric_definitions.md](docs/metric_definitions.md)

---

## Deactivating Virtual Environment

When you're done working:
```bash
deactivate
```

To reactivate later:
```bash
cd /Users/eddieazuelos/db2POC
source .venv/bin/activate
```

---

**Setup complete! 🎉** You now have a fully functional analytics data warehouse.
