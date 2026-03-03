-- Q1 create db, use, and create table
CREATE DATABASE IF NOT EXISTS amazon_sales_db;
USE amazon_sales_db;

CREATE TABLE amazon_sales_cleaned (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title TEXT,
  rating DECIMAL(3,2) NULL,
  number_of_reviews INT NULL,
  bought_in_last_month INT NULL,
  discounted_price DECIMAL(10,2) NULL,
  listed_price DECIMAL(10,2) NULL,
  is_best_seller BOOLEAN NULL,
  is_sponsored  BOOLEAN NULL,
  is_couponed   BOOLEAN NULL,
  buy_box_availability VARCHAR(50) NULL
);