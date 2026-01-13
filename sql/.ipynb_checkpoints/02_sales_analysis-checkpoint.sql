-- ============================================
-- Olist 电商数据分析 - 销售分析
-- ============================================

-- 1. 总体销售指标
-- ============================================

-- 总销售额、订单数、平均订单金额
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(oi.order_item_id) AS total_items,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value,
    ROUND(AVG(oi.price), 2) AS avg_item_price,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

-- 2. 时间趋势分析
-- ============================================

-- 月度销售趋势
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS customer_count,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_order_value
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;

-- 季度销售对比
SELECT 
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(QUARTER FROM o.order_purchase_timestamp) AS quarter,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp), 
         EXTRACT(QUARTER FROM o.order_purchase_timestamp)
ORDER BY year, quarter;

-- 3. 支付方式分析
-- ============================================

-- 支付方式统计
SELECT 
    op.payment_type,
    COUNT(DISTINCT op.order_id) AS order_count,
    COUNT(*) AS payment_count,
    ROUND(SUM(op.payment_value), 2) AS total_payment_value,
    ROUND(AVG(op.payment_value), 2) AS avg_payment_value,
    ROUND(MAX(op.payment_value), 2) AS max_payment_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_payments), 2) AS percentage
FROM order_payments op
GROUP BY op.payment_type
ORDER BY total_payment_value DESC;

-- 支付分期分析
SELECT 
    op.payment_installments,
    COUNT(*) AS payment_count,
    ROUND(SUM(op.payment_value), 2) AS total_value,
    ROUND(AVG(op.payment_value), 2) AS avg_value
FROM order_payments op
WHERE op.payment_type = 'credit_card'
GROUP BY op.payment_installments
ORDER BY op.payment_installments;

-- 4. 销售地域分析
-- ============================================

-- 各州销售排名
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS customer_count,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_order_value
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;

-- 5. 销售时间段分析
-- ============================================

-- 按小时分析订单分布
SELECT 
    EXTRACT(HOUR FROM o.order_purchase_timestamp) AS hour_of_day,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY EXTRACT(HOUR FROM o.order_purchase_timestamp)
ORDER BY hour_of_day;

-- 按星期分析订单分布
SELECT 
    EXTRACT(DOW FROM o.order_purchase_timestamp) AS day_of_week,
    CASE EXTRACT(DOW FROM o.order_purchase_timestamp)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY EXTRACT(DOW FROM o.order_purchase_timestamp)
ORDER BY day_of_week;
