-- Query 6: Top 10 products by discount amount (deduped)
SELECT DISTINCT
  title,
  listed_price,
  discounted_price,
  ROUND(listed_price - discounted_price, 2) AS discount_amount
FROM amazon_sales_cleaned
WHERE listed_price IS NOT NULL
  AND discounted_price IS NOT NULL
  AND listed_price > 0
ORDER BY discount_amount DESC
LIMIT 10;


-- Query 7: Sponsored vs non-sponsored (avg discount %, avg rating, avg reviews)
WITH base AS (
  SELECT
    is_sponsored,
    rating,
    number_of_reviews,
    100 * (listed_price - discounted_price) / listed_price AS discount_pct
  FROM amazon_sales_cleaned
  WHERE listed_price IS NOT NULL
    AND discounted_price IS NOT NULL
    AND listed_price > 0
)
SELECT
  is_sponsored,
  COUNT(*) AS product_count,
  ROUND(AVG(rating), 2) AS avg_rating,
  ROUND(AVG(number_of_reviews), 0) AS avg_reviews,
  ROUND(AVG(discount_pct), 2) AS avg_discount_pct
FROM base
WHERE rating IS NOT NULL
GROUP BY is_sponsored
ORDER BY is_sponsored;


-- Query 8: Best seller vs non-best seller
WITH base AS (
  SELECT
    is_best_seller,
    rating,
    number_of_reviews,
    bought_in_last_month,
    100 * (listed_price - discounted_price) / listed_price AS discount_pct
  FROM amazon_sales_cleaned
  WHERE listed_price IS NOT NULL
    AND discounted_price IS NOT NULL
    AND listed_price > 0
)
SELECT
  is_best_seller,
  COUNT(*) AS product_count,
  ROUND(AVG(rating), 2) AS avg_rating,
  ROUND(AVG(number_of_reviews), 0) AS avg_reviews,
  ROUND(AVG(bought_in_last_month), 0) AS avg_bought_last_month,
  ROUND(AVG(discount_pct), 2) AS avg_discount_pct
FROM base
WHERE rating IS NOT NULL
  AND bought_in_last_month IS NOT NULL
  AND is_best_seller IS NOT NULL
GROUP BY is_best_seller
ORDER BY is_best_seller;


-- Query 9: Discount bucket vs demand
WITH base AS (
  SELECT
    bought_in_last_month,
    rating,
    (listed_price - discounted_price) / listed_price AS disc
  FROM amazon_sales_cleaned
  WHERE listed_price IS NOT NULL
    AND discounted_price IS NOT NULL
    AND listed_price > 0
    AND bought_in_last_month IS NOT NULL
    AND rating IS NOT NULL
)
SELECT
  CASE
    WHEN disc < 0.10 THEN '0-10%'
    WHEN disc < 0.20 THEN '10-20%'
    WHEN disc < 0.30 THEN '20-30%'
    WHEN disc < 0.40 THEN '30-40%'
    ELSE '40%+'
  END AS discount_bucket,
  COUNT(*) AS product_count,
  ROUND(AVG(bought_in_last_month), 0) AS avg_bought_last_month,
  ROUND(AVG(rating), 2) AS avg_rating
FROM base
GROUP BY discount_bucket
ORDER BY
  CASE discount_bucket
    WHEN '0-10%' THEN 1
    WHEN '10-20%' THEN 2
    WHEN '20-30%' THEN 3
    WHEN '30-40%' THEN 4
    ELSE 5
  END;


-- Query 10: Buy box availability distribution (NULL-safe + correct % math)
SELECT
  COALESCE(buy_box_availability, 'Unknown') AS buy_box_availability,
  COUNT(*) AS product_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM amazon_sales_cleaned), 2) AS pct_of_total
FROM amazon_sales_cleaned
GROUP BY COALESCE(buy_box_availability, 'Unknown')
ORDER BY product_count DESC;


-- Query 11: Top products by demand
SELECT
  title,
  bought_in_last_month,
  rating,
  number_of_reviews,
  discounted_price,
  listed_price,
  ROUND(100 * (listed_price - discounted_price) / listed_price, 2) AS discount_pct,
  DENSE_RANK() OVER (ORDER BY bought_in_last_month DESC) AS demand_rank
