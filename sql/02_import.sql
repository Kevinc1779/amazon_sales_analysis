-- Q2 import csv

LOAD DATA LOCAL INFILE '/Users/kevinc1779/Desktop/amazon_sales_analysis/data/amazon_sales_cleaned.csv'
INTO TABLE amazon_sales_cleaned
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@title, @rating, @reviews, @bought, @discounted, @listed, @best, @sponsored, @couponed, @buybox)
SET
  title = NULLIF(@title,''),
  rating = NULLIF(@rating,''),
  number_of_reviews = NULLIF(@reviews,''),
  bought_in_last_month = NULLIF(@bought,''),
  discounted_price = NULLIF(@discounted,''),
  listed_price = NULLIF(@listed,''),
  is_best_seller = CASE UPPER(@best) WHEN 'TRUE' THEN 1 WHEN 'FALSE' THEN 0 ELSE NULL END,
  is_sponsored   = CASE UPPER(@sponsored) WHEN 'TRUE' THEN 1 WHEN 'FALSE' THEN 0 ELSE NULL END,
  is_couponed    = CASE UPPER(@couponed) WHEN 'TRUE' THEN 1 WHEN 'FALSE' THEN 0 ELSE NULL END,
  buy_box_availability = NULLIF(@buybox,'');