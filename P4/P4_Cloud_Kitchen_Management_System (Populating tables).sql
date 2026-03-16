-- ============================================
-- Cloud Kitchen Management System
-- INSERT Script | DAMG 6210 | Group 5
-- ============================================

USE CloudKitchenDB;
GO


-- VENDOR

INSERT INTO VENDOR (vendor_name, phone_number, email, vendor_type) VALUES
('FreshFarm Supplies',   '617-111-2233', 'contact@freshfarm.com',    'supplier'),
('GreenLeaf Produce',    '617-222-3344', 'info@greenleaf.com',       'supplier'),
('DairyDirect Co.',      '617-333-4455', 'hello@dairydirect.com',    'supplier'),
('SpicePath Wholesale',  '617-444-5566', 'orders@spicepath.com',     'supplier'),
('OceanCatch Seafood',   '617-555-6677', 'supply@oceancatch.com',    'supplier'),
('SwiftDash Delivery',   '617-666-7788', 'ops@swiftdash.com',        'delivery_partner'),
('QuickMove Logistics',  '617-777-8899', 'support@quickmove.com',    'delivery_partner'),
('FastLane Couriers',    '617-888-9900', 'hello@fastlane.com',       'delivery_partner'),
('RapidRun Delivery',    '617-999-0011', 'contact@rapidrun.com',     'delivery_partner'),
('CityHop Express',      '617-100-1122', 'info@cityhop.com',         'delivery_partner');
GO


-- SUPPLIER

INSERT INTO SUPPLIER (supplier_id, contact_person) VALUES
(1, 'James Carter'),
(2, 'Linda Nguyen'),
(3, 'Robert Singh'),
(4, 'Priya Patel'),
(5, 'Michael Chen');
GO


-- DELIVERY_PARTNER

INSERT INTO DELIVERY_PARTNER (partner_id, commission_rate, service_area, rating) VALUES
(6,  12.50, 'Downtown Boston',          4.7),
(7,  10.00, 'Cambridge and Somerville', 4.5),
(8,  15.00, 'Back Bay and South End',   4.3),
(9,  11.00, 'Allston and Brighton',     4.6),
(10, 13.50, 'Fenway and Kenmore',       4.4);
GO


-- CUSTOMER

INSERT INTO CUSTOMER (customer_name, phone_number, email, loyalty_points) VALUES
('Omisha Sharma',    '857-201-3344', 'omisha@gmail.com',  150),
('Raj Patel',        '857-202-4455', 'raj@gmail.com',     200),
('Emily Clarke',     '857-203-5566', 'emily@gmail.com',   50),
('Kevin Brooks',     '857-204-6677', 'kevin@gmail.com',   300),
('Aisha Rahman',     '857-205-7788', 'aisha@gmail.com',   75),
('Daniel Kim',       '857-206-8899', 'daniel@gmail.com',  120),
('Sofia Morales',    '857-207-9900', 'sofia@gmail.com',   90),
('Liam Johnson',     '857-208-0011', 'liam@gmail.com',    60),
('Priya Nair',       '857-209-1122', 'priya@gmail.com',   180),
('Tyler Washington', '857-210-2233', 'tyler@gmail.com',   220);
GO


-- ADDRESS

INSERT INTO ADDRESS (customer_id, street, city, [state], zip_code, is_default) VALUES
(1,  '123 Huntington Ave', 'Boston',     'MA', '02115', 1),
(2,  '456 Comm Ave',       'Boston',     'MA', '02134', 1),
(3,  '789 Mass Ave',       'Cambridge',  'MA', '02139', 1),
(4,  '321 Beacon St',      'Boston',     'MA', '02116', 1),
(5,  '654 Tremont St',     'Boston',     'MA', '02118', 1),
(6,  '987 Boylston St',    'Boston',     'MA', '02215', 1),
(7,  '111 Harvard St',     'Cambridge',  'MA', '02138', 1),
(8,  '222 Broadway',       'Somerville', 'MA', '02145', 1),
(9,  '333 Washington St',  'Boston',     'MA', '02108', 1),
(10, '444 Newbury St',     'Boston',     'MA', '02115', 1);
GO


-- BRAND

