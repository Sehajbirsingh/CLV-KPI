-- Check for NULL or missing values in orders table
SELECT * 
FROM orders 
WHERE `Order ID` IS NULL
   OR `Customer ID` IS NULL
   OR `Sales` IS NULL
   OR `Profit` IS NULL;

select count(*) from orders; --9994

select  count(distinct `Order ID`,`Product ID`) from orders; --9986



SELECT `Order ID`, `Product ID`, COUNT(*) AS count
FROM orders
GROUP BY `Order ID`, `Product ID`
HAVING COUNT(*) > 1;



SELECT o.*
FROM orders o
JOIN (
    SELECT `Order ID`, `Product ID`
    FROM orders
    GROUP BY `Order ID`, `Product ID`
    HAVING COUNT(*) > 1
) dup
ON o.`Order ID` = dup.`Order ID` AND o.`Product ID` = dup.`Product ID`;

SELECT o.`Product ID`,o.`Order ID`,o.`Sales`,o.`Quantity`,o.`Discount`,o.`Profit`
FROM orders o
JOIN (
    SELECT `Order ID`, `Product ID`
    FROM orders
    GROUP BY `Order ID`, `Product ID`
    HAVING COUNT(*) > 1
) dup
ON o.`Order ID` = dup.`Order ID` AND o.`Product ID` = dup.`Product ID`;
--product id =OFF-PA-10001970 , order id = CA-2020-129714
--sales= 49.12, 24.56
--quantity = 4,2
--discount = 0, 0
--profit = 23.0864, 11.5432





CREATE  TABLE merged_orders AS
SELECT 
    `Order ID`, 
    `Product ID`, 
    MAX(`Order Date`) AS `Order Date`, 
    MAX(`Ship Date`) AS `Ship Date`, 
    MAX(`Ship Mode`) AS `Ship Mode`, 
    MAX(`Customer ID`) AS `Customer ID`, 
    MAX(`Customer Name`) AS `Customer Name`, 
    MAX(`Segment`) AS `Segment`, 
    MAX(`Country/Region`) AS `Country/Region`, 
    MAX(`City`) AS `City`, 
    MAX(`State`) AS `State`, 
    MAX(`Postal Code`) AS `Postal Code`, 
    MAX(`Region`) AS `Region`, 
    MAX(`Category`) AS `Category`, 
    MAX(`Sub-Category`) AS `Sub-Category`, 
    MAX(`Product Name`) AS `Product Name`, 
    SUM(`Sales`) AS `Total Sales`, 
    SUM(`Quantity`) AS `Total Quantity`, 
    MAX(`Discount`) AS `Discount`, 
    SUM(`Profit`) AS `Total Profit`
FROM orders
GROUP BY `Order ID`, `Product ID`;

CREATE  TABLE clean_orders AS
SELECT 
    `Order ID`, 
    `Product ID`, 
    MAX(`Order Date`) AS `Order Date`, 
    MAX(`Ship Date`) AS `Ship Date`, 
    MAX(`Ship Mode`) AS `Ship Mode`, 
    MAX(`Customer ID`) AS `Customer ID`, 
    MAX(`Customer Name`) AS `Customer Name`, 
    MAX(`Segment`) AS `Segment`, 
    MAX(`Country/Region`) AS `Country/Region`, 
    MAX(`City`) AS `City`, 
    MAX(`State`) AS `State`, 
    MAX(`Postal Code`) AS `Postal Code`, 
    MAX(`Region`) AS `Region`, 
    MAX(`Category`) AS `Category`, 
    MAX(`Sub-Category`) AS `Sub-Category`, 
    MAX(`Product Name`) AS `Product Name`, 
    SUM(`Sales`) AS `Total Sales`, 
    SUM(`Quantity`) AS `Total Quantity`, 
    MAX(`Discount`) AS `Discount`, 
    SUM(`Profit`) AS `Total Profit`
FROM orders
GROUP BY `Order ID`, `Product ID`;

