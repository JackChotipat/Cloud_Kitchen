-- ============================================
-- Cloud Kitchen Management System
-- PSM Script | DAMG 6210 | Group 5
-- Contains: UDFs, Views, Stored Procedures, Triggers
-- ============================================

USE CloudKitchenDB;
GO


-- SECTION 1: USER DEFINED FUNCTIONS (UDFs)
-- UDFs are defined first because Views depend on them.


-- UDF 1: udf_GetBrandRevenue

IF OBJECT_ID('dbo.udf_GetBrandRevenue', 'FN') IS NOT NULL
    DROP FUNCTION dbo.udf_GetBrandRevenue;
GO

CREATE FUNCTION dbo.udf_GetBrandRevenue
(
    @brand_id   INT,
    @start_date DATETIME,
    @end_date   DATETIME
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @revenue DECIMAL(10,2);

    SELECT @revenue = ISNULL(SUM(p.amount_paid), 0)
    FROM [ORDER] o
    JOIN PAYMENT p ON o.order_id = p.order_id
    WHERE o.brand_id      = @brand_id
      AND o.order_status  = 'delivered'
      AND p.payment_status = 'completed'
      AND o.order_datetime BETWEEN @start_date AND @end_date;

    RETURN @revenue;
END;
GO



-- UDF 2: udf_GetOrderPrepTime

IF OBJECT_ID('dbo.udf_GetOrderPrepTime', 'FN') IS NOT NULL
    DROP FUNCTION dbo.udf_GetOrderPrepTime;
GO

CREATE FUNCTION dbo.udf_GetOrderPrepTime
(
    @order_id INT
)
RETURNS INT
AS
BEGIN
    DECLARE @total_prep_time INT;

    SELECT @total_prep_time = ISNULL(SUM(mi.preparation_time * oi.quantity), 0)
    FROM ORDER_ITEM oi
    JOIN MENU_ITEM mi ON oi.item_id = mi.item_id
    WHERE oi.order_id = @order_id;

    RETURN @total_prep_time;
END;
GO


-- UDF 3: udf_IsIngredientLowStock

IF OBJECT_ID('dbo.udf_IsIngredientLowStock', 'FN') IS NOT NULL
    DROP FUNCTION dbo.udf_IsIngredientLowStock;
GO

CREATE FUNCTION dbo.udf_IsIngredientLowStock
(
    @ingredient_id INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @is_low BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM INGREDIENT
        WHERE ingredient_id     = @ingredient_id
          AND current_stock     < minimum_threshold
    )
        SET @is_low = 1;

    RETURN @is_low;
END;
GO


-- SECTION 2: VIEWS
-- Views are defined after UDFs since some call UDF functions.

-- VIEW 1: vw_WeeklyRevenuePerBrand

IF OBJECT_ID('dbo.vw_WeeklyRevenuePerBrand', 'V') IS NOT NULL
    DROP VIEW dbo.vw_WeeklyRevenuePerBrand;
GO

CREATE VIEW dbo.vw_WeeklyRevenuePerBrand AS
SELECT
    b.brand_id,
    b.brand_name,
    b.cuisine_type,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    SUM(p.amount_paid)                                  AS total_revenue,
    AVG(p.amount_paid)                                  AS avg_order_value,
    AVG(CAST(o.customer_rating AS DECIMAL(3,2)))        AS avg_customer_rating,
    DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), 
            CAST(GETDATE() AS DATE))                    AS week_start_date,
    CAST(GETDATE() AS DATE)                             AS report_date
FROM BRAND b
JOIN [ORDER] o      ON b.brand_id       = o.brand_id
JOIN PAYMENT p      ON o.order_id       = p.order_id
WHERE o.order_status    = 'delivered'
  AND p.payment_status  = 'completed'
  AND o.order_datetime >= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()),
                                  CAST(GETDATE() AS DATE))
GROUP BY
    b.brand_id,
    b.brand_name,
    b.cuisine_type;
GO


-- VIEW 2: vw_TopPerformingMenuItems