INSERT INTO BRAND (brand_name, cuisine_type, active_status, [description]) VALUES
('Burger Haven',    'American',      1, 'Gourmet burgers and fries'),
('Pasta Palace',    'Italian',       1, 'Handmade pastas and risottos'),
('Wok & Roll',      'Asian',         1, 'Pan-Asian stir fry and noodles'),
('Spice Garden',    'Indian',        1, 'Authentic Indian curries and breads'),
('Green Bowl',      'Healthy',       1, 'Salads, grain bowls and smoothies'),
('Taco Fiesta',     'Mexican',       1, 'Tacos, burritos and quesadillas'),
('Sushi Spot',      'Japanese',      1, 'Fresh sushi rolls and ramen'),
('The Grill House', 'BBQ',           1, 'Smoked meats and classic BBQ sides'),
('Pita & More',     'Mediterranean', 1, 'Wraps, hummus and mezze platters'),
('Sweet Tooth',     'Desserts',      1, 'Cakes, waffles and dessert bowls');
GO


-- MENU_ITEM

INSERT INTO MENU_ITEM (brand_id, item_name, [description], price, category, preparation_time, available, dietary_tags) VALUES
(1,  'Classic Cheeseburger',   'Beef patty with cheddar',         9.99,  'Main',      12, 1, NULL),
(1,  'Crispy Fries',           'Seasoned golden fries',           3.99,  'Side',      8,  1, 'vegan'),
(2,  'Spaghetti Bolognese',    'Slow cooked meat sauce',          13.99, 'Main',      18, 1, NULL),
(2,  'Garlic Bread',           'Toasted with herb butter',        4.99,  'Side',      6,  1, 'vegetarian'),
(3,  'Chicken Fried Rice',     'Wok tossed with vegetables',      11.99, 'Main',      15, 1, NULL),
(4,  'Butter Chicken',         'Creamy tomato curry',             14.99, 'Main',      20, 1, 'gluten-free'),
(5,  'Quinoa Power Bowl',      'Quinoa, avocado, greens',         12.99, 'Main',      10, 1, 'vegan,gluten-free'),
(6,  'Beef Tacos',             'Three tacos with salsa',          10.99, 'Main',      12, 1, NULL),
(7,  'Salmon Sushi Roll',      'Fresh salmon and cucumber',       15.99, 'Main',      20, 1, 'gluten-free'),
(8,  'BBQ Ribs Platter',       'Slow smoked pork ribs',           18.99, 'Main',      30, 1, NULL),
(9,  'Falafel Wrap',           'Crispy falafel in pita',          10.99, 'Main',      12, 1, 'vegan'),
(10, 'Chocolate Lava Cake',    'Warm chocolate cake',             7.99,  'Dessert',   15, 1, 'vegetarian'),
(3,  'Vegetable Spring Rolls', 'Crispy rolls with dipping sauce', 6.99,  'Appetizer', 10, 1, 'vegan'),
(4,  'Garlic Naan',            'Freshly baked flatbread',         2.99,  'Side',      8,  1, 'vegetarian'),
(5,  'Green Detox Smoothie',   'Spinach, banana, almond milk',    6.99,  'Drink',     5,  1, 'vegan,gluten-free');
GO


-- INGREDIENT

INSERT INTO INGREDIENT (supplier_id, ingredient_name, unit_of_measurement, current_stock, minimum_threshold, shelf_life_days) VALUES
(1, 'Beef Patty',       'kg',     50.00,  10.00, 3),
(1, 'Cheddar Cheese',   'kg',     20.00,  5.00,  14),
(2, 'Spaghetti',        'kg',     40.00,  8.00,  365),
(2, 'Tomato Sauce',     'liters', 30.00,  6.00,  7),
(3, 'Chicken Breast',   'kg',     60.00,  12.00, 3),
(3, 'Heavy Cream',      'liters', 15.00,  3.00,  7),
(4, 'Basmati Rice',     'kg',     80.00,  15.00, 365),
(4, 'Garam Masala',     'kg',     10.00,  2.00,  180),
(2, 'Avocado',          'units',  100.00, 20.00, 5),
(5, 'Salmon Fillet',    'kg',     25.00,  5.00,  2),
(1, 'Pork Ribs',        'kg',     40.00,  8.00,  3),
(2, 'Chickpeas',        'kg',     35.00,  7.00,  365),
(4, 'Flour',            'kg',     100.00, 20.00, 180),
(3, 'Eggs',             'units',  200.00, 30.00, 14),
(2, 'Quinoa',           'kg',     30.00,  6.00,  365);
GO


-- KITCHEN_STATION

INSERT INTO KITCHEN_STATION (station_name, station_type, operational_status) VALUES
('Grill Station',   'Grill',        'active'),
('Salad Prep',      'Cold Prep',    'active'),
('Wok Station',     'Stir Fry',     'active'),
('Pasta Station',   'Boiling',      'active'),
('Pastry Station',  'Baking',       'active'),
('Fryer Station',   'Frying',       'active'),
('Sushi Counter',   'Cold Prep',    'active'),
('Tandoor Station', 'Baking',       'active'),
('Sauce Station',   'Preparation',  'maintenance'),
('Plating Station', 'Assembly',     'active');
GO


