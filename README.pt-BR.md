# 📊 Relatórios Avançados em SQL — Banco de Dados Northwind

![NorthWind Traders](image/NorthWindTraders.png)

## Objetivo

Este repositório tem como objetivo demonstrar como gerar **relatórios analíticos avançados em SQL**, utilizando o banco de dados **Northwind** como base de estudo.

As queries apresentadas aqui simulam análises do mundo real, aplicáveis a empresas de todos os tamanhos que desejam **tomar decisões orientadas por dados**, medindo performance de vendas, comportamento de clientes e oportunidades de marketing.

---

## Contexto: Banco de Dados Northwind

O banco de dados **Northwind** contém os dados de vendas da empresa fictícia **Northwind Traders**, que importa e exporta alimentos especiais de todo o mundo.

Ele inclui informações sobre:  
- **Fornecedores:** Parceiros comerciais e vendedores  
- **Clientes:** Empresas que compram produtos da Northwind  
- **Funcionários:** Equipe de vendas  
- **Produtos:** Catálogo e preços  
- **Pedidos e Detalhes de Pedido:** Transações de vendas  
- **Transportadoras:** Responsáveis pelas entregas  

O dataset possui **14 tabelas** e cobre o ciclo completo de pedidos, desde o cliente até o faturamento, conforme mostrado no seguinte diagrama de relacionamento de entidades.

![NorthWind Diagram](image/NorthWindDiagram.png)

---

## Como Executar

### Manualmente

Utilize o arquivo SQL fornecido, `sql/nortwhind.sql`, para popular o seu banco de dados.

### Com Docker (Recomendado)

**Pré-requisito**: Instale o Docker Desktop

* [Começar com Docker](https://www.docker.com/get-started)

### Passos para configuração com Docker:

1.  Iniciar o Docker Desktop

2.  **Clone** o repositório e entre na pasta do projeto pelo Git Bash:    

    ```bash
    git clone https://github.com/arthurdurso/Project-NorthWind-Analysis.git

    cd Project-NorthWind-Analysis
    ```
    
3.  Suba os serviços com o **comando**: (Esperar rodar completamente)
    ```bash
    docker compose up
    ```  
   
4. **Conectar o PgAdmin**  
Acesse o PgAdmin em [http://localhost:5050](http://localhost:5050), utilizando a senha `postgres`.  

Adicione um novo servidor no PgAdmin:
    
    - Aba General:
        - Nome: db
    - Aba Connection:
        - Nome do host: db
        - Nome de usuário: postgres
        - Senha: postgres 

Em seguida, apenas **Salvar**. Você poderá selecionar o banco de dados **northwind** no servidor **db** criado.

5. **Explorar o Banco de Dados**  

No PgAdmin, você pode verificar todas as **tabelas e views** do banco northwind:  

- Expanda o servidor `db` → `Databases` → `northwind` → `Schemas` → `public` para ver as tabelas e views.  
- Clique com o botão direito → **View/Edit Data** → **All Rows** para inspecionar o conteúdo de cada tabela.  

> Esta etapa é útil para verificar se o script `northwind.sql` carregou corretamente e se todas as tabelas e dados estão disponíveis para análise.

6. **Parar o Docker Compose:**  
Pare o servidor iniciado com `docker-compose up` usando Ctrl-C e remova os contêineres com:
    
    ```
    docker-compose down
    ```
    
7. **Arquivos e Persistência:** 
Suas alterações nos bancos de dados Postgres são persistidas no volume Docker postgresql_data e podem ser recuperadas reiniciando o Docker Compose com docker-compose up.
Para deletar todos os dados do banco, execute:
    
    ```
    docker-compose down -v
    ```

---

## Relatórios Criados

Abaixo estão exemplos de consultas SQL analíticas desenvolvidas a partir do banco de dados Northwind.

Cada relatório busca responder a perguntas de negócio reais — como volume de vendas, desempenho de clientes e tendências ao longo do tempo.

Essas queries podem servir como base para dashboards, análises de performance ou estudos de Business Intelligence (BI).

## Perguntas de Negócio

1. **Relatórios de Receita**
    
    * Qual foi o total de receitas no ano de 1997?

    ```sql
    SELECT ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS total_revenue_1997
    FROM order_details od
    JOIN (
        SELECT 
            order_id
        FROM orders 
        WHERE EXTRACT(YEAR FROM order_date) = 1997
    ) AS o 
    on od.order_id = o.order_id;
    ```

    * Faça uma análise de crescimento mensal e o cálculo de YTD (Year-To-Date)

    ```sql
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
    FROM Acumulative_Revenue;
    ```

2. **Segmentação de clientes**
    
    * Qual é o valor total que cada cliente já pagou até agora?

    ```sql
        SELECT  
            c.contact_name,
            ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount) + o.freight)::NUMERIC, 2) AS total_paid
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY c.contact_name
    ORDER BY total_paid DESC;
    ```
    
    * Separe os clientes em 5 grupos de acordo com o valor pago

    ```sql
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
    ```
    
    * Agora somente os clientes que estão nos grupos 3, 4 e 5 para que seja feita uma análise de Marketing especial com eles 

    ```sql
    -- Using the previous WITH 

    SELECT 
            *
    FROM Ranked_Customers
    WHERE payment_group IN (3, 4, 5);
    ```

3. **Top 10 Produtos Mais Vendidos**
    
    * Identificar os 10 produtos mais vendidos.

    ```sql
    SELECT 
            p.product_name,
            SUM(od.quantity) AS total_quantity_sold
    FROM products p
    JOIN order_details od ON p.product_id = od.product_id
    GROUP BY p.product_name
    ORDER BY total_quantity_sold DESC
    LIMIT 10;
    ```
    
4. **Clientes do Reino Unido que Pagaram Mais de 1000 Dólares**
    
    * Quais clientes do Reino Unido pagaram mais de 1000 dólares?

    ```sql
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
        WHERE UPPER(country) = 'UK'
    ) AS c ON c.customer_id = o.customer_id
    GROUP BY c.contact_name
    HAVING SUM(od.unit_price * od.quantity * (1 - od.discount) + o.freight) > 1000
    ORDER BY total_paid DESC;
    ```
    
---