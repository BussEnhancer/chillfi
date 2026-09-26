-- ============================================================
-- ChillFi Database Schema
-- ============================================================

-- USERS
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100),
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(15) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  avatar_url TEXT,
  role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'support_staff')),
  is_active BOOLEAN DEFAULT TRUE,
  is_phone_verified BOOLEAN DEFAULT FALSE,
  notification_preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE users ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{}';

DO $$ BEGIN
  ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
  ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('customer', 'admin', 'support_staff'));
EXCEPTION WHEN others THEN NULL;
END $$;

-- OTP SESSIONS
CREATE TABLE IF NOT EXISTS otp_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(15) NOT NULL,
  otp TEXT NOT NULL,
  purpose VARCHAR(30) DEFAULT 'login' CHECK (purpose IN ('login', 'signup', 'forgot_password')),
  attempts INT DEFAULT 0,
  is_used BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- REFRESH TOKENS
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- FCM TOKENS (push notifications)
CREATE TABLE IF NOT EXISTS fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform VARCHAR(10) DEFAULT 'android' CHECK (platform IN ('android', 'ios', 'web')),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, token)
);

-- BRANDS
CREATE TABLE IF NOT EXISTS brands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  logo_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- CATEGORIES
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(10),
  description TEXT,
  parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- PRODUCTS
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  old_price DECIMAL(10,2),
  stock INT DEFAULT 0,
  brand_id UUID REFERENCES brands(id) ON DELETE SET NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  rating DECIMAL(2,1) DEFAULT 0,
  review_count INT DEFAULT 0,
  status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Out of Stock', 'Low Stock')),
  is_featured BOOLEAN DEFAULT FALSE,
  is_flash_sale BOOLEAN DEFAULT FALSE,
  flash_sale_ends_at TIMESTAMP,
  tags TEXT[],
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- PRODUCT IMAGES
CREATE TABLE IF NOT EXISTS product_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  is_primary BOOLEAN DEFAULT FALSE,
  sort_order INT DEFAULT 0
);

-- ADDRESSES
CREATE TABLE IF NOT EXISTS addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  label VARCHAR(20) DEFAULT 'Home' CHECK (label IN ('Home', 'Work', 'Other')),
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(15) NOT NULL,
  line1 TEXT NOT NULL,
  line2 TEXT,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  pincode VARCHAR(10) NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- COUPONS
CREATE TABLE IF NOT EXISTS coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(30) UNIQUE NOT NULL,
  type VARCHAR(20) DEFAULT 'Percentage' CHECK (type IN ('Percentage', 'Flat', 'Free Shipping')),
  value DECIMAL(10,2) DEFAULT 0,
  min_order DECIMAL(10,2) DEFAULT 0,
  max_discount DECIMAL(10,2) DEFAULT 0,
  used_count INT DEFAULT 0,
  usage_limit INT DEFAULT 1000,
  expires_at TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- COUPON USAGE
CREATE TABLE IF NOT EXISTS coupon_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID REFERENCES coupons(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  order_id UUID,
  used_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(coupon_id, user_id)
);

-- CART
CREATE TABLE IF NOT EXISTS cart (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- CART ITEMS
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID REFERENCES cart(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INT DEFAULT 1,
  added_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(cart_id, product_id)
);

-- WISHLIST
CREATE TABLE IF NOT EXISTS wishlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  added_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- ORDERS
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number VARCHAR(20) UNIQUE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) DEFAULT 0,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  tax_amount DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  coupon_id UUID REFERENCES coupons(id) ON DELETE SET NULL,
  payment_method VARCHAR(20) DEFAULT 'COD' CHECK (payment_method IN ('COD', 'PhonePe', 'UPI', 'Card', 'NetBanking')),
  payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
  status VARCHAR(20) DEFAULT 'Processing' CHECK (status IN ('Processing', 'Shipped', 'Delivered', 'Cancelled')),
  tracking_id VARCHAR(100),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE orders ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipment_provider VARCHAR(20) DEFAULT 'delhivery';

