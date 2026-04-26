-- 1. Nạp Users (100,000 dòng)
INSERT INTO users (username, email)
SELECT 
    'user_' || i, 
    'user_' || i || '@gmail.com'
FROM generate_series(1, 100000) AS s(i);

-- 2. Nạp Products (50,000 dòng)
INSERT INTO products (product_name, price, category)
SELECT 
    'product_' || i, 
    (random() * 1000)::numeric(10,2),
    CASE 
        WHEN i % 3 = 0 THEN 'phone'
        WHEN i % 3 = 1 THEN 'laptop'
        ELSE 'accessory'
    END
FROM generate_series(1, 50000) AS s(i);

-- 3. Nạp Orders (3,500,000 dòng)
INSERT INTO orders (user_id, order_date, total_amount)
SELECT 
    floor(random() * 100000 + 1)::int, 
    '2024-01-01'::timestamp + (random() * interval '729 days'), 
    (random() * 5000)::numeric(10,2)
FROM generate_series(1, 3500000);

-- 4. Nạp Order Items (15,000,000 dòng)
-- Lưu ý: Lệnh này sẽ mất vài phút để thực thi
INSERT INTO order_items (order_id, product_id, quantity, price_unit)
SELECT 
    floor(random() * 3500000 + 1)::int, 
    floor(random() * 50000 + 1)::int,
    (random() * 5)::int + 1,
    (random() * 1000)::numeric(10,2)
FROM generate_series(1, 15000000);
