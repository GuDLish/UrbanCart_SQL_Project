/* ============================================================================
   UrbanCart Sales & Customer Intelligence Project
   Data preparation: schema, import order, and quality checks
   ============================================================================ */

/* ============================================================================
   PART A — SCHEMA
   ============================================================================ */

CREATE TABLE stores (
    store_id     INT PRIMARY KEY,
    store_name   VARCHAR(100) NOT NULL,
    city         VARCHAR(50)  NOT NULL,
    region       VARCHAR(20)  NOT NULL          -- North / South / East / West / Online
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50)  NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL,        -- selling price (before discount)
    unit_cost    DECIMAL(10,2) NOT NULL,         -- what it costs UrbanCart to source it
    supplier     VARCHAR(100)
);

CREATE TABLE customers (
    customer_id      INT PRIMARY KEY,
    customer_name    VARCHAR(100) NOT NULL,
    email            VARCHAR(150),
    gender           VARCHAR(10),
    age              INT,
    city             VARCHAR(50),
    region           VARCHAR(20),
    signup_date      DATE NOT NULL,
    customer_segment VARCHAR(20)                -- Regular / Premium / New (loyalty tier)
);

CREATE TABLE orders (
    order_id       INT PRIMARY KEY,
    customer_id    INT NOT NULL REFERENCES customers(customer_id),
    store_id       INT NOT NULL REFERENCES stores(store_id),
    order_date     DATE NOT NULL,
    channel        VARCHAR(20)  NOT NULL,        -- Online / In-Store
    payment_method VARCHAR(30),
    order_status   VARCHAR(20)  NOT NULL         -- Delivered / Returned / Cancelled
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id),
    product_id    INT NOT NULL REFERENCES products(product_id),
    quantity      INT NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,        -- price at time of sale
    discount_pct  INT NOT NULL DEFAULT 0          -- 0, 5, 10, 15 or 20
);

/* --- Loading the data ---------------------------------------------------
   Load in this order (parents before children, so foreign keys resolve):
   stores -> products -> customers -> orders -> order_items

   PostgreSQL (run from psql, adjust path):
     \copy stores       FROM 'data/stores.csv'       CSV HEADER;
     \copy products     FROM 'data/products.csv'     CSV HEADER;
     \copy customers    FROM 'data/customers.csv'    CSV HEADER;
     \copy orders       FROM 'data/orders.csv'       CSV HEADER;
     \copy order_items  FROM 'data/order_items.csv'  CSV HEADER;

   MySQL (enable local_infile, adjust path):
     LOAD DATA LOCAL INFILE 'data/stores.csv' INTO TABLE stores
       FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
     -- repeat for products, customers, orders, order_items

   SQLite (from the sqlite3 CLI):
     .mode csv
     .import --skip 1 data/stores.csv stores
     -- repeat for the remaining 4 tables

   Any GUI tool (DBeaver, MySQL Workbench, pgAdmin) can also import each CSV
   through its "Import Wizard" pointed at the matching table.
   ---------------------------------------------------------------------- */

/* ============================================================================
   DATA QUALITY CHECKS
   Run after importing all five CSV files. Each issue query should return zero.
   ============================================================================ */

-- Confirm expected row counts.
SELECT 'stores' AS table_name, COUNT(*) AS row_count FROM stores
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

-- Missing customer or store links in orders.
SELECT o.*
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN stores s ON s.store_id = o.store_id
WHERE c.customer_id IS NULL OR s.store_id IS NULL;

-- Missing order or product links in line items.
SELECT oi.*
FROM order_items oi
LEFT JOIN orders o ON o.order_id = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE o.order_id IS NULL OR p.product_id IS NULL;

-- Invalid quantities, prices, or discount percentages.
SELECT *
FROM order_items
WHERE quantity <= 0
   OR unit_price < 0
   OR discount_pct NOT IN (0, 5, 10, 15, 20);

-- Unexpected order values.
SELECT *
FROM orders
WHERE channel NOT IN ('Online', 'In-Store')
   OR order_status NOT IN ('Delivered', 'Returned', 'Cancelled');
