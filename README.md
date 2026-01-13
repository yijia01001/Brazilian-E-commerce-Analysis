# Olist 巴西电商数据分析项目

## 📊 项目概述

这是一个完整的电商数据分析项目，基于巴西电商平台 Olist 的真实数据集进行多维度分析，展示从数据清洗到可视化展示的完整数据分析流程。

## 🎯 项目目标

- 分析电商业务关键指标（销售额、订单量、客户行为等）
- 识别高价值客户和产品类别
- 评估物流配送效率
- 分析客户满意度和评价趋势
- 探索地理位置对业务的影响

## 📁 项目结构

```
Brazilian E-commerce Analysis/
├── README.md                                       # 项目说明文档
├── requirements.txt                                # Python依赖包
├── Brazilian E-Commerce Public Dataset by Olist/   # 原始数据集
│   ├── olist_customers_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   └── product_category_name_translation.csv
├── sql/                                            # SQL分析脚本
│   ├── 01_data_exploration.sql
│   ├── 02_sales_analysis.sql
│   ├── 03_customer_analysis.sql
│   ├── 04_product_analysis.sql
│   └── 05_logistics_analysis.sql
├── analysis notebooks/                             # Python分析脚本
│   ├── 01_data_loading.ipynb
│   ├── 02_data_cleaning.ipynb
│   ├── 03_exploratory_analysis.ipynb
│   ├── 04_advanced_analytics.ipynb
│   └── 05_visualizations.ipynb
└──  outputs/                                        # 输出结果
    ├── charts/                                     # 图表文件
    ├── reports/                                    # 分析报告
    └── cleaned_data/                               # 清洗后的数据
```

## 🛠️ 技术栈

- **SQL**: 数据查询和聚合分析
- **Python**: 数据处理、统计分析和可视化
  - pandas: 数据处理
  - matplotlib/seaborn: 数据可视化
  - numpy: 数值计算
- **Tableau**: 交互式数据可视化

## 📊 数据集说明

### 数据集来源
Kaggle - Brazilian E-Commerce Public Dataset by Olist

### 数据表说明
1. **customers** (99,441条记录)
   - 客户基本信息（ID、城市、州等）

2. **orders** (99,441条记录)
   - 订单信息（状态、时间戳、配送日期等）

3. **order_items** (112,650条记录)
   - 订单商品详情（价格、运费、商品ID等）

4. **products** (32,951条记录)
   - 商品信息（类别、重量、尺寸等）

5. **order_payments** (103,886条记录)
   - 支付信息（支付方式、分期数、金额等）

6. **order_reviews** (99,441条记录)
   - 客户评价（评分、评论内容等）

7. **sellers** (3,095条记录)
   - 卖家信息（地理位置等）

8. **geolocation** (8,001,363条记录)
   - 地理位置坐标数据

## 📈 主要分析内容

### 1. 销售分析
- 总体销售额趋势
- 月度/季度销售对比
- 支付方式分布
- 订单状态分析

### 2. 客户分析
- 客户地域分布
- 客户价值分层（RFM模型）
- 复购率分析
- 客户生命周期价值（CLV）

### 3. 产品分析
- 热门产品类别
- 产品价格分析
- 产品评分分析
- 库存周转分析

### 4. 物流分析
- 配送时间分析
- 配送时效vs承诺时效
- 地理位置对配送的影响

### 5. 评价分析
- 评价分数分布
- 评价趋势分析
- 负面评价原因分析

## 💡 业务洞察
- 更偏向一次性交易平台，单纯拉新难以形成可持续增长，建议在首次购买后尽早触发二次购买激励，针对高 RFM 客户设计会员与忠诚度计划
- 存在明显的商品组合消费现象，建议推出商品组合优惠，提高平均订单金额
- 健康美容和手表礼品等明星品类贡献大，应作为高毛利重点引流类目
- 玩具和汽车用品末位类目销售额较低，应评估是否需要通过营销活动提高其曝光度
- 由于 Black Friday 驱动，11 月是全年的核心业绩增长点
- SP 的销售额远超其他各州，是平台维持基本盘的核心市场

## 🔗 资源链接

- [Kaggle 数据集](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## 🤝 贡献

这是一个个人作品，用于数据分析学习和记录。所有分析均基于公开数据集，结果仅供参考学习。欢迎提出建议和改进意见。

## 📧 联系方式

如有问题或建议，欢迎联系yijia01001@gmail.com。

---

**最后更新**: 2026年

**状态**: ✅ 完成
