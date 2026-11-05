USE `salesdb`;

/* ==============================================================================
   SQL Window Ranking Functions
-------------------------------------------------------------------------------
   Table of Contents:
     1. ROW_NUMBER
     2. RANK
     3. DENSE_RANK
     4. NTILE
     5. CUME_DIST
=================================================================================
*/


/* ============================================================
   SQL WINDOW RANKING | ROW_NUMBER, RANK, DENSE_RANK
   ============================================================ */

/* TASK 1:
   Rank Orders Based on Sales from Highest to Lowest
*/
SELECT
    OrderID,
    ProductID,
    Sales,
    ROW_NUMBER() OVER (ORDER BY Sales DESC) AS SalesRank_Row,
    RANK() OVER (ORDER BY Sales DESC) AS SalesRank_Rank,
    DENSE_RANK() OVER (ORDER BY Sales DESC) AS SalesRank_Dense
FROM Orders;


/* TASK 2:
   Use Case | Top-N Analysis: Find the Highest Sale for Each Product
*/
SELECT * FROM (
	SELECT
	    OrderID,
	    ProductID,
	    Sales,
	    ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) AS RankByProduct
	FROM Orders
) t WHERE RankByProduct = 1;


/* TASK 3:
   Use Case | Bottom-N Analysis: Find the Lowest 2 Customers Based on Their Total Sales
*/
SELECT * FROM (
	SELECT
		CustomerID,
		SUM(Sales) AS TotalSales,
		ROW_NUMBER() OVER(ORDER BY SUM(Sales)) AS CustomerRank
	FROM Orders GROUP BY CustomerID
) t WHERE CustomerRank <= 2;

-- This could have also been solved without a window function:
SELECT
	CustomerID,
	SUM(Sales) AS TotalSales
FROM Orders GROUP BY CustomerID
ORDER BY TotalSales ASC LIMIT 2;


/* TASK 4:
   Use Case | Assign Unique IDs to the Rows of the 'Order Archive'
*/
SELECT
    *,
    ROW_NUMBER() OVER(ORDER BY OrderID, OrderDate) AS UniqueID
FROM Orders_Archive;


/* TASK 5:
   Use Case | Identify Duplicates:
   Identify Duplicate Rows in 'Order Archive' and return a clean result without any duplicates
*/
SELECT * FROM (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY OrderID ORDER BY CreationTime DESC) AS rn
    FROM Orders_Archive
) AS UniqueOrdersArchive
WHERE rn = 1;


/* ============================================================
   SQL WINDOW RANKING | NTILE
   ============================================================ */

/* TASK 6:
   Divide Orders into Groups Based on Sales
*/
SELECT
    OrderID,
    ProductID,
    Sales,
    NTILE(1) OVER (ORDER BY Sales) AS OneBucket,
    NTILE(2) OVER (ORDER BY Sales) AS TwoBuckets,
    NTILE(3) OVER (ORDER BY Sales) AS ThreeBuckets,
    NTILE(4) OVER (ORDER BY Sales) AS FourBuckets
FROM Orders;

SELECT
    OrderID,
    ProductID,
    Sales,
    NTILE(1) OVER (ORDER BY Sales) AS OneBucket,
    NTILE(2) OVER (ORDER BY Sales) AS TwoBuckets,
    NTILE(3) OVER (ORDER BY Sales) AS ThreeBuckets,
    NTILE(4) OVER (ORDER BY Sales) AS FourBuckets,
    NTILE(2) OVER (PARTITION BY ProductID ORDER BY Sales) AS TwoBucketByProducts
FROM Orders;

SELECT
    OrderID,
    ProductID,
    Sales,
    NTILE(2) OVER (PARTITION BY ProductID ORDER BY Sales) AS TwoBucketByProducts
FROM Orders;


/* TASK 7:
   Segment all Orders into 3 Categories: High, Medium, and Low Sales.
*/
-- Intermediate result-set with bucket numbers based on `Sales` column values:
SELECT OrderID, Sales,
    NTILE(3) OVER (ORDER BY Sales DESC) AS Buckets
FROM Orders;

-- Finally, using CASE WHEN:
SELECT OrderID, Sales, Buckets,
    CASE
        WHEN Buckets = 1 THEN 'High'
        WHEN Buckets = 2 THEN 'Medium'
        WHEN Buckets = 3 THEN 'Low'
    END AS SalesSegmentations
FROM (
    SELECT OrderID, Sales,
        NTILE(3) OVER (ORDER BY Sales DESC) AS Buckets
    FROM Orders
) AS SalesBuckets;


/* TASK 8:
   Divide Orders into Groups for Processing
*/
SELECT
    *,
    NTILE(5) OVER (ORDER BY OrderID) AS Buckets
FROM Orders;


/* ============================================================
   SQL WINDOW RANKING | CUME_DIST
   ============================================================ */

/* TASK 9:
   Find Products that Fall Within the Highest 40% of the Prices
*/
SELECT ProductID, Product, Category, Price,
    DistRank
FROM (
    SELECT ProductID, Product, Category, Price,
	    CUME_DIST() OVER(ORDER BY Price DESC) AS DistRank
    FROM Products
) t WHERE DistRank <= 0.40;
