#!/bin/bash
# Deploy Delhivery backend changes to EC2
# Usage: ./deploy_backend.sh /path/to/chillfi-key.pem

KEY="${1:-$HOME/.ssh/chillfi-key.pem}"
EC2="ubuntu@3.111.32.220"
APP_DIR="/home/ubuntu/chillfi-backend/src"
BACKEND="$(dirname "$0")/backend/src"

SCP_OPTS="-i $KEY -o StrictHostKeyChecking=no"
SSH_OPTS="-i $KEY -o StrictHostKeyChecking=no"

echo "Deploying to $EC2..."

scp $SCP_OPTS \
  "$BACKEND/utils/delhivery.js" \
  "$BACKEND/controllers/orderController.js" \
  "$BACKEND/controllers/adminController.js" \
  "$BACKEND/routes/admin.js" \
  "$BACKEND/routes/orders.js" \
  $EC2:/tmp/ || { echo "SCP failed"; exit 1; }

ssh $SSH_OPTS $EC2 "
  set -e
  cp /tmp/delhivery.js $APP_DIR/utils/delhivery.js
  cp /tmp/orderController.js $APP_DIR/controllers/orderController.js
  cp /tmp/adminController.js $APP_DIR/controllers/adminController.js
  cp /tmp/admin_routes.js $APP_DIR/routes/admin.js || cp /tmp/admin.js $APP_DIR/routes/admin.js 2>/dev/null || true
  cp /tmp/orders_routes.js $APP_DIR/routes/orders.js || cp /tmp/orders.js $APP_DIR/routes/orders.js 2>/dev/null || true
  pm2 restart chillfi-api
  pm2 status chillfi-api
  echo 'Deploy complete!'
" || { echo "SSH failed"; exit 1; }
