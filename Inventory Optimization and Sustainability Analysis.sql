/* Inventory Optimization and Sustainability Analysis 

Skills used Joins, CTEs, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Importing datasets into SSMS

-- Viewing the datasets

select *
from [SQL Inventory Analysis]..BegInvFINAL12312016

select *
from [SQL Inventory Analysis]..EndInvFINAL12312016

select *
from [SQL Inventory Analysis]..InvoicePurchases12312016

select *
from [SQL Inventory Analysis]..PurchasesFINAL12312016

select *
from [SQL Inventory Analysis]..[2017PurchasePricesDec]

select *
from [SQL Inventory Analysis]..SalesFINAL12312016



--I noticed '"' and spaces in the data for BegInvFINAL12312016,EndInvFINAL12312016,InvoicePurchases12312016,PurchasesFINAL12312016,2017PurchasePricesDec
--So I created new tables, trimmed the required spaces and removed '"'

-- For BegInvFINAL12312016 data

IF OBJECT_ID('BegInvFINAL12312016New', 'U') IS NOT NULL
    DROP TABLE BegInvFINAL12312016New;
SELECT   
    REPLACE(["InventoryId"], '"', '') AS ["InventoryId"],["Store"],
    REPLACE(["City"], '"', '') AS ["City"],["Brand"],
    REPLACE(["Description"], '"', '') AS ["Description"],
    REPLACE(["Size"], '"', '') AS ["Size"],["onHand"],["Price"],["startDate"]
	INTO
	BegInvFINAL12312016New
FROM [SQL Inventory Analysis]..BegInvFINAL12312016;


-- For EndInvFINAL12312016 data

IF OBJECT_ID('EndInvFINAL12312016New', 'U') IS NOT NULL
    DROP TABLE EndInvFINAL12312016New;
SELECT   
    REPLACE(["InventoryId"], '"', '') AS ["InventoryId"],["Store"],
    REPLACE(["City"], '"', '') AS ["City"],["Brand"],
    REPLACE(["Description"], '"', '') AS ["Description"],
    REPLACE(["Size"], '"', '') AS ["Size"],["onHand"],["Price"],["endDate"]
	INTO
	EndInvFINAL12312016New
FROM [SQL Inventory Analysis]..EndInvFINAL12312016;


-- For InvoicePurchases12312016 data

IF OBJECT_ID('InvoicePurchases12312016New', 'U') IS NOT NULL
    DROP TABLE InvoicePurchases12312016New;
SELECT   ["VendorNumber"],
    REPLACE(["VendorName"], '"', '') AS ["VendorName"],
    REPLACE(["InvoiceDate"], '"', '') AS ["InvoiceDate"],["PONumber"],
    REPLACE(["PODate"], '"', '') AS ["PODate"],
	REPLACE(["PayDate"], '"', '') AS ["PayDate"],["Quantity"],["Dollars"],["Freight"],
    REPLACE(["Approval"], '"', '') AS ["Approval"]
	INTO
	InvoicePurchases12312016New
FROM [SQL Inventory Analysis]..InvoicePurchases12312016;


-- For PurchasesFINAL12312016 data

IF OBJECT_ID('PurchasesFINAL12312016New', 'U') IS NOT NULL
    DROP TABLE PurchasesFINAL12312016New;
SELECT 
    REPLACE(["InventoryId"], '"', '') AS ["InventoryId"],["Store"],["Brand"],["Description"],
    REPLACE(["Size"], '"', '') AS ["Size"],["VendorNumber"],
    RTRIM(REPLACE(["VendorName"], '"', '')) AS ["VendorName"],["PONumber"],
	REPLACE(["PODate"], '"', '') AS ["PODate"],
    REPLACE(["ReceivingDate"], '"', '') AS ["ReceivingDate"],
	REPLACE(["InvoiceDate"], '"', '') AS ["InvoiceDate"],
	REPLACE(["PayDate"], '"', '') AS ["PayDate"],["PurchasePrice"],["Quantity"],["Dollars"],["Classification"]
	INTO
	PurchasesFINAL12312016New
FROM [SQL Inventory Analysis]..PurchasesFINAL12312016;


-- For 2017PurchasePricesDec data

IF OBJECT_ID('[2017PurchasePricesDecNew]', 'U') IS NOT NULL
    DROP TABLE [2017PurchasePricesDecNew];
SELECT ["Brand"],
    REPLACE(["Description"], '"', '') AS ["Description"],["Price"],
    REPLACE(["Size"], '"', '') AS ["Size"],
	REPLACE(["Volume"], '"', '') AS ["Volume"],["Classification"],["PurchasePrice"],["VendorNumber"],
    RTRIM(REPLACE(["VendorName"], '"', '')) AS ["VendorName"]
	INTO
	[2017PurchasePricesDecNew]
FROM [SQL Inventory Analysis]..[2017PurchasePricesDec];



-- Checking for missing values

select *
from BegInvFINAL12312016New
where ["Brand"] is null
--no missing values


select *
from InvoicePurchases12312016New
where ["VendorNumber"] is null
--no missing values


select *
from EndInvFINAL12312016New
where ["Brand"] is null
--no missing values


select *
from PurchasesFINAL12312016New
where ["Brand"] is null
--no missing values


select *
from [2017PurchasePricesDecNew]
where ["Brand"] is null
--no missing values


select *
from [SQL Inventory Analysis]..SalesFINAL12312016
where Brand is null
--no missing values


-- Counting distinct items

select COUNT(distinct(["Brand"]))
from BegInvFINAL12312016New
--8094


select COUNT(distinct(["VendorNumber"]))
from InvoicePurchases12312016New
--126


select COUNT(distinct(["Brand"]))
from EndInvFINAL12312016New
--9653


select COUNT(distinct(["Brand"]))
from PurchasesFINAL12312016New
--10664


select COUNT(distinct(["Brand"]))
from [2017PurchasePricesDecNew]
--12261


select COUNT(distinct(Brand))
from [SQL Inventory Analysis]..SalesFINAL12312016
--7658

--I observed that the brands purchased increased from 10664 in 2016 to 12261 in 2017
--Only 7658 brands were sold in 2016
--We held more inventory at the end of the year 2016 when compared to the beginning of the year


-- INVENTORY ANALYSIS
-- Checking for the sum of each top 6 product in our inventory at the beginning of the year

select top 6 ["Brand"],["Description"], sum(cast(["onHand"] as int)) as sum_of_beg_inventory
from BegInvFINAL12312016New
group by ["Brand"],["Description"]
order by sum_of_beg_inventory desc


-- Checking for the sum of each last 6 product in our inventory at the beginning of the year

select top 6 ["Brand"],["Description"], sum(cast(["onHand"] as int)) as sum_of_beg_inventory
from BegInvFINAL12312016New
group by ["Brand"],["Description"]
order by sum_of_beg_inventory


-- Checking for the sum of each top 6 product in our inventory at the end of the year

select top 6 ["Brand"],["Description"], sum(cast(["onHand"] as int)) as sum_of_end_inventory
from EndInvFINAL12312016New
group by ["Brand"],["Description"]
order by sum_of_end_inventory desc


-- Checking for the sum of each last 6 product in our inventory at the end of the year

select top 6 ["Brand"],["Description"], sum(cast(["onHand"] as int)) as sum_of_end_inventory
from EndInvFINAL12312016New
group by ["Brand"],["Description"]
order by sum_of_end_inventory


-- Checking for the number of inventory that is not available in the beginning of year

select ["onHand"], count(["onHand"]) as beg_inv_not_available
from BegInvFINAL12312016New
where ["onHand"] = 0
group by ["onHand"]
-- 6044


-- Checking for the number of inventory that is not available at the end of year

select ["onHand"], count(["onHand"]) as end_inv_not_available
from EndInvFINAL12312016New
where ["onHand"] = 0
group by ["onHand"]
--7230


-- PURCHASING ANALYSIS
-- Top 10 vendors by purchase volume

select top 10 ["VendorNumber"],["VendorName"],["Description"],["Brand"],sum(cast(["Quantity"] as float)) as total_qtty
from PurchasesFINAL12312016New
group by ["VendorNumber"],["VendorName"],["Description"],["Brand"]
order by total_qtty desc 


-- Top 10 vendors by purchase price

select top 10 ["VendorNumber"],["VendorName"], ["Description"],["Brand"], sum(try_cast(["PurchasePrice"] as float)) as total_purchase_price
from PurchasesFINAL12312016New
group by ["VendorNumber"],["VendorName"],["Description"],["Brand"]
order by total_purchase_price desc 


-- Time/Average time in days it took for the vendors to supply (Lead Time)

WITH DateDifferences AS (
SELECT DATEDIFF(DAY,
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["PODate"], 112), '-', '') AS DATE),
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["ReceivingDate"], 112), '-', '') AS DATE)
        ) AS Lead_Time_Days
FROM PurchasesFINAL12312016New
)
SELECT Round(AVG(CAST(Lead_Time_Days AS decimal)),0) AS Average_Lead_Time_Days
FROM DateDifferences
WHERE Lead_Time_Days >= 0;


-- Checking for frequency of lead time by vendors

WITH DateDifferences AS (
SELECT DATEDIFF(DAY,
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["PODate"], 112), '-', '') AS DATE),
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["ReceivingDate"], 112), '-', '') AS DATE)
        ) AS Lead_Time_Days
FROM PurchasesFINAL12312016New
)
SELECT Lead_Time_Days, COUNT(*) AS Frequency
FROM DateDifferences
WHERE Lead_Time_Days >= 0
GROUP BY Lead_Time_Days
ORDER BY Lead_Time_Days;

-- Time in days it took for payment to be made to vendors

WITH DateDifferences AS (
SELECT ["Brand"],["Description"], DATEDIFF(DAY,
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["InvoiceDate"], 112), '-', '') AS DATE),
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["PayDate"], 112), '-', '') AS DATE)
        ) AS Payment_Duration_in_Days_Cast
FROM PurchasesFINAL12312016New
)
SELECT AVG(CAST(Payment_Duration_in_Days_Cast AS BIGINT)) AS Average_Payment_Duration_in_Days
FROM DateDifferences
WHERE Payment_Duration_in_Days_Cast >= 0


-- Checking for the frequency of payment duration to vendors

WITH DateDifferences AS (
SELECT DATEDIFF(DAY,
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["InvoiceDate"], 112), '-', '') AS DATE),
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["PayDate"], 112), '-', '') AS DATE)
        ) AS Payment_Duration_in_Days
FROM PurchasesFINAL12312016New
)
SELECT Payment_Duration_in_Days, COUNT(*) AS Frequency
FROM DateDifferences
WHERE Payment_Duration_in_Days >= 0
GROUP BY Payment_Duration_in_Days
ORDER BY Payment_Duration_in_Days;


-- SALES ANALYSIS
-- Checking for the best selling product

select top 10 brand,description,  sum(cast(salesquantity as int)) as sum_of_salesqtty
from [SQL Inventory Analysis]..SalesFINAL12312016
group by Brand,Description
order by sum_of_salesqtty desc


-- Checking for the slow selling product

select top 10 brand,description,  sum(cast(salesquantity as int)) as sum_of_salesqtty
from [SQL Inventory Analysis]..SalesFINAL12312016
group by Brand,Description
order by sum_of_salesqtty


-- Sum_of_salesqtty and salesdate

select salesdate,  sum(cast(salesquantity as int)) as sum_of_salesqtty
from [SQL Inventory Analysis]..SalesFINAL12312016
group by salesdate
order by sum_of_salesqtty desc


-- Salesprice and salesdate

select salesdate, avg(cast(salesprice as float)) as avg_salesprice
from [SQL Inventory Analysis]..SalesFINAL12312016
group by salesdate
order by avg_salesprice desc


-- Checking for top 10 products with highest sales

select top 10 brand,description,  sum(cast(SalesDollars as float)) as sum_of_sales
from [SQL Inventory Analysis]..SalesFINAL12312016
group by Brand,Description
order by sum_of_sales desc
--plot clustered column chart of best selling product and product with highest sales


-- Checking for the sales per day

DECLARE @DateDifference INT;
SELECT @DateDifference = DATEDIFF(
        DAY,
        MIN(CONVERT(DATE, salesdate)),
        MAX(CONVERT(DATE, salesdate))
    )
FROM [SQL Inventory Analysis]..SalesFINAL12312016;
IF @DateDifference <> 0
BEGIN
SELECT brand,description,
SUM(CAST(SalesQuantity AS INT)) / CAST(@DateDifference AS DECIMAL) AS SalesPerDay
FROM [SQL Inventory Analysis]..SalesFINAL12312016
GROUP by brand, description
ORDER by SalesPerDay desc
END
ELSE
BEGIN
    PRINT 'DateDifference is zero. Cannot divide by zero.';
END


-- Creating table from sales per day query

DECLARE @DateDifference INT;
SELECT @DateDifference = DATEDIFF(
        DAY,
        MIN(CONVERT(DATE, salesdate)),
        MAX(CONVERT(DATE, salesdate))
    )
FROM [SQL Inventory Analysis]..SalesFINAL12312016;
IF @DateDifference <> 0
BEGIN
IF OBJECT_ID('SalesPerDay_Table', 'U') IS NOT NULL
BEGIN
DROP TABLE SalesPerDay_Table;
    END
    SELECT brand,description,SUM(CAST(SalesQuantity AS INT)) / CAST(@DateDifference AS DECIMAL) AS SalesPerDay
    INTO 
        SalesPerDay_Table  
    FROM [SQL Inventory Analysis]..SalesFINAL12312016
    GROUP BY brand, description
    ORDER BY SalesPerDay DESC;
END
ELSE
BEGIN
    PRINT 'DateDifference is zero. Cannot divide by zero.';
END

-- SalesPerDay_Table
select *
from SalesPerDay_Table
group by brand, description,SalesPerDay
order by SalesPerDay desc


-- Checking Maximum sales for each product

select brand,description,Max(cast(SalesQuantity as int)) as Maximum_Sales
 FROM [SQL Inventory Analysis]..SalesFINAL12312016
 group by brand,description


-- Bringing forward lead time query and creating a Lead_Time_Table

 IF OBJECT_ID('Lead_Time_Table', 'U') IS NOT NULL
BEGIN
    DROP TABLE Lead_Time_Table;
END
 SELECT ["Brand"],["Description"],
        DATEDIFF(DAY,
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["PODate"], 112), '-', '') AS DATE),
            TRY_CAST(REPLACE(CONVERT(VARCHAR(12), ["ReceivingDate"], 112), '-', '') AS DATE)
        ) AS Lead_Time_Days
		INTO Lead_Time_Table
FROM PurchasesFINAL12312016New
	
	
-- Checking for average lead time

IF OBJECT_ID('Lead_Time_Table2', 'U') IS NOT NULL
BEGIN
    DROP TABLE Lead_Time_Table2;
END
select ["Brand"], ["Description"],AVG(CAST(Lead_Time_Days AS DECIMAL)) AS Average_Lead_Time_Days
into Lead_Time_Table2
FROM Lead_Time_Table
WHERE Lead_Time_Days >= 0
group by ["Brand"], ["Description"]

select *
from Lead_Time_Table2


-- Joining the sales per day table and lead_time_table2 and calculating the optimal stock
-- Joining also the maximum sales query and calculating the safety stock

select S.brand, S.description,S.salesperday,L.Average_Lead_Time_Days,
S.salesperday * L.Average_Lead_Time_Days AS Optimal_Stock, MaxSalesTable.Maximum_Sales,
MaxSalesTable.Maximum_Sales - S.salesperday as Safety_Stock
      from SalesPerDay_Table as S
left join Lead_Time_Table2 as L
      on S.Brand=L.["Brand"]
and S.Description=L.["Description"]
--left join Max_SalesPerDay_Table as M
--      on S.Brand = M.brand
-- and S.Description = M.description
LEFT JOIN
    (SELECT brand,description,MAX(CAST(SalesQuantity AS INT)) AS Maximum_Sales
        FROM [SQL Inventory Analysis]..SalesFINAL12312016
        GROUP BY brand, description
    ) AS MaxSalesTable 
ON S.Brand = MaxSalesTable.brand AND S.Description = MaxSalesTable.description
where L.Average_Lead_Time_Days is not null 
order by S.SalesPerDay desc


--I noticed that safety stock has negative values for 547 rows, ie the salesperday is greater than the maximum_sales per day which shouldn't be
--this could be as a result of data entry error,outliers or computational error so I need to find a way to deal with it. 
--so we will update for this case for the salesperday values to be equal to the maximum_sales values
--first, let's create a table from above query

IF OBJECT_ID('Stock_Table', 'U') IS NOT NULL
    DROP TABLE Stock_Table;
SELECT 
    S.brand,
    S.description,
    S.salesperday,
    L.Average_Lead_Time_Days,
    S.salesperday * L.Average_Lead_Time_Days AS Optimal_Stock,
    MaxSalesTable.Maximum_Sales,
    MaxSalesTable.Maximum_Sales - S.salesperday as Safety_Stock
INTO Stock_Table
FROM SalesPerDay_Table as S
LEFT JOIN Lead_Time_Table2 as L ON S.Brand = L.["Brand"] AND S.Description = L.["Description"]
--LEFT JOIN Max_SalesPerDay_Table as M ON S.Brand = M.brand AND S.Description = M.description
LEFT JOIN
    ( SELECT brand,
            description, MAX(CAST(SalesQuantity AS INT)) AS Maximum_Sales
        FROM [SQL Inventory Analysis]..SalesFINAL12312016
        GROUP BY brand, description
    ) AS MaxSalesTable 
ON S.Brand = MaxSalesTable.brand AND S.Description = MaxSalesTable.description
WHERE L.Average_Lead_Time_Days IS NOT NULL 
ORDER BY  S.SalesPerDay DESC;

select *
from Stock_Table
where Safety_Stock < 0


--We will create a new table called Stock_Table2
--We will now replace the salesperday values < 0 with its maximum_sales values, then subtract to get the modified safety stock
--We will also calculate the recommended stock

IF OBJECT_ID('Stock_Table', 'U') IS NOT NULL
    DROP TABLE Stock_Table2;
SELECT brand,description,average_lead_time_days,optimal_stock,maximum_sales,Salesperday_Modified,
    maximum_sales - Salesperday_Modified AS Safetystock_Modified,
	optimal_stock + (maximum_sales - Salesperday_Modified) AS Recommended_Stock
	into Stock_Table2
From (
SELECT brand,description,salesperday,average_lead_time_days,optimal_stock,maximum_sales,safety_stock,
    CASE
        WHEN SalesPerDay > Maximum_Sales THEN Maximum_Sales
        ELSE SalesPerDay
    END AS Salesperday_Modified
FROM Stock_Table )
as subquery
order by Recommended_Stock desc

select *
from Stock_Table2

-- Checking for the current stock level

select ["Brand"],["Description"], sum(cast(["onHand"] as int)) as sum_of_end_inventory
from EndInvFINAL12312016New
group by ["Brand"],["Description"]
order by sum_of_end_inventory desc

--We will merge stock_table2 to above current stock level query and create table, Stock_Table3
--after merging i discovered there were nulls in the current inventory, that is, the nulls were as a result of the non-matching columns from the stock_table2
--so i had to replace the nulls with zero
--i calculated the order quantity and replaced values less than 0 with 0 for cases where the current inventory is higher than the recommended stock

IF OBJECT_ID('Stock_Table', 'U') IS NOT NULL
    DROP TABLE Stock_Table3;
select s.Brand,s.description,s.average_lead_time_days,s.optimal_stock,s.maximum_sales,s.salesperday_modified,s.safetystock_modified,s.recommended_stock,
COALESCE(Current_Stock_Table.Current_Inventory, 0) AS Current_Inventory,
CASE
        WHEN s.recommended_stock - COALESCE(Current_Stock_Table.Current_Inventory, 0) < 0
        THEN 0
        ELSE s.recommended_stock - COALESCE(Current_Stock_Table.Current_Inventory, 0)
    END AS Order_Quantity
into Stock_Table3
from Stock_Table2 AS s
left join
(
select ["Brand"],["Description"], COALESCE(SUM(CAST(["onHand"] AS INT)), 0) AS Current_Inventory
from EndInvFINAL12312016New
group by ["Brand"],["Description"]
)
as Current_Stock_Table
on S.Brand = Current_Stock_Table.["Brand"] AND S.Description = Current_Stock_Table.["Description"]
order by Current_Inventory

select *
from Stock_Table3
order by Salesperday_Modified


--Looking at the stock_table3, the stock data are expressed in decimal but we need rounded up values to show inventory
--So at this point that we are done with calculation, we will have to round up all data in the stock_table3 to the nearest whole number

SELECT
    Brand,
    description,
    CEILING(average_lead_time_days) AS average_lead_time_days_rounded,
    CEILING(optimal_stock) AS optimal_stock_rounded,
    maximum_sales,
    CEILING(salesperday_modified) AS salesperday_modified_rounded,
    CEILING(safetystock_modified) AS safetystock_modified_rounded,
    CEILING(recommended_stock) AS recommended_stock_rounded,
    Current_Inventory,
    CEILING(Order_Quantity) AS Order_Quantity_rounded
FROM
    Stock_Table3

-- Creating view to store data for visualization
CREATE VIEW StockView AS
SELECT
    Brand,
    description,
    CEILING(average_lead_time_days) AS average_lead_time_days_rounded,
    CEILING(optimal_stock) AS optimal_stock_rounded,
    maximum_sales,
    CEILING(salesperday_modified) AS salesperday_modified_rounded,
    CEILING(safetystock_modified) AS safetystock_modified_rounded,
    CEILING(recommended_stock) AS recommended_stock_rounded,
    Current_Inventory,
    CEILING(Order_Quantity) AS Order_Quantity_rounded
FROM
    Stock_Table3
	







