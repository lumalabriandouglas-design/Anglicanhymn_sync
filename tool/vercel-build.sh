#!/usr/bin/env bash
set -euo pipefail

# Vercel does not ship Flutter. Clone a shallow stable SDK, then build web.
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"

if [[ ! -x "$FLUTTER_DIR/bin/flutter" ]]; then
  echo "Cloning Flutter SDK..."
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"

flutter --version
flutter config --no-analytics --enable-web
flutter pub get
flutter build web --release
