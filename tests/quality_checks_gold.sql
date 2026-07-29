/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Author      : Kaushal Chanchadiya
Project     : SQL Data Warehouse Project
Database    : PostgreSQL
Schema      : gold

Description:
    This script validates the integrity and consistency of the Gold layer,
    ensuring that the business-ready views are suitable for analytical and
    reporting purposes.

Quality Checks Performed:
    • Verify uniqueness of surrogate keys in dimension views.
    • Validate referential integrity between the fact view and dimension views.
    • Detect orphaned records caused by missing customer or product references.

Expected Results:
    • Dimension surrogate keys should be unique.
    • All fact records should successfully match corresponding customer and
      product dimension records.
    • All queries should return zero rows under normal conditions.

Usage:
    Execute this script after creating the Gold layer views to verify that the
    analytical model is complete and free from data integrity issues.

===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results

SELECT 
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY
	customer_key
HAVING
	COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================	

-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 

SELECT 
	product_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY
	product_key
HAVING
	COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================	

-- Check referential integrity between the fact view and dimension views
-- Expectation: No results

SELECT 
	*
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;


