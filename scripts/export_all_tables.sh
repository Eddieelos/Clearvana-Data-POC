#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
OUTPUT_DIR="$PROJECT_ROOT/seeds"

# Load connection configuration
if [ -f "$PROJECT_ROOT/connection_config.sh" ]; then
    source "$PROJECT_ROOT/connection_config.sh"
    MYSQL_HOST="$DB_HOST"
    MYSQL_PORT="$DB_PORT"
    MYSQL_USER="$DB_USER"
    MYSQL_PASS="$DB_PASS"
    MYSQL_DB="$DB_NAME"
else
    echo "❌ Error: connection_config.sh not found!"
    echo "Please copy connection_config.example.sh to connection_config.sh and configure your credentials."
    exit 1
fi

echo "Exporting Clearvana db2 tables to CSV..."
echo "========================================="

# Export customers
echo "Exporting customers..."
echo "customer_id,created_at,last_updated,name,default_currency,account_manager,country" > $OUTPUT_DIR/raw_customers.csv
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS -D $MYSQL_DB \
  --batch --skip-column-names \
  -e "SELECT * FROM customers" \
  | sed 's/\t/,/g;s/NULL//g' >> $OUTPUT_DIR/raw_customers.csv

# Export recurring_products
echo "Exporting recurring_products..."
echo "product_id,product_plan_name,product_family_name,subscription_frequency,fee_type,currency,fee_per_frequency,price_for_successful_removal" > $OUTPUT_DIR/raw_recurring_products.csv
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS -D $MYSQL_DB \
  --batch --skip-column-names \
  -e "SELECT * FROM recurring_products" \
  | sed 's/\t/,/g;s/NULL//g' >> $OUTPUT_DIR/raw_recurring_products.csv

# Export stripe_subscriptions (last 2 years)
echo "Exporting stripe_subscriptions..."
echo "subscription_id,customer_id,product_id,status,amount_in_dollars,currency,start_date,ended_date" > $OUTPUT_DIR/raw_stripe_subscriptions.csv
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS -D $MYSQL_DB \
  --batch --skip-column-names \
  -e "SELECT * FROM stripe_subscriptions WHERE start_date >= '2024-01-01'" \
  | sed 's/\t/,/g;s/NULL//g' >> $OUTPUT_DIR/raw_stripe_subscriptions.csv

# Export xero_invoices (last 12 months)
echo "Exporting xero_invoices..."
echo "invoice_id,customer_id,created,status,due_date,fully_paid_on_date,total_amount,amount_due,currency_code,currency_rate_to_aud,subscription_id,repeating_invoice_id,salesperson" > $OUTPUT_DIR/raw_xero_invoices.csv
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS -D $MYSQL_DB \
  --batch --skip-column-names \
  -e "SELECT * FROM xero_invoices WHERE created >= '2025-01-01'" \
  | sed 's/\t/,/g;s/NULL//g' >> $OUTPUT_DIR/raw_xero_invoices.csv

# Export xero_invoices_items (last 12 months)
echo "Exporting xero_invoices_items..."
echo "line_item_id,invoice_id,product_id,product_family_name,currency_code,line_amount,description,ticket_id" > $OUTPUT_DIR/raw_xero_invoices_items.csv
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS -D $MYSQL_DB \
  --batch --skip-column-names \
  -e "SELECT xii.* FROM xero_invoices_items xii 
      INNER JOIN xero_invoices xi ON xii.invoice_id = xi.invoice_id 
      WHERE xi.created >= '2025-01-01'" \
  | sed 's/\t/,/g;s/NULL//g' >> $OUTPUT_DIR/raw_xero_invoices_items.csv

# Export xero_repeating_invoices
echo "Exporting xero_repeating_invoices..."
echo "repeating_invoice_id,customer_id,status,currency_code,subscription_frequency,amount_in_dollars,start_date,ended_date" > $OUTPUT_DIR/raw_xero_repeating_invoices.csv
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS -D $MYSQL_DB \
  --batch --skip-column-names \
  -e "SELECT * FROM xero_repeating_invoices" \
  | sed 's/\t/,/g;s/NULL//g' >> $OUTPUT_DIR/raw_xero_repeating_invoices.csv

# Export removals_tickets (SAMPLED - last 6 months, every 10th row)
echo "Exporting removals_tickets (sampled)..."
echo "ticket_id,created_at,last_updated,customer_id,removal_status,platform,successfully_removed_date,price_for_successful_removal,currency,billing_type" > $OUTPUT_DIR/raw_removal_tickets_sample.csv
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS -D $MYSQL_DB \
  --batch --skip-column-names \
  -e "SELECT * FROM (
        SELECT @row := @row + 1 AS rownum, rt.*
        FROM (SELECT @row := 0) r, removals_tickets rt
        WHERE rt.created_at >= '2025-07-01'
      ) ranked 
      WHERE MOD(rownum, 10) = 0 
      LIMIT 50000" \
  | cut -f2- | sed 's/\t/,/g;s/NULL//g' >> $OUTPUT_DIR/raw_removal_tickets_sample.csv

echo ""
echo "✅ Export complete!"
echo ""
echo "Files created in $OUTPUT_DIR:"
ls -lh $OUTPUT_DIR/*.csv
echo ""
echo "Next steps:"
echo "1. cd .."
echo "2. dbt seed"
echo "3. dbt run"
