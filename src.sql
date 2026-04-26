-- Users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10, 2),
    category VARCHAR(50)
);

-- Orders (Partition)
CREATE TABLE orders (
    order_id SERIAL,
    user_id INT,
    order_date TIMESTAMP,
    total_amount DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (order_date);

-- Partition
CREATE TABLE orders_2024 PARTITION OF orders
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE orders_2025 PARTITION OF orders
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Order Items
CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price_unit DECIMAL(10, 2)
);
