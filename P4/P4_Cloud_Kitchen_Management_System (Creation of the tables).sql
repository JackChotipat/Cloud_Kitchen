-- ============================================
-- Cloud Kitchen Management System
-- DDL Script | DAMG 6210 | Group 5
-- ============================================

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'CloudKitchenDB')
BEGIN
    ALTER DATABASE CloudKitchenDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CloudKitchenDB;
END
GO

CREATE DATABASE CloudKitchenDB;
GO

USE CloudKitchenDB;
GO


-- DROP TABLES IF THEY EXIST 

IF OBJECT_ID('STAFF_STATION',   'U') IS NOT NULL DROP TABLE STAFF_STATION;
IF OBJECT_ID('ORDER_STATION',   'U') IS NOT NULL DROP TABLE ORDER_STATION;
IF OBJECT_ID('ORDER_ITEM',      'U') IS NOT NULL DROP TABLE ORDER_ITEM;
IF OBJECT_ID('PAYMENT',         'U') IS NOT NULL DROP TABLE PAYMENT;
IF OBJECT_ID('RECIPE',          'U') IS NOT NULL DROP TABLE RECIPE;
IF OBJECT_ID('INGREDIENT',      'U') IS NOT NULL DROP TABLE INGREDIENT;
IF OBJECT_ID('[ORDER]',         'U') IS NOT NULL DROP TABLE [ORDER];
IF OBJECT_ID('ADDRESS',         'U') IS NOT NULL DROP TABLE ADDRESS;
IF OBJECT_ID('MENU_ITEM',       'U') IS NOT NULL DROP TABLE MENU_ITEM;
IF OBJECT_ID('BRAND',           'U') IS NOT NULL DROP TABLE BRAND;
IF OBJECT_ID('KITCHEN_STAFF',   'U') IS NOT NULL DROP TABLE KITCHEN_STAFF;
IF OBJECT_ID('KITCHEN_STATION', 'U') IS NOT NULL DROP TABLE KITCHEN_STATION;
IF OBJECT_ID('CUSTOMER',        'U') IS NOT NULL DROP TABLE CUSTOMER;
IF OBJECT_ID('DELIVERY_PARTNER','U') IS NOT NULL DROP TABLE DELIVERY_PARTNER;
IF OBJECT_ID('SUPPLIER',        'U') IS NOT NULL DROP TABLE SUPPLIER;
IF OBJECT_ID('VENDOR',          'U') IS NOT NULL DROP TABLE VENDOR;
GO


-- VENDOR (Supertype)

CREATE TABLE VENDOR (
    vendor_id       INT IDENTITY(1,1)   NOT NULL,
    vendor_name     VARCHAR(100)        NOT NULL,
    phone_number    VARCHAR(15)         NOT NULL,
    email           VARCHAR(150)        NOT NULL,
    vendor_type     VARCHAR(20)         NOT NULL,
    CONSTRAINT PK_VENDOR 
        PRIMARY KEY (vendor_id),
    CONSTRAINT UQ_VENDOR_PHONE 
        UNIQUE (phone_number),
    CONSTRAINT UQ_VENDOR_EMAIL 
        UNIQUE (email),
    CONSTRAINT CHK_VENDOR_TYPE 
        CHECK (vendor_type IN ('supplier', 'delivery_partner'))
);
GO


-- SUPPLIER (Subtype of VENDOR)

CREATE TABLE SUPPLIER (
    supplier_id     INT             NOT NULL,
    contact_person  VARCHAR(100)    NULL,
    CONSTRAINT PK_SUPPLIER 
        PRIMARY KEY (supplier_id),
    CONSTRAINT FK_SUPPLIER_VENDOR 
        FOREIGN KEY (supplier_id) REFERENCES VENDOR(vendor_id)
);
GO


-- DELIVERY_PARTNER (Another Subtype of VENDOR)

CREATE TABLE DELIVERY_PARTNER (
    partner_id      INT             NOT NULL,
    commission_rate DECIMAL(5,2)    NOT NULL,
    service_area    VARCHAR(200)    NOT NULL,
    rating          DECIMAL(3,2)    NULL,
    CONSTRAINT PK_DELIVERY_PARTNER 
        PRIMARY KEY (partner_id),
    CONSTRAINT FK_DELIVERY_PARTNER_VENDOR 
        FOREIGN KEY (partner_id) REFERENCES VENDOR(vendor_id),
    CONSTRAINT CHK_COMMISSION_RATE 
        CHECK (commission_rate BETWEEN 0 AND 100),
    CONSTRAINT CHK_PARTNER_RATING 
        CHECK (rating BETWEEN 0 AND 5)
);
GO


