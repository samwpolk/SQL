/*

                 Introduction to SQL Programming Project
You have been hired by the ChinookCorp Company to provide reports based off of the
data located in their Chinook database. Using the report specifications below develop
queries that produce the proper result set. The example provided with each question is
part of the actual answer. Make sure your answers match what’s in the example. Submit
your answers in the same format you submit your homework. These questions are
designed to be challenging. I encourage you to use the Discussion Boards to help each
other out. 

*/


-- =========================================================
--  Finding the Top 10 Artists by Sales in SQL Server
-- =========================================================

-- 1. Provide a report displaying the 10 artists with the most sales from July 2011 through June 2012.
-- Do not include any video tracks in the sales. Display the Artist's name and the total sales for the
-- year. Include ties for 10th if there are any.

-- === Entity-Relationship Diagram (Text-Based ERD) ===
-- Artist (ArtistId PK, Name)
--     |
--     |--< Album (AlbumId PK, Title, ArtistId FK ? Artist)
--            |
--            |--< Track (TrackId PK, Name, AlbumId FK ? Album, MediaTypeId FK ? MediaType)
--                   |
--                   |--< InvoiceLine (InvoiceLineId PK, InvoiceId FK ? Invoice, TrackId FK ? Track, UnitPrice, Quantity)
--                           |
--                           |--< Invoice (InvoiceId PK, CustomerId FK ? Customer, InvoiceDate)

-- === Explanation of Joins ===
-- 1. Join Artist ? Album ? Track to link each artist with their albums and tracks.
-- 2. Join Track ? InvoiceLine ? Invoice to connect sales records to the tracks.
-- 3. Join Track ? MediaType to filter out video tracks.

-- =========================================================
--  Step 1: Calculate Total Sales Per Artist
-- =========================================================
WITH SalesByArtist AS (
    SELECT 
        ar.Name AS Artist,
		COUNT(il.Quantity) AS Number,
		MAX(il.UnitPrice * il.Quantity) As Highest,
        SUM(il.UnitPrice * il.Quantity) AS TotalSales
    FROM Artist ar
    JOIN Album al ON ar.ArtistId = al.ArtistId  -- Artist ? Album
    JOIN Track t ON al.AlbumId = t.AlbumId  -- Album ? Track
    JOIN InvoiceLine il ON t.TrackId = il.TrackId  -- Track ? InvoiceLine (Sales Data)
    JOIN Invoice i ON il.InvoiceId = i.InvoiceId  -- InvoiceLine ? Invoice (Date Filtering)
    JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId  -- Track ? MediaType (Filtering Out Videos)
    WHERE i.InvoiceDate BETWEEN '2011-07-01' AND '2012-06-30'  -- Filter sales between July 2011 - June 2012
      AND mt.Name NOT LIKE '%Video%'  -- Exclude video tracks
    GROUP BY ar.ArtistId, ar.Name
)

-- =========================================================
--  Step 2: Rank Artists Based on Sales
-- =========================================================
, RankedArtists AS (
    SELECT 
        Artist,
        TotalSales,
		Highest,
		Number,
        DENSE_RANK() OVER (ORDER BY TotalSales DESC) AS RankPosition  -- Assign Rank Using DENSE_RANK()
    FROM SalesByArtist
)

-- =========================================================
--  Step 3: Retrieve the Top 10 Artists (Including Ties)
-- =========================================================
SELECT RankPosition, Artist,TotalSales
FROM RankedArtists
WHERE RankPosition <= 10  -- Ensure only the top 10 artists (with ties) are included
ORDER BY RankPosition;  -- Order the results by rank

-- =========================================================
--  Explanation of Ranking Methods:
-- =========================================================
-- 1. Using DENSE_RANK() ensures no skipped ranks (e.g., Rank 1, 2, 2, 3, 3, 4 instead of Rank 1, 2, 2, 4, 4, 5).
-- 2. Ensures that all artists with the same sales as the 10th ranked artist are included.
-- 3. This approach prevents missing artists when multiple artists have identical sales.



