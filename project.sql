SELECT * FROM user_events LIMIT 10;

--counts how many unique users reached each stage of the purchase funnel (view → cart → checkout → payment → purchase) in the last 30 days. 

WITH funnel_stages AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage5_purchase
  FROM user_events
  WHERE event_date >= (
    SELECT datetime(MAX(event_date), '-30 days') FROM user_events
  )
)
SELECT * FROM funnel_stages;

--Same CTE, but instead of returning raw counts, it divides each stage by the one before it, turning raw counts into percentages
--what fraction of people who viewed actually added to cart, what fraction who added to cart actually checked out, etc.
-- This tells you where in the funnel you're losing the most people, which is the actual actionable insight (raw counts alone don't tell you efficiency).

WITH funnel_stages AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage5_purchase
  FROM user_events
  WHERE event_date >= (
    SELECT datetime(MAX(event_date), '-30 days') FROM user_events
  )
)
SELECT
  stage1_views,
  stage2_cart,
  ROUND(stage2_cart * 100 / stage1_views, 2) AS view_to_cart_rate,
  stage3_checkout,
  ROUND(stage3_checkout * 100 / stage2_cart, 2) AS cart_to_checkout_rate,
  stage4_payment,
  ROUND(stage4_payment * 100 / stage3_checkout, 2) AS checkout_to_payment_rate,
  stage5_purchase,
  ROUND(stage5_purchase * 100 / stage4_payment, 2) AS payment_to_purchase_rate,
  ROUND(stage5_purchase * 100 / stage1_views, 2) AS overall_conversion_rate
FROM funnel_stages;

--breaks the same funnel down by where the traffic came from (organic, paid ads, email, social). 
--This answers "which marketing channel actually converts, not just which one brings the most visitors" — e.g. social media might drive huge view counts but convert poorly, while email drives fewer views but converts much better.

WITH source_funnel AS (
  SELECT
    traffic_source,
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS carts,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
  FROM user_events
  WHERE event_date >= (
    SELECT datetime(MAX(event_date), '-30 days') FROM user_events
  )
  GROUP BY traffic_source
)
SELECT
  traffic_source,
  views,
  carts,
  purchases,
  ROUND(carts * 100 / views, 2) AS cart_conversion_rate,
  ROUND(purchases * 100 / views, 2) AS purchase_conversion_rate,
  ROUND(purchases * 100 / carts, 2) AS cart_to_purchase_conversion_rate
FROM source_funnel
ORDER BY purchases DESC;

--for users who did eventually purchase, measures how long they took to move between stages (view→cart, cart→purchase, total journey).
--This tells you about user behavior/friction — an unusually long journey might indicate a confusing UX; an unusually short one might indicate bot traffic.

WITH user_journey AS (
  SELECT
    user_id,
    MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
    MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
    MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time
  FROM user_events
  WHERE event_date >= (
    SELECT datetime(MAX(event_date), '-30 days') FROM user_events
  )
  GROUP BY user_id
  HAVING MAX(CASE WHEN event_type = 'purchase' THEN 1 END) IS NOT NULL
)
SELECT
  COUNT(*) AS converted_users,
  ROUND(AVG(julianday(cart_time) - julianday(view_time)) * 24 * 60, 2) AS avg_view_to_cart_minutes,
  ROUND(AVG(julianday(purchase_time) - julianday(cart_time)) * 24 * 60, 2) AS avg_cart_to_purchase_minutes,
  ROUND(AVG(julianday(purchase_time) - julianday(view_time)) * 24 * 60, 2)AS avg_total_journey_minutes
FROM user_journey;

--converts the funnel into financial terms — total visitors, buyers, orders, revenue, and derived KPIs like average order value and revenue per visitor.
--This is what lets you connect funnel performance to actual business impact (e.g., comparing average order value against customer acquisition cost to judge whether a marketing channel is profitable).

WITH funnel_revenue AS (
  SELECT
    COUNT(DISTINCT user_id) AS total_visitors,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders,
    SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue
  FROM user_events
  WHERE event_date >= (
    SELECT datetime(MAX(event_date), '-30 days') FROM user_events
  )
)
SELECT
  total_visitors,
  total_buyers,
  total_orders,
  total_revenue,
  ROUND(total_revenue / total_orders, 2) AS average_order_value,
  ROUND(total_revenue / total_buyers, 2) AS revenue_per_buyer,
  ROUND(total_revenue / total_visitors, 2) AS revenue_per_visitor
FROM funnel_revenue;