USE master;
GO

DROP DATABASE IF EXISTS [LAB15_DB_a];
DROP DATABASE IF EXISTS [LAB15_DB_b];
GO

CREATE DATABASE LAB15_DB_a;
GO
CREATE DATABASE LAB15_DB_b;
GO

USE LAB15_DB_a;
GO

CREATE TABLE Categories
(
    id   int PRIMARY KEY,
    name varchar(30) NOT NULL UNIQUE
)
GO

USE LAB15_DB_b;
GO

CREATE TABLE Products
(
    id          UNIQUEIDENTIFIER     DEFAULT NEWID() PRIMARY KEY,
    name        varchar(30) NOT NULL UNIQUE ,
    description text,
    price       money       NOT NULL DEFAULT 0,
    category_id int                  DEFAULT NULL,
)
GO

CREATE TRIGGER products_insert_trig
    ON Products
    INSTEAD OF INSERT AS
BEGIN
    IF ((SELECT COUNT(*)
         FROM inserted i
                  INNER JOIN LAB15_DB_a.dbo.Categories c
                             ON i.category_id = c.id) = (SELECT COUNT(*) FROM inserted))
        INSERT INTO Products
        SELECT *
        FROM inserted
    ELSE
        BEGIN
            THROW 50001, 'No reference found', 1;
        END
END
GO

CREATE TRIGGER products_update_trig
    ON Products
    INSTEAD OF UPDATE AS
BEGIN
    IF UPDATE(id)
        BEGIN
            RAISERROR ('Update interrupted', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
    IF UPDATE(category_id)
        IF ((SELECT COUNT(*)
             FROM inserted i
                      INNER JOIN LAB15_DB_a.dbo.Categories c
                                 ON i.category_id = c.id) = (SELECT COUNT(*) FROM inserted))
            UPDATE Products
            SET Products.category_id = (SELECT c.id
                                        FROM inserted i
                                                 JOIN deleted d ON i.id = d.id
                                                 LEFT JOIN LAB15_DB_a.dbo.Categories c ON i.category_id = c.id
                                        WHERE d.id = Products.id)
            WHERE id in (SELECT id FROM deleted)
        ELSE
            BEGIN
                THROW 50001, 'No reference found', 1;
            END
    IF UPDATE(name)
        UPDATE Products
        SET Products.name = (SELECT i.name
                             FROM inserted as i
                                      JOIN deleted as d
                                           ON i.id = d.id
                             WHERE Products.id = d.id)
        WHERE name IN (SELECT name FROM deleted)

    IF UPDATE(price)
        UPDATE Products
        SET Products.price = (SELECT i.price
                              FROM inserted as i
                                       JOIN deleted as d
                                            ON i.id = d.id
                              WHERE Products.id = d.id)
        WHERE name IN (SELECT name FROM deleted)

END
GO

INSERT Products(name, price, category_id)
VALUES ('Apple', 10, 1),
       ('Onion', 8, 2)
GO

UPDATE Products
SET category_id = 1
WHERE category_id = 2
GO

INSERT LAB15_DB_a.dbo.Categories(id, name)
VALUES (1, 'Fruits'),
       (2, 'Vegetables')
GO


USE LAB15_DB_a
GO

CREATE TRIGGER cat_delete_trig
    ON Categories
    INSTEAD OF DELETE AS
BEGIN
    DELETE
    FROM Categories
    WHERE Categories.id IN (SELECT deleted.id FROM deleted)

    DELETE
    FROM LAB15_DB_b.dbo.Products
    WHERE Products.category_id IN (SELECT deleted.id FROM deleted)
END
GO

DELETE
FROM Categories
WHERE id = 2;
GO


CREATE TRIGGER cat_update_trig
    ON Categories
    INSTEAD OF UPDATE AS
BEGIN
    DECLARE @tmp TABLE
                 (
                     del_id INT,
                     new_id INT
                 );
    IF UPDATE(id)
        BEGIN
            UPDATE Categories
            SET Categories.id   = inserted.id,
                Categories.name = inserted.name
            OUTPUT deleted.id,
                   inserted.id INTO @tmp
            FROM inserted
            WHERE Categories.name = inserted.name;
            UPDATE LAB15_DB_b.dbo.Products
            SET category_id = t.new_id
            FROM @tmp t
            WHERE category_id = t.del_id
        END
END
GO

UPDATE Categories
SET id=id + 1
WHERE id < 100

