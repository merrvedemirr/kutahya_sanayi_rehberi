#!/usr/bin/env bash
set -euo pipefail

# Netlify cache (varsa Flutter'ı tekrar indirmeyiz)
CACHE_DIR="${NETLIFY_CACHE_DIR:-$HOME/.cache}"
FLUTTER_DIR="$CACHE_DIR/flutter"

if [ -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Using cached Flutter..."
  export PATH="$FLUTTER_DIR/bin:$PATH"
else
  echo "Installing Flutter..."
  mkdir -p "$CACHE_DIR"
  git clone -b stable https://github.com/flutter/flutter.git --depth 1 "$FLUTTER_DIR"
  export PATH="$FLUTTER_DIR/bin:$PATH"
  flutter channel stable
  flutter config --enable-web --no-analytics
  flutter precache --web
fi

flutter --version
flutter pub get
flutter build web --release
