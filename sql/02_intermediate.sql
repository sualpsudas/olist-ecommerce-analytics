-- ============================================================
-- INTERMEDIATE LEVEL (Questions 11-20)
-- Techniques: CTE, Window Functions, DATE functions, NTILE,
--             ROW_NUMBER, DENSE_RANK, cumulative sum, LEAD, moving average
-- ============================================================


-- Q6: Monthly revenue trend — best and worst months
WITH monthly_revenue AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        ROUND(SUM(op.payment_value), 2)               AS revenue
    FROM orders o
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM monthly_revenue
ORDER BY month;


-- Q7: Actual vs estimated delivery time gap
SELECT
    order_status,
    ROUND(AVG(
        JULIANDAY(order_delivered_customer_date) -
        JULIANDAY(order_purchase_timestamp)
    ), 1)                                           AS avg_actual_days,
    ROUND(AVG(
        JULIANDAY(order_estimated_delivery_date) -
        JULIANDAY(order_purchase_timestamp)
    ), 1)                                           AS avg_estimated_days,
    ROUND(AVG(
        JULIANDAY(order_estimated_delivery_date) -
        JULIANDAY(order_delivered_customer_date)
    ), 1)                                           AS avg_days_early_late,
    COUNT(*)                                        AS total_orders
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- Q8: Top 3 best-selling products per category
WITH ranked_products AS (
    SELECT
        t.product_category_name_english     AS category,
        oi.product_id,
        COUNT(oi.order_id)                  AS total_sold,
        RANK() OVER (
            PARTITION BY t.product_category_name_english
            ORDER BY COUNT(oi.order_id) DESC
        )                                   AS rank_in_category
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY category, oi.product_id
)
SELECT category, product_id, total_sold, rank_in_category
FROM ranked_products
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;


-- Q9: Top 10% sellers — share of total revenue
WITH seller_revenue AS (
    SELECT
        oi.seller_id,
        ROUND(SUM(oi.price), 2)     AS total_revenue,
        NTILE(10) OVER (
            ORDER BY SUM(oi.price) DESC
        )                           AS decile
    FROM order_items oi
    GROUP BY oi.seller_id
),
totals AS (
    SELECT SUM(total_revenue) AS grand_total FROM seller_revenue
)
SELECT
    CASE WHEN decile = 1 THEN 'Top 10%' ELSE 'Bottom 90%' END  AS seller_group,
    COUNT(*)                                                     AS seller_count,
    ROUND(SUM(total_revenue), 2)                                 AS group_revenue,
    ROUND(SUM(total_revenue) * 100.0 / MAX(grand_total), 2)     AS revenue_share_pct
FROM seller_revenue, totals
GROUP BY seller_group;


-- Q10: Weekday vs weekend order behavior
SELECT
    CASE
        WHEN CAST(STRFTIME('%w', order_purchase_timestamp) AS INTEGER) IN (0, 6)
        THEN 'Weekend'
        ELSE 'Weekday'
    END                             AS day_type,
    COUNT(*)                        AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_orders
FROM orders
GROUP BY day_type;


-- Q16: First order per customer — deduplication pattern (ROW_NUMBER)
WITH ranked_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp ASC
        )                                   AS rn
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
)
SELECT customer_unique_id, order_id, order_purchase_timestamp
FROM ranked_orders
WHERE rn = 1
LIMIT 20;


-- Q17: RANK vs DENSE_RANK — product revenue ranking within category
--      (notice the difference when there are ties)
WITH cat_product_revenue AS (
    SELECT
        t.product_category_name_english     AS category,
        oi.product_id,
        ROUND(SUM(oi.price), 2)             AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY category, oi.product_id
)
SELECT
    category,
    product_id,
    revenue,
    RANK()       OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_with_gaps,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS dense_rank_no_gaps
FROM cat_product_revenue
WHERE category = 'computers_accessories'
ORDER BY revenue DESC
LIMIT 20;


-- Q18: Cumulative (running) revenue over time (SUM OVER ORDER BY)
WITH monthly_rev AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp)   AS month,
        ROUND(SUM(op.payment_value), 2)                 AS revenue
    FROM orders o
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2)        AS cumulative_revenue
FROM monthly_rev
ORDER BY month;


-- Q19: LEAD() — compare each month's revenue to the following month
WITH monthly_rev AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp)   AS month,
        ROUND(SUM(op.payment_value), 2)                 AS revenue
    FROM orders o
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    LEAD(revenue) OVER (ORDER BY month)                 AS next_month_revenue,
    ROUND(
        (LEAD(revenue) OVER (ORDER BY month) - revenue) * 100.0
        / NULLIF(revenue, 0),
        2
    )                                                   AS expected_change_pct
FROM monthly_rev
ORDER BY month;


-- Q20: 3-month moving average of monthly order volume (ROWS BETWEEN)
WITH monthly_orders AS (
    SELECT
        STRFTIME('%Y-%m', order_purchase_timestamp)     AS month,
        COUNT(*)                                        AS order_count
    FROM orders
    GROUP BY month
)
SELECT
    month,
    order_count,
    ROUND(
        AVG(order_count) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        1
    )                                                   AS moving_avg_3m
FROM monthly_orders
ORDER BY month;
