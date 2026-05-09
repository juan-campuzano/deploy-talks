#!/usr/bin/env bash
set -euo pipefail

# Instalar Flutter si no está disponible
if ! command -v flutter &> /dev/null; then
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.0-stable.tar.xz" \
    | tar -xJ -C "$HOME"
  export PATH="$PATH:$HOME/flutter/bin"
  flutter precache --web
fi

cd app

flutter build web \
  --dart-define=ADMIN_PASSWORD=$ADMIN_PASSWORD \
  --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
  --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
  --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID"