select count(*) from clean_orders; --9986

update clean_orders set `Postal Code` = '0000' where `Postal Code` = '';



SELECT COUNT(*) FROM merged_orders;  --9986
--issue solved

SELECT `Order ID`, `Product ID`, COUNT(*) AS count
FROM merged_orders
GROUP BY `Order ID`, `Product ID`
HAVING COUNT(*) > 1; --0



select `Order ID` from merged_orders limit 10;
 


--before :

--product id =OFF-PA-10001970 , order id = CA-2020-129714
--sales= 49.12, 24.56
--quantity = 4,2
--discount = 0, 0
--profit = 23.0864, 11.5432

--after:
select * from merged_orders where `Order ID`='CA-2020-129714' and `Product ID`='OFF-PA-10001970';

select * from merged_orders where `Order ID`='US-2018-150119' and `Product ID`='FUR-CH-10002965';


select count(*) from temp_merged_orders;

-- Replace the original orders table with the merged data
TRUNCATE TABLE orders;

INSERT INTO orders
SELECT * FROM merged_orders;

-- Drop the temporary table
DROP TEMPORARY TABLE merged_orders;

-- Verify the results
SELECT COUNT(*) FROM orders;

SELECT o.`Product ID`, o.`Order ID`, o.`Sales`, o.`Quantity`, o.`Discount`, o.`Profit`
FROM orders o
WHERE (`Order ID`, `Product ID`) IN (
    SELECT `Order ID`, `Product ID`
    FROM (
        SELECT `Order ID`, `Product ID`
        FROM orders
        GROUP BY `Order ID`, `Product ID`
        HAVING COUNT(*) > 1
    ) dup
);

---redunddancy check 

select distinct `Country/Region` from orders; --1 value thus drop this column


-- Drop the 'Country/Region' column from the merged_orders table
ALTER TABLE merged_orders
DROP COLUMN `Country/Region`;

-- Verify the column has been dropped
DESCRIBE merged_orders;

--deleting orders from table which were returned

SELECT count(DISTINCT `Order ID`)
FROM returns
WHERE Returned = 'Yes'; --296

DELETE FROM merged_orders
WHERE `Order ID` IN (
    SELECT DISTINCT `Order ID`
    FROM returns
    WHERE Returned = 'Yes'
);

select count(*) from merged_orders; --9186 = > 9196-800

-- Target Audience and Report Purposes

-- 1. Operational Reports
--    Target Audience: Mid-level managers, department heads, and team leaders
--    Intended Use:
--    - Monitor and control daily operations
--    - Identify short-term trends and issues
--    - Support tactical decision-making
--    - Drive performance improvement initiatives
--    Examples:
--    - Daily sales reports
--    - Inventory levels
--    - Customer service response times

-- 2. Executive Reports
--    Target Audience: C-level executives, board members, and senior management
--    Intended Use:
--    - Support strategic decision-making
--    - Analyze long-term trends and overall company performance
--    - Facilitate research analysis for future planning
--    - Monitor key performance indicators (KPIs)
--    Examples:
--    - Quarterly financial summaries
--    - Market share analysis
--    - Year-over-year growth comparisons

-- Note: The data in our 'orders' table can be used to generate both types of reports,
-- focusing on different metrics and time frames as appropriate for each audience.

-- Business Context and Assumptions for Report Generation

-- Business Context:
-- 1. Our company operates in a retail environment with diverse product categories.
-- 2. We have a nation wide presence(USA), serving customers across different regions.
-- 3. Reports are generated regularly for both operational and strategic purposes.
-- 4. Data from the 'merged_orders' table forms the basis of our reporting system.

