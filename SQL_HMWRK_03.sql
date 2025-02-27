-- SQL Homework 3
-- Sam Polk

-- 1. Find the genres that have an ampersand "&" in the name. (3 rows)
-- Use the Genre table. Display 2 columns, Name and NewName.
-- NewName is derived from Name, but it will have some of the ampersands removed.
-- If the ampersand has a space before and after it then Replace the ampersand with the word "and", otherwise the name stays the same.
-- Only display those records with an ampersand in the Name column.
SELECT Name, 
       CASE
           WHEN Name LIKE '%&%' THEN REPLACE(Name, '&', ' and ')
           ELSE Name 
       END AS NewName
FROM Genre
WHERE Name LIKE '%&%';


-- 2. Display Employee names and Birthdates. (8 rows)
-- Use the Employee table.
-- Concatenate the first and last name into new column called FullName.
-- Display the Birthdate in 3 different columns called Day, Month and Year.
-- The Month column value should be the full name of the month.
SELECT FirstName + ' ' + LastName AS FullName,
       DAY(BirthDate) AS Day,
       DATENAME(MONTH, BirthDate) AS Month,
       YEAR(BirthDate) AS Year
FROM Employee;

SELECT FirstName + ' ' + LastName FullName,
       DAY(BirthDate) Day,
       DATENAME(MONTH, BirthDate) Month,
       YEAR(BirthDate) Year
FROM Employee;


-- 3. Run a query with the following modifications to the Album Title column: (347 rows)
-- Display Title with all the spaces removed. Name it TitleNoSpaces.
-- Display Title in all upper-case letters. Name it TitleUpperCase.
-- Display Title in reverse order. Name it TitleReverse.
-- Display the character length of the Title column Name it TitleLength.
-- Display the starting position of the first space in the Title column. Name it SpaceLocation.
SELECT Title,
       REPLACE(Title, ' ', '') AS TitleNoSpaces,
       UPPER(Title) AS TitleUpperCase,
       REVERSE(Title) AS TitleReverse,
       LEN(Title) AS TitleLength,
       CHARINDEX(' ', Title) AS SpaceLocation
FROM Album;


-- 4. Display the current age in years of Employees. (8 rows)
-- Display FirstName, LastName, BirthDate, and Age.
-- Age is a column you will have to build from birthdate and the current date.
-- Note: This question is tougher than it looks. I will accept a close answer.
SELECT FirstName, LastName, BirthDate, 
       DATEDIFF(YEAR, BirthDate, GETDATE()) AS Age
FROM Employee;

SELECT 
    FirstName, 
    LastName, 
    FORMAT(BirthDate, 'MM-dd-yyyy') AS BirthDate,  -- Formats BirthDate to mm-dd-yyyy
    YEAR(GETDATE()) - YEAR(BirthDate) - 
    IIF(MONTH(BirthDate) > MONTH(GETDATE()) OR 
        (MONTH(BirthDate) = MONTH(GETDATE()) AND DAY(BirthDate) > DAY(GETDATE())), 1, 0) AS Age
FROM Employee;


DECLARE @CurrentDate DATE;  -- Variable for today's date
DECLARE @Age INT;           -- Variable to store the calculated age

SET @CurrentDate = GETDATE();  -- Get today's date

SELECT 
    FirstName, 
    LastName, 
    FORMAT(BirthDate, 'MM-dd-yyyy') AS BirthDate,  -- Format BirthDate as MM-dd-yyyy
    -- Calculate age
    YEAR(@CurrentDate) - YEAR(BirthDate) - 
    IIF(MONTH(BirthDate) > MONTH(@CurrentDate) OR 
        (MONTH(BirthDate) = MONTH(@CurrentDate) AND DAY(BirthDate) > DAY(@CurrentDate)), 1, 0) AS Age
FROM Employee;

DECLARE @CurrentUnixSeconds BIGINT = DATEDIFF(SECOND, '1970-01-01', GETDATE());

