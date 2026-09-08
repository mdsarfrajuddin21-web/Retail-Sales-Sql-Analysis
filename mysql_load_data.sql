

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
