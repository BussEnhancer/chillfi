#!/bin/bash
# ChillFi — full deploy to EC2 (3.111.32.220)
# Usage: chmod +x deploy.sh && ./deploy.sh
# Requires: ssh key at ~/.ssh/chillfi.pem (or set EC2_KEY below)

set -e

EC2_USER="ubuntu"
EC2_HOST="3.111.32.220"
EC2_KEY="${EC2_KEY:-~/.ssh/chillfi.pem}"
REMOTE_BACKEND="/home/ubuntu/chillfi/backend"
REMOTE_WEB="/var/www/chillfi"          # nginx serves from here

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
WEB_DIR="$SCRIPT_DIR/web/website"

SSH="ssh -i $EC2_KEY -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST"

echo ""
echo "=== 1/4  Building website ==="
cd "$WEB_DIR"
npm run build
echo "Build complete → dist/"

echo ""
echo "=== 2/4  Uploading backend source ==="
cd "$SCRIPT_DIR"
rsync -az --delete \
  --exclude 'node_modules' \
  --exclude '.env' \
  --exclude 'uploads/' \
  -e "ssh -i $EC2_KEY -o StrictHostKeyChecking=no" \
  "$BACKEND_DIR/src/" \
  "$EC2_USER@$EC2_HOST:$REMOTE_BACKEND/src/"

rsync -az \
  -e "ssh -i $EC2_KEY -o StrictHostKeyChecking=no" \
  "$BACKEND_DIR/package.json" \
  "$BACKEND_DIR/package-lock.json" \
  "$EC2_USER@$EC2_HOST:$REMOTE_BACKEND/"

echo ""
echo "=== 3/4  Uploading website build ==="
rsync -az --delete \
  -e "ssh -i $EC2_KEY -o StrictHostKeyChecking=no" \
  "$WEB_DIR/dist/" \
  "$EC2_USER@$EC2_HOST:$REMOTE_WEB/"

echo ""
echo "=== 4/4  Restarting backend on EC2 ==="
$SSH bash -s << 'REMOTE'
set -e
cd /home/ubuntu/chillfi/backend

# Install any new packages
npm install --omit=dev --silent

# Run schema migration (IF NOT EXISTS guards make this safe to re-run)
echo "  → Applying DB schema (indexes + new tables)..."
node -e "
const pool = require('./src/db/pool');
const fs = require('fs');
const sql = fs.readFileSync('./src/db/schema.sql', 'utf8');
pool.query(sql).then(() => { console.log('  Schema OK'); process.exit(0); }).catch(e => { console.error('  Schema error:', e.message); process.exit(1); });
" || echo "  Schema step skipped (check manually if needed)"

# Restart PM2 process
pm2 restart chillfi-api --update-env
pm2 save

echo "  Backend restarted"
REMOTE

echo ""
echo "✅ Deploy complete!"
echo "   Backend : http://$EC2_HOST:5000/api/health"
echo "   Website : http://$EC2_HOST"
echo ""
echo "Post-deploy checks:"
echo "  curl http://$EC2_HOST/api/health"
echo "  curl http://$EC2_HOST/api/brands"
echo "  curl http://$EC2_HOST/api/payment/callback  (should redirect, not 404)"
