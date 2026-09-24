-- ============================================================
-- ChillFi Seed Data
-- ============================================================

-- BRANDS
INSERT INTO brands (id, name, logo_url, is_active) VALUES
  ('b1000000-0000-0000-0000-000000000001', 'Samsung',  'https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg', TRUE),
  ('b1000000-0000-0000-0000-000000000002', 'Sony',     'https://upload.wikimedia.org/wikipedia/commons/c/ca/Sony_logo.svg',    TRUE),
  ('b1000000-0000-0000-0000-000000000003', 'Apple',    'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg', TRUE),
  ('b1000000-0000-0000-0000-000000000004', 'boAt',     'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=60', TRUE),
  ('b1000000-0000-0000-0000-000000000005', 'Lenovo',   'https://upload.wikimedia.org/wikipedia/commons/b/b8/Lenovo_logo_2015.svg', TRUE),
  ('b1000000-0000-0000-0000-000000000006', 'Noise',    'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=60', TRUE),
  ('b1000000-0000-0000-0000-000000000007', 'OnePlus',  'https://upload.wikimedia.org/wikipedia/commons/8/8a/OnePlus_Logo.svg', TRUE)
ON CONFLICT (name) DO NOTHING;

-- CATEGORIES
INSERT INTO categories (id, name, icon, description, is_active, sort_order) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'Smartphones',  '📱', 'All mobile phones and accessories',    TRUE, 1),
  ('c1000000-0000-0000-0000-000000000002', 'Audio',        '🎧', 'Headphones, earbuds, speakers',        TRUE, 2),
  ('c1000000-0000-0000-0000-000000000003', 'Laptops',      '💻', 'Laptops and computing accessories',    TRUE, 3),
  ('c1000000-0000-0000-0000-000000000004', 'Wearables',    '⌚', 'Smartwatches and fitness bands',       TRUE, 4),
  ('c1000000-0000-0000-0000-000000000005', 'Smart TVs',    '📺', '4K, OLED and QLED televisions',        TRUE, 5),
  ('c1000000-0000-0000-0000-000000000006', 'Cameras',      '📷', 'DSLRs, mirrorless and action cams',    TRUE, 6),
  ('c1000000-0000-0000-0000-000000000007', 'Accessories',  '🔌', 'Cables, cases, chargers and more',     TRUE, 7)
ON CONFLICT DO NOTHING;

-- PRODUCTS
INSERT INTO products (id, name, description, price, old_price, stock, brand_id, category_id, rating, review_count, status, is_featured, is_flash_sale) VALUES
  ('a1000000-0000-0000-0000-000000000001',
   'Samsung Galaxy S24 FE 5G (8GB+256GB)',
   '6.7" Dynamic AMOLED 2X display, 50MP triple camera, 4600mAh battery, 45W fast charging, IP68 water resistant, Android 14',
   39999, 54999, 142,
   'b1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001',
   0, 0, 'Active', TRUE, FALSE),

  ('a1000000-0000-0000-0000-000000000002',
   'Sony WH-1000XM5 Wireless Headphones',
   'Industry-leading noise cancellation with dual noise sensor technology, 30hr battery, crystal clear hands-free calling, Multipoint connection, Hi-Res audio',
   24990, 34990, 67,
   'b1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000002',
   0, 0, 'Active', TRUE, FALSE),

  ('a1000000-0000-0000-0000-000000000003',
   'Lenovo IdeaPad Slim 3 (Intel i5 12th Gen)',
   'Intel Core i5-1235U, 16GB DDR4, 512GB SSD NVMe, 15.6" FHD IPS, Intel Iris Xe Graphics, Windows 11, 2yr warranty',
   52999, 64999, 34,
   'b1000000-0000-0000-0000-000000000005', 'c1000000-0000-0000-0000-000000000003',
   0, 0, 'Active', TRUE, FALSE),

  ('a1000000-0000-0000-0000-000000000004',
   'Apple AirPods Pro (2nd Gen) — USB-C',
   'Active Noise Cancellation, Transparency mode, Adaptive Audio, Personalized Spatial Audio, 30hr total battery with case, MagSafe charging',
   19900, 26900, 0,
   'b1000000-0000-0000-0000-000000000003', 'c1000000-0000-0000-0000-000000000002',
   0, 0, 'Out of Stock', TRUE, FALSE),

  ('a1000000-0000-0000-0000-000000000005',
   'Noise ColorFit Ultra 3 Smartwatch',
   '1.96" AMOLED display, BT calling, health suite (SpO2, stress, sleep), 100+ watch faces, 7-day battery, IP68 rated',
   2999, 7999, 289,
   'b1000000-0000-0000-0000-000000000006', 'c1000000-0000-0000-0000-000000000004',
   0, 0, 'Active', FALSE, TRUE),

  ('a1000000-0000-0000-0000-000000000006',
   'Samsung 55" Crystal 4K UHD Smart TV',
   'Crystal 4K processor, HDR10+, PurColor, Tizen OS, Amazon Alexa built-in, 3 HDMI, 1 USB, auto motion plus',
   42999, 69990, 18,
   'b1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000005',
   0, 0, 'Active', FALSE, FALSE),

  ('a1000000-0000-0000-0000-000000000007',
   'boAt Airdopes 141 TWS Earbuds',
   '42HR playtime, ENx™ technology for clear calls, 8mm drivers, IPX4, Type-C charging, instant pairing, low-latency gaming mode',
   1299, 2990, 510,
   'b1000000-0000-0000-0000-000000000004', 'c1000000-0000-0000-0000-000000000002',
   0, 0, 'Active', FALSE, TRUE),

  ('a1000000-0000-0000-0000-000000000008',
   'OnePlus Nord CE4 5G (8GB+256GB)',
   '6.7" 120Hz AMOLED, Snapdragon 7s Gen 3, 50MP Sony sensor, 100W SUPERVOOC charging, 5500mAh, OxygenOS 14, dual SIM',
   24999, 32999, 87,
   'b1000000-0000-0000-0000-000000000007', 'c1000000-0000-0000-0000-000000000001',
   0, 0, 'Active', TRUE, FALSE),

  ('a1000000-0000-0000-0000-000000000009',
   'Sony WF-1000XM5 True Wireless Earbuds',
   'Industry-leading noise cancellation, 24hr battery with case, Multipoint connection, LDAC Hi-Res audio, IPX4, Speak-to-Chat',
   17990, 24990, 45,
   'b1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000002',
   0, 0, 'Active', FALSE, FALSE),

  ('a1000000-0000-0000-0000-000000000010',
   'Samsung Galaxy Watch6 Classic 47mm',
   'Rotating bezel, 1.5" Super AMOLED, body composition, ECG & BP monitor, sleep coaching, Wear OS, 5ATM + IP68',
   31999, 44999, 29,
   'b1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000004',
   0, 0, 'Active', TRUE, FALSE)
