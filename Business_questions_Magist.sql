/*****
Business Questions - to be solved in SQL

In relation to the PRODUCTS:
*****/
use magist;

-- What categories of tech products does Magist have?
-- I defined these categories as tech categories (9 out of 74 categories)
-- "audio", 
-- "electronics", 
-- "computers_accessories", 
-- "pc_gamer", 
-- "computers", 
-- "signaling_and_security", 
-- "telephony",
-- "consoles_games",
-- "small_appliances"

SELECT DISTINCT
product_category_name_english
FROM
    product_category_name_translation
ORDER BY product_category_name_english;

-- How many products of these tech categories have been sold (within the time window of the database snapshot)?  -- 4022
SELECT COUNT(DISTINCT(oi.product_id)) AS tech_products_sold
FROM order_items oi
LEFT JOIN products p 
	USING (product_id)
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE product_category_name_english = "audio"
OR product_category_name_english =  "electronics"
OR product_category_name_english =  "computers_accessories"
OR product_category_name_english =  "pc_gamer"
OR product_category_name_english =  "computers"
OR product_category_name_english =  "small_appliances"
OR product_category_name_english =  "telephony"
OR product_category_name_english = "signaling_and_security"
OR product_category_name_english = "consoles_games";
	

-- What percentage does that represent from the overall number of products sold? 	-- 32951
SELECT COUNT(DISTINCT(product_id)) AS products_sold
FROM order_items;

    
SELECT 4022 / 32951; -- 
	-- 0.1221, therefore 12%

-- What’s the average price of all products being sold?
SELECT ROUND(AVG(price), 2)
FROM order_items;
	-- 120.65

-- Are expensive tech products popular?
SELECT COUNT(oi.product_id), 
	CASE 
		WHEN price > 500 THEN "Expensive"
		WHEN price > 100 THEN "Mid-range"
		ELSE "Cheap"
	END AS "price_range"
FROM order_items oi
LEFT JOIN products p
	ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE pt.product_category_name_english IN ("audio", "signaling_and_security", "electronics", "computers_accessories", "pc_gamer", "computers", "consoles_games", "telephony", "small_appliances")
GROUP BY price_range
ORDER BY 1 DESC;
	-- 12550 cheap
    -- 4524 mid-range
    -- 656 expensive

/*****
In relation to the SELLERS:
*****/

-- How many months of data are included in the magist database?
SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))
FROM
    orders;
	-- 25 months
    
-- How many sellers are there?
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers;
	-- 3095
    
-- How many Tech sellers are there? 
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers
        LEFT JOIN
    order_items USING (seller_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ("audio", "signaling_and_security", "electronics", "computers_accessories", "pc_gamer", "computers", "consoles_games", "telephony", "small_appliances");
	-- 591

-- What percentage of overall sellers are Tech sellers?
SELECT (591 / 3095) * 100;
	-- 19.09%
    
 -- What is the total amount earned by all sellers?
	-- I use price from order_items and not payment_value from order_payments as an order may contain tech and non tech product. With payment_value we can't distinguish between items in an order
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');
    -- 13494400.74
    
-- the average monthly income of all sellers?
SELECT 13494400.74/ 3095 / 25;
	-- 174.40

-- What is the total amount earned by all Tech sellers?
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
        AND pt.product_category_name_english IN ("audio", "signaling_and_security", "electronics", "computers_accessories", "pc_gamer", "computers", "consoles_games", "telephony", "small_appliances");
	-- 2023026.64
    
-- the average monthly income of Tech sellers?
SELECT 2023026.64 / 454 / 25;
	-- 178.24

/*****
In relation to the DELIVERY:
*****/

-- What’s the average time between the order being placed and the product being delivered?
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))
FROM orders;
	-- 12.5035

-- How many orders are delivered on time vs orders delivered with a delay?
SELECT 
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'Delayed' 
        ELSE 'On time'
    END AS delivery_status, 
    COUNT(DISTINCT order_id) AS orders_count
FROM orders 
WHERE order_status = 'delivered'
    AND order_estimated_delivery_date IS NOT NULL
    AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;
	-- on time 89805
    -- delayed 6665
    