-- KITCHEN_STAFF

INSERT INTO KITCHEN_STAFF (staff_name, [role], current_shift, hire_date) VALUES
('Marco Rivera', 'Head Chef',      'morning',   '2021-03-15'),
('Aisha Patel',  'Sous Chef',      'morning',   '2022-01-10'),
('James Wong',   'Grill Cook',     'afternoon', '2022-06-20'),
('Sara Lee',     'Pastry Chef',    'morning',   '2021-11-05'),
('Tom Bradley',  'Prep Cook',      'afternoon', '2023-02-14'),
('Nina Russo',   'Sushi Chef',     'morning',   '2022-08-30'),
('Carlos Diaz',  'Line Cook',      'night',     '2023-05-01'),
('Fatima Hassan','Sous Chef',      'night',     '2021-07-22'),
('David Park',   'Wok Specialist', 'afternoon', '2022-03-18'),
('Leila Adams',  'Prep Cook',      'night',     '2023-09-10');
GO


-- ORDER

INSERT INTO [ORDER] (customer_id, brand_id, partner_id, order_datetime, order_status, total_amount, delivery_fee, platform_source, special_instructions, customer_rating, review_text, review_date) VALUES
(1,  1,  6,  '2024-01-10 12:30:00', 'delivered',      23.97, 2.99, 'Uber Eats', 'No onions please',          5, 'Amazing burgers!',       '2024-01-10'),
(2,  2,  7,  '2024-01-11 13:00:00', 'delivered',      18.98, 1.99, 'DoorDash',  NULL,                        4, 'Great pasta',            '2024-01-11'),
(3,  3,  8,  '2024-01-12 18:30:00', 'delivered',      18.98, 2.49, 'Uber Eats', 'Extra spicy',               5, 'Best fried rice ever',   '2024-01-12'),
(4,  4,  9,  '2024-01-13 19:00:00', 'delivered',      17.98, 1.99, 'Direct',    'Less salt',                 4, 'Loved the curry',        '2024-01-13'),
(5,  5,  10, '2024-01-14 11:30:00', 'delivered',      19.98, 2.99, 'Grubhub',   NULL,                        5, 'So fresh and healthy',   '2024-01-14'),
(6,  6,  6,  '2024-01-15 20:00:00', 'delivered',      10.99, 1.99, 'DoorDash',  'Add hot sauce',             3, 'Tacos were okay',        '2024-01-15'),
(7,  7,  7,  '2024-01-16 13:30:00', 'delivered',      15.99, 2.49, 'Uber Eats', NULL,                        5, 'Freshest sushi in town', '2024-01-16'),
(8,  8,  8,  '2024-01-17 18:00:00', 'delivered',      18.99, 3.99, 'Direct',    'Well done please',          4, 'Ribs were fantastic',    '2024-01-17'),
(9,  9,  9,  '2024-01-18 12:00:00', 'delivered',      10.99, 1.99, 'Grubhub',   NULL,                        5, 'Perfect falafel wrap',   '2024-01-18'),
(10, 10, 10, '2024-01-19 15:00:00', 'delivered',      7.99,  1.49, 'Uber Eats', 'Extra chocolate sauce',     4, 'Delicious lava cake',    '2024-01-19'),
(1,  3,  6,  '2024-01-20 19:30:00', 'preparing',      11.99, 2.99, 'DoorDash',  NULL,                        NULL, NULL,               NULL),
(2,  4,  7,  '2024-01-21 20:00:00', 'pending',        17.98, 1.99, 'Direct',    'No coriander',              NULL, NULL,               NULL);
GO


-- ORDER_ITEM

INSERT INTO ORDER_ITEM (order_id, item_id, quantity, item_price, customization_notes) VALUES
(1,  1,  1, 9.99,  'No onions'),
(1,  2,  2, 3.99,  NULL),
(2,  3,  1, 13.99, NULL),
(2,  4,  1, 4.99,  NULL),
(3,  5,  1, 11.99, 'Extra spicy'),
(3,  13, 1, 6.99,  NULL),
(4,  6,  1, 14.99, 'Less salt'),
(4,  14, 1, 2.99,  NULL),
(5,  7,  1, 12.99, NULL),
(5,  15, 1, 6.99,  NULL),
(6,  8,  1, 10.99, 'Add hot sauce'),
(7,  9,  1, 15.99, NULL),
(8,  10, 1, 18.99, 'Well done'),
(9,  11, 1, 10.99, NULL),
(10, 12, 1, 7.99,  'Extra chocolate sauce'),
(11, 5,  1, 11.99, NULL),
(12, 6,  1, 14.99, 'No coriander'),
(12, 14, 1, 2.99,  NULL);
GO


