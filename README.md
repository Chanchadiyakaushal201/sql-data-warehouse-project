# 🏗 SQL Data Warehouse Project

> An end-to-end SQL Data Warehouse built using PostgreSQL, following the Medallion Architecture (Bronze → Silver → Gold) to transform raw CRM and ERP data into a business-ready analytical model, with advanced SQL analytics and interactive Power BI dashboards.

<p align="center">

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-025E8C?style=for-the-badge)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github)

</p>

---

# 📖 Table of Contents

- [Project Overview](#-project-overview)
- [Business Problem](#-business-problem)
- [Project Objectives](#-project-objectives)
- [Project Architecture](#-project-architecture)
- [Data Flow](#-data-flow)
- [Data Model (Star Schema)](#-data-model-star-schema)
- [ETL Pipeline](#-etl-pipeline)
- [Medallion Architecture](#-medallion-architecture)
- [Data Warehouse Layers](#-data-warehouse-layers)
  - Bronze Layer
  - Silver Layer
  - Gold Layer
- [Data Quality & Validation](#-data-quality--validation)
- [Exploratory Data Analysis (EDA)](#-exploratory-data-analysis-eda)
- [Advanced SQL Analytics](#-advanced-sql-analytics)
- [Analytical Report Views](#-analytical-report-views)
- [Power BI Dashboard](#-power-bi-dashboard)
- [Repository Structure](#-repository-structure)
- [Technology Stack](#-technology-stack)
- [Skills Demonstrated](#-skills-demonstrated)
- [Future Improvements](#-future-improvements)
- [Acknowledgements](#-acknowledgements)
- [License](#-license)

---

# 📌 Project Overview

Modern organizations generate data from multiple operational systems. However, this raw data is often inconsistent, duplicated, and unsuitable for business reporting.

This project demonstrates how to design and implement a modern SQL Data Warehouse using PostgreSQL by integrating CRM and ERP source systems into a centralized analytical model.

The solution follows the **Medallion Architecture**, transforming raw operational data into trusted business-ready datasets through structured ETL processes.

The final Gold layer is modeled as a **Star Schema** and connected directly to **Power BI**, enabling interactive dashboards for executive reporting, customer analytics, and product performance analysis.

---

# 💼 Business Problem

Business data typically exists across multiple operational systems, making it difficult to produce consistent and reliable reports.

Common challenges include:

- Data spread across CRM and ERP systems
- Duplicate and inconsistent records
- Missing or invalid values
- Lack of a centralized analytical model
- Slow and repetitive reporting processes

To address these challenges, this project builds a structured SQL Data Warehouse that standardizes data, improves quality, and provides a single source of truth for business analytics.

---

# 🎯 Project Objectives

The primary objectives of this project are:

- Design a scalable SQL Data Warehouse using PostgreSQL.
- Implement the Medallion Architecture (Bronze → Silver → Gold).
- Integrate CRM and ERP source systems into a unified analytical model.
- Perform data cleaning, validation, and standardization.
- Design a Star Schema optimized for reporting.
- Create reusable SQL analytical reports.
- Build interactive Power BI dashboards directly from the Gold layer.
- Demonstrate an end-to-end analytics workflow from raw data to business insights.

---

# 🏛 Project Architecture

The overall solution follows a layered architecture that separates raw ingestion, data transformation, and business reporting.

<p align="center">
<img src="https://github.com/Chanchadiyakaushal201/sql-data-warehouse-project/blob/b14c87c45b607b2dd1d3fb894b9f5c514db3bdab/docs/data_architecture.png" width="900">
</p>

The architecture consists of:

- **Bronze Layer** – Raw ingestion of CRM and ERP data.
- **Silver Layer** – Data cleansing, validation, and transformation.
- **Gold Layer** – Business-ready dimensional model and analytical report views.
- **Power BI** – Interactive dashboards powered directly from the Gold layer.

# 🔄 Data Flow

The data warehouse integrates data from two independent business systems:

- **CRM (Customer Relationship Management)** – Customer, Product, and Sales data.
- **ERP (Enterprise Resource Planning)** – Customer, Location, and Product Category data.

The ETL pipeline follows a layered approach where raw data is ingested into the Bronze layer, transformed in the Silver layer, and modeled into business-ready views in the Gold layer before being consumed by Power BI.

<p align="center">
<img src="https://github.com/Chanchadiyakaushal201/sql-data-warehouse-project/blob/e03099472280afd6ae2bbbec89d9d4a4d854d4f5/docs/data_flow.png" width="900">
</p>

### Data Flow Summary

```text
CRM + ERP Source Systems
          │
          ▼
   Bronze Layer (Raw Data)
          │
          ▼
Silver Layer (Clean & Standardized)
          │
          ▼
 Gold Layer (Star Schema + Reports)
          │
          ▼
      Power BI Dashboard
```

---

# ⭐ Data Model (Star Schema)

The Gold layer is designed using a **Star Schema**, which separates descriptive business entities into **Dimension Views** and transactional data into a **Fact View**.

This design improves:

- Query performance
- Report simplicity
- Data consistency
- Analytical scalability

<p align="center">
<img src="docs/architecture/data_model.png" width="900">
</p>

### Gold Layer Objects

| Object | Type | Purpose |
|---------|------|---------|
| `gold.dim_customers` | Dimension View | Customer information and demographics |
| `gold.dim_products` | Dimension View | Product hierarchy and category details |
| `gold.fact_sales` | Fact View | Sales transactions and business measures |
| `gold.customer_report` | Analytical View | Customer-level aggregated business metrics |
| `gold.product_report` | Analytical View | Product-level aggregated business metrics |

> **Note:**  
> The `customer_report` and `product_report` views are analytical SQL reports built for business reporting. They are intentionally kept separate from the Star Schema because they contain pre-aggregated metrics rather than transactional data.

---

# ⚙ ETL Pipeline

The warehouse follows a structured ETL (Extract, Transform, Load) process to ensure data quality and consistency.

## 1️⃣ Extract

Raw data is imported from CRM and ERP source systems into the **Bronze Layer** without modification.

**Characteristics**

- Raw source data
- No transformations
- Historical preservation
- Full load process

---

## 2️⃣ Transform

The **Silver Layer** performs data cleansing and standardization to prepare the data for analytical use.

Transformation activities include:

- Removing duplicate records
- Standardizing text values
- Handling missing values
- Data type conversion
- Business rule validation
- Date formatting
- Referential integrity checks

---

## 3️⃣ Load

The transformed data is modeled into the **Gold Layer**, where dimensional views and analytical report views are created for reporting and dashboarding.

The Gold layer provides:

- Star Schema
- Business-ready dimensions
- Sales fact view
- Customer analytical report
- Product analytical report

---

# 🥉🥈🥇 Medallion Architecture

This project follows the **Medallion Architecture**, a modern data engineering pattern that organizes data into progressive quality layers.

| Layer | Purpose | Output |
|--------|---------|--------|
| 🥉 Bronze | Raw ingestion from source systems | Raw Tables |
| 🥈 Silver | Cleaned and validated business data | Standardized Tables |
| 🥇 Gold | Business-ready analytical model | Dimension Views, Fact View & Report Views |

### Benefits

- Improves data quality
- Simplifies maintenance
- Supports scalable reporting
- Separates raw and business-ready data
- Enables reusable analytical datasets

---

# 🏗 Architecture Highlights

The SQL Data Warehouse demonstrates several industry-standard design practices:

- ✔ Medallion Architecture (Bronze → Silver → Gold)
- ✔ Layered ETL Pipeline
- ✔ Star Schema Modeling
- ✔ SQL View-Based Gold Layer
- ✔ Customer & Product Analytical Report Views
- ✔ Modular SQL Scripts
- ✔ Reusable Reporting Model
- ✔ Direct Power BI Integration
