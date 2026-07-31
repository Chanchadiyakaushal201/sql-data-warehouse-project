/*
===============================================================================
SQL Script: Exploratory Data Analysis (EDA)
===============================================================================
Author      : Kaushal Chanchadiya
Project     : SQL Data Warehouse Project
Database    : PostgreSQL
Schema      : gold

Description:
    This script performs exploratory data analysis (EDA) on the Gold layer of
    the data warehouse.

    The objective is to understand the overall structure, quality, and
    distribution of the business-ready data before performing advanced
    analytical queries and building dashboards.

Analysis Sections:
    • Database Exploration
    • Dimensions Exploration
    • Date Exploration
    • Measures Exploration
    • Magnitude Analysis
    • Ranking Analysis

Source Views:
    • gold.dim_customers
    • gold.dim_products
    • gold.fact_sales

Analysis Objectives:
    • Explore the overall database structure and available business entities.
    • Understand customer, product, and sales dimensions.
    • Examine the available date range and customer age distribution.
    • Calculate key business measures and dataset statistics.
    • Analyze data magnitude across countries, categories, and customers.
    • Identify top-performing and lowest-performing products and customers.

Notes:
    • All queries are executed against the Gold layer.
    • The Gold layer follows a Star Schema optimized for analytical workloads.
    • This script is intended for exploratory analysis only and does not modify
      any database objects or data.
    • Execute this script after the Gold layer views have been successfully
      created.

===============================================================================
*/

-- ====================================================================
-- Database Exploration
-- ====================================================================	

-- Explore All Objects in the Database.

SELECT
	table_catalog,
	table_schema,
	table_name,
	table_type
FROM INFORMATION_SCHEMA.TABLES
WHERE 
	table_schema IN ('bronze', 'silver', 'gold')
ORDER BY 
	table_schema, 
	table_name;

-- Explore All Columns in the Database.

SELECT
	table_catalog,
	table_schema,
	table_name,
	column_name,
	data_type,
	is_nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
	table_schema IN ('bronze', 'silver', 'gold')
ORDER BY 
	table_schema,
	table_name,
	ordinal_position;

-- ====================================================================
-- Dimensions Exploration
-- ====================================================================	

-- Explore All Countries our customers come from.

SELECT DISTINCT
	country
FROM gold.dim_customers;

-- Explore All Categories.

SELECT DISTINCT
	category,
	subcategory,
	product_name
FROM gold.dim_products
ORDER BY 
	category,
	subcategory,
	product_name;

-- ====================================================================
-- Date Exploration
-- ====================================================================	

-- Find the date of first and last order	
-- How many years of sales are available

SELECT	
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	EXTRACT(YEAR FROM MAX(order_date)) - EXTRACT(YEAR FROM MIN(order_date)) AS year_span
FROM gold.fact_sales;

-- Find the oldest customer

SELECT 
    first_name, 
    last_name, 
    birthdate, 
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) AS age
FROM gold.dim_customers
ORDER BY birthdate ASC 
LIMIT 1;

-- Find the youngest customer

SELECT 
    first_name, 
    last_name, 
    birthdate, 
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) AS age
FROM gold.dim_customers
ORDER BY birthdate DESC NULLS LAST
LIMIT 1;

-- ====================================================================
-- Measures Exploration
-- ====================================================================	

-- Find the Total Sales.

SELECT
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Find how many items are sold.

SELECT
	SUM(quantity) AS items_sold
FROM gold.fact_sales;

-- Find the average selling price.

SELECT
	ROUND(AVG(price), 2) AS avg_price
FROM gold.fact_sales; 

-- Find the total number of orders.

SELECT
	COUNT(order_number) AS total_orders
FROM gold.fact_sales;

SELECT 
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales; 

-- Find the total number of products.

SELECT
	COUNT(product_key) AS total_products
FROM gold.dim_products; 		

-- Find the total number of customers.

SELECT
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

-- Find the total number of customers that has placed an order.

SELECT
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the business.

SELECT
	'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
	'Items Sold', SUM(quantity)
FROM gold.fact_sales
UNION ALL
SELECT
	'Avg Price', ROUND(AVG(price), 2)
FROM gold.fact_sales
UNION ALL
SELECT 
	'Total Orders', COUNT(DISTINCT order_number)
FROM gold.fact_sales
UNION ALL
SELECT
	'Total Products', COUNT(DISTINCT product_key)
FROM gold.dim_products
UNION ALL
SELECT
	'Total Customers', COUNT(customer_key)
FROM gold.dim_customers;

-- ====================================================================
-- Magnitude Analysis
-- ====================================================================	

-- Find total customers by countries.

SELECT
	country,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY 
	country
ORDER BY
	total_customers DESC;

-- Find total customers by gender.

SELECT
	gender,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY 
	gender
ORDER BY
	total_customers DESC;

-- Find total customers by marital status.

SELECT
	marital_status,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY 
	marital_status
ORDER BY
	total_customers DESC;

-- Find total products by category.

SELECT
	category,
	COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY 
	category
ORDER BY 
	total_products DESC;

-- What is the average costs in each category?

SELECT
	category,
	ROUND(AVG(cost), 2) AS avg_cost
FROM gold.dim_products
GROUP BY 
	category
ORDER BY 
	avg_cost DESC;

-- What is the total revenue generated for each category?

SELECT
	p.category,
	SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
	   ON s.product_key = p.product_key
GROUP BY
	p.category
ORDER BY
	total_revenue DESC;

-- Find total revenue is generated by each customer.

SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
	   ON c.customer_key = s.customer_key
GROUP BY
	c.first_name,
	c.last_name,
	c.customer_key
ORDER BY
	total_revenue DESC;

-- What is the distribution of sold items across countries?

SELECT
	c.country,
	SUM(s.quantity) AS total_items_sold
FROM gold.fact_sales AS s	
LEFT JOIN gold.dim_customers AS c
	   ON c.customer_key = s.customer_key
GROUP BY 
	c.country
ORDER BY
	total_items_sold DESC;

-- ====================================================================
-- Ranking Analysis
-- ====================================================================	

-- Which 5 products generate the highest revenue?

SELECT
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
       ON s.product_key = p.product_key
GROUP BY 
	p.product_name
ORDER BY 
	total_revenue DESC
LIMIT 5;

-- What are the 5 worst-performing products in terms of sales?

SELECT
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
       ON s.product_key = p.product_key
GROUP BY 
	p.product_name
ORDER BY 
	total_revenue
LIMIT 5;

-- Find the top 10 customers who have generated the highest revenue.

SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
       ON c.customer_key = s.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY
	total_revenue DESC
LIMIT 10;

-- Find the top 5 customers with the fewest orders placed.

SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
       ON c.customer_key = s.customer_key
GROUP BY 
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY
	total_orders
LIMIT 5;
