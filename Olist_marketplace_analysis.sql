
/*How many orders are in each order_status?*/ 

SELECT order_status, COUNT(*) AS order_count
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY order_count DESC;


/*How many orders were delivered, and what share of all orders is that?*/

SELECT
    SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    COUNT(*) AS total_orders,
    CAST(SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS FLOAT)*100.00
        / COUNT(*) AS delivered_share
FROM olist_orders_dataset;


/*What is the earliest and latest order purchase date in the dataset?*/

SELECT
    MIN(order_purchase_timestamp) AS earliest_order_date,
    MAX(order_purchase_timestamp) AS latest_order_date
FROM olist_orders_dataset;


*/List the 10 most recent delivered orders.*/

SELECT TOP 10 order_id, order_purchase_timestamp, order_delivered_customer_date
FROM olist_orders_dataset
where order_status = 'delivered'
order by order_purchase_timestamp DESC;


*/How many days on average does delivery take (purchase to customer delivery)?*/

SELECT ROUND(AVG(CAST(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) AS FLOAT)), 2) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered';


*/Flag each delivered order as late or on-time and count both.*/

SELECT
    CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
         THEN 'Late' ELSE 'On Time' END AS delivery_flag,
    COUNT(*) AS order_count
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
              THEN 'Late' ELSE 'On Time' END;


 */ What is the overall late-delivery rate?*/

SELECT
    CAST(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                  THEN 1 ELSE 0 END) AS FLOAT) / ROUND(COUNT(*), 2) * 100.0 AS late_rate
FROM olist_orders_dataset
WHERE order_status = 'delivered';


*/Which orders were delivered more than 30 days after purchase? (outlier check)*/

SELECT order_id, order_purchase_timestamp, order_delivered_customer_date,
       DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) AS delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) > 30
ORDER BY delivery_days DESC;


*/What is the average delivery days for late orders?*/

SELECT ROUND(AVG(CAST(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) AS FLOAT)), 2) AS avg_late_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date > order_estimated_delivery_date;


*/show the late rate by customer state*/

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    CAST(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                  THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS late_rate
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY late_rate DESC;


*/Show only late rate for states with at least 200 delivered orders*/

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    CAST(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                  THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS late_rate
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(*) >= 200
ORDER BY late_rate DESC;


*/What is the average freight value and average price per order item?*/

SELECT
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(freight_value), 2) AS avg_freight
FROM olist_order_items_dataset;


*/Show freight cost by seller state.*/

SELECT
    s.seller_state,
    ROUND(AVG(freight_value), 2) AS avg_freight
FROM olist_order_items_dataset o
JOIN olist_sellers_dataset s ON o.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY avg_freight DESC;


SELECT
    s.seller_state,
    COUNT(*) AS line_items,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY avg_freight DESC;


*/Build the seller_state → customer_state "route" and count orders per route*/

SELECT
    s.seller_state + ' -> ' + c.customer_state AS route,
    COUNT(DISTINCT o.order_id) AS orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state + ' -> ' + c.customer_state
ORDER BY orders DESC;


*/Which product categories have the most orders?*/

SELECT
    p.product_category_name,
    COUNT(DISTINCT o.order_id) AS orders
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products_dataset p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY orders DESC;


*/What is the late rate by product category? (which categories are hardest to deliver on time)*/

SELECT
    t.Column2 AS product_category_name_english,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    CAST(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                  THEN 1 ELSE 0 END) AS FLOAT) / COUNT(DISTINCT o.order_id) AS late_rate
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.Column1
WHERE o.order_status = 'delivered'
GROUP BY t.Column2
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY late_rate DESC;


*/What is the average review score for late vs. on-time orders? (does lateness hurt reviews?)*/

SELECT
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 'Late' ELSE 'On Time' END AS delivery_flag,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score,
    COUNT(*) AS orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
              THEN 'Late' ELSE 'On Time' END;


*/Which states have the worst late-delivery rate, and where does each one rank nationally? (ties should share the same rank).*/

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    CAST(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                  THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS late_rate,
    RANK() OVER (
        ORDER BY CAST(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                              THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) DESC
    ) AS late_rate_rank
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(*) >= 200;


*/ For each state, what % of the national delivered-order volume does it represent?*/

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    CAST(COUNT(*) AS FLOAT) / ROUND(SUM(COUNT(*)) OVER (), 2) * 100.0 AS national_share
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY national_share DESC;


*/For each customer, number their orders chronologically*/

SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS order_sequence
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';


*/TOP 3 worst-late-rate routes per seller state*/

WITH route_stats AS (
    SELECT
        s.seller_state,
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS orders,
        CAST(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                      THEN 1 ELSE 0 END) AS FLOAT) / COUNT(DISTINCT o.order_id) AS late_rate
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
    JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_state, c.customer_state
    HAVING COUNT(DISTINCT o.order_id) >= 100
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY seller_state ORDER BY late_rate DESC) AS rn
    FROM route_stats
)
SELECT seller_state, customer_state, orders, late_rate
FROM ranked
WHERE rn <= 3
ORDER BY seller_state, rn;