-- =========================================================
--  Report: Total Sales for Sales Support Agents by Year and Quarter
-- =========================================================


-- 2. Provide a report displaying the total sales for all Sales Support Agents grouped by year and
-- quarter. Include data from January 2010 through June 2012. Each year has 4 Sales Quarters
-- divided as follows:
-- Jan-Mar: Quarter 1
-- Apr-Jun: Quarter 2
-- Jul-Sep: Quarter 3
-- Oct-Dec: Quarter 4
-- The Sales Quarter column should display its values as First, Second, Third, Fourth. The data
-- needs to be ordered by the employee name, the calendar year, and the sales quarter. The sales
-- quarter order should be numeric and not alphabetical (e.g. “Third” comes before “Fourth”).



-- === Entity-Relationship Diagram (Text-Based ERD) ===
-- Employee (EmployeeId PK, FirstName, LastName, Title)
--     |
--     |--< Customer (CustomerId PK, SupportRepId FK ? Employee)
--            |
--            |--< Invoice (InvoiceId PK, CustomerId FK ? Customer, InvoiceDate, Total)

-- === Explanation of Joins ===
-- 1. Join Employee ? Customer to link support agents to the customers they assist.
-- 2. Join Customer ? Invoice to associate customersth their purchases.
-- 3. Filtering Criteria:
--    - Only includes employees with the title 'Sales Support Agent'.
--    - Filters invoices between '2010-01-01' and '2012-06-30'.

-- =========================================================
--  Step 1: Aggregate Sales Data Per Employee, Per Year, Per Quarter
-- =========================================================
WITH SalesData AS (
    SELECT 
        -- Combine first and last names for readability
        CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,

        -- Extract the year from the invoice date
        YEAR(i.InvoiceDate) AS SalesYear,

        -- Extract the quarter number (1-4) from the invoice date
        DATEPART(QUARTER, i.InvoiceDate) AS SalesQuarterNumber,

        -- Aggregate total sales for each employee per year and quarter
        SUM(i.Total) AS TotalSales,
		-- Number of Sales
		COUNT(i.Total) AS NumberOfSales,
		--
		MAX(i.Total) AS HighestSale
    FROM Employee e
    -- Join Employee with Customer using EmployeeId ? SupportRepId
    JOIN Customer c ON e.EmployeeId = c.SupportRepId
    -- Join Customer with Invoice using CustomerId ? CustomerId
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    WHERE 
        -- Filter only employees with the title 'Sales Support Agent'
        e.Title = 'Sales Support Agent' 

        -- Consider only invoices between January 1, 2010, and June 30, 2012
        AND i.InvoiceDate BETWEEN '2010-01-01' AND '2012-06-30'
    GROUP BY 
        -- Grouping by Employee Name, Sales Year, and Sales Quarter
        e.FirstName, e.LastName,
        YEAR(i.InvoiceDate),
        DATEPART(QUARTER, i.InvoiceDate)
)

-- =========================================================
--  Step 2: Convert Quarter Numbers into Readable Labels
-- =========================================================
, FormattedSales AS (
    SELECT 
        EmployeeName,
        SalesYear, 

        -- Convert quarter numbers into human-readable text labels
        CASE 
            WHEN SalesQuarterNumber = 1 THEN 'First'
            WHEN SalesQuarterNumber = 2 THEN 'Second'
            WHEN SalesQuarterNumber = 3 THEN 'Third'
            WHEN SalesQuarterNumber = 4 THEN 'Fourth'
        END AS SalesQuarter,

        -- Retain the aggregated sales data
		NumberOfSales,
		HighestSale,
        TotalSales,

        -- Keep quarter number to ensure correct sorting order
        SalesQuarterNumber
    FROM SalesData
)

