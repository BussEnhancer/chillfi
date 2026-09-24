-- Shiprocket integration migration
-- Run once on the production DB (EC2: psql -U chillfi_user -d chillfi_db)

-- 1. Add shipment_provider column to orders (tracks which courier API was used)
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS shipment_provider VARCHAR(20) DEFAULT 'delhivery';

-- 2. Back-fill existing shipped orders as delhivery (they all were)
UPDATE orders SET shipment_provider = 'delhivery' WHERE shipment_provider IS NULL;

-- Done. Verify:
SELECT COUNT(*) AS total_orders,
       SUM(CASE WHEN tracking_id IS NOT NULL THEN 1 ELSE 0 END) AS shipped_orders,
       shipment_provider
FROM orders GROUP BY shipment_provider;
