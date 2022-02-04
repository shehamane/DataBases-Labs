USE master;
GO

IF DB_ID(N'Lab8') IS NOT NULL
    DROP DATABASE Lab8;
GO

CREATE DATABASE Lab8;
GO

USE Lab8
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Products')
    DROP TABLE Products
GO


CREATE TABLE Products
(
    id    INT IDENTITY (1, 1) PRIMARY KEY,
    name  NVARCHAR(100) NOT NULL,
    type  NVARCHAR(100),
    price int DEFAULT 0
)
GO

INSERT INTO Products
VALUES (N'Яблоко', N'Фрукты', 25),
       (N'Банан', N'Фрукты', 20),
       (N'Огурец', N'Овощи', 15),
       (N'Груша', N'Фрукты', 0)
GO

CREATE PROCEDURE dbo.usp_GetFruits @fruits_cursor CURSOR VARYING OUTPUT
AS
    SET @fruits_cursor = CURSOR
        FORWARD_ONLY STATIC FOR
            SELECT p.name, p.price
            FROM Products p
            Where p.type = N'Фрукты'
    OPEN @fruits_cursor;
GO


CREATE FUNCTION dbo.ufn_PriceToRub(@price int)
    RETURNS int
AS
BEGIN
    DECLARE @ret int;
    SET @ret = @price * 74
    RETURN @ret
END
GO

CREATE PROCEDURE dbo.usp_GetFruitsWithRubPrice @fruits_cursor CURSOR VARYING OUTPUT
AS
    SET @fruits_cursor = CURSOR
        FORWARD_ONLY STATIC FOR
        SELECT p.name, p.price, dbo.ufn_PriceToRub(p.price)
        FROM Products p
        Where p.type = N'Фрукты'
    OPEN @fruits_cursor;
GO

CREATE FUNCTION dbo.ufn_IsNotFree(@price int)
    RETURNS BIT
AS
BEGIN
    if @price = 0
        RETURN 0
    RETURN 1
END
GO

CREATE PROCEDURE dbo.getFruitsNotFree
AS
    DECLARE @products_cursor CURSOR
    EXEC usp_GetFruits @fruits_cursor = @products_cursor OUTPUT

    DECLARE @price int
    DECLARE @name NVARCHAR(100)
    WHILE (1=1)
    BEGIN
       FETCH NEXT FROM @products_cursor INTO @name, @price
        IF @@FETCH_STATUS <> 0
           BREAK
        IF dbo.ufn_IsNotFree(@price) = 1
            PRINT FORMATMESSAGE('Name: %s, Price: %d$', @name, @price)
    END
    CLOSE @products_cursor
    DEALLOCATE @products_cursor
GO

EXEC dbo.getFruitsNotFree
GO

CREATE FUNCTION dbo.ufn_GetFruitsWithRubPrice_Inline()
RETURNS TABLE
AS RETURN
(
    SELECT p.name, dbo.ufn_PriceToRub(p.price) as price
    FROM Products p
    WHERE p.type=N'Фрукты'
)
GO

CREATE FUNCTION dbo.ufn_GetFruitsWithRubPrice_NotInline()
RETURNS @retTable TABLE(
    name NVARCHAR(100) NOT NULL ,
    price INT
)
AS
BEGIN
    INSERT @retTable SELECT name, dbo.ufn_PriceToRub(price) as price FROM Products
    WHERE type=N'Фрукты'
    RETURN
END
GO

CREATE PROCEDURE dbo.usp_getFruitsWithRubPrice_Table
    @fruits_cursor CURSOR VARYING OUTPUT
AS
    SET @fruits_cursor = CURSOR FORWARD_ONLY STATIC FOR
        SELECT * FROM
        dbo.ufn_GetFruitsWithRubPrice_Inline()
    OPEN @fruits_cursor
GO


DECLARE @cursor CURSOR
EXEC usp_getFruitsWithRubPrice_Table @fruits_cursor = @cursor OUTPUT
DECLARE @name NVARCHAR(100)
DECLARE @price INT
WHILE 1=1
BEGIN
        FETCH NEXT FROM @cursor INTO @name, @price
        IF @@FETCH_STATUS <> 0
            BREAK
        PRINT FORMATMESSAGE('Name: %s, Price: %dRUB', @name, @price)
end
