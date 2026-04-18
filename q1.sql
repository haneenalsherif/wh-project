CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    store_id INTEGER REFERENCES stores(id)
);

**************************************************************
INSERT INTO categories (name, store_id) VALUES
('مشروبات', 1),
('مأكولات', 1),
('حلويات', 1),

('أدوية السعال', 2),
('غسول', 2),
('مضاد حيوي', 2),
('أطفال', 2),
('الجهاز الهضمي', 2);
**************************************************************

SELECT * FROM categories;

ALTER TABLE products
ADD COLUMN category_id INTEGER REFERENCES categories(id);


UPDATE products SET category_id = 1 WHERE store_id = 1 AND name IN ('آيس لاتيه', 'فرابتشينو');
UPDATE products SET category_id = 2 WHERE store_id = 1 AND name IN ('لازانيا');
UPDATE products SET category_id = 3 WHERE store_id = 1 AND name IN ('تشيز كيك');

UPDATE products SET category_id = 4 WHERE store_id = 2 AND name IN ('شراب سعال');
UPDATE products SET category_id = 5 WHERE store_id = 2 AND name IN ('غسول طبي');
UPDATE products SET category_id = 6 WHERE store_id = 2 AND name IN ('مضاد حيوي A', 'مضاد حيوي B', 'مضاد حيوي C');
UPDATE products SET category_id = 7 WHERE store_id = 2 AND name IN ('باراسيتامول أطفال', 'خافض حرارة للأطفال', 'شراب آلام الأطفال');
UPDATE products SET category_id = 8 WHERE store_id = 2 AND name IN ('دواء معدة', 'مضاد حموضة', 'حبوب هضم');


INSERT INTO products (name, description, price, image, store_id, category_id) VALUES
('قهوة ساخنة', 'قهوة دافئة بطعم غني وهادئ.', 8.00, 'images/dolce2.jpg.jpg', 1, 1),
('لازانيا', 'طبق ساخن غني بالجبن والصلصة.', 18.00, 'images/dolce4.jpg.jpg', 1, 2),
('بيتزا', 'بيتزا طازجة بمكونات شهية.', 20.00, 'images/dolce5.jpg.jpg', 1, 2),
('سندوتش خفيف', 'وجبة خفيفة وسريعة مناسبة في أي وقت.', 14.00, 'images/dolce6.jpg.jpg', 1, 2),
('كيك شوكولاتة', 'كيك غني بطبقات الشوكولاتة الطرية.', 12.00, 'images/dolce7.jpg.jpg', 1, 3),
('حلو اليوم', 'قطعة حلو خاصة بتقديم أنيق.', 9.00, 'images/dolce9.jpg.jpg', 1, 3);


SELECT * FROM categories WHERE store_id = 2;





INSERT INTO categories (name, store_id)
VALUES ('المسكنات وخافض الحرارة كبار', 2);


SELECT * FROM categories WHERE store_id = 2;



UPDATE products
SET category_id = 9
WHERE store_id = 2
AND name IN ('باراسيتامول', 'إيبوبروفين', 'شرائط لاصقة مسكنة');


CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(30) NOT NULL,
    customer_address TEXT NOT NULL,
    store_id INTEGER REFERENCES stores(id),
    total_price NUMERIC(10,2) NOT NULL,
    status VARCHAR(30) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    product_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    qty INTEGER NOT NULL
);


SELECT * FROM orders ORDER BY id DESC;

SELECT * FROM order_items ORDER BY id DESC;



ALTER TABLE orders
ADD COLUMN payment_method VARCHAR(30);

ALTER TABLE orders
ADD COLUMN delivery_note TEXT;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE users;




CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT id, full_name, phone, email, created_at
FROM users
ORDER BY id DESC;





CREATE TABLE IF NOT EXISTS addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    details TEXT NOT NULL,
    lat NUMERIC(10,7),
    lng NUMERIC(10,7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




