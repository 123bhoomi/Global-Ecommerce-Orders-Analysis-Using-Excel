-- Convert Total_Retail_Price from text to a numeric field by removing the $ symbol.
ALTER TABLE customer_orders
ADD COLUMN total_retail_price_numeric NUMERIC;

UPDATE customer_orders
SET total_retail_price_numeric = 
  REPLACE(REPLACE(total_retail_price, '$', ''), ',', '')::NUMERIC;

ALTER TABLE customer_orders
DROP COLUMN total_retail_price;

ALTER TABLE customer_orders
RENAME COLUMN total_retail_price_numeric TO total_retail_price;

select * from customer_orders;

--Ensure all rows have non-null Customer_Name, Product_Name, and Supplier.
SELECT *
FROM customer_orders
WHERE customer_name IS NULL
   OR product_name IS NULL
   OR supplier IS NULL;

DELETE FROM customer_orders
WHERE customer_name IS NULL
   OR product_name IS NULL
   OR supplier IS NULL;

--Total Revenue by Supplier.
SELECT 
    supplier,
    SUM(total_retail_price) AS total_revenue
FROM customer_orders
GROUP BY supplier
ORDER BY total_revenue DESC;

--Top-Selling Products by Quantity.
SELECT 
    product_name,
    SUM(quantity) AS total_quantity_sold
FROM customer_orders
GROUP BY product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

--Average Purchase Value by Customer.
SELECT 
    customer_name,
    AVG(total_retail_price) AS average_purchase_value
FROM customer_orders
GROUP BY customer_name
ORDER BY average_purchase_value DESC;

--Supplier with Most Unique Products Sold.
SELECT 
    supplier,
    COUNT(DISTINCT product_name) AS unique_products_sold
FROM customer_orders
GROUP BY supplier
ORDER BY unique_products_sold DESC
LIMIT 1;

--Top 3 Customers by Total Spend.
SELECT 
    customer_name,
    SUM(total_retail_price) AS total_spent
FROM customer_orders
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 3;

--High-Value Orders: Quantity > 2 and Total > $100.
SELECT *
FROM customer_orders
WHERE quantity > 2
  AND total_retail_price > 100;

-- Most Commonly Ordered Products per Supplier.
SELECT supplier, product_name, total_quantity
FROM (
    SELECT 
        supplier,
        product_name,
        SUM(quantity) AS total_quantity,
        RANK() OVER (PARTITION BY supplier ORDER BY SUM(quantity) DESC) AS rank
    FROM customer_orders
    GROUP BY supplier, product_name
) ranked_products
WHERE rank = 1;

