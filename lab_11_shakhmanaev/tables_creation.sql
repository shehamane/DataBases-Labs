USE LAB11_DB
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'LineItems')
    BEGIN
        ALTER TABLE LineItems
            DROP CONSTRAINT FK_LineItems_Orders;
        ALTER TABLE LineItems
            DROP CONSTRAINT FK_LineItems_Products;
        DROP TABLE LineItems
    END
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Products')
    BEGIN
        ALTER TABLE Products
            DROP CONSTRAINT FK_Products_Categories;
        DROP TABLE Products
    END
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Categories')
    BEGIN
        ALTER TABLE Categories
            DROP CONSTRAINT FK_Categories_Categories;
        DROP TABLE Categories
    END
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Orders')
    BEGIN
        ALTER TABLE Orders
            DROP CONSTRAINT FK_Order_User;
        DROP TABLE Orders
    END
GO

IF EXISTS(SELECT 1
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_NAME = 'Users')
    BEGIN
        ALTER TABLE Users
            DROP CONSTRAINT FK_Users_Users;
        DROP TABLE Users
    END
GO


CREATE TABLE Users
(
    user_id          INT IDENTITY (1, 1) PRIMARY KEY,
    referral_id      INT,
    email            CHAR(320)    NOT NULL UNIQUE,
    username         CHAR(30)     NOT NULL UNIQUE,
    delivery_address VARCHAR(MAX) NOT NULL,
    phone_number     CHAR(11),
    bonus_balance    MONEY        NOT NULL DEFAULT 0,
    CONSTRAINT FK_Users_Users FOREIGN KEY (referral_id)
        REFERENCES Users (user_id)
)
GO

CREATE TABLE Orders
(
    order_id        INT IDENTITY (1, 1) PRIMARY KEY,
    user_id         INT NOT NULL,
    proceed_date    DATETIME,
    proceed_state   BIT NOT NULL DEFAULT 0,
    delivery_state  TINYINT,
    delivery_method TINYINT DEFAULT 0,
    delivery_price  MONEY DEFAULT 0,
    CONSTRAINT FK_Order_User FOREIGN KEY (user_id)
        REFERENCES Users (user_id)
        ON DELETE CASCADE
)
GO

CREATE TABLE Categories
(
    category_id INT IDENTITY (1, 1) PRIMARY KEY,
    parent_id   INT,
    name        CHAR(20) NOT NULL UNIQUE,
    description VARCHAR(50),
    CONSTRAINT FK_Categories_Categories FOREIGN KEY (parent_id)
        REFERENCES Categories (category_id)
)
GO

CREATE TABLE Products
(
    product_id  INT IDENTITY (1, 1) PRIMARY KEY,
    category_id INT         NOT NULL,
    name        VARCHAR(20) NOT NULL,
    description VARCHAR(50),
    price       MONEY       NOT NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (category_id)
        REFERENCES Categories (category_id)
        ON DELETE CASCADE
)
GO

CREATE TABLE LineItems
(
    order_id    INT   NOT NULL,
    product_id  INT   NOT NULL,
    amount      INT   NOT NULL,
    state       BIT   NOT NULL DEFAULT 1,
    fixed_price MONEY NOT NULL,
    CONSTRAINT FK_LineItems_Orders FOREIGN KEY (order_id)
        REFERENCES Orders (order_id)
        ON DELETE CASCADE,
    CONSTRAINT FK_LineItems_Products FOREIGN KEY (product_id)
        REFERENCES Products (product_id)
        ON DELETE CASCADE
)
GO

ALTER TABLE Products
    ADD vendor_code INT NOT NULL UNIQUE
GO