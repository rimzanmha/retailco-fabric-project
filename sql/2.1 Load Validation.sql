-- =====================================================================
-- RetailCo 360 | Warehouse: wh_retail | 2.1 - Load Validation
-- =====================================================================

EXEC dbo.usp_load_warehouse;


SELECT 'fact_sales'   AS tbl, COUNT(*) AS warehouse_rows FROM dbo.fact_sales
UNION ALL SELECT 'dim_date',     COUNT(*) FROM dbo.dim_date
UNION ALL SELECT 'dim_product',  COUNT(*) FROM dbo.dim_product
UNION ALL SELECT 'dim_store',    COUNT(*) FROM dbo.dim_store
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dbo.dim_customer;

-- warehouse vs lakehouse 
SELECT (SELECT COUNT(*) FROM dbo.fact_sales)                AS wh_rows,
       (SELECT COUNT(*) FROM lh_retail.dbo.silver_sales)    AS lh_rows,
       (SELECT SUM(net_amount) FROM dbo.fact_sales)         AS wh_revenue,
       (SELECT SUM(net_amount) FROM lh_retail.dbo.silver_sales) AS lh_revenue;


SELECT
  (SELECT COUNT(*) FROM dbo.fact_sales f LEFT JOIN dbo.dim_store    s ON f.store_id    = s.store_id    WHERE s.store_id    IS NULL) AS orphan_store,
  (SELECT COUNT(*) FROM dbo.fact_sales f LEFT JOIN dbo.dim_product  p ON f.product_id  = p.product_id  WHERE p.product_id  IS NULL) AS orphan_product,
  (SELECT COUNT(*) FROM dbo.fact_sales f LEFT JOIN dbo.dim_customer c ON f.customer_id = c.customer_id WHERE c.customer_id IS NULL AND f.customer_id IS NOT NULL) AS orphan_customer,
  (SELECT COUNT(*) FROM dbo.fact_sales f LEFT JOIN dbo.dim_date     d ON f.date_key    = d.date_key    WHERE d.date_key    IS NULL) AS orphan_date;