-- ORDER ITEMS
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name VARCHAR(255) NOT NULL,
  product_image TEXT,
  price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL
);

-- PAYMENTS
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  txn_id VARCHAR(100),
  merchant_txn_id VARCHAR(100),
  amount DECIMAL(10,2),
  status VARCHAR(20) DEFAULT 'Pending',
  gateway_response JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- SHIPPING RULES (per-pincode-prefix overrides; flat fee in store_settings is the fallback)
CREATE TABLE IF NOT EXISTS shipping_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pincode_prefix VARCHAR(10) NOT NULL,
  fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  free_above DECIMAL(10,2),
  cod_available BOOLEAN DEFAULT TRUE,
  estimated_days INT DEFAULT 5,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- REFUND / RETURN / EXCHANGE REQUESTS
CREATE TABLE IF NOT EXISTS refund_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  type VARCHAR(20) DEFAULT 'Refund' CHECK (type IN ('Refund', 'Return', 'Exchange')),
  reason TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'Requested' CHECK (status IN ('Requested', 'Approved', 'Rejected', 'Refunded')),
  refund_amount DECIMAL(10,2),
  admin_notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- REVIEWS
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title VARCHAR(150),
  body TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- RECENTLY VIEWED
CREATE TABLE IF NOT EXISTS recently_viewed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  viewed_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- SEARCH LOGS
CREATE TABLE IF NOT EXISTS search_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  query VARCHAR(255) NOT NULL,
  results_count INT DEFAULT 0,
  searched_at TIMESTAMP DEFAULT NOW()
);

-- BANNERS (admin-managed homepage banners)
CREATE TABLE IF NOT EXISTS banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(150),
  subtitle TEXT,
  image_url TEXT NOT NULL,
  link TEXT,
  position VARCHAR(20) DEFAULT 'hero' CHECK (position IN ('hero', 'promo', 'offer')),
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- TESTIMONIALS (admin-managed homepage customer testimonials)
CREATE TABLE IF NOT EXISTS testimonials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name VARCHAR(150) NOT NULL,
  avatar_url TEXT,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  quote TEXT NOT NULL,
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- PROMO BANNERS (admin-managed homepage promo strip, separate placement from hero banners)
CREATE TABLE IF NOT EXISTS promo_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(150) NOT NULL,
  subtitle TEXT,
  image_url TEXT,
  link TEXT,
  background_color VARCHAR(20),
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(150) NOT NULL,
  body TEXT,
  type VARCHAR(30) DEFAULT 'general',
  is_read BOOLEAN DEFAULT FALSE,
  data JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- CONTACT MESSAGES (submitted via storefront Contact Us form)
CREATE TABLE IF NOT EXISTS contact_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL,
  phone VARCHAR(20),
  subject VARCHAR(50) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  reply TEXT,
  replied_at TIMESTAMP,
  replied_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE contact_messages ADD COLUMN IF NOT EXISTS reply TEXT;
ALTER TABLE contact_messages ADD COLUMN IF NOT EXISTS replied_at TIMESTAMP;
ALTER TABLE contact_messages ADD COLUMN IF NOT EXISTS replied_by UUID REFERENCES users(id);