-- CUSTOMER

CREATE TABLE CUSTOMER (
    customer_id     INT IDENTITY(1,1)   NOT NULL,
    customer_name   VARCHAR(100)        NOT NULL,
    phone_number    VARCHAR(15)         NOT NULL,
    email           VARCHAR(150)        NOT NULL,
    loyalty_points  INT                 NOT NULL DEFAULT 0,
    CONSTRAINT PK_CUSTOMER 
        PRIMARY KEY (customer_id),
    CONSTRAINT UQ_CUSTOMER_PHONE 
        UNIQUE (phone_number),
    CONSTRAINT UQ_CUSTOMER_EMAIL 
        UNIQUE (email),
    CONSTRAINT CHK_LOYALTY_POINTS 
        CHECK (loyalty_points >= 0)
);
GO


-- ADDRESS

CREATE TABLE ADDRESS (
    address_id      INT IDENTITY(1,1)   NOT NULL,
    customer_id     INT                 NOT NULL,
    street          VARCHAR(200)        NOT NULL,
    city            VARCHAR(100)        NOT NULL,
    [state]         VARCHAR(50)         NOT NULL,
    zip_code        VARCHAR(10)         NOT NULL,
    is_default      BIT                 NOT NULL DEFAULT 0,
    CONSTRAINT PK_ADDRESS 
        PRIMARY KEY (address_id),
    CONSTRAINT FK_ADDRESS_CUSTOMER 
        FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);
GO


-- BRAND

CREATE TABLE BRAND (
    brand_id        INT IDENTITY(1,1)   NOT NULL,
    brand_name      VARCHAR(100)        NOT NULL,
    cuisine_type    VARCHAR(50)         NOT NULL,
    active_status   BIT                 NOT NULL DEFAULT 1,
    [description]   TEXT                NULL,
    CONSTRAINT PK_BRAND 
        PRIMARY KEY (brand_id),
    CONSTRAINT UQ_BRAND_NAME 
        UNIQUE (brand_name)
);
GO


-- MENU_ITEM

CREATE TABLE MENU_ITEM (
    item_id             INT IDENTITY(1,1)   NOT NULL,
    brand_id            INT                 NOT NULL,
    item_name           VARCHAR(100)        NOT NULL,
    [description]       TEXT                NULL,
    price               DECIMAL(10,2)       NOT NULL,
    category            VARCHAR(50)         NOT NULL,
    preparation_time    INT                 NOT NULL,
    available           BIT                 NOT NULL DEFAULT 1,
    dietary_tags        VARCHAR(200)        NULL,
    CONSTRAINT PK_MENU_ITEM 
        PRIMARY KEY (item_id),
    CONSTRAINT FK_MENU_ITEM_BRAND 
        FOREIGN KEY (brand_id) REFERENCES BRAND(brand_id),
    CONSTRAINT CHK_MENU_ITEM_PRICE 
        CHECK (price > 0),
    CONSTRAINT CHK_PREP_TIME 
        CHECK (preparation_time > 0)
);
GO


-- INGREDIENT

CREATE TABLE INGREDIENT (
    ingredient_id       INT IDENTITY(1,1)   NOT NULL,
    supplier_id         INT                 NOT NULL,
    ingredient_name     VARCHAR(100)        NOT NULL,
    unit_of_measurement VARCHAR(20)         NOT NULL,
    current_stock       DECIMAL(10,2)       NOT NULL,
    minimum_threshold   DECIMAL(10,2)       NOT NULL,
    shelf_life_days     INT                 NOT NULL,
    CONSTRAINT PK_INGREDIENT 
        PRIMARY KEY (ingredient_id),
    CONSTRAINT FK_INGREDIENT_SUPPLIER 
        FOREIGN KEY (supplier_id) REFERENCES SUPPLIER(supplier_id),
    CONSTRAINT UQ_INGREDIENT_NAME 
        UNIQUE (ingredient_name),
    CONSTRAINT CHK_CURRENT_STOCK 
        CHECK (current_stock >= 0),
    CONSTRAINT CHK_MINIMUM_THRESHOLD 
        CHECK (minimum_threshold > 0),
    CONSTRAINT CHK_SHELF_LIFE 
        CHECK (shelf_life_days > 0)
);
GO


