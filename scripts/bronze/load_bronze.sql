/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source → Bronze)
===============================================================================
Author      : Kaushal Chanchadiya
Project     : SQL Data Warehouse Project
Database    : PostgreSQL
Schema      : bronze

Description:
    This stored procedure loads raw data from the CRM and ERP source CSV files
    into the Bronze layer of the data warehouse.

    The procedure performs the following tasks:
        • Truncates Bronze tables before loading.
        • Loads CSV files using PostgreSQL COPY.
        • Displays progress messages using RAISE NOTICE.
        • Measures the loading duration for each table.
        • Measures the total execution time.
        • Reports the number of rows loaded.
        • Handles and reports errors using EXCEPTION blocks.

Source Systems:
    • CRM
        - cust_info.csv
        - prd_info.csv
        - sales_details.csv

    • ERP
        - CUST_AZ12.csv
        - LOC_A101.csv
        - PX_CAT_G1V2.csv

Execution:
    CALL bronze.load_bronze();

Notes:
    • This procedure is designed for the Bronze layer of the Medallion
      Architecture.
    • PostgreSQL COPY requires the database server to have access to the CSV
      files.
    • Update the file paths inside the procedure if the project directory
      changes.

===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE 
	v_start_time TIMESTAMP;
	v_end_time TIMESTAMP;
	v_batch_start_time TIMESTAMP;
	v_batch_end_time TIMESTAMP;
	v_rows INT;

	v_error_msg TEXT;
    v_error_state TEXT;
	v_error_context TEXT;	
BEGIN
	v_batch_start_time := clock_timestamp();
	
	RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';
	
	-- ===========================================================================
	-- CRM Tables
	-- ===========================================================================

	RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';
	
	-- ==========================================================
	-- bronze.crm_cust_info
	-- ==========================================================

	v_start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info;

	RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
	COPY bronze.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
	FROM 'D:\sql_data_warehouse\dataset\source_crm\cust_info.csv'
	WITH (
		FORMAT CSV,
		HEADER TRUE,
		DELIMITER ','
	);
	
	-- ==========================================================
	-- Capture and display rows affected
	-- ==========================================================

	GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE '( % rows affected )', v_rows;

	v_end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time))::INT;
    RAISE NOTICE '>> -------------';
	
	-- ==========================================================
	-- bronze.crm_prd_info
	-- ==========================================================

	v_start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
	TRUNCATE TABLE bronze.crm_prd_info;

	RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';	
	COPY bronze.crm_prd_info (
		prd_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	FROM 'D:\sql_data_warehouse\dataset\source_crm\prd_info.csv'
	WITH (
		FORMAT CSV,
		HEADER TRUE,
		DELIMITER ','
	);

	GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE '( % rows affected )', v_rows;

	v_end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time))::INT;
    RAISE NOTICE '>> -------------';
	
	-- ==========================================================
	-- bronze.crm_sales_details
	-- ==========================================================

	v_start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';	
	TRUNCATE TABLE bronze.crm_sales_details;

	RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';		
	COPY bronze.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	FROM 'D:\sql_data_warehouse\dataset\source_crm\sales_details.csv'
	WITH (
		FORMAT CSV,
		HEADER TRUE,
		DELIMITER ','
	);

	GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE '( % rows affected )', v_rows;

	v_end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time))::INT;
    RAISE NOTICE '>> -------------';
	
	-- ===========================================================================
	-- ERP Tables
	-- ===========================================================================

	RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';
	
	-- ==========================================================
	-- bronze.erp_cust_az12
	-- ==========================================================

	v_start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';		
	TRUNCATE TABLE bronze.erp_cust_az12;

	RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';		
	COPY bronze.erp_cust_az12 (
		cid,
		bdate,
		gen
	)
	FROM 'D:\sql_data_warehouse\dataset\source_erp\cust_az12.csv'
	WITH (
		FORMAT CSV,
		HEADER TRUE,
		DELIMITER ','
	);

	GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE '( % rows affected )', v_rows;

	v_end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time))::INT;
    RAISE NOTICE '>> -------------';
	
	-- ==========================================================
	-- bronze.erp_loc_a101
	-- ==========================================================

	v_start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';		
	TRUNCATE TABLE bronze.erp_loc_a101;

	RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';		
	COPY bronze.erp_loc_a101 (
		cid,
		cntry 
	)
	FROM 'D:\sql_data_warehouse\dataset\source_erp\loc_a101.csv'
	WITH (
		FORMAT CSV,
		HEADER TRUE,
		DELIMITER ','
	);

	GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE '( % rows affected )', v_rows;

	v_end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time))::INT;
    RAISE NOTICE '>> -------------';
	
	-- ==========================================================
	-- bronze.erp_px_cat_g1v2
	-- ==========================================================

	v_start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';		
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;

	RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';			
	COPY bronze.erp_px_cat_g1v2 (
		id,
		cat,
		subcat,
		maintenance 	
	)
	FROM 'D:\sql_data_warehouse\dataset\source_erp\px_cat_g1v2.csv'
	WITH (
		FORMAT CSV,
		HEADER TRUE,
		DELIMITER ','
	);

	GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE '( % rows affected )', v_rows;

	v_end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time))::INT;
    RAISE NOTICE '>> -------------';

	v_batch_end_time := clock_timestamp();
	RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '>> Total Load Duration: % seconds', EXTRACT(EPOCH FROM (v_batch_end_time - v_batch_start_time))::INT;
    RAISE NOTICE '==========================================';
	
	-- ==========================================================
	-- Error
	-- ==========================================================
	
	EXCEPTION
	    WHEN OTHERS THEN
	        GET STACKED DIAGNOSTICS 
	            v_error_msg = MESSAGE_TEXT,
	            v_error_state = RETURNED_SQLSTATE,
				v_error_context = PG_EXCEPTION_CONTEXT;
	
	        RAISE NOTICE '==========================================';
	        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
	        RAISE NOTICE 'Error Message: %', v_error_msg;
	        RAISE NOTICE 'Error State: %', v_error_state;
			RAISE NOTICE 'Error Context: %', v_error_context;
	        RAISE NOTICE '==========================================';
END;
$$;

-- =============================================
-- Execute Procedure
-- =============================================

-- CALL bronze.load_bronze();