-- =========================================================
--  Step 3: Retrieve Final Results, Ordered by Name, Year, and Quarter
-- =========================================================
SELECT 
    EmployeeName,  -- Full name of the sales agent
    SalesYear,     -- Year of sales
    SalesQuarter,  -- Quarter of sales (First, Second, Third, Fourth)
	HighestSale, --
	NumberOfSales, --
    TotalSales     -- Total sales amount per quarter
FROM FormattedSales
ORDER BY 
    -- Sorting results by Employee Name, then by Year, then by Quarter (numerically)
    EmployeeName, SalesYear, SalesQuarterNumber;

-- =========================================================
--  Explanation of Sorting:
-- =========================================================
-- 1. Sorting by Employee Name ensures results are grouped by salesperson.
-- 2. Sorting by Sales Year keeps the report structured chronologically.
-- 3. Sorting by SalesQuarterNumber ensures the quarters appear in numeric order.
--    (E.g., "Third" comes before "Fourth" instead of being sorted alphabetically.)

-- =========================================================
--  Identifying and Managing Duplicate Playlists
-- =========================================================

-- 3. The Sales Reps have discovered duplicate Playlists in the database. Some but not all of the
-- Playlists have Tracks associated with them. The duplicates have the same Playlist name, but
-- have a higher Playlist ID. Write a report that displays the duplicate Playlist IDs and Playlist
-- Names, as well as any associated Track IDs if they exist. Your result set will be marked for
--  deletion so it must be accurate.


-- === Example Output ===
-- | Playlist Name | Duplicate Playlist ID | Track ID |
-- |---------------|-----------------------|----------|
-- | Music         | 8                     | 3503     |
-- | TV Shows      | 10                    | 2819     |

-- === Entity-Relationship Diagram (Text-Based ERD) ===
-- Playlist (PlaylistId PK, Name)
--     |
--     |--< PlaylistTrack (PlaylistId FK ? Playlist, TrackId FK ? Track)
--             |
--             |--< Track (TrackId PK, Name)

-- === Explanation of Joins ===
-- 1. Self-Join on Playlist Table:
--    - To identify duplicate playlists, we perform a self-join on the Playlist table,
--      matching playlists with the same Name but ensuring the PlaylistId of the first
--      instance (p1) is less than that of the second (p2). This helps in identifying
--      duplicates with higher PlaylistId values.
-- 2. Left Join with PlaylistTrack:
--    - To retrieve associated tracks, we perform a left join between the duplicate
--      playlists (p2) and the PlaylistTrack table. This ensures that we capture all
--      tracks associated with the duplicate playlists, if they exist.

-- =========================================================
--  SQL Query Implementation
-- =========================================================

-- Step 1: Identify Duplicate Playlists
WITH DuplicatePlaylists AS (
    SELECT
        p1.PlaylistId AS OriginalPlaylistId,
        p2.PlaylistId AS DuplicatePlaylistId,
        p2.Name AS PlaylistName
    FROM
        Playlist p1
    JOIN
        Playlist p2 ON p1.Name = p2.Name AND p1.PlaylistId < p2.PlaylistId
)

-- Step 2: Retrieve Associated Track IDs
SELECT
    dp.PlaylistName,
    dp.DuplicatePlaylistId,
    pt.TrackId
FROM
    DuplicatePlaylists dp
LEFT JOIN
    PlaylistTrack pt ON dp.DuplicatePlaylistId = pt.PlaylistId
ORDER BY
    dp.PlaylistName,
    dp.DuplicatePlaylistId,
    pt.TrackId;

-- === Explanation ===
-- - The Common Table Expression (CTE) 'DuplicatePlaylists' identifies pairs of playlists
--   with the same name, where the second playlist (p2) has a higher PlaylistId than the first (p1).
-- - The final SELECT statement retrieves the playlist name, duplicate PlaylistId, and any
--   associated TrackId by performing a left join with the PlaylistTrack table.
-- - Results are ordered by PlaylistName, DuplicatePlaylistId, and TrackId for clarity.