-- Assumptions:
-- 1. Returned orders (as previously removed) were fully processed and refunded.
--    These orders are excluded from our analysis to avoid skewing results.
-- 2. All monetary values in the 'Sales' and 'Profit' columns are in a single, consistent currency.
-- 3. The 'Order Date' and 'Ship Date' are accurate and reflect actual business operations.
-- 4. Customer segmentation ('Segment' column) is up-to-date and accurately categorized.
-- 5. Product categorization ('Category' and 'Sub-Category' columns) is consistent and current.
-- 6. Seasonal trends may impact sales and should be considered in long-term analyses.
-- 7. The 'Discount' column accurately reflects all price reductions applied to orders.

-- These contexts and assumptions will guide our report generation process,
-- ensuring that the insights derived are relevant, accurate, and actionable
-- for both operational and executive decision-making.

--
--postal code blank replace with 0000

select distinct * from merged_orders where `Postal Code` = ''; --15000

update merged_orders set `Postal Code` = '0000' where `Postal Code` = '';

--CA-2021-104066

select * from merged_orders where `Order ID`='CA-2021-104066';


SELECT * INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ordercleaned.xlsx'
FROM clean_orders;


DESCRIBE clean_orders;



SELECT 'Order ID', 'Product ID', 'Order Date', 'Ship Date', 'Ship Mode', 'Customer ID', 
       'Customer Name', 'Segment', 'Country/Region', 'City', 'State', 'Postal Code', 
       'Region', 'Category', 'Sub-Category', 'Product Name', 'Total Sales', 
       'Total Quantity', 'Discount', 'Total Profit'
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order.cleaned.csv'
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n';


-- Export the clean_orders table to CSV file with headers
SELECT 'Order ID', 'Product ID', 'Order Date', 'Ship Date', 'Ship Mode', 'Customer ID', 
       'Customer Name', 'Segment', 'Country/Region', 'City', 'State', 'Postal Code', 
       'Region', 'Category', 'Sub-Category', 'Product Name', 'Total Sales', 
       'Total Quantity', 'Discount', 'Total Profit'
UNION ALL
SELECT `Order ID`, `Product ID`, `Order Date`, `Ship Date`, `Ship Mode`, `Customer ID`, 
       `Customer Name`, `Segment`, `Country/Region`, `City`, `State`, `Postal Code`, 
       `Region`, `Category`, `Sub-Category`, `Product Name`, `Total Sales`, 
       `Total Quantity`, `Discount`, `Total Profit`
FROM clean_orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order.cleaned.csv'
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n';



--select distinct city for jan 2021 where region is central, I think order date is in string format




select distinct `City` from clean_orders where `Region`='Central' and `Order Date` like '01/%/2021';

select distinct `Order Date` from clean_orders where `Region`='Central' order by `Order Date` desc limit 10 ;

