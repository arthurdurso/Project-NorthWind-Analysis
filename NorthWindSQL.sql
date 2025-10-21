-- 1. Relatórios de Receita

-- Qual foi o total de receitas no ano de 1997?

SELECT ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS total_revenue_1997
FROM order_details od
JOIN (
    SELECT 
        order_id
    FROM orders 
    WHERE EXTRACT(YEAR FROM order_date) = 1997
) AS o 
on od.order_id = o.order_id;

-- Faça uma análise de crescimento mensal e o cálculo de YTD

WITH Monthly_Revenue AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS total_revenue
    FROM order_details od
    JOIN orders o 
    on od.order_id = o.order_id
    GROUP BY order_year, order_month
    ORDER BY order_year, order_month
), Acumulative_Revenue AS (
    SELECT
        order_year,
        order_month,
        total_revenue,
        SUM(total_revenue) OVER (PARTITION BY order_year ORDER BY order_month) AS ytd_revenue
    FROM Monthly_Revenue
)

SELECT  
        order_year,
        order_month,
        total_revenue,
        total_revenue - LAG(total_revenue) OVER (PARTITION BY order_year ORDER BY order_month) AS month_growth,
        ytd_revenue,
        ROUND((total_revenue - LAG(total_revenue) OVER (PARTITION BY order_year ORDER BY order_month)) / LAG(total_revenue) OVER (PARTITION BY order_year ORDER BY order_month) * 100::NUMERIC, 2) AS month_growth_percentage
FROM Acumulative_Revenue 


-- 2. Segmentação de clientes
    
-- Qual é o valor total que cada cliente já pagou até agora?

SELECT  
        c.contact_name,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount) + o.freight)::NUMERIC, 2) AS total_paid
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY c.contact_name
ORDER BY total_paid DESC;

--Separe os clientes em 5 grupos de acordo com o valor pago por cliente

WITH Customer_Payments AS (
    SELECT  
            c.customer_id,
            c.contact_name,
            ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount) + o.freight)::NUMERIC, 2) AS total_paid
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY c.customer_id, c.contact_name
), Ranked_Customers AS (
    SELECT 
        customer_id,
        contact_name,
        total_paid,
        NTILE(5) OVER (ORDER BY total_paid DESC) AS payment_group
    FROM Customer_Payments
)

SELECT 
        *
FROM Ranked_Customers;

-- Agora somente os clientes que estão nos grupos 3, 4 e 5 para que seja feita uma análise de Marketing especial com eles

SELECT 
        *
FROM Ranked_Customers
WHERE payment_group IN (3, 4, 5);

-- 3. Produtos Mais Vendidos
    
-- Identificar os 10 produtos mais vendidos.

SELECT 
        p.product_name,
        SUM(od.quantity) AS total_quantity_sold
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- 4. Clientes do Reino Unido que Pagaram Mais de 1000 Dólares

SELECT 
        c.contact_name,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount) + o.freight)::NUMERIC, 2) AS total_paid
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
JOIN (
    SELECT 
            customer_id,
            contact_name,
            country
    FROM customers
    WHERE upper(country) = 'UK'
) AS c ON c.customer_id = o.customer_id
GROUP BY c.contact_name
HAVING ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount) + o.freight)::NUMERIC, 2) > 1000
ORDER BY total_paid DESC

