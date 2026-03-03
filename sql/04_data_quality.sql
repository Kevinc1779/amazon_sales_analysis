-- Query 4: Data quality checks (NULLs + duplicate detection)

-- 4A) NULL counts for key fields
SELECT
  COUNT(*) AS total_rows,
  SUM(rating IS NULL) AS rating_nulls,
  SUM(number_of_reviews IS NULL) AS reviews_nulls,
  SUM(bought_in_last_month IS NULL) AS bought_nulls,
  SUM(discounted_price IS NULL) AS discounted_price_nulls,
  SUM(listed_price IS NULL) AS listed_price_nulls,
  SUM(is_best_seller IS NULL) AS best_seller_nulls,
  SUM(is_sponsored IS NULL) AS sponsored_nulls,
  SUM(is_couponed IS NULL) AS couponed_nulls
FROM amazon_sales_cleaned;

-- 4B) Duplicate rows by (title, listed_price, discounted_price)
SELECT
  title,
  listed_price,
  discounted_price,
  COUNT(*) AS cnt
FROM amazon_sales_cleaned
GROUP BY title, listed_price, discounted_price
HAVING cnt > 1
ORDER BY cnt DESC, title;