ON CONFLICT DO NOTHING;

-- PRODUCT IMAGES
INSERT INTO product_images (product_id, url, is_primary, sort_order) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=800', TRUE,  0),
  ('a1000000-0000-0000-0000-000000000001', 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?auto=format&fit=crop&q=80&w=800', FALSE, 1),

  ('a1000000-0000-0000-0000-000000000002', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=800', TRUE,  0),
  ('a1000000-0000-0000-0000-000000000002', 'https://images.unsplash.com/photo-1578319439584-104c94d37305?auto=format&fit=crop&q=80&w=800', FALSE, 1),

  ('a1000000-0000-0000-0000-000000000003', 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&q=80&w=800', TRUE,  0),
  ('a1000000-0000-0000-0000-000000000003', 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?auto=format&fit=crop&q=80&w=800', FALSE, 1),

  ('a1000000-0000-0000-0000-000000000004', 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&q=80&w=800', TRUE,  0),

  ('a1000000-0000-0000-0000-000000000005', 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=800', TRUE,  0),

  ('a1000000-0000-0000-0000-000000000006', 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&q=80&w=800', TRUE,  0),

  ('a1000000-0000-0000-0000-000000000007', 'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=800', TRUE,  0),

  ('a1000000-0000-0000-0000-000000000008', 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?auto=format&fit=crop&q=80&w=800', TRUE,  0),

  ('a1000000-0000-0000-0000-000000000009', 'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?auto=format&fit=crop&q=80&w=800', TRUE,  0),

  ('a1000000-0000-0000-0000-000000000010', 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&q=80&w=800', TRUE,  0)
ON CONFLICT DO NOTHING;

-- COUPONS
INSERT INTO coupons (id, code, type, value, min_order, max_discount, usage_limit, is_active, expires_at) VALUES
  ('ca100000-0000-0000-0000-000000000001', 'CHILLFI10',  'Percentage',    10,  999,  500,  1000, TRUE, NOW() + INTERVAL '90 days'),
  ('ca100000-0000-0000-0000-000000000002', 'FLAT200',    'Flat',         200, 1999,    0,   500, TRUE, NOW() + INTERVAL '60 days'),
  ('ca100000-0000-0000-0000-000000000003', 'FREESHIP',   'Free Shipping',  0,  499,   49,   999, TRUE, NOW() + INTERVAL '30 days'),
  ('ca100000-0000-0000-0000-000000000004', 'WELCOME20',  'Percentage',    20, 1499, 1000,   200, TRUE, NOW() + INTERVAL '120 days')
ON CONFLICT (code) DO NOTHING;

-- BANNERS
INSERT INTO banners (title, subtitle, image_url, link, position, sort_order, is_active) VALUES
  ('Monsoon Sale — Up to 70% Off',  'On top electronics & gadgets',  'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&q=80&w=1400', '/products', 'hero',  1, TRUE),
  ('New Samsung Galaxy S24 FE',     'The fan edition you''ve waited for', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=1400', '/product/a1000000-0000-0000-0000-000000000001', 'hero', 2, TRUE),
  ('Sony Audio — Premium Sound',    'WH-1000XM5 now at ₹24,990',    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=1400', '/product/a1000000-0000-0000-0000-000000000002', 'hero', 3, TRUE),
  ('Flash Deals — Today Only',      'Grab them before they''re gone', 'https://images.unsplash.com/photo-1607082349566-187342175e2f?auto=format&fit=crop&q=80&w=900',  '/offers', 'promo', 1, TRUE),
  ('Free Delivery on ₹499+',       'Use code FREESHIP at checkout',  'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?auto=format&fit=crop&q=80&w=900',  '/products', 'promo', 2, TRUE)
ON CONFLICT DO NOTHING;

-- STORE SETTINGS
INSERT INTO store_settings (key, value) VALUES
  ('store_name',               'ChillFi'),
  ('store_email',              'support@chillfi.in'),
  ('store_phone',              '+91 98765 43210'),
  ('store_address',            '123, Tech Park, Whitefield, Bengaluru, Karnataka - 560066'),
  ('gst_number',               '29AABCU9603R1ZM'),
  ('website_url',              'https://chillfi.web.app'),
  ('support_email',            'help@chillfi.in'),
  ('free_shipping_threshold',  '499'),
  ('standard_shipping_fee',    '49'),
  ('express_shipping_fee',     '99'),
  ('max_delivery_days',        '7'),
  ('free_shipping_enabled',    'true'),
  ('express_enabled',          'true'),
  ('cod_enabled',              'true')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
