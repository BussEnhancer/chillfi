#!/bin/bash
# ============================================================
# ChillFi — deploy backend (+ optional website) to the EC2 production host.
#
#   ./deploy_backend.sh <key.pem>                 # DRY RUN: shows what would change, touches nothing
#   ./deploy_backend.sh <key.pem> --apply         # deploy backend
#   ./deploy_backend.sh <key.pem> --apply --web   # deploy backend + build & deploy website
#
# Host layout (verified 2026-09-23):
#   backend  /home/ec2-user/chillfi/backend   (pm2 "chillfi-api", cluster mode, .env lives here — never overwritten)
#   website  /var/www/chillfi                 (nginx; /api/ proxied to :5000)
# Every --apply run first backs up both targets to ~/deploy-backups/<timestamp>/.
# DB migrations in src/db/schema.sql are additive (IF NOT EXISTS) and run on app start.
# Rollback: copy the backup back over the target and `pm2 reload chillfi-api`.
# ============================================================
set -euo pipefail

KEY="${1:?usage: $0 <key.pem> [--apply] [--web]}"
APPLY=false; WEB=false
for a in "${@:2}"; do case "$a" in --apply) APPLY=true;; --web) WEB=true;; esac; done

HOST="ec2-user@3.111.32.220"
REMOTE_BACKEND="/home/ec2-user/chillfi/backend"
REMOTE_WEB="/var/www/chillfi"
ROOT="$(cd "$(dirname "$0")" && pwd)"
remote() { ssh -i "$KEY" -o BatchMode=yes "$@"; }
RSYNC_NODEL=(-rlptz -e "ssh -i \"$KEY\" -o BatchMode=yes")
$APPLY || RSYNC_NODEL+=(--dry-run --itemize-changes)
RSYNC_FLAGS=("${RSYNC_NODEL[@]}" --delete)

echo "▶ Target: $HOST   mode: $($APPLY && echo APPLY || echo DRY-RUN)   website: $WEB"

if $APPLY; then
  TS=$(date +%Y%m%d-%H%M%S)
  echo "▶ Backing up remote to ~/deploy-backups/$TS"
  remote "$HOST" "mkdir -p ~/deploy-backups/$TS && cp -a $REMOTE_BACKEND/src $REMOTE_BACKEND/package.json ~/deploy-backups/$TS/ && sudo cp -a $REMOTE_WEB ~/deploy-backups/$TS/www 2>/dev/null || true"
fi

echo "▶ Backend source"
rsync "${RSYNC_FLAGS[@]}" "$ROOT/backend/src/" "$HOST:$REMOTE_BACKEND/src/"
rsync "${RSYNC_NODEL[@]}" "$ROOT/backend/scripts/" "$HOST:$REMOTE_BACKEND/scripts/"
rsync "${RSYNC_NODEL[@]}" "$ROOT/backend/package.json" "$ROOT/backend/package-lock.json" "$HOST:$REMOTE_BACKEND/"

if $WEB; then
  echo "▶ Website (build with .env.production → $(cat "$ROOT/web/website/.env.production"))"
  if $APPLY; then (cd "$ROOT/web/website" && npm run build >/dev/null); fi
  remote "$HOST" "mkdir -p ~/web-staging"
  rsync "${RSYNC_FLAGS[@]}" "$ROOT/web/website/dist/" "$HOST:~/web-staging/"
  $APPLY && remote "$HOST" "sudo rsync -a --delete ~/web-staging/ $REMOTE_WEB/"
fi

if ! $APPLY; then echo "✓ Dry run complete — nothing changed. Re-run with --apply to deploy."; exit 0; fi

echo "▶ Installing deps + reloading pm2"
remote "$HOST" "cd $REMOTE_BACKEND && npm install --omit=dev --no-audit --no-fund >/dev/null && pm2 reload chillfi-api && sleep 5 && pm2 status chillfi-api"

echo "▶ Health check"
curl -fsS https://chillfi.in/api/app-config >/dev/null && echo "✓ API healthy" || { echo "✗ API health check FAILED — roll back from ~/deploy-backups/$TS"; exit 1; }
remote "$HOST" "pm2 logs chillfi-api --lines 20 --nostream | grep -E 'schema|scheduler|Failed|error' || true"
