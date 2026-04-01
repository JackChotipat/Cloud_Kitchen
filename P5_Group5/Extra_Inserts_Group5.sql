-- ============================================
-- Cloud Kitchen Management System
-- Supplementary INSERT Script | DAMG 6210 | Group 5

USE CloudKitchenDB;
GO
-- 1. ADDITIONAL ADDRESSES
INSERT INTO ADDRESS (customer_id, street, city, [state], zip_code, is_default) VALUES
(1,  '88 St. Botolph St',   'Boston',    'MA', '02116', 0),  -- Omisha second address
(3,  '45 Inman St',         'Cambridge', 'MA', '02139', 0),  -- Emily second address
(5,  '200 Ruggles St',      'Boston',    'MA', '02120', 0);  -- Aisha second address
GO


-- 2. ADDITIONAL ORDERS

INSERT INTO [ORDER] (customer_id, brand_id, partner_id, order_datetime, order_status, total_amount, delivery_fee, platform_source, special_instructions, customer_rating, review_text, review_date) VALUES
(3,  1,  8,  '2024-02-01 13:00:00', 'out_for_delivery', 13.98, 2.49, 'Uber Eats',  'Extra ketchup',         NULL, NULL,                       NULL),
(7,  5,  10, '2024-02-02 14:30:00', 'out_for_delivery', 19.98, 2.99, 'Grubhub',    NULL,                    NULL, NULL,                       NULL),
(2,  6,  7,  '2024-02-03 18:00:00', 'cancelled',        10.99, 1.99, 'DoorDash',   'Change of mind',        NULL, NULL,                       NULL),
(9,  3,  9,  '2024-02-04 19:30:00', 'cancelled',        11.99, 2.49, 'Uber Eats',  NULL,                    NULL, NULL,                       NULL),
(4,  7,  6,  '2024-02-05 12:00:00', 'delivered',        15.99, 2.49, 'Direct',     NULL,                    2,    'Roll was falling apart',   '2024-02-05'),
(6,  2,  8,  '2024-02-06 20:00:00', 'delivered',        18.98, 1.99, 'DoorDash',   'No garlic please',      5,    'Absolutely loved it',      '2024-02-06'),
(10, 4,  10, '2024-02-07 11:00:00', 'pending',          17.98, 1.99, 'Grubhub',    'Less spice',            NULL, NULL,                       NULL);
GO


-- 3. ORDER ITEMS FOR NEW ORDERS
INSERT INTO ORDER_ITEM (order_id, item_id, quantity, item_price, customization_notes) VALUES
(13, 1,  1, 9.99,  'Extra ketchup'),
(13, 2,  1, 3.99,  NULL),
(14, 7,  1, 12.99, NULL),
(14, 15, 1, 6.99,  NULL),
(15, 8,  1, 10.99, NULL),
(16, 5,  1, 11.99, NULL),
(17, 9,  1, 15.99, NULL),
(18, 3,  1, 13.99, 'No garlic please'),
(18, 4,  1, 4.99,  NULL),
(19, 6,  1, 14.99, 'Less spice'),
(19, 14, 1, 2.99,  NULL);
GO


-- 4. PAYMENTS FOR NEW ORDERS
INSERT INTO PAYMENT (order_id, payment_method, payment_status, payment_datetime, transaction_id, amount_paid) VALUES
(13, 'platform', 'completed', '2024-02-01 13:01:00', 'TXN-10011', 16.47),
(14, 'online',   'completed', '2024-02-02 14:31:00', 'TXN-10012', 22.97),
(17, 'card',     'refunded',  '2024-02-05 15:00:00', 'TXN-10013', 18.48),
(18, 'online',   'failed',    '2024-02-06 20:01:00', 'TXN-10014', 20.97),
(19, 'cash',     'pending',   '2024-02-07 11:01:00', NULL,         19.97);
GO


-- 5. UPDATED INGREDIENT STOCK (below minimum_threshold)
UPDATE INGREDIENT
SET current_stock = 7.50
WHERE ingredient_id = 1;

UPDATE INGREDIENT
SET current_stock = 1.80
WHERE ingredient_id = 6;

UPDATE INGREDIENT
SET current_stock = 2.00
WHERE ingredient_id = 10;
GO


-- 6. ORDER_STATION ROWS FOR NEW ACTIVE ORDERS
INSERT INTO ORDER_STATION (order_id, station_id, start_time, completion_time, [status]) VALUES
(13, 1,  '2024-02-01 13:02:00', '2024-02-01 13:14:00', 'completed'),
(14, 2,  '2024-02-02 14:32:00', '2024-02-02 14:42:00', 'completed'),
(17, 7,  '2024-02-05 12:02:00', '2024-02-05 12:22:00', 'completed'),
(18, 4,  '2024-02-06 20:02:00', '2024-02-06 20:20:00', 'completed');
GO