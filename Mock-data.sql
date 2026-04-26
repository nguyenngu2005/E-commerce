-- 1. Users (100k dòng) - OK
INSERT INTO users (username, email)
SELECT 'user_' || i, 'user_' || i || '@gmail.com'
FROM generate_series(1, 100000) AS s(i);

-- 2. Products (50k dòng) - OK
INSERT INTO products (product_name, price, category)
SELECT 'product_' || i, (random() * 1000)::numeric(10,2),
    CASE WHEN i % 3 = 0 THEN 'phone' WHEN i % 3 = 1 THEN 'laptop' ELSE 'accessory' END
FROM generate_series(1, 50000) AS s(i);

-- 3. Orders (3 triệu dòng) - Chỉnh lại cách lấy User_ID
INSERT INTO orders (user_id, order_date, total_amount)
SELECT 
    floor(random() * 100000 + 1)::int, -- Đảm bảo khớp với 100k users
    '2024-01-01'::timestamp + (random() * interval '729 days'), 
    (random() * 5000)::numeric(10,2)
FROM generate_series(1, 3000000);

-- 4. Order Items (10 triệu dòng) - Chỉnh lại cách lấy Order_ID
INSERT INTO order_items (order_id, product_id, quantity, price_unit)
SELECT 
    floor(random() * 3000000 + 1)::int, -- Khớp với 3 triệu orders vừa tạo
    floor(random() * 50000 + 1)::int,   -- Khớp với 50k products
    (random() * 5)::int + 1,
    (random() * 1000)::numeric(10,2)
FROM generate_series(1, 10000000);
