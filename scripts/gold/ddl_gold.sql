/*
===============================================================================
DDL Script: Create Gold Layer Views
===============================================================================
Author      : Kaushal Chanchadiya
Project     : SQL Data Warehouse Project
Database    : PostgreSQL
Schema      : gold

Description:
    This script creates the business-ready views for the Gold layer of the
    data warehouse.

    The Gold layer follows a star schema design and integrates cleaned data
    from the Silver layer into customer and product dimensions and a sales
    fact view for analytical and reporting use cases.

Objects Created:
    • gold.dim_customers
    • gold.dim_products
    • gold.fact_sales

Source Layer:
    • silver.crm_cust_info
    • silver.crm_prd_info
    • silver.crm_sales_details
    • silver.erp_cust_az12
    • silver.erp_loc_a101
    • silver.erp_px_cat_g1v2

Model Structure:
    • gold.dim_customers provides customer demographic and geographic details.
    • gold.dim_products provides current product and category details.
    • gold.fact_sales stores transactional sales metrics and links to the
      customer and product dimensions through surrogate keys.

Notes:
    • The Gold layer is implemented using views, so no separate load procedure
      is required.
    • Surrogate keys are generated using ROW_NUMBER().
    • gold.dim_products includes only current product records where
      prd_end_dt IS NULL.
    • Execute this script only after the Silver layer has been successfully
      loaded and validated.

===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_customers;

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	CASE
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is Master For gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ci.cst_marital_status AS marital_status,
	la.cntry AS country,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date	
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON	ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON	ci.cst_key = la.cid;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_products;

CREATE OR REPLACE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pi.prd_key, pi.prd_start_dt) AS product_key,
	pi.prd_id AS product_id,
	pi.prd_key AS product_number,
	pi.prd_nm AS product_name,
	pi.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance AS maintenance,
	pi.prd_line AS product_line,
	pi.prd_cost AS cost,
	pi.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON	pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL; -- Filter out all historical data

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_sales;

CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	ps.product_key,
	cs.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS ps
ON	sd.sls_prd_key = ps.product_number
LEFT JOIN gold.dim_customers AS cs
ON	sd.sls_cust_id = cs.customer_id;
