/*
===============================================================================
SQL Script: Create Customer Report View
===============================================================================
Author      : Kaushal Chanchadiya
Project     : SQL Data Warehouse Project
Database    : PostgreSQL
Schema      : gold

Description:
    This script creates a customer-level analytical report that consolidates
    customer details, purchasing activity, behavioral segments, and key
    performance indicators.

Object Created:
    • gold.customer_report

Source Views:
    • gold.dim_customers
    • gold.fact_sales

Report Grain:
    • One row per purchasing customer.

Metrics and Attributes:
    • Customer age and age group
    • Customer segment
    • Total orders, sales, quantity, and products
    • Last order date and recency
    • Customer lifespan
    • Average order value
    • Average monthly spend

Notes:
    • Only customers with at least one valid sales transaction are included.
    • Customer segments are based on lifespan and total spending.
    • Recency and age are calculated relative to CURRENT_DATE.
    • Execute this script after the core Gold views have been created.

===============================================================================
*/

-- ====================================================================
-- gold.customer_report 
-- ====================================================================	

/*
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
*/

DROP VIEW IF EXISTS gold.customer_report;

CREATE OR REPLACE VIEW gold.customer_report AS 
WITH base_details AS (
	SELECT
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
		EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.birthdate)) AS age
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customers AS c
	  	   ON c.customer_key = s.customer_key
	WHERE s.order_date IS NOT NULL
),
customer_agg AS (
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan
	FROM base_details
	GROUP BY 
		customer_key,
		customer_number,
		customer_name,
		age
)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age IS NULL THEN 'Unknown'
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE 'Above 50'
	END AS age_group,
	CASE
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segments,
	last_order_date,
	EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order_date)) * 12 + EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order_date)) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(total_sales::NUMERIC / total_orders, 2)
	END AS avg_order_value,
	CASE
		WHEN lifespan = 0 THEN total_sales::NUMERIC
		ELSE ROUND((total_sales::NUMERIC / lifespan), 2)
	END AS avg_monthly_spend
FROM customer_agg;

SELECT *
FROM gold.customer_report