*/delivered orders with a late flag*/

WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_state,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
             THEN 1 ELSE 0 END AS is_late
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
)
SELECT customer_state, COUNT(*) AS orders, ROUND(AVG(CAST(is_late AS FLOAT)) * 100.0, 2) AS late_rate
FROM delivered_orders
GROUP BY customer_state
ORDER BY late_rate DESC;


*/Beyond raw late rate, which states are actually costing the business the most late deliveries once volume is factored in?*/

WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_state,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
             THEN 1 ELSE 0 END AS is_late
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
baseline AS (
    SELECT ROUND(AVG(CAST(is_late AS FLOAT)) * 100.0, 2) AS baseline_late_rate
    FROM delivered_orders
    WHERE customer_state IN ('SP', 'MG', 'PR')
),
state_stats AS (
    SELECT
        customer_state,
        COUNT(*) AS orders,
        ROUND(AVG(CAST(is_late AS FLOAT)) * 100.0, 2) AS late_rate
    FROM delivered_orders
    GROUP BY customer_state
    HAVING COUNT(*) >= 200
)
SELECT
    s.customer_state,
    s.orders,
    s.late_rate,
    b.baseline_late_rate,
    ROUND((s.late_rate - b.baseline_late_rate) * s.orders, 2) AS excess_late_orders
FROM state_stats s
CROSS JOIN baseline b
ORDER BY excess_late_orders DESC;


*/What share of total national excess late orders does Rio de Janeiro (RJ) alone represent?*/

WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_state,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
             THEN 1 ELSE 0 END AS is_late
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
baseline AS (
    SELECT ROUND(AVG(CAST(is_late AS FLOAT)) * 100.0, 2) AS baseline_late_rate
    FROM delivered_orders
    WHERE customer_state IN ('SP', 'MG', 'PR')
),
state_excess AS (
    SELECT
        d.customer_state,
        ROUND((AVG(CAST(d.is_late AS FLOAT)) - b.baseline_late_rate) * COUNT(*), 2) AS excess_late_orders
    FROM delivered_orders d
    CROSS JOIN baseline b
    GROUP BY d.customer_state, b.baseline_late_rate
    HAVING COUNT(*) >= 200
)
SELECT
    customer_state,
    excess_late_orders,
    excess_late_orders / SUM(CASE WHEN excess_late_orders > 0 THEN excess_late_orders ELSE 0 END)
        OVER () *100.0 AS pct_of_total_excess
FROM state_excess
WHERE excess_late_orders > 0
ORDER BY excess_late_orders DESC;


*/Was the Feb to Mar 2018 late-rate spike driven by an order-volume surge, 
or something else? (compare that months volume and late rate to the prior 3-month average)*/

WITH monthly AS (
    SELECT
        CONVERT(VARCHAR(7), order_purchase_timestamp, 120) AS order_month,
        COUNT(*) AS orders,
        CAST(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                      THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS late_rate
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
    GROUP BY CONVERT(VARCHAR(7), order_purchase_timestamp, 120)
)
SELECT
    order_month,
    orders,
    late_rate,
    AVG(late_rate) OVER (ORDER BY order_month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS prior_3mo_avg_late_rate
FROM monthly
WHERE order_month IN ('2018-02', '2018-03')
GROUP BY order_month, orders, late_rate
ORDER BY order_month;


/* What payment types are most associated with late deliveries?*/

SELECT
    pay.payment_type,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    CAST(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                  THEN 1 ELSE 0 END) AS FLOAT) / COUNT(DISTINCT o.order_id) AS late_rate
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset pay ON o.order_id = pay.order_id
WHERE o.order_status = 'delivered'
GROUP BY pay.payment_type
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY late_rate DESC;


*/How much extra does it actually cost to ship to the worst Northeast routes compared to the high-volume SP→RJ route?*/

SELECT
    s.seller_state + ' -> ' + c.customer_state AS route,
    COUNT(DISTINCT o.order_id) AS orders,
    AVG(oi.freight_value) AS avg_freight,
    AVG(oi.freight_value) - (
        SELECT AVG(oi2.freight_value)
        FROM olist_order_items_dataset oi2
        JOIN olist_orders_dataset o2 ON oi2.order_id = o2.order_id
        JOIN olist_sellers_dataset s2 ON oi2.seller_id = s2.seller_id
        JOIN olist_customers_dataset c2 ON o2.customer_id = c2.customer_id
        WHERE s2.seller_state = 'SP' AND c2.customer_state = 'RJ'
          AND o2.order_status = 'delivered'
    ) AS freight_premium_vs_sp_rj
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
  AND s.seller_state = 'SP'
  AND c.customer_state IN ('AL', 'MA', 'SE', 'PI', 'CE', 'RJ')
GROUP BY s.seller_state, c.customer_state
ORDER BY avg_freight DESC;
