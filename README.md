# UrbanCart Sales & Customer Intelligence

## Problem Solved

UrbanCart had two years of sales data spread across five files, but leadership could not quickly tell **whether the business was growing, which products and channels created value, who its best customers were, or whether discounts and returns were hurting profit**.

This project connects **3,524 orders and 6,682 line items** from 2024–2025, answers **15 decision-focused business questions in SQL**, and presents the results in an Excel dashboard that non-technical stakeholders can use.

## Business Impact

The analysis gives decision-makers one clear view of:

- sales growth, seasonality, and average order value;
- category and product revenue, gross profit, and margin;
- high-value customers, repeat purchases, RFM segments, and retention;
- online versus in-store and regional performance;
- discount effectiveness, returns, and cancellations.

## Dashboard Snapshot

| KPI | Result |
|---|---:|
| Net revenue | ₹10,243,322.40 |
| Delivered orders | 2,500 |
| Average order value | ₹4,097.33 |
| Repeat purchase rate | 72.9% |
| Return rate | 15.0% |
| Gross margin | 32.6% |

> Dashboard figures include **Delivered** orders only and are net of discounts. The return rate uses returned orders as a share of all orders.

## Dataset

UrbanCart sells through 16 physical stores across North, South, East, and West India, plus one online store.

| File | Description | Rows |
|---|---|---:|
| `customers.csv` | Customer profile, location, signup date, and loyalty segment | 900 |
| `products.csv` | Product, category, price, cost, and supplier | 180 |
| `stores.csv` | Store and regional information | 17 |
| `orders.csv` | Order date, customer, store, channel, payment, and status | 3,524 |
| `order_items.csv` | Product-level quantity, selling price, and discount | 6,682 |

## Project Structure

```text
UrbanCart-SQL-Analytics/
├── README.md
├── data/
│   ├── customers.csv
│   ├── order_items.csv
│   ├── orders.csv
│   ├── products.csv
│   └── stores.csv
├── sql/
│   ├── 01_data_preparation.sql
│   ├── 02_analysis.sql
│   └── 03_business_questions.sql
├── dashboard/
│   └── UrbanCart_Dashboard.xlsx
├── screenshots/
│   └── README.md
└── documentation/
    ├── problem_statement.md
    └── project_report.pdf
```

## Analysis Workflow

1. Created a relational schema for stores, products, customers, orders, and order items.
2. Added import instructions and checks for missing relationships, invalid quantities, prices, discounts, channels, and statuses.
3. Joined the five tables and calculated net revenue, gross profit, margin, average order value, and repeat rate.
4. Used CTEs and window functions for month-over-month growth, product ranking, RFM segmentation, and cohort retention.
5. Built a formula-driven Excel dashboard for business users.

## Tools and Skills

- **SQL:** joins, aggregations, CTEs, window functions, ranking, cohort analysis, and data-quality checks
- **Excel:** formulas, KPI reporting, summary tables, and charts
- **Business analysis:** sales, product, customer, channel, region, promotion, and returns analysis

## How to Run

1. Create a database in SQLite, PostgreSQL, or MySQL 8+.
2. Run `sql/01_data_preparation.sql` to create the five tables.
3. Import the CSV files from `data/` in this order: `stores`, `products`, `customers`, `orders`, `order_items`.
4. Run the data-quality checks at the end of `sql/01_data_preparation.sql`.
5. Run the numbered queries in `sql/02_analysis.sql`.
6. Open `dashboard/UrbanCart_Dashboard.xlsx` to explore the business summary.

### SQL Compatibility

The analysis was tested with SQLite. For PostgreSQL, replace `STRFTIME('%Y-%m', date)` with `TO_CHAR(date, 'YYYY-MM')`. For MySQL, use `DATE_FORMAT(date, '%Y-%m')`.

## Metric Definitions

- **Net Revenue** = quantity × unit price × (1 − discount percentage), for Delivered orders only
- **Gross Profit** = net revenue − quantity × unit cost
- **Average Order Value** = net revenue ÷ delivered orders
- **Repeat Purchase Rate** = customers with more than one delivered order ÷ customers with a delivered order

## Screenshots

Screenshots are intentionally not included yet. See `screenshots/README.md` for the exact three images to add and how to capture them cleanly.