-- =========================================================
--  Artist Popularity by Country Report
-- =========================================================

-- 4. Management would like to view Artist popularity by Country. Provide a report that displays the
-- Customer country and the Artist name. Determine the total number of tracks sold by an artist
-- to each country, and the total unique tracks by artist sold to each country. Include a column
-- that shows the difference between the track count and the unique track count. Include the total
-- revenue which will be the cost of the track multiplied by the number of tracks purchased.
-- Include a column that shows whether the tracks are audio or video (Hint: Videos have a
-- MediaTypeId =3). The range of data will be between July 2009 and June 2013. Order the results
-- by Country, Track Count and Artist Name.




-- === Entity-Relationship Diagram (Text-Based ERD) ===
-- Customer (CustomerId PK, Country)
--     |
--     |--< Invoice (InvoiceId PK, CustomerId FK ? Customer, InvoiceDate)
--            |
--            |--< InvoiceLine (InvoiceLineId PK, InvoiceId FK ? Invoice, TrackId FK ? Track, UnitPrice, Quantity)
--                   |
--                   |--< Track (TrackId PK, Name, AlbumId FK ? Album, MediaTypeId FK ? MediaType)
--                          |
--                          |--< Album (AlbumId PK, ArtistId FK ? Artist)
--                                 |
--                                 |--< Artist (ArtistId PK, Name)
--                          |
--                          |--< MediaType (MediaTypeId PK, Name)

-- === Explanation of Joins ===
-- 1. Customer ? Invoice:
--    - Links each customer to their invoices to identify purchases made by customers in different countries.
-- 2. Invoice ? InvoiceLine:
--    - Connects invoices to their respective line items to access details about each purchased track.
-- 3. InvoiceLine ? Track:
--    - Associates each line item with its corresponding track to retrieve track information.
-- 4. Track ? Album ? Artist:
--    - Links tracks to their albums and respective artists to obtain artist information.
-- 5. Track ? MediaType:
--    - Associates tracks with their media types to determine whether they are audio or video.

-- =========================================================
--  SQL Query Implementation
-- =========================================================

WITH ArtistSalesByCountry AS (
    SELECT
        c.Country,
        ar.Name AS ArtistName,
        COUNT(il.TrackId) AS TotalTracksSold,
        COUNT(DISTINCT il.TrackId) AS UniqueTracksSold,
        SUM(il.UnitPrice * il.Quantity) AS TotalRevenue,
        mt.Name AS MediaTypeName
    FROM
        Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Album al ON t.AlbumId = al.AlbumId
    JOIN Artist ar ON al.ArtistId = ar.ArtistId
    JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId
    WHERE
        i.InvoiceDate BETWEEN '2009-07-01' AND '2013-06-30'
    GROUP BY
        c.Country,
        ar.Name,
        mt.Name
)

SELECT
    Country,
    ArtistName,
    TotalTracksSold,
    UniqueTracksSold,
    (TotalTracksSold - UniqueTracksSold) AS Difference,
    TotalRevenue,
    CASE
        WHEN MediaTypeName = 'Video' THEN 'Video'
        ELSE 'Audio'
    END AS MediaType
FROM
    ArtistSalesByCountry
ORDER BY
    Country,
    TotalTracksSold DESC,
    ArtistName;

-- === Explanation ===
-- 1. The CTE 'ArtistSalesByCountry' aggregates sales data per artist for each country, including:
--    - Total number of tracks sold (TotalTracksSold)
--    - Total number of unique tracks sold (UniqueTracksSold)
--    - Total revenue generated from sales (TotalRevenue)
--    - Media type of the tracks (MediaTypeName)
-- 2. The main SELECT statement computes the difference between total tracks sold and unique tracks sold.
-- 3. It classifies the media type as 'Audio' or 'Video' based on the MediaTypeName.
-- 4. Results are ordered by Country, TotalTracksSold in descending order, and ArtistName.

