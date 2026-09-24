# Delhivery — Staging Validation & Go-Live Runbook

Integration status (2026-09-23): built and verified end-to-end (app, website, admin) against a local
simulator of Delhivery's documented API. **Real Delhivery staging has not been exercised yet** — it needs
a staging API token.

## A. Real staging validation (needs: staging token)
1. Admin → Settings → API Keys → Shipping:
   - `Delhivery Environment` = **staging**
   - `Delhivery STAGING API Token` = token from Delhivery
   - `Delhivery STAGING Pickup Location` = exact warehouse name on the staging account
2. Local only: delete `DELHIVERY_STAGING_BASE_URL` from `backend/.env` (it points staging at the simulator).
3. Admin → API Keys → Delhivery Integration → **Test connection** → must say "Connected (staging)".
4. Run the automated suite against real staging (no `SIM_URL` → simulator-only fault cases are skipped):
   ```
   cd backend
   ADMIN_TOKEN=… CUSTOMER_TOKEN=… WEBHOOK_SECRET=… PRODUCT_ID=… ADDRESS_ID=… \
     node scripts/test-delhivery-lifecycle.js
   ```
   Creates real *staging* shipments (no charge) and posts documented-format webhook events to ChillFi.
5. Place one order from the app and one from the website; confirm AWB appears in Admin → Orders.

## B. Production deploy (code) — no Delhivery/PhonePe behaviour changes until configured
1. `./deploy_backend.sh <key.pem>` → review the dry run.
2. `./deploy_backend.sh <key.pem> --apply --web` → backs up to `~/deploy-backups/<ts>/`, deploys backend +
   website, reloads pm2, health-checks. Migrations are additive and run on start.
3. On the server `.env` (`/home/ec2-user/chillfi/backend/.env`) add:
   ```
   APP_BASE_URL=https://chillfi.in
   WEBSITE_URL=https://chillfi.in
   ```
   then `pm2 reload chillfi-api`. (Without APP_BASE_URL, PhonePe redirect/callback URLs are broken today.)
Safe by default: production DB gets `DELHIVERY_ENV=staging` with no staging token → auto-ship is skipped;
legacy orders are never auto-shipped (only orders created after deploy, `shipping_status='pending'`).

## C. Delhivery go-live (config only — do only after A passes)
1. Admin → API Keys → Shipping:
   - `Delhivery PRODUCTION API Token` = existing live token (Delhivery One → Settings → API Setup → View/Copy.
     **Do not click "Request Live API Token"** — it invalidates the current token.)
   - `Delhivery PRODUCTION Pickup Location` = `Sairam Mobile` or `VBINFOTECH` (exact spelling)
   - `Seller GSTIN`, `Default package weight (grams)`, `Delhivery Webhook Secret` (random, 32+ chars)
2. Ask Delhivery to enable the scan-push webhook (email draft: `DELHIVERY_REQUEST_EMAIL.md`):
   URL `https://chillfi.in/api/shipping/delhivery/webhook`, header `Authorization: Bearer <webhook secret>`.
   Until then the 30-minute poll keeps statuses in sync.
3. Switch `Delhivery Environment` → **production** (confirmation dialog). New orders now create real,
   chargeable shipments from the wallet.
4. Place one real low-value order, confirm AWB on Delhivery One, then cancel it from Admin before pickup.

## D. PhonePe go-live (config only)
Admin → API Keys → Payment Gateway: enter live Merchant ID / Salt Key / Salt Index, then set
`PhonePe Environment` = **PRODUCTION** (confirmation dialog). Requires `NODE_ENV=production` and
`APP_BASE_URL` (step B3). Note: this uses PhonePe's v1 salt-key PG API; merchants onboarded on PhonePe's
newer v2 (client-id/secret) API need a code update — confirm with PhonePe which your MID uses.

## Rollback
- Delhivery: set `Delhivery Environment` back to staging (instant). Auto-ship can be switched off with
  `Auto-create Delhivery shipment` = false.
- Code: restore `~/deploy-backups/<ts>/src` over `/home/ec2-user/chillfi/backend/src`, `pm2 reload chillfi-api`.
