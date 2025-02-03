USE Chinook;

# Revenue Analysis
# Date Range
SELECT Min(InvoiceDate), MAX(InvoiceDate) FROM Invoice;

# Total Revenue
SELECT SUM(Total) AS TotalRevenue FROM Invoice;

# Monthly Revenue Trends (Line Chart)
SELECT DATE_FORMAT(Invoice.InvoiceDate, '%Y-%m') AS Month,
SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS Total_Sales
FROM InvoiceLine
JOIN Invoice ON Invoice.InvoiceId = InvoiceLine.InvoiceId
GROUP BY Month
ORDER BY Month ASC;

# Revenue by Genre Over Time (monthly) - Bar Chart
# Total
SELECT Genre.Name AS Genre, 
SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS TotalSales
FROM InvoiceLine
JOIN Track ON InvoiceLine.TrackId = Track.TrackId
JOIN Genre ON Track.GenreId = Genre.GenreId
GROUP BY Genre.Name
ORDER BY Genre ASC;

# Monthly
SELECT Genre.Name AS Genre, 
DATE_FORMAT(Invoice.InvoiceDate, '%Y-%m') AS Month,
SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS TotalSales
FROM InvoiceLine
JOIN Track ON InvoiceLine.TrackId = Track.TrackId
JOIN Genre ON Track.GenreId = Genre.GenreId
JOIN Invoice ON InvoiceLine.InvoiceId = Invoice.InvoiceId
GROUP BY Genre.Name, Month
ORDER BY Month ASC, Genre ASC;

# Revenue by Media Type - Bar Chart
# Total
SELECT MediaType.Name AS Media_Type,
SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS TotalSales
FROM InvoiceLine
JOIN Track ON InvoiceLine.TrackId = Track.TrackId
JOIN MediaType ON Track.MediaTypeId = MediaType.MediaTypeId
JOIN Genre ON Track.GenreId = Genre.GenreId
GROUP BY Media_Type
ORDER BY Media_Type;

# Monthly
SELECT MediaType.Name AS Media_Type,
DATE_FORMAT(Invoice.InvoiceDate, '%Y-%m') AS Month,
SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS TotalSales
FROM InvoiceLine
JOIN Track ON InvoiceLine.TrackId = Track.TrackId
JOIN MediaType ON Track.MediaTypeId = MediaType.MediaTypeId
JOIN Genre ON Track.GenreId = Genre.GenreId
JOIN Invoice ON InvoiceLine.InvoiceId = Invoice.InvoiceId
GROUP BY Media_Type, Month
ORDER BY Month ASC, Media_Type;

# Media Type Popularity - Pie Chart
SELECT MediaType.Name AS MediaType, 
COUNT(InvoiceLine.TrackId) AS TrackCount
FROM InvoiceLine
JOIN Track ON InvoiceLine.TrackId = Track.TrackId
JOIN MediaType ON Track.MediaTypeId = MediaType.MediaTypeId
GROUP BY MediaType
ORDER BY TrackCount DESC;

# Customer Count by Employee - Table
SELECT Employee.FirstName, Employee.LastName,
COUNT(Customer.CustomerId) AS Customer_Count
FROM Customer
JOIN Employee ON Employee.EmployeeId = Customer.SupportRepId
GROUP BY EmployeeId;

# Genre Popularity by Region - Heatmap
SELECT Genre.Name AS Genre, Customer.Country AS Country,
COUNT(Invoice.InvoiceId) AS NumberofPurchases
FROM Invoice
JOIN Customer ON Customer.CustomerId = Invoice.CustomerId
JOIN InvoiceLine ON InvoiceLine.InvoiceId = Invoice.InvoiceId
JOIN Track ON Track.TrackId = InvoiceLine.TrackId
JOIN Genre ON Genre.GenreId = Track.GenreId
GROUP BY Genre.Name, Customer.Country
ORDER BY Genre.Name, COUNT(Invoice.InvoiceId) DESC;

# Repeat vs. One-Time Customers
SELECT CustomerType, COUNT(CustomerId) AS CustomerCount
FROM (
    SELECT Customer.CustomerId,
           CASE WHEN COUNT(Invoice.InvoiceId) > 1 THEN 'Repeat' ELSE 'One-Time' END AS CustomerType
    FROM Customer
    JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
    GROUP BY Customer.CustomerId
) AS Subquery
GROUP BY CustomerType;

# Revenue Growth Rate Over Time
SELECT 
    CurrentMonth.Month AS Month,
    CurrentMonth.TotalRevenue AS CurrentRevenue,
    COALESCE(
        (CurrentMonth.TotalRevenue - PreviousMonth.TotalRevenue) / PreviousMonth.TotalRevenue * 100, 
        0
    ) AS GrowthRate
FROM (
    -- Current month revenue
    SELECT 
        DATE_FORMAT(Invoice.InvoiceDate, '%Y-%m') AS Month, 
        SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS TotalRevenue
    FROM 
        InvoiceLine
    JOIN 
        Invoice ON InvoiceLine.InvoiceId = Invoice.InvoiceId
    GROUP BY 
        Month
) AS CurrentMonth
LEFT JOIN (
    -- Previous month revenue
    SELECT 
        DATE_FORMAT(Invoice.InvoiceDate, '%Y-%m') AS Month, 
        SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS TotalRevenue
    FROM 
        InvoiceLine
    JOIN 
        Invoice ON InvoiceLine.InvoiceId = Invoice.InvoiceId
    GROUP BY 
        Month
) AS PreviousMonth
ON 
    STR_TO_DATE(CurrentMonth.Month, '%Y-%m') = DATE_ADD(STR_TO_DATE(PreviousMonth.Month, '%Y-%m'), INTERVAL 1 MONTH)
ORDER BY 
    Month ASC;

