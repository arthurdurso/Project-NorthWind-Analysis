🔗 Este documento também está disponível em [Português](./README.pt-BR.md). # Construir

# 📊 Advanced Report in SQL — Northwind Database

![alt text](NorthWindTraders.png)

## Goal

Este repositório tem como objetivo demonstrar como gerar **relatórios analíticos avançados em SQL**, utilizando o banco de dados **Northwind** como base de estudo.

As queries aqui apresentadas simulam análises reais aplicáveis a empresas de todos os portes que desejam **tomar decisões orientadas por dados**, medindo performance de vendas, comportamento de clientes e oportunidades de marketing.

---

## Context: Northwind Database

O banco de dados **Northwind** contém os dados de vendas da empresa fictícia **Northwind Traders**, que importa e exporta alimentos especiais de todo o mundo.

Ele inclui informações sobre:
- **Fornecedores:** Parceiros comerciais e vendedores
- **Clientes:** Empresas que compram produtos da Northwind
- **Funcionários:** Equipe de vendas
- **Produtos:** Catálogo e preços
- **Pedidos e Detalhes de Pedido:** Transações de vendas
- **Transportadoras:** Responsáveis pelas entregas

O dataset possui **14 tabelas** e cobre o ciclo completo de pedidos, desde o cliente até o faturamento.

---

## How to Execute

### Manualmente

Utilize o arquivo SQL fornecido, `nortwhind.sql`, para popular o seu banco de dados.

### Com Docker e Docker Compose

**Pré-requisito**: Instale o Docker e Docker Compose

* [Começar com Docker](https://www.docker.com/get-started)
* [Instalar Docker Compose](https://docs.docker.com/compose/install/)

### Passos para configuração com Docker:

1. **Iniciar o Docker Compose** Execute o comando abaixo para subir os serviços:
    
    ```
    docker-compose up
    ```
    
    Aguarde as mensagens de configuração, como:
    
    ```csharp
    Creating network "northwind_psql_db" with driver "bridge"
    Creating volume "northwind_psql_db" with default driver
    Creating volume "northwind_psql_pgadmin" with default driver
    Creating pgadmin ... done
    Creating db      ... done
    ```
       
2. **Conectar o PgAdmin** Acesse o PgAdmin pelo URL: [http://localhost:5050](http://localhost:5050), com a senha `postgres`. 

Configure um novo servidor no PgAdmin:
    
    * **Aba General**:
        * Nome: db
    * **Aba Connection**:
        * Nome do host: db
        * Nome de usuário: postgres
        * Senha: postgres Em seguida, selecione o banco de dados "northwind".

3. **Parar o Docker Compose** Pare o servidor iniciado pelo comando `docker-compose up` usando Ctrl-C e remova os contêineres com:
    
    ```
    docker-compose down
    ```
    
4. **Arquivos e Persistência** Suas modificações nos bancos de dados Postgres serão persistidas no volume Docker `postgresql_data` e podem ser recuperadas reiniciando o Docker Compose com `docker-compose up`. Para deletar os dados do banco, execute:
    
    ```
    docker-compose down -v
    ```

---

## Reports Created

## Relatórios que vamos criar

1. **Relatórios de Receita**
    
    * Qual foi o total de receitas no ano de 1997?

    * Faça uma análise de crescimento mensal e o cálculo de YTD

2. **Segmentação de clientes**
    
    * Qual é o valor total que cada cliente já pagou até agora?

    * Separe os clientes em 5 grupos de acordo com o valor pago por cliente

    * Agora somente os clientes que estão nos grupos 3, 4 e 5 para que seja feita uma análise de Marketing especial com eles

3. **Top 10 Produtos Mais Vendidos**
    
    * Identificar os 10 produtos mais vendidos.

4. **Clientes do Reino Unido que Pagaram Mais de 1000 Dólares**
    
    * Quais clientes do Reino Unido pagaram mais de 1000 dólares?

---