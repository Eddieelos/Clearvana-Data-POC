#!/usr/bin/env python3
"""
Add headers to CSV files that are missing them
"""

import os

seeds_dir = os.path.join(os.path.dirname(__file__), '..', 'seeds')

# Define headers for each file
headers = {
    'raw_customers.csv': 'customer_id,created_at,last_updated,name,default_currency,account_manager,country',
    'raw_recurring_products.csv': 'product_id,product_plan_name,product_family_name,subscription_frequency,fee_type,currency,fee_per_frequency,price_for_successful_removal',
    'raw_stripe_subscriptions.csv': 'subscription_id,customer_id,product_id,status,amount_in_dollars,currency,start_date,ended_date',
    'raw_xero_invoices.csv': 'invoice_id,subscription_id,created,status,total_amount,currency_code',
    'raw_xero_invoices_items.csv': 'line_item_id,invoice_id,product_id,product_family_name,currency_code,line_amount,description,ticket_id',
    'raw_xero_repeating_invoices.csv': 'repeating_invoice_id,customer_id,status,currency_code,subscription_frequency,amount_in_dollars,start_date,ended_date',
    'raw_removal_tickets_sample.csv': 'ticket_id,created_at,last_updated,customer_id,removal_status,platform,successfully_removed_date,price_for_successful_removal,currency,billing_type'
}

print("Adding headers to CSV files...")
print("=" * 50)

for filename, header in headers.items():
    filepath = os.path.join(seeds_dir, filename)
    
    if not os.path.exists(filepath):
        print(f"⚠️  {filename} - File not found")
        continue
    
    # Read the existing content
    with open(filepath, 'r') as f:
        first_line = f.readline().strip()
        
        # Check if header already exists
        if first_line == header:
            print(f"✅ {filename} - Header already present")
            continue
        
        # Read all content
        f.seek(0)
        content = f.read()
    
    # Write header + content
    with open(filepath, 'w') as f:
        f.write(header + '\n' + content)
    
    print(f"✅ {filename} - Header added")

print("\n" + "=" * 50)
print("Done! All headers have been added.")