-- PAYMENT

INSERT INTO PAYMENT (order_id, payment_method, payment_status, payment_datetime, transaction_id, amount_paid) VALUES
(1,  'online',   'completed', '2024-01-10 12:31:00', 'TXN-10001', 26.96),
(2,  'card',     'completed', '2024-01-11 13:01:00', 'TXN-10002', 20.97),
(3,  'platform', 'completed', '2024-01-12 18:31:00', 'TXN-10003', 21.47),
(4,  'cash',     'completed', '2024-01-13 19:05:00', 'TXN-10004', 19.97),
(5,  'online',   'completed', '2024-01-14 11:31:00', 'TXN-10005', 22.97),
(6,  'card',     'completed', '2024-01-15 20:01:00', 'TXN-10006', 12.98),
(7,  'platform', 'completed', '2024-01-16 13:31:00', 'TXN-10007', 18.48),
(8,  'online',   'completed', '2024-01-17 18:01:00', 'TXN-10008', 22.98),
(9,  'card',     'completed', '2024-01-18 12:01:00', 'TXN-10009', 12.98),
(10, 'online',   'completed', '2024-01-19 15:01:00', 'TXN-10010', 9.48),
(11, 'platform', 'pending',   '2024-01-20 19:31:00', NULL,         14.98),
(12, 'cash',     'pending',   '2024-01-21 20:01:00', NULL,         19.97);
GO


-- RECIPE

INSERT INTO RECIPE (item_id, ingredient_id, quantity_required, preparation_notes) VALUES
(1,  1,  0.25, 'Grill patty to medium well'),
(1,  2,  0.05, 'Slice and place on top of patty'),
(3,  3,  0.15, 'Boil until al dente'),
(3,  4,  0.10, 'Simmer sauce for 20 minutes'),
(5,  5,  0.20, 'Dice and stir fry on high heat'),
(5,  7,  0.15, 'Cook rice separately before frying'),
(6,  5,  0.25, 'Marinate in spices for 2 hours'),
(6,  6,  0.10, 'Add cream at the end'),
(6,  8,  0.02, 'Add to sauce while simmering'),
(7,  15, 0.15, 'Cook quinoa and let cool'),
(7,  9,  0.10, 'Slice and layer on top'),
(9,  10, 0.15, 'Slice fresh and roll'),
(10, 11, 0.30, 'Smoke ribs for 4 hours at low heat'),
(11, 12, 0.10, 'Fry until golden brown'),
(12, 14, 2.00, 'Mix into batter');
GO


-- ORDER_STATION

INSERT INTO ORDER_STATION (order_id, station_id, start_time, completion_time, [status]) VALUES
(1,  1,  '2024-01-10 12:32:00', '2024-01-10 12:44:00', 'completed'),
(2,  4,  '2024-01-11 13:02:00', '2024-01-11 13:20:00', 'completed'),
(3,  3,  '2024-01-12 18:32:00', '2024-01-12 18:47:00', 'completed'),
(4,  8,  '2024-01-13 19:02:00', '2024-01-13 19:22:00', 'completed'),
(5,  2,  '2024-01-14 11:32:00', '2024-01-14 11:42:00', 'completed'),
(6,  6,  '2024-01-15 20:02:00', '2024-01-15 20:14:00', 'completed'),
(7,  7,  '2024-01-16 13:32:00', '2024-01-16 13:52:00', 'completed'),
(8,  1,  '2024-01-17 18:02:00', '2024-01-17 18:32:00', 'completed'),
(9,  6,  '2024-01-18 12:02:00', '2024-01-18 12:14:00', 'completed'),
(10, 5,  '2024-01-19 15:02:00', '2024-01-19 15:17:00', 'completed'),
(11, 3,  '2024-01-20 19:32:00', NULL,                   'in_progress'),
(12, 8,  '2024-01-21 20:02:00', NULL,                   'pending');
GO


-- STAFF_STATION

INSERT INTO STAFF_STATION (employee_id, station_id) VALUES
(1,  1),
(2,  4),
(3,  1),
(4,  5),
(5,  2),
(6,  7),
(7,  3),
(8,  8),
(9,  3),
(10, 6),
(1,  10),
(2,  9),
(3,  6),
(4,  10),
(5,  4);
GO