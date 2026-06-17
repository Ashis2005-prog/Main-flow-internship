CREATE DATABASE IF NOT EXISTS quickmart_db;
USE quickmart_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    segment VARCHAR(30),
    join_date DATE
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    description VARCHAR(200)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category_id INT,
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    stock_qty INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE NOT NULL,
    city VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Delivered',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2),
    discount DECIMAL(4,2) DEFAULT 0.00,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SELECT * FROM customers;

SELECT name, email, city
FROM customers
WHERE segment='VIP';

SELECT product_name, unit_price, stock_qty
FROM products
WHERE unit_price > 10000
ORDER BY unit_price DESC;

SELECT city,
       COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

SELECT c.category_name,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue,
       ROUND(AVG(oi.unit_price),2) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

SELECT city,
       COUNT(*) AS order_count
FROM orders
GROUP BY city
HAVING COUNT(*) > 1
ORDER BY order_count DESC;

SELECT o.order_id,
       c.name AS customer_name,
       c.city,
       o.order_date,
       p.product_name,
       oi.quantity,
       oi.unit_price,
       ROUND(oi.quantity * oi.unit_price * (1 - oi.discount),2) AS line_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_date,o.order_id;

SELECT p.product_name,
       p.unit_price,
       p.stock_qty,
       oi.order_id
FROM products p
LEFT JOIN order_items oi
ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;

SELECT c.name,
       c.segment,
       ROUND(SUM(oi.quantity * oi.unit_price * (1-oi.discount)),2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id,c.name,c.segment
HAVING total_spent >
(
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price * (1-oi2.discount))
        AS customer_total
        FROM orders o2
        JOIN order_items oi2
        ON o2.order_id = oi2.order_id
        GROUP BY o2.customer_id
    ) avg_table
)
ORDER BY total_spent DESC;

SELECT product_name,
       unit_price,
       CASE
           WHEN unit_price < 1000 THEN 'Budget'
           WHEN unit_price < 10000 THEN 'Mid-Range'
           WHEN unit_price < 50000 THEN 'Premium'
           ELSE 'Luxury'
       END AS price_category
FROM products
ORDER BY unit_price;

SELECT c.category_name,
       ROUND(SUM(oi.quantity*oi.unit_price*(1-oi.discount)),2) AS revenue,
       ROUND(
            SUM(oi.quantity*oi.unit_price*(1-oi.discount))*100.0
            /
            (SELECT SUM(quantity*unit_price*(1-discount))
             FROM order_items),2
       ) AS pct_of_total
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;

SELECT YEAR(o.order_date) AS year,
       MONTH(o.order_date) AS month_num,
       MONTHNAME(o.order_date) AS month_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(
            SUM(oi.quantity*oi.unit_price*(1-oi.discount)),2
       ) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status='Delivered'
GROUP BY YEAR(o.order_date),
         MONTH(o.order_date),
         MONTHNAME(o.order_date)
ORDER BY year,month_num;

SELECT c.name,
       c.segment,
       c.city,
       ROUND(SUM(oi.quantity*oi.unit_price*(1-oi.discount)),2) AS total_spent,
       RANK() OVER(
           ORDER BY SUM(oi.quantity*oi.unit_price*(1-oi.discount)) DESC
       ) AS spending_rank
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY c.customer_id,c.name,c.segment,c.city
ORDER BY spending_rank;

SELECT cat.category_name,
       p.product_name,
       ROUND(SUM(oi.quantity*oi.unit_price*(1-oi.discount)),2) AS revenue,
       RANK() OVER(
           PARTITION BY cat.category_id
           ORDER BY SUM(oi.quantity*oi.unit_price*(1-oi.discount)) DESC
       ) AS rank_in_category
FROM order_items oi
JOIN products p ON oi.product_id=p.product_id
JOIN categories cat ON p.category_id=cat.category_id
GROUP BY cat.category_id,
         cat.category_name,
         p.product_id,
         p.product_name
ORDER BY cat.category_name, rank_in_category;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;