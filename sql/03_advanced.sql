-- ============================================================
-- ADVANCED LEVEL (Questions 21-30)
-- Techniques: CTE chains, RFM, Cohort, LAG, composite scoring,
--             statistical comparison, MoM growth,
--             duplicate detection, gaps & islands, YoY, pivot, CLV
-- ============================================================


-- Q11: RFM Analysis — Customer Segmentation
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)     AS last_purchase,
        COUNT(DISTINCT o.order_id)          AS frequency,
        ROUND(SUM(op.payment_value), 2)     AS monetary
    FROM customers c
    JOIN orders o         ON c.customer_id = o.customer_id
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        CAST(
            JULIANDAY('2018-10-17') - JULIANDAY(last_purchase)
        AS INTEGER)                         AS recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY last_purchase DESC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)       AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)        AS m_score
    FROM rfm_base
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score)   AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Potential Loyalists'
        WHEN (r_score + f_score + m_score) >= 4  THEN 'At Risk'
        ELSE 'Lost'
    END                             AS segment
FROM rfm_scores
ORDER BY rfm_total DESC;


-- Q12: Cohort Analysis — Monthly Retention
WITH cohort_base AS (
    SELECT
        c.customer_unique_id,
        STRFTIME('%Y-%m', MIN(o.order_purchase_timestamp)) AS cohort_month,
        STRFTIME('%Y-%m', o.order_purchase_timestamp)      AS order_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, order_month
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS cohort_customers
    FROM cohort_base
    GROUP BY cohort_month
),
retention AS (
    SELECT
        cb.cohort_month,
        cb.order_month,
        COUNT(DISTINCT cb.customer_unique_id) AS active_customers
    FROM cohort_base cb
    GROUP BY cb.cohort_month, cb.order_month
)
SELECT
    r.cohort_month,
    r.order_month,
    cs.cohort_customers,
    r.active_customers,
    ROUND(r.active_customers * 100.0 / cs.cohort_customers, 2) AS retention_rate
FROM retention r
JOIN cohort_size cs ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, r.order_month;


-- Q13: Impact of late delivery on review scores
WITH delivery_status AS (
    SELECT
        o.order_id,
        CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late'
            ELSE 'On Time'
        END                         AS delivery_flag,
        r.review_score
    FROM orders o
    JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    delivery_flag,
    COUNT(*)                        AS total_orders,
    ROUND(AVG(review_score), 3)     AS avg_score,
    ROUND(MIN(review_score), 0)     AS min_score,
    ROUND(MAX(review_score), 0)     AS max_score,
    SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS low_scores,
    ROUND(
        SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    )                               AS low_score_pct
FROM delivery_status
GROUP BY delivery_flag;


-- Q14: Seller composite performance score
WITH seller_stats AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id)         AS total_orders,
        ROUND(SUM(oi.price), 2)             AS total_revenue,
        ROUND(AVG(r.review_score), 3)       AS avg_review,
        ROUND(AVG(
            JULIANDAY(o.order_delivered_customer_date) -
            JULIANDAY(o.order_purchase_timestamp)
        ), 1)                               AS avg_delivery_days
    FROM order_items oi
    JOIN orders o        ON oi.order_id = o.order_id
    JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY oi.seller_id
    HAVING total_orders >= 10
),
scored AS (
    SELECT
        seller_id,
        total_orders,
        total_revenue,
        avg_review,
        avg_delivery_days,
        NTILE(5) OVER (ORDER BY total_revenue ASC)      AS volume_score,
        NTILE(5) OVER (ORDER BY avg_review ASC)         AS review_score,
        NTILE(5) OVER (ORDER BY avg_delivery_days DESC) AS speed_score
    FROM seller_stats
)
SELECT
    seller_id,
    total_orders,
    total_revenue,
    avg_review,
    avg_delivery_days,
    -- Weighted: 40% volume, 40% review, 20% speed
    ROUND((volume_score * 0.4 + review_score * 0.4 + speed_score * 0.2), 2) AS composite_score
FROM scored
ORDER BY composite_score DESC
LIMIT 20;


-- Q15: Month-over-Month revenue growth by category
WITH monthly_cat_revenue AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp)   AS month,
        t.product_category_name_english                  AS category,
        ROUND(SUM(oi.price), 2)                          AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY month, category
),
with_lag AS (
    SELECT
        month,
        category,
        revenue,
        LAG(revenue) OVER (
            PARTITION BY category ORDER BY month
        )                                                AS prev_month_revenue
    FROM monthly_cat_revenue
)
SELECT
    month,
    category,
    revenue,
    prev_month_revenue,
    ROUND(
        (revenue - prev_month_revenue) * 100.0 / NULLIF(prev_month_revenue, 0),
        2
    )                                                    AS mom_growth_pct
