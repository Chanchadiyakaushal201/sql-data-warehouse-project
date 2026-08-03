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
<img src="docs/architecture/data_architecture.png" width="900">
</p>

The architecture consists of:

- **Bronze Layer** – Raw ingestion of CRM and ERP data.
- **Silver Layer** – Data cleansing, validation, and transformation.
- **Gold Layer** – Business-ready dimensional model and analytical report views.
- **Power BI** – Interactive dashboards powered directly from the Gold layer.
