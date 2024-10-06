CREATE TABLE emp (
    emp_id INT PRIMARY KEY,        -- Employee ID
    first_name VARCHAR(50),        -- First Name
    last_name VARCHAR(50),         -- Last Name
    department VARCHAR(50),        -- Department
    job_title VARCHAR(50),         -- Job Title
    salary DECIMAL(10, 2),         -- Salary
    hire_date DATE,                -- Hire Date
    email VARCHAR(100),            -- Email
    phone_number VARCHAR(15),      -- Phone Number
    city VARCHAR(50)               -- City
);

-- Inserting data into the emp table
INSERT INTO emp (emp_id, first_name, last_name, department, job_title, salary, hire_date, email, phone_number, city)
VALUES 
(1, 'John', 'Doe', 'IT', 'Software Engineer', 80000, '2022-01-15', 'john.doe@example.com', '555-1234', 'New York'),
(2, 'Jane', 'Smith', 'HR', 'HR Manager', 75000, '2021-07-20', 'jane.smith@example.com', '555-5678', 'Chicago'),
(3, 'Michael', 'Johnson', 'Finance', 'Accountant', 68000, '2020-05-10', 'michael.johnson@example.com', '555-8765', 'San Francisco'),
(4, 'Emily', 'Davis', 'Marketing', 'Marketing Manager', 72000, '2019-11-23', 'emily.davis@example.com', '555-4567', 'Los Angeles'),
(5, 'Chris', 'Brown', 'Sales', 'Sales Executive', 65000, '2022-09-30', 'chris.brown@example.com', '555-2345', 'Houston'),
(6, 'Amanda', 'Clark', 'IT', 'Data Analyst', 82000, '2021-03-01', 'amanda.clark@example.com', '555-6543', 'New York'),
(7, 'Robert', 'Miller', 'Operations', 'Operations Manager', 90000, '2020-10-12', 'robert.miller@example.com', '555-7890', 'Chicago'),
(8, 'Jessica', 'Taylor', 'Legal', 'Legal Advisor', 88000, '2023-04-05', 'jessica.taylor@example.com', '555-9876', 'Miami'),
(9, 'David', 'Anderson', 'IT', 'Cloud Engineer', 95000, '2021-08-17', 'david.anderson@example.com', '555-5432', 'Seattle'),
(10, 'Sophia', 'Wilson', 'Admin', 'Administrative Assistant', 60000, '2019-06-28', 'sophia.wilson@example.com', '555-0987', 'Atlanta');


select * FROM emp ;

SELECT COUNT(*) FROM merged_orders;  

select  count(*) FROM returns limit 5 ;

CREATE DATABASE IF NOT EXISTS DB_1;
USE DB_1;

CREATE TABLE orders (
    Row_ID INT  PRIMARY KEY,
    Order_ID TEXT,
    Order_Date TEXT,
    Ship_Date TEXT,
    Ship_Mode TEXT,
    Customer_ID TEXT,
    Customer_Name TEXT,
    Segment TEXT,
    Country_Region TEXT,
    City TEXT,
    State TEXT,
    Postal_Code INT,
    Region TEXT,
    Product_ID TEXT,
    Category TEXT,
    Sub_Category TEXT,
    Product_Name TEXT,
    Sales DOUBLE,
    Quantity INT,
    Discount DOUBLE,
    Profit DOUBLE
);

select * FROM orders limit 5 ;

--return data type of column Sales from orders table
select data_type FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'Sales';

-- Load data from CSV file into orders table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Orders (1).csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify the data has been loaded
SELECT COUNT(*) FROM orders;
SELECT * FROM orders LIMIT 5;





SHOW VARIABLES LIKE 'secure_file_priv';

