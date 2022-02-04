USE LAB6_DB;
GO


CREATE VIEW dbo.Rich_Users
WITH SCHEMABINDING AS
SELECT u.email, u.age
FROM dbo.Users as u
WHERE u.balance > 0
WITH CHECK OPTION
GO

CREATE VIEW Products_Info AS
SELECT p.name, p.price, c.name category_name
FROM Products p JOIN Categories c ON c.id = p.category_id
GO

CREATE UNIQUE CLUSTERED INDEX Users_Age_Idx
ON dbo.Rich_Users (age ASC, balance DESC)
GO


DROP INDEX Users_Age_Idx ON Rich_Users
GO


CREATE UNIQUE NONCLUSTERED INDEX Products_Price_Idx
ON dbo.Products (name desc) INCLUDE (price)
GO

SELECT id, name, price FROM Products
WHERE name LIKE 'Ба%'
GO

SELECT * FROM Products

EXECUTE sp_helpindex Products
Go

DROP INDEX Products_Price_Idx ON Products