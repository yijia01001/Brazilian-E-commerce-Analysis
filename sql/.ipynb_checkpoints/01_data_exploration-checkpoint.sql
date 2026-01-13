-- ============================================
-- Olist 电商数据分析 - 数据探索
-- ============================================
-- 此脚本用于探索数据集的基本信息和数据质量

-- 1. 查看各表的基本信息
-- ============================================

-- 客户表统计
SELECT 
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    COUNT(DISTINCT customer_state) AS number_of_states,
    COUNT(DISTINCT customer_city) AS number_of_cities
FROM customers;

-- 订单表统计
SELECT 
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customer_orders,
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date,
    COUNT(DISTINCT order_status) AS number_of_statuses
FROM orders;

-- 订单商品表统计
SELECT 
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(DISTINCT seller_id) AS unique_sellers,
    AVG(price) AS avg_price,
    AVG(freight_value) AS avg_freight,
    SUM(price) AS total_revenue,
    SUM(freight_value) AS total_freight
FROM order_items;

-- 产品表统计
SELECT 
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_category_name) AS unique_categories,
    AVG(product_weight_g) AS avg_weight,
    AVG(product_length_cm) AS avg_length,
    AVG(product_height_cm) AS avg_height,
    AVG(product_width_cm) AS avg_width
FROM products;

-- 支付表统计
SELECT 
    COUNT(*) AS total_payments,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT payment_type) AS payment_types,
    AVG(payment_value) AS avg_payment,
    SUM(payment_value) AS total_payment_value
FROM order_payments;

-- 评价表统计
SELECT 
    COUNT(*) AS total_reviews,
    COUNT(DISTINCT order_id) AS unique_orders,
    AVG(review_score) AS avg_review_score,
    COUNT(CASE WHEN review_score = 5 THEN 1 END) AS score_5,
    COUNT(CASE WHEN review_score = 4 THEN 1 END) AS score_4,
    COUNT(CASE WHEN review_score = 3 THEN 1 END) AS score_3,
    COUNT(CASE WHEN review_score = 2 THEN 1 END) AS score_2,
    COUNT(CASE WHEN review_score = 1 THEN 1 END) AS score_1
FROM order_reviews;

-- 卖家表统计
SELECT 
    COUNT(*) AS total_sellers,
    COUNT(DISTINCT seller_state) AS number_of_states,
    COUNT(DISTINCT seller_city) AS number_of_cities
FROM sellers;

-- 2. 数据质量检查
-- ============================================

-- 检查缺失值
SELECT 
    'orders' AS table_name,
    COUNT(*) - COUNT(order_id) AS missing_order_id,
    COUNT(*) - COUNT(customer_id) AS missing_customer_id,
    COUNT(*) - COUNT(order_purchase_timestamp) AS missing_purchase_date,
    COUNT(*) - COUNT(order_status) AS missing_status
FROM orders

UNION ALL

SELECT 
    'products' AS table_name,
    COUNT(*) - COUNT(product_id) AS missing_product_id,
    COUNT(*) - COUNT(product_category_name) AS missing_category,
    COUNT(*) - COUNT(product_weight_g) AS missing_weight,
    0 AS missing_status
FROM products;

-- 检查订单状态分布
SELECT 
    order_status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY count DESC;

-- 检查支付方式分布
SELECT 
    payment_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_payments), 2) AS percentage,
    AVG(payment_value) AS avg_payment_value,
    SUM(payment_value) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY count DESC;
