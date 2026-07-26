/*
=============================================================
Create Medallion Architecture Schemas
=============================================================

Script Purpose:
    This script creates the three schemas used in the
    Medallion Architecture.

Schemas:
    bronze  - Raw ingested source data
    silver  - Cleaned and standardized data
    gold    - Business-ready analytical models

=============================================================
*/

--- Create Bronze Schema ---

CREATE SCHEMA IF NOT EXISTS bronze;

--- Create Silver Schema ---

CREATE SCHEMA IF NOT EXISTS silver;

--- Create Gold Schema ---

CREATE SCHEMA IF NOT EXISTS gold;