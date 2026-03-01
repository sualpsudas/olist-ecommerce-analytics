-- ============================================================
-- BASIC LEVEL (Questions 1-10)
-- Techniques: GROUP BY, JOIN, ORDER BY, CASE WHEN, AVG,
--             DISTINCT, LEFT JOIN + NULL, HAVING, subquery, UNION
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


-- Q6: How many customers are repeat buyers? (DISTINCT + subquery)
SELECT
    COUNT(DISTINCT customer_unique_id)  AS repeat_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id)               AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING order_count > 1
) sub;


-- Q7: Which orders have no review? What percentage is missing? (LEFT JOIN + NULL)
SELECT
    COUNT(*)                                                        AS total_orders,
    SUM(CASE WHEN r.review_id IS NULL THEN 1 ELSE 0 END)           AS missing_reviews,
    ROUND(
        SUM(CASE WHEN r.review_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    )                                                               AS missing_pct
FROM orders o
LEFT JOIN order_reviews r ON o.order_id = r.order_id;


-- Q8: Categories with both high volume (>500 orders) AND high satisfaction (>4.0)
--     (HAVING with multiple conditions)
SELECT
    t.product_category_name_english AS category,
    COUNT(oi.order_id)              AS total_orders,
    ROUND(AVG(r.review_score), 2)   AS avg_score
FROM order_items oi
JOIN products p     ON oi.product_id = p.product_id
JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
JOIN orders o       ON oi.order_id = o.order_id
JOIN order_reviews r ON o.order_id = r.order_id
GROUP BY category
HAVING total_orders > 500 AND avg_score > 4.0
ORDER BY avg_score DESC;


-- Q9: Products priced above their own category average (scalar subquery)
SELECT
    oi.product_id,
    t.product_category_name_english                     AS category,
    ROUND(AVG(oi.price), 2)                             AS product_avg_price,
    ROUND((
        SELECT AVG(oi2.price)
        FROM order_items oi2
        JOIN products p2 ON oi2.product_id = p2.product_id
        WHERE p2.product_category_name = p.product_category_name
    ), 2)                                               AS category_avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY oi.product_id, category
HAVING product_avg_price > category_avg_price
ORDER BY category, product_avg_price DESC
LIMIT 20;


-- Q10: States that have BOTH customers and sellers (INTERSECT / IN subquery)
SELECT
    customer_state              AS state,
    'Customer + Seller'         AS presence
FROM customers
WHERE customer_state IN (SELECT seller_state FROM sellers)
GROUP BY customer_state

UNION ALL

SELECT
    customer_state              AS state,
    'Customer only'             AS presence
FROM customers
WHERE customer_state NOT IN (SELECT seller_state FROM sellers)
GROUP BY customer_state

ORDER BY presence, state;
