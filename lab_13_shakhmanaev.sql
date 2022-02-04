USE LAB13_DB_a
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Products')
    DROP TABLE Products
GO

CREATE TABLE dbo.Products
(
    id          INTEGER PRIMARY KEY
        CHECK (id BETWEEN 1 AND 10),
    name        varchar(30) NOT NULL UNIQUE ,
    price       money       NOT NULL DEFAULT 0,
)
GO

USE LAB13_DB_b
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Products')
    DROP TABLE Products
GO

CREATE TABLE dbo.Products
(
    id          INTEGER PRIMARY KEY
        CHECK (id BETWEEN 11 AND 20),
    name        varchar(30) NOT NULL,
    price       money       NOT NULL DEFAULT 0,
)
GO


USE LAB13_DB_a
GO
-- DROP VIEW products_view
-- GO

CREATE VIEW products_view AS
SELECT *
FROM LAB13_DB_a.dbo.Products
UNION ALL
SELECT *
FROM LAB13_DB_b.dbo.Products
GO



USE LAB13_DB_b
GO
-- DROP VIEW products_view
-- GO

CREATE VIEW products_view AS
SELECT *
FROM LAB13_DB_a.dbo.Products
UNION ALL
SELECT *
FROM LAB13_DB_b.dbo.Products
GO

INSERT INTO products_view
VALUES (1, N'Огурец', 25),
       (2, N'Яблоко', 25),
       (11, N'Помидор', 100),
       (10, N'Арбузик', 100),
       (16, N'Банан', 100),
       (8, N'Баклажан', 100),
       (20, N'Малина', 100),
       (3, N'Свекла', 100)
GO

