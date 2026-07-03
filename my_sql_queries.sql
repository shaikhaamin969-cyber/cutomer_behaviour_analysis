USE customer_behaviour;
 SELECT * FROM customer;
-- what is total revenve genrate by male vs female cutomer ?
SELECT gender,sum(purchase_amount) AS revenue
FROM customer
GROUP BY gender;
-- which cutomer use discount but still spent more then average purchase amount?
SELECT customer_id,purchase_amount
FROM customer
WHERE discount_applied='Yes' and purchase_amount >=(SELECT AVG(purchase_amount) FROM customer)
ORDER BY purchase_amount DESC;
-- what are the top 5 product with the highest average review rating
SELECT item_purchased,ROUND(AVG(review_rating)) AS avg_review_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_review_rating DESC
 LIMIT 5;

-- compare average purchase amount between standard and express shipping
SELECT shipping_type ,ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in("Standard","Express")
GROUP BY shipping_type;

-- do subscriber customer spend more? compare average spend and total revenue between subscriber and non subscriber
SELECT subscription_status,AVG(purchase_amount) AS avg_spend,
COUNT(customer_id) AS total_cutomer,
SUM(purchase_amount) AS total_revenue
FROM customer 
GROUP BY subscription_status
ORDER BY avg_spend,total_revenue DESC;

-- which 5 product have the highest percentage of purchase when discount applied
SELECT item_purchased,
ROUND(
    100 * SUM(
        CASE
            WHEN discount_applied='Yes' THEN 1
            ELSE 0
        END
    ) / COUNT(*),
2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- segment customer into new,returnig,and loyal based on their total number of previous purchase and show the count of each segment

WITH customer_type AS(
SELECT customer_id,previous_purchases,
CASE
	WHEN previous_purchases=1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM customer
)

SELECT customer_segment ,COUNT(*) AS 'Number of customer'
FROM customer_type
GROUP BY customer_segment;
    
-- What are the top 3 purchased product in each category    
with item_counts as (
select category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id) DESC) as item_rank
from customer
group by category, item_purchased



)

select item_rank, category, item_purchased, total_orders
from item_counts 
WHERE item_rank <=3;

-- Are customers who are repeat buyers (more than 5 previous purchase ) are also likely subscribe?
SELECT subscription_status,
COUNT(customer_id) AS repeat_buyers
FROM customer 
WHERE previous_purchases >5
GROUP BY subscription_status;

-- what is the revenue contribution of each age group
SELECT age_group,SUM(purchase_amount) AS revenue 
FROM customer 
GROUP BY age_group
ORDER BY revenue DESC;