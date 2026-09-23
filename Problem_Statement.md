# UrbanCart Sales & Customer Intelligence Project

## The Business

**UrbanCart** is a retail company selling Electronics, Home & Kitchen, Fashion, Beauty, Sports &
Fitness, and Books & Stationery products. It sells through **16 physical stores** across North,
South, East and West India, plus **one online store**. It has been operating for two full years
(2024–2025).

## The Problem

Leadership has a lot of raw sales data sitting in spreadsheets and systems, but no clear answers
to the questions that actually drive decisions:

- **Is the business growing, and where is the growth coming from?**
- **Which products and categories should we double down on — and which are underperforming?**
- **Who are our best customers, and how do we keep them from leaving?**
- **Is our online store outperforming physical stores, or is it the other way around?**
- **Are discounts helping us sell more, or just eating into profit?**
- **How many customers buy once and never come back?**

This project turns raw transaction data into answers to those questions, using SQL for the
analysis and Excel for a dashboard that non-technical stakeholders can open and understand
immediately.

## The Data

Five related tables, covering **3,524 orders and 6,682 individual line items**, spanning
Jan 2024 – Dec 2025:

| Table | What it holds | Rows |
|---|---|---|
| `customers.csv` | Who's buying: name, age, gender, city, region, signup date, loyalty segment | 900 |
| `products.csv` | What's for sale: name, category, selling price, cost price, supplier | 180 |
| `stores.csv` | Where it's sold: 16 physical stores + 1 online store, with region | 17 |
| `orders.csv` | Each transaction: customer, store, date, channel, payment method, status | 3,524 |
| `order_items.csv` | Each product line inside an order: quantity, price, discount applied | 6,682 |

This is what a real business's operational data usually looks like: it needs to be **joined
across tables** to answer any interesting question — which is exactly what the SQL file does.

## The Deliverables

1. **This problem statement** — the business framing above.
2. **`02_schema_and_analysis.sql`** — table definitions plus 15 business questions answered in
   SQL, organized into five sections (Sales Performance, Product Insights, Customer Insights,
   Channel & Regional Performance, Discounts & Returns). Every query has a plain-English comment
   explaining the business question it answers before the code.
3. **`03_UrbanCart_Dashboard.xlsx`** — an Excel workbook with the raw data, a KPI summary sheet,
   pivot-style summary tables, and charts, all built with live formulas so it recalculates if the
   underlying data changes.
4. **`raw_data/`** — the five CSV files described above, ready to load into any SQL database
   (MySQL, PostgreSQL, SQLite, SQL Server) or open directly in Excel.

## How to Use This Project

1. Load the five CSVs from `raw_data/` into a database using the `CREATE TABLE` statements at
   the top of `02_schema_and_analysis.sql` (import instructions are included there).
2. Run each numbered query to reproduce the analysis, or adapt them to ask new questions.
3. Open `03_UrbanCart_Dashboard.xlsx` for the same story in a format built for a business
   audience — no SQL required to read it.

## Key Metrics Used Throughout

- **Net Revenue** = `quantity × unit price × (1 − discount%)`, counted only on `Delivered` orders
  (cancelled and returned orders are excluded from revenue).
- **Gross Profit** = Net Revenue − (`quantity × unit cost`).
- **AOV (Average Order Value)** = Net Revenue ÷ number of orders.
- **Repeat Rate** = % of customers with more than one delivered order.
