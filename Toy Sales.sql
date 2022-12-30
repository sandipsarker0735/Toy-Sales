#Sandip Sarker
#Toy Sales Data Exploration and analysis
#Dataset: Data has been collected from the following sources https://www.mavenanalytics.io/data-playground?page=3&pageSize=5
#Data includes toy sales in different cities and stores in Mexico. I have cleaned the data in excel and make it ready for the use in MySQL
#I have have a look at the 4 tables of this dataset, gained insights and done an exploratory analysis to answer the critical questions

use project;

-- First I would like to view the whole dataset of each table

SELECT 
    *
FROM
    inventory;

SELECT 
    *
FROM
    products;

SELECT 
    *
FROM
    sales;

SELECT 
    *
FROM
    stores;
    
#Removing $ sign from the table

UPDATE products 
SET 
    product_cost = REPLACE(product_cost, '$', '');

UPDATE products 
SET 
    product_price = REPLACE(product_price, '$', '');
    
#Modify the product_price and product_cost column from text to int

ALTER TABLE products
MODIFY COLUMN product_cost INT;

ALTER TABLE products
MODIFY COLUMN product_price INT;
    
#First I would like to see what are and how many distinct product and product categories are there

SELECT DISTINCT
    product_category
FROM
    products;

SELECT 
    COUNT(DISTINCT product_category)
FROM
    products;
    
-- Total 5 categoris of products
    
SELECT 
    COUNT(DISTINCT product_iD)
FROM
    products;
    
-- Total 35 products are there
    
#Then I would like to know the distinct locations of the stores

SELECT DISTINCT
    store_location
FROM
    stores;

SELECT 
    store_location, COUNT(store_location)
FROM
    stores
GROUP BY store_location;

-- 4 distinct locations are there

#Total number of cities

SELECT 
    distinct Store_city
FROM
    stores;

-- 29 store cities are there

#Count the number of products

SELECT 
    COUNT(DISTINCT Product_Name)
FROM
    Products;
    
-- 35 products are there
    
#Total Stock on hand

SELECT 
    SUM(stock_on_hand) AS Total_stock_in_Hand
FROM
    inventory;
    
-- 29742 stock on hand

#Adding profit column and calculate the values of product category

SELECT 
    product_ID,
    product_name,
    product_category,
    (product_price - product_cost) AS Profit_per_unit_sales
FROM
    products;

SELECT 
	product_category,
    AVG(product_price - product_cost) AS Avg_profit_per_unit,
    MIN(product_price - product_cost) AS Min_profit_per_unit,
    MAX(product_price - product_cost) AS Max_profit_per_unit
 FROM products
 GROUP BY product_category;

#Lets find out how many sales unit per products have been made (top 10)

SELECT 
    p.product_ID,
    p.product_name,
    p.product_category,
    SUM(s.units) AS Units_sold
FROM
    products p
        INNER JOIN
    sales s ON p.product_ID = s.Product_ID
GROUP BY p.product_ID, p.Product_name, p.Product_category
ORDER BY units_sold DESC
LIMIT 10;

#How much sales revenue per products have been made (top 10)

SELECT 
    p.product_ID,
    p.product_name,
    p.product_price,
    SUM(s.units) AS Units_sold,
    p.product_price * SUM(s.units) AS Sales_Revenue_per_Product
FROM
    products p
        INNER JOIN
    sales s ON p.product_ID = s.product_ID
GROUP BY p.product_name , p.product_ID , p.product_price
ORDER BY p.product_ID
LIMIT 10;

#Identify the cost of products sold

SELECT 
    p.product_ID,
    p.product_name,
    p.product_cost,
    SUM(s.units) AS units_sold,
    p.product_cost * SUM(s.units) AS Cost_per_product
FROM
    products p
        INNER JOIN
    sales s ON p.product_ID = s.product_ID
GROUP BY p.product_ID , p.product_name , p.product_cost
ORDER BY Cost_per_product desc;

#Now lets determine the profit percentage per product

SELECT 
    s.product_ID,
    p.product_name,
    p.product_cost,
    p.product_price,
    SUM(s.units) AS units_sold,
    SUM(s.units) * p.product_cost AS cost_per_product,
    SUM(s.units) * p.product_price AS revenue_per_product,
    p.product_price * SUM(s.units) - p.product_cost * SUM(s.units) AS Profit,
    ROUND(((p.product_price * SUM(s.units) - p.product_cost * SUM(s.units)) / (p.product_price * SUM(s.units))) * 100,2) AS Profit_Percentage
FROM
    sales s
        INNER JOIN
    products p ON s.product_ID = p.product_ID
GROUP BY s.product_ID,
    p.product_name,
    p.product_cost,
    p.product_price
ORDER BY profit_percentage DESC;

-- Mini Basketball Hoop (highest)

#Find out the sum of total stock on hand in each product category

SELECT 
    p.product_category,
    p.product_ID,
    p.product_name,
    SUM(i.stock_on_hand) AS Total_Inventory
FROM
    products p
        INNER JOIN
    inventory i ON p.product_ID = i.product_ID
GROUP BY p.product_category , p.product_ID, p.product_name
ORDER BY Total_inventory DESC;

-- Games category has the highest number of stock on hand

#It is important to know the total cost of inventory in each product

SELECT 
    p.product_ID,
    p.product_name,
    p.product_cost,
    SUM(i.stock_on_hand),
    SUM(i.stock_on_hand) * p.product_cost AS Inventory_cost_per_product
FROM
    products p
        INNER JOIN
    inventory i ON p.product_ID = i.product_ID
