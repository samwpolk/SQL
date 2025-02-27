/* Samuel Polk */


/* 1. Display all columns and rows from the Employee Table */
SELECT * 
  FROM Employee;

/* 2. Display FirstName, LastName, and Email columns from the Employee Table */
SELECT [FirstName]
      ,[LastName]
      ,[Email]
  FROM Employee;

/* 3. Display Name, Composer, and AlbumId from the Track table.
   Only return rows whose AlbumId is equal to 19 */
SELECT [Name]
      ,[Composer]
      ,[AlbumId]
  FROM Track
  WHERE AlbumId = 19;

/* 4. Display Name, Composer, and AlbumId from the Track table.
   Create an Alias for the Name column called "Track Title."
   Only return rows whose AlbumId is equal to 19.
   Order the rows by Composer and then by Name, both in ascending order. */
SELECT [Name] AS [Track Title]
      ,[Composer]
      ,[AlbumId]
  FROM Track
  WHERE AlbumId = 19
  ORDER BY [Composer], [Name];

/* 5. Display BillingCountry, BillingCity, and Total from the Invoice Table.
   Only display the top 5 rows.
   Only return rows where the BillingCountry column is not equal to "USA."
   Order the rows by Total in descending order. */
SELECT TOP 5 [BillingCountry]
      ,[BillingCity]
      ,[Total]
  FROM Invoice
  WHERE BillingCountry <> 'USA'
  ORDER BY [Total] DESC;

/* 6. Display State and Country from the Customer table.
   Only return distinct rows.
   Only return rows where the Country column is equal to "USA." */
SELECT DISTINCT [State]
      ,[Country]
  FROM Customer
  WHERE Country = 'USA';

/* 7. Display CustomerId, BillingCity, BillingPostalCode, and Total from the Invoice table.
   Only return rows where the BillingCountry equals "Germany" and the Total column is greater than 5.
   Order by CustomerId ascending, then Total ascending. */
SELECT [CustomerId]
      ,[BillingCity]
      ,[BillingPostalCode]
      ,[Total]
  FROM Invoice
  WHERE BillingCountry = 'Germany' AND Total > 5
  ORDER BY [CustomerId], [Total];

/* 8. Display Country and State from the Customer table.
   Only return the top 20 rows.
   Only return distinct rows.
   Assign Country the alias "Country Name" and State the alias "State or Region."
   Order by Country and State in ascending order. */
SELECT DISTINCT TOP 20
       [Country] AS [Country Name]
      ,[State] AS [State or Region]
  FROM Customer
  ORDER BY [Country], [State];

/* 9. Display AlbumId, MediaTypeId, and Name from the Track Table.
   Only return rows with an AlbumId less than or equal to 5, or a MediaTypeID equal to 2.
   Order by AlbumId in ascending order. */
SELECT [AlbumId]
      ,[MediaTypeId]
      ,[Name]
  FROM Track
  WHERE ([AlbumId] <= 5 OR [MediaTypeId] = 2)
  ORDER BY [AlbumId];

/* 10. Display AlbumId, Name, Milliseconds, and UnitPrice from the Track table.
   Only return rows with AlbumId = 5 and Milliseconds > 300000, or have a UnitPrice greater than 0.99.
   Order by AlbumId and Milliseconds in ascending order. */
SELECT [AlbumId]
      ,[Name]
      ,[Milliseconds]
      ,[UnitPrice]
  FROM Track
  WHERE (AlbumId = 5 AND Milliseconds > 300000) OR (UnitPrice > 0.99)
  ORDER BY [AlbumId], [Milliseconds];
