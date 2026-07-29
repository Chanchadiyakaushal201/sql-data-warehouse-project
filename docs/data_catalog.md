# Data Catalog — Gold Layer

## Overview

The Gold layer represents the business-ready analytical model of the data warehouse.

It is designed using a star schema and consists of:

- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

The dimension views contain descriptive business attributes, while the fact view contains transactional sales data and references the dimensions through surrogate keys.

---

## 1. `gold.dim_customers`

### Purpose

Stores customer information enriched with demographic and geographic attributes from the CRM and ERP source systems.

### Source Tables

- `silver.crm_cust_info`
- `silver.erp_cust_az12`
- `silver.erp_loc_a101`

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | BIGINT | Surrogate key uniquely identifying each customer record in the Gold customer dimension. |
| `customer_id` | INTEGER | Original numerical customer identifier from the CRM source system. |
| `customer_number` | VARCHAR(50) | Business identifier used to track and reference the customer. |
| `first_name` | VARCHAR(50) | Customer's first name. |
| `last_name` | VARCHAR(50) | Customer's last name or family name. |
| `country` | VARCHAR(50) | Customer's standardized country of residence. |
| `marital_status` | VARCHAR(50) | Customer's standardized marital status, such as Married, Single, or n/a. |
| `gender` | VARCHAR(50) | Customer's standardized gender. CRM is treated as the primary source, with ERP used as a fallback. |
| `birthdate` | DATE | Customer's date of birth. |
| `create_date` | DATE | Date when the customer record was created in the source system. |

### Business Rules

- CRM is treated as the primary source for gender.
- ERP gender is used when CRM gender is unavailable.
- Country information is retrieved from the ERP location table.
- A surrogate key is generated using `ROW_NUMBER()`.

---

## 2. `gold.dim_products`

### Purpose

Stores current product information enriched with category, subcategory, and maintenance attributes.

### Source Tables

- `silver.crm_prd_info`
- `silver.erp_px_cat_g1v2`

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | BIGINT | Surrogate key uniquely identifying each product record in the Gold product dimension. |
| `product_id` | INTEGER | Original numerical product identifier from the CRM source system. |
| `product_number` | VARCHAR(50) | Business identifier used to track and reference the product. |
| `product_name` | VARCHAR(50) | Descriptive name of the product. |
| `category_id` | VARCHAR(50) | Identifier linking the product to its category information. |
| `category` | VARCHAR(50) | High-level product classification, such as Bikes or Components. |
| `subcategory` | VARCHAR(50) | More detailed classification within the product category. |
| `maintenance_required` | VARCHAR(50) | Indicates whether the product requires maintenance. |
| `cost` | INTEGER | Standard or base cost of the product. |
| `product_line` | VARCHAR(50) | Product line or product series, such as Road, Mountain, Touring, or Other Sales. |
| `start_date` | DATE | Date when the product record became active. |

### Business Rules

- Product category information is enriched from the ERP category table.
- Only current product records are included.
- Historical product records are excluded using:

```sql
WHERE prd_end_dt IS NULL