GROUP BY p.product_ID , p.product_name , p.product_cost
ORDER BY Inventory_cost_per_product DESC;

-- Lego Bricks has the highest inventory cost

#Total inventory cost

SELECT 
    SUM(inventory_cost_per_product) AS Total_cost
FROM
    (SELECT 
        p.product_ID,
            p.product_name,
            p.product_cost,
            SUM(i.stock_on_hand),
            SUM(i.stock_on_hand) * p.product_cost AS Inventory_cost_per_product
    FROM
        products p
    INNER JOIN inventory i ON p.product_ID = i.product_ID
    GROUP BY p.product_ID , p.product_name , p.product_cost
    ORDER BY Inventory_cost_per_product DESC) AS Total_cost;
    
-- 300507
    
#Stores with highest Profit margin 

SELECT 
    s.product_ID,
    p.product_name,
    p.product_cost,
    p.product_price,
    st.store_ID,
    st.store_name,
    SUM(s.units) AS units_sold,
    SUM(s.units) * p.product_cost AS cost_per_product,
    SUM(s.units) * p.product_price AS revenue_per_product,
    p.product_price * SUM(s.units) - p.product_cost * SUM(s.units) AS Profit
FROM
    products p
        INNER JOIN
    sales s ON p.product_ID = s.product_ID
        INNER JOIN
    stores st ON s.store_ID = st.store_ID
GROUP BY s.product_ID , p.product_name , p.product_cost , p.product_price , st.store_ID , st.store_name
ORDER BY Profit DESC;

-- Maven Toys Ciudad de Mexico 2 has the highest profit earnings store

#City with highest profit margin

SELECT 
    s.product_ID,
    p.product_name,
    p.product_cost,
    p.product_price,
    st.store_ID,
    st.store_city,
    SUM(s.units) AS units_sold,
    SUM(s.units) * p.product_cost AS cost_per_product,
    SUM(s.units) * p.product_price AS revenue_per_product,
    p.product_price * SUM(s.units) - p.product_cost * SUM(s.units) AS Profit
FROM
    products p
        INNER JOIN
    sales s ON p.product_ID = s.product_ID
        INNER JOIN
    stores st ON s.store_ID = st.store_ID
GROUP BY s.product_ID , p.product_name , p.product_cost , p.product_price , st.store_ID , st.store_city
ORDER BY Profit DESC;

-- Cuidad de Mexico

#Adding a profit column for calculation and fill it

ALTER TABLE products 
ADD Profit INT;

UPDATE products 
SET 
    Profit = (product_price - product_cost);
    
#create a temporary table containing profit and sales revenue for sorting required data

create temporary table Whole
SELECT 
    p.product_ID,
    p.product_name,
    p.product_cost,
    p.product_price,
    st.store_ID,
    st.store_city,
    SUM(s.units) AS units_sold,
    SUM(s.units) * p.product_cost AS cost_per_product,
    SUM(s.units) * p.product_price AS revenue_per_product,
    p.product_price * SUM(s.units) - p.product_cost * SUM(s.units) AS Profit
FROM
    products p
        INNER JOIN
    sales s ON p.product_ID = s.product_ID
        INNER JOIN
    stores st ON s.store_ID = st.store_ID
GROUP BY s.product_ID , p.product_name , p.product_cost , p.product_price , st.store_ID , st.store_city
ORDER BY Profit DESC;

#city that generates highest profit and Sales revenue

SELECT 
    store_city, SUM(profit)
FROM
    whole
GROUP BY store_city
LIMIT 1;

SELECT 
    store_city, SUM(revenue_per_product)
FROM
    whole
GROUP BY store_city
LIMIT 1;

-- Cuidad de Mexico in terms of sales and profit as well

#Products that generates highest profit and revenue

select product_name, sum(profit)
FROM
    whole
GROUP BY product_name
LIMIT 1;

SELECT 
    product_name, SUM(revenue_per_product)
FROM
    whole
GROUP BY product_name
LIMIT 1;

-- Colorbuds in both cases

#comments based on profit in store city

SELECT DISTINCT
    store_city,
    SUM(profit),
    CASE
        WHEN SUM(profit) < 4000 THEN 'Attention must be given'
        ELSE 'hold the position'
    END AS Comments
FROM
    whole
GROUP BY store_city
ORDER BY SUM(profit) DESC;

-- 20 store cities need to pay attention to increase their sales and profit
#Comments based on the above analysis

-- 1. Lots of inventories are not being used (29742). Company should ensure to keep the minimum unused inventory and increase its sales.
-- 2. products like PlayDoh Toolkit, Lego Bricks, Animal Figures and Glass Marbles are selling comparatively lower units. Their sales need to be increased
-- 3. products like Mini Basketball Hoop, Colorbuds, Uno Card Game, Barrel O' Slime, Glass Marbles are among earning highest profit percentage. products e.g. Rubik's Cube, Dino Egg are the lowest profit percentage earners.
-- 4. products like Lego Bricks, Rubik's Cube, Magic Sand should increase their sales as they have lots of outstanding inventories.
-- 5. Stores e.g. Maven Toys Guanajuato 3, Maven Toys Guadalajara 1, Maven Toys Monterrey 4 should focus more on increase sales and generate profit.
-- 6. Cities e.g. Guadalajara, Monterrey, Campeche should focus more on increasing their sales revenue and generate profit. If needed, marketing campaign should be introduced.
-- 7. Out of 29 store cities 20 stores need to get extra focus as their profit is below average





