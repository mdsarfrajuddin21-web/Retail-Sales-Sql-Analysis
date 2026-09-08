-- =========================================================
-- LOAD CSV DATA INTO MYSQL
-- Run this AFTER mysql_schema.sql
-- =========================================================
-- NOTE: LOAD DATA INFILE requires the CSV files to be readable by the
-- MySQL server process, and MySQL's "secure_file_priv" setting often
-- restricts which folder you can load from. Two options:
--
-- OPTION A (simplest for beginners): Use MySQL Workbench's
--   "Table Data Import Wizard" (right-click a table > Table Data Import
--   Wizard) and point it at each CSV. No path/permission issues.
--
-- OPTION B: Use LOAD DATA INFILE as below. First check your allowed
--   folder with:  SHOW VARIABLES LIKE 'secure_file_priv';
--   Then copy the CSVs into that folder and adjust the paths below.
--   (On some setups you can use LOAD DATA LOCAL INFILE instead, which
--   reads from your local machine rather than the server's folder —
--   you may need to enable local_infile: SET GLOBAL local_infile = 1;)

USE retail_sales;

LOAD DATA LOCAL INFILE 'D:/SQL project/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, first_name, last_name, email, city, state, region, segment, signup_date);

LOAD DATA LOCAL INFILE 'D:/SQL project/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(employee_id, first_name, last_name, region, hire_date);

LOAD DATA LOCAL INFILE 'D:/SQL project/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, category, cost_price, unit_price);

LOAD DATA LOCAL INFILE 'D:/SQL project/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, employee_id, order_date, @ship_date, order_status, region)
SET ship_date = NULLIF(@ship_date, '');

LOAD DATA LOCAL INFILE 'D:/SQL project/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_item_id, order_id, product_id, quantity, unit_price, discount);

-- Verify row counts
SELECT 'customers' AS tbl, COUNT(*) AS rows_loaded FROM customers
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
