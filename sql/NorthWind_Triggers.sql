-- Faça uma análise de crescimento mensal

CREATE MATERIALIZED VIEW monthly_revenue_mv AS
WITH Monthly_Revenue AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS total_revenue
    FROM order_details od
    JOIN orders o 
        ON od.order_id = o.order_id
    GROUP BY order_year, order_month
)
SELECT
    order_year,
    order_month,
    total_revenue
FROM Monthly_Revenue;


CREATE OR REPLACE FUNCTION fun_refresh_monthly_revenue_mv()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW monthly_revenue_mv;
        RETURN NULL;
    END;
$$;

CREATE OR REPLACE TRIGGER trg_refresh_monthly_revenue_mv_order_details
AFTER INSERT OR UPDATE OR DELETE ON order_details
FOR EACH STATEMENT
EXECUTE FUNCTION fun_refresh_monthly_revenue_mv();

CREATE OR REPLACE TRIGGER trg_refresh_monthly_revenue_mv_order
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION fun_refresh_monthly_revenue_mv();



-- Teste de verificação
INSERT INTO orders VALUES (15999, 'OLDWO', 2, '2998-01-01', '2998-01-29', '2998-01-09', 3, 45.5299988, 'Old World Delicatessen', '2743 Bering St.', 'Anchorage', 'AK', '99508', 'USA');
INSERT INTO order_details VALUES (15999, 26, 7, 20, 0);

-- Consulta para verificar se a MV foi atualizada
SELECT * FROM monthly_revenue_mv ORDER BY order_year DESC, order_month DESC;
