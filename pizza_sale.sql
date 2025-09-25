use pizza_sales;

select*from order_details;
select*from orders;
select*from pizza_types;
select*from pizzas;

----Retrieve the total number of orders placed.
Select count(order_id) as Total_Orders from orders;

----Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS Total_Revenue
FROM 
    order_details
INNER JOIN 
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


----Identify the highest-priced pizza.
SELECT TOP 1 
    pizza_types.name, 
    ROUND(pizzas.price, 2) AS price
FROM 
    pizza_types
JOIN 
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY 
    pizzas.price DESC;


----Identify the most common pizza size ordered.
SELECT TOP 1 
    pizzas.size, 
    COUNT(order_details.order_details_id) AS order_count
FROM 
    pizzas
JOIN 
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 
    pizzas.size
ORDER BY 
    order_count DESC;

----List the top 5 most ordered pizza types along with their quantities.

SELECT TOP 5
    pizza_types.name, 
    SUM(order_details.quantity) AS total_quantity
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.name
ORDER BY 
    total_quantity DESC;


----Join the necessary tables to find the total quantity of each category ordered.

SELECT 
    pizza_types.category, 
    SUM(order_details.quantity) AS quantity
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    quantity DESC;

ALTER TABLE orders
ALTER COLUMN [time] TIME(0);

EXEC sp_rename 'orders.[time]', 'time_column', 'COLUMN';

----Determine the distribution of orders by hour of the day.
SELECT 
    DATEPART(HOUR, time_column) AS order_hour, 
    COUNT(order_id) AS order_count
FROM 
    orders
GROUP BY 
    DATEPART(HOUR, time_column)
ORDER BY 
    order_hour;  


----Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;


----Group the orders by date and calculate the average number of pizzas ordered per day.
EXEC sp_rename 'orders.[Date]', 'Order_date', 'COLUMN';

SELECT 
    AVG(total_quantity) AS avg_quantity_per_day
FROM (
    SELECT 
        orders.Order_date, 
        SUM(order_details.quantity) AS total_quantity
    FROM 
        orders
    JOIN 
        order_details ON orders.order_id = order_details.order_id
    GROUP BY 
        orders.Order_date
) AS Order_Quantity;


----Determine the top 3 most ordered pizza types based on revenue.
EXEC sp_rename 'pizza_types.[name]', 'pizza_name', 'COLUMN';

SELECT TOP 3
    pizza_types.pizza_name, 
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM 
    pizza_types
JOIN 
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.pizza_name
ORDER BY 
    revenue DESC;


----Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category, 
    ROUND(
        SUM(order_details.quantity * pizzas.price) * 100.0 / 
        (
            SELECT 
                SUM(order_details.quantity * pizzas.price)
            FROM 
                order_details
            JOIN 
                pizzas ON pizzas.pizza_id = order_details.pizza_id
        ), 
    2) AS revenue_percentage
FROM 
    pizza_types
JOIN 
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    revenue_percentage DESC;


	 
----Analyze the cumulative revenue generated over time.
SELECT 
    Order_date, 
    SUM(revenue) OVER (ORDER BY Order_date) AS cum_revenue
FROM (
    SELECT 
        orders.Order_date, 
        ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
    FROM 
        order_details
    JOIN 
        pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN 
        orders ON orders.order_id = order_details.order_id 
    GROUP BY 
        orders.Order_date
) AS sales
ORDER BY 
    Order_date;


----Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    pizza_types.category, 
    pizza_types.pizza_name, 
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category, 
    pizza_types.pizza_name
ORDER BY 
    revenue DESC;
