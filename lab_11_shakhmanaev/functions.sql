USE LAB11_DB
GO

CREATE PROCEDURE checkCategoryForExisting @name CHAR(20),
                                          @result BIT OUTPUT
AS
    SET @result = 0
    IF ((SELECT COUNT(*)
         FROM Categories c
         WHERE c.name = @name) > 0)
        SET @result = 1
    RETURN
GO

CREATE PROCEDURE getReferralsID @user_id INT
AS
BEGIN
    SELECT u.user_id
    FROM Users u
    WHERE u.referral_id = @user_id
END
GO

CREATE PROCEDURE getOrderSize @order_id INT,
                              @order_size INT OUTPUT
AS
BEGIN
    SELECT @order_size = COUNT(*)
    FROM LineItems
    WHERE order_id = @order_id
END
GO

CREATE PROCEDURE proceedOrder @order_id INT
AS
    BEGIN
       UPDATE Orders
        SET proceed_state = 1,
            proceed_date = GETDATE(),
            delivery_state = 0
        WHERE order_id=@order_id
    END
