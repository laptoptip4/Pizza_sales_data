SELECT * FROM dominos.order_details;

-- Retrieve the total number of orders placed.-- 
select count(order_id) as Total_Number
from dominos.order_details;

-- Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as total_sum
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types.name,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size,count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by order_count desc;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, 
    SUM(order_details.quantity) AS quantity
FROM 
    pizza_types 
JOIN 
    pizzas 
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details 
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.name
ORDER BY 
    quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category , sum(order_details.quantity) as quntity
from pizza_types join order_details
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quntity desc;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(pizza_id)
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category; 

--  OR

select category,count(name) 
from pizza_types group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity) ,0)from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name AS pizza_type, 
       ROUND(SUM(p.price * od.quantity)) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.name AS pizza_type,
    ROUND(SUM(p.price * od.quantity), 2) AS revenue,
    ROUND(
        (SUM(p.price * od.quantity) / 
        (SELECT SUM(p2.price * od2.quantity)
         FROM order_details od2
         JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id)
        ) * 100, 2
    ) AS percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY percentage_contribution DESC;

-- Analyze the cumulative revenue generated over time.
SELECT 
    o.order_date,
    SUM(od.quantity * p.price) AS daily_revenue,
    SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.order_date) AS cumulative_revenue
FROM orders o
JOIN order_details od 
    ON o.order_id = od.order_id
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category,
       name AS pizza_name,
       total_revenue
FROM (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS total_revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rnk
    FROM order_details od
    JOIN pizzas p 
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt 
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) ranked_pizzas
WHERE rnk <= 3
ORDER BY category, total_revenue DESC;