FROM amazon_sales_cleaned
WHERE bought_in_last_month IS NOT NULL
  AND rating IS NOT NULL
  AND number_of_reviews IS NOT NULL
  AND listed_price IS NOT NULL
  AND discounted_price IS NOT NULL
  AND listed_price > 0
ORDER BY bought_in_last_month DESC, rating DESC, number_of_reviews DESC
LIMIT 20;

-- Query 12: Dataset profile (high-level)
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT title) AS distinct_titles,
  ROUND(100.0 * SUM(listed_price IS NOT NULL AND listed_price > 0) / COUNT(*), 2) AS pct_with_listed_price,
  ROUND(100.0 * SUM(discounted_price IS NOT NULL) / COUNT(*), 2) AS pct_with_discounted_price,
  ROUND(100.0 * SUM(bought_in_last_month IS NOT NULL) / COUNT(*), 2) AS pct_with_bought_in_last_month,
  ROUND(100.0 * SUM(is_sponsored = 1) / COUNT(*), 2) AS pct_sponsored,
  ROUND(100.0 * SUM(is_best_seller = 1) / COUNT(*), 2) AS pct_best_seller
FROM amazon_sales_cleaned;


-- Query 13: Data sanity checks (should be near zero)
SELECT 'negative_or_zero_listed_price' AS check_name, COUNT(*) AS bad_rows
FROM amazon_sales_cleaned
WHERE listed_price IS NULL OR listed_price <= 0

UNION ALL
SELECT 'discounted_greater_than_listed' AS check_name, COUNT(*) AS bad_rows
FROM amazon_sales_cleaned
WHERE listed_price IS NOT NULL AND discounted_price IS NOT NULL AND discounted_price > listed_price

UNION ALL
SELECT 'rating_out_of_range' AS check_name, COUNT(*) AS bad_rows
FROM amazon_sales_cleaned
WHERE rating IS NOT NULL AND (rating < 0 OR rating > 5);


-- Query 14: Top products by reviews (social proof leaders)
SELECT
  title,
  rating,
  number_of_reviews,
  bought_in_last_month,
  discounted_price,
  listed_price,
  ROUND(100 * (listed_price - discounted_price) / listed_price, 2) AS discount_pct
FROM amazon_sales_cleaned
WHERE number_of_reviews IS NOT NULL
  AND rating IS NOT NULL
  AND listed_price IS NOT NULL
  AND discounted_price IS NOT NULL
  AND listed_price > 0
ORDER BY number_of_reviews DESC
LIMIT 20;


-- Query 15: Highest-rated products with a minimum review threshold (reduce noise)
SELECT
  title,
  rating,
  number_of_reviews,
  bought_in_last_month,
  discounted_price,
  listed_price,
  ROUND(100 * (listed_price - discounted_price) / listed_price, 2) AS discount_pct
FROM amazon_sales_cleaned
WHERE rating IS NOT NULL
  AND number_of_reviews IS NOT NULL
  AND number_of_reviews >= 1000
  AND listed_price IS NOT NULL
  AND discounted_price IS NOT NULL
  AND listed_price > 0
ORDER BY rating DESC, number_of_reviews DESC
LIMIT 20;

-- View for Tableau (computed fields reused consistently)
CREATE OR REPLACE VIEW v_amazon_sales_features AS
SELECT
  *,
  ROUND(100 * (listed_price - discounted_price) / listed_price, 2) AS discount_pct,
  CASE
    WHEN listed_price IS NULL OR discounted_price IS NULL OR listed_price <= 0 THEN NULL
    WHEN (listed_price - discounted_price) / listed_price < 0.10 THEN '0-10%'
    WHEN (listed_price - discounted_price) / listed_price < 0.20 THEN '10-20%'
    WHEN (listed_price - discounted_price) / listed_price < 0.30 THEN '20-30%'
    WHEN (listed_price - discounted_price) / listed_price < 0.40 THEN '30-40%'
    ELSE '40%+'
  END AS discount_bucket,
  COALESCE(buy_box_availability, 'Unknown') AS buy_box_availability_clean
FROM amazon_sales_cleaned
WHERE listed_price IS NULL OR listed_price > 0;