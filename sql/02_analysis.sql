/* ============================================================================
   UrbanCart Sales & Customer Intelligence Project
   Analysis: 15 business questions across sales, products, customers,
   channels, regions, discounts, and returns.

   Run sql/01_data_preparation.sql and import the CSV files first.
   ============================================================================ */

/* ============================================================================
   PART B — ANALYSIS
   ============================================================================ */

/* ----------------------------------------------------------------------------
   SECTION 1: SALES PERFORMANCE
   ---------------------------------------------------------------------------- */

-- Q1. What's our overall performance? (headline numbers for a leadership summary)
-- Total net revenue, total delivered orders, and average order value (AOV),
-- counting only successfully Delivered orders.
SELECT
    COUNT(DISTINCT o.order_id)                                              AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2)   AS net_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
          / COUNT(DISTINCT o.order_id), 2)                                  AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';


-- Q2. Is revenue growing month over month?
-- Monthly net revenue plus the change vs. the previous month (uses LAG, a
-- window function that looks at the "previous row" without a self-join).
WITH monthly_revenue AS (
    SELECT
        STRFTIME('%Y-%m', o.order_date)                                        AS month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))        AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue, 2)                                                       AS net_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2)                  AS change_vs_prev_month,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / LAG(revenue) OVER (ORDER BY month), 1)                          AS pct_growth_vs_prev_month
FROM monthly_revenue
ORDER BY month;


-- Q3. Which months are our busiest? (seasonality check for inventory & staffing planning)
SELECT
    STRFTIME('%m', o.order_date)                                            AS month_number,
    CASE STRFTIME('%m', o.order_date)
        WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar' WHEN '04' THEN 'Apr'
        WHEN '05' THEN 'May' WHEN '06' THEN 'Jun' WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug'
        WHEN '09' THEN 'Sep' WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec'
    END                                                                      AS month_name,
    COUNT(DISTINCT o.order_id)                                               AS orders_across_both_years,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS revenue_across_both_years
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY month_number, month_name
ORDER BY month_number;


/* ----------------------------------------------------------------------------
   SECTION 2: PRODUCT INSIGHTS
   ---------------------------------------------------------------------------- */

-- Q4. What are our top 10 best-selling products by revenue?
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                                        AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue
FROM order_items oi
JOIN orders o    ON o.order_id = oi.order_id
JOIN products p  ON p.product_id = oi.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY net_revenue DESC
LIMIT 10;


-- Q5. Which category makes us the most money, and which is the most profitable
-- as a % of revenue? (revenue can be high while margin is thin, or vice versa)
SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2)               AS net_revenue,
    ROUND(SUM(oi.quantity * p.unit_cost), 2)                                                 AS total_cost,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
          - SUM(oi.quantity * p.unit_cost), 2)                                               AS gross_profit,
    ROUND(100.0 * (SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
          - SUM(oi.quantity * p.unit_cost))
          / SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 1)             AS margin_pct
FROM order_items oi
JOIN orders o    ON o.order_id = oi.order_id
JOIN products p  ON p.product_id = oi.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY net_revenue DESC;


-- Q6. Who is our #1 product within EACH category? (useful for merchandising —
-- what to feature first on the category page in-store or online).
-- Uses RANK(), a window function, so ties share the same rank.
WITH product_revenue AS (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)) AS net_revenue
    FROM order_items oi
    JOIN orders o   ON o.order_id = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.category, p.product_name
),
ranked AS (
    SELECT
        category, product_name, ROUND(net_revenue, 2) AS net_revenue,
        RANK() OVER (PARTITION BY category ORDER BY net_revenue DESC) AS rank_in_category
    FROM product_revenue
)
SELECT category, product_name, net_revenue
FROM ranked
WHERE rank_in_category = 1
ORDER BY net_revenue DESC;


/* ----------------------------------------------------------------------------
   SECTION 3: CUSTOMER INSIGHTS
   ---------------------------------------------------------------------------- */

-- Q7. Who are our top 20 customers by total spend (our VIPs — candidates for a
-- loyalty program or a personal outreach)?
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    COUNT(DISTINCT o.order_id)                                                AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2)   AS lifetime_spend
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.customer_segment
ORDER BY lifetime_spend DESC
LIMIT 20;


-- Q8. RFM segmentation — score every customer on Recency (how long since they
-- last bought), Frequency (how often) and Monetary (how much), then bucket
-- them into segments. This is the standard way marketing teams decide who to
-- send a "come back" offer to vs. who to reward as a top customer.
-- Note: NTILE(4) splits customers into 4 equal-sized groups (quartiles) —
-- score 1 is always the "best" group for each dimension below.
WITH customer_activity AS (
    SELECT
        o.customer_id,
        MAX(o.order_date)                                                   AS last_order_date,
        COUNT(DISTINCT o.order_id)                                          AS frequency,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))    AS monetary
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
),
rfm_scored AS (
    SELECT
        customer_id, last_order_date, frequency, ROUND(monetary, 2) AS monetary,
        NTILE(4) OVER (ORDER BY last_order_date DESC)  AS recency_score,    -- 1 = bought most recently
        NTILE(4) OVER (ORDER BY frequency DESC)        AS frequency_score,  -- 1 = buys most often
        NTILE(4) OVER (ORDER BY monetary DESC)         AS monetary_score    -- 1 = spends the most
    FROM customer_activity
)
SELECT
    customer_id, last_order_date, frequency, monetary,
    recency_score, frequency_score, monetary_score,
    CASE
        WHEN recency_score = 1 AND frequency_score = 1 AND monetary_score = 1 THEN 'Champion'
        WHEN recency_score <= 2 AND frequency_score <= 2                     THEN 'Loyal Customer'
        WHEN recency_score >= 3 AND frequency_score >= 3                     THEN 'At Risk'
        ELSE 'Regular'
    END AS rfm_segment
