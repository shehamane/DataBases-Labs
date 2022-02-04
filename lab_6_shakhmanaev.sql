USE master;
GO

IF DB_ID(N'LAB6_DB') IS NOT NULL
    DROP DATABASE LAB6_DB;
GO

CREATE DATABASE LAB6_DB;
GO

USE LAB6_DB;
Go

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Users')
    DROP TABLE Users
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Products')
    DROP TABLE Products
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Categories')
    DROP TABLE Categories
GO

CREATE TABLE Users
(
    id      int IDENTITY (0, 1),
    email   varchar(max) NOT NULL,
    age     int CHECK (age > 18 AND age < 117),
    balance money        NOT NULL DEFAULT 0
)
GO

CREATE TABLE Categories
(
    id   int PRIMARY KEY,
    name varchar(30) NOT NULL
)
GO

CREATE TABLE Products
(
    id          UNIQUEIDENTIFIER     DEFAULT NEWID() PRIMARY KEY ,
    name        varchar(30) NOT NULL,
    description text,
    price       money       NOT NULL DEFAULT 0,
    category_id int                  DEFAULT NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (category_id)
        REFERENCES Categories (id)
        ON DELETE SET DEFAULT
        ON UPDATE CASCADE
)
GO

SET IDENTITY_INSERT Users OFF
INSERT Users
    (email, age)
VALUES ('abc@abc.com', 23),
       ('aaa@aaa.aaa', 28),
       ('avonamardba@gmail.com', 19),
       ('oleg_kek@mail.sru', 108)
GO

UPDATE Users
SET balance = balance + 100
WHERE Users.age > 20
GO

SET IDENTITY_INSERT Users ON
INSERT Users
    (id, email, age)
VALUES (SCOPE_IDENTITY() + 1, 'kurigohan@mail.ru', 74)
GO


CREATE SEQUENCE CategorySec
    START WITH 1
    INCREMENT BY 2
GO

INSERT Categories
    (id, name)
VALUES (NEXT VALUE FOR CategorySec, N'Фрукты'),
       (NEXT VALUE FOR CategorySec, N'Овощи'),
       (NEXT VALUE FOR CategorySec, N'Ягоды')

GO


INSERT Products
    (name, price, category_id)
VALUES (N'Огурец', 25, 1),
       (N'Яблоко', 25, 3),
       (N'Помидор', 100, 3),
       (N'Арбузик', 100, 5),
       (N'Банан', 100, 3),
       (N'Баклажан', 100, 1),
       (N'Малина', 100, 5),
       (N'Свекла', 100, 1)
GO

DELETE
FROM Categories
WHERE id = 1
GO

UPDATE Categories
SET id=2
WHERE id = 3
GO