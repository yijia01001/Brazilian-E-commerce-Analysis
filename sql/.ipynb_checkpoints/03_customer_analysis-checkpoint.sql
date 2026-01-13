-- ============================================
-- Olist 电商数据分析 - 客户分析
-- ============================================

-- 1. 客户地域分布
-- ============================================

-- 各州客户分布
SELECT 
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    COUNT(DISTINCT customer_id) AS total_customer_records,
    COUNT(DISTINCT customer_city) AS number_of_cities,
    ROUND(COUNT(DISTINCT customer_unique_id) * 100.0 / 
          (SELECT COUNT(DISTINCT customer_unique_id) FROM customers), 2) AS customer_percentage
FROM customers
GROUP BY customer_state
ORDER BY unique_customers DESC;

-- 主要城市客户分布
SELECT 
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(COUNT(DISTINCT customer_unique_id) * 100.0 / 
          (SELECT COUNT(DISTINCT customer_unique_id) FROM customers), 2) AS customer_percentage
FROM customers
GROUP BY customer_city, customer_state
ORDER BY unique_customers DESC
LIMIT 20;

-- 2. 客户价值分析（RFM模型）
-- ============================================

-- Recency: 最近一次购买时间
-- Frequency: 购买频率
-- Monetary: 消费金额

WITH customer_metrics AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS order_frequency,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS monetary_value,
        (SELECT MAX(order_purchase_timestamp) FROM orders) AS max_date
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT 
        customer_unique_id,
        last_order_date,
        order_frequency,
        monetary_value,
        DATE_PART('day', max_date - last_order_date) AS recency_days,
        NTILE(5) OVER (ORDER BY DATE_PART('day', max_date - last_order_date) DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY order_frequency) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value) AS monetary_score
    FROM customer_metrics
)
SELECT 
    recency_score,
    frequency_score,
    monetary_score,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary_value), 2) AS avg_monetary,
    ROUND(AVG(order_frequency), 2) AS avg_frequency
FROM rfm_scores
GROUP BY recency_score, frequency_score, monetary_score
ORDER BY recency_score, frequency_score, monetary_score;

-- 3. 客户分层
-- ============================================

WITH customer_metrics AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value,
        ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_order_value
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN order_count >= 5 AND total_value >= 500 THEN 'VIP客户'
        WHEN order_count >= 3 AND total_value >= 200 THEN '高价值客户'
        WHEN order_count >= 2 THEN '中等客户'
        ELSE '普通客户'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_value), 2) AS segment_total_value,
    ROUND(AVG(order_count), 2) AS avg_orders,
    ROUND(AVG(total_value), 2) AS avg_value
FROM customer_metrics
GROUP BY 
    CASE 
        WHEN order_count >= 5 AND total_value >= 500 THEN 'VIP客户'
        WHEN order_count >= 3 AND total_value >= 200 THEN '高价值客户'
        WHEN order_count >= 2 THEN '中等客户'
        ELSE '普通客户'
    END
ORDER BY segment_total_value DESC;

-- 4. 复购率分析
-- ============================================

WITH customer_order_count AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN '新客户（1单）'
        WHEN order_count = 2 THEN '复购客户（2单）'
        WHEN order_count BETWEEN 3 AND 5 THEN '忠诚客户（3-5单）'
        ELSE '超级客户（5单以上）'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_order_count), 2) AS percentage
FROM customer_order_count
GROUP BY 
    CASE 
        WHEN order_count = 1 THEN '新客户（1单）'
        WHEN order_count = 2 THEN '复购客户（2单）'
        WHEN order_count BETWEEN 3 AND 5 THEN '忠诚客户（3-5单）'
        ELSE '超级客户（5单以上）'
    END
ORDER BY customer_count DESC;

-- 总体复购率
SELECT 
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_unique_id END) * 100.0 / 
    COUNT(DISTINCT customer_unique_id) AS repeat_customer_rate
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) subq;

-- 5. 客户生命周期价值（CLV）
-- ============================================

SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    MIN(o.order_purchase_timestamp) AS first_order_date,
    MAX(o.order_purchase_timestamp) AS last_order_date,
    DATE_PART('day', MAX(o.order_purchase_timestamp) - MIN(o.order_purchase_timestamp)) AS customer_lifetime_days,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_order_value
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_value DESC
LIMIT 100;
