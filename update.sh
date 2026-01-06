#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="go-test-api"
LOCK_FILE="/tmp/punk-go-test-api-update.lock"
LOG_FILE="$APP_DIR/cron.log"

log() {
  echo "[$(date -Is)] $*" | tee -a "$LOG_FILE"
}

(
  # evitar ejecuciones simultáneas
  flock -n 9 || { log "SKIP: another update is running"; exit 0; }

  cd "$APP_DIR"

  log "START update"

  # no permitir cambios locales en el server
  if ! git diff --quiet || ! git diff --cached --quiet; then
    log "ERROR: local changes detected. Aborting update."
    exit 1
  fi

  log "git fetch"
  git fetch --prune

  LOCAL_COMMIT="$(git rev-parse HEAD)"
  REMOTE_COMMIT="$(git rev-parse @{u})"

  if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
    log "NOOP: already up to date"
    exit 0
  fi

  log "git pull --ff-only"
  git pull --ff-only

  log "docker compose build $SERVICE_NAME"
  docker compose build "$SERVICE_NAME"

  log "RUN deploy.sh"
  ./deploy.sh

  log "DONE update"
) 9>"$LOCK_FILE"
