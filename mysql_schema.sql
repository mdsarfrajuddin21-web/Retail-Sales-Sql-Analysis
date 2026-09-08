-- =========================================================
-- RETAIL SALES DATABASE SCHEMA (MySQL 8.0+)
-- Portfolio Project: Business Analyst SQL Skills
-- =========================================================

CREATE DATABASE IF NOT EXISTS retail_sales;
USE retail_sales;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100),
    city          VARCHAR(50),
    state         VARCHAR(10),
    region        VARCHAR(20),
    segment       VARCHAR(20),
    signup_date   DATE
) ENGINE=InnoDB;

CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    region        VARCHAR(20),
    hire_date     DATE
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50),
    cost_price    DECIMAL(10,2),
    unit_price    DECIMAL(10,2)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    employee_id   INT,
    order_date    DATE,
    ship_date     DATE NULL,
    order_status  VARCHAR(20),   -- Completed / Cancelled / Returned
    region        VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    discount      DECIMAL(4,2),   -- e.g. 0.10 = 10% off
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);