-- STORE SETTINGS
CREATE TABLE IF NOT EXISTS store_settings (
  key VARCHAR(100) PRIMARY KEY,
  value TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- EMAIL TEMPLATES (admin-editable subject/body; a missing row means "use the built-in default")
CREATE TABLE IF NOT EXISTS email_templates (
  key VARCHAR(60) PRIMARY KEY,
  subject TEXT,
  body TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- INDEXES for performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_flash_sale ON products(is_flash_sale);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_user ON wishlist(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_recently_viewed_user ON recently_viewed(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
-- Older databases were created with otp VARCHAR(6): too short for hashed codes / Firebase session info.
ALTER TABLE otp_sessions ALTER COLUMN otp TYPE TEXT;
CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_sessions(phone);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_payments_merchant_txn ON payments(merchant_txn_id);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(is_featured);
CREATE INDEX IF NOT EXISTS idx_cart_user ON cart(user_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usage_coupon_user ON coupon_usage(coupon_id, user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);

-- SHIPPING / DELHIVERY LIFECYCLE
-- orders.status stays the customer-facing 4-state value (Processing/Shipped/Delivered/Cancelled);
-- orders.shipping_status carries the detailed courier stage (see utils/shipmentStatus.js).
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_status VARCHAR(30);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS courier_status VARCHAR(60);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS courier_status_type VARCHAR(10);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS courier_status_at TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS courier_location VARCHAR(150);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS expected_delivery_date TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipment_env VARCHAR(12);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipment_error TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipment_attempts INT DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipment_claimed_at TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipment_created_at TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tracking_synced_at TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS pickup_scheduled_for DATE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS pickup_request_id VARCHAR(40);
CREATE INDEX IF NOT EXISTS idx_orders_tracking_id ON orders(tracking_id);
CREATE INDEX IF NOT EXISTS idx_orders_shipping_status ON orders(shipping_status);

CREATE TABLE IF NOT EXISTS shipment_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  awb VARCHAR(100) NOT NULL,
  source VARCHAR(20) NOT NULL,             -- webhook | poll | api | admin
  status VARCHAR(60),
  status_type VARCHAR(10),
  location VARCHAR(150),
  instructions TEXT,
  event_time TIMESTAMP,
  applied BOOLEAN DEFAULT FALSE,           -- whether it changed the order's state
  dedupe_key VARCHAR(300) NOT NULL UNIQUE,
  raw JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_shipment_events_order ON shipment_events(order_id, event_time);

-- Notification de-duplication (courier webhooks are retried; one notification per event)
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS dedupe_key VARCHAR(200);
CREATE UNIQUE INDEX IF NOT EXISTS idx_notifications_dedupe ON notifications(dedupe_key) WHERE dedupe_key IS NOT NULL;

INSERT INTO store_settings (key, value) VALUES ('DELHIVERY_ENV', 'staging') ON CONFLICT (key) DO NOTHING;

-- Default OTP provider setting
INSERT INTO store_settings (key, value) VALUES ('OTP_PROVIDER', 'firebase')
  ON CONFLICT (key) DO NOTHING;

-- Orders keep the delivery address they were placed with (editing/deleting an address never changes past orders)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_address JSONB;
UPDATE orders o SET shipping_address = jsonb_build_object('label', a.label, 'name', a.name, 'phone', a.phone,
  'line1', a.line1, 'line2', a.line2, 'city', a.city, 'state', a.state, 'pincode', a.pincode)
  FROM addresses a WHERE a.id = o.address_id AND o.shipping_address IS NULL;

-- GST tax invoices (sequential per financial year; issued once an order has shipped)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS invoice_number VARCHAR(20) UNIQUE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS invoice_date TIMESTAMP;
ALTER TABLE products ADD COLUMN IF NOT EXISTS hsn_code VARCHAR(10);
CREATE TABLE IF NOT EXISTS invoice_counters (fy VARCHAR(4) PRIMARY KEY, last_no INT NOT NULL DEFAULT 0);
INSERT INTO store_settings (key, value) VALUES ('invoices_enabled', 'false') ON CONFLICT (key) DO NOTHING;

-- Admin / support-staff sign-in history (Settings → Security → Login Activity Log)
CREATE TABLE IF NOT EXISTS admin_login_events (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  method VARCHAR(30),
  ip VARCHAR(64),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_admin_login_events_time ON admin_login_events(created_at DESC);

-- Admin / staff change history (Settings → Security → Admin activity). Values of secrets are never stored.
CREATE TABLE IF NOT EXISTS admin_audit_log (
  id SERIAL PRIMARY KEY,
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  actor_name VARCHAR(100),
  method VARCHAR(8),
  path TEXT,
  details JSONB,
  ip VARCHAR(64),
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_time ON admin_audit_log(created_at DESC);
