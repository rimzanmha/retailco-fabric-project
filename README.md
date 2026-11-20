# RetailCo Fabric Project

RetailCo 360 is an end-to-end retail analytics platform that I built on Microsoft Fabric. It takes messy sales data through a medallion lakehouse, serves it from a T-SQL star-schema warehouse and a Power BI report, adds a real-time operations dashboard, and promotes the solution from a Dev to a Test workspace with a deployment pipeline.

## Business problems
- **Poor Data Quality:** Duplicate orders, missing values, and inconsistent data formats.
- **No Single Source of Truth:** Inconsistent sales reporting across five stores and the online channel.
- **Lack of Automation:** Manual data processing and limited pipeline monitoring.
- **No Real-Time Visibility:** Limited ability to monitor incoming orders as they happen.

## Architecture: 
<img width="750" height="500" alt="retailco-architecture" src="https://github.com/user-attachments/assets/0cdf96ff-f99c-43a2-97f4-46eaaa46c7f8" />

## Dashboard
<img width="750" height="400" alt="image" src="https://github.com/user-attachments/assets/c2acfed8-a5f2-4954-9dfd-4a8250c9b22b" />

## Business Questions Answered

RetailCo runs five stores and an online channel, and leadership wanted one trusted version of the numbers plus a live view of orders. The project answers:

- What are the total revenue, gross margin percentage, and online sales share across the business?
- How does revenue trend by month?
- Which regions, cities, and product categories generate the most revenue?
- How do revenue, order volumes, and margins differ by region, category, and channel (In-store, Online, App)?
- How does revenue compare month-over-month and year-to-date?
- What is happening in real time? How many live events are occurring by type, what is the revenue per minute, and what is the cart-to-purchase conversion rate by channel?

## Dataset

Source: Synthetic retail data supplied with a Microsoft Fabric training capstone brief (5 stores, 27 products, 200 customers), plus a synthetic event file for the real-time path.

| Item | Detail |
|---|---|
| Raw sales file | 6,120 rows |
| After removing 120 duplicate orders | 6,000 orders (kept in `silver_sales` and `fact_sales`) |
| Stores / Products / Customers | 5 / 27 / 200 |
| Order dates | Jan 2026 – mid-2026 (synthetic) |
| Real-time event table (`events_raw`) | 15,120 events (2026-06-13 to 2026-11-10) |

## Table Structure
Warehouse star schema: fact_sales joined to dim_date, dim_store, dim_product, dim_customer
Fact Table - sales, Dimension Tables - dim_store (including region and city), dim_product (including category), dim_customer, dim_date

### Sales Table (`silver_sales`)

| Column | Type | Description |
|---|---|---|
| `order_id` | Integer | Unique order ID (e.g. 500001) |
| `order_date` | Date | Date the order was placed (two source date formats standardised) |
| `customer_id` | Integer | Customer key; blank for guest orders |
| `product_id` | Integer | Product key |
| `store_id` | Integer | Store key |
| `quantity` | Integer | Units ordered |
| `unit_price` | Decimal | Price per unit |
| `discount_pct` | Integer | Discount percentage (0, 5, 10, 15 …) |
| `net_amount` | Decimal | `quantity × unit_price × (1 − discount_pct/100)` |
| `channel` | Text | In-store, Online, or App |
| `revenue_band` | Text | Low <500, Mid 500–2000, High >2000 (derived) |
| `_loaded_at` | Timestamp | Load timestamp |

## Tools Used

| Area | Tools |
|---|---|
| Platform | Microsoft Fabric |
| Storage | Lakehouse (OneLake), Delta Lake |
| Transformation | PySpark, Spark SQL |
| Orchestration | Fabric Data Pipelines (ForEach, Lookup, Notebook and Stored Procedure activities) |
| Warehouse | Fabric Warehouse, T-SQL |
| Real-time | Eventstream, Eventhouse, KQL, Real-Time Dashboard |
| Reporting | Power BI (semantic model, DAX) |
| Deployment | Deployment Pipelines (Dev → Test) |

## Approach

| Layer | Component | Purpose |
|---|---|---|
| Bronze | Lakehouse `lh_retail`, Files area | Raw CSVs exactly as received |
| Silver | Delta tables via PySpark notebooks | Cleaned, typed, standardised sales and dimensions |
| Gold | Delta tables via Spark SQL | Business-ready summaries (by day, region, category) |
| Orchestration | Pipeline `pl_retail_master` | Runs notebooks and warehouse load in order, on a schedule |
| Serving | Warehouse `wh_retail` | Star schema for reporting |
| Reporting | Power BI semantic model and report | KPIs and breakdowns |
| Real-time | Eventstream → Eventhouse `eh_retail` → Real-Time Dashboard | Live event analytics |
| Promotion | Deployment pipeline `dp_retailco` | Dev → Test |

## Results and Insights

| Measure | Result |
|---|---|
| Silver rows after cleaning | 6,000 |
| Lakehouse vs. warehouse revenue difference | 0 |
| Pipeline end-to-end duration | ~5 min |
| Warehouse load procedure runtime | ~2 min |

## Business Insights
#### Power BI Report

- **Total revenue:** $20.61M, with a gross margin of 37.64% and an online share of 31.96%.
- **Regional performance:** The South region dominates, generating approximately $12.7M in revenue (roughly 61% of total), compared with $3.9M for North and $4.0M for West.
- **Top product category:** Electronics is the biggest category. South Electronics alone contributes approximately $8.07M (39% of total revenue), and Electronics is the top category in every region.
- **Online sales:** Online share is fairly consistent across regions and categories, mostly ranging from 27% to 38%.
- **City performance:** Bengaluru leads in revenue, followed by Hyderabad, Chennai, New Delhi and Mumbai. Some revenue has a blank city value, which is noted as an area for further development.

## Further Development Needed

- **Security:** Implement Row-Level Security (RLS), Column-Level Security (CLS), Object-Level Security (OLS), and dynamic data masking. None are currently applied.
- **Incremental loading:** Use a watermark or Delta `MERGE` and partition large tables instead of performing a full reload.
- **Automated tests:** Add tests for the notebooks and a Silver-versus-Warehouse total validation after every pipeline run.
- **Git integration:** Connect the Fabric workspace to a repository and promote changes through pull requests (unavailable on the trial tenant).

## Knowledge Gained

- **Medallion architecture:** Building Bronze, Silver and Gold layers using PySpark, Spark SQL and Delta Lake.
- **Data quality:** Profiling data before cleaning and validating business rules before repairing blank values rather than deleting valid sales.
- **Pipeline orchestration:** Config-driven orchestration using ForEach, parameters, row-count gates and stored procedure activities.
- **Data warehousing:** Designing star schemas and writing idempotent, re-runnable T-SQL load procedures.
- **Real-time analytics:** Working with Eventstream, Eventhouse, KQL and materialized views.
- **Power BI:** Creating semantic models and developing DAX measures.
- **Deployment:** Promoting solutions across environments using Fabric Deployment Pipelines.
- **Troubleshooting:** Diagnosing and resolving issues using error messages, including a file-format error and a stored procedure recursion error (error 217).

## Author

**Ahamed Rimzan** Aspiring Data Engineer, Calgary, AB. 4+ years across data analytics, quality assurance, and business-critical reporting. Microsoft Certified: Fabric Analytics Engineer Associate (DP-600). Post-Graduate Diploma in Business Analytics, SAIT (GPA 4.0).

- LinkedIn: https://www.linkedin.com/in/ahamed-rimzan-36483720/
- GitHub: https://github.com/rimzanmha
- Email: rimzanmha@gmail.com
