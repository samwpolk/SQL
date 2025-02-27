

-- 1. Display all tracks with media type name
SELECT 
    t.Name AS TrackName, 
    mt.Name AS MediaName, 
    CASE WHEN mt.Name LIKE '%Video%' THEN 'Video' ELSE 'Audio' END AS MediaType,
    CASE 
        WHEN mt.Name LIKE '%AAC%' THEN 'AAC'
        WHEN mt.Name LIKE '%MPEG%' THEN 'MPEG'
        ELSE 'Unknown'
    END AS EncodingFormat
FROM Track t
JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId;

SELECT 
    t.Name AS TrackName, 
    mt.Name AS MediaName, 
    IIF(mt.Name LIKE '%Video%', 'Video', 'Audio') AS MediaType,
    IIF(mt.Name LIKE '%AAC%', 'AAC', IIF(mt.Name LIKE '%MPEG%', 'MPEG', 'Unknown')) AS EncodingFormat
FROM Track t
JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId;

-- 2. Display the total track count for each Media type
SELECT mt.Name AS MediaTypeName, COUNT(*) AS TotalTracks
FROM Track t
JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId
GROUP BY mt.Name;

-- 3. Sum total sales per Sales Support Agent by year
SELECT e.FirstName, e.LastName, YEAR(i.InvoiceDate) AS SaleYear, SUM(i.Total) AS TotalSales
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.FirstName, e.LastName, YEAR(i.InvoiceDate);

-- 4. Highest amount paid by each customer
SELECT c.LastName, c.FirstName, MAX(i.Total) AS MaxInvoice
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.LastName, c.FirstName;

-- 5. Check if postal codes are numeric
SELECT Country, PostalCode, 
       CASE 
           WHEN ISNUMERIC(PostalCode) = 1 THEN 'Yes'
           WHEN PostalCode IS NULL THEN 'Unknown'
           ELSE 'No' 
       END AS NumericPostalCode
FROM Customer
ORDER BY NumericPostalCode, Country;


-- 6. Customers whose total purchases exceed 42 dollars
SELECT c.FirstName, c.LastName, SUM(i.Total) AS TotalSales
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.FirstName, c.LastName
HAVING SUM(i.Total) > 42;


-- 7. Artist with the most tracks
SELECT TOP 1 a.Name AS TopArtist
FROM Artist a
JOIN Album al ON a.ArtistId = al.ArtistId
JOIN Track t ON al.AlbumId = t.AlbumId
GROUP BY a.Name
ORDER BY COUNT(t.TrackId) DESC;


-- 8. Assign customers to groups
SELECT FirstName, LastName, 
       CASE 
           WHEN LastName LIKE '[A-G]%' THEN 'Group1'
           WHEN LastName LIKE '[H-M]%' THEN 'Group2'
           WHEN LastName LIKE '[N-S]%' THEN 'Group3'
           WHEN LastName LIKE '[T-Z]%' THEN 'Group4'
           ELSE NULL
       END AS CustomerGrouping
FROM Customer;

SELECT FirstName, LastName, 
       LEFT(LastName, 1) AS Initial,
       CASE 
           WHEN LEFT(LastName, 1) BETWEEN 'A' AND 'G' THEN 'Group1'
           WHEN LEFT(LastName, 1) BETWEEN 'H' AND 'M' THEN 'Group2'
           WHEN LEFT(LastName, 1) BETWEEN 'N' AND 'S' THEN 'Group3'
           WHEN LEFT(LastName, 1) BETWEEN 'T' AND 'Z' THEN 'Group4'
           ELSE NULL
       END AS CustomerGrouping
FROM Customer;

-- 9. Artist album count
SELECT a.Name AS ArtistName, COUNT(al.AlbumId) AS AlbumCount
FROM Artist a
JOIN Album al ON a.ArtistId = al.ArtistId
GROUP BY a.Name
ORDER BY AlbumCount DESC, ArtistName;

-- 10. Employee departments
SELECT FirstName, LastName, Title,
       CASE 
           WHEN Title LIKE '%Manager%' THEN 'Management'
           WHEN Title LIKE '%Sales%' THEN 'Sales'
           WHEN Title LIKE '%IT%' THEN 'Technology'
           ELSE 'Other'
       END AS Department
FROM Employee
ORDER BY Department;