SELECT 
    FirstName, 
    LastName, 
    FORMAT(BirthDate, 'MM-dd-yyyy') AS BirthDate,  
    FLOOR((@CurrentUnixSeconds - DATEDIFF(SECOND, '1970-01-01', BirthDate)) / 31556952.0) AS Age
FROM Employee;


SELECT 
    FirstName, 
    LastName, 
    FORMAT(BirthDate, 'MM-dd-yyyy') AS BirthDate,  
    FLOOR((CAST(DATEDIFF(SECOND, '1970-01-01', GETDATE()) AS BIGINT) - 
           CAST(DATEDIFF(SECOND, '1970-01-01', BirthDate) AS BIGINT)) / 31556952.0) AS Age
FROM Employee;

-- 5. Display Title and ShortTitle for Employees. (8 rows)
-- Use the Employee table.
-- Short title is derived from the Title column but has the first word in the title removed.
-- (e.g. "General Manager" becomes "Manager".)
-- Remove any leading spaces.
SELECT Title,
       LTRIM(SUBSTRING(Title, CHARINDEX(' ', Title) + 1, LEN(Title))) AS ShortTitle
FROM Employee;


-- 6. Display Customer names and initials. (59 rows)
-- Display FirstName, LastName, Initials.
-- Initials is the customer's initials from his or her first and last name.
-- Order the records by Initials.
SELECT FirstName, LastName,
       UPPER(LEFT(FirstName, 1) + LEFT(LastName, 1)) AS Initials
FROM Customer
ORDER BY Initials;

-- 7. Display the Name, Phone, and Fax numbers for USA customers. (13 Rows)
-- Use the FirstName, LastName, Phone and Fax columns.
-- For Phone and Fax remove the international code "+1" and replace the dash "-" with a space.
-- If the Fax number is NULL replace it with the value "Unknown".
-- Order by LastName.
SELECT FirstName + ' ' + LastName AS Name,
       REPLACE(REPLACE(Phone, '+1', ''), '-', ' ') AS Phone,
       COALESCE(REPLACE(REPLACE(Fax, '+1', ''), '-', ' '), 'Unknown') AS Fax
FROM Customer
WHERE Country = 'USA'
ORDER BY LastName;


-- 8. Display customer names and their company. (35 rows)
-- Use the Customer table.
-- Create a new column called CustomerName that has LastName followed by a comma then FirstName.
-- CustomerName must be all upper case.
-- If the company value is NULL, replace it with "N/A".
-- Only display customers whose last name starts with A through M.
SELECT UPPER(LastName + ', ' + FirstName) AS CustomerName,
       COALESCE(Company, 'N/A') AS Company
FROM Customer
WHERE LastName LIKE '[A-M]%';

-- 9. Display the fiscal year an invoice record was recorded in the Invoice table. (412 rows)
-- Your result set will have InvoiceId, CustomerId, Total, InvoiceDate and FiscalYear columns.
-- The FiscalYear is 6 months ahead of the calendar year
-- (e.g. fiscal year 2010 contains dates from July 2009 through June 2010)
-- Display the FiscalYear in the following format (FY2009, FY2010, FY2011, etc...)
-- Change the InvoiceDate column datatype from datetime to date (i.e. don't display the time which is all zeros anyway.)
-- Order by InvoiceDate in descending order.
SELECT InvoiceId, CustomerId, Total,
       CAST(InvoiceDate AS DATE) AS InvoiceDate,
       'FY' + CAST(YEAR(DATEADD(MONTH, 6, InvoiceDate)) AS VARCHAR) AS FiscalYear
FROM Invoice
ORDER BY InvoiceDate DESC

-- 10. Group the customers into Customer Type buckets. (59 rows)
-- Use the Customer table.
-- Display the following columns: CustomerType, FirstName, LastName and Country.
-- CustomerType is a derived column. If the customer is from "USA" or "Canada" then display "Domestic" otherwise display "International".
-- Order by CustomerType then LastName in ascending order.
SELECT CASE 
           WHEN Country IN ('USA', 'Canada') THEN 'Domestic'
           ELSE 'International' 
       END AS CustomerType,
       FirstName, LastName, Country
FROM Customer
ORDER BY CustomerType, LastName;