-- === Considerations ===
-- - Ensure accurate date filtering to include sales between July 2009 and June 2013.
-- - The MediaType table should have appropriate entries to distinguish between audio and video tracks.
-- - For large datasets, consider indexing relevant columns to optimize query performance.


-- =========================================================
--  Employee Birthday Celebration Dates
-- =========================================================

-- 5. HR wants to plan birthday celebrations for all employees in 2016. They would like a list of
-- employee names and birth dates, as well as the day of the week the birthday falls on in 2016.
-- Celebrations will be planned the same day as the birthday if it falls on Monday through Friday. If
-- the birthday falls on a weekend then the celebration date needs to be set on the following
-- Monday. Provide a report that displays the above date logic. The column formatting needs to
-- be the same as in the example below. (Hint: This is a tough one. I used 7 different functions in
-- my solution. You will need to nest functions inside other functions. Don’t worry about
-- accounting for leap birthdays in your script.)


-- Declare and initialize the test year variable
DECLARE @TestYear INT = 2016;

-- Common Table Expression (CTE) to calculate birthdays and their corresponding day of the week in the test year
WITH CelebrationCalculations AS (
    SELECT
        -- Concatenate first and last names to get the full employee name
        FirstName + ' ' + LastName AS EmployeeName,
		@TestYear AS BirthDayYear,
        -- Format the original birth date as MM/dd/yyyy for display purposes
        FORMAT(BirthDate, 'MM/dd/yyyy') AS BirthDate,
        -- Construct the birthday date in the test year
        DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate)) AS BirthdayCurrentYear,
        -- Determine the day of the week for the constructed birthday (1 = Sunday, 7 = Saturday)
        DATEPART(dw, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) AS DayOfWeek
    FROM
        Employee
)

-- Final SELECT statement to determine the celebration date
SELECT
    EmployeeName,
    BirthDate,
	FORMAT(BirthdayCurrentYear,'MM/dd/yyyy') AS [Birthday2016],
	DayOfWeek AS DayOfWeek#,
	DATENAME(dw,BirthdayCurrentYear) AS DayOfWeek,
    -- Calculate the celebration date based on the day of the week and format date
	FORMAT(
		CASE
			WHEN DayOfWeek = 1 THEN DATEADD(day, 1, BirthdayCurrentYear) 
			WHEN DayOfWeek = 7 THEN DATEADD(day, 2, BirthdayCurrentYear) 
			ELSE BirthdayCurrentYear
		END, 'MM/dd/yyy'
	) AS CelebrationDate,
    -- Retrieve the name of the day for the celebration date
    DATENAME(dw, CASE
        WHEN DayOfWeek = 1 THEN DATEADD(day, 1, BirthdayCurrentYear)
        WHEN DayOfWeek = 7 THEN DATEADD(day, 2, BirthdayCurrentYear)
        ELSE BirthdayCurrentYear
    END) AS CelebrationDay
FROM
    CelebrationCalculations;


--------------------------

-- =========================================================
--  Solution 2: Adjusting Celebration Dates Without CTE
-- =========================================================

-- Declare and initialize the test year variable
--DECLARE @TestYear INT = 2016;

