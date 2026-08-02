/*
===============================================================================
SQL Script: Advanced Data Analytics
===============================================================================
Author      : Kaushal Chanchadiya
Project     : SQL Data Warehouse Project
Database    : PostgreSQL
Schema      : gold

Description:
    This script performs advanced analytical queries on the Gold layer of the
    data warehouse.

    It analyzes sales trends, cumulative performance, product performance,
    category contribution, and customer and product segmentation using CTEs,
    window functions, aggregations, and analytical comparisons.

Analysis Sections:
    • Change Over Time Analysis
    • Cumulative Analysis
    • Performance Analysis
    • Part-to-Whole Analysis
    • Data Segmentation

Source Views:
    • gold.dim_customers
    • gold.dim_products
    • gold.fact_sales

Notes:
    • All queries are read-only and do not modify warehouse data.
    • Calculations use the business-ready Gold layer.
    • Execute this script after the Gold views have been created and validated.
    • Customer and product reports are maintained in separate report scripts.

===============================================================================
*/

-- ====================================================================
-- Change Over Time Analysis
-- ====================================================================	

-- Analyze Sales Performance Over Time.

-- Year 

SELECT
	EXTRACT(YEAR FROM order_date) AS order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_units_sold
FROM gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY
	EXTRACT(YEAR FROM order_date)
ORDER BY
	order_year;

-- Month

WITH month_sales AS (
	SELECT
		DATE_TRUNC('month', order_date)::DATE AS order_month,
		SUM(sales_amount) AS total_sales,
		COUNT(DISTINCT customer_key) AS total_customer,
		SUM(quantity) AS total_units_sold
	FROM gold.fact_sales
	WHERE 
		order_date IS NOT NULL
	GROUP BY
		DATE_TRUNC('month', order_date)
)
SELECT
	TO_CHAR(order_month, 'YYYY-Mon') AS month,
	total_sales,
	total_customer,
	total_units_sold
FROM month_sales
ORDER BY
	order_month;

-- How many new customers were added each year

SELECT
	TO_CHAR(DATE_TRUNC('year', create_date)::DATE, 'YYYY') AS create_year,
	COUNT(customer_key) AS total_customer
FROM gold.dim_customers
GROUP BY
	DATE_TRUNC('year', create_date)::DATE
ORDER BY
	create_year;

-- ====================================================================
-- Cumulative Analysis
-- ====================================================================	

-- Calculate the total sales or avg price per month &
-- the running total of sales over time

WITH month_sales AS (
	SELECT
		DATE_TRUNC('month', order_date)::DATE AS order_month,
		SUM(sales_amount) AS total_sales,
		ROUND(AVG(price), 2) AS avg_price
	FROM gold.fact_sales
	WHERE
		order_date IS NOT NULL
	GROUP BY
		DATE_TRUNC('month', order_date)
)
SELECT
	TO_CHAR(order_month, 'YYYY-Mon') AS month,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales,
	SUM(avg_price) OVER (ORDER BY order_month) AS running_avg_price
FROM month_sales
ORDER BY
	order_month;

-- ====================================================================
-- Performance Analysis
-- ====================================================================	

/* Analyze the yearly performance of products by comparing their sales to
   both the average sales performance of the product and the previous year's sales */

WITH yearly_product_sales AS (
	SELECT
		EXTRACT(YEAR FROM s.order_date) AS order_year,
		p.product_key,
		p.product_name,
		SUM(s.sales_amount) AS current_sales
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS p
		   ON s.product_key = p.product_key
	WHERE 
		s.order_date IS NOT NULL
	GROUP BY
		EXTRACT(YEAR FROM s.order_date),
		p.product_key,
		p.product_name
)
SELECT
	order_year,
	product_key,
	product_name,
	current_sales,
	ROUND(AVG(current_sales) OVER (PARTITION BY product_key), 2) AS avg_sales,
	(current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_key), 2)) AS diff_avg,
	CASE
		WHEN (current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_key), 2)) > 0 THEN 'Above Avg'
		WHEN (current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_key), 2)) < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END avg_change,
	LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) AS pre_sales,
	(current_sales - LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year)) AS diff_pre,
	CASE
		WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year)) > 0 THEN 'Increase'
		WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year)) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END pre_change
FROM yearly_product_sales
ORDER BY
	product_key,
	order_year;

-- ====================================================================
-- Part-To-Whole Analysis
-- ====================================================================	

-- Which categories contribute the most to overall sales?

WITH category_sales AS (
	SELECT
		p.category,
		SUM(s.sales_amount) AS total_sales
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS p
		   ON p.product_key = s.product_key
	GROUP BY
		p.category
)
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((total_sales / SUM(total_sales) OVER()) * 100, 2), '%') AS pct_total 
FROM category_sales
ORDER BY
	total_sales DESC;

-- ====================================================================
-- Data Segmentation 
-- ====================================================================	

/* Segment products into cost ranges and
	count how many products fall into each segment */

WITH product_segments AS (
	SELECT
	product_key,
	product_name,
	cost,
	CASE
		WHEN cost < 100 THEN 'Below 100' 
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END AS cost_range
FROM gold.dim_products
)
SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segments
GROUP BY
	cost_range
ORDER BY 
	total_products DESC;

/* 
	Group Customers into three segments based on their spending behavior:
		- VIP : Customers with at least 12 months of history and spending more than 5000.
		- Regular : Customers with at least 12 months of history but spending 5000 or less.
		- New : Customers with a lifespan less than 12 months.
	AND find the total number of customer by each group.
*/

WITH customer_spend AS (
	SELECT
	c.customer_key,
	SUM(s.sales_amount) AS total_spending,
	MIN(s.order_date) AS first_order,
	MAX(s.order_date) AS last_order,
	(EXTRACT(YEAR FROM AGE(MAX(s.order_date), MIN(s.order_date))) * 12 + EXTRACT(MONTH FROM AGE(MAX(s.order_date), MIN(s.order_date)))) AS lifespan
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
	   ON c.customer_key = s.customer_key
GROUP BY
	c.customer_key
)
SELECT
	CASE
		WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	COUNT(customer_key) AS total_customers
FROM customer_spend
GROUP BY
	customer_segment;