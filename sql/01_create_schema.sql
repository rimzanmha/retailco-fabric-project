-- =====================================================================
-- RetailCo 360 | Warehouse: wh_retail | 01 - Star schema
-- =====================================================================

DROP TABLE IF EXISTS dbo.fact_sales;
DROP TABLE IF EXISTS dbo.dim_date;
DROP TABLE IF EXISTS dbo.dim_product;
DROP TABLE IF EXISTS dbo.dim_store;
DROP TABLE IF EXISTS dbo.dim_customer;

CREATE TABLE dbo.dim_date (
    date_key   INT         NOT NULL,
    full_date  DATE        NOT NULL,
    [year]     INT         NOT NULL,
    [quarter]  INT         NOT NULL,
    [month]    INT         NOT NULL,
    [day]      INT         NOT NULL,
    day_name   VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.dim_product (
    product_id   INT          NOT NULL,
    product_name VARCHAR(100),
    category     VARCHAR(100),
    unit_price   DECIMAL(10,2),
    unit_cost    DECIMAL(10,2)
);

CREATE TABLE dbo.dim_store (
    store_id   INT          NOT NULL,
    store_name VARCHAR(100),
    city       VARCHAR(100),
    [state]    VARCHAR(100),
    region     VARCHAR(100),
    open_date  DATE
);

CREATE TABLE dbo.dim_customer (
    customer_id   INT          NOT NULL,
    customer_name VARCHAR(200),
    email         VARCHAR(200),
    city          VARCHAR(100),
    loyalty_tier  VARCHAR(50)
);

CREATE TABLE dbo.fact_sales (
    order_id     BIGINT        NOT NULL,
    date_key     INT           NOT NULL,   -- yyyymmdd, joins to dim_date
    customer_id  INT,                      -- NULL = guest order (allowed)
    product_id   INT           NOT NULL,
    store_id     INT           NOT NULL,
    quantity     INT,
    unit_price   DECIMAL(10,2),
    discount_pct INT,
    net_amount   DECIMAL(12,2),
    channel      VARCHAR(50),
    revenue_band VARCHAR(50)
);

-- Fabric Warehouse keys are metadata only (NOT ENFORCED). They still help the engine and Power BI model relationships.
ALTER TABLE dbo.dim_date     ADD CONSTRAINT pk_dim_date     PRIMARY KEY NONCLUSTERED (date_key)    NOT ENFORCED;
ALTER TABLE dbo.dim_product  ADD CONSTRAINT pk_dim_product  PRIMARY KEY NONCLUSTERED (product_id)  NOT ENFORCED;
ALTER TABLE dbo.dim_store    ADD CONSTRAINT pk_dim_store    PRIMARY KEY NONCLUSTERED (store_id)    NOT ENFORCED;
ALTER TABLE dbo.dim_customer ADD CONSTRAINT pk_dim_customer PRIMARY KEY NONCLUSTERED (customer_id) NOT ENFORCED;
ALTER TABLE dbo.fact_sales   ADD CONSTRAINT pk_fact_sales   PRIMARY KEY NONCLUSTERED (order_id)    NOT ENFORCED;
