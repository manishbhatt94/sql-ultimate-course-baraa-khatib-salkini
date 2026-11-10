/* ==============================================================================
   SQL Window Value Functions
-------------------------------------------------------------------------------

   Table of Contents:
     1. LEAD
     2. LAG
     3. FIRST_VALUE
     4. LAST_VALUE
=================================================================================
*/


/* ============================================================
   SQL WINDOW VALUE | LEAD, LAG
   ============================================================ */

/* TASK 1:
   Analyze the Month-over-Month Performance by Finding the Percentage Change in Sales
   Between the Current and Previous Months
*/
-- Total sales recorded per month:
SELECT MONTH(OrderDate) AS OrderMonth, SUM(Sales) AS CurrentMonthSales
FROM Orders GROUP BY MONTH(OrderDate);

-- Get previous month's sales, alongside current month's sales value:
SELECT
   MONTH(OrderDate) AS OrderMonth,
   SUM(Sales) AS CurrentMonthSales,
   LAG(SUM(Sales)) OVER(ORDER BY MONTH(OrderDate) ASC) PreviousMonthSales
FROM Orders GROUP BY MONTH(OrderDate);

-- Final query:
SELECT OrderMonth, CurrentMonthSales, PreviousMonthSales,
   ROUND(
      (CurrentMonthSales - PreviousMonthSales) / PreviousMonthSales * 100.0,
      2
   ) AS MoM_Percent
FROM (
   SELECT
      MONTH(OrderDate) AS OrderMonth,
      SUM(Sales) AS CurrentMonthSales,
      LAG(SUM(Sales)) OVER(ORDER BY MONTH(OrderDate) ASC) PreviousMonthSales
   FROM Orders GROUP BY MONTH(OrderDate)
) t;


/* TASK 2:
   Customer Loyalty Analysis - Rank Customers Based on the Average Days Between Their Orders
*/

-- First, for each customer, we compute: CurrentOrderDate, PreviousOrderDate, and difference b/w
-- those dates i.e. DaysSincePrevOrder.
SELECT OrderID, CustomerID, OrderDate AS CurrentOrderDate,
   LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate,
   DATEDIFF(
      OrderDate,
      LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate)
   ) AS DaysSincePrevOrder
FROM Orders;


-- Final query (But has issue of NULL value being top-ranked) - MySQL's ORDER BY
-- doesn't support the NULLS LAST flag.
SELECT
   t.CustomerID,
   AVG(t.DaysSincePrevOrder) AS AvgDaysBetweenOrders,
   RANK() OVER(ORDER BY AVG(t.DaysSincePrevOrder) ASC) AS CustomerRank
FROM (
   SELECT OrderID, CustomerID, OrderDate AS CurrentOrderDate,
      LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate,
      DATEDIFF(
         OrderDate,
         LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate)
      ) AS DaysSincePrevOrder
   FROM Orders
) t GROUP BY t.CustomerID;


SELECT
   t.CustomerID,
   AVG(t.DaysSincePrevOrder) AS AvgDaysBetweenOrders,
   RANK() OVER(
      ORDER BY (AVG(t.DaysSincePrevOrder) IS NULL) ASC, -- Sort key: evaluates to 0/1 - for pushing NULLs to last.
               AVG(t.DaysSincePrevOrder) ASC
   ) AS CustomerRank
FROM (
   SELECT OrderID, CustomerID, OrderDate AS CurrentOrderDate,
      LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate,
      DATEDIFF(
         OrderDate,
         LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate)
      ) AS DaysSincePrevOrder
   FROM Orders
) t GROUP BY t.CustomerID;


/* ============================================================
   SQL WINDOW VALUE | FIRST & LAST VALUE
   ============================================================ */

/* TASK 3:
   Find the Lowest and Highest Sales for Each Product
*/
SELECT ProductID, MIN(Sales) AS LowestSales, MAX(Sales) AS HighestSales
FROM Orders GROUP BY ProductID;


/* TASK 4:
   Find the Lowest and Highest Sales for Each Product,
   and determine the difference between the current Sales and the lowest Sales for each Product.
*/
-- Using MIN, MAX as aggregate window functions:
SELECT
   ProductID, OrderID, Sales,
   MIN(Sales) OVER(PARTITION BY ProductID) AS LowestSales,
   MAX(Sales) OVER(PARTITION BY ProductID) AS HighestSales,
   (Sales - MIN(Sales) OVER(PARTITION BY ProductID)) AS SalesDifference
FROM Orders;

-- Using FIRST_VALUE, LAST_VALUE as value window functions:
SELECT
   ProductID, OrderID, Sales,
   FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales) AS LowestSales,
   LAST_VALUE(Sales) OVER(
      PARTITION BY ProductID
      ORDER BY Sales
      ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
   ) AS HighestSales,
   (Sales -
      FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales)
   ) AS SalesDifference
FROM Orders;

-- Using FIRST_VALUE only (so that we don't have to override the default frame
-- definition with LAST_VALUE to make it work):
SELECT
   ProductID, OrderID, Sales,
   FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales) AS LowestSales,
   FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales DESC) AS HighestSales,
   (Sales -
      FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales)
   ) AS SalesDifference
FROM Orders;