-- KITCHEN_STATION

CREATE TABLE KITCHEN_STATION (
    station_id          INT IDENTITY(1,1)   NOT NULL,
    station_name        VARCHAR(100)        NOT NULL,
    station_type        VARCHAR(50)         NOT NULL,
    operational_status  VARCHAR(20)         NOT NULL DEFAULT 'active',
    CONSTRAINT PK_KITCHEN_STATION 
        PRIMARY KEY (station_id),
    CONSTRAINT UQ_STATION_NAME 
        UNIQUE (station_name),
    CONSTRAINT CHK_OPERATIONAL_STATUS 
        CHECK (operational_status IN ('active', 'inactive', 'maintenance'))
);
GO


-- KITCHEN_STAFF

CREATE TABLE KITCHEN_STAFF (
    employee_id     INT IDENTITY(1,1)   NOT NULL,
    staff_name      VARCHAR(100)        NOT NULL,
    [role]          VARCHAR(50)         NOT NULL,
    current_shift   VARCHAR(20)         NOT NULL,
    hire_date       DATE                NOT NULL,
    CONSTRAINT PK_KITCHEN_STAFF 
        PRIMARY KEY (employee_id),
    CONSTRAINT CHK_SHIFT 
        CHECK (current_shift IN ('morning', 'afternoon', 'night'))
);
GO


-- ORDER

CREATE TABLE [ORDER] (
    order_id                INT IDENTITY(1,1)   NOT NULL,
    customer_id             INT                 NOT NULL,
    brand_id                INT                 NOT NULL,
    partner_id              INT                 NOT NULL,
    order_datetime          DATETIME            NOT NULL DEFAULT GETDATE(),
    order_status            VARCHAR(20)         NOT NULL DEFAULT 'pending',
    total_amount            DECIMAL(10,2)       NOT NULL,
    delivery_fee            DECIMAL(10,2)       NOT NULL,
    platform_source         VARCHAR(50)         NOT NULL,
    special_instructions    TEXT                NULL,
    customer_rating         TINYINT             NULL,
    review_text             TEXT                NULL,
    review_date             DATE                NULL,
    CONSTRAINT PK_ORDER 
        PRIMARY KEY (order_id),
    CONSTRAINT FK_ORDER_CUSTOMER 
        FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT FK_ORDER_BRAND 
        FOREIGN KEY (brand_id) REFERENCES BRAND(brand_id),
    CONSTRAINT FK_ORDER_PARTNER 
        FOREIGN KEY (partner_id) REFERENCES DELIVERY_PARTNER(partner_id),
    CONSTRAINT CHK_ORDER_STATUS 
        CHECK (order_status IN ('pending', 'preparing', 'out_for_delivery', 'delivered', 'cancelled')),
    CONSTRAINT CHK_CUSTOMER_RATING 
        CHECK (customer_rating BETWEEN 1 AND 5),
    CONSTRAINT CHK_TOTAL_AMOUNT 
        CHECK (total_amount > 0),
    CONSTRAINT CHK_DELIVERY_FEE 
        CHECK (delivery_fee >= 0)
);
GO


-- ORDER_ITEM

CREATE TABLE ORDER_ITEM (
    order_item_id       INT IDENTITY(1,1)   NOT NULL,
    order_id            INT                 NOT NULL,
    item_id             INT                 NOT NULL,
    quantity            INT                 NOT NULL,
    item_price          DECIMAL(10,2)       NOT NULL,
    customization_notes TEXT                NULL,
    CONSTRAINT PK_ORDER_ITEM 
        PRIMARY KEY (order_item_id),
    CONSTRAINT FK_ORDER_ITEM_ORDER 
        FOREIGN KEY (order_id) REFERENCES [ORDER](order_id),
    CONSTRAINT FK_ORDER_ITEM_MENU 
        FOREIGN KEY (item_id) REFERENCES MENU_ITEM(item_id),
    CONSTRAINT CHK_ORDER_ITEM_QUANTITY 
        CHECK (quantity > 0),
    CONSTRAINT CHK_ORDER_ITEM_PRICE 
        CHECK (item_price > 0)
);
GO


