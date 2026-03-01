-- ============================================================
-- BASIC LEVEL (Questions 1-5)
-- Techniques: GROUP BY, JOIN, ORDER BY, CASE WHEN, AVG
-- ============================================================


-- Q1: Top product categories by number of orders
SELECT
    p.product_category_name_english AS category,
    COUNT(oi.order_id)              AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY total_orders DESC
LIMIT 15;


-- Q2: Distribution of order statuses
SELECT
    order_status,
    COUNT(*)                                    AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Q3: States with the most customers
SELECT
    c.customer_state                AS state,
    COUNT(DISTINCT c.customer_id)   AS unique_customers
FROM customers c
GROUP BY state
ORDER BY unique_customers DESC
LIMIT 10;


-- Q4: Average order value by payment type
SELECT
    op.payment_type,
    COUNT(DISTINCT op.order_id)             AS total_orders,
    ROUND(AVG(op.payment_value), 2)         AS avg_order_value,
    ROUND(SUM(op.payment_value), 2)         AS total_revenue
FROM order_payments op
GROUP BY op.payment_type
ORDER BY total_revenue DESC;


-- Q5: Average review score by product category
SELECT
    t.product_category_name_english AS category,
    COUNT(r.review_id)              AS total_reviews,
    ROUND(AVG(r.review_score), 2)   AS avg_score
FROM order_reviews r
JOIN orders o         ON r.order_id = o.order_id
JOIN order_items oi   ON o.order_id = oi.order_id
JOIN products p       ON oi.product_id = p.product_id
JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY category
HAVING total_reviews > 50
ORDER BY avg_score DESC
LIMIT 15;