-- Calculate birthdays and their celebration dates
SELECT
    -- Concatenate first and last names to get the full employee name
    FirstName + ' ' + LastName AS EmployeeName,
    -- Format the original birth date as MM/dd/yyyy for display purposes
    FORMAT(BirthDate, 'MM/dd/yyyy') AS BirthDate,
    -- Construct the birthday date in the test year
    FORMAT(DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate)),'MM/dd/yyyy') AS Birthday2016,
    --Determine the day of the week for the constructed birthday (1 = Sunday, 7 = Saturday)
    DATEPART(WEEKDAY, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) AS DayOfWeek#,
	DATENAME(dw, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) AS DayOfWeek,
    ----

    -- Calculate the celebration date based on the day of the week
    FORMAT(
		CASE
			WHEN DATEPART(WEEKDAY, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) = 1 THEN DATEADD(DAY, 1, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) -- If Sunday, add 1 day
			WHEN DATEPART(WEEKDAY, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) = 7 THEN DATEADD(DAY, 2, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) -- If Saturday, add 2 days
			ELSE DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate)) -- For other days, keep the original date
		END, 'MM/dd/yyyy'
	) AS CelebrationDate,

    -- Retrieve the name of the day for the celebration date'

		DATENAME(WEEKDAY,
		    FORMAT(
				CASE
					WHEN DATEPART(WEEKDAY, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) = 1 THEN DATEADD(DAY, 1, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate)))
					WHEN DATEPART(WEEKDAY, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))) = 7 THEN DATEADD(DAY, 2, DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate)))
					ELSE DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))
		       END,'MM/dd/yyyy')
	    ) AS CelebrationDay
FROM
    Employee;


-- =========================================================
--  Solution 3: Adjusting Celebration Birthday for Leap Year
-- =========================================================

--DECLARE @TestYear INT = 2016;  -- Change the year dynamically
DECLARE @DynamicSQL NVARCHAR(MAX);
DECLARE @DynamicColumn NVARCHAR(255);

-- Construct the dynamic column name for Birthday@TestYear
SET @DynamicColumn = CONCAT('[Birthday', @TestYear, ']');
 
-- Build the dynamic SQL query
SET @DynamicSQL = N'
WITH CelebrationCalculations AS (
    SELECT
        FirstName + '' '' + LastName AS EmployeeName,
        FORMAT(BirthDate, ''MM/dd/yyyy'') AS BirthDate,
        
        -- Handle leap years: Move Feb 29 to March 1 if not a leap year
        CASE 
            WHEN MONTH(BirthDate) = 2 AND DAY(BirthDate) = 29 
                 AND NOT ((@TestYear % 4 = 0 AND @TestYear % 100 <> 0) OR (@TestYear % 400 = 0))
            THEN DATEFROMPARTS(@TestYear, 3, 1)  -- Move to March 1
            ELSE DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))
        END AS BirthdayCurrentYear,

        DATEPART(WEEKDAY, 
            CASE 
                WHEN MONTH(BirthDate) = 2 AND DAY(BirthDate) = 29 
                     AND NOT ((@TestYear % 4 = 0 AND @TestYear % 100 <> 0) OR (@TestYear % 400 = 0))
                THEN DATEFROMPARTS(@TestYear, 3, 1)  -- Move to March 1
                ELSE DATEFROMPARTS(@TestYear, MONTH(BirthDate), DAY(BirthDate))
            END
        ) AS DayOfWeek
    FROM Employee
)
SELECT
    EmployeeName,
    BirthDate,
    FORMAT(BirthdayCurrentYear, ''MM/dd/yyyy'') AS ' + @DynamicColumn + N',
    DayOfWeek AS DayOfWeek#,
    DATENAME(dw, BirthdayCurrentYear) AS DayOfWeek,
    FORMAT(
        CASE
            WHEN DayOfWeek = 1 THEN DATEADD(day, 1, BirthdayCurrentYear)  -- Move Sunday to Monday
            WHEN DayOfWeek = 7 THEN DATEADD(day, 2, BirthdayCurrentYear)  -- Move Saturday to Monday
            ELSE BirthdayCurrentYear
        END, ''MM/dd/yyyy''
    ) AS CelebrationDate,
    DATENAME(dw, 
        CASE
            WHEN DayOfWeek = 1 THEN DATEADD(day, 1, BirthdayCurrentYear)
            WHEN DayOfWeek = 7 THEN DATEADD(day, 2, BirthdayCurrentYear)
            ELSE BirthdayCurrentYear
        END
    ) AS CelebrationDay
FROM CelebrationCalculations;';

-- Execute the dynamic SQL query
EXEC sp_executesql @DynamicSQL, N'@TestYear INT', @TestYear;
