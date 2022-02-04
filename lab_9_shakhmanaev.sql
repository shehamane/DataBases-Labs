USE master;
GO

USE LAB9_DB;
GO

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
    id           int IDENTITY (0, 1),
    email        varchar(max),
    phone_number varchar(11),
    age          int CHECK (age > 18 AND age < 117),
    balance      money NOT NULL DEFAULT 0,
    name         varchar(100)
)
GO

CREATE TABLE Categories
(
    id   int PRIMARY KEY,
    name varchar(30) NOT NULL UNIQUE
)
GO

CREATE TABLE Products
(
    id          UNIQUEIDENTIFIER     DEFAULT NEWID() PRIMARY KEY,
    name        varchar(30) NOT NULL UNIQUE,
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
    (email, age, name)
VALUES ('abc@abc.com', 23, 'Alexander'),
       ('aaa@aaa.aaa', 28, 'Dinara'),
       ('avonamardba@gmail.com', 19, 'Zagir'),
       ('oleg_kek@mail.sru', 108, 'Bender Ostap')
GO

UPDATE Users
SET balance = balance + 100
WHERE Users.age > 20
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.SEQUENCES
          WHERE SEQUENCE_NAME = 'CategorySec')
    DROP SEQUENCE CategorySec
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



DROP VIEW Products_Info
GO

CREATE VIEW Products_Info AS
SELECT p.id, p.name, p.price, c.name category_name
FROM Products p
         JOIN Categories c ON c.id = p.category_id
GO


CREATE TRIGGER users_insert_trig
    ON Users
    FOR INSERT
    AS
    IF
            (SELECT COUNT(*)
             FROM inserted
             WHERE inserted.phone_number IS NULL
               AND inserted.email IS NULL) > 0
        BEGIN
            SELECT * FROM inserted
            RAISERROR ('Inserted user have not any contact information', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
GO

-- INSERT Users (age, name)
-- VALUES (19, 'Maga')
-- GO


CREATE TRIGGER users_update_trig
    ON Users
    FOR UPDATE
    AS
    IF UPDATE(age)
        BEGIN
            PRINT ('Users updated')
            RETURN
        END
GO

UPDATE Users
SET age = 20
WHERE name = 'Alexander'
GO

CREATE TRIGGER users_delete_trig
    ON Users
    FOR DELETE
    AS
    PRINT ('User deleted')
GO

-- DELETE Users
-- WHERE age = 20
-- GO


CREATE TRIGGER prod_info_update_trig
    ON Products_Info
    INSTEAD OF UPDATE
    AS
    IF UPDATE(price) OR UPDATE(id)
        BEGIN
            RAISERROR ('Update interrupted', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
    IF UPDATE(category_name)
        BEGIN
            IF ((SELECT COUNT(*)
                 FROM inserted i
                          INNER JOIN Categories c
                                     ON i.category_name = c.name) < (SELECT COUNT(*) FROM inserted))
                BEGIN
                    RAISERROR ('No such category', 16, 1)
                    ROLLBACK TRANSACTION
                    RETURN
                END
            ELSE
                UPDATE Products
                SET Products.category_id = (SELECT c1.id
                                            FROM inserted i
                                                     JOIN deleted d ON i.id = d.id
                                                     LEFT JOIN Categories c1 ON i.category_name = c1.name
                                            WHERE d.id = Products.id)
                WHERE id in (SELECT id FROM deleted)
        END
    IF UPDATE(name)
        UPDATE Products
        SET Products.name = (SELECT i.name
                             FROM inserted as i
                                      JOIN deleted as d
                                           ON i.id = d.id
                             WHERE Products.name = d.name)
        WHERE name IN (SELECT name FROM deleted)
GO



UPDATE Products_Info
SET name='Banana'
WHERE name = N'Банан'
GO


UPDATE Products_Info
SET category_name=N'Овощи'
WHERE name = N'Огурец'
GO

UPDATE Products_Info
SET category_name=N'Хлеб'
WHERE name = N'Огурец'
GO

UPDATE Products_Info
SET name=name + '!'
WHERE price = 100
GO

CREATE TRIGGER prod_info_insert_trig
    ON Products_Info
    INSTEAD OF INSERT
    AS
BEGIN
    IF ((SELECT COUNT(*)
         FROM inserted i
                  INNER JOIN Categories c
                             ON i.category_name = c.name) = (SELECT COUNT(*) FROM inserted))
        INSERT INTO Products (name, price, category_id)
        SELECT i.name, i.price, c.id
        FROM inserted as i
                 INNER JOIN Categories as c
                            ON i.category_name = c.name
    ELSE
        BEGIN
            RAISERROR ('No such category', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
END
GO

INSERT Products_Info (name, price, category_name)
VALUES (N'Тыква', 150, N'Овощи')
GO

INSERT Products_Info (name, price, category_name)
VALUES (N'Клубника', 150, 'Хлеб')
GO

CREATE TRIGGER prod_info_del_trig
    ON Products_Info
    INSTEAD OF DELETE
    AS
    DELETE Products
    WHERE Products.id IN
          (SELECT id FROM deleted)
GO
--
DELETE Products_Info
WHERE price = 100
GO