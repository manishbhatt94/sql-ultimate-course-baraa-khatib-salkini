USE `salesdb`;

SELECT * FROM orders;
SELECT * FROM products;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | BASICS
===============================================================================*/

/* TASK 1: 
   Calculate the Total Sales Across All Orders 
*/
SELECT SUM(sales) AS total_sales FROM orders;


/* TASK 2: 
   Calculate the Total Sales for Each Product 
*/
SELECT productid, SUM(sales) AS total_sales FROM orders GROUP BY productid;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | OVER CLAUSE
===============================================================================*/

/* TASK 3: 
   Find the total sales across all orders,
   additionally providing details such as OrderID and OrderDate 
*/

SELECT OrderId, OrderDate,
	SUM(Sales) OVER() AS TotalSales
FROM Orders;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | PARTITION CLAUSE
===============================================================================*/

/* TASK 4: 
   Find the total sales across all orders and for each product,
   additionally providing details such as OrderID and OrderDate 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,
    SUM(Sales) OVER () AS Total_Sales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS Sales_By_Product
FROM Orders;


/* TASK 5: 
   Find the total sales across all orders, for each product,
   and for each combination of product and order status,
   additionally providing details such as OrderID and OrderDate 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER () AS Total_Sales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS Sales_By_Product,
    SUM(Sales) OVER (PARTITION BY ProductID, OrderStatus) AS Sales_By_Product_Status
FROM Orders;


/* ==============================================================================
   SQL WINDOW FUNCTIONS | ORDER CLAUSE
===============================================================================*/

/* TASK 6: 
   Rank each order by Sales from highest to lowest */
SELECT
    OrderID,
    OrderDate,
    Sales,
    RANK() OVER (ORDER BY Sales DESC) AS Rank_Sales
FROM Orders;


/* ==============================================================================
   SQL WINDOW FUNCTIONS | FRAME CLAUSE
===============================================================================*/

SELECT OrderID,
    OrderDate, ProductID, OrderStatus, Sales,
    SUM(Sales) OVER(
		ORDER BY OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS SalesRunningTotal
FROM Orders;

SELECT OrderID,
    OrderDate, ProductID, OrderStatus, Sales,
    SUM(Sales) OVER(
		ORDER BY OrderDate
        ROWS UNBOUNDED PRECEDING -- Same as above query.
        -- Shorthand form: Can omit the "following" part - which is implied as CURRENT ROW.
        -- Cannot omit the "preceding" part - this is an SQL syntax error.
	) AS SalesRunningTotal
FROM Orders;

SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
    SUM(Sales) OVER(
		ORDER BY OrderDate
        ROWS UNBOUNDED FOLLOWING  -- ERROR! Error Code: 1064
        -- SQL Error: ^^^^^^^^^^
        -- "FOLLOWING" is not valid at this position. Same ways below is also invalid, similar error
        -- ROWS 2 FOLLOWING
	) AS SalesTotalX
FROM Orders;

SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
    SUM(Sales) OVER(
		ORDER BY OrderDate
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) AS SalesTotalX
FROM Orders;

-- Above with shorthand for FRAME definition:
SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
    SUM(Sales) OVER(
		ORDER BY OrderDate
        ROWS 2 PRECEDING  -- CURRENT ROW is implied for "following" part!
	) AS SalesTotalX
FROM Orders;

-- === DEFAULT FRAME ====
-- === Case A) DEFAULT FRAME - When ORDER BY --> IS NOT USED ====
SELECT OrderID, OrderDate, OrderStatus, Sales,
	SUM(Sales) OVER(PARTITION BY OrderStatus) AS SalesTotalX
FROM Orders;
-- Here all values for `SalesTotalX` within a partition are computed
-- using the entire partition.
-- So: Default Frame is: The entire partition.

-- === Case B) DEFAULT FRAME - When ORDER BY --> IS USED ====
SELECT OrderID, OrderDate, OrderStatus, Sales,
	SUM(Sales) OVER(PARTITION BY OrderStatus ORDER BY OrderDate) AS SalesTotalX
FROM Orders;
-- Here, we see the frame used for computation is from the first row
-- within a partion, upto the current row in the partion.
-- So: Default Frame is like: RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.

/* TASK 7: 
   Calculate Total Sales by Order Status for current and next two orders 
*/
SELECT
    OrderID, OrderDate, ProductID,
    OrderStatus, Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
    ) AS Total_Sales
FROM Orders;



/* ==============================================================================
   SQL WINDOW FUNCTIONS | GROUP BY
===============================================================================*/

/* TASK 12: 
   Rank customers by their total sales 
*/
SELECT
    CustomerID,
    SUM(Sales) AS Total_Sales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS Rank_Customers
FROM Orders GROUP BY CustomerID;