FROM with_lag
WHERE prev_month_revenue IS NOT NULL
ORDER BY mom_growth_pct DESC
LIMIT 30;


-- Q26: Duplicate detection — orders with more than one review (data quality check)
--      Then show how to keep only the latest review per order (ROW_NUMBER dedup)
SELECT
    order_id,
    COUNT(*)        AS review_count
FROM order_reviews
GROUP BY order_id
HAVING review_count > 1
ORDER BY review_count DESC
LIMIT 10;

-- Deduplicated: keep only the most recent review per order
WITH deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY review_creation_date DESC
        )           AS rn
    FROM order_reviews
)
SELECT order_id, review_id, review_score, review_creation_date
FROM deduped
WHERE rn = 1
LIMIT 20;


-- Q27: Gaps and Islands — customers who churned (60+ day gap) and came back
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_purchase_timestamp                      AS order_date,
        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        )                                               AS prev_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),
gaps AS (
    SELECT
        customer_unique_id,
        prev_order_date                                 AS churned_after,
        order_date                                      AS returned_on,
        ROUND(
            JULIANDAY(order_date) - JULIANDAY(prev_order_date),
            0
        )                                               AS gap_days
    FROM customer_orders
    WHERE prev_order_date IS NOT NULL
)
SELECT *
FROM gaps
WHERE gap_days > 60
ORDER BY gap_days DESC
LIMIT 20;


-- Q28: Year-over-Year (YoY) revenue growth by product category
WITH yearly_cat AS (
    SELECT
        STRFTIME('%Y', o.order_purchase_timestamp)      AS year,
        t.product_category_name_english                 AS category,
        ROUND(SUM(oi.price), 2)                         AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY year, category
)
SELECT
    category,
    year,
    revenue,
    LAG(revenue) OVER (PARTITION BY category ORDER BY year)     AS prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (PARTITION BY category ORDER BY year))
        * 100.0
        / NULLIF(LAG(revenue) OVER (PARTITION BY category ORDER BY year), 0),
        2
    )                                                           AS yoy_growth_pct
FROM yearly_cat
WHERE year IN ('2017', '2018')
ORDER BY yoy_growth_pct DESC
LIMIT 20;


-- Q29: SQL Pivot — monthly order count broken down by payment type
--      (conditional aggregation with CASE WHEN inside COUNT)
SELECT
    STRFTIME('%Y-%m', o.order_purchase_timestamp)                       AS month,
    COUNT(CASE WHEN op.payment_type = 'credit_card' THEN 1 END)        AS credit_card,
    COUNT(CASE WHEN op.payment_type = 'boleto'      THEN 1 END)        AS boleto,
    COUNT(CASE WHEN op.payment_type = 'voucher'     THEN 1 END)        AS voucher,
    COUNT(CASE WHEN op.payment_type = 'debit_card'  THEN 1 END)        AS debit_card,
    COUNT(*)                                                            AS total
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY month
ORDER BY month;


-- Q30: Customer Lifetime Value (CLV) with recency weighting
--      (multi-CTE, NTILE, business scoring)
WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id)                                      AS total_orders,
        ROUND(SUM(op.payment_value), 2)                                 AS total_spend,
        MIN(o.order_purchase_timestamp)                                 AS first_order,
        MAX(o.order_purchase_timestamp)                                 AS last_order,
        ROUND(
            JULIANDAY(MAX(o.order_purchase_timestamp)) -
            JULIANDAY(MIN(o.order_purchase_timestamp)),
            0
        )                                                               AS lifespan_days,
        ROUND(
            JULIANDAY('2018-10-17') -
            JULIANDAY(MAX(o.order_purchase_timestamp)),
            0
        )                                                               AS days_since_last
    FROM customers c
    JOIN orders o          ON c.customer_id = o.customer_id
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
    HAVING total_orders >= 2
),
clv AS (
    SELECT *,
        ROUND(total_spend / NULLIF(lifespan_days, 0) * 365, 2)         AS annual_value,
        -- Recency discount: more recent = higher weight
        ROUND(
            total_spend * (1.0 / (1 + days_since_last / 365.0)),
            2
        )                                                               AS clv_score
    FROM customer_metrics
)
SELECT
    customer_unique_id,
    total_orders,
    total_spend,
    lifespan_days,
    annual_value,
    clv_score,
    NTILE(4) OVER (ORDER BY clv_score DESC)                            AS clv_quartile
FROM clv
ORDER BY clv_score DESC
LIMIT 30;
