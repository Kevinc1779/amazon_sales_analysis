-- Q2 import csv

LOAD DATA LOCAL INFILE '/Users/kevinc1779/Desktop/amazon_sales_analysis/data/amazon_sales_cleaned.csv'
INTO TABLE amazon_sales_cleaned
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@title, @rating, @reviews, @bought, @discounted, @listed, @best, @sponsored, @couponed, @buybox)
SET
  title = NULLIF(@title,''),
  rating = NULLIF(NULLIF(@rating,''), 'NaN'),
  number_of_reviews = NULLIF(NULLIF(@reviews,''), 'NaN'),
  bought_in_last_month = NULLIF(NULLIF(@bought,''), 'NaN'),
  discounted_price = NULLIF(NULLIF(@discounted,''), 'NaN'),
  listed_price = NULLIF(NULLIF(@listed,''), 'NaN'),

  is_best_seller = NULLIF(NULLIF(@best,''), 'NaN'),
  is_sponsored   = NULLIF(NULLIF(@sponsored,''), 'NaN'),
  is_couponed    = NULLIF(NULLIF(@couponed,''), 'NaN'),

  buy_box_availability = NULLIF(NULLIF(@buybox,''), 'NaN');