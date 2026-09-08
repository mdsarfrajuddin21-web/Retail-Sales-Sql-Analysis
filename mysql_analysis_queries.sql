-- =========================================================
-- BUSINESS ANALYST SQL PORTFOLIO — ANALYSIS QUERIES (MySQL 8.0+)
-- Organized from basic -> intermediate -> advanced
-- =========================================================

USE retail_sales;

-- ---------------------------------------------------------
-- LEVEL 1: BASICS (SELECT, WHERE, ORDER BY, LIMIT)
-- ---------------------------------------------------------

-- 1. List all customers from the "West" region
SELECT customer_id, first_name, last_name, city, state
FROM customers
WHERE region = 'West';

-- 2. Top 10 most expensive products
SELECT product_name, category, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10;

-- 3. Count orders by status
SELECT order_status, COUNT(*) AS num_orders
FROM orders
GROUP BY order_status
ORDER BY num_orders DESC;


-- ---------------------------------------------------------
-- LEVEL 2: JOINS & AGGREGATIONS
-- ---------------------------------------------------------

-- 4. Total revenue by product category
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- 5. Monthly revenue trend
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY order_month
ORDER BY order_month;

-- 6. Top 10 customers by lifetime revenue
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 10;

-- 7. Sales performance by employee (rep) and region
SELECT e.employee_id, CONCAT(e.first_name, ' ', e.last_name) AS employee_name, e.region,
       COUNT(DISTINCT o.order_id) AS orders_handled,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue_generated
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY e.employee_id, employee_name, e.region
ORDER BY revenue_generated DESC;


-- ---------------------------------------------------------
-- LEVEL 3: SUBQUERIES, CTEs, WINDOW FUNCTIONS
-- ---------------------------------------------------------

-- 8. Customers who have never placed an order (LEFT JOIN + NULL check)
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 9. Running total of monthly revenue (window function)
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY order_month
)
SELECT order_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY order_month), 2) AS running_total
FROM monthly
ORDER BY order_month;

-- 10. Rank products by revenue within each category (window function)
WITH product_revenue AS (
    SELECT p.category, p.product_name,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category, p.product_name
)
SELECT category, product_name, ROUND(revenue, 2) AS revenue,
       RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
FROM product_revenue
ORDER BY category, rank_in_category;

-- 11. Month-over-month revenue growth (%) using LAG()
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY order_month
)
SELECT order_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY order_month))
             / LAG(revenue) OVER (ORDER BY order_month), 1) AS mom_growth_pct
FROM monthly
ORDER BY order_month;

-- 12. Customer segmentation: simple RFM-style query
WITH customer_stats AS (
    SELECT c.customer_id,
           CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
           DATEDIFF('2025-01-01', MAX(o.order_date)) AS recency_days,
           COUNT(DISTINCT o.order_id) AS frequency,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS monetary
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, customer_name
)
SELECT *,
       CASE
           WHEN recency_days <= 60 AND frequency >= 5 THEN 'Champion'
           WHEN recency_days <= 120 THEN 'Active'
           WHEN recency_days > 180 THEN 'At Risk'
           ELSE 'Regular'
       END AS customer_tier
FROM customer_stats
ORDER BY monetary DESC
LIMIT 20;

-- 13. Order cancellation/return rate by region
SELECT region,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
       SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) AS returned,
       ROUND(100.0 * SUM(CASE WHEN order_status IN ('Cancelled','Returned') THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS problem_rate_pct
FROM orders
GROUP BY region
ORDER BY problem_rate_pct DESC;

-- 14. Average order value (AOV) by customer segment
SELECT c.segment,
       ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT o.order_id, o.customer_id,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id, o.customer_id
) order_totals
JOIN customers c ON c.customer_id = order_totals.customer_id
GROUP BY c.segment
ORDER BY avg_order_value DESC;


-- ---------------------------------------------------------
-- LEVEL 4: VIEWS (for BI tool / dashboard connection)
-- ---------------------------------------------------------

-- 15. Create a reusable view for a "clean" sales fact table
DROP VIEW IF EXISTS vw_sales_summary;
CREATE VIEW vw_sales_summary AS
SELECT o.order_id, o.order_date, o.region, o.order_status,
       c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, c.segment,
       p.product_id, p.product_name, p.category,
       oi.quantity, oi.unit_price, oi.discount,
       ROUND(oi.quantity * oi.unit_price * (1 - oi.discount), 2) AS line_revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id;

-- Example use: revenue by category, completed orders only
-- SELECT category, SUM(line_revenue) FROM vw_sales_summary WHERE order_status='Completed' GROUP BY category;