FROM rfm_scored
ORDER BY monetary DESC;


-- Q9. What % of customers come back for a second order? (repeat purchase rate
-- — a core health metric for any retail business)
WITH orders_per_customer AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                                             AS customers_with_1plus_order,
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END)                     AS one_time_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)                     AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                                 AS repeat_purchase_rate_pct
FROM orders_per_customer;


-- Q10. Cohort retention — of customers who made their FIRST purchase in a
-- given month, what % were still buying 1, 2, 3... months later? This is the
-- classic "cohort table" used to judge whether retention is improving.
WITH first_purchase AS (
    SELECT customer_id, MIN(STRFTIME('%Y-%m', order_date)) AS cohort_month
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
customer_active_months AS (
    SELECT DISTINCT customer_id, STRFTIME('%Y-%m', order_date) AS active_month
    FROM orders
    WHERE order_status = 'Delivered'
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    f.cohort_month,
    (CAST(STRFTIME('%Y', a.active_month || '-01') AS INT)
       - CAST(STRFTIME('%Y', f.cohort_month || '-01') AS INT)) * 12
    + (CAST(STRFTIME('%m', a.active_month || '-01') AS INT)
       - CAST(STRFTIME('%m', f.cohort_month || '-01') AS INT))            AS months_since_first_purchase,
    COUNT(DISTINCT a.customer_id)                                         AS active_customers,
    cs.cohort_customers,
    ROUND(100.0 * COUNT(DISTINCT a.customer_id) / cs.cohort_customers, 1) AS retention_pct
FROM first_purchase f
JOIN customer_active_months a ON a.customer_id = f.customer_id
JOIN cohort_size cs           ON cs.cohort_month = f.cohort_month
GROUP BY f.cohort_month, months_since_first_purchase, cs.cohort_customers
ORDER BY f.cohort_month, months_since_first_purchase;
-- Note: MySQL/PostgreSQL don't have STRFTIME — replace date-formatting calls
-- with DATE_FORMAT(date, '%Y-%m') on MySQL, or TO_CHAR(date, 'YYYY-MM') on
-- PostgreSQL. The join/window-function logic itself is unchanged.


/* ----------------------------------------------------------------------------
   SECTION 4: CHANNEL & REGIONAL PERFORMANCE
   ---------------------------------------------------------------------------- */

-- Q11. Online vs. in-store: which channel drives more revenue, and which has
-- the higher average order value?
SELECT
    o.channel,
    COUNT(DISTINCT o.order_id)                                                AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2)   AS net_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
          / COUNT(DISTINCT o.order_id), 2)                                   AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.channel
ORDER BY net_revenue DESC;


-- Q12. How does each region perform? (North / South / East / West / Online)
SELECT
    s.region,
    COUNT(DISTINCT o.order_id)                                                AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2)   AS net_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
          / COUNT(DISTINCT o.order_id), 2)                                   AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN stores s        ON s.store_id = o.store_id
WHERE o.order_status = 'Delivered'
GROUP BY s.region
ORDER BY net_revenue DESC;


-- Q13. What payment methods do customers prefer, and does that differ by channel?
SELECT
    o.channel,
    o.payment_method,
    COUNT(*)                                                                  AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY o.channel), 1)  AS pct_of_channel_orders
FROM orders o
WHERE o.order_status = 'Delivered'
GROUP BY o.channel, o.payment_method
ORDER BY o.channel, orders DESC;


/* ----------------------------------------------------------------------------
   SECTION 5: DISCOUNTS & RETURNS
   ---------------------------------------------------------------------------- */

-- Q14. Do discounted line items actually sell more units, and what do
-- discounts cost us in margin? (are promotions working or just giving away profit?)
SELECT
    CASE WHEN oi.discount_pct = 0 THEN 'No Discount' ELSE 'Discounted' END      AS discount_group,
    COUNT(*)                                                                     AS line_items,
    SUM(oi.quantity)                                                             AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2)   AS net_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (oi.discount_pct / 100.0)), 2)       AS revenue_given_up_to_discount
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY discount_group;


-- Q15. Which categories see the most returns and cancellations relative to
-- their order volume? (a quality/fit problem shows up here before it shows up
-- in customer complaints)
SELECT
    p.category,
    COUNT(DISTINCT o.order_id)                                                          AS total_orders,
    SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)                        AS returned_orders,
    SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)                       AS cancelled_orders,
    ROUND(100.0 * SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)
          / COUNT(DISTINCT o.order_id), 1)                                              AS return_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)
          / COUNT(DISTINCT o.order_id), 1)                                              AS cancel_rate_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY return_rate_pct DESC;
