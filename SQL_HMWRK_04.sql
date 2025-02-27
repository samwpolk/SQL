-- Question 1
-- Display Artist Name as 'ArtistName' and Album Title as 'AlbumTitle' for artists whose names start with A through D and have an album.


SELECT 
    Artist.Name AS ArtistName,
	Album.Title AS AlbumTitle
FROM Artist
INNER JOIN Album ON Artist.ArtistId = Album.ArtistId
WHERE LEFT(Artist.Name, 1) IN ('A', 'B', 'C', 'D')
ORDER BY Artist.Name, Album.Title;


SELECT 
    ar.Name AS ArtistName,
    al.Title AS AlbumTitle
FROM Artist ar
INNER JOIN Album al ON ar.ArtistId = al.ArtistId
WHERE CHARINDEX(LEFT(ar.Name, 1), 'ABCD') > 0
ORDER BY ar.Name, al.Title;

SELECT 
    ar.Name AS ArtistName,
    al.Title AS AlbumTitle
FROM Artist ar
INNER JOIN Album al ON ar.ArtistId = al.ArtistId
WHERE ar.Name BETWEEN 'A' AND 'E'
ORDER BY ar.Name, al.Title;

-- Question 2
-- Display Artist Name as 'ArtistName' and Album Title as 'AlbumTitle' for all artists whose names start with A through D, even if they don't have an album.
-- Order results by ArtistName and AlbumTitle in ascending order.

SELECT 
    ar.Name AS ArtistName,
    COALESCE(al.Title, 'No Album') AS AlbumTitle
FROM Artist ar
LEFT JOIN Album al ON ar.ArtistId = al.ArtistId
WHERE ar.Name BETWEEN 'A' AND 'E'
ORDER BY ar.Name, al.Title;

SELECT 
    ar.Name AS ArtistName,
    CASE WHEN al.Title IS NULL THEN 'No Album' ELSE al.Title END AS AlbumTitle
FROM Artist ar
LEFT OUTER JOIN Album al ON ar.ArtistId = al.ArtistId
WHERE ar.Name BETWEEN 'A' AND 'E'
ORDER BY ar.Name, al.Title;

-- Question 3
-- Show Artist Name as 'ArtistName' and Track Name as 'TrackName' for tracks with Genre name 'Alternative'.
-- Order by ArtistName and TrackName in ascending order.

SELECT 
    ar.Name AS ArtistName,
    t.Name AS TrackName
FROM Artist ar
JOIN Album al ON ar.ArtistId = al.ArtistId
JOIN Track t ON al.AlbumId = t.AlbumId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE g.Name = 'Alternative'
ORDER BY ar.Name, t.Name;

SELECT 
    ar.Name AS ArtistName,
    t.Name AS TrackName
FROM Artist ar
JOIN Album al ON ar.ArtistId = al.ArtistId
JOIN Track t ON al.AlbumId = t.AlbumId
WHERE t.GenreId = (
    SELECT GenreId 
    FROM Genre 
    WHERE Name = 'Alternative'
)
ORDER BY ar.Name, t.Name;

-- Question 4
-- Create a cartesian product using the first and last names from the Employee table.
-- Display FirstName and LastName, where each first name matches with every last name.

SELECT 
    e1.FirstName,
    e2.LastName
FROM Employee e1
CROSS JOIN Employee e2;

-- Question 5
-- Display Artist Name as 'ArtistName', Album Title as 'AlbumName', Track Name as 'TrackName', and Genre Name as 'GenreName' for tracks on the 'Grunge' playlist.

SELECT 
    ar.Name AS ArtistName,
    al.Title AS AlbumName,
    t.Name AS TrackName,
    g.Name AS GenreName
FROM Artist ar
JOIN Album al ON ar.ArtistId = al.ArtistId
JOIN Track t ON al.AlbumId = t.AlbumId
JOIN Genre g ON t.GenreId = g.GenreId
JOIN PlaylistTrack pt ON t.TrackId = pt.TrackId
JOIN Playlist p ON pt.PlaylistId = p.PlaylistId
WHERE p.Name = 'Grunge';

-- Question 6
-- Display Album Title, Track Name, and Milliseconds as Seconds for tracks from the album 'Let There Be Rock'.

SELECT 
    al.Title,
    t.Name AS TrackName,
    t.Milliseconds / 1000.0 AS Seconds
FROM Album al
JOIN Track t ON al.AlbumId = t.AlbumId
WHERE al.Title = 'Let There Be Rock';


-- Question 7
-- Display Employee First and Last Name, Customer First and Last Name, and Customer Country.
-- Concatenate Employee names as 'CustomerRep' and Customer names as 'CustomerName'.
-- Order by CustomerRep and Customer Country.

SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS CustomerRep,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    c.Country
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
ORDER BY CustomerRep, c.Country;


-- Question 8
-- Display Album Title, Track Name, and InvoiceId for all tracks.
-- Include tracks even if they don't have an associated InvoiceId.
-- Order by Track Name and InvoiceId in descending order.

SELECT 
    al.Title AS AlbumTitle,
    t.Name AS TrackName,
    il.InvoiceId
FROM Track t
LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
ORDER BY t.Name DESC, il.InvoiceId DESC;

-- Question 9
-- Display EmployeeId, LastName, FirstName, ReportsTo, and ManagerName.

SELECT 
    e1.EmployeeId,
    e1.LastName,
    e1.FirstName,
    e1.ReportsTo,
    CASE 
        WHEN e2.EmployeeId IS NULL THEN 'N/A'
        ELSE e2.FirstName + ' ' + e2.LastName 
    END AS ManagerName
FROM Employee e1
LEFT JOIN Employee e2 ON e1.ReportsTo = e2.EmployeeId;

-- Question 10
-- Display Customer LastName, Album Title, Track Name, and Invoice InvoiceDate as 'PurchaseDate' in dd/mm/yyyy format for albums purchased by Julia Barnett.
-- Order by InvoiceDate, Title, and Name.


SELECT 
    c.LastName,
    al.Title AS AlbumTitle,
    t.Name AS TrackName,
    FORMAT(i.InvoiceDate, 'dd/MM/yyyy') AS PurchaseDate
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
WHERE c.FirstName = 'Julia' 
    AND c.LastName = 'Barnett'
ORDER BY i.InvoiceDate, al.Title, t.Name;








