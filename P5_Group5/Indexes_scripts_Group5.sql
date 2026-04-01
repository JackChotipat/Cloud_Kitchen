-- ============================================
-- Cloud Kitchen Management System
-- Indexes Script | DAMG 6210 | Group 5
-- ============================================

USE CloudKitchenDB;
GO

-- NON-CLUSTERED INDEXES

-- INDEX 1: IX_ORDER_ITEM_order_id
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_ORDER_ITEM_order_id'
    AND object_id = OBJECT_ID('ORDER_ITEM')
)
    DROP INDEX IX_ORDER_ITEM_order_id ON ORDER_ITEM;
GO

CREATE NONCLUSTERED INDEX IX_ORDER_ITEM_order_id
ON ORDER_ITEM (order_id)
INCLUDE (item_id, quantity, item_price);
GO

-- Verification
SELECT
    'IX_ORDER_ITEM_order_id'    AS index_name,
    'ORDER_ITEM'                AS [table],
    'order_id'                  AS indexed_column,
    'item_id, quantity, item_price' AS included_columns,
    'SP1, SP2, SP4, vw_TopPerformingMenuItems, vw_WeeklyRevenuePerBrand' AS used_by;
GO



-- INDEX 2: IX_ORDER_order_status
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_ORDER_order_status'
    AND object_id = OBJECT_ID('[ORDER]')
)
    DROP INDEX IX_ORDER_order_status ON [ORDER];
GO

CREATE NONCLUSTERED INDEX IX_ORDER_order_status
ON [ORDER] (order_status)
INCLUDE (order_id, customer_id, brand_id, total_amount, order_datetime);
GO

-- Verification
SELECT
    'IX_ORDER_order_status'     AS index_name,
    'ORDER'                     AS [table],
    'order_status'              AS indexed_column,
    'order_id, customer_id, brand_id, total_amount, order_datetime' AS included_columns,
    'SP2, vw_WeeklyRevenuePerBrand, vw_OrderStatusPipeline, trg_OrderStatusAudit' AS used_by;
GO



-- INDEX 3: IX_ORDER_customer_id
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_ORDER_customer_id'
    AND object_id = OBJECT_ID('[ORDER]')
)
    DROP INDEX IX_ORDER_customer_id ON [ORDER];
GO

CREATE NONCLUSTERED INDEX IX_ORDER_customer_id
ON [ORDER] (customer_id)
INCLUDE (order_id, brand_id, order_status, total_amount, order_datetime);
GO

-- Verification
SELECT
    'IX_ORDER_customer_id'      AS index_name,
    'ORDER'                     AS [table],
    'customer_id'               AS indexed_column,
    'order_id, brand_id, order_status, total_amount, order_datetime' AS included_columns,
    'SP1, loyalty points update, customer reporting' AS used_by;
GO



-- INDEX 4: IX_INGREDIENT_supplier_id
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_INGREDIENT_supplier_id'
    AND object_id = OBJECT_ID('INGREDIENT')
)
    DROP INDEX IX_INGREDIENT_supplier_id ON INGREDIENT;
GO

CREATE NONCLUSTERED INDEX IX_INGREDIENT_supplier_id
ON INGREDIENT (supplier_id)
INCLUDE (ingredient_id, ingredient_name, current_stock, minimum_threshold);
GO

-- Verification
SELECT
    'IX_INGREDIENT_supplier_id' AS index_name,
    'INGREDIENT'                AS [table],
    'supplier_id'               AS indexed_column,
    'ingredient_id, ingredient_name, current_stock, minimum_threshold' AS included_columns,
    'SP8, vw_LowStockIngredientSummary, udf_IsIngredientLowStock, trg_AutoUpdateMenuAvailability' AS used_by;
GO


/*
-- INDEX SUMMARY

SELECT
    t.name          AS table_name,
    i.name          AS index_name,
    i.type_desc     AS index_type,
    STRING_AGG(c.name, ', ')
        WITHIN GROUP (ORDER BY ic.key_ordinal) AS indexed_columns
FROM sys.indexes i
JOIN sys.tables t           ON i.object_id  = t.object_id
JOIN sys.index_columns ic   ON i.object_id  = ic.object_id
                           AND i.index_id   = ic.index_id
JOIN sys.columns c          ON ic.object_id = c.object_id
                           AND ic.column_id = c.column_id
WHERE i.name IN (
    'IX_ORDER_ITEM_order_id',
    'IX_ORDER_order_status',
    'IX_ORDER_customer_id',
    'IX_INGREDIENT_supplier_id'
)
AND ic.is_included_column = 0
GROUP BY t.name, i.name, i.type_desc
ORDER BY t.name;
GO
*/