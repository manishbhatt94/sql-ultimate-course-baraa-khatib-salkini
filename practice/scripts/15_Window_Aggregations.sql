USE `salesdb`;

SELECT * FROM orders;
SELECT * FROM products;

/* ============================================================
   SQL WINDOW AGGREGATION | COUNT
   ============================================================ */

-- ==== Task A: ====
-- ==== Find the total number of orders ======
SELECT COUNT(*) AS TotalOrders FROM Orders;

-- ==== Task B: ====
-- ==== Find the total number of orders. Additionally provide details such as
-- OrderID and OrderDate for all orders =====
SELECT OrderID, OrderDate,
COUNT(*) OVER() AS TotalOrders
FROM Orders;

-- ==== Task C: ====
-- ==== Find the total number of orders, for each customer ======
SELECT CustomerID, COUNT(*) AS TotalOrdersByCustomer
FROM Orders GROUP BY CustomerID;

-- ==== Find the total number of orders, for each customer. Also provide extra
-- details like OrderID & OrderDate for all orders ======
SELECT OrderID, OrderDate, CustomerID,
	COUNT(*) OVER() AS TotalOrders,
	COUNT(*) OVER(PARTITION BY CustomerID) AS OrdersByCustomer
FROM Orders;

-- ==== Task D: ====
-- ==== Find the total no. of customers; additionally provide all customer
-- details =====
SELECT *, COUNT(*) OVER() AS TotalCustomers FROM Customers;

-- ==== Find the total no. of scores for the customers =====
SELECT *,
	COUNT(*) OVER() AS TotalCustomers,
	COUNT(Score) OVER() AS TotalScores
FROM Customers;


/* TASK 1:
   Find the Total Number of Orders and the Total Number of Orders for Each Customer
*/
SELECT
	OrderID, OrderDate, CustomerID,
	COUNT(*) OVER() AS TotalOrders,
	COUNT(*) OVER(PARTITION BY CustomerID) AS OrdersByCustomers
FROM Orders;


/* TASK 2:
   - Find the Total Number of Customers
   - Find the Total Number of Scores for Customers
   - Find the Total Number of Countries
*/
SELECT
    *,
    COUNT(*) OVER () AS TotalCustomersStar,
    COUNT(1) OVER () AS TotalCustomersOne,
    COUNT(Score) OVER() AS TotalScores,
    COUNT(Country) OVER() AS TotalCountries
FROM Customers;


-- ==== Task E: ====
-- ==== Check whether the table `Orders` contains any duplicate rows =====
SELECT OrderID,
	COUNT(*) OVER(PARTITION BY OrderID) AS CheckPK
	FROM Orders;
-- Expected `CheckPK` to be 1 for all rows, to check Data Quality, by seeing if
-- the Primary Key columns has any duplicate values.

SELECT * FROM Orders_Archive;

-- Do the same for `Orders_Archive` table:
SELECT OrderID,
	COUNT(*) OVER(PARTITION BY OrderID) AS CheckPK
	FROM Orders_Archive;

-- Find the records in `Orders_Archive` table, in which the PK column `OrderId`
-- has duplicate values in the table:
-- (We'll use above result-set as a derived-table subquery)
SELECT * FROM (
	SELECT OrderID,
		COUNT(*) OVER(PARTITION BY OrderID) AS CheckPK
	FROM Orders_Archive
) t WHERE t.CheckPK > 1;


/* ============================================================
   SQL WINDOW AGGREGATION | SUM
   ============================================================ */

/* TASK 4:
   - Find the Total Sales Across All Orders 
   - Find the Total Sales for Each Product
   - Provide additional details like OrderID, OrderDate, Sales, ProductID
*/
SELECT
    OrderID,
    OrderDate,
    Sales,
    ProductID,
    SUM(Sales) OVER () AS TotalSales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS SalesByProduct
FROM Orders;

/* TASK 5:
   Find the Percentage Contribution of Each Order's Sales to the Total Sales
*/
SELECT
    OrderID,
    ProductID,
    Sales,
    SUM(Sales) OVER () AS TotalSales,
    ROUND(CAST(Sales AS FLOAT) / SUM(Sales) OVER () * 100, 2) AS PercentageOfTotal
FROM Orders;


/* ============================================================
   SQL WINDOW AGGREGATION | AVG
   ============================================================ */

/* TASK 6:
   - Find the Average Sales Across All Orders 
   - Find the Average Sales for Each Product
   - Additionally, provide details like OrderID, OrderDate, Sales, ProductID
*/
SELECT
    OrderID,
    OrderDate,
    Sales,
    ProductID,
    AVG(Sales) OVER () AS AvgSales,
    AVG(Sales) OVER (PARTITION BY ProductID) AS AvgSalesByProduct
FROM Orders;


/* TASK 7:
   Find the Average Scores of Customers
   (Note the `Customers` table's `score` column has NULL values)
*/
SELECT
    CustomerID,
    LastName,
    Score,
    COALESCE(Score, 0) AS CustomerScore,
    SUM(score) OVER() AS TotalScore,
    AVG(Score) OVER () AS AvgScore,
    AVG(COALESCE(Score, 0)) OVER () AS AvgScoreWithoutNull
FROM Customers;


/* TASK 8:
   Find all orders where Sales exceed the average Sales across all orders
*/
-- Remember, we can't use the WINDOW functions in WHERE clause. Window function
-- are only allowed in SELECT and ORDER BY clauses.
SELECT *
FROM (
	SELECT
		OrderID,
		ProductID,
		Sales,
		AVG(Sales) OVER () AS Avg_Sales
	FROM Orders
) t WHERE Sales > Avg_Sales;


/* ============================================================
   SQL WINDOW AGGREGATION | MAX / MIN
   ============================================================ */

-- ==== Task E: ====
-- - Find the highest & lowest sales of all orders
-- - Find the highest & lowest sales for each product
-- - Additionally, provide details like OrderID, OrderDate, Sales, ProductID
SELECT OrderID, OrderDate, ProductID, Sales,
	MAX(Sales) OVER(PARTITION BY ProductID) AS HighestSalesByProduct,
	MIN(Sales) OVER(PARTITION BY ProductID) AS LowestSalesByProduct,
	MAX(Sales) OVER() AS HighestSales,
	MIN(Sales) OVER() AS LowestSales
FROM Orders;


/* TASK 11:
   Show the employees who have the highest salaries
*/
SELECT t.* FROM (
	SELECT *, MAX(Salary) OVER() AS HighestSalary
	FROM Employees
) t WHERE t.Salary = t.HighestSalary;

/* TASK 12:
   Find the deviation of each Sale from the minimum and maximum Sales
*/
SELECT
   OrderID,
   OrderDate,
   ProductID,
   Sales,
   MAX(Sales) OVER () AS HighestSales,
   MIN(Sales) OVER () AS LowestSales,
   Sales - MIN(Sales) OVER () AS DeviationFromMin,
   MAX(Sales) OVER () - Sales AS DeviationFromMax
FROM Orders;
