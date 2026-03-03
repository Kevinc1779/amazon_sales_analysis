-- Q3 verifying import
SELECT COUNT(*) AS total_rows
FROM amazon_sales_cleaned;

SELECT
  title,
  rating,
  number_of_reviews,
  bought_in_last_month,
  discounted_price,
  listed_price,
  is_best_seller,
  is_sponsored,
  is_couponed,
  buy_box_availability
FROM amazon_sales_cleaned
LIMIT 20;