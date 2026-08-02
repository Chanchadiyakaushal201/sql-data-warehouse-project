/*
===============================================================================
SQL Script: Create Product Report View
===============================================================================
Author      : Kaushal Chanchadiya
Project     : SQL Data Warehouse Project
Database    : PostgreSQL
Schema      : gold

Description:
    This script creates a product-level analytical report that consolidates
    product attributes, sales performance, customer reach, segmentation, and
    key performance indicators.

Object Created:
    • gold.product_report

Source Views:
    • gold.dim_products
    • gold.fact_sales

Report Grain:
    • One row per product with sales activity.

Metrics and Attributes:
    • Product category, subcategory, and cost
    • Product performance segment
    • Total orders, sales, quantity, and customers
    • Last sales date and recency
    • Product sales lifespan
    • Average selling price
    • Average order revenue
    • Average monthly revenue

Notes:
    • Only products with at least one valid sales transaction are included.
    • Product segments are assigned according to total sales.
    • Recency is calculated relative to CURRENT_DATE.
    • Execute this script after the core Gold views have been created.

===============================================================================
*/

-- ====================================================================
-- gold.product_report 
-- ====================================================================	

/*
	1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
	   - average sale price
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
*/

DROP VIEW IF EXISTS gold.product_report;

CREATE OR REPLACE VIEW gold.product_report AS 
WITH base_details AS (
	SELECT
		s.order_number,
		s.order_date,
		s.customer_key,
		s.sales_amount,
		s.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS p
	   	   ON p.product_key = s.product_key
	WHERE s.order_date IS NOT NULL
),
product_agg AS (
	SELECT
		product_key,
	    product_name,
	    category,
	    subcategory,
	    cost,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT customer_key) AS total_customers,
		EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan,
		ROUND(AVG((sales_amount::NUMERIC / NULLIF(quantity, 0))), 2) AS avg_selling_price,	
		MAX(order_date) AS last_order_date
	FROM base_details
	GROUP BY 
		product_key,
	    product_name,
	    category,
	    subcategory,
	    cost
)
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	CASE
		WHEN total_sales > 50000 THEN 'High Performer'
		WHEN total_sales >= 10000 THEN 'Mid Range'
		ELSE 'Low Performer'
	END AS product_segment,
	last_order_date,
	EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order_date)) * 12 + EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order_date)) AS recency,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(total_sales::NUMERIC / total_orders, 2)
	END AS avg_order_revenue,
	CASE
		WHEN lifespan = 0 THEN total_sales::NUMERIC
		ELSE ROUND(total_sales::NUMERIC / lifespan, 2)
	END AS avg_monthly_revenue
FROM product_agg;

SELECT *
FROM gold.product_report
