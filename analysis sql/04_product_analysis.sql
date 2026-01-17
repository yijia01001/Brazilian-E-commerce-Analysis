-- ============================================
-- Olist 电商数据分析 - 产品分析
-- ============================================

-- 1. 产品类别分析
-- ============================================

-- 热门产品类别（按销售额）
SELECT 
    p.product_category_name,
    pt.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS order_count,
    COUNT(oi.order_item_id) AS item_count,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(SUM(oi.price) / COUNT(oi.order_item_id), 2) AS revenue_per_item
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name, pt.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 20;

-- 热门产品类别（按订单数）
SELECT 
    p.product_category_name,
    pt.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS order_count,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name, pt.product_category_name_english
ORDER BY order_count DESC
LIMIT 20;

-- 2. 产品价格分析
-- ============================================

-- 价格区间分布
SELECT 
    CASE 
        WHEN oi.price < 10 THEN '0-10'
        WHEN oi.price < 50 THEN '10-50'
        WHEN oi.price < 100 THEN '50-100'
        WHEN oi.price < 200 THEN '100-200'
        WHEN oi.price < 500 THEN '200-500'
        ELSE '500+'
    END AS price_range,
    COUNT(*) AS item_count,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(MIN(oi.price), 2) AS min_price,
    ROUND(MAX(oi.price), 2) AS max_price
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY price_range
ORDER BY price_range;

-- 3. 产品评分分析
-- ============================================

-- 产品类别平均评分
SELECT 
    p.product_category_name,
    pt.product_category_name_english,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(CASE WHEN r.review_score = 5 THEN 1 END) AS score_5_count,
    COUNT(CASE WHEN r.review_score = 1 THEN 1 END) AS score_1_count,
    ROUND(COUNT(CASE WHEN r.review_score >= 4 THEN 1 END) * 100.0 / COUNT(r.review_id), 2) AS positive_rate
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
INNER JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name, pt.product_category_name_english
HAVING COUNT(r.review_id) >= 10
ORDER BY avg_review_score DESC, review_count DESC
LIMIT 20;

-- 4. 畅销产品TOP 50
-- ============================================

SELECT 
    oi.product_id,
    p.product_category_name,
    pt.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS order_count,
    COUNT(oi.order_item_id) AS item_count,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
INNER JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id, p.product_category_name, pt.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 50;

-- 5. 产品特征分析
-- ============================================

-- 产品重量对销售的影响
SELECT 
    CASE 
        WHEN p.product_weight_g < 500 THEN 'Light (<500g)'
        WHEN p.product_weight_g < 1000 THEN 'Medium (500g-1kg)'
        WHEN p.product_weight_g < 2000 THEN 'Heavy (1-2kg)'
        ELSE 'Very Heavy (>2kg)'
    END AS weight_category,
    COUNT(*) AS product_count,
    COUNT(DISTINCT oi.order_id) AS order_count,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered' AND p.product_weight_g IS NOT NULL
GROUP BY weight_category
ORDER BY avg_price;

-- 产品照片数量对评分的影响
SELECT 
    p.product_photos_qty,
    COUNT(DISTINCT oi.product_id) AS product_count,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' 
    AND p.product_photos_qty IS NOT NULL 
    AND r.review_score IS NOT NULL
GROUP BY p.product_photos_qty
ORDER BY p.product_photos_qty;
