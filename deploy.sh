#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="go-test-api"

docker compose up -d "$SERVICE_NAME"
