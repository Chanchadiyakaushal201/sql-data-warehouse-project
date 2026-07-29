# Naming Conventions

This document describes the naming standards used throughout the SQL Data Warehouse project.

## General Principles

- Use **snake_case** (`customer_key`, `order_date`).
- Use **lowercase** for all database objects.
- Use **English** names.
- Avoid spaces, special characters, and SQL reserved keywords.
- Keep naming consistent across all warehouse layers.

---

# Schema Naming

| Schema | Purpose |
|---------|---------|
| `bronze` | Raw data from source systems |
| `silver` | Cleaned and transformed data |
| `gold` | Business-ready analytical views |

---

# Table & View Naming

## Bronze & Silver

Pattern:

```text
<source_system>_<entity>
```

Examples:

```text
crm_cust_info
crm_prd_info
crm_sales_details
erp_cust_az12
erp_loc_a101
erp_px_cat_g1v2
```

---

## Gold

Pattern:

```text
<category>_<entity>
```

Examples:

```text
dim_customers
dim_products
fact_sales
```

| Prefix | Meaning |
|---------|---------|
| `dim_` | Dimension view |
| `fact_` | Fact view |

---

# Column Naming

Use meaningful business names in the Gold layer.

Examples:

| Source | Gold |
|--------|------|
| `cst_id` | `customer_id` |
| `cst_key` | `customer_number` |
| `prd_nm` | `product_name` |
| `sls_ord_num` | `order_number` |
| `sls_sales` | `sales_amount` |

Date columns use the suffix `_date`.

Examples:

```text
order_date
shipping_date
due_date
create_date
```

---

# Key Naming

| Suffix | Purpose | Example |
|---------|----------|---------|
| `_key` | Surrogate Key | `customer_key` |
| `_id` | Source Identifier | `customer_id` |
| `_number` | Business Identifier | `order_number` |

---

# Stored Procedures

Loading procedures follow the pattern:

```text
load_<layer>
```

Examples:

```text
load_bronze()
load_silver()
```

The Gold layer uses **views**, so no `load_gold()` procedure is required.

---

# SQL Script Naming

| Prefix | Purpose |
|---------|---------|
| `ddl_` | Table/View creation |
| `load_` | Data loading |
| `quality_checks_` | Data validation |

Examples:

```text
ddl_bronze.sql
load_silver.sql
quality_checks_gold.sql
```

---

# Source Abbreviations

| Abbreviation | Meaning |
|--------------|---------|
| `crm` | Customer Relationship Management |
| `erp` | Enterprise Resource Planning |
| `cst` | Customer |
| `prd` | Product |
| `sls` | Sales |
| `cat` | Category |
| `dt` | Date |

---

## Summary

The project follows a simple naming strategy:

```text
Bronze → Source-aligned names
Silver → Source-aligned cleaned data
Gold   → Business-friendly analytical names
```
