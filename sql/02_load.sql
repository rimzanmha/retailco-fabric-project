-- =====================================================================
-- RetailCo 360 | Warehouse: wh_retail | 2. Load from the Lakehouse
-- =====================================================================
CREATE OR ALTER PROCEDURE dbo.usp_load_warehouse
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.fact_sales;
    TRUNCATE TABLE dbo.dim_date;
    TRUNCATE TABLE dbo.dim_product;
    TRUNCATE TABLE dbo.dim_store;
    TRUNCATE TABLE dbo.dim_customer;

    INSERT INTO dbo.dim_product (product_id, product_name, category, unit_price, unit_cost)
    SELECT product_id, product_name, category,
           CAST(unit_price AS DECIMAL(10,2)), CAST(unit_cost AS DECIMAL(10,2))
    FROM lh_retail.dbo.silver_dim_product;

    INSERT INTO dbo.dim_store (store_id, store_name, city, [state], region, open_date)
    SELECT store_id, store_name, city, [state], region, open_date
    FROM lh_retail.dbo.silver_dim_store;

    INSERT INTO dbo.dim_customer (customer_id, customer_name, email, city, loyalty_tier)
    SELECT customer_id, customer_name, email, city, loyalty_tier
    FROM lh_retail.dbo.silver_dim_customer;

    INSERT INTO dbo.dim_date (date_key, full_date, [year], [quarter], [month], [day], day_name)
    SELECT date_key, full_date, [year], [quarter], [month], [day], day_name
    FROM lh_retail.dbo.gold_dim_date;

    INSERT INTO dbo.fact_sales
        (order_id, date_key, customer_id, product_id, store_id, quantity,
         unit_price, discount_pct, net_amount, channel, revenue_band)
    SELECT order_id,
           CAST(CONVERT(CHAR(8), order_date, 112) AS INT),
           customer_id, product_id, store_id, quantity,
           CAST(unit_price AS DECIMAL(10,2)), discount_pct,
           CAST(net_amount AS DECIMAL(12,2)), channel, revenue_band
    FROM lh_retail.dbo.silver_sales;
END;