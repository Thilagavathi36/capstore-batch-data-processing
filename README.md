# AtliQ Commerce | End-to-End Azure Data Engineering Capstone

**Azure SQL · Azure Data Factory · ADLS Gen2 · Databricks / PySpark · Delta Lake · dbt · Microsoft Fabric / Power BI · GitHub Actions**

## Business goal

Build a reliable analytics platform for AtliQ Commerce: ingest transactional and web data, validate and clean it, publish a reporting-ready star schema, and deliver sales and customer insights without querying the operational OLTP database for every report.

## Architecture


Azure SQL OLTP + CSV / Clickstream sources
                |
       Azure Data Factory
   metadata + watermark ingestion
                |
        ADLS Gen2 Bronze
       Parquet / raw files
                |
   Azure Databricks / PySpark
  Delta Silver + DQ log + MERGE
                |
     dbt staging views (6)
     dbt Gold tables (5)
                |
     Microsoft Fabric / Power BI
   semantic model + sales dashboard

GitHub Actions dbt CI | Databricks Workflow | Audit | Alerts

![AtliQ Architecture](docs/images/capstone_arch.drawio-1.png)

## Milestone summary

| Milestone | Deliverable 
|---|---|
| **M1** | Azure SQL normalized OLTP, ETL control/watermarks 
| **M2** | Metadata-driven ADF → ADLS Bronze full/incremental ingestion
| **M3** | Databricks Silver Delta cleaning, dedup, MERGE, quarantine, DQ log 
| **M4** | dbt: 8 sources, 6 staging views, 5 Gold tables, 17 tests 
| **M5** | Databricks job orchestration, rerun safety 
| **M6** | Fabric Power BI sales report and semantic model 
| **M7** | GitHub Actions CI, retry policy, audit tables, task-level failure email 

## Gold data model

- `dim_customer` — customer attributes
- `dim_product` — product attributes
- `dim_date` — shared reporting calendar
- `fact_sales` — sales at deduplicated order-item grain
- `fact_web_sessions` — session-level web behavior/funnel

Six staging SQL models: `stg_customers`, `stg_orders`, `stg_order_items`, `stg_payments`, `stg_products`, `stg_supplier_price_list`. Model definitions and tests are in `atliq_gold/models/` (generic tests in `schema.yml`; the top-level `tests/` folder may only contain `.gitkeep`).

## Observed validation results

| Check | Result | Interpretation |
|---|---:|---|
| dbt build/CI | **28 PASS, 0 WARN, 0 ERROR, 0 SKIP** | 6 staging + 5 Gold + 17 tests |
| Gold `fact_sales` | **23,263 rows** | Historical validation snapshot |
| Gold `SUM(gross_revenue)` | **40,331,441.00** | Historical gross revenue; not Power BI Net Revenue |
| Audit table snapshots | **13 tables / 188,651 rows** | Total current rows, **not** per-run rows processed |
| Successful audit run | `964179792108871` | Run status SUCCESS, 2026-11-06 |
| Controlled failure alert | **Received** | Task-level email after intentional invalid date |

![workflow evidenc](docs/images/Jobs_workflow-1.png)

![Audit snapshot evidence](docs/images/Audit_log_Table-1.png)

## Repository map


.github/workflows/dbt-ci.yml          # dbt CI on pull requests
Databricks/jobs/JOB_M5_Silver_Processing.yml
Databricks/M3_FINAL_01_Bronze_to_Silver.ipynb
Databricks/M3_FINAL_02_Update_DQ_Log.ipynb
M7_Pipeline_Run_Audit.ipynb
adf/                                   # ADF JSON assets
atliq_gold/                            # dbt project and tests
phase1_project_assets/                 # source/sample assets
AtliQ_Commerce_Dashboard.pbix          # Power BI report (binary)
docs/M1-M7-TECHNICAL-DOCUMENTATION.md  # full narrative + evidence



## How to operate

1. Validate source data and ETL watermarks in Azure SQL.
2. Trigger the ADF Bronze pipeline manually when needed (the schedule is paused).
3. Confirm dated Bronze input partitions and full-refresh source files exist.
4. Run `JOB_M5_Silver_Processing` with the correct processing `run_date`.
5. Verify Silver, DQ log, dbt Gold build, and the `ALL_DONE` audit task.
6. Review `pipeline_run_audit`, `pipeline_table_counts`, `dq_log`, and Power BI outputs.

**CI:** PRs touching `atliq_gold/**` or `.github/workflows/dbt-ci.yml` execute `dbt build --target ci` with environment-provided Databricks secrets. CI uses isolated schema `gold_ci`; do not run CI against production `gold`.

## Reporting

The existing dashboard includes Net Revenue, Orders, Customers, Average Order Value, monthly trend, product/city revenue, conversion funnel, date and category slicers. Values change with filters. 

![Semantic Model](docs/images/AtliQ_Semantic_model.png)
![Dashboard](docs/images/AtliQ_dashboard.png)

