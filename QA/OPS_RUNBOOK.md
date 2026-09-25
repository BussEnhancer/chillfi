# ChillFi — operations runbook (owner steps)

Everything below is already built and deployed-ready; these steps need **your** accounts or AWS console access.

## 1. Uptime alerts (5 minutes, free)
1. Create a free account at **uptimerobot.com** (or Better Stack / Freshping).
2. *Add New Monitor* → type **HTTP(s) - Keyword**:
   - URL: `https://chillfi.in/api/health`
   - Keyword: `"status":"ok"` → alert when keyword **not** found
   - Interval: 5 minutes
3. Add a second monitor, type **HTTP(s)**, URL `https://chillfi.in/` (the website itself).
4. Alert contacts: your email + the UptimeRobot mobile app (push). Optional: SMS.

`/api/health` returns **200** only when the API **and the database** respond; **503** if the database is down.

## 2. Email (order emails + new-order / low-stock alerts)
1. Get SMTP details from your email provider, for example:
   - Zoho Mail: `smtp.zoho.in`, port 587, your mailbox + an *app password*
   - Google Workspace: `smtp.gmail.com`, port 587, an *app password*
   - Amazon SES: `email-smtp.ap-south-1.amazonaws.com`, port 587, SES SMTP credentials (verify the chillfi.in domain first)
2. chillfi.in/admin → **Settings → API Keys → Email (SMTP)**: enter Host, Port, Username, Password, From (e.g. `ChillFi <orders@chillfi.in>`) → Save each.
3. Click **Send test email** (goes to the Store Email). If it arrives, you're done.
4. For best delivery, add SPF/DKIM records for chillfi.in as your provider instructs.

## 3. SMS order updates (optional; India DLT rules apply)
1. In MSG91, register a **DLT-approved transactional template** with two variables, e.g.
   `Your ChillFi order ##order## update: ##status##. Track at chillfi.in -ChillFi`
2. Admin → Settings → API Keys → OTP / SMS: set **MSG91 Auth Key**, **MSG91 DLT template ID**, then **SMS order updates = on**.
SMS is sent only for: order confirmed, shipped, out for delivery, delivered, cancelled.

## 4. GST tax invoices
1. Admin → Settings → Store Info: enter your **real 15-character GSTIN**, legal **Store Name** and registered **Store Address** → Save.
2. Turn on **Issue GST Tax Invoices** → Save (refused unless the GSTIN is valid).
3. Optional: add **HSN codes** to products (Admin → Products → edit → HSN Code).
Invoices appear once an order is Shipped/Delivered (website order page, app order details, admin order view).
Numbering: `CF/<FY>/<000001>` per financial year, sequential.

## 5. Bigger server (optional; ~1–2 min downtime)
Current: 1 small instance (~1 GB RAM). Recommended when traffic grows: **t3.small (2 GB)**.
1. **First** check EC2 → Elastic IPs: `3.111.32.220` must be an **Elastic IP** attached to the instance — otherwise stopping the instance changes its public IP and chillfi.in breaks (then allocate + associate an Elastic IP and update DNS first).
2. EC2 → Instances → select → *Instance state → Stop* → *Actions → Instance settings → Change instance type* → `t3.small` → *Start*.
3. The API restarts automatically (pm2 startup service, Node 22). Check `https://chillfi.in/api/health`.

## 6. Database backups (recommended — not set up yet)
The PostgreSQL database runs on the same EC2 instance and **no backup exists**. Ask me to add a nightly `pg_dump` (7-day retention, optionally copied to S3), and/or enable EC2 → *Lifecycle Manager* daily EBS snapshots.