SELECT DISTINCT `City`,`Customer Name`,`Product Name`
FROM clean_orders
WHERE `Region` = 'Central'
  AND STR_TO_DATE(`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31';




SELECT 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Order ID`,
    COUNT(DISTINCT co.`Product ID`) AS `Distinct Products Bought`,
    SUM(co.`Total Sales`) AS `Total Sales`,
    SUM(co.`Total Profit`) AS `Total Profit`,
    co.`Order Date`,
    co.`Ship Date`,
    co.`Ship Mode`,
    co.`Segment`
FROM 
    clean_orders co
WHERE 
    co.`Region` = 'Central'
    AND STR_TO_DATE(co.`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Order ID`,
    co.`Order Date`,
    co.`Ship Date`,
    co.`Ship Mode`,
    co.`Segment`
ORDER BY 
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Order Date`;



-------------------------------

WITH CustomerSummary AS (
    SELECT 
        `Customer Name`,
        SUM(`Total Sales`) AS `Gross Spent`,
        SUM(`Total Profit`) AS `Gross Profit`,
        COUNT(DISTINCT `Order ID`) AS `Order Count`
    FROM clean_orders
    WHERE `Region` = 'Central'
        AND STR_TO_DATE(`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
    GROUP BY `Customer Name`
)

SELECT 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Order ID`,
    COUNT(DISTINCT co.`Product ID`) AS `Distinct Products Bought`,
    SUM(co.`Total Sales`) AS `Order Total Sales`,
    SUM(co.`Total Profit`) AS `Order Total Profit`,
    co.`Order Date`,
    co.`Ship Date`,
    co.`Ship Mode`,
    co.`Segment`,
    co.`Category`,
    cs.`Gross Spent` AS `Customer Gross Spent`,
    cs.`Gross Profit` AS `Customer Gross Profit`,
    ROUND(cs.`Gross Profit` / cs.`Gross Spent` * 100, 2) AS `Customer Profit Margin %`,
    cs.`Order Count` AS `Customer Order Count`
FROM 
    clean_orders co
JOIN CustomerSummary cs ON co.`Customer Name` = cs.`Customer Name`
WHERE 
    co.`Region` = 'Central'
    AND STR_TO_DATE(co.`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Order ID`,
    co.`Order Date`,
    co.`Ship Date`,
    co.`Ship Mode`,
    co.`Segment`,
    co.`Category`,
    cs.`Gross Spent`,
    cs.`Gross Profit`,
    cs.`Order Count`
ORDER BY 
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Order Date`;



    ---------------------------


WITH CategoryMetrics AS (
    SELECT 
        `Category`,
        SUM(`Total Quantity`) AS `Total Quantity`,
        AVG(`Discount`) AS `Avg Discount`
    FROM clean_orders
    WHERE `Region` = 'Central'
        AND STR_TO_DATE(`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
    GROUP BY `Category`
),
CustomerMetrics AS (
    SELECT 
        `Customer Name`,
        SUM(`Total Sales`) AS `Gross Sales`,
        SUM(`Total Profit`) AS `Total Profit`
    FROM clean_orders
    WHERE `Region` = 'Central'
        AND STR_TO_DATE(`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
    GROUP BY `Customer Name`
)
SELECT 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    cm.`Gross Sales` AS `Customer Gross Sales`,
    cm.`Total Profit` AS `Customer Total Profit`,
    co.`Category`,
    cat.`Total Quantity` AS `Category Total Quantity`,
    ROUND(cat.`Avg Discount` * 100, 2) AS `Category Avg Discount %`
FROM 
    clean_orders co
JOIN CustomerMetrics cm ON co.`Customer Name` = cm.`Customer Name`
JOIN CategoryMetrics cat ON co.`Category` = cat.`Category`
WHERE 
    co.`Region` = 'Central'
    AND STR_TO_DATE(co.`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    cm.`Gross Sales`,
    cm.`Total Profit`,
    co.`Category`,
    cat.`Total Quantity`,
    cat.`Avg Discount`
ORDER BY 
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Category`;


    ----------------------

WITH CategoryCustomerMetrics AS (
    SELECT 
        `Customer Name`,
        `Category`,
        SUM(`Total Quantity`) AS `Total Quantity`,
        SUM(`Total Sales`) AS `Total Sales`,
        SUM(`Total Profit`) AS `Total Profit`,
        AVG(`Discount`) AS `Avg Discount`
    FROM clean_orders
    WHERE 
        STR_TO_DATE(`Order Date`, '%m/%d/%Y') BETWEEN '2022-01-01' AND '2022-01-31'
    GROUP BY `Customer Name`, `Category`
),
CustomerMetrics AS (
    SELECT 
        `Customer Name`,
        SUM(`Total Sales`) AS `Gross Sales`,
        SUM(`Total Profit`) AS `Total Profit`,
        SUM(`Total Quantity`) AS `Total Quantity`
    FROM clean_orders
    WHERE 
        STR_TO_DATE(`Order Date`, '%m/%d/%Y') BETWEEN '2022-01-01' AND '2022-01-31'
    GROUP BY `Customer Name`
)
SELECT 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    cm.`Gross Sales` AS `Customer Total Sales`,
    cm.`Total Profit` AS `Customer Total Profit`,
    cm.`Total Quantity` AS `Customer Total Quantity`,
    ROUND(cm.`Total Profit` / cm.`Gross Sales` * 100, 2) AS `Customer Profit Margin %`,
    co.`Category`,
    ccm.`Total Quantity` AS `Category Customer Quantity`,
    ccm.`Total Sales` AS `Category Customer Sales`,
    ccm.`Total Profit` AS `Category Customer Profit`,
    ROUND(ccm.`Avg Discount` * 100, 2) AS `Category Customer Avg Discount %`,
    ROUND(ccm.`Total Profit` / ccm.`Total Sales` * 100, 2) AS `Category Customer Profit Margin %`
FROM 
    clean_orders co
JOIN CustomerMetrics cm ON co.`Customer Name` = cm.`Customer Name`
JOIN CategoryCustomerMetrics ccm ON co.`Customer Name` = ccm.`Customer Name` AND co.`Category` = ccm.`Category`
WHERE 
    STR_TO_DATE(co.`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    cm.`Gross Sales`,
    cm.`Total Profit`,
    cm.`Total Quantity`,
    co.`Category`,
    ccm.`Total Quantity`,
    ccm.`Total Sales`,
    ccm.`Total Profit`,
    ccm.`Avg Discount`
ORDER BY 
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Category`;



-----------------------
WITH CategoryCustomerMetrics AS (
    SELECT 
        `Region`,
        `Customer Name`,
        `Category`,
        SUM(`Total Quantity`) AS `Total Quantity`,
        SUM(`Total Sales`) AS `Total Sales`,
        SUM(`Total Profit`) AS `Total Profit`,
        AVG(`Discount`) AS `Avg Discount`
    FROM clean_orders
    WHERE STR_TO_DATE(`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
    GROUP BY `Region`, `Customer Name`, `Category`
),
CustomerMetrics AS (
    SELECT 
        `Region`,
        `Customer Name`,
        SUM(`Total Sales`) AS `Gross Sales`,
        SUM(`Total Profit`) AS `Total Profit`,
        SUM(`Total Quantity`) AS `Total Quantity`
    FROM clean_orders
    WHERE STR_TO_DATE(`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
    GROUP BY `Region`, `Customer Name`
)
SELECT 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    cm.`Gross Sales` AS `Customer Total Sales`,
    cm.`Total Profit` AS `Customer Total Profit`,
    cm.`Total Quantity` AS `Customer Total Quantity`,
    ROUND(cm.`Total Profit` / cm.`Gross Sales` * 100, 2) AS `Customer Profit Margin %`,
    co.`Category`,
    ccm.`Total Quantity` AS `Category Customer Quantity`,
    ccm.`Total Sales` AS `Category Customer Sales`,
    ccm.`Total Profit` AS `Category Customer Profit`,
    ROUND(ccm.`Avg Discount` * 100, 2) AS `Category Customer Avg Discount %`,
    ROUND(ccm.`Total Profit` / ccm.`Total Sales` * 100, 2) AS `Category Customer Profit Margin %`
FROM 
    clean_orders co
JOIN CustomerMetrics cm ON co.`Customer Name` = cm.`Customer Name` AND co.`Region` = cm.`Region`
JOIN CategoryCustomerMetrics ccm ON co.`Customer Name` = ccm.`Customer Name` AND co.`Category` = ccm.`Category` AND co.`Region` = ccm.`Region`
WHERE 
    STR_TO_DATE(co.`Order Date`, '%m/%d/%Y') BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    cm.`Gross Sales`,
    cm.`Total Profit`,
    cm.`Total Quantity`,
    co.`Category`,
    ccm.`Total Quantity`,
    ccm.`Total Sales`,
    ccm.`Total Profit`,
    ccm.`Avg Discount`
ORDER BY 
    co.`Region`,
    co.`State`,
    co.`City`,
    co.`Customer Name`,
    co.`Category`;




SELECT MIN(`Order Date`), MAX(`Order Date`)
FROM clean_orders
WHERE `Order Date` LIKE '2022-01%';

--get names of columns in clean_orders
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'clean_orders';

----------------------------------------

--rename total sales to sales, total profit to profit, total quantity to quantity
ALTER TABLE clean_orders
RENAME COLUMN `Total Sales` TO `Sales`;

ALTER TABLE clean_orders
RENAME COLUMN `Total Profit` TO `Profit`;

ALTER TABLE clean_orders
RENAME COLUMN `Total Quantity` TO `Quantity`;

-----------------


CREATE TABLE customer_clv AS
SELECT
    `Customer ID` AS Customer_ID,
    `Customer Name` AS Customer_Name,
    MIN(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS First_Order_Date,
    MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS Last_Order_Date,
    COUNT(DISTINCT `Order ID`) AS Total_Orders_Placed,
    COUNT(DISTINCT `Product ID`) AS Total_Products_Purchased,
    SUM(Quantity) / COUNT(DISTINCT `Order ID`) AS Avg_Products_per_Order,
    COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m/%d/%Y'), '%Y-%m')) AS Months_Active,
    SUM(Sales) AS Total_Spend,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity_Purchased,
    MAX(Region) AS Region,
    MAX(State) AS State,
    MAX(City) AS City,
    AVG(Sales) AS Avg_Order_Value,
    SUM(Profit) / SUM(Sales) AS Profit_Margin,
    DATEDIFF(MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')), MIN(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))) AS Customer_Lifespan_Days,
    COUNT(DISTINCT `Order ID`) / NULLIF(COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m/%d/%Y'), '%Y-%m')), 0) AS Purchase_Frequency,
    DATEDIFF(CURDATE(), MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))) AS Days_Since_Last_Purchase,
    CASE
        WHEN DATEDIFF(CURDATE(), MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))) > 365 THEN 'Inactive'
        WHEN DATEDIFF(CURDATE(), MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))) BETWEEN 181 AND 365 THEN 'At Risk'
        WHEN DATEDIFF(CURDATE(), MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))) BETWEEN 91 AND 180 THEN 'Needs Attention'
        ELSE 'Active'
    END AS Customer_Status,
    (SUM(Sales) / NULLIF(COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m/%d/%Y'), '%Y-%m')), 0)) * 12 * 
    (1 / (1 + EXP(-((COUNT(DISTINCT `Order ID`) / NULLIF(COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m/%d/%Y'), '%Y-%m')), 0)) - 1)))) *
    (SUM(Profit) / NULLIF(SUM(Sales), 0)) AS Customer_Lifetime_Value
FROM
    clean_orders
GROUP BY
    `Customer ID`, `Customer Name`
HAVING
    COUNT(*) > 0;

select * from customer_clv;


CREATE TABLE customer_clv2 AS
SELECT
    `Customer ID` AS cust_id,
    `Customer Name` AS cust_name,
    MIN(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS first_order,
    MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS last_order,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT `Product ID`) AS total_products,
    SUM(Quantity) AS total_quantity,
    SUM(Quantity) / COUNT(DISTINCT `Order ID`) AS avg_prod_per_order,
    COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m/%d/%Y'), '%Y-%m')) AS active_months,
    SUM(Sales) AS total_spend,
    SUM(Profit) AS total_profit,
    MAX(Region) AS region,
    MAX(State) AS state,
    MAX(City) AS city,
    AVG(Sales) AS avg_order_value,
    SUM(Profit) / SUM(Sales) AS profit_margin,
    DATEDIFF(MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y')), MIN(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))) AS customer_lifespan,
    COUNT(DISTINCT `Order ID`) / NULLIF(COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m/%d/%Y'), '%Y-%m')), 0) AS purchase_freq,
    DATEDIFF(CURDATE(), MAX(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))) AS days_since_last,
    SUM(Quantity) / COUNT(DISTINCT `Product ID`) AS avg_quantity_per_product
FROM
    clean_orders
GROUP BY
    `Customer ID`, `Customer Name`;

select * from customer_clv2;
