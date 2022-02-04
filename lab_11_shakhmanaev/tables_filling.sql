USE LAB11_DB
GO

INSERT INTO Users(username, email, delivery_address)
VALUES ('shehamane', 'shehamane@mail.ru', N'ул. Пушкина, д. Колотушкина'),
       ('avonamardba', 'avonamardba@gmail.com', N'ПГТ Дядькино'),
       ('leeroy_jenkins', 'leeeeroy@yahoo.com', 'Azeroth')
GO


INSERT INTO Categories(name)
VALUES ('Продукты питания'),
       ('Одежда')
GO

INSERT INTO Categories(parent_id, name)
VALUES (1, 'Фрукты'),
       (1, 'Овощи'),
       (1, 'Выпечка'),
       (2, 'Куртки'),
       (2, 'Обувь')
GO


INSERT INTO ProductsInfo_View(vendor_code, name, price, category_name)
VALUES (1, N'Яблоко, кг', 100, N'Фрукты'),
       (2, N'Банан, шт', 20, N'Фрукты'),
       (3, N'Огурец, кг', 70, N'Овощи'),
       (4, N'Чебурек', 35, N'Выпечка'),
       (5, N'Nike AirForce', 9990, N'Обувь')
GO

INSERT INTO Orders(user_id, proceed_state)
VALUES (1, 0),
       (2, 0),
       (3, 0)
GO

INSERT INTO LineItems(order_id, product_id, amount)
VALUES (1, 1, 10),
       (2, 3, 7),
       (1, 1, 2),
       (2, 4, 1),
       (3, 5, 1),
       (3, 3, 3)
