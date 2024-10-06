CREATE TABLE customer_clv3 AS
SELECT
    co.`Customer ID` AS cust_id,
    co.`Customer Name` AS cust_name,
    MIN(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y')) AS first_order,
    MAX(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y')) AS last_order,
    COUNT(DISTINCT co.`Order ID`) AS total_orders,
    SUM(co.Sales) AS total_revenue,
    SUM(co.Profit) AS total_profit,
    SUM(co.Quantity) AS total_quantity,
    COUNT(DISTINCT co.`Product ID`) AS unique_products,
    MAX(co.Region) AS region,
    MAX(co.State) AS state,
    MAX(co.City) AS city,
    
    -- Time-based metrics
    DATEDIFF(MAX(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y')), MIN(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y'))) AS customer_lifespan,
    COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y'), '%Y-%m')) AS active_months,
    DATEDIFF(CURDATE(), MAX(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y'))) AS days_since_last_order,
    
    -- Average metrics
    AVG(co.Sales) AS avg_order_value,
    SUM(co.Sales) / NULLIF(COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y'), '%Y-%m')), 0) AS avg_monthly_revenue,
    SUM(co.Quantity) / COUNT(DISTINCT co.`Order ID`) AS avg_items_per_order,
    
    -- Frequency and monetary metrics
    COUNT(DISTINCT co.`Order ID`) / NULLIF(COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y'), '%Y-%m')), 0) AS purchase_frequency,
    SUM(co.Profit) / SUM(co.Sales) AS profit_margin,
    
    -- RFM components
    DATEDIFF(CURDATE(), MAX(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y'))) AS recency,
    COUNT(DISTINCT co.`Order ID`) AS frequency,
    SUM(co.Sales) AS monetary,
    
    -- Customer value metrics
    SUM(co.Sales) / NULLIF(DATEDIFF(MAX(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y')), MIN(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y'))), 0) AS revenue_per_day,
    SUM(co.Profit) / NULLIF(DATEDIFF(MAX(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y')), MIN(STR_TO_DATE(co.`Order Date`, '%m/%d/%Y'))), 0) AS profit_per_day,
    
    -- Category preferences
    (SELECT Category
     FROM clean_orders co2
     WHERE co2.`Customer ID` = co.`Customer ID`
     GROUP BY Category
     ORDER BY SUM(Sales) DESC
     LIMIT 1) AS top_category,
    (SELECT SUM(Sales)
     FROM clean_orders co2
     WHERE co2.`Customer ID` = co.`Customer ID`
     GROUP BY Category
     ORDER BY SUM(Sales) DESC
     LIMIT 1) AS top_category_sales
FROM 
    clean_orders co
GROUP BY
    co.`Customer ID`, co.`Customer Name`;



select * from customer_clv3;



WITH customer_metrics AS (
    SELECT 
        `Customer ID`,
        `Customer Name`,
        Region,
        COUNT(DISTINCT `Order ID`) AS total_orders,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit,
        AVG(Sales) AS avg_order_value,
        MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS last_order_date,
        DATEDIFF(CURDATE(), MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))) AS days_since_last_order,
        COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m/%d/%Y'), '%Y-%m')) AS active_months
    FROM clean_orders
    GROUP BY `Customer ID`, `Customer Name`, Region
),
clv_calc AS (
    SELECT 
        *,
        (total_sales / active_months) AS avg_monthly_sales,
        (total_profit / total_sales) AS profit_margin,
        (total_orders / active_months) AS purchase_frequency,
        ((total_sales / active_months) * 12 * 
         (1 / (1 + EXP(-((total_orders / active_months) - 1)))) * 
         (total_profit / total_sales) * 
         (1 / (1 + 0.1 - (total_profit / total_sales)))) AS clv
    FROM customer_metrics
),
ranked_customers AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY clv DESC) AS rank_in_region
    FROM clv_calc
)
SELECT 
    `Customer ID`,
    `Customer Name`,
    Region,
    total_orders,
    total_sales,
    total_profit,
    avg_order_value,
    days_since_last_order,
    active_months,
    avg_monthly_sales,
    profit_margin,
    purchase_frequency,
    clv
FROM ranked_customers
WHERE rank_in_region <= 5
ORDER BY Region, clv DESC;

SELECT DISTINCT `Order ID`,Region,`Customer ID`,City
FROM clean_orders
WHERE `Customer Name` = 'Tamara Chand';

select distinct 'Order ID' from clean_orders where 'Customer Name'='Tamara Chand';



---------------
WITH customer_metrics AS (
    SELECT 
        `Customer ID`,
        `Customer Name`,
        Region,
        State,
        City,
        MAX(Segment) AS Segment,
        COUNT(DISTINCT `Order ID`) AS total_orders,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit,
        SUM(Quantity) AS total_products_bought,
        MIN(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS first_order_date,
        MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS last_order_date,
        COUNT(DISTINCT `Product ID`) AS unique_products_bought
    FROM clean_orders
    GROUP BY `Customer ID`, `Customer Name`, Region, State, City
),
clv_calc AS (
    SELECT 
        *,
        total_orders / 793 AS purchase_frequency,
        GREATEST(TIMESTAMPDIFF(MONTH, first_order_date, last_order_date), 1) AS customer_lifespan_months,
        total_sales / GREATEST(TIMESTAMPDIFF(MONTH, first_order_date, last_order_date), 1) AS avg_monthly_sales,
        total_profit / total_sales AS profit_margin,
        (total_sales / GREATEST(TIMESTAMPDIFF(MONTH, first_order_date, last_order_date), 1)) * 
        (total_orders / 793) * 
        GREATEST(TIMESTAMPDIFF(MONTH, first_order_date, last_order_date), 1) AS clv
    FROM customer_metrics
),
ranked_customers AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY clv DESC) AS rank_in_region
    FROM clv_calc
)
SELECT 
    `Customer ID`,
    `Customer Name`,
    Region,
    State,
    City,
    Segment,
    total_orders,
    total_sales,
    total_profit,
    total_products_bought,
    unique_products_bought,
    first_order_date,
    last_order_date,
    customer_lifespan_months,
    purchase_frequency,
    avg_monthly_sales,
    profit_margin,
    clv
FROM ranked_customers
WHERE rank_in_region <= 5
ORDER BY Region, clv DESC;



WITH customer_metrics AS (
    SELECT 
        `Customer ID`,
        `Customer Name`,
        MAX(Segment) AS Segment,
        COUNT(DISTINCT `Order ID`) AS total_orders,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit,
        SUM(Quantity) AS total_products_bought,
        MIN(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS first_order_date,
        MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS last_order_date,
        COUNT(DISTINCT `Product ID`) AS unique_products_bought
    FROM clean_orders
    GROUP BY `Customer ID`, `Customer Name`
),
clv_calc AS (
    SELECT 
        *,
        total_orders / 793 AS purchase_frequency,
        GREATEST(TIMESTAMPDIFF(MONTH, first_order_date, last_order_date), 1) AS customer_lifespan_months,
        total_sales / GREATEST(TIMESTAMPDIFF(MONTH, first_order_date, last_order_date), 1) AS avg_monthly_sales,
        total_profit / total_sales AS profit_margin,
        (total_sales / GREATEST(TIMESTAMPDIFF(MONTH, first_order_date, last_order_date), 1)) * 
        (total_orders / 793) * 
        GREATEST(TIMESTAMPDIFF(MONTH, first_order_date, last_order_date), 1) AS clv
    FROM customer_metrics
),
ranked_customers AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Segment ORDER BY clv DESC) AS rank_in_segment
    FROM clv_calc
)
SELECT 
    `Customer ID`,
    `Customer Name`,
    Segment,
    total_orders,
    total_sales,
    total_profit,
    total_products_bought,
    unique_products_bought,
    first_order_date,
    last_order_date,
    customer_lifespan_months,
    purchase_frequency,
    avg_monthly_sales,
    profit_margin,
    clv
FROM ranked_customers
WHERE rank_in_segment <= 5
ORDER BY Segment, clv DESC;



----------------
WITH customer_metrics AS (
    SELECT 
        `Customer ID`,
        `Customer Name`,
        MAX(Segment) AS Segment,
        COUNT(DISTINCT `Order ID`) AS total_orders,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit,
        SUM(Quantity) AS total_products_bought,
        DATE_FORMAT(MIN(STR_TO_DATE(`Order Date`, '%m/%d/%Y')), '%Y-%m-%d') AS first_order_date,
        DATE_FORMAT(MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')), '%Y-%m-%d') AS last_order_date,
        COUNT(DISTINCT `Product ID`) AS unique_products_bought
    FROM clean_orders
    GROUP BY `Customer ID`, `Customer Name`
    HAVING SUM(Profit) >= 0  -- This line filters out customers with negative total profit
),
clv_calc AS (
    SELECT 
        *,
        total_orders / 793 AS purchase_frequency,
        GREATEST(TIMESTAMPDIFF(MONTH, STR_TO_DATE(first_order_date, '%Y-%m-%d'), STR_TO_DATE(last_order_date, '%Y-%m-%d')), 1) AS customer_lifespan_months,
        total_sales / GREATEST(TIMESTAMPDIFF(MONTH, STR_TO_DATE(first_order_date, '%Y-%m-%d'), STR_TO_DATE(last_order_date, '%Y-%m-%d')), 1) AS avg_monthly_sales,
        total_profit / GREATEST(TIMESTAMPDIFF(MONTH, STR_TO_DATE(first_order_date, '%Y-%m-%d'), STR_TO_DATE(last_order_date, '%Y-%m-%d')), 1) AS avg_monthly_profit,
        (
            (0.7 * (total_sales / GREATEST(TIMESTAMPDIFF(MONTH, STR_TO_DATE(first_order_date, '%Y-%m-%d'), STR_TO_DATE(last_order_date, '%Y-%m-%d')), 1))) + 
            (0.3 * (total_profit / GREATEST(TIMESTAMPDIFF(MONTH, STR_TO_DATE(first_order_date, '%Y-%m-%d'), STR_TO_DATE(last_order_date, '%Y-%m-%d')), 1)))
        ) * 
        GREATEST(TIMESTAMPDIFF(MONTH, STR_TO_DATE(first_order_date, '%Y-%m-%d'), STR_TO_DATE(last_order_date, '%Y-%m-%d')), 1) * 
        (1 + (total_orders / 793)) AS clv
    FROM customer_metrics
),
ranked_customers AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Segment ORDER BY clv DESC) AS rank_in_segment
    FROM clv_calc
)
SELECT 
    `Customer ID`,
    `Customer Name`,
    Segment,
    total_orders,
    total_sales,
    total_profit,
    total_products_bought,
    unique_products_bought,
    first_order_date,
    last_order_date,
    customer_lifespan_months,
    purchase_frequency,
    avg_monthly_sales,
    avg_monthly_profit,
    clv
FROM ranked_customers
WHERE rank_in_segment <= 5
ORDER BY Segment, clv DESC;