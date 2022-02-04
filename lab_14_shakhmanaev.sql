USE
    LAB13_DB_a
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Categories')
    DROP TABLE Categories
GO

CREATE TABLE dbo.Categories
(
    id   INTEGER PRIMARY KEY,
    name varchar(30) NOT NULL UNIQUE
)
GO

USE LAB13_DB_b
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Categories')
    DROP TABLE Categories
GO

CREATE TABLE dbo.Categories
(
    id          INTEGER PRIMARY KEY,
    description varchar(255) NOT NULL
)
GO



USE LAB13_DB_a
GO

-- DROP VIEW categories_view
-- GO

CREATE VIEW categories_view AS
SELECT c1.id, c1.name, c2.description
FROM LAB13_DB_a.dbo.Categories c1
         INNER JOIN
     LAB13_DB_b.dbo.Categories c2
     ON c1.id = c2.id
GO

CREATE TRIGGER insert_trig
    ON categories_view
    INSTEAD OF INSERT AS
BEGIN
    DECLARE @tmp TABLE
                 (
                     id   INT,
                     name VARCHAR(30)
                 );
    INSERT INTO LAB13_DB_a.dbo.Categories
    OUTPUT inserted.id,
           inserted.name INTO @tmp
    SELECT NEXT VALUE FOR CategorySec, inserted.name
    FROM inserted;
    INSERT INTO LAB13_DB_b.dbo.Categories
    SELECT t.id, inserted.description
    FROM inserted
             INNER JOIN @tmp AS t ON t.name = inserted.name;
END
GO

CREATE TRIGGER delete_trigger
    ON categories_view
    INSTEAD OF DELETE AS
    DELETE
    FROM LAB13_DB_a.dbo.Categories
    WHERE Categories.id IN (SELECT deleted.id FROM deleted);
    DELETE
    FROM LAB13_DB_b.dbo.Categories
    WHERE id IN (SELECT deleted.id FROM deleted);
GO

CREATE TRIGGER update_trigger
    ON categories_view
    INSTEAD OF UPDATE AS
    IF UPDATE(id)
        THROW 50011, 'You can not update ID', 1;
    IF UPDATE(name)
    UPDATE LAB13_DB_a.dbo.Categories
    SET name = inserted.name
    FROM inserted
    WHERE LAB13_DB_a.dbo.Categories.id = inserted.id;
    IF UPDATE(description)
    UPDATE LAB13_DB_b.dbo.Categories
    SET description = inserted.description
    FROM inserted
    WHERE LAB13_DB_b.dbo.Categories.id = inserted.id;
GO


USE LAB13_DB_b;
GO


CREATE VIEW categories_view AS
SELECT c1.id, c1.name, c2.description
FROM LAB13_DB_a.dbo.Categories c1
         INNER JOIN
     LAB13_DB_b.dbo.Categories c2
     ON c1.id = c2.id
GO

INSERT categories_view (id, name, description)
VALUES (1, 'Фрукты', 'desc1'),
       (2, 'Овощи', 'desc2'),
       (3, 'Хлеб', 'desc3');
GO

DELETE
FROM categories_view
WHERE id = 4;
GO

UPDATE categories_view
SET description = 'aaaaa'
WHERE id = 2;
GO