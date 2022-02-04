USE LAB11_DB
GO

-- USER
CREATE TRIGGER user_delete
    ON Users
    INSTEAD OF DELETE
    AS
    DECLARE
        @deleted_id_cursor CURSOR
    SET @deleted_id_cursor = CURSOR SCROLL STATIC
        FOR
        SELECT user_id
        FROM deleted
    OPEN @deleted_id_cursor
    DECLARE
        @deleted_id INT
    WHILE 1 = 1
        BEGIN
            FETCH NEXT FROM @deleted_id_cursor INTO @deleted_id
            IF @@FETCH_STATUS <> 0
                BREAK
            UPDATE Users
            SET referral_id = NULL
            WHERE user_id IN (
                SELECT u.user_id
                FROM Users u
                WHERE u.referral_id = @deleted_id
            )
            DELETE Users
            WHERE user_id = @deleted_id
        END
GO

CREATE TRIGGER user_update
    ON Users
    AFTER UPDATE
    AS
    IF UPDATE(user_id)
        BEGIN
            RAISERROR (50009, 16, 10)
        END
GO

-- ORDERS
CREATE TRIGGER order_update
    ON Orders
    INSTEAD OF UPDATE
    AS
BEGIN
    IF 0 IN (SELECT o.size
             FROM deleted d
                      LEFT JOIN orders_info_view o
                                ON d.order_id = o.order_id)
        BEGIN
            RAISERROR ('Empty order cant be proceeded', 16, 10)
            ROLLBACK TRANSACTION
            RETURN
        END
    IF UPDATE(user_id) OR UPDATE(order_id)
        BEGIN
            RAISERROR (50009, 16, 10)
            ROLLBACK TRANSACTION
            RETURN
        END
    BEGIN
        UPDATE Orders
        SET delivery_state  = i.delivery_state,
            delivery_method = i.delivery_method,
            delivery_price  = i.delivery_price
        FROM inserted as i
        WHERE Orders.order_id = i.order_id

        UPDATE Orders
        SET proceed_state = 1,
            proceed_date  = GETDATE()
        FROM inserted as i
        WHERE Orders.order_id = i.order_id
          AND i.proceed_state = 1
    END
END
GO



-- LINEITEMS
CREATE TRIGGER lineItem_insert
    ON LineItems
    INSTEAD OF INSERT
    AS
BEGIN
    DECLARE @inserted_cursor CURSOR
    SET @inserted_cursor = CURSOR STATIC SCROLL
        FOR
        SELECT * FROM inserted
    DECLARE @product_id INT, @order_id INT, @amount INT, @state BIT, @fixed_price MONEY
    OPEN @inserted_cursor
    WHILE 1 = 1
        BEGIN
            FETCH NEXT FROM @inserted_cursor INTO @order_id, @product_id, @amount, @state, @fixed_price
            SELECT @fixed_price = p.price FROM Products p WHERE p.product_id = @product_id
            IF @@FETCH_STATUS <> 0
                BREAK
            IF ((SELECT COUNT(*)
                 FROM LineItems
                 WHERE product_id = @product_id
                   AND order_id = @order_id) > 0)
                UPDATE LineItems
                SET amount=amount + @amount
                WHERE product_id = @product_id
                  AND order_id = @order_id
            ELSE
                INSERT INTO LineItems
                VALUES (@order_id, @product_id, @amount, @state, @fixed_price)
        END
END
GO

CREATE TRIGGER lineItem_update
    ON LineItems
    INSTEAD OF UPDATE
    AS
    IF UPDATE(order_id) OR UPDATE(product_id) OR UPDATE(fixed_price)
        BEGIN
            RAISERROR (50009, 16, 10)
            ROLLBACK TRANSACTION
            RETURN
        END
    ELSE
        BEGIN
            UPDATE LineItems
            SET amount = i.amount,
                state  = i.state
            FROM inserted as i
            WHERE LineItems.order_id = i.order_id
              AND LineItems.product_id = i.product_id
        END
GO

-- PRODUCTS
CREATE TRIGGER product_update
    ON Products
    INSTEAD OF UPDATE
    AS
BEGIN
    IF UPDATE(product_id) OR UPDATE(vendor_code)
        BEGIN
            RAISERROR (50009, 16, 10)
            ROLLBACK TRANSACTION
            RETURN
        END
    BEGIN
        UPDATE Products
        SET name        = i.name,
            description = i.description,
            price       = i.price,
            category_id = i.category_id
        FROM inserted as i
        WHERE Products.product_id = i.product_id
    END
END
GO
