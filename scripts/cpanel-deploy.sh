#!/usr/bin/env bash
set -euo pipefail

INPUT_TARGET="${1:-auto}"

resolve_deploy_path() {
  if [[ "$INPUT_TARGET" != "auto" ]]; then
    echo "$INPUT_TARGET"
    return
  fi

  for candidate in /home/*/beep.garcehorne.com/bubo; do
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done

  # Common cPanel docroot patterns for a subdomain like beep.garcehorne.com.
  if [[ -d "$HOME/public_html/beep.garcehorne.com" ]]; then
    echo "$HOME/public_html/beep.garcehorne.com/bubo"
    return
  fi

  if [[ -d "$HOME/public_html/beep" ]]; then
    echo "$HOME/public_html/beep/bubo"
    return
  fi

  echo "$HOME/public_html/bubo"
}

DEPLOY_PATH="$(resolve_deploy_path)"

echo "Deploying Bubo to: $DEPLOY_PATH"
echo "Working directory: $(pwd)"
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