-- PAYMENT

CREATE TABLE PAYMENT (
    payment_id          INT IDENTITY(1,1)   NOT NULL,
    order_id            INT                 NOT NULL,
    payment_method      VARCHAR(20)         NOT NULL,
    payment_status      VARCHAR(20)         NOT NULL DEFAULT 'pending',
    payment_datetime    DATETIME            NOT NULL DEFAULT GETDATE(),
    transaction_id      VARCHAR(100)        NULL,
    amount_paid         DECIMAL(10,2)       NOT NULL,
    CONSTRAINT PK_PAYMENT 
        PRIMARY KEY (payment_id),
    CONSTRAINT FK_PAYMENT_ORDER 
        FOREIGN KEY (order_id) REFERENCES [ORDER](order_id),
    CONSTRAINT CHK_PAYMENT_METHOD 
        CHECK (payment_method IN ('cash', 'card', 'online', 'platform')),
    CONSTRAINT CHK_PAYMENT_STATUS 
        CHECK (payment_status IN ('pending', 'completed', 'refunded', 'failed')),
    CONSTRAINT CHK_AMOUNT_PAID 
        CHECK (amount_paid > 0)
);
GO

-- Allows multiple NULLs but blocks duplicate real transaction IDs
CREATE UNIQUE INDEX UQ_TRANSACTION_ID 
ON PAYMENT (transaction_id) 
WHERE transaction_id IS NOT NULL;
GO


-- RECIPE

CREATE TABLE RECIPE (
    recipe_id           INT IDENTITY(1,1)   NOT NULL,
    item_id             INT                 NOT NULL,
    ingredient_id       INT                 NOT NULL,
    quantity_required   DECIMAL(10,2)       NOT NULL,
    preparation_notes   TEXT                NULL,
    CONSTRAINT PK_RECIPE 
        PRIMARY KEY (recipe_id),
    CONSTRAINT FK_RECIPE_MENU_ITEM 
        FOREIGN KEY (item_id) REFERENCES MENU_ITEM(item_id),
    CONSTRAINT FK_RECIPE_INGREDIENT 
        FOREIGN KEY (ingredient_id) REFERENCES INGREDIENT(ingredient_id),
    CONSTRAINT UQ_RECIPE_ITEM_INGREDIENT 
        UNIQUE (item_id, ingredient_id),
    CONSTRAINT CHK_QUANTITY_REQUIRED 
        CHECK (quantity_required > 0)
);
GO


-- ORDER_STATION

CREATE TABLE ORDER_STATION (
    order_station_id    INT IDENTITY(1,1)   NOT NULL,
    order_id            INT                 NOT NULL,
    station_id          INT                 NOT NULL,
    start_time          DATETIME            NULL,
    completion_time     DATETIME            NULL,
    [status]            VARCHAR(20)         NOT NULL DEFAULT 'pending',
    CONSTRAINT PK_ORDER_STATION 
        PRIMARY KEY (order_station_id),
    CONSTRAINT FK_ORDER_STATION_ORDER 
        FOREIGN KEY (order_id) REFERENCES [ORDER](order_id),
    CONSTRAINT FK_ORDER_STATION_STATION 
        FOREIGN KEY (station_id) REFERENCES KITCHEN_STATION(station_id),
    CONSTRAINT CHK_ORDER_STATION_STATUS 
        CHECK ([status] IN ('pending', 'in_progress', 'completed')),
    CONSTRAINT CHK_COMPLETION_AFTER_START 
        CHECK (completion_time IS NULL OR completion_time >= start_time)
);
GO


-- STAFF_STATION

CREATE TABLE STAFF_STATION (
    staff_station_id    INT IDENTITY(1,1)   NOT NULL,
    employee_id         INT                 NOT NULL,
    station_id          INT                 NOT NULL,
    CONSTRAINT PK_STAFF_STATION 
        PRIMARY KEY (staff_station_id),
    CONSTRAINT FK_STAFF_STATION_EMPLOYEE 
        FOREIGN KEY (employee_id) REFERENCES KITCHEN_STAFF(employee_id),
    CONSTRAINT FK_STAFF_STATION_STATION 
        FOREIGN KEY (station_id) REFERENCES KITCHEN_STATION(station_id),
    CONSTRAINT UQ_STAFF_STATION 
        UNIQUE (employee_id, station_id)
);
GO