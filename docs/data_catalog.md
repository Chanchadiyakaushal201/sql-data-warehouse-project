# Data Catalog for Gold Layer

## Overview

The Gold layer is the business-ready representation of the data warehouse. It is designed for analytical and reporting use cases using a star schema composed of two dimension views and one fact view.

### Gold Layer Objects

- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

---

## 1. `gold.dim_customers`

### Purpose

Stores customer details enriched with demographic and geographic information from the CRM and ERP source systems.

### Source Objects

- `silver.crm_cust_info`
- `silver.erp_cust_az12`
- `silver.erp_loc_a101`

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | BIGINT | Surrogate key uniquely identifying each customer record in the dimension view. Generated using `ROW_NUMBER()`. |
| `customer_id` | INT | Original numerical customer identifier from the CRM source system. |
| `customer_number` | VARCHAR(50) | Alphanumeric business identifier used to track and reference the customer. |
| `first_name` | VARCHAR(50) | Customer's first name. |
| `last_name` | VARCHAR(50) | Customer's last name or family name. |
| `gender` | VARCHAR(50) | Customer's standardized gender. CRM is treated as the master source, while ERP is used as a fallback when CRM contains `n/a`. |
| `marital_status` | VARCHAR(30) | Customer's standardized marital status, such as `Married`, `Single`, or `n/a`. |
| `country` | VARCHAR(50) | Customer's standardized country of residence. |
| `birthdate` | DATE | Customer's date of birth. |
| `create_date` | DATE | Date when the customer record was created in the CRM source system. |

### Business Rules

- The surrogate key is generated using `ROW_NUMBER()` ordered by `cst_id`.
- CRM is the master source for gender information.
- ERP gender is used when the CRM gender value is `n/a`.
- Country information is obtained from the ERP location source.
- Customer records are joined using the customer business key.

---

## 2. `gold.dim_products`

### Purpose

Stores current product information enriched with category, subcategory, and maintenance details.

### Source Objects

- `silver.crm_prd_info`
- `silver.erp_px_cat_g1v2`

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | BIGINT | Surrogate key uniquely identifying each product record in the dimension view. Generated using `ROW_NUMBER()`. |
| `product_id` | INT | Original numerical product identifier from the CRM source system. |
| `product_number` | VARCHAR(50) | Alphanumeric business identifier used to track and reference the product. |
| `product_name` | VARCHAR(50) | Descriptive name of the product. |
| `category_id` | VARCHAR(50) | Identifier linking the product to its category information. |
| `category` | VARCHAR(50) | High-level product classification, such as Bikes or Components. |
| `subcategory` | VARCHAR(50) | Detailed product classification within the main category. |
| `maintenance` | VARCHAR(30) | Indicates whether maintenance is required for the product. |
| `product_line` | VARCHAR(30) | Product line or series, such as Road, Mountain, Touring, or Other Sales. |
| `cost` | INT | Standard or base cost of the product. |
| `start_date` | DATE | Date when the current product record became active. |

### Business Rules

- The surrogate key is generated using `ROW_NUMBER()` ordered by `prd_key` and `prd_start_dt`.
- Product category information is obtained from the ERP category source.
- Only current product records are included.
- Historical product records are excluded using `prd_end_dt IS NULL`.

---

## 3. `gold.fact_sales`

### Purpose

Stores business-ready transactional sales data and connects each sales record to the customer and product dimensions.

### Source Objects

- `silver.crm_sales_details`
- `gold.dim_products`
- `gold.dim_customers`

### Grain

One row represents one product line within a sales order.

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | VARCHAR(50) | Alphanumeric identifier assigned to the sales order. |
| `product_key` | BIGINT | Surrogate key linking the sales record to `gold.dim_products`. |
| `customer_key` | BIGINT | Surrogate key linking the sales record to `gold.dim_customers`. |
| `order_date` | DATE | Date when the sales order was placed. |
| `shipping_date` | DATE | Date when the sales order was shipped. |
| `due_date` | DATE | Date when the sales order was expected to be completed or delivered. |
| `sales_amount` | INT | Total sales amount for the sales line. |
| `quantity` | INT | Number of product units included in the sales line. |
| `price` | INT | Selling price per product unit. |

### Relationships

| Fact Column | Related Dimension | Dimension Column | Cardinality |
|---|---|---|---|
| `customer_key` | `gold.dim_customers` | `customer_key` | Many-to-one |
| `product_key` | `gold.dim_products` | `product_key` | Many-to-one |

### Business Rules

- `product_key` is retrieved by matching `sls_prd_key` with `product_number`.
- `customer_key` is retrieved by matching `sls_cust_id` with `customer_id`.
- Left joins are used so unmatched source records remain visible for data-quality validation.
- Missing dimension references are checked in `quality_checks_gold.sql`.

---

## Gold Layer Data Model

```text
                    gold.dim_customers
                    ------------------
                    customer_key
                          |
                          | 1
                          |
                          | *
                    gold.fact_sales
                    ---------------
                    customer_key
                    product_key
                          |
                          | *
                          |
                          | 1
                    gold.dim_products
                    -----------------
                    product_key
```

---

## PostgreSQL Data Type Note

PostgreSQL returns `BIGINT` from the `ROW_NUMBER()` window function. Therefore, the generated surrogate keys are documented as:

- `customer_key` — `BIGINT`
- `product_key` — `BIGINT`

---

## Usage

The Gold layer is intended to support:

- Business reporting
- Dashboard development
- KPI calculation
- Customer analysis
- Product performance analysis
- Sales trend analysis
- Ad hoc analytical queries
