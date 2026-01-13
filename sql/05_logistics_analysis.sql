-- ============================================
-- Olist 电商数据分析 - 物流分析
-- ============================================

-- 1. 配送时间分析
-- ============================================

-- 平均配送时间
SELECT 
    COUNT(*) AS total_delivered_orders,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 2) AS avg_delivery_days_total,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 2) AS avg_pickup_days,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date)), 2) AS avg_shipping_days,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_delivered_customer_date)), 2) AS avg_early_delivery_days
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_purchase_timestamp IS NOT NULL;

-- 配送时间分布
SELECT 
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 5 THEN '0-5天'
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 10 THEN '6-10天'
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 15 THEN '11-15天'
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 20 THEN '16-20天'
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 30 THEN '21-30天'
        ELSE '30天以上'
    END AS delivery_time_range,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders 
                              WHERE order_status = 'delivered' 
                              AND order_delivered_customer_date IS NOT NULL), 2) AS percentage
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_time_range
ORDER BY order_count DESC;

-- 2. 配送时效 vs 承诺时效
-- ============================================

-- 准时率、提前率、延迟率
SELECT 
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1 END) AS on_time_orders,
    COUNT(CASE WHEN order_delivered_customer_date < order_estimated_delivery_date THEN 1 END) AS early_orders,
    COUNT(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 END) AS late_orders,
    ROUND(COUNT(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1 END) * 100.0 / COUNT(*), 2) AS on_time_rate,
    ROUND(COUNT(CASE WHEN order_delivered_customer_date < order_estimated_delivery_date THEN 1 END) * 100.0 / COUNT(*), 2) AS early_rate,
    ROUND(COUNT(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 END) * 100.0 / COUNT(*), 2) AS late_rate
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL;

-- 3. 地域物流分析
-- ============================================

-- 各州平均配送时间
SELECT 
    c.customer_state,
    COUNT(*) AS order_count,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days,
    ROUND(AVG(DATEDIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date)), 2) AS avg_early_days,
    ROUND(COUNT(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 END) * 100.0 / COUNT(*), 2) AS on_time_rate
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY avg_delivery_days;

-- 4. 物流效率趋势
-- ============================================

-- 月度配送时间趋势
SELECT 
    month(o.order_purchase_timestamp) AS month,
    COUNT(*) AS order_count,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days,
    ROUND(COUNT(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 END) * 100.0 / COUNT(*), 2) AS on_time_rate
FROM orders o
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY month(o.order_purchase_timestamp)
ORDER BY month;

-- 5. 运费分析
-- ============================================

-- 运费与配送时间关系
SELECT 
    CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) <= 7 THEN '0-7天'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) <= 14 THEN '8-14天'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) <= 21 THEN '15-21天'
        ELSE '21天以上'
    END AS delivery_time_range,
    COUNT(*) AS order_count,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(AVG(oi.freight_value / NULLIF(oi.price, 0) * 100), 2) AS freight_percentage
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_time_range
ORDER BY order_count DESC;

-- 6. 订单状态分析
-- ============================================

SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;