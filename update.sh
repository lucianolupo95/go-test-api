#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="go-test-api"
LOCK_FILE="/tmp/punk-go-test-api-update.lock"
LOG_FILE="$APP_DIR/cron.log"
COMPOSE_DIR="/srv/punk-records/infra"

log() {
  echo "[$(date -Is)] $*" | tee -a "$LOG_FILE"
}

(
  flock -n 9 || { log "SKIP: another update is running"; exit 0; }

  cd "$APP_DIR"
  log "START update"

  # proteger el server
  if ! git diff --quiet || ! git diff --cached --quiet; then
    log "ERROR: local changes detected. Aborting update."
    exit 1
  fi

  git fetch --prune

  LOCAL="$(git rev-parse HEAD)"
  REMOTE="$(git rev-parse @{u})"

  if [ "$LOCAL" = "$REMOTE" ]; then
    log "NOOP: already up to date"
    exit 0
  fi

  log "git pull"
  git pull --ff-only

  log "docker compose build $SERVICE_NAME"
  cd "$COMPOSE_DIR"
  docker compose build "$SERVICE_NAME"

  log "deploy"
  cd "$APP_DIR"
  ./deploy.sh

  log "DONE update"
) 9>"$LOCK_FILE"