IF OBJECT_ID('dbo.vw_TopPerformingMenuItems', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TopPerformingMenuItems;
GO

CREATE VIEW dbo.vw_TopPerformingMenuItems AS
SELECT
    mi.item_id,
    mi.item_name,
    mi.category,
    mi.price                                            AS current_price,
    mi.preparation_time                                 AS prep_time_minutes,
    mi.dietary_tags,
    b.brand_name,
    b.cuisine_type,
    COUNT(oi.order_item_id)                             AS times_ordered,
    SUM(oi.quantity)                                    AS total_units_sold,
    SUM(oi.quantity * oi.item_price)                    AS total_revenue_generated,
    AVG(CAST(o.customer_rating AS DECIMAL(3,2)))        AS avg_rating,
    RANK() OVER (ORDER BY SUM(oi.quantity) DESC)        AS sales_rank
FROM MENU_ITEM mi
JOIN BRAND b        ON mi.brand_id   = b.brand_id
JOIN ORDER_ITEM oi  ON mi.item_id    = oi.item_id
JOIN [ORDER] o      ON oi.order_id   = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    mi.item_id,
    mi.item_name,
    mi.category,
    mi.price,
    mi.preparation_time,
    mi.dietary_tags,
    b.brand_name,
    b.cuisine_type;
GO


-- VIEW 3: vw_LowStockIngredientSummary
IF OBJECT_ID('dbo.vw_LowStockIngredientSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_LowStockIngredientSummary;
GO

CREATE VIEW dbo.vw_LowStockIngredientSummary AS
SELECT
    i.ingredient_id,
    i.ingredient_name,
    i.unit_of_measurement,
    i.current_stock,
    i.minimum_threshold,
    i.current_stock - i.minimum_threshold               AS stock_deficit,
    i.shelf_life_days,
    v.vendor_name                                       AS supplier_name,
    v.phone_number                                      AS supplier_phone,
    v.email                                             AS supplier_email,
    s.contact_person                                    AS supplier_contact,
    mi.item_name                                        AS affected_menu_item,
    mi.available                                        AS item_currently_available,
    dbo.udf_IsIngredientLowStock(i.ingredient_id)       AS is_low_stock
FROM INGREDIENT i
JOIN SUPPLIER s     ON i.supplier_id    = s.supplier_id
JOIN VENDOR v       ON s.supplier_id    = v.vendor_id
JOIN RECIPE r       ON i.ingredient_id  = r.ingredient_id
JOIN MENU_ITEM mi   ON r.item_id        = mi.item_id
WHERE dbo.udf_IsIngredientLowStock(i.ingredient_id) = 1;
GO


-- VIEW 4: vw_OrderStatusPipeline

IF OBJECT_ID('dbo.vw_OrderStatusPipeline', 'V') IS NOT NULL
    DROP VIEW dbo.vw_OrderStatusPipeline;
GO

CREATE VIEW dbo.vw_OrderStatusPipeline AS
SELECT
    o.order_status,
    COUNT(o.order_id)                                   AS order_count,
    SUM(o.total_amount)                                 AS total_value_in_stage,
    AVG(o.total_amount)                                 AS avg_order_value,
    MIN(o.order_datetime)                               AS oldest_order_in_stage,
    MAX(o.order_datetime)                               AS newest_order_in_stage,
    DATEDIFF(MINUTE,
             MIN(o.order_datetime),
             GETDATE())                                 AS minutes_since_oldest_order
FROM [ORDER] o
GROUP BY o.order_status;
GO


-- SECTION 3: STORED PROCEDURES

-- SP 1: usp_PlaceOrder
-- TYPE: OrderItemType

IF TYPE_ID('dbo.OrderItemType') IS NOT NULL
    DROP TYPE dbo.OrderItemType;
GO

CREATE TYPE dbo.OrderItemType AS TABLE
(
    item_id     INT             NOT NULL,
    quantity    INT             NOT NULL,
    item_price  DECIMAL(10,2)  NOT NULL
);
GO


IF OBJECT_ID('dbo.usp_PlaceOrder', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_PlaceOrder;
GO

CREATE PROCEDURE dbo.usp_PlaceOrder
    @customer_id            INT,
    @brand_id               INT,
    @partner_id             INT,
    @platform_source        VARCHAR(50),
    @special_instructions   TEXT                = NULL,
    @payment_method         VARCHAR(20),
    @items                  OrderItemType       READONLY,
    -- Output parameters
    @new_order_id           INT                 OUTPUT,
    @total_amount           DECIMAL(10,2)       OUTPUT,
    @message                VARCHAR(255)        OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validate customer exists
        IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE customer_id = @customer_id)
        BEGIN
            SET @message = 'ERROR: Customer ID ' + CAST(@customer_id AS VARCHAR) + ' does not exist.';
            RETURN;
        END

        -- Validate brand exists and is active
        IF NOT EXISTS (SELECT 1 FROM BRAND WHERE brand_id = @brand_id AND active_status = 1)
        BEGIN
            SET @message = 'ERROR: Brand ID ' + CAST(@brand_id AS VARCHAR) + ' does not exist or is inactive.';
            RETURN;
        END

        -- Validate delivery partner exists
        IF NOT EXISTS (SELECT 1 FROM DELIVERY_PARTNER WHERE partner_id = @partner_id)
        BEGIN
            SET @message = 'ERROR: Delivery partner ID ' + CAST(@partner_id AS VARCHAR) + ' does not exist.';
            RETURN;
        END

        -- Validate at least one item provided
        IF NOT EXISTS (SELECT 1 FROM @items)
        BEGIN
            SET @message = 'ERROR: At least one order item must be provided.';
            RETURN;
        END

        -- Validate all item IDs exist in MENU_ITEM
        IF EXISTS (
            SELECT 1 FROM @items i
            WHERE NOT EXISTS (
                SELECT 1 FROM MENU_ITEM mi WHERE mi.item_id = i.item_id
            )
        )
        BEGIN
            SET @message = 'ERROR: One or more item IDs do not exist in MENU_ITEM.';
            RETURN;
        END

      
        -- Calculate total amount from items table
        SELECT @total_amount = ISNULL(SUM(quantity * item_price), 0)
        FROM @items;

        -- Calculate delivery fee (10% of total, min $1.99)
        DECLARE @delivery_fee DECIMAL(10,2);
        SET @delivery_fee = CASE
            WHEN @total_amount * 0.10 < 1.99 THEN 1.99
            ELSE ROUND(@total_amount * 0.10, 2)
        END;

       
        BEGIN TRANSACTION;

        -- Insert ORDER
        INSERT INTO [ORDER] (
            customer_id, brand_id, partner_id, order_datetime,
            order_status, total_amount, delivery_fee,
            platform_source, special_instructions
        )
        VALUES (
            @customer_id, @brand_id, @partner_id, GETDATE(),
            'pending', @total_amount, @delivery_fee,
            @platform_source, @special_instructions
        );

        SET @new_order_id = SCOPE_IDENTITY();

        -- Insert ORDER_ITEM rows from table parameter
        INSERT INTO ORDER_ITEM (order_id, item_id, quantity, item_price)
        SELECT @new_order_id, item_id, quantity, item_price
        FROM @items;

        -- Insert PAYMENT with pending status
        INSERT INTO PAYMENT (
            order_id, payment_method, payment_status,
            payment_datetime, amount_paid
        )
        VALUES (
            @new_order_id, @payment_method, 'pending',
            GETDATE(), @total_amount + @delivery_fee
        );

        -- Award loyalty points (1 point per dollar spent, rounded)
        UPDATE CUSTOMER
        SET loyalty_points = loyalty_points + ROUND(@total_amount, 0)
        WHERE customer_id = @customer_id;

        COMMIT TRANSACTION;

        SET @message = 'SUCCESS: Order #' + CAST(@new_order_id AS VARCHAR) +
                       ' placed successfully. Total: $' + CAST(@total_amount AS VARCHAR) +
                       ' | Delivery fee: $' + CAST(@delivery_fee AS VARCHAR) +
                       ' | Loyalty points awarded: ' + CAST(ROUND(@total_amount, 0) AS VARCHAR);

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @message = 'ERROR: ' + ERROR_MESSAGE();
        SET @new_order_id = NULL;
        SET @total_amount = NULL;
    END CATCH
END;
GO


-- SP 2: usp_UpdateOrderStatus

IF OBJECT_ID('dbo.usp_UpdateOrderStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UpdateOrderStatus;
GO

CREATE PROCEDURE dbo.usp_UpdateOrderStatus
    @order_id       INT,
    @new_status     VARCHAR(20),
    @old_status     VARCHAR(20) OUTPUT,
    @message        VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check order exists and get current status
        SELECT @old_status = order_status
        FROM [ORDER]
        WHERE order_id = @order_id;

        IF @old_status IS NULL
        BEGIN
            SET @message = 'ERROR: Order ID ' + CAST(@order_id AS VARCHAR) + ' does not exist.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate status transition
        DECLARE @valid_transition BIT = 0;

        IF @old_status = 'pending'          AND @new_status = 'preparing'          SET @valid_transition = 1;
        IF @old_status = 'preparing'        AND @new_status = 'out_for_delivery'   SET @valid_transition = 1;
        IF @old_status = 'out_for_delivery' AND @new_status = 'delivered'          SET @valid_transition = 1;
        IF @old_status != 'delivered'       AND @new_status = 'cancelled'          SET @valid_transition = 1;

        IF @valid_transition = 0
        BEGIN
            SET @message = 'ERROR: Invalid status transition from "' +
                           @old_status + '" to "' + @new_status + '".';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update order status
        UPDATE [ORDER]
        SET order_status = @new_status
        WHERE order_id = @order_id;

        -- If delivered ? mark payment as completed
        IF @new_status = 'delivered'
            UPDATE PAYMENT
            SET payment_status = 'completed'
            WHERE order_id = @order_id
              AND payment_status = 'pending';

        -- If cancelled ? mark payment as failed
        IF @new_status = 'cancelled'
            UPDATE PAYMENT
            SET payment_status = 'failed'
            WHERE order_id = @order_id
              AND payment_status = 'pending';

        COMMIT TRANSACTION;

        SET @message = 'SUCCESS: Order #' + CAST(@order_id AS VARCHAR) +
                       ' status updated from "' + @old_status +
                       '" to "' + @new_status + '".';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @message = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


-- SP 4: usp_ManageInventory

IF OBJECT_ID('dbo.usp_ManageInventory', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ManageInventory;
GO

CREATE PROCEDURE dbo.usp_ManageInventory
    @order_id   INT,
    @message    VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate order exists
        IF NOT EXISTS (SELECT 1 FROM [ORDER] WHERE order_id = @order_id)
        BEGIN
            SET @message = 'ERROR: Order ID ' + CAST(@order_id AS VARCHAR) + ' does not exist.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Deduct stock for each ingredient used in this order
        UPDATE i
        SET i.current_stock = i.current_stock -
            (oi.quantity * r.quantity_required)
        FROM INGREDIENT i
        JOIN RECIPE r       ON i.ingredient_id = r.ingredient_id
        JOIN ORDER_ITEM oi  ON r.item_id        = oi.item_id
        WHERE oi.order_id = @order_id;

        -- Prevent negative stock
        IF EXISTS (
            SELECT 1 FROM INGREDIENT WHERE current_stock < 0
        )
        BEGIN
            SET @message = 'ERROR: Insufficient stock for one or more ingredients. Transaction rolled back.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        COMMIT TRANSACTION;

        -- Report any low stock warnings after deduction
        DECLARE @low_stock_warning VARCHAR(500) = '';

        SELECT @low_stock_warning = @low_stock_warning +
               '| LOW STOCK: ' + i.ingredient_name +
               ' (Current: ' + CAST(i.current_stock AS VARCHAR) +
               ', Threshold: ' + CAST(i.minimum_threshold AS VARCHAR) + ') '
        FROM INGREDIENT i
        JOIN RECIPE r       ON i.ingredient_id = r.ingredient_id
        JOIN ORDER_ITEM oi  ON r.item_id        = oi.item_id
        WHERE oi.order_id   = @order_id
          AND i.current_stock < i.minimum_threshold;

        IF @low_stock_warning = ''
            SET @message = 'SUCCESS: Inventory updated for Order #' + CAST(@order_id AS VARCHAR) + '. All stock levels healthy.';
        ELSE
            SET @message = 'SUCCESS: Inventory updated for Order #' + CAST(@order_id AS VARCHAR) + '. WARNINGS: ' + @low_stock_warning;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @message = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


-- SP 8: usp_CheckLowStockIngredients

IF OBJECT_ID('dbo.usp_CheckLowStockIngredients', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CheckLowStockIngredients;
GO

CREATE PROCEDURE dbo.usp_CheckLowStockIngredients
    @supplier_id    INT         = NULL,     -- Optional filter by supplier
    @message        VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SELECT
            i.ingredient_id,
            i.ingredient_name,
            i.unit_of_measurement,
            i.current_stock,
            i.minimum_threshold,
            i.minimum_threshold - i.current_stock   AS reorder_quantity_needed,
            i.shelf_life_days,
            v.vendor_name                           AS supplier_name,
            v.phone_number                          AS supplier_phone,
            v.email                                 AS supplier_email,
            s.contact_person,
            STRING_AGG(mi.item_name, ', ')          AS affected_menu_items
        FROM INGREDIENT i
        JOIN SUPPLIER s     ON i.supplier_id    = s.supplier_id
        JOIN VENDOR v       ON s.supplier_id    = v.vendor_id
        JOIN RECIPE r       ON i.ingredient_id  = r.ingredient_id
        JOIN MENU_ITEM mi   ON r.item_id        = mi.item_id
        WHERE i.current_stock < i.minimum_threshold
          AND (@supplier_id IS NULL OR i.supplier_id = @supplier_id)
        GROUP BY
            i.ingredient_id,
            i.ingredient_name,
            i.unit_of_measurement,
            i.current_stock,
            i.minimum_threshold,
            i.shelf_life_days,
            v.vendor_name,
            v.phone_number,
            v.email,
            s.contact_person
        ORDER BY
            (i.minimum_threshold - i.current_stock) DESC;

        DECLARE @low_count INT;
        SELECT @low_count = COUNT(*)
        FROM INGREDIENT
        WHERE current_stock < minimum_threshold
          AND (@supplier_id IS NULL OR supplier_id = @supplier_id);

        IF @low_count = 0
            SET @message = 'All ingredient stock levels are healthy.';
        ELSE
            SET @message = CAST(@low_count AS VARCHAR) + ' ingredient(s) below minimum threshold. Reorder required.';

    END TRY
    BEGIN CATCH
        SET @message = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


-- SP 9: usp_AddVendor

IF OBJECT_ID('dbo.usp_AddVendor', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddVendor;
GO

CREATE PROCEDURE dbo.usp_AddVendor
    @vendor_name        VARCHAR(100),
    @phone_number       VARCHAR(15),
    @email              VARCHAR(150),
    @vendor_type        VARCHAR(20),
    -- Supplier specific
    @contact_person     VARCHAR(100)    = NULL,
    -- Delivery partner specific
    @commission_rate    DECIMAL(5,2)    = NULL,
    @service_area       VARCHAR(200)    = NULL,
    @rating             DECIMAL(3,2)    = NULL,
    -- Output
    @new_vendor_id      INT             OUTPUT,
    @message            VARCHAR(255)    OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate vendor_type
        IF @vendor_type NOT IN ('supplier', 'delivery_partner')
        BEGIN
            SET @message = 'ERROR: vendor_type must be either "supplier" or "delivery_partner".';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate phone uniqueness
        IF EXISTS (SELECT 1 FROM VENDOR WHERE phone_number = @phone_number)
        BEGIN
            SET @message = 'ERROR: Phone number ' + @phone_number + ' already exists in the system.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate email uniqueness
        IF EXISTS (SELECT 1 FROM VENDOR WHERE email = @email)
        BEGIN
            SET @message = 'ERROR: Email ' + @email + ' already exists in the system.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate subtype-specific required fields
        IF @vendor_type = 'delivery_partner'
           AND (@commission_rate IS NULL OR @service_area IS NULL)
        BEGIN
            SET @message = 'ERROR: commission_rate and service_area are required for delivery partners.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insert into VENDOR supertype
        INSERT INTO VENDOR (vendor_name, phone_number, email, vendor_type)
        VALUES (@vendor_name, @phone_number, @email, @vendor_type);

        SET @new_vendor_id = SCOPE_IDENTITY();

        -- Insert into appropriate subtype
        IF @vendor_type = 'supplier'
        BEGIN
            INSERT INTO SUPPLIER (supplier_id, contact_person)
            VALUES (@new_vendor_id, @contact_person);
        END
        ELSE IF @vendor_type = 'delivery_partner'
        BEGIN
            INSERT INTO DELIVERY_PARTNER (partner_id, commission_rate, service_area, rating)
            VALUES (@new_vendor_id, @commission_rate, @service_area, @rating);
        END

        COMMIT TRANSACTION;

        SET @message = 'SUCCESS: New ' + @vendor_type + ' "' + @vendor_name +
                       '" added with Vendor ID ' + CAST(@new_vendor_id AS VARCHAR) + '.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @new_vendor_id = NULL;
        SET @message = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


-- SP 10: usp_AddMenuItem

IF OBJECT_ID('dbo.usp_AddMenuItem', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddMenuItem;
GO

CREATE PROCEDURE dbo.usp_AddMenuItem
    @brand_id               INT,
    @item_name              VARCHAR(100),
    @description            TEXT            = NULL,
    @price                  DECIMAL(10,2),
    @category               VARCHAR(50),
    @preparation_time       INT,
    @dietary_tags           VARCHAR(200)    = NULL,
    -- Optional recipe ingredients (up to 3 for simplicity)
    @ingredient1_id         INT             = NULL,
    @ingredient1_qty        DECIMAL(10,2)   = NULL,
    @ingredient2_id         INT             = NULL,
    @ingredient2_qty        DECIMAL(10,2)   = NULL,
    @ingredient3_id         INT             = NULL,
    @ingredient3_qty        DECIMAL(10,2)   = NULL,
    -- Output
    @new_item_id            INT             OUTPUT,
    @message                VARCHAR(255)    OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate brand exists and is active
        IF NOT EXISTS (SELECT 1 FROM BRAND WHERE brand_id = @brand_id AND active_status = 1)
        BEGIN
            SET @message = 'ERROR: Brand ID ' + CAST(@brand_id AS VARCHAR) + ' does not exist or is inactive.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate price
        IF @price <= 0
        BEGIN
            SET @message = 'ERROR: Price must be greater than 0.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate preparation time
        IF @preparation_time <= 0
        BEGIN
            SET @message = 'ERROR: Preparation time must be greater than 0.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validate ingredient IDs if provided
        IF @ingredient1_id IS NOT NULL AND
           NOT EXISTS (SELECT 1 FROM INGREDIENT WHERE ingredient_id = @ingredient1_id)
        BEGIN
            SET @message = 'ERROR: Ingredient ID ' + CAST(@ingredient1_id AS VARCHAR) + ' does not exist.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @ingredient2_id IS NOT NULL AND
           NOT EXISTS (SELECT 1 FROM INGREDIENT WHERE ingredient_id = @ingredient2_id)
        BEGIN
            SET @message = 'ERROR: Ingredient ID ' + CAST(@ingredient2_id AS VARCHAR) + ' does not exist.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @ingredient3_id IS NOT NULL AND
           NOT EXISTS (SELECT 1 FROM INGREDIENT WHERE ingredient_id = @ingredient3_id)
        BEGIN
            SET @message = 'ERROR: Ingredient ID ' + CAST(@ingredient3_id AS VARCHAR) + ' does not exist.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insert MENU_ITEM
        INSERT INTO MENU_ITEM (
            brand_id, item_name, [description], price,
            category, preparation_time, available, dietary_tags
        )
        VALUES (
            @brand_id, @item_name, @description, @price,
            @category, @preparation_time, 1, @dietary_tags
        );

        SET @new_item_id = SCOPE_IDENTITY();

        -- Insert RECIPE rows if ingredients provided
        IF @ingredient1_id IS NOT NULL AND @ingredient1_qty IS NOT NULL
            INSERT INTO RECIPE (item_id, ingredient_id, quantity_required)
            VALUES (@new_item_id, @ingredient1_id, @ingredient1_qty);

        IF @ingredient2_id IS NOT NULL AND @ingredient2_qty IS NOT NULL
            INSERT INTO RECIPE (item_id, ingredient_id, quantity_required)
            VALUES (@new_item_id, @ingredient2_id, @ingredient2_qty);

        IF @ingredient3_id IS NOT NULL AND @ingredient3_qty IS NOT NULL
            INSERT INTO RECIPE (item_id, ingredient_id, quantity_required)
            VALUES (@new_item_id, @ingredient3_id, @ingredient3_qty);

        COMMIT TRANSACTION;

        SET @message = 'SUCCESS: Menu item "' + @item_name +
                       '" added with Item ID ' + CAST(@new_item_id AS VARCHAR) +
                       ' under Brand ID ' + CAST(@brand_id AS VARCHAR) + '.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @new_item_id = NULL;
        SET @message = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


-- SECTION 4: TRIGGERS
-- TRIGGER SETUP: ORDER_AUDIT table

IF OBJECT_ID('ORDER_AUDIT', 'U') IS NOT NULL
    DROP TABLE ORDER_AUDIT;
GO

CREATE TABLE ORDER_AUDIT (
    audit_id        INT IDENTITY(1,1)   NOT NULL,
    order_id        INT                 NOT NULL,
    old_status      VARCHAR(20)         NOT NULL,
    new_status      VARCHAR(20)         NOT NULL,
    changed_at      DATETIME            NOT NULL DEFAULT GETDATE(),
    changed_by      VARCHAR(100)        NOT NULL DEFAULT SYSTEM_USER,
    CONSTRAINT PK_ORDER_AUDIT PRIMARY KEY (audit_id)
);
GO


-- TRIGGER 1: trg_OrderStatusAudit
-- Fires: AFTER UPDATE on ORDER

IF OBJECT_ID('dbo.trg_OrderStatusAudit', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_OrderStatusAudit;
GO

CREATE TRIGGER dbo.trg_OrderStatusAudit
ON [ORDER]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only fire if order_status actually changed
    IF UPDATE(order_status)
    BEGIN
        INSERT INTO ORDER_AUDIT (order_id, old_status, new_status, changed_at, changed_by)
        SELECT
            i.order_id,
            d.order_status  AS old_status,
            i.order_status  AS new_status,
            GETDATE(),
            SYSTEM_USER
        FROM inserted i
        JOIN deleted d ON i.order_id = d.order_id
        WHERE i.order_status <> d.order_status;
    END
END;
GO


-- TRIGGER 2: trg_PreventUnavailableOrderItem
-- Fires: INSTEAD OF INSERT on ORDER_ITEM

IF OBJECT_ID('dbo.trg_PreventUnavailableOrderItem', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_PreventUnavailableOrderItem;
GO

CREATE TRIGGER dbo.trg_PreventUnavailableOrderItem
ON ORDER_ITEM
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if any inserted item is unavailable
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN MENU_ITEM mi ON i.item_id = mi.item_id
        WHERE mi.available = 0
    )
    BEGIN
        DECLARE @unavailable_items VARCHAR(500) = '';

        SELECT @unavailable_items = @unavailable_items + mi.item_name + ', '
        FROM inserted i
        JOIN MENU_ITEM mi ON i.item_id = mi.item_id
        WHERE mi.available = 0;

        RAISERROR('ORDER BLOCKED: The following items are currently unavailable: %s', 16, 1, @unavailable_items);
        RETURN;
    END

    -- All items available — proceed with insert
    INSERT INTO ORDER_ITEM (order_id, item_id, quantity, item_price, customization_notes)
    SELECT order_id, item_id, quantity, item_price, customization_notes
    FROM inserted;
END;
GO


-- TRIGGER 3: trg_AutoUpdateMenuAvailability
-- Fires: AFTER UPDATE on INGREDIENT

IF OBJECT_ID('dbo.trg_AutoUpdateMenuAvailability', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AutoUpdateMenuAvailability;
GO

CREATE TRIGGER dbo.trg_AutoUpdateMenuAvailability
ON INGREDIENT
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only fire if current_stock was updated
    IF UPDATE(current_stock)
    BEGIN
        -- Find ingredients that have just dropped below threshold
        -- and mark all affected menu items as unavailable
        UPDATE mi
        SET mi.available = 0
        FROM MENU_ITEM mi
        JOIN RECIPE r       ON mi.item_id       = r.item_id
        JOIN inserted i     ON r.ingredient_id  = i.ingredient_id
        JOIN deleted d      ON i.ingredient_id  = d.ingredient_id
        WHERE i.current_stock   < i.minimum_threshold
          AND d.current_stock   >= d.minimum_threshold;  -- only when crossing threshold, not already below

        -- Restore availability if stock was replenished above threshold
        UPDATE mi
        SET mi.available = 1
        FROM MENU_ITEM mi
        JOIN RECIPE r       ON mi.item_id       = r.item_id
        JOIN inserted i     ON r.ingredient_id  = i.ingredient_id
        JOIN deleted d      ON i.ingredient_id  = d.ingredient_id
        WHERE i.current_stock   >= i.minimum_threshold
          AND d.current_stock   < d.minimum_threshold;  -- only when restocking above threshold
    END
END;
GO


/*
-- SAMPLE EXECUTION — for testing and demonstration

-- Test SP9: Add a new supplier vendor
DECLARE @vid INT, @msg VARCHAR(255);
EXEC dbo.usp_AddVendor
    @vendor_name     = 'OrganicRoots Supply',
    @phone_number    = '617-321-9876',
    @email           = 'contact@organicroots.com',
    @vendor_type     = 'supplier',
    @contact_person  = 'Angela Torres',
    @new_vendor_id   = @vid OUTPUT,
    @message         = @msg OUTPUT;
SELECT @vid AS new_vendor_id, @msg AS message;
GO

-- Test SP10: Add a new menu item with recipe
DECLARE @iid INT, @msg VARCHAR(255);
EXEC dbo.usp_AddMenuItem
    @brand_id           = 1,
    @item_name          = 'Smoky BBQ Burger',
    @description        = 'Beef patty with smoky BBQ sauce',
    @price              = 11.99,
    @category           = 'Main',
    @preparation_time   = 15,
    @dietary_tags       = NULL,
    @ingredient1_id     = 1,
    @ingredient1_qty    = 0.25,
    @ingredient2_id     = 2,
    @ingredient2_qty    = 0.05,
    @new_item_id        = @iid OUTPUT,
    @message            = @msg OUTPUT;
SELECT @iid AS new_item_id, @msg AS message;
GO

-- Test SP1: Place a new order using TABLE TYPE parameter
-- Step 1: Declare a variable of the custom type
-- Step 2: Insert items into it
-- Step 3: Pass it to the procedure as @items
DECLARE @oid INT, @total DECIMAL(10,2), @msg VARCHAR(255);
DECLARE @orderItems OrderItemType;

INSERT INTO @orderItems (item_id, quantity, item_price) VALUES
(1, 1, 9.99),   -- Classic Cheeseburger
(2, 1, 3.99);   -- Crispy Fries

EXEC dbo.usp_PlaceOrder
    @customer_id           = 1,
    @brand_id              = 1,
    @partner_id            = 6,
    @platform_source       = 'Direct',
    @special_instructions  = 'Ring doorbell twice',
    @payment_method        = 'online',
    @items                 = @orderItems,
    @new_order_id          = @oid OUTPUT,
    @total_amount          = @total OUTPUT,
    @message               = @msg OUTPUT;
SELECT @oid AS new_order_id, @total AS total_amount, @msg AS message;
GO

-- Test SP2: Update order status
DECLARE @old VARCHAR(20), @msg VARCHAR(255);
EXEC dbo.usp_UpdateOrderStatus
    @order_id    = 20,
    @new_status  = 'preparing',
    @old_status  = @old OUTPUT,
    @message     = @msg OUTPUT;
SELECT @old AS old_status, @msg AS message;
GO

-- Test SP4: Manage inventory for order
DECLARE @msg VARCHAR(255);
EXEC dbo.usp_ManageInventory
    @order_id = 20,
    @message  = @msg OUTPUT;
SELECT @msg AS message;
GO

-- Test SP8: Check low stock ingredients
DECLARE @msg VARCHAR(255);
EXEC dbo.usp_CheckLowStockIngredients
    @supplier_id = NULL,
    @message     = @msg OUTPUT;
SELECT @msg AS message;
GO

-- View all audit logs
SELECT * FROM ORDER_AUDIT ORDER BY changed_at DESC;
GO

-- Check pipeline
SELECT * FROM vw_OrderStatusPipeline;
GO

-- Check low stock
SELECT * FROM vw_LowStockIngredientSummary;
GO

-- Check top items
SELECT TOP 5 * FROM vw_TopPerformingMenuItems ORDER BY sales_rank;
GO
*/