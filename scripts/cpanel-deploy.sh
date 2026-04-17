#!/usr/bin/env bash
set -euo pipefail

DEPLOY_PATH="${1:-$HOME/public_html/bubo}"

echo "Deploying Bubo to: $DEPLOY_PATH"
mkdir -p "$DEPLOY_PATH"

# Build on the server if npm is available; otherwise deploy the existing public output.
if command -v npm >/dev/null 2>&1; then
  if [[ -f package-lock.json ]]; then
    npm ci
  else
    npm install
  fi
  npm run build:bubo
else
  echo "npm not found on cPanel host; deploying existing public/ files as-is."
fi

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete public/ "$DEPLOY_PATH/"
else
  rm -rf "$DEPLOY_PATH"/*
  cp -R public/. "$DEPLOY_PATH/"
fi

echo "Deployment complete."
