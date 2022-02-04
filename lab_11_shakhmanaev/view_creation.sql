USE LAB11_DB
GO

CREATE VIEW ProductsInfo_View
            (vendor_code, name, description, price, category_name)
            WITH SCHEMABINDING
AS
SELECT P.vendor_code, P.name, P.description, P.price, C.name
FROM dbo.Products P
         LEFT JOIN dbo.Categories C on P.category_id = C.category_id
GO

CREATE TRIGGER prod_info_insert
    ON ProductsInfo_View
    INSTEAD OF INSERT
    AS
    IF ((SELECT COUNT(*)
         FROM inserted i
                  INNER JOIN Categories C
                             ON i.category_name = C.name) = (SELECT COUNT(*)
                                                             FROM inserted))
        INSERT INTO Products (vendor_code, name, price, description, category_id)
        SELECT i.vendor_code, i.name, i.price, i.description, c.category_id
        FROM inserted i
                 INNER JOIN Categories C
                            ON i.category_name = c.name
    ELSE
        BEGIN
            RAISERROR ('No such category', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
GO
--
-- INSERT ProductsInfo_View (vendor_code, name, price, category_name)
-- VALUES (13, N'Тыква', 150, N'Овощи')
-- GO
--
-- INSERT ProductsInfo_View (vendor_code, name, price, category_name)
-- VALUES (11, N'Клубника', 150, 'Хлеб')
-- GO

CREATE TRIGGER prod_info_update
    ON ProductsInfo_View
    INSTEAD OF UPDATE
    AS
    IF UPDATE(vendor_code)
        BEGIN
            RAISERROR ('impossible to delete vendor_code', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
    IF UPDATE(category_name)
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
            SET Products.category_id = (SELECT c1.category_id
                                        FROM inserted i
                                                 JOIN deleted d ON i.vendor_code = d.vendor_code
                                                 LEFT JOIN Categories c1 ON i.category_name = c1.name
                                        WHERE d.vendor_code = Products.vendor_code)
            WHERE vendor_code in (SELECT vendor_code FROM deleted)
    IF UPDATE(name) OR UPDATE(description) OR UPDATE(price)
        UPDATE Products
        SET name        = i.name,
            description = i.description,
            price       = i.price
        FROM inserted i
        WHERE Products.vendor_code = i.vendor_code
GO

DROP VIEW orders_info_view
CREATE VIEW orders_info_view
            (order_id, user_id, username, proceed_state, size, price, proceed_date)
            WITH SCHEMABINDING
AS
(
SELECT o.order_id,
       o.user_id,
       u.username,
       o.proceed_state,
       SUM(amount)                     OrderSize,
       SUM(li.fixed_price * li.amount) OrderPrice,
       o.proceed_date
FROM dbo.Orders o
         INNER JOIN dbo.Users u ON o.user_id = u.user_id
         INNER JOIN dbo.LineItems li
                    ON o.order_id = li.order_id
GROUP BY o.user_id, o.proceed_state, o.order_id, u.username, proceed_date)
WITH CHECK OPTION
GO


CREATE VIEW categories_info_view
            (category_id, name, parent_name)
            WITH SCHEMABINDING
AS
SELECT c1.category_id, c1.name, c2.name
FROM dbo.Categories c1
         LEFT JOIN dbo.Categories c2
                   ON c1.parent_id = c2.category_id
GO

CREATE TRIGGER categories_info_view_update
    ON categories_info_view
    INSTEAD OF UPDATE
    AS
    IF UPDATE(category_id)
        BEGIN
            RAISERROR ('category_id cant be updated', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
    IF UPDATE(parent_name)
        IF ((SELECT COUNT(*)
             FROM inserted i
                      INNER JOIN Categories c
                                 ON i.parent_name = c.name) < (SELECT COUNT(*)
                                                               FROM inserted))
            BEGIN
                RAISERROR ('No such category', 16, 1)
                ROLLBACK TRANSACTION
                RETURN
            END
        ELSE
            UPDATE Categories
            SET Categories.parent_id = (SELECT c1.category_id
                                        FROM inserted i
                                                 JOIN deleted d ON i.category_id = d.category_id
                                                 LEFT JOIN Categories c1 ON i.parent_name = c1.name
                                        WHERE d.category_id = Categories.category_id)
            WHERE category_id in (SELECT category_id FROM deleted)
    IF UPDATE(name)
        UPDATE Categories
        SET name = i.name
        FROM inserted i
        WHERE Categories.category_id = i.category_id


-- UPDATE ProductsInfo_View
-- SET category_name=N'Хлеб'
-- WHERE name=N'Банан, шт'
-- GO
--
-- UPDATE ProductsInfo_View
-- SET name=N'Банан, шт.',
--     description=N'Вкусные бананчики',
--     price=80
-- WHERE name=N'Банан, шт'
-- GO
