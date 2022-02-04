USE LAB11_DB
GO

INSERT Users(referral_id, email, username, delivery_address, phone_number)
VALUES (1, 'test1@mail.ru', 'test1', 'test1', '00000000000')
GO

UPDATE Users
SET referral_id=2
WHERE user_id = 4
GO

DELETE Users
WHERE user_id = 2
GO

INSERT Orders(user_id)
VALUES (1),
       (3),
       (4)
GO

UPDATE Orders
SET proceed_state = 1
WHERE proceed_state = 0

INSERT Products(category_id, name, price, vendor_code)
VALUES (6, N'Куртка "Белая раса"', 15000, 123)
GO

UPDATE Products
SET vendor_code=321
WHERE vendor_code = 123
GO


UPDATE Products
SET name=N'Куртка GigaChad'
WHERE vendor_code = 123
GO

UPDATE LineItems
SET amount=amount + 1
GO

UPDATE LineItems
SET fixed_price=fixed_price + 1
GO

INSERT LineItems(order_id, product_id, amount)
VALUES (6, 3, 3)
GO

SELECT category_name
FROM ProductsInfo_View
GO

EXEC proceedOrder @order_id = 6

UPDATE orders_info_view
SET size=4
WHERE order_id = 7

UPDATE categories_info_view
SET parent_name=N'Фрукты'
WHERE category_id = 3

UPDATE categories_info_view
SET name=N'Кроссовки'
WHERE name = N'Обувь'

INSERT LineItems(order_id, product_id, amount)
VALUES (8, 4, 6),
       (8, 2, 1)

EXEC proceedOrder @order_id = 8

SELECT *
FROM orders_info_view
ORDER BY price DESC
GO

INSERT LineItems(order_id, product_id, amount)
VALUES (7, 6, 11)

UPDATE Orders
SET proceed_state=1
WHERE order_id = 7

SELECT C.name,
       COUNT(P.product_id) as size,
       AVG(P.price)        as average_price,
       MIN(P.price)        as min_price,
       MAX(P.price)        as max_price
FROM Categories C
         INNER JOIN Products P on C.category_id = P.category_id
GROUP BY C.name
HAVING (COUNT(P.product_id) > 0)
ORDER BY average_price
GO


SELECT P.name,
       SUM(LI.amount)       as sold_number,
       COUNT(LI.product_id) as ordered_number
FROM Products P
         INNER JOIN LineItems LI ON P.product_id = LI.product_id
         LEFT JOIN Orders O on LI.order_id = O.order_id
WHERE O.proceed_state=1
GROUP BY P.name
ORDER BY sold_number DESC, ordered_number DESC


UPDATE ProductsInfo_View
SET name='Nike AirForce1'
WHERE vendor_code=5

SELECT u.username, u.email
FROM Users u
WHERE u.email LIKE '%@mail.ru' AND u.phone_number IS NULL

SELECT p.name, p.vendor_code, p.price
FROM Products p
WHERE p.price BETWEEN 1000 AND 10000

SELECT *
FROM Categories child FULL OUTER JOIN Categories parent
ON child.parent_id = parent.category_id

SELECT name, price
FROM ProductsInfo_View
WHERE category_name = N'Фрукты'
UNION
SELECT name, price
FROM Products
WHERE category_id =4
ORDER BY  name

