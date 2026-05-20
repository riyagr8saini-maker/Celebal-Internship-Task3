USE SuperstoreDB;
-- Create Customers table
CREATE TABLE customers AS
SELECT DISTINCT 
    `Customer ID`, 
    `Customer Name`, 
    Segment, 
    Country, 
    City, 
    State, 
    Region
FROM sales;
SELECT COUNT(*) FROM customers;

-- Create Orders table
CREATE TABLE orders AS
SELECT DISTINCT 
    `Order ID`, 
    `Order Date`, 
    `Ship Date`, 
    `Ship Mode`, 
    `Customer ID`
FROM sales;
SELECT COUNT(*) FROM orders;

-- Create Products table
CREATE TABLE products AS
SELECT DISTINCT 
    `Product ID`, 
    Category, 
    `Sub-Category`, 
    `Product Name`
FROM sales;

-- Above average sales per order
SELECT o.`Order ID`, o.`Customer ID`, c.`Customer Name`, SUM(sales.Sales) AS OrderSales
FROM sales
JOIN orders o ON sales.`Order ID` = o.`Order ID`
JOIN customers c ON o.`Customer ID` = c.`Customer ID`
GROUP BY o.`Order ID`, o.`Customer ID`, c.`Customer Name`
HAVING SUM(sales.Sales) > (
    SELECT AVG(Sales) FROM sales
);

-- Highest order amount per customer 
-- Step 1: Calculate order totals
WITH order_totals AS (
    SELECT 
        s.`Order ID`, 
        o.`Customer ID`, 
        SUM(s.Sales) AS OrderSales
    FROM sales s
    JOIN orders o ON s.`Order ID` = o.`Order ID`
    GROUP BY s.`Order ID`, o.`Customer ID`
),

-- Step 2: Find max order per customer
max_orders AS (
    SELECT 
        `Customer ID`, 
        MAX(OrderSales) AS MaxOrderSales
    FROM order_totals
    GROUP BY `Customer ID`
)

-- Step 3: Join to get details
SELECT 
    c.`Customer ID`, 
    c.`Customer Name`, 
    ot.`Order ID`, 
    ot.OrderSales
FROM order_totals ot
JOIN max_orders mo 
    ON ot.`Customer ID` = mo.`Customer ID` 
   AND ot.OrderSales = mo.MaxOrderSales
JOIN customers c 
    ON ot.`Customer ID` = c.`Customer ID`;
    
-- Total sales per customer using CTE
WITH customer_sales AS (
    SELECT 
        c.`Customer ID`, 
        c.`Customer Name`, 
        SUM(s.Sales) AS TotalSales
    FROM sales s
    JOIN customers c ON s.`Customer ID` = c.`Customer ID`
    GROUP BY c.`Customer ID`, c.`Customer Name`
)
SELECT * 
FROM customer_sales
ORDER BY TotalSales DESC;

-- Rank customers by total sales
WITH customer_sales AS (
    SELECT 
        c.`Customer ID`, 
        c.`Customer Name`, 
        SUM(s.Sales) AS TotalSales
    FROM sales s
    JOIN customers c ON s.`Customer ID` = c.`Customer ID`
    GROUP BY c.`Customer ID`, c.`Customer Name`
)
SELECT 
    `Customer ID`, 
    `Customer Name`, 
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank,
    DENSE_RANK() OVER (ORDER BY TotalSales DESC) AS DenseRank,
    ROW_NUMBER() OVER (ORDER BY TotalSales DESC) AS RowNum
FROM customer_sales;

-- Final analysis: customer, total sales, rank
WITH customer_sales AS (
    SELECT 
        c.`Customer ID`, 
        c.`Customer Name`, 
        SUM(s.Sales) AS TotalSales
    FROM sales s
    JOIN customers c ON s.`Customer ID` = c.`Customer ID`
    GROUP BY c.`Customer ID`, c.`Customer Name`
)
SELECT 
    cs.`Customer ID`, 
    cs.`Customer Name`, 
    cs.TotalSales,
    RANK() OVER (ORDER BY cs.TotalSales DESC) AS SalesRank,
    DENSE_RANK() OVER (ORDER BY cs.TotalSales DESC) AS DenseRank,
    ROW_NUMBER() OVER (ORDER BY cs.TotalSales DESC) AS RowNum
FROM customer_sales cs
ORDER BY SalesRank